
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 17 37 10 80       	mov    $0x80103717,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 d4 89 10 	movl   $0x801089d4,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100049:	e8 cc 50 00 00       	call   8010511a <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 70 15 11 80 64 	movl   $0x80111564,0x80111570
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 74 15 11 80 64 	movl   $0x80111564,0x80111574
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 74 15 11 80       	mov    0x80111574,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 74 15 11 80       	mov    %eax,0x80111574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801000bd:	e8 79 50 00 00       	call   8010513b <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 74 15 11 80       	mov    0x80111574,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100104:	e8 94 50 00 00       	call   8010519d <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 d6 10 	movl   $0x8010d660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 86 4c 00 00       	call   80104daa <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 70 15 11 80       	mov    0x80111570,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010017c:	e8 1c 50 00 00       	call   8010519d <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 db 89 10 80 	movl   $0x801089db,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 c9 25 00 00       	call   801027a1 <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 ec 89 10 80 	movl   $0x801089ec,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 8c 25 00 00       	call   801027a1 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 f3 89 10 80 	movl   $0x801089f3,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010023c:	e8 fa 4e 00 00       	call   8010513b <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 74 15 11 80       	mov    0x80111574,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 74 15 11 80       	mov    %eax,0x80111574

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 4f 4c 00 00       	call   80104ef1 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801002a9:	e8 ef 4e 00 00       	call   8010519d <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 c1 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801003bb:	e8 7b 4d 00 00       	call   8010513b <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 fa 89 10 80 	movl   $0x801089fa,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 5a 03 00 00       	call   80100750 <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec 03 8a 10 80 	movl   $0x80108a03,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 84 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100533:	e8 65 4c 00 00       	call   8010519d <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 0a 8a 10 80 	movl   $0x80108a0a,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 19 8a 10 80 	movl   $0x80108a19,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 58 4c 00 00       	call   801051ec <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 1b 8a 10 80 	movl   $0x80108a1b,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x11c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 a7 4d 00 00       	call   8010545e <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006c6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 c8                	add    %ecx,%eax
801006d2:	89 54 24 08          	mov    %edx,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 04 24             	mov    %eax,(%esp)
801006e1:	e8 a9 4c 00 00       	call   8010538f <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 d3 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 ba fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 a6 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 90 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 87 fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 c6 65 00 00       	call   80106d41 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 ba 65 00 00       	call   80106d41 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 ae 65 00 00       	call   80106d41 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 a1 65 00 00       	call   80106d41 <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 1f fe ff ff       	call   801005ca <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
801007ba:	e8 7c 49 00 00       	call   8010513b <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 37 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 64                	je     8010083a <consoleintr+0x8d>
801007d6:	e9 91 00 00 00       	jmp    8010086c <consoleintr+0xbf>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 55                	je     8010083a <consoleintr+0x8d>
801007e5:	e9 82 00 00 00       	jmp    8010086c <consoleintr+0xbf>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 d8 47 00 00       	call   80104fc7 <procdump>
      break;
801007ef:	e9 07 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 3c 18 11 80       	mov    %eax,0x8011183c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
80100816:	a1 38 18 11 80       	mov    0x80111838,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	74 16                	je     80100835 <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100824:	83 e8 01             	sub    $0x1,%eax
80100827:	83 e0 7f             	and    $0x7f,%eax
8010082a:	0f b6 80 b4 17 11 80 	movzbl -0x7feee84c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100831:	3c 0a                	cmp    $0xa,%al
80100833:	75 bf                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100835:	e9 c1 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083a:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
80100840:	a1 38 18 11 80       	mov    0x80111838,%eax
80100845:	39 c2                	cmp    %eax,%edx
80100847:	74 1e                	je     80100867 <consoleintr+0xba>
        input.e--;
80100849:	a1 3c 18 11 80       	mov    0x8011183c,%eax
8010084e:	83 e8 01             	sub    $0x1,%eax
80100851:	a3 3c 18 11 80       	mov    %eax,0x8011183c
        consputc(BACKSPACE);
80100856:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010085d:	e8 ee fe ff ff       	call   80100750 <consputc>
      }
      break;
80100862:	e9 94 00 00 00       	jmp    801008fb <consoleintr+0x14e>
80100867:	e9 8f 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100870:	0f 84 84 00 00 00    	je     801008fa <consoleintr+0x14d>
80100876:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
8010087c:	a1 34 18 11 80       	mov    0x80111834,%eax
80100881:	29 c2                	sub    %eax,%edx
80100883:	89 d0                	mov    %edx,%eax
80100885:	83 f8 7f             	cmp    $0x7f,%eax
80100888:	77 70                	ja     801008fa <consoleintr+0x14d>
        c = (c == '\r') ? '\n' : c;
8010088a:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010088e:	74 05                	je     80100895 <consoleintr+0xe8>
80100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100893:	eb 05                	jmp    8010089a <consoleintr+0xed>
80100895:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010089d:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801008a2:	8d 50 01             	lea    0x1(%eax),%edx
801008a5:	89 15 3c 18 11 80    	mov    %edx,0x8011183c
801008ab:	83 e0 7f             	and    $0x7f,%eax
801008ae:	89 c2                	mov    %eax,%edx
801008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008b3:	88 82 b4 17 11 80    	mov    %al,-0x7feee84c(%edx)
        consputc(c);
801008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bc:	89 04 24             	mov    %eax,(%esp)
801008bf:	e8 8c fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c4:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008c8:	74 18                	je     801008e2 <consoleintr+0x135>
801008ca:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008ce:	74 12                	je     801008e2 <consoleintr+0x135>
801008d0:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801008d5:	8b 15 34 18 11 80    	mov    0x80111834,%edx
801008db:	83 ea 80             	sub    $0xffffff80,%edx
801008de:	39 d0                	cmp    %edx,%eax
801008e0:	75 18                	jne    801008fa <consoleintr+0x14d>
          input.w = input.e;
801008e2:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801008e7:	a3 38 18 11 80       	mov    %eax,0x80111838
          wakeup(&input.r);
801008ec:	c7 04 24 34 18 11 80 	movl   $0x80111834,(%esp)
801008f3:	e8 f9 45 00 00       	call   80104ef1 <wakeup>
        }
      }
      break;
801008f8:	eb 00                	jmp    801008fa <consoleintr+0x14d>
801008fa:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
801008fb:	8b 45 08             	mov    0x8(%ebp),%eax
801008fe:	ff d0                	call   *%eax
80100900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100907:	0f 89 b7 fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010090d:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100914:	e8 84 48 00 00       	call   8010519d <release>
}
80100919:	c9                   	leave  
8010091a:	c3                   	ret    

8010091b <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010091b:	55                   	push   %ebp
8010091c:	89 e5                	mov    %esp,%ebp
8010091e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100921:	8b 45 08             	mov    0x8(%ebp),%eax
80100924:	89 04 24             	mov    %eax,(%esp)
80100927:	e8 7d 10 00 00       	call   801019a9 <iunlock>
  target = n;
8010092c:	8b 45 10             	mov    0x10(%ebp),%eax
8010092f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100932:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100939:	e8 fd 47 00 00       	call   8010513b <acquire>
  while(n > 0){
8010093e:	e9 aa 00 00 00       	jmp    801009ed <consoleread+0xd2>
    while(input.r == input.w){
80100943:	eb 42                	jmp    80100987 <consoleread+0x6c>
      if(proc->killed){
80100945:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010094b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010094e:	85 c0                	test   %eax,%eax
80100950:	74 21                	je     80100973 <consoleread+0x58>
        release(&input.lock);
80100952:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100959:	e8 3f 48 00 00       	call   8010519d <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 f2 0e 00 00       	call   8010185b <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 80 17 11 	movl   $0x80111780,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 34 18 11 80 	movl   $0x80111834,(%esp)
80100982:	e8 23 44 00 00       	call   80104daa <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100987:	8b 15 34 18 11 80    	mov    0x80111834,%edx
8010098d:	a1 38 18 11 80       	mov    0x80111838,%eax
80100992:	39 c2                	cmp    %eax,%edx
80100994:	74 af                	je     80100945 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100996:	a1 34 18 11 80       	mov    0x80111834,%eax
8010099b:	8d 50 01             	lea    0x1(%eax),%edx
8010099e:	89 15 34 18 11 80    	mov    %edx,0x80111834
801009a4:	83 e0 7f             	and    $0x7f,%eax
801009a7:	0f b6 80 b4 17 11 80 	movzbl -0x7feee84c(%eax),%eax
801009ae:	0f be c0             	movsbl %al,%eax
801009b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009b4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009b8:	75 19                	jne    801009d3 <consoleread+0xb8>
      if(n < target){
801009ba:	8b 45 10             	mov    0x10(%ebp),%eax
801009bd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009c0:	73 0f                	jae    801009d1 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009c2:	a1 34 18 11 80       	mov    0x80111834,%eax
801009c7:	83 e8 01             	sub    $0x1,%eax
801009ca:	a3 34 18 11 80       	mov    %eax,0x80111834
      }
      break;
801009cf:	eb 26                	jmp    801009f7 <consoleread+0xdc>
801009d1:	eb 24                	jmp    801009f7 <consoleread+0xdc>
    }
    *dst++ = c;
801009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801009d6:	8d 50 01             	lea    0x1(%eax),%edx
801009d9:	89 55 0c             	mov    %edx,0xc(%ebp)
801009dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009df:	88 10                	mov    %dl,(%eax)
    --n;
801009e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009e5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009e9:	75 02                	jne    801009ed <consoleread+0xd2>
      break;
801009eb:	eb 0a                	jmp    801009f7 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f1:	0f 8f 4c ff ff ff    	jg     80100943 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
801009f7:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
801009fe:	e8 9a 47 00 00       	call   8010519d <release>
  ilock(ip);
80100a03:	8b 45 08             	mov    0x8(%ebp),%eax
80100a06:	89 04 24             	mov    %eax,(%esp)
80100a09:	e8 4d 0e 00 00       	call   8010185b <ilock>

  return target - n;
80100a0e:	8b 45 10             	mov    0x10(%ebp),%eax
80100a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a14:	29 c2                	sub    %eax,%edx
80100a16:	89 d0                	mov    %edx,%eax
}
80100a18:	c9                   	leave  
80100a19:	c3                   	ret    

80100a1a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a1a:	55                   	push   %ebp
80100a1b:	89 e5                	mov    %esp,%ebp
80100a1d:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	89 04 24             	mov    %eax,(%esp)
80100a26:	e8 7e 0f 00 00       	call   801019a9 <iunlock>
  acquire(&cons.lock);
80100a2b:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a32:	e8 04 47 00 00       	call   8010513b <acquire>
  for(i = 0; i < n; i++)
80100a37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a3e:	eb 1d                	jmp    80100a5d <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a46:	01 d0                	add    %edx,%eax
80100a48:	0f b6 00             	movzbl (%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	0f b6 c0             	movzbl %al,%eax
80100a51:	89 04 24             	mov    %eax,(%esp)
80100a54:	e8 f7 fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a60:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a63:	7c db                	jl     80100a40 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a65:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a6c:	e8 2c 47 00 00       	call   8010519d <release>
  ilock(ip);
80100a71:	8b 45 08             	mov    0x8(%ebp),%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 df 0d 00 00       	call   8010185b <ilock>

  return n;
80100a7c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a7f:	c9                   	leave  
80100a80:	c3                   	ret    

80100a81 <consoleinit>:

void
consoleinit(void)
{
80100a81:	55                   	push   %ebp
80100a82:	89 e5                	mov    %esp,%ebp
80100a84:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a87:	c7 44 24 04 1f 8a 10 	movl   $0x80108a1f,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a96:	e8 7f 46 00 00       	call   8010511a <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 27 8a 10 	movl   $0x80108a27,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100aaa:	e8 6b 46 00 00       	call   8010511a <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aaf:	c7 05 ec 21 11 80 1a 	movl   $0x80100a1a,0x801121ec
80100ab6:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ab9:	c7 05 e8 21 11 80 1b 	movl   $0x8010091b,0x801121e8
80100ac0:	09 10 80 
  cons.locking = 1;
80100ac3:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100aca:	00 00 00 

  picenable(IRQ_KBD);
80100acd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ad4:	e8 ed 32 00 00       	call   80103dc6 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100ae0:	00 
80100ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae8:	e8 70 1e 00 00       	call   8010295d <ioapicenable>
}
80100aed:	c9                   	leave  
80100aee:	c3                   	ret    

80100aef <exec>:
#include "elf.h"
#include "kthread.h"

int
exec(char *path, char **argv)
{
80100aef:	55                   	push   %ebp
80100af0:	89 e5                	mov    %esp,%ebp
80100af2:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100af8:	e8 13 29 00 00       	call   80103410 <begin_op>
  if((ip = namei(path)) == 0){
80100afd:	8b 45 08             	mov    0x8(%ebp),%eax
80100b00:	89 04 24             	mov    %eax,(%esp)
80100b03:	e8 fe 18 00 00       	call   80102406 <namei>
80100b08:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b0b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b0f:	75 0f                	jne    80100b20 <exec+0x31>
    end_op();
80100b11:	e8 7e 29 00 00       	call   80103494 <end_op>
    return -1;
80100b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b1b:	e9 e8 03 00 00       	jmp    80100f08 <exec+0x419>
  }
  ilock(ip);
80100b20:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b23:	89 04 24             	mov    %eax,(%esp)
80100b26:	e8 30 0d 00 00       	call   8010185b <ilock>
  pgdir = 0;
80100b2b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b32:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b39:	00 
80100b3a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b41:	00 
80100b42:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b4c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b4f:	89 04 24             	mov    %eax,(%esp)
80100b52:	e8 11 12 00 00       	call   80101d68 <readi>
80100b57:	83 f8 33             	cmp    $0x33,%eax
80100b5a:	77 05                	ja     80100b61 <exec+0x72>
    goto bad;
80100b5c:	e9 7b 03 00 00       	jmp    80100edc <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
80100b61:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b67:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b6c:	74 05                	je     80100b73 <exec+0x84>
    goto bad;
80100b6e:	e9 69 03 00 00       	jmp    80100edc <exec+0x3ed>

  if((pgdir = setupkvm()) == 0)
80100b73:	e8 1f 73 00 00       	call   80107e97 <setupkvm>
80100b78:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b7b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b7f:	75 05                	jne    80100b86 <exec+0x97>
    goto bad;
80100b81:	e9 56 03 00 00       	jmp    80100edc <exec+0x3ed>

  // Load program into memory.
  sz = 0;
80100b86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b8d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b94:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100b9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100b9d:	e9 cb 00 00 00       	jmp    80100c6d <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ba2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ba5:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bac:	00 
80100bad:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bb1:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bbb:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bbe:	89 04 24             	mov    %eax,(%esp)
80100bc1:	e8 a2 11 00 00       	call   80101d68 <readi>
80100bc6:	83 f8 20             	cmp    $0x20,%eax
80100bc9:	74 05                	je     80100bd0 <exec+0xe1>
      goto bad;
80100bcb:	e9 0c 03 00 00       	jmp    80100edc <exec+0x3ed>
    if(ph.type != ELF_PROG_LOAD)
80100bd0:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bd6:	83 f8 01             	cmp    $0x1,%eax
80100bd9:	74 05                	je     80100be0 <exec+0xf1>
      continue;
80100bdb:	e9 80 00 00 00       	jmp    80100c60 <exec+0x171>
    if(ph.memsz < ph.filesz)
80100be0:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100be6:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bec:	39 c2                	cmp    %eax,%edx
80100bee:	73 05                	jae    80100bf5 <exec+0x106>
      goto bad;
80100bf0:	e9 e7 02 00 00       	jmp    80100edc <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf5:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bfb:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c01:	01 d0                	add    %edx,%eax
80100c03:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c11:	89 04 24             	mov    %eax,(%esp)
80100c14:	e8 4c 76 00 00       	call   80108265 <allocuvm>
80100c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c20:	75 05                	jne    80100c27 <exec+0x138>
      goto bad;
80100c22:	e9 b5 02 00 00       	jmp    80100edc <exec+0x3ed>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c27:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c2d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c33:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c39:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c3d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c41:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c44:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c48:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c4f:	89 04 24             	mov    %eax,(%esp)
80100c52:	e8 23 75 00 00       	call   8010817a <loaduvm>
80100c57:	85 c0                	test   %eax,%eax
80100c59:	79 05                	jns    80100c60 <exec+0x171>
      goto bad;
80100c5b:	e9 7c 02 00 00       	jmp    80100edc <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c60:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c67:	83 c0 20             	add    $0x20,%eax
80100c6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c6d:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c74:	0f b7 c0             	movzwl %ax,%eax
80100c77:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c7a:	0f 8f 22 ff ff ff    	jg     80100ba2 <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c80:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c83:	89 04 24             	mov    %eax,(%esp)
80100c86:	e8 54 0e 00 00       	call   80101adf <iunlockput>
  end_op();
80100c8b:	e8 04 28 00 00       	call   80103494 <end_op>
  ip = 0;
80100c90:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c9a:	05 ff 0f 00 00       	add    $0xfff,%eax
80100c9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ca4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ca7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100caa:	05 00 20 00 00       	add    $0x2000,%eax
80100caf:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cbd:	89 04 24             	mov    %eax,(%esp)
80100cc0:	e8 a0 75 00 00       	call   80108265 <allocuvm>
80100cc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ccc:	75 05                	jne    80100cd3 <exec+0x1e4>
    goto bad;
80100cce:	e9 09 02 00 00       	jmp    80100edc <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cdf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ce2:	89 04 24             	mov    %eax,(%esp)
80100ce5:	e8 ab 77 00 00       	call   80108495 <clearpteu>
  sp = sz;
80100cea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ced:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100cf0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cf7:	e9 9a 00 00 00       	jmp    80100d96 <exec+0x2a7>
    if(argc >= MAXARG)
80100cfc:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d00:	76 05                	jbe    80100d07 <exec+0x218>
      goto bad;
80100d02:	e9 d5 01 00 00       	jmp    80100edc <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d11:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d14:	01 d0                	add    %edx,%eax
80100d16:	8b 00                	mov    (%eax),%eax
80100d18:	89 04 24             	mov    %eax,(%esp)
80100d1b:	e8 d9 48 00 00       	call   801055f9 <strlen>
80100d20:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d23:	29 c2                	sub    %eax,%edx
80100d25:	89 d0                	mov    %edx,%eax
80100d27:	83 e8 01             	sub    $0x1,%eax
80100d2a:	83 e0 fc             	and    $0xfffffffc,%eax
80100d2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d3d:	01 d0                	add    %edx,%eax
80100d3f:	8b 00                	mov    (%eax),%eax
80100d41:	89 04 24             	mov    %eax,(%esp)
80100d44:	e8 b0 48 00 00       	call   801055f9 <strlen>
80100d49:	83 c0 01             	add    $0x1,%eax
80100d4c:	89 c2                	mov    %eax,%edx
80100d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d51:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d58:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d5b:	01 c8                	add    %ecx,%eax
80100d5d:	8b 00                	mov    (%eax),%eax
80100d5f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d63:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d67:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d71:	89 04 24             	mov    %eax,(%esp)
80100d74:	e8 e1 78 00 00       	call   8010865a <copyout>
80100d79:	85 c0                	test   %eax,%eax
80100d7b:	79 05                	jns    80100d82 <exec+0x293>
      goto bad;
80100d7d:	e9 5a 01 00 00       	jmp    80100edc <exec+0x3ed>
    ustack[3+argc] = sp;
80100d82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d85:	8d 50 03             	lea    0x3(%eax),%edx
80100d88:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d8b:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d92:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100da3:	01 d0                	add    %edx,%eax
80100da5:	8b 00                	mov    (%eax),%eax
80100da7:	85 c0                	test   %eax,%eax
80100da9:	0f 85 4d ff ff ff    	jne    80100cfc <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100daf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db2:	83 c0 03             	add    $0x3,%eax
80100db5:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dbc:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100dc0:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dc7:	ff ff ff 
  ustack[1] = argc;
80100dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcd:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd6:	83 c0 01             	add    $0x1,%eax
80100dd9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de3:	29 d0                	sub    %edx,%eax
80100de5:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	83 c0 04             	add    $0x4,%eax
80100df1:	c1 e0 02             	shl    $0x2,%eax
80100df4:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfa:	83 c0 04             	add    $0x4,%eax
80100dfd:	c1 e0 02             	shl    $0x2,%eax
80100e00:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e04:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e11:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e18:	89 04 24             	mov    %eax,(%esp)
80100e1b:	e8 3a 78 00 00       	call   8010865a <copyout>
80100e20:	85 c0                	test   %eax,%eax
80100e22:	79 05                	jns    80100e29 <exec+0x33a>
    goto bad;
80100e24:	e9 b3 00 00 00       	jmp    80100edc <exec+0x3ed>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e29:	8b 45 08             	mov    0x8(%ebp),%eax
80100e2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e32:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e35:	eb 17                	jmp    80100e4e <exec+0x35f>
    if(*s == '/')
80100e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e3a:	0f b6 00             	movzbl (%eax),%eax
80100e3d:	3c 2f                	cmp    $0x2f,%al
80100e3f:	75 09                	jne    80100e4a <exec+0x35b>
      last = s+1;
80100e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e44:	83 c0 01             	add    $0x1,%eax
80100e47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e4a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e51:	0f b6 00             	movzbl (%eax),%eax
80100e54:	84 c0                	test   %al,%al
80100e56:	75 df                	jne    80100e37 <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e5e:	8d 50 64             	lea    0x64(%eax),%edx
80100e61:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e68:	00 
80100e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e70:	89 14 24             	mov    %edx,(%esp)
80100e73:	e8 37 47 00 00       	call   801055af <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7e:	8b 40 04             	mov    0x4(%eax),%eax
80100e81:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e8a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e8d:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e96:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e99:	89 10                	mov    %edx,(%eax)
  thread->tf->eip = elf.entry;  // main
80100e9b:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80100ea1:	8b 40 10             	mov    0x10(%eax),%eax
80100ea4:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100eaa:	89 50 38             	mov    %edx,0x38(%eax)
  thread->tf->esp = sp;
80100ead:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80100eb3:	8b 40 10             	mov    0x10(%eax),%eax
80100eb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eb9:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ebc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec2:	89 04 24             	mov    %eax,(%esp)
80100ec5:	e8 be 70 00 00       	call   80107f88 <switchuvm>
  freevm(oldpgdir);
80100eca:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ecd:	89 04 24             	mov    %eax,(%esp)
80100ed0:	e8 26 75 00 00       	call   801083fb <freevm>
  return 0;
80100ed5:	b8 00 00 00 00       	mov    $0x0,%eax
80100eda:	eb 2c                	jmp    80100f08 <exec+0x419>

 bad:
  if(pgdir)
80100edc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ee0:	74 0b                	je     80100eed <exec+0x3fe>
    freevm(pgdir);
80100ee2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ee5:	89 04 24             	mov    %eax,(%esp)
80100ee8:	e8 0e 75 00 00       	call   801083fb <freevm>
  if(ip){
80100eed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ef1:	74 10                	je     80100f03 <exec+0x414>
    iunlockput(ip);
80100ef3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ef6:	89 04 24             	mov    %eax,(%esp)
80100ef9:	e8 e1 0b 00 00       	call   80101adf <iunlockput>
    end_op();
80100efe:	e8 91 25 00 00       	call   80103494 <end_op>
  }
  return -1;
80100f03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f08:	c9                   	leave  
80100f09:	c3                   	ret    

80100f0a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f0a:	55                   	push   %ebp
80100f0b:	89 e5                	mov    %esp,%ebp
80100f0d:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f10:	c7 44 24 04 2d 8a 10 	movl   $0x80108a2d,0x4(%esp)
80100f17:	80 
80100f18:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f1f:	e8 f6 41 00 00       	call   8010511a <initlock>
}
80100f24:	c9                   	leave  
80100f25:	c3                   	ret    

80100f26 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f26:	55                   	push   %ebp
80100f27:	89 e5                	mov    %esp,%ebp
80100f29:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f2c:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f33:	e8 03 42 00 00       	call   8010513b <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f38:	c7 45 f4 74 18 11 80 	movl   $0x80111874,-0xc(%ebp)
80100f3f:	eb 29                	jmp    80100f6a <filealloc+0x44>
    if(f->ref == 0){
80100f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f44:	8b 40 04             	mov    0x4(%eax),%eax
80100f47:	85 c0                	test   %eax,%eax
80100f49:	75 1b                	jne    80100f66 <filealloc+0x40>
      f->ref = 1;
80100f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f4e:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f55:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f5c:	e8 3c 42 00 00       	call   8010519d <release>
      return f;
80100f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f64:	eb 1e                	jmp    80100f84 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f66:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f6a:	81 7d f4 d4 21 11 80 	cmpl   $0x801121d4,-0xc(%ebp)
80100f71:	72 ce                	jb     80100f41 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f73:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f7a:	e8 1e 42 00 00       	call   8010519d <release>
  return 0;
80100f7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f84:	c9                   	leave  
80100f85:	c3                   	ret    

80100f86 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f86:	55                   	push   %ebp
80100f87:	89 e5                	mov    %esp,%ebp
80100f89:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f8c:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f93:	e8 a3 41 00 00       	call   8010513b <acquire>
  if(f->ref < 1)
80100f98:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9b:	8b 40 04             	mov    0x4(%eax),%eax
80100f9e:	85 c0                	test   %eax,%eax
80100fa0:	7f 0c                	jg     80100fae <filedup+0x28>
    panic("filedup");
80100fa2:	c7 04 24 34 8a 10 80 	movl   $0x80108a34,(%esp)
80100fa9:	e8 8c f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fae:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb1:	8b 40 04             	mov    0x4(%eax),%eax
80100fb4:	8d 50 01             	lea    0x1(%eax),%edx
80100fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80100fba:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbd:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100fc4:	e8 d4 41 00 00       	call   8010519d <release>
  return f;
80100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fcc:	c9                   	leave  
80100fcd:	c3                   	ret    

80100fce <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fce:	55                   	push   %ebp
80100fcf:	89 e5                	mov    %esp,%ebp
80100fd1:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fd4:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100fdb:	e8 5b 41 00 00       	call   8010513b <acquire>
  if(f->ref < 1)
80100fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe3:	8b 40 04             	mov    0x4(%eax),%eax
80100fe6:	85 c0                	test   %eax,%eax
80100fe8:	7f 0c                	jg     80100ff6 <fileclose+0x28>
    panic("fileclose");
80100fea:	c7 04 24 3c 8a 10 80 	movl   $0x80108a3c,(%esp)
80100ff1:	e8 44 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80100ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff9:	8b 40 04             	mov    0x4(%eax),%eax
80100ffc:	8d 50 ff             	lea    -0x1(%eax),%edx
80100fff:	8b 45 08             	mov    0x8(%ebp),%eax
80101002:	89 50 04             	mov    %edx,0x4(%eax)
80101005:	8b 45 08             	mov    0x8(%ebp),%eax
80101008:	8b 40 04             	mov    0x4(%eax),%eax
8010100b:	85 c0                	test   %eax,%eax
8010100d:	7e 11                	jle    80101020 <fileclose+0x52>
    release(&ftable.lock);
8010100f:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80101016:	e8 82 41 00 00       	call   8010519d <release>
8010101b:	e9 82 00 00 00       	jmp    801010a2 <fileclose+0xd4>
    return;
  }
  ff = *f;
80101020:	8b 45 08             	mov    0x8(%ebp),%eax
80101023:	8b 10                	mov    (%eax),%edx
80101025:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101028:	8b 50 04             	mov    0x4(%eax),%edx
8010102b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010102e:	8b 50 08             	mov    0x8(%eax),%edx
80101031:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101034:	8b 50 0c             	mov    0xc(%eax),%edx
80101037:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010103a:	8b 50 10             	mov    0x10(%eax),%edx
8010103d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101040:	8b 40 14             	mov    0x14(%eax),%eax
80101043:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101046:	8b 45 08             	mov    0x8(%ebp),%eax
80101049:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101050:	8b 45 08             	mov    0x8(%ebp),%eax
80101053:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101059:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80101060:	e8 38 41 00 00       	call   8010519d <release>
  
  if(ff.type == FD_PIPE)
80101065:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101068:	83 f8 01             	cmp    $0x1,%eax
8010106b:	75 18                	jne    80101085 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010106d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101071:	0f be d0             	movsbl %al,%edx
80101074:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101077:	89 54 24 04          	mov    %edx,0x4(%esp)
8010107b:	89 04 24             	mov    %eax,(%esp)
8010107e:	e8 f3 2f 00 00       	call   80104076 <pipeclose>
80101083:	eb 1d                	jmp    801010a2 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101085:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101088:	83 f8 02             	cmp    $0x2,%eax
8010108b:	75 15                	jne    801010a2 <fileclose+0xd4>
    begin_op();
8010108d:	e8 7e 23 00 00       	call   80103410 <begin_op>
    iput(ff.ip);
80101092:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101095:	89 04 24             	mov    %eax,(%esp)
80101098:	e8 71 09 00 00       	call   80101a0e <iput>
    end_op();
8010109d:	e8 f2 23 00 00       	call   80103494 <end_op>
  }
}
801010a2:	c9                   	leave  
801010a3:	c3                   	ret    

801010a4 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010a4:	55                   	push   %ebp
801010a5:	89 e5                	mov    %esp,%ebp
801010a7:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010aa:	8b 45 08             	mov    0x8(%ebp),%eax
801010ad:	8b 00                	mov    (%eax),%eax
801010af:	83 f8 02             	cmp    $0x2,%eax
801010b2:	75 38                	jne    801010ec <filestat+0x48>
    ilock(f->ip);
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	8b 40 10             	mov    0x10(%eax),%eax
801010ba:	89 04 24             	mov    %eax,(%esp)
801010bd:	e8 99 07 00 00       	call   8010185b <ilock>
    stati(f->ip, st);
801010c2:	8b 45 08             	mov    0x8(%ebp),%eax
801010c5:	8b 40 10             	mov    0x10(%eax),%eax
801010c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801010cb:	89 54 24 04          	mov    %edx,0x4(%esp)
801010cf:	89 04 24             	mov    %eax,(%esp)
801010d2:	e8 4c 0c 00 00       	call   80101d23 <stati>
    iunlock(f->ip);
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 10             	mov    0x10(%eax),%eax
801010dd:	89 04 24             	mov    %eax,(%esp)
801010e0:	e8 c4 08 00 00       	call   801019a9 <iunlock>
    return 0;
801010e5:	b8 00 00 00 00       	mov    $0x0,%eax
801010ea:	eb 05                	jmp    801010f1 <filestat+0x4d>
  }
  return -1;
801010ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010f1:	c9                   	leave  
801010f2:	c3                   	ret    

801010f3 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010f3:	55                   	push   %ebp
801010f4:	89 e5                	mov    %esp,%ebp
801010f6:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010f9:	8b 45 08             	mov    0x8(%ebp),%eax
801010fc:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101100:	84 c0                	test   %al,%al
80101102:	75 0a                	jne    8010110e <fileread+0x1b>
    return -1;
80101104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101109:	e9 9f 00 00 00       	jmp    801011ad <fileread+0xba>
  if(f->type == FD_PIPE)
8010110e:	8b 45 08             	mov    0x8(%ebp),%eax
80101111:	8b 00                	mov    (%eax),%eax
80101113:	83 f8 01             	cmp    $0x1,%eax
80101116:	75 1e                	jne    80101136 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101118:	8b 45 08             	mov    0x8(%ebp),%eax
8010111b:	8b 40 0c             	mov    0xc(%eax),%eax
8010111e:	8b 55 10             	mov    0x10(%ebp),%edx
80101121:	89 54 24 08          	mov    %edx,0x8(%esp)
80101125:	8b 55 0c             	mov    0xc(%ebp),%edx
80101128:	89 54 24 04          	mov    %edx,0x4(%esp)
8010112c:	89 04 24             	mov    %eax,(%esp)
8010112f:	e8 c3 30 00 00       	call   801041f7 <piperead>
80101134:	eb 77                	jmp    801011ad <fileread+0xba>
  if(f->type == FD_INODE){
80101136:	8b 45 08             	mov    0x8(%ebp),%eax
80101139:	8b 00                	mov    (%eax),%eax
8010113b:	83 f8 02             	cmp    $0x2,%eax
8010113e:	75 61                	jne    801011a1 <fileread+0xae>
    ilock(f->ip);
80101140:	8b 45 08             	mov    0x8(%ebp),%eax
80101143:	8b 40 10             	mov    0x10(%eax),%eax
80101146:	89 04 24             	mov    %eax,(%esp)
80101149:	e8 0d 07 00 00       	call   8010185b <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010114e:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101151:	8b 45 08             	mov    0x8(%ebp),%eax
80101154:	8b 50 14             	mov    0x14(%eax),%edx
80101157:	8b 45 08             	mov    0x8(%ebp),%eax
8010115a:	8b 40 10             	mov    0x10(%eax),%eax
8010115d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101161:	89 54 24 08          	mov    %edx,0x8(%esp)
80101165:	8b 55 0c             	mov    0xc(%ebp),%edx
80101168:	89 54 24 04          	mov    %edx,0x4(%esp)
8010116c:	89 04 24             	mov    %eax,(%esp)
8010116f:	e8 f4 0b 00 00       	call   80101d68 <readi>
80101174:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101177:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010117b:	7e 11                	jle    8010118e <fileread+0x9b>
      f->off += r;
8010117d:	8b 45 08             	mov    0x8(%ebp),%eax
80101180:	8b 50 14             	mov    0x14(%eax),%edx
80101183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101186:	01 c2                	add    %eax,%edx
80101188:	8b 45 08             	mov    0x8(%ebp),%eax
8010118b:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010118e:	8b 45 08             	mov    0x8(%ebp),%eax
80101191:	8b 40 10             	mov    0x10(%eax),%eax
80101194:	89 04 24             	mov    %eax,(%esp)
80101197:	e8 0d 08 00 00       	call   801019a9 <iunlock>
    return r;
8010119c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010119f:	eb 0c                	jmp    801011ad <fileread+0xba>
  }
  panic("fileread");
801011a1:	c7 04 24 46 8a 10 80 	movl   $0x80108a46,(%esp)
801011a8:	e8 8d f3 ff ff       	call   8010053a <panic>
}
801011ad:	c9                   	leave  
801011ae:	c3                   	ret    

801011af <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011af:	55                   	push   %ebp
801011b0:	89 e5                	mov    %esp,%ebp
801011b2:	53                   	push   %ebx
801011b3:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011b6:	8b 45 08             	mov    0x8(%ebp),%eax
801011b9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011bd:	84 c0                	test   %al,%al
801011bf:	75 0a                	jne    801011cb <filewrite+0x1c>
    return -1;
801011c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011c6:	e9 20 01 00 00       	jmp    801012eb <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011cb:	8b 45 08             	mov    0x8(%ebp),%eax
801011ce:	8b 00                	mov    (%eax),%eax
801011d0:	83 f8 01             	cmp    $0x1,%eax
801011d3:	75 21                	jne    801011f6 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011d5:	8b 45 08             	mov    0x8(%ebp),%eax
801011d8:	8b 40 0c             	mov    0xc(%eax),%eax
801011db:	8b 55 10             	mov    0x10(%ebp),%edx
801011de:	89 54 24 08          	mov    %edx,0x8(%esp)
801011e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801011e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801011e9:	89 04 24             	mov    %eax,(%esp)
801011ec:	e8 17 2f 00 00       	call   80104108 <pipewrite>
801011f1:	e9 f5 00 00 00       	jmp    801012eb <filewrite+0x13c>
  if(f->type == FD_INODE){
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 00                	mov    (%eax),%eax
801011fb:	83 f8 02             	cmp    $0x2,%eax
801011fe:	0f 85 db 00 00 00    	jne    801012df <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101204:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010120b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101212:	e9 a8 00 00 00       	jmp    801012bf <filewrite+0x110>
      int n1 = n - i;
80101217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121a:	8b 55 10             	mov    0x10(%ebp),%edx
8010121d:	29 c2                	sub    %eax,%edx
8010121f:	89 d0                	mov    %edx,%eax
80101221:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101224:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101227:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010122a:	7e 06                	jle    80101232 <filewrite+0x83>
        n1 = max;
8010122c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010122f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101232:	e8 d9 21 00 00       	call   80103410 <begin_op>
      ilock(f->ip);
80101237:	8b 45 08             	mov    0x8(%ebp),%eax
8010123a:	8b 40 10             	mov    0x10(%eax),%eax
8010123d:	89 04 24             	mov    %eax,(%esp)
80101240:	e8 16 06 00 00       	call   8010185b <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101245:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 50 14             	mov    0x14(%eax),%edx
8010124e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101251:	8b 45 0c             	mov    0xc(%ebp),%eax
80101254:	01 c3                	add    %eax,%ebx
80101256:	8b 45 08             	mov    0x8(%ebp),%eax
80101259:	8b 40 10             	mov    0x10(%eax),%eax
8010125c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101260:	89 54 24 08          	mov    %edx,0x8(%esp)
80101264:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101268:	89 04 24             	mov    %eax,(%esp)
8010126b:	e8 5c 0c 00 00       	call   80101ecc <writei>
80101270:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101273:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101277:	7e 11                	jle    8010128a <filewrite+0xdb>
        f->off += r;
80101279:	8b 45 08             	mov    0x8(%ebp),%eax
8010127c:	8b 50 14             	mov    0x14(%eax),%edx
8010127f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101282:	01 c2                	add    %eax,%edx
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010128a:	8b 45 08             	mov    0x8(%ebp),%eax
8010128d:	8b 40 10             	mov    0x10(%eax),%eax
80101290:	89 04 24             	mov    %eax,(%esp)
80101293:	e8 11 07 00 00       	call   801019a9 <iunlock>
      end_op();
80101298:	e8 f7 21 00 00       	call   80103494 <end_op>

      if(r < 0)
8010129d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012a1:	79 02                	jns    801012a5 <filewrite+0xf6>
        break;
801012a3:	eb 26                	jmp    801012cb <filewrite+0x11c>
      if(r != n1)
801012a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012a8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012ab:	74 0c                	je     801012b9 <filewrite+0x10a>
        panic("short filewrite");
801012ad:	c7 04 24 4f 8a 10 80 	movl   $0x80108a4f,(%esp)
801012b4:	e8 81 f2 ff ff       	call   8010053a <panic>
      i += r;
801012b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012bc:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c2:	3b 45 10             	cmp    0x10(%ebp),%eax
801012c5:	0f 8c 4c ff ff ff    	jl     80101217 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ce:	3b 45 10             	cmp    0x10(%ebp),%eax
801012d1:	75 05                	jne    801012d8 <filewrite+0x129>
801012d3:	8b 45 10             	mov    0x10(%ebp),%eax
801012d6:	eb 05                	jmp    801012dd <filewrite+0x12e>
801012d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012dd:	eb 0c                	jmp    801012eb <filewrite+0x13c>
  }
  panic("filewrite");
801012df:	c7 04 24 5f 8a 10 80 	movl   $0x80108a5f,(%esp)
801012e6:	e8 4f f2 ff ff       	call   8010053a <panic>
}
801012eb:	83 c4 24             	add    $0x24,%esp
801012ee:	5b                   	pop    %ebx
801012ef:	5d                   	pop    %ebp
801012f0:	c3                   	ret    

801012f1 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012f1:	55                   	push   %ebp
801012f2:	89 e5                	mov    %esp,%ebp
801012f4:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012f7:	8b 45 08             	mov    0x8(%ebp),%eax
801012fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101301:	00 
80101302:	89 04 24             	mov    %eax,(%esp)
80101305:	e8 9c ee ff ff       	call   801001a6 <bread>
8010130a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010130d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101310:	83 c0 18             	add    $0x18,%eax
80101313:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010131a:	00 
8010131b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010131f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101322:	89 04 24             	mov    %eax,(%esp)
80101325:	e8 34 41 00 00       	call   8010545e <memmove>
  brelse(bp);
8010132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132d:	89 04 24             	mov    %eax,(%esp)
80101330:	e8 e2 ee ff ff       	call   80100217 <brelse>
}
80101335:	c9                   	leave  
80101336:	c3                   	ret    

80101337 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101337:	55                   	push   %ebp
80101338:	89 e5                	mov    %esp,%ebp
8010133a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010133d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101340:	8b 45 08             	mov    0x8(%ebp),%eax
80101343:	89 54 24 04          	mov    %edx,0x4(%esp)
80101347:	89 04 24             	mov    %eax,(%esp)
8010134a:	e8 57 ee ff ff       	call   801001a6 <bread>
8010134f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101355:	83 c0 18             	add    $0x18,%eax
80101358:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010135f:	00 
80101360:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101367:	00 
80101368:	89 04 24             	mov    %eax,(%esp)
8010136b:	e8 1f 40 00 00       	call   8010538f <memset>
  log_write(bp);
80101370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101373:	89 04 24             	mov    %eax,(%esp)
80101376:	e8 a0 22 00 00       	call   8010361b <log_write>
  brelse(bp);
8010137b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137e:	89 04 24             	mov    %eax,(%esp)
80101381:	e8 91 ee ff ff       	call   80100217 <brelse>
}
80101386:	c9                   	leave  
80101387:	c3                   	ret    

80101388 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101388:	55                   	push   %ebp
80101389:	89 e5                	mov    %esp,%ebp
8010138b:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010138e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101395:	8b 45 08             	mov    0x8(%ebp),%eax
80101398:	8d 55 d8             	lea    -0x28(%ebp),%edx
8010139b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010139f:	89 04 24             	mov    %eax,(%esp)
801013a2:	e8 4a ff ff ff       	call   801012f1 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013ae:	e9 07 01 00 00       	jmp    801014ba <balloc+0x132>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013bc:	85 c0                	test   %eax,%eax
801013be:	0f 48 c2             	cmovs  %edx,%eax
801013c1:	c1 f8 0c             	sar    $0xc,%eax
801013c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013c7:	c1 ea 03             	shr    $0x3,%edx
801013ca:	01 d0                	add    %edx,%eax
801013cc:	83 c0 03             	add    $0x3,%eax
801013cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801013d3:	8b 45 08             	mov    0x8(%ebp),%eax
801013d6:	89 04 24             	mov    %eax,(%esp)
801013d9:	e8 c8 ed ff ff       	call   801001a6 <bread>
801013de:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013e8:	e9 9d 00 00 00       	jmp    8010148a <balloc+0x102>
      m = 1 << (bi % 8);
801013ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f0:	99                   	cltd   
801013f1:	c1 ea 1d             	shr    $0x1d,%edx
801013f4:	01 d0                	add    %edx,%eax
801013f6:	83 e0 07             	and    $0x7,%eax
801013f9:	29 d0                	sub    %edx,%eax
801013fb:	ba 01 00 00 00       	mov    $0x1,%edx
80101400:	89 c1                	mov    %eax,%ecx
80101402:	d3 e2                	shl    %cl,%edx
80101404:	89 d0                	mov    %edx,%eax
80101406:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010140c:	8d 50 07             	lea    0x7(%eax),%edx
8010140f:	85 c0                	test   %eax,%eax
80101411:	0f 48 c2             	cmovs  %edx,%eax
80101414:	c1 f8 03             	sar    $0x3,%eax
80101417:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010141a:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010141f:	0f b6 c0             	movzbl %al,%eax
80101422:	23 45 e8             	and    -0x18(%ebp),%eax
80101425:	85 c0                	test   %eax,%eax
80101427:	75 5d                	jne    80101486 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
80101429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010142c:	8d 50 07             	lea    0x7(%eax),%edx
8010142f:	85 c0                	test   %eax,%eax
80101431:	0f 48 c2             	cmovs  %edx,%eax
80101434:	c1 f8 03             	sar    $0x3,%eax
80101437:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010143a:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010143f:	89 d1                	mov    %edx,%ecx
80101441:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101444:	09 ca                	or     %ecx,%edx
80101446:	89 d1                	mov    %edx,%ecx
80101448:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010144b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010144f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101452:	89 04 24             	mov    %eax,(%esp)
80101455:	e8 c1 21 00 00       	call   8010361b <log_write>
        brelse(bp);
8010145a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010145d:	89 04 24             	mov    %eax,(%esp)
80101460:	e8 b2 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101465:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101468:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010146b:	01 c2                	add    %eax,%edx
8010146d:	8b 45 08             	mov    0x8(%ebp),%eax
80101470:	89 54 24 04          	mov    %edx,0x4(%esp)
80101474:	89 04 24             	mov    %eax,(%esp)
80101477:	e8 bb fe ff ff       	call   80101337 <bzero>
        return b + bi;
8010147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010147f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101482:	01 d0                	add    %edx,%eax
80101484:	eb 4e                	jmp    801014d4 <balloc+0x14c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101486:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010148a:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101491:	7f 15                	jg     801014a8 <balloc+0x120>
80101493:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101496:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101499:	01 d0                	add    %edx,%eax
8010149b:	89 c2                	mov    %eax,%edx
8010149d:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014a0:	39 c2                	cmp    %eax,%edx
801014a2:	0f 82 45 ff ff ff    	jb     801013ed <balloc+0x65>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014ab:	89 04 24             	mov    %eax,(%esp)
801014ae:	e8 64 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014b3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014c0:	39 c2                	cmp    %eax,%edx
801014c2:	0f 82 eb fe ff ff    	jb     801013b3 <balloc+0x2b>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014c8:	c7 04 24 69 8a 10 80 	movl   $0x80108a69,(%esp)
801014cf:	e8 66 f0 ff ff       	call   8010053a <panic>
}
801014d4:	c9                   	leave  
801014d5:	c3                   	ret    

801014d6 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014d6:	55                   	push   %ebp
801014d7:	89 e5                	mov    %esp,%ebp
801014d9:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014dc:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014df:	89 44 24 04          	mov    %eax,0x4(%esp)
801014e3:	8b 45 08             	mov    0x8(%ebp),%eax
801014e6:	89 04 24             	mov    %eax,(%esp)
801014e9:	e8 03 fe ff ff       	call   801012f1 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801014f1:	c1 e8 0c             	shr    $0xc,%eax
801014f4:	89 c2                	mov    %eax,%edx
801014f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014f9:	c1 e8 03             	shr    $0x3,%eax
801014fc:	01 d0                	add    %edx,%eax
801014fe:	8d 50 03             	lea    0x3(%eax),%edx
80101501:	8b 45 08             	mov    0x8(%ebp),%eax
80101504:	89 54 24 04          	mov    %edx,0x4(%esp)
80101508:	89 04 24             	mov    %eax,(%esp)
8010150b:	e8 96 ec ff ff       	call   801001a6 <bread>
80101510:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101513:	8b 45 0c             	mov    0xc(%ebp),%eax
80101516:	25 ff 0f 00 00       	and    $0xfff,%eax
8010151b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101521:	99                   	cltd   
80101522:	c1 ea 1d             	shr    $0x1d,%edx
80101525:	01 d0                	add    %edx,%eax
80101527:	83 e0 07             	and    $0x7,%eax
8010152a:	29 d0                	sub    %edx,%eax
8010152c:	ba 01 00 00 00       	mov    $0x1,%edx
80101531:	89 c1                	mov    %eax,%ecx
80101533:	d3 e2                	shl    %cl,%edx
80101535:	89 d0                	mov    %edx,%eax
80101537:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	8d 50 07             	lea    0x7(%eax),%edx
80101540:	85 c0                	test   %eax,%eax
80101542:	0f 48 c2             	cmovs  %edx,%eax
80101545:	c1 f8 03             	sar    $0x3,%eax
80101548:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010154b:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101550:	0f b6 c0             	movzbl %al,%eax
80101553:	23 45 ec             	and    -0x14(%ebp),%eax
80101556:	85 c0                	test   %eax,%eax
80101558:	75 0c                	jne    80101566 <bfree+0x90>
    panic("freeing free block");
8010155a:	c7 04 24 7f 8a 10 80 	movl   $0x80108a7f,(%esp)
80101561:	e8 d4 ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101569:	8d 50 07             	lea    0x7(%eax),%edx
8010156c:	85 c0                	test   %eax,%eax
8010156e:	0f 48 c2             	cmovs  %edx,%eax
80101571:	c1 f8 03             	sar    $0x3,%eax
80101574:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101577:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010157c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010157f:	f7 d1                	not    %ecx
80101581:	21 ca                	and    %ecx,%edx
80101583:	89 d1                	mov    %edx,%ecx
80101585:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101588:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010158c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010158f:	89 04 24             	mov    %eax,(%esp)
80101592:	e8 84 20 00 00       	call   8010361b <log_write>
  brelse(bp);
80101597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159a:	89 04 24             	mov    %eax,(%esp)
8010159d:	e8 75 ec ff ff       	call   80100217 <brelse>
}
801015a2:	c9                   	leave  
801015a3:	c3                   	ret    

801015a4 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015a4:	55                   	push   %ebp
801015a5:	89 e5                	mov    %esp,%ebp
801015a7:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015aa:	c7 44 24 04 92 8a 10 	movl   $0x80108a92,0x4(%esp)
801015b1:	80 
801015b2:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
801015b9:	e8 5c 3b 00 00       	call   8010511a <initlock>
}
801015be:	c9                   	leave  
801015bf:	c3                   	ret    

801015c0 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015c0:	55                   	push   %ebp
801015c1:	89 e5                	mov    %esp,%ebp
801015c3:	83 ec 38             	sub    $0x38,%esp
801015c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c9:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015cd:	8b 45 08             	mov    0x8(%ebp),%eax
801015d0:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801015d7:	89 04 24             	mov    %eax,(%esp)
801015da:	e8 12 fd ff ff       	call   801012f1 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015df:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015e6:	e9 98 00 00 00       	jmp    80101683 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ee:	c1 e8 03             	shr    $0x3,%eax
801015f1:	83 c0 02             	add    $0x2,%eax
801015f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801015f8:	8b 45 08             	mov    0x8(%ebp),%eax
801015fb:	89 04 24             	mov    %eax,(%esp)
801015fe:	e8 a3 eb ff ff       	call   801001a6 <bread>
80101603:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101606:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101609:	8d 50 18             	lea    0x18(%eax),%edx
8010160c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160f:	83 e0 07             	and    $0x7,%eax
80101612:	c1 e0 06             	shl    $0x6,%eax
80101615:	01 d0                	add    %edx,%eax
80101617:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010161a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010161d:	0f b7 00             	movzwl (%eax),%eax
80101620:	66 85 c0             	test   %ax,%ax
80101623:	75 4f                	jne    80101674 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101625:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010162c:	00 
8010162d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101634:	00 
80101635:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101638:	89 04 24             	mov    %eax,(%esp)
8010163b:	e8 4f 3d 00 00       	call   8010538f <memset>
      dip->type = type;
80101640:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101643:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101647:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164d:	89 04 24             	mov    %eax,(%esp)
80101650:	e8 c6 1f 00 00       	call   8010361b <log_write>
      brelse(bp);
80101655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101658:	89 04 24             	mov    %eax,(%esp)
8010165b:	e8 b7 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101663:	89 44 24 04          	mov    %eax,0x4(%esp)
80101667:	8b 45 08             	mov    0x8(%ebp),%eax
8010166a:	89 04 24             	mov    %eax,(%esp)
8010166d:	e8 e5 00 00 00       	call   80101757 <iget>
80101672:	eb 29                	jmp    8010169d <ialloc+0xdd>
    }
    brelse(bp);
80101674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101677:	89 04 24             	mov    %eax,(%esp)
8010167a:	e8 98 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010167f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101683:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101686:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101689:	39 c2                	cmp    %eax,%edx
8010168b:	0f 82 5a ff ff ff    	jb     801015eb <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101691:	c7 04 24 99 8a 10 80 	movl   $0x80108a99,(%esp)
80101698:	e8 9d ee ff ff       	call   8010053a <panic>
}
8010169d:	c9                   	leave  
8010169e:	c3                   	ret    

8010169f <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010169f:	55                   	push   %ebp
801016a0:	89 e5                	mov    %esp,%ebp
801016a2:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016a5:	8b 45 08             	mov    0x8(%ebp),%eax
801016a8:	8b 40 04             	mov    0x4(%eax),%eax
801016ab:	c1 e8 03             	shr    $0x3,%eax
801016ae:	8d 50 02             	lea    0x2(%eax),%edx
801016b1:	8b 45 08             	mov    0x8(%ebp),%eax
801016b4:	8b 00                	mov    (%eax),%eax
801016b6:	89 54 24 04          	mov    %edx,0x4(%esp)
801016ba:	89 04 24             	mov    %eax,(%esp)
801016bd:	e8 e4 ea ff ff       	call   801001a6 <bread>
801016c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c8:	8d 50 18             	lea    0x18(%eax),%edx
801016cb:	8b 45 08             	mov    0x8(%ebp),%eax
801016ce:	8b 40 04             	mov    0x4(%eax),%eax
801016d1:	83 e0 07             	and    $0x7,%eax
801016d4:	c1 e0 06             	shl    $0x6,%eax
801016d7:	01 d0                	add    %edx,%eax
801016d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016dc:	8b 45 08             	mov    0x8(%ebp),%eax
801016df:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e6:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016e9:	8b 45 08             	mov    0x8(%ebp),%eax
801016ec:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f3:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801016f7:	8b 45 08             	mov    0x8(%ebp),%eax
801016fa:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101701:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101705:	8b 45 08             	mov    0x8(%ebp),%eax
80101708:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170f:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101713:	8b 45 08             	mov    0x8(%ebp),%eax
80101716:	8b 50 18             	mov    0x18(%eax),%edx
80101719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010171f:	8b 45 08             	mov    0x8(%ebp),%eax
80101722:	8d 50 1c             	lea    0x1c(%eax),%edx
80101725:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101728:	83 c0 0c             	add    $0xc,%eax
8010172b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101732:	00 
80101733:	89 54 24 04          	mov    %edx,0x4(%esp)
80101737:	89 04 24             	mov    %eax,(%esp)
8010173a:	e8 1f 3d 00 00       	call   8010545e <memmove>
  log_write(bp);
8010173f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101742:	89 04 24             	mov    %eax,(%esp)
80101745:	e8 d1 1e 00 00       	call   8010361b <log_write>
  brelse(bp);
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	89 04 24             	mov    %eax,(%esp)
80101750:	e8 c2 ea ff ff       	call   80100217 <brelse>
}
80101755:	c9                   	leave  
80101756:	c3                   	ret    

80101757 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101757:	55                   	push   %ebp
80101758:	89 e5                	mov    %esp,%ebp
8010175a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010175d:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101764:	e8 d2 39 00 00       	call   8010513b <acquire>

  // Is the inode already cached?
  empty = 0;
80101769:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101770:	c7 45 f4 74 22 11 80 	movl   $0x80112274,-0xc(%ebp)
80101777:	eb 59                	jmp    801017d2 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177c:	8b 40 08             	mov    0x8(%eax),%eax
8010177f:	85 c0                	test   %eax,%eax
80101781:	7e 35                	jle    801017b8 <iget+0x61>
80101783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101786:	8b 00                	mov    (%eax),%eax
80101788:	3b 45 08             	cmp    0x8(%ebp),%eax
8010178b:	75 2b                	jne    801017b8 <iget+0x61>
8010178d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101790:	8b 40 04             	mov    0x4(%eax),%eax
80101793:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101796:	75 20                	jne    801017b8 <iget+0x61>
      ip->ref++;
80101798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179b:	8b 40 08             	mov    0x8(%eax),%eax
8010179e:	8d 50 01             	lea    0x1(%eax),%edx
801017a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a4:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017a7:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
801017ae:	e8 ea 39 00 00       	call   8010519d <release>
      return ip;
801017b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b6:	eb 6f                	jmp    80101827 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017bc:	75 10                	jne    801017ce <iget+0x77>
801017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c1:	8b 40 08             	mov    0x8(%eax),%eax
801017c4:	85 c0                	test   %eax,%eax
801017c6:	75 06                	jne    801017ce <iget+0x77>
      empty = ip;
801017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017ce:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017d2:	81 7d f4 14 32 11 80 	cmpl   $0x80113214,-0xc(%ebp)
801017d9:	72 9e                	jb     80101779 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017df:	75 0c                	jne    801017ed <iget+0x96>
    panic("iget: no inodes");
801017e1:	c7 04 24 ab 8a 10 80 	movl   $0x80108aab,(%esp)
801017e8:	e8 4d ed ff ff       	call   8010053a <panic>

  ip = empty;
801017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	8b 55 08             	mov    0x8(%ebp),%edx
801017f9:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801017fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fe:	8b 55 0c             	mov    0xc(%ebp),%edx
80101801:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101807:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010180e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101811:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101818:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
8010181f:	e8 79 39 00 00       	call   8010519d <release>

  return ip;
80101824:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101827:	c9                   	leave  
80101828:	c3                   	ret    

80101829 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101829:	55                   	push   %ebp
8010182a:	89 e5                	mov    %esp,%ebp
8010182c:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010182f:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101836:	e8 00 39 00 00       	call   8010513b <acquire>
  ip->ref++;
8010183b:	8b 45 08             	mov    0x8(%ebp),%eax
8010183e:	8b 40 08             	mov    0x8(%eax),%eax
80101841:	8d 50 01             	lea    0x1(%eax),%edx
80101844:	8b 45 08             	mov    0x8(%ebp),%eax
80101847:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010184a:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101851:	e8 47 39 00 00       	call   8010519d <release>
  return ip;
80101856:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101859:	c9                   	leave  
8010185a:	c3                   	ret    

8010185b <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010185b:	55                   	push   %ebp
8010185c:	89 e5                	mov    %esp,%ebp
8010185e:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101861:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101865:	74 0a                	je     80101871 <ilock+0x16>
80101867:	8b 45 08             	mov    0x8(%ebp),%eax
8010186a:	8b 40 08             	mov    0x8(%eax),%eax
8010186d:	85 c0                	test   %eax,%eax
8010186f:	7f 0c                	jg     8010187d <ilock+0x22>
    panic("ilock");
80101871:	c7 04 24 bb 8a 10 80 	movl   $0x80108abb,(%esp)
80101878:	e8 bd ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010187d:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101884:	e8 b2 38 00 00       	call   8010513b <acquire>
  while(ip->flags & I_BUSY)
80101889:	eb 13                	jmp    8010189e <ilock+0x43>
    sleep(ip, &icache.lock);
8010188b:	c7 44 24 04 40 22 11 	movl   $0x80112240,0x4(%esp)
80101892:	80 
80101893:	8b 45 08             	mov    0x8(%ebp),%eax
80101896:	89 04 24             	mov    %eax,(%esp)
80101899:	e8 0c 35 00 00       	call   80104daa <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
8010189e:	8b 45 08             	mov    0x8(%ebp),%eax
801018a1:	8b 40 0c             	mov    0xc(%eax),%eax
801018a4:	83 e0 01             	and    $0x1,%eax
801018a7:	85 c0                	test   %eax,%eax
801018a9:	75 e0                	jne    8010188b <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018ab:	8b 45 08             	mov    0x8(%ebp),%eax
801018ae:	8b 40 0c             	mov    0xc(%eax),%eax
801018b1:	83 c8 01             	or     $0x1,%eax
801018b4:	89 c2                	mov    %eax,%edx
801018b6:	8b 45 08             	mov    0x8(%ebp),%eax
801018b9:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018bc:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
801018c3:	e8 d5 38 00 00       	call   8010519d <release>

  if(!(ip->flags & I_VALID)){
801018c8:	8b 45 08             	mov    0x8(%ebp),%eax
801018cb:	8b 40 0c             	mov    0xc(%eax),%eax
801018ce:	83 e0 02             	and    $0x2,%eax
801018d1:	85 c0                	test   %eax,%eax
801018d3:	0f 85 ce 00 00 00    	jne    801019a7 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018d9:	8b 45 08             	mov    0x8(%ebp),%eax
801018dc:	8b 40 04             	mov    0x4(%eax),%eax
801018df:	c1 e8 03             	shr    $0x3,%eax
801018e2:	8d 50 02             	lea    0x2(%eax),%edx
801018e5:	8b 45 08             	mov    0x8(%ebp),%eax
801018e8:	8b 00                	mov    (%eax),%eax
801018ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801018ee:	89 04 24             	mov    %eax,(%esp)
801018f1:	e8 b0 e8 ff ff       	call   801001a6 <bread>
801018f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fc:	8d 50 18             	lea    0x18(%eax),%edx
801018ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101902:	8b 40 04             	mov    0x4(%eax),%eax
80101905:	83 e0 07             	and    $0x7,%eax
80101908:	c1 e0 06             	shl    $0x6,%eax
8010190b:	01 d0                	add    %edx,%eax
8010190d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101913:	0f b7 10             	movzwl (%eax),%edx
80101916:	8b 45 08             	mov    0x8(%ebp),%eax
80101919:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010191d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101920:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101924:	8b 45 08             	mov    0x8(%ebp),%eax
80101927:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
8010192b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192e:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101932:	8b 45 08             	mov    0x8(%ebp),%eax
80101935:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101939:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193c:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101940:	8b 45 08             	mov    0x8(%ebp),%eax
80101943:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101947:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194a:	8b 50 08             	mov    0x8(%eax),%edx
8010194d:	8b 45 08             	mov    0x8(%ebp),%eax
80101950:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101956:	8d 50 0c             	lea    0xc(%eax),%edx
80101959:	8b 45 08             	mov    0x8(%ebp),%eax
8010195c:	83 c0 1c             	add    $0x1c,%eax
8010195f:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101966:	00 
80101967:	89 54 24 04          	mov    %edx,0x4(%esp)
8010196b:	89 04 24             	mov    %eax,(%esp)
8010196e:	e8 eb 3a 00 00       	call   8010545e <memmove>
    brelse(bp);
80101973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101976:	89 04 24             	mov    %eax,(%esp)
80101979:	e8 99 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	8b 40 0c             	mov    0xc(%eax),%eax
80101984:	83 c8 02             	or     $0x2,%eax
80101987:	89 c2                	mov    %eax,%edx
80101989:	8b 45 08             	mov    0x8(%ebp),%eax
8010198c:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010198f:	8b 45 08             	mov    0x8(%ebp),%eax
80101992:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101996:	66 85 c0             	test   %ax,%ax
80101999:	75 0c                	jne    801019a7 <ilock+0x14c>
      panic("ilock: no type");
8010199b:	c7 04 24 c1 8a 10 80 	movl   $0x80108ac1,(%esp)
801019a2:	e8 93 eb ff ff       	call   8010053a <panic>
  }
}
801019a7:	c9                   	leave  
801019a8:	c3                   	ret    

801019a9 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019a9:	55                   	push   %ebp
801019aa:	89 e5                	mov    %esp,%ebp
801019ac:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019b3:	74 17                	je     801019cc <iunlock+0x23>
801019b5:	8b 45 08             	mov    0x8(%ebp),%eax
801019b8:	8b 40 0c             	mov    0xc(%eax),%eax
801019bb:	83 e0 01             	and    $0x1,%eax
801019be:	85 c0                	test   %eax,%eax
801019c0:	74 0a                	je     801019cc <iunlock+0x23>
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	8b 40 08             	mov    0x8(%eax),%eax
801019c8:	85 c0                	test   %eax,%eax
801019ca:	7f 0c                	jg     801019d8 <iunlock+0x2f>
    panic("iunlock");
801019cc:	c7 04 24 d0 8a 10 80 	movl   $0x80108ad0,(%esp)
801019d3:	e8 62 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019d8:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
801019df:	e8 57 37 00 00       	call   8010513b <acquire>
  ip->flags &= ~I_BUSY;
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	8b 40 0c             	mov    0xc(%eax),%eax
801019ea:	83 e0 fe             	and    $0xfffffffe,%eax
801019ed:	89 c2                	mov    %eax,%edx
801019ef:	8b 45 08             	mov    0x8(%ebp),%eax
801019f2:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
801019f5:	8b 45 08             	mov    0x8(%ebp),%eax
801019f8:	89 04 24             	mov    %eax,(%esp)
801019fb:	e8 f1 34 00 00       	call   80104ef1 <wakeup>
  release(&icache.lock);
80101a00:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101a07:	e8 91 37 00 00       	call   8010519d <release>
}
80101a0c:	c9                   	leave  
80101a0d:	c3                   	ret    

80101a0e <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a0e:	55                   	push   %ebp
80101a0f:	89 e5                	mov    %esp,%ebp
80101a11:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a14:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101a1b:	e8 1b 37 00 00       	call   8010513b <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	8b 40 08             	mov    0x8(%eax),%eax
80101a26:	83 f8 01             	cmp    $0x1,%eax
80101a29:	0f 85 93 00 00 00    	jne    80101ac2 <iput+0xb4>
80101a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a32:	8b 40 0c             	mov    0xc(%eax),%eax
80101a35:	83 e0 02             	and    $0x2,%eax
80101a38:	85 c0                	test   %eax,%eax
80101a3a:	0f 84 82 00 00 00    	je     80101ac2 <iput+0xb4>
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a47:	66 85 c0             	test   %ax,%ax
80101a4a:	75 76                	jne    80101ac2 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4f:	8b 40 0c             	mov    0xc(%eax),%eax
80101a52:	83 e0 01             	and    $0x1,%eax
80101a55:	85 c0                	test   %eax,%eax
80101a57:	74 0c                	je     80101a65 <iput+0x57>
      panic("iput busy");
80101a59:	c7 04 24 d8 8a 10 80 	movl   $0x80108ad8,(%esp)
80101a60:	e8 d5 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a65:	8b 45 08             	mov    0x8(%ebp),%eax
80101a68:	8b 40 0c             	mov    0xc(%eax),%eax
80101a6b:	83 c8 01             	or     $0x1,%eax
80101a6e:	89 c2                	mov    %eax,%edx
80101a70:	8b 45 08             	mov    0x8(%ebp),%eax
80101a73:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a76:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101a7d:	e8 1b 37 00 00       	call   8010519d <release>
    itrunc(ip);
80101a82:	8b 45 08             	mov    0x8(%ebp),%eax
80101a85:	89 04 24             	mov    %eax,(%esp)
80101a88:	e8 7d 01 00 00       	call   80101c0a <itrunc>
    ip->type = 0;
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101a96:	8b 45 08             	mov    0x8(%ebp),%eax
80101a99:	89 04 24             	mov    %eax,(%esp)
80101a9c:	e8 fe fb ff ff       	call   8010169f <iupdate>
    acquire(&icache.lock);
80101aa1:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101aa8:	e8 8e 36 00 00       	call   8010513b <acquire>
    ip->flags = 0;
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	89 04 24             	mov    %eax,(%esp)
80101abd:	e8 2f 34 00 00       	call   80104ef1 <wakeup>
  }
  ip->ref--;
80101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac5:	8b 40 08             	mov    0x8(%eax),%eax
80101ac8:	8d 50 ff             	lea    -0x1(%eax),%edx
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ad1:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101ad8:	e8 c0 36 00 00       	call   8010519d <release>
}
80101add:	c9                   	leave  
80101ade:	c3                   	ret    

80101adf <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101adf:	55                   	push   %ebp
80101ae0:	89 e5                	mov    %esp,%ebp
80101ae2:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	89 04 24             	mov    %eax,(%esp)
80101aeb:	e8 b9 fe ff ff       	call   801019a9 <iunlock>
  iput(ip);
80101af0:	8b 45 08             	mov    0x8(%ebp),%eax
80101af3:	89 04 24             	mov    %eax,(%esp)
80101af6:	e8 13 ff ff ff       	call   80101a0e <iput>
}
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	53                   	push   %ebx
80101b01:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b04:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b08:	77 3e                	ja     80101b48 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b10:	83 c2 04             	add    $0x4,%edx
80101b13:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b1e:	75 20                	jne    80101b40 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b20:	8b 45 08             	mov    0x8(%ebp),%eax
80101b23:	8b 00                	mov    (%eax),%eax
80101b25:	89 04 24             	mov    %eax,(%esp)
80101b28:	e8 5b f8 ff ff       	call   80101388 <balloc>
80101b2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b36:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b3c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b43:	e9 bc 00 00 00       	jmp    80101c04 <bmap+0x107>
  }
  bn -= NDIRECT;
80101b48:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b4c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b50:	0f 87 a2 00 00 00    	ja     80101bf8 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b56:	8b 45 08             	mov    0x8(%ebp),%eax
80101b59:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b63:	75 19                	jne    80101b7e <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	8b 00                	mov    (%eax),%eax
80101b6a:	89 04 24             	mov    %eax,(%esp)
80101b6d:	e8 16 f8 ff ff       	call   80101388 <balloc>
80101b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b7b:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 00                	mov    (%eax),%eax
80101b83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b86:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b8a:	89 04 24             	mov    %eax,(%esp)
80101b8d:	e8 14 e6 ff ff       	call   801001a6 <bread>
80101b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b98:	83 c0 18             	add    $0x18,%eax
80101b9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ba1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ba8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bab:	01 d0                	add    %edx,%eax
80101bad:	8b 00                	mov    (%eax),%eax
80101baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bb2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bb6:	75 30                	jne    80101be8 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bbb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bc5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	8b 00                	mov    (%eax),%eax
80101bcd:	89 04 24             	mov    %eax,(%esp)
80101bd0:	e8 b3 f7 ff ff       	call   80101388 <balloc>
80101bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bdb:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be0:	89 04 24             	mov    %eax,(%esp)
80101be3:	e8 33 1a 00 00       	call   8010361b <log_write>
    }
    brelse(bp);
80101be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101beb:	89 04 24             	mov    %eax,(%esp)
80101bee:	e8 24 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf6:	eb 0c                	jmp    80101c04 <bmap+0x107>
  }

  panic("bmap: out of range");
80101bf8:	c7 04 24 e2 8a 10 80 	movl   $0x80108ae2,(%esp)
80101bff:	e8 36 e9 ff ff       	call   8010053a <panic>
}
80101c04:	83 c4 24             	add    $0x24,%esp
80101c07:	5b                   	pop    %ebx
80101c08:	5d                   	pop    %ebp
80101c09:	c3                   	ret    

80101c0a <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c0a:	55                   	push   %ebp
80101c0b:	89 e5                	mov    %esp,%ebp
80101c0d:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c17:	eb 44                	jmp    80101c5d <itrunc+0x53>
    if(ip->addrs[i]){
80101c19:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c1f:	83 c2 04             	add    $0x4,%edx
80101c22:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c26:	85 c0                	test   %eax,%eax
80101c28:	74 2f                	je     80101c59 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c30:	83 c2 04             	add    $0x4,%edx
80101c33:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c37:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3a:	8b 00                	mov    (%eax),%eax
80101c3c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c40:	89 04 24             	mov    %eax,(%esp)
80101c43:	e8 8e f8 ff ff       	call   801014d6 <bfree>
      ip->addrs[i] = 0;
80101c48:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c4e:	83 c2 04             	add    $0x4,%edx
80101c51:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c58:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c5d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c61:	7e b6                	jle    80101c19 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c69:	85 c0                	test   %eax,%eax
80101c6b:	0f 84 9b 00 00 00    	je     80101d0c <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c71:	8b 45 08             	mov    0x8(%ebp),%eax
80101c74:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	8b 00                	mov    (%eax),%eax
80101c7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c80:	89 04 24             	mov    %eax,(%esp)
80101c83:	e8 1e e5 ff ff       	call   801001a6 <bread>
80101c88:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c8e:	83 c0 18             	add    $0x18,%eax
80101c91:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101c94:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101c9b:	eb 3b                	jmp    80101cd8 <itrunc+0xce>
      if(a[j])
80101c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ca7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101caa:	01 d0                	add    %edx,%eax
80101cac:	8b 00                	mov    (%eax),%eax
80101cae:	85 c0                	test   %eax,%eax
80101cb0:	74 22                	je     80101cd4 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cbc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cbf:	01 d0                	add    %edx,%eax
80101cc1:	8b 10                	mov    (%eax),%edx
80101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc6:	8b 00                	mov    (%eax),%eax
80101cc8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ccc:	89 04 24             	mov    %eax,(%esp)
80101ccf:	e8 02 f8 ff ff       	call   801014d6 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cd4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cdb:	83 f8 7f             	cmp    $0x7f,%eax
80101cde:	76 bd                	jbe    80101c9d <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ce0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ce3:	89 04 24             	mov    %eax,(%esp)
80101ce6:	e8 2c e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cee:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf4:	8b 00                	mov    (%eax),%eax
80101cf6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cfa:	89 04 24             	mov    %eax,(%esp)
80101cfd:	e8 d4 f7 ff ff       	call   801014d6 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d16:	8b 45 08             	mov    0x8(%ebp),%eax
80101d19:	89 04 24             	mov    %eax,(%esp)
80101d1c:	e8 7e f9 ff ff       	call   8010169f <iupdate>
}
80101d21:	c9                   	leave  
80101d22:	c3                   	ret    

80101d23 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d23:	55                   	push   %ebp
80101d24:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	8b 00                	mov    (%eax),%eax
80101d2b:	89 c2                	mov    %eax,%edx
80101d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d30:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d33:	8b 45 08             	mov    0x8(%ebp),%eax
80101d36:	8b 50 04             	mov    0x4(%eax),%edx
80101d39:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d3c:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d42:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d46:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d49:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4f:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d53:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d56:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5d:	8b 50 18             	mov    0x18(%eax),%edx
80101d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d63:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d66:	5d                   	pop    %ebp
80101d67:	c3                   	ret    

80101d68 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d68:	55                   	push   %ebp
80101d69:	89 e5                	mov    %esp,%ebp
80101d6b:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d71:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d75:	66 83 f8 03          	cmp    $0x3,%ax
80101d79:	75 60                	jne    80101ddb <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d82:	66 85 c0             	test   %ax,%ax
80101d85:	78 20                	js     80101da7 <readi+0x3f>
80101d87:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d8e:	66 83 f8 09          	cmp    $0x9,%ax
80101d92:	7f 13                	jg     80101da7 <readi+0x3f>
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d9b:	98                   	cwtl   
80101d9c:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101da3:	85 c0                	test   %eax,%eax
80101da5:	75 0a                	jne    80101db1 <readi+0x49>
      return -1;
80101da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dac:	e9 19 01 00 00       	jmp    80101eca <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101db1:	8b 45 08             	mov    0x8(%ebp),%eax
80101db4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101db8:	98                   	cwtl   
80101db9:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101dc0:	8b 55 14             	mov    0x14(%ebp),%edx
80101dc3:	89 54 24 08          	mov    %edx,0x8(%esp)
80101dc7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dca:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dce:	8b 55 08             	mov    0x8(%ebp),%edx
80101dd1:	89 14 24             	mov    %edx,(%esp)
80101dd4:	ff d0                	call   *%eax
80101dd6:	e9 ef 00 00 00       	jmp    80101eca <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dde:	8b 40 18             	mov    0x18(%eax),%eax
80101de1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101de4:	72 0d                	jb     80101df3 <readi+0x8b>
80101de6:	8b 45 14             	mov    0x14(%ebp),%eax
80101de9:	8b 55 10             	mov    0x10(%ebp),%edx
80101dec:	01 d0                	add    %edx,%eax
80101dee:	3b 45 10             	cmp    0x10(%ebp),%eax
80101df1:	73 0a                	jae    80101dfd <readi+0x95>
    return -1;
80101df3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101df8:	e9 cd 00 00 00       	jmp    80101eca <readi+0x162>
  if(off + n > ip->size)
80101dfd:	8b 45 14             	mov    0x14(%ebp),%eax
80101e00:	8b 55 10             	mov    0x10(%ebp),%edx
80101e03:	01 c2                	add    %eax,%edx
80101e05:	8b 45 08             	mov    0x8(%ebp),%eax
80101e08:	8b 40 18             	mov    0x18(%eax),%eax
80101e0b:	39 c2                	cmp    %eax,%edx
80101e0d:	76 0c                	jbe    80101e1b <readi+0xb3>
    n = ip->size - off;
80101e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e12:	8b 40 18             	mov    0x18(%eax),%eax
80101e15:	2b 45 10             	sub    0x10(%ebp),%eax
80101e18:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e22:	e9 94 00 00 00       	jmp    80101ebb <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e27:	8b 45 10             	mov    0x10(%ebp),%eax
80101e2a:	c1 e8 09             	shr    $0x9,%eax
80101e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e31:	8b 45 08             	mov    0x8(%ebp),%eax
80101e34:	89 04 24             	mov    %eax,(%esp)
80101e37:	e8 c1 fc ff ff       	call   80101afd <bmap>
80101e3c:	8b 55 08             	mov    0x8(%ebp),%edx
80101e3f:	8b 12                	mov    (%edx),%edx
80101e41:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e45:	89 14 24             	mov    %edx,(%esp)
80101e48:	e8 59 e3 ff ff       	call   801001a6 <bread>
80101e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e50:	8b 45 10             	mov    0x10(%ebp),%eax
80101e53:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e58:	89 c2                	mov    %eax,%edx
80101e5a:	b8 00 02 00 00       	mov    $0x200,%eax
80101e5f:	29 d0                	sub    %edx,%eax
80101e61:	89 c2                	mov    %eax,%edx
80101e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e66:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e69:	29 c1                	sub    %eax,%ecx
80101e6b:	89 c8                	mov    %ecx,%eax
80101e6d:	39 c2                	cmp    %eax,%edx
80101e6f:	0f 46 c2             	cmovbe %edx,%eax
80101e72:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e75:	8b 45 10             	mov    0x10(%ebp),%eax
80101e78:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e7d:	8d 50 10             	lea    0x10(%eax),%edx
80101e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e83:	01 d0                	add    %edx,%eax
80101e85:	8d 50 08             	lea    0x8(%eax),%edx
80101e88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e8b:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e8f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e93:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e96:	89 04 24             	mov    %eax,(%esp)
80101e99:	e8 c0 35 00 00       	call   8010545e <memmove>
    brelse(bp);
80101e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea1:	89 04 24             	mov    %eax,(%esp)
80101ea4:	e8 6e e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ea9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eac:	01 45 f4             	add    %eax,-0xc(%ebp)
80101eaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb2:	01 45 10             	add    %eax,0x10(%ebp)
80101eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb8:	01 45 0c             	add    %eax,0xc(%ebp)
80101ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ebe:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ec1:	0f 82 60 ff ff ff    	jb     80101e27 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ec7:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101eca:	c9                   	leave  
80101ecb:	c3                   	ret    

80101ecc <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ecc:	55                   	push   %ebp
80101ecd:	89 e5                	mov    %esp,%ebp
80101ecf:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ed9:	66 83 f8 03          	cmp    $0x3,%ax
80101edd:	75 60                	jne    80101f3f <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee6:	66 85 c0             	test   %ax,%ax
80101ee9:	78 20                	js     80101f0b <writei+0x3f>
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101eee:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef2:	66 83 f8 09          	cmp    $0x9,%ax
80101ef6:	7f 13                	jg     80101f0b <writei+0x3f>
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eff:	98                   	cwtl   
80101f00:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80101f07:	85 c0                	test   %eax,%eax
80101f09:	75 0a                	jne    80101f15 <writei+0x49>
      return -1;
80101f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f10:	e9 44 01 00 00       	jmp    80102059 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f1c:	98                   	cwtl   
80101f1d:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80101f24:	8b 55 14             	mov    0x14(%ebp),%edx
80101f27:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f2e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f32:	8b 55 08             	mov    0x8(%ebp),%edx
80101f35:	89 14 24             	mov    %edx,(%esp)
80101f38:	ff d0                	call   *%eax
80101f3a:	e9 1a 01 00 00       	jmp    80102059 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f42:	8b 40 18             	mov    0x18(%eax),%eax
80101f45:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f48:	72 0d                	jb     80101f57 <writei+0x8b>
80101f4a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f4d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f50:	01 d0                	add    %edx,%eax
80101f52:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f55:	73 0a                	jae    80101f61 <writei+0x95>
    return -1;
80101f57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f5c:	e9 f8 00 00 00       	jmp    80102059 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101f61:	8b 45 14             	mov    0x14(%ebp),%eax
80101f64:	8b 55 10             	mov    0x10(%ebp),%edx
80101f67:	01 d0                	add    %edx,%eax
80101f69:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f6e:	76 0a                	jbe    80101f7a <writei+0xae>
    return -1;
80101f70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f75:	e9 df 00 00 00       	jmp    80102059 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f81:	e9 9f 00 00 00       	jmp    80102025 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f86:	8b 45 10             	mov    0x10(%ebp),%eax
80101f89:	c1 e8 09             	shr    $0x9,%eax
80101f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f90:	8b 45 08             	mov    0x8(%ebp),%eax
80101f93:	89 04 24             	mov    %eax,(%esp)
80101f96:	e8 62 fb ff ff       	call   80101afd <bmap>
80101f9b:	8b 55 08             	mov    0x8(%ebp),%edx
80101f9e:	8b 12                	mov    (%edx),%edx
80101fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fa4:	89 14 24             	mov    %edx,(%esp)
80101fa7:	e8 fa e1 ff ff       	call   801001a6 <bread>
80101fac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101faf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fb7:	89 c2                	mov    %eax,%edx
80101fb9:	b8 00 02 00 00       	mov    $0x200,%eax
80101fbe:	29 d0                	sub    %edx,%eax
80101fc0:	89 c2                	mov    %eax,%edx
80101fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fc5:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fc8:	29 c1                	sub    %eax,%ecx
80101fca:	89 c8                	mov    %ecx,%eax
80101fcc:	39 c2                	cmp    %eax,%edx
80101fce:	0f 46 c2             	cmovbe %edx,%eax
80101fd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fd4:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdc:	8d 50 10             	lea    0x10(%eax),%edx
80101fdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe2:	01 d0                	add    %edx,%eax
80101fe4:	8d 50 08             	lea    0x8(%eax),%edx
80101fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fea:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ff5:	89 14 24             	mov    %edx,(%esp)
80101ff8:	e8 61 34 00 00       	call   8010545e <memmove>
    log_write(bp);
80101ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102000:	89 04 24             	mov    %eax,(%esp)
80102003:	e8 13 16 00 00       	call   8010361b <log_write>
    brelse(bp);
80102008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200b:	89 04 24             	mov    %eax,(%esp)
8010200e:	e8 04 e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102013:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102016:	01 45 f4             	add    %eax,-0xc(%ebp)
80102019:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201c:	01 45 10             	add    %eax,0x10(%ebp)
8010201f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102022:	01 45 0c             	add    %eax,0xc(%ebp)
80102025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102028:	3b 45 14             	cmp    0x14(%ebp),%eax
8010202b:	0f 82 55 ff ff ff    	jb     80101f86 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102031:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102035:	74 1f                	je     80102056 <writei+0x18a>
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	8b 40 18             	mov    0x18(%eax),%eax
8010203d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102040:	73 14                	jae    80102056 <writei+0x18a>
    ip->size = off;
80102042:	8b 45 08             	mov    0x8(%ebp),%eax
80102045:	8b 55 10             	mov    0x10(%ebp),%edx
80102048:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	89 04 24             	mov    %eax,(%esp)
80102051:	e8 49 f6 ff ff       	call   8010169f <iupdate>
  }
  return n;
80102056:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102059:	c9                   	leave  
8010205a:	c3                   	ret    

8010205b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010205b:	55                   	push   %ebp
8010205c:	89 e5                	mov    %esp,%ebp
8010205e:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102061:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102068:	00 
80102069:	8b 45 0c             	mov    0xc(%ebp),%eax
8010206c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102070:	8b 45 08             	mov    0x8(%ebp),%eax
80102073:	89 04 24             	mov    %eax,(%esp)
80102076:	e8 86 34 00 00       	call   80105501 <strncmp>
}
8010207b:	c9                   	leave  
8010207c:	c3                   	ret    

8010207d <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010207d:	55                   	push   %ebp
8010207e:	89 e5                	mov    %esp,%ebp
80102080:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102083:	8b 45 08             	mov    0x8(%ebp),%eax
80102086:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010208a:	66 83 f8 01          	cmp    $0x1,%ax
8010208e:	74 0c                	je     8010209c <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102090:	c7 04 24 f5 8a 10 80 	movl   $0x80108af5,(%esp)
80102097:	e8 9e e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010209c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020a3:	e9 88 00 00 00       	jmp    80102130 <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020a8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020af:	00 
801020b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801020b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801020be:	8b 45 08             	mov    0x8(%ebp),%eax
801020c1:	89 04 24             	mov    %eax,(%esp)
801020c4:	e8 9f fc ff ff       	call   80101d68 <readi>
801020c9:	83 f8 10             	cmp    $0x10,%eax
801020cc:	74 0c                	je     801020da <dirlookup+0x5d>
      panic("dirlink read");
801020ce:	c7 04 24 07 8b 10 80 	movl   $0x80108b07,(%esp)
801020d5:	e8 60 e4 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801020da:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020de:	66 85 c0             	test   %ax,%ax
801020e1:	75 02                	jne    801020e5 <dirlookup+0x68>
      continue;
801020e3:	eb 47                	jmp    8010212c <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
801020e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020e8:	83 c0 02             	add    $0x2,%eax
801020eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801020f2:	89 04 24             	mov    %eax,(%esp)
801020f5:	e8 61 ff ff ff       	call   8010205b <namecmp>
801020fa:	85 c0                	test   %eax,%eax
801020fc:	75 2e                	jne    8010212c <dirlookup+0xaf>
      // entry matches path element
      if(poff)
801020fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102102:	74 08                	je     8010210c <dirlookup+0x8f>
        *poff = off;
80102104:	8b 45 10             	mov    0x10(%ebp),%eax
80102107:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010210a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010210c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102110:	0f b7 c0             	movzwl %ax,%eax
80102113:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102116:	8b 45 08             	mov    0x8(%ebp),%eax
80102119:	8b 00                	mov    (%eax),%eax
8010211b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010211e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102122:	89 04 24             	mov    %eax,(%esp)
80102125:	e8 2d f6 ff ff       	call   80101757 <iget>
8010212a:	eb 18                	jmp    80102144 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010212c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102130:	8b 45 08             	mov    0x8(%ebp),%eax
80102133:	8b 40 18             	mov    0x18(%eax),%eax
80102136:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102139:	0f 87 69 ff ff ff    	ja     801020a8 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010213f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102144:	c9                   	leave  
80102145:	c3                   	ret    

80102146 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102146:	55                   	push   %ebp
80102147:	89 e5                	mov    %esp,%ebp
80102149:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010214c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102153:	00 
80102154:	8b 45 0c             	mov    0xc(%ebp),%eax
80102157:	89 44 24 04          	mov    %eax,0x4(%esp)
8010215b:	8b 45 08             	mov    0x8(%ebp),%eax
8010215e:	89 04 24             	mov    %eax,(%esp)
80102161:	e8 17 ff ff ff       	call   8010207d <dirlookup>
80102166:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102169:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010216d:	74 15                	je     80102184 <dirlink+0x3e>
    iput(ip);
8010216f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102172:	89 04 24             	mov    %eax,(%esp)
80102175:	e8 94 f8 ff ff       	call   80101a0e <iput>
    return -1;
8010217a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010217f:	e9 b7 00 00 00       	jmp    8010223b <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102184:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010218b:	eb 46                	jmp    801021d3 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010218d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102190:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102197:	00 
80102198:	89 44 24 08          	mov    %eax,0x8(%esp)
8010219c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010219f:	89 44 24 04          	mov    %eax,0x4(%esp)
801021a3:	8b 45 08             	mov    0x8(%ebp),%eax
801021a6:	89 04 24             	mov    %eax,(%esp)
801021a9:	e8 ba fb ff ff       	call   80101d68 <readi>
801021ae:	83 f8 10             	cmp    $0x10,%eax
801021b1:	74 0c                	je     801021bf <dirlink+0x79>
      panic("dirlink read");
801021b3:	c7 04 24 07 8b 10 80 	movl   $0x80108b07,(%esp)
801021ba:	e8 7b e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801021bf:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021c3:	66 85 c0             	test   %ax,%ax
801021c6:	75 02                	jne    801021ca <dirlink+0x84>
      break;
801021c8:	eb 16                	jmp    801021e0 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021cd:	83 c0 10             	add    $0x10,%eax
801021d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021d6:	8b 45 08             	mov    0x8(%ebp),%eax
801021d9:	8b 40 18             	mov    0x18(%eax),%eax
801021dc:	39 c2                	cmp    %eax,%edx
801021de:	72 ad                	jb     8010218d <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801021e0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021e7:	00 
801021e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801021eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021f2:	83 c0 02             	add    $0x2,%eax
801021f5:	89 04 24             	mov    %eax,(%esp)
801021f8:	e8 5a 33 00 00       	call   80105557 <strncpy>
  de.inum = inum;
801021fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102200:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102207:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010220e:	00 
8010220f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102213:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102216:	89 44 24 04          	mov    %eax,0x4(%esp)
8010221a:	8b 45 08             	mov    0x8(%ebp),%eax
8010221d:	89 04 24             	mov    %eax,(%esp)
80102220:	e8 a7 fc ff ff       	call   80101ecc <writei>
80102225:	83 f8 10             	cmp    $0x10,%eax
80102228:	74 0c                	je     80102236 <dirlink+0xf0>
    panic("dirlink");
8010222a:	c7 04 24 14 8b 10 80 	movl   $0x80108b14,(%esp)
80102231:	e8 04 e3 ff ff       	call   8010053a <panic>
  
  return 0;
80102236:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010223b:	c9                   	leave  
8010223c:	c3                   	ret    

8010223d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010223d:	55                   	push   %ebp
8010223e:	89 e5                	mov    %esp,%ebp
80102240:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102243:	eb 04                	jmp    80102249 <skipelem+0xc>
    path++;
80102245:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102249:	8b 45 08             	mov    0x8(%ebp),%eax
8010224c:	0f b6 00             	movzbl (%eax),%eax
8010224f:	3c 2f                	cmp    $0x2f,%al
80102251:	74 f2                	je     80102245 <skipelem+0x8>
    path++;
  if(*path == 0)
80102253:	8b 45 08             	mov    0x8(%ebp),%eax
80102256:	0f b6 00             	movzbl (%eax),%eax
80102259:	84 c0                	test   %al,%al
8010225b:	75 0a                	jne    80102267 <skipelem+0x2a>
    return 0;
8010225d:	b8 00 00 00 00       	mov    $0x0,%eax
80102262:	e9 86 00 00 00       	jmp    801022ed <skipelem+0xb0>
  s = path;
80102267:	8b 45 08             	mov    0x8(%ebp),%eax
8010226a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010226d:	eb 04                	jmp    80102273 <skipelem+0x36>
    path++;
8010226f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102273:	8b 45 08             	mov    0x8(%ebp),%eax
80102276:	0f b6 00             	movzbl (%eax),%eax
80102279:	3c 2f                	cmp    $0x2f,%al
8010227b:	74 0a                	je     80102287 <skipelem+0x4a>
8010227d:	8b 45 08             	mov    0x8(%ebp),%eax
80102280:	0f b6 00             	movzbl (%eax),%eax
80102283:	84 c0                	test   %al,%al
80102285:	75 e8                	jne    8010226f <skipelem+0x32>
    path++;
  len = path - s;
80102287:	8b 55 08             	mov    0x8(%ebp),%edx
8010228a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010228d:	29 c2                	sub    %eax,%edx
8010228f:	89 d0                	mov    %edx,%eax
80102291:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102294:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102298:	7e 1c                	jle    801022b6 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
8010229a:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022a1:	00 
801022a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801022a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801022ac:	89 04 24             	mov    %eax,(%esp)
801022af:	e8 aa 31 00 00       	call   8010545e <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022b4:	eb 2a                	jmp    801022e0 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022b9:	89 44 24 08          	mov    %eax,0x8(%esp)
801022bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801022c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801022c7:	89 04 24             	mov    %eax,(%esp)
801022ca:	e8 8f 31 00 00       	call   8010545e <memmove>
    name[len] = 0;
801022cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d5:	01 d0                	add    %edx,%eax
801022d7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022da:	eb 04                	jmp    801022e0 <skipelem+0xa3>
    path++;
801022dc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022e0:	8b 45 08             	mov    0x8(%ebp),%eax
801022e3:	0f b6 00             	movzbl (%eax),%eax
801022e6:	3c 2f                	cmp    $0x2f,%al
801022e8:	74 f2                	je     801022dc <skipelem+0x9f>
    path++;
  return path;
801022ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022ed:	c9                   	leave  
801022ee:	c3                   	ret    

801022ef <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022ef:	55                   	push   %ebp
801022f0:	89 e5                	mov    %esp,%ebp
801022f2:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801022f5:	8b 45 08             	mov    0x8(%ebp),%eax
801022f8:	0f b6 00             	movzbl (%eax),%eax
801022fb:	3c 2f                	cmp    $0x2f,%al
801022fd:	75 1c                	jne    8010231b <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
801022ff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102306:	00 
80102307:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010230e:	e8 44 f4 ff ff       	call   80101757 <iget>
80102313:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102316:	e9 af 00 00 00       	jmp    801023ca <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010231b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102321:	8b 40 60             	mov    0x60(%eax),%eax
80102324:	89 04 24             	mov    %eax,(%esp)
80102327:	e8 fd f4 ff ff       	call   80101829 <idup>
8010232c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010232f:	e9 96 00 00 00       	jmp    801023ca <namex+0xdb>
    ilock(ip);
80102334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102337:	89 04 24             	mov    %eax,(%esp)
8010233a:	e8 1c f5 ff ff       	call   8010185b <ilock>
    if(ip->type != T_DIR){
8010233f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102342:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102346:	66 83 f8 01          	cmp    $0x1,%ax
8010234a:	74 15                	je     80102361 <namex+0x72>
      iunlockput(ip);
8010234c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234f:	89 04 24             	mov    %eax,(%esp)
80102352:	e8 88 f7 ff ff       	call   80101adf <iunlockput>
      return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
8010235c:	e9 a3 00 00 00       	jmp    80102404 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102361:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102365:	74 1d                	je     80102384 <namex+0x95>
80102367:	8b 45 08             	mov    0x8(%ebp),%eax
8010236a:	0f b6 00             	movzbl (%eax),%eax
8010236d:	84 c0                	test   %al,%al
8010236f:	75 13                	jne    80102384 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102374:	89 04 24             	mov    %eax,(%esp)
80102377:	e8 2d f6 ff ff       	call   801019a9 <iunlock>
      return ip;
8010237c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237f:	e9 80 00 00 00       	jmp    80102404 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102384:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010238b:	00 
8010238c:	8b 45 10             	mov    0x10(%ebp),%eax
8010238f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102396:	89 04 24             	mov    %eax,(%esp)
80102399:	e8 df fc ff ff       	call   8010207d <dirlookup>
8010239e:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023a5:	75 12                	jne    801023b9 <namex+0xca>
      iunlockput(ip);
801023a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023aa:	89 04 24             	mov    %eax,(%esp)
801023ad:	e8 2d f7 ff ff       	call   80101adf <iunlockput>
      return 0;
801023b2:	b8 00 00 00 00       	mov    $0x0,%eax
801023b7:	eb 4b                	jmp    80102404 <namex+0x115>
    }
    iunlockput(ip);
801023b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bc:	89 04 24             	mov    %eax,(%esp)
801023bf:	e8 1b f7 ff ff       	call   80101adf <iunlockput>
    ip = next;
801023c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023ca:	8b 45 10             	mov    0x10(%ebp),%eax
801023cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801023d1:	8b 45 08             	mov    0x8(%ebp),%eax
801023d4:	89 04 24             	mov    %eax,(%esp)
801023d7:	e8 61 fe ff ff       	call   8010223d <skipelem>
801023dc:	89 45 08             	mov    %eax,0x8(%ebp)
801023df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023e3:	0f 85 4b ff ff ff    	jne    80102334 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023ed:	74 12                	je     80102401 <namex+0x112>
    iput(ip);
801023ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f2:	89 04 24             	mov    %eax,(%esp)
801023f5:	e8 14 f6 ff ff       	call   80101a0e <iput>
    return 0;
801023fa:	b8 00 00 00 00       	mov    $0x0,%eax
801023ff:	eb 03                	jmp    80102404 <namex+0x115>
  }
  return ip;
80102401:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102404:	c9                   	leave  
80102405:	c3                   	ret    

80102406 <namei>:

struct inode*
namei(char *path)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010240c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010240f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102413:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010241a:	00 
8010241b:	8b 45 08             	mov    0x8(%ebp),%eax
8010241e:	89 04 24             	mov    %eax,(%esp)
80102421:	e8 c9 fe ff ff       	call   801022ef <namex>
}
80102426:	c9                   	leave  
80102427:	c3                   	ret    

80102428 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102428:	55                   	push   %ebp
80102429:	89 e5                	mov    %esp,%ebp
8010242b:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010242e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102431:	89 44 24 08          	mov    %eax,0x8(%esp)
80102435:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010243c:	00 
8010243d:	8b 45 08             	mov    0x8(%ebp),%eax
80102440:	89 04 24             	mov    %eax,(%esp)
80102443:	e8 a7 fe ff ff       	call   801022ef <namex>
}
80102448:	c9                   	leave  
80102449:	c3                   	ret    

8010244a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010244a:	55                   	push   %ebp
8010244b:	89 e5                	mov    %esp,%ebp
8010244d:	83 ec 14             	sub    $0x14,%esp
80102450:	8b 45 08             	mov    0x8(%ebp),%eax
80102453:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102457:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010245b:	89 c2                	mov    %eax,%edx
8010245d:	ec                   	in     (%dx),%al
8010245e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102461:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102465:	c9                   	leave  
80102466:	c3                   	ret    

80102467 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102467:	55                   	push   %ebp
80102468:	89 e5                	mov    %esp,%ebp
8010246a:	57                   	push   %edi
8010246b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010246c:	8b 55 08             	mov    0x8(%ebp),%edx
8010246f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102472:	8b 45 10             	mov    0x10(%ebp),%eax
80102475:	89 cb                	mov    %ecx,%ebx
80102477:	89 df                	mov    %ebx,%edi
80102479:	89 c1                	mov    %eax,%ecx
8010247b:	fc                   	cld    
8010247c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010247e:	89 c8                	mov    %ecx,%eax
80102480:	89 fb                	mov    %edi,%ebx
80102482:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102485:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102488:	5b                   	pop    %ebx
80102489:	5f                   	pop    %edi
8010248a:	5d                   	pop    %ebp
8010248b:	c3                   	ret    

8010248c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010248c:	55                   	push   %ebp
8010248d:	89 e5                	mov    %esp,%ebp
8010248f:	83 ec 08             	sub    $0x8,%esp
80102492:	8b 55 08             	mov    0x8(%ebp),%edx
80102495:	8b 45 0c             	mov    0xc(%ebp),%eax
80102498:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010249c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010249f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024a3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024a7:	ee                   	out    %al,(%dx)
}
801024a8:	c9                   	leave  
801024a9:	c3                   	ret    

801024aa <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024aa:	55                   	push   %ebp
801024ab:	89 e5                	mov    %esp,%ebp
801024ad:	56                   	push   %esi
801024ae:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024af:	8b 55 08             	mov    0x8(%ebp),%edx
801024b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024b5:	8b 45 10             	mov    0x10(%ebp),%eax
801024b8:	89 cb                	mov    %ecx,%ebx
801024ba:	89 de                	mov    %ebx,%esi
801024bc:	89 c1                	mov    %eax,%ecx
801024be:	fc                   	cld    
801024bf:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024c1:	89 c8                	mov    %ecx,%eax
801024c3:	89 f3                	mov    %esi,%ebx
801024c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024c8:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024cb:	5b                   	pop    %ebx
801024cc:	5e                   	pop    %esi
801024cd:	5d                   	pop    %ebp
801024ce:	c3                   	ret    

801024cf <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024cf:	55                   	push   %ebp
801024d0:	89 e5                	mov    %esp,%ebp
801024d2:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024d5:	90                   	nop
801024d6:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024dd:	e8 68 ff ff ff       	call   8010244a <inb>
801024e2:	0f b6 c0             	movzbl %al,%eax
801024e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801024e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024eb:	25 c0 00 00 00       	and    $0xc0,%eax
801024f0:	83 f8 40             	cmp    $0x40,%eax
801024f3:	75 e1                	jne    801024d6 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801024f5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f9:	74 11                	je     8010250c <idewait+0x3d>
801024fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024fe:	83 e0 21             	and    $0x21,%eax
80102501:	85 c0                	test   %eax,%eax
80102503:	74 07                	je     8010250c <idewait+0x3d>
    return -1;
80102505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010250a:	eb 05                	jmp    80102511 <idewait+0x42>
  return 0;
8010250c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102511:	c9                   	leave  
80102512:	c3                   	ret    

80102513 <ideinit>:

void
ideinit(void)
{
80102513:	55                   	push   %ebp
80102514:	89 e5                	mov    %esp,%ebp
80102516:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102519:	c7 44 24 04 1c 8b 10 	movl   $0x80108b1c,0x4(%esp)
80102520:	80 
80102521:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102528:	e8 ed 2b 00 00       	call   8010511a <initlock>
  picenable(IRQ_IDE);
8010252d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102534:	e8 8d 18 00 00       	call   80103dc6 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102539:	a1 60 39 11 80       	mov    0x80113960,%eax
8010253e:	83 e8 01             	sub    $0x1,%eax
80102541:	89 44 24 04          	mov    %eax,0x4(%esp)
80102545:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010254c:	e8 0c 04 00 00       	call   8010295d <ioapicenable>
  idewait(0);
80102551:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102558:	e8 72 ff ff ff       	call   801024cf <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010255d:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102564:	00 
80102565:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010256c:	e8 1b ff ff ff       	call   8010248c <outb>
  for(i=0; i<1000; i++){
80102571:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102578:	eb 20                	jmp    8010259a <ideinit+0x87>
    if(inb(0x1f7) != 0){
8010257a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102581:	e8 c4 fe ff ff       	call   8010244a <inb>
80102586:	84 c0                	test   %al,%al
80102588:	74 0c                	je     80102596 <ideinit+0x83>
      havedisk1 = 1;
8010258a:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102591:	00 00 00 
      break;
80102594:	eb 0d                	jmp    801025a3 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102596:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010259a:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025a1:	7e d7                	jle    8010257a <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025a3:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025aa:	00 
801025ab:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025b2:	e8 d5 fe ff ff       	call   8010248c <outb>
}
801025b7:	c9                   	leave  
801025b8:	c3                   	ret    

801025b9 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025b9:	55                   	push   %ebp
801025ba:	89 e5                	mov    %esp,%ebp
801025bc:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025c3:	75 0c                	jne    801025d1 <idestart+0x18>
    panic("idestart");
801025c5:	c7 04 24 20 8b 10 80 	movl   $0x80108b20,(%esp)
801025cc:	e8 69 df ff ff       	call   8010053a <panic>

  idewait(0);
801025d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025d8:	e8 f2 fe ff ff       	call   801024cf <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025e4:	00 
801025e5:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801025ec:	e8 9b fe ff ff       	call   8010248c <outb>
  outb(0x1f2, 1);  // number of sectors
801025f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025f8:	00 
801025f9:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102600:	e8 87 fe ff ff       	call   8010248c <outb>
  outb(0x1f3, b->sector & 0xff);
80102605:	8b 45 08             	mov    0x8(%ebp),%eax
80102608:	8b 40 08             	mov    0x8(%eax),%eax
8010260b:	0f b6 c0             	movzbl %al,%eax
8010260e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102612:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102619:	e8 6e fe ff ff       	call   8010248c <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010261e:	8b 45 08             	mov    0x8(%ebp),%eax
80102621:	8b 40 08             	mov    0x8(%eax),%eax
80102624:	c1 e8 08             	shr    $0x8,%eax
80102627:	0f b6 c0             	movzbl %al,%eax
8010262a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010262e:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102635:	e8 52 fe ff ff       	call   8010248c <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
8010263a:	8b 45 08             	mov    0x8(%ebp),%eax
8010263d:	8b 40 08             	mov    0x8(%eax),%eax
80102640:	c1 e8 10             	shr    $0x10,%eax
80102643:	0f b6 c0             	movzbl %al,%eax
80102646:	89 44 24 04          	mov    %eax,0x4(%esp)
8010264a:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102651:	e8 36 fe ff ff       	call   8010248c <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102656:	8b 45 08             	mov    0x8(%ebp),%eax
80102659:	8b 40 04             	mov    0x4(%eax),%eax
8010265c:	83 e0 01             	and    $0x1,%eax
8010265f:	c1 e0 04             	shl    $0x4,%eax
80102662:	89 c2                	mov    %eax,%edx
80102664:	8b 45 08             	mov    0x8(%ebp),%eax
80102667:	8b 40 08             	mov    0x8(%eax),%eax
8010266a:	c1 e8 18             	shr    $0x18,%eax
8010266d:	83 e0 0f             	and    $0xf,%eax
80102670:	09 d0                	or     %edx,%eax
80102672:	83 c8 e0             	or     $0xffffffe0,%eax
80102675:	0f b6 c0             	movzbl %al,%eax
80102678:	89 44 24 04          	mov    %eax,0x4(%esp)
8010267c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102683:	e8 04 fe ff ff       	call   8010248c <outb>
  if(b->flags & B_DIRTY){
80102688:	8b 45 08             	mov    0x8(%ebp),%eax
8010268b:	8b 00                	mov    (%eax),%eax
8010268d:	83 e0 04             	and    $0x4,%eax
80102690:	85 c0                	test   %eax,%eax
80102692:	74 34                	je     801026c8 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102694:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
8010269b:	00 
8010269c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026a3:	e8 e4 fd ff ff       	call   8010248c <outb>
    outsl(0x1f0, b->data, 512/4);
801026a8:	8b 45 08             	mov    0x8(%ebp),%eax
801026ab:	83 c0 18             	add    $0x18,%eax
801026ae:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026b5:	00 
801026b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ba:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026c1:	e8 e4 fd ff ff       	call   801024aa <outsl>
801026c6:	eb 14                	jmp    801026dc <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026c8:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026cf:	00 
801026d0:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026d7:	e8 b0 fd ff ff       	call   8010248c <outb>
  }
}
801026dc:	c9                   	leave  
801026dd:	c3                   	ret    

801026de <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026de:	55                   	push   %ebp
801026df:	89 e5                	mov    %esp,%ebp
801026e1:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801026e4:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
801026eb:	e8 4b 2a 00 00       	call   8010513b <acquire>
  if((b = idequeue) == 0){
801026f0:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801026f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801026fc:	75 11                	jne    8010270f <ideintr+0x31>
    release(&idelock);
801026fe:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102705:	e8 93 2a 00 00       	call   8010519d <release>
    // cprintf("spurious IDE interrupt\n");
    return;
8010270a:	e9 90 00 00 00       	jmp    8010279f <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010270f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102712:	8b 40 14             	mov    0x14(%eax),%eax
80102715:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271d:	8b 00                	mov    (%eax),%eax
8010271f:	83 e0 04             	and    $0x4,%eax
80102722:	85 c0                	test   %eax,%eax
80102724:	75 2e                	jne    80102754 <ideintr+0x76>
80102726:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010272d:	e8 9d fd ff ff       	call   801024cf <idewait>
80102732:	85 c0                	test   %eax,%eax
80102734:	78 1e                	js     80102754 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102739:	83 c0 18             	add    $0x18,%eax
8010273c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102743:	00 
80102744:	89 44 24 04          	mov    %eax,0x4(%esp)
80102748:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010274f:	e8 13 fd ff ff       	call   80102467 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102757:	8b 00                	mov    (%eax),%eax
80102759:	83 c8 02             	or     $0x2,%eax
8010275c:	89 c2                	mov    %eax,%edx
8010275e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102761:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102766:	8b 00                	mov    (%eax),%eax
80102768:	83 e0 fb             	and    $0xfffffffb,%eax
8010276b:	89 c2                	mov    %eax,%edx
8010276d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102770:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102775:	89 04 24             	mov    %eax,(%esp)
80102778:	e8 74 27 00 00       	call   80104ef1 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010277d:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102782:	85 c0                	test   %eax,%eax
80102784:	74 0d                	je     80102793 <ideintr+0xb5>
    idestart(idequeue);
80102786:	a1 34 c6 10 80       	mov    0x8010c634,%eax
8010278b:	89 04 24             	mov    %eax,(%esp)
8010278e:	e8 26 fe ff ff       	call   801025b9 <idestart>

  release(&idelock);
80102793:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
8010279a:	e8 fe 29 00 00       	call   8010519d <release>
}
8010279f:	c9                   	leave  
801027a0:	c3                   	ret    

801027a1 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027a1:	55                   	push   %ebp
801027a2:	89 e5                	mov    %esp,%ebp
801027a4:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027a7:	8b 45 08             	mov    0x8(%ebp),%eax
801027aa:	8b 00                	mov    (%eax),%eax
801027ac:	83 e0 01             	and    $0x1,%eax
801027af:	85 c0                	test   %eax,%eax
801027b1:	75 0c                	jne    801027bf <iderw+0x1e>
    panic("iderw: buf not busy");
801027b3:	c7 04 24 29 8b 10 80 	movl   $0x80108b29,(%esp)
801027ba:	e8 7b dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027bf:	8b 45 08             	mov    0x8(%ebp),%eax
801027c2:	8b 00                	mov    (%eax),%eax
801027c4:	83 e0 06             	and    $0x6,%eax
801027c7:	83 f8 02             	cmp    $0x2,%eax
801027ca:	75 0c                	jne    801027d8 <iderw+0x37>
    panic("iderw: nothing to do");
801027cc:	c7 04 24 3d 8b 10 80 	movl   $0x80108b3d,(%esp)
801027d3:	e8 62 dd ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801027d8:	8b 45 08             	mov    0x8(%ebp),%eax
801027db:	8b 40 04             	mov    0x4(%eax),%eax
801027de:	85 c0                	test   %eax,%eax
801027e0:	74 15                	je     801027f7 <iderw+0x56>
801027e2:	a1 38 c6 10 80       	mov    0x8010c638,%eax
801027e7:	85 c0                	test   %eax,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027eb:	c7 04 24 52 8b 10 80 	movl   $0x80108b52,(%esp)
801027f2:	e8 43 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801027f7:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
801027fe:	e8 38 29 00 00       	call   8010513b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010280d:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102814:	eb 0b                	jmp    80102821 <iderw+0x80>
80102816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102819:	8b 00                	mov    (%eax),%eax
8010281b:	83 c0 14             	add    $0x14,%eax
8010281e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102824:	8b 00                	mov    (%eax),%eax
80102826:	85 c0                	test   %eax,%eax
80102828:	75 ec                	jne    80102816 <iderw+0x75>
    ;
  *pp = b;
8010282a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282d:	8b 55 08             	mov    0x8(%ebp),%edx
80102830:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102832:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102837:	3b 45 08             	cmp    0x8(%ebp),%eax
8010283a:	75 0d                	jne    80102849 <iderw+0xa8>
    idestart(b);
8010283c:	8b 45 08             	mov    0x8(%ebp),%eax
8010283f:	89 04 24             	mov    %eax,(%esp)
80102842:	e8 72 fd ff ff       	call   801025b9 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102847:	eb 15                	jmp    8010285e <iderw+0xbd>
80102849:	eb 13                	jmp    8010285e <iderw+0xbd>
    sleep(b, &idelock);
8010284b:	c7 44 24 04 00 c6 10 	movl   $0x8010c600,0x4(%esp)
80102852:	80 
80102853:	8b 45 08             	mov    0x8(%ebp),%eax
80102856:	89 04 24             	mov    %eax,(%esp)
80102859:	e8 4c 25 00 00       	call   80104daa <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010285e:	8b 45 08             	mov    0x8(%ebp),%eax
80102861:	8b 00                	mov    (%eax),%eax
80102863:	83 e0 06             	and    $0x6,%eax
80102866:	83 f8 02             	cmp    $0x2,%eax
80102869:	75 e0                	jne    8010284b <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
8010286b:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102872:	e8 26 29 00 00       	call   8010519d <release>
}
80102877:	c9                   	leave  
80102878:	c3                   	ret    

80102879 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102879:	55                   	push   %ebp
8010287a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010287c:	a1 14 32 11 80       	mov    0x80113214,%eax
80102881:	8b 55 08             	mov    0x8(%ebp),%edx
80102884:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102886:	a1 14 32 11 80       	mov    0x80113214,%eax
8010288b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010288e:	5d                   	pop    %ebp
8010288f:	c3                   	ret    

80102890 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102890:	55                   	push   %ebp
80102891:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102893:	a1 14 32 11 80       	mov    0x80113214,%eax
80102898:	8b 55 08             	mov    0x8(%ebp),%edx
8010289b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010289d:	a1 14 32 11 80       	mov    0x80113214,%eax
801028a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801028a5:	89 50 10             	mov    %edx,0x10(%eax)
}
801028a8:	5d                   	pop    %ebp
801028a9:	c3                   	ret    

801028aa <ioapicinit>:

void
ioapicinit(void)
{
801028aa:	55                   	push   %ebp
801028ab:	89 e5                	mov    %esp,%ebp
801028ad:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028b0:	a1 44 33 11 80       	mov    0x80113344,%eax
801028b5:	85 c0                	test   %eax,%eax
801028b7:	75 05                	jne    801028be <ioapicinit+0x14>
    return;
801028b9:	e9 9d 00 00 00       	jmp    8010295b <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801028be:	c7 05 14 32 11 80 00 	movl   $0xfec00000,0x80113214
801028c5:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028cf:	e8 a5 ff ff ff       	call   80102879 <ioapicread>
801028d4:	c1 e8 10             	shr    $0x10,%eax
801028d7:	25 ff 00 00 00       	and    $0xff,%eax
801028dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801028df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028e6:	e8 8e ff ff ff       	call   80102879 <ioapicread>
801028eb:	c1 e8 18             	shr    $0x18,%eax
801028ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801028f1:	0f b6 05 40 33 11 80 	movzbl 0x80113340,%eax
801028f8:	0f b6 c0             	movzbl %al,%eax
801028fb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801028fe:	74 0c                	je     8010290c <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102900:	c7 04 24 70 8b 10 80 	movl   $0x80108b70,(%esp)
80102907:	e8 94 da ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010290c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102913:	eb 3e                	jmp    80102953 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102918:	83 c0 20             	add    $0x20,%eax
8010291b:	0d 00 00 01 00       	or     $0x10000,%eax
80102920:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102923:	83 c2 08             	add    $0x8,%edx
80102926:	01 d2                	add    %edx,%edx
80102928:	89 44 24 04          	mov    %eax,0x4(%esp)
8010292c:	89 14 24             	mov    %edx,(%esp)
8010292f:	e8 5c ff ff ff       	call   80102890 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102937:	83 c0 08             	add    $0x8,%eax
8010293a:	01 c0                	add    %eax,%eax
8010293c:	83 c0 01             	add    $0x1,%eax
8010293f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102946:	00 
80102947:	89 04 24             	mov    %eax,(%esp)
8010294a:	e8 41 ff ff ff       	call   80102890 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010294f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102956:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102959:	7e ba                	jle    80102915 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010295b:	c9                   	leave  
8010295c:	c3                   	ret    

8010295d <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010295d:	55                   	push   %ebp
8010295e:	89 e5                	mov    %esp,%ebp
80102960:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102963:	a1 44 33 11 80       	mov    0x80113344,%eax
80102968:	85 c0                	test   %eax,%eax
8010296a:	75 02                	jne    8010296e <ioapicenable+0x11>
    return;
8010296c:	eb 37                	jmp    801029a5 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010296e:	8b 45 08             	mov    0x8(%ebp),%eax
80102971:	83 c0 20             	add    $0x20,%eax
80102974:	8b 55 08             	mov    0x8(%ebp),%edx
80102977:	83 c2 08             	add    $0x8,%edx
8010297a:	01 d2                	add    %edx,%edx
8010297c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102980:	89 14 24             	mov    %edx,(%esp)
80102983:	e8 08 ff ff ff       	call   80102890 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102988:	8b 45 0c             	mov    0xc(%ebp),%eax
8010298b:	c1 e0 18             	shl    $0x18,%eax
8010298e:	8b 55 08             	mov    0x8(%ebp),%edx
80102991:	83 c2 08             	add    $0x8,%edx
80102994:	01 d2                	add    %edx,%edx
80102996:	83 c2 01             	add    $0x1,%edx
80102999:	89 44 24 04          	mov    %eax,0x4(%esp)
8010299d:	89 14 24             	mov    %edx,(%esp)
801029a0:	e8 eb fe ff ff       	call   80102890 <ioapicwrite>
}
801029a5:	c9                   	leave  
801029a6:	c3                   	ret    

801029a7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029a7:	55                   	push   %ebp
801029a8:	89 e5                	mov    %esp,%ebp
801029aa:	8b 45 08             	mov    0x8(%ebp),%eax
801029ad:	05 00 00 00 80       	add    $0x80000000,%eax
801029b2:	5d                   	pop    %ebp
801029b3:	c3                   	ret    

801029b4 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029b4:	55                   	push   %ebp
801029b5:	89 e5                	mov    %esp,%ebp
801029b7:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029ba:	c7 44 24 04 a2 8b 10 	movl   $0x80108ba2,0x4(%esp)
801029c1:	80 
801029c2:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
801029c9:	e8 4c 27 00 00       	call   8010511a <initlock>
  kmem.use_lock = 0;
801029ce:	c7 05 54 32 11 80 00 	movl   $0x0,0x80113254
801029d5:	00 00 00 
  freerange(vstart, vend);
801029d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801029db:	89 44 24 04          	mov    %eax,0x4(%esp)
801029df:	8b 45 08             	mov    0x8(%ebp),%eax
801029e2:	89 04 24             	mov    %eax,(%esp)
801029e5:	e8 26 00 00 00       	call   80102a10 <freerange>
}
801029ea:	c9                   	leave  
801029eb:	c3                   	ret    

801029ec <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801029ec:	55                   	push   %ebp
801029ed:	89 e5                	mov    %esp,%ebp
801029ef:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
801029f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801029f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f9:	8b 45 08             	mov    0x8(%ebp),%eax
801029fc:	89 04 24             	mov    %eax,(%esp)
801029ff:	e8 0c 00 00 00       	call   80102a10 <freerange>
  kmem.use_lock = 1;
80102a04:	c7 05 54 32 11 80 01 	movl   $0x1,0x80113254
80102a0b:	00 00 00 
}
80102a0e:	c9                   	leave  
80102a0f:	c3                   	ret    

80102a10 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a10:	55                   	push   %ebp
80102a11:	89 e5                	mov    %esp,%ebp
80102a13:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a16:	8b 45 08             	mov    0x8(%ebp),%eax
80102a19:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a23:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a26:	eb 12                	jmp    80102a3a <freerange+0x2a>
    kfree(p);
80102a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2b:	89 04 24             	mov    %eax,(%esp)
80102a2e:	e8 16 00 00 00       	call   80102a49 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a33:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3d:	05 00 10 00 00       	add    $0x1000,%eax
80102a42:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a45:	76 e1                	jbe    80102a28 <freerange+0x18>
    kfree(p);
}
80102a47:	c9                   	leave  
80102a48:	c3                   	ret    

80102a49 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a49:	55                   	push   %ebp
80102a4a:	89 e5                	mov    %esp,%ebp
80102a4c:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a52:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a57:	85 c0                	test   %eax,%eax
80102a59:	75 1b                	jne    80102a76 <kfree+0x2d>
80102a5b:	81 7d 08 5c ee 11 80 	cmpl   $0x8011ee5c,0x8(%ebp)
80102a62:	72 12                	jb     80102a76 <kfree+0x2d>
80102a64:	8b 45 08             	mov    0x8(%ebp),%eax
80102a67:	89 04 24             	mov    %eax,(%esp)
80102a6a:	e8 38 ff ff ff       	call   801029a7 <v2p>
80102a6f:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a74:	76 0c                	jbe    80102a82 <kfree+0x39>
    panic("kfree");
80102a76:	c7 04 24 a7 8b 10 80 	movl   $0x80108ba7,(%esp)
80102a7d:	e8 b8 da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a82:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a89:	00 
80102a8a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a91:	00 
80102a92:	8b 45 08             	mov    0x8(%ebp),%eax
80102a95:	89 04 24             	mov    %eax,(%esp)
80102a98:	e8 f2 28 00 00       	call   8010538f <memset>

  if(kmem.use_lock)
80102a9d:	a1 54 32 11 80       	mov    0x80113254,%eax
80102aa2:	85 c0                	test   %eax,%eax
80102aa4:	74 0c                	je     80102ab2 <kfree+0x69>
    acquire(&kmem.lock);
80102aa6:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102aad:	e8 89 26 00 00       	call   8010513b <acquire>
  r = (struct run*)v;
80102ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ab8:	8b 15 58 32 11 80    	mov    0x80113258,%edx
80102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac1:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac6:	a3 58 32 11 80       	mov    %eax,0x80113258
  if(kmem.use_lock)
80102acb:	a1 54 32 11 80       	mov    0x80113254,%eax
80102ad0:	85 c0                	test   %eax,%eax
80102ad2:	74 0c                	je     80102ae0 <kfree+0x97>
    release(&kmem.lock);
80102ad4:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102adb:	e8 bd 26 00 00       	call   8010519d <release>
}
80102ae0:	c9                   	leave  
80102ae1:	c3                   	ret    

80102ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102ae2:	55                   	push   %ebp
80102ae3:	89 e5                	mov    %esp,%ebp
80102ae5:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102ae8:	a1 54 32 11 80       	mov    0x80113254,%eax
80102aed:	85 c0                	test   %eax,%eax
80102aef:	74 0c                	je     80102afd <kalloc+0x1b>
    acquire(&kmem.lock);
80102af1:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102af8:	e8 3e 26 00 00       	call   8010513b <acquire>
  r = kmem.freelist;
80102afd:	a1 58 32 11 80       	mov    0x80113258,%eax
80102b02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b09:	74 0a                	je     80102b15 <kalloc+0x33>
    kmem.freelist = r->next;
80102b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0e:	8b 00                	mov    (%eax),%eax
80102b10:	a3 58 32 11 80       	mov    %eax,0x80113258
  if(kmem.use_lock)
80102b15:	a1 54 32 11 80       	mov    0x80113254,%eax
80102b1a:	85 c0                	test   %eax,%eax
80102b1c:	74 0c                	je     80102b2a <kalloc+0x48>
    release(&kmem.lock);
80102b1e:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102b25:	e8 73 26 00 00       	call   8010519d <release>
  return (char*)r;
80102b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b2d:	c9                   	leave  
80102b2e:	c3                   	ret    

80102b2f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b2f:	55                   	push   %ebp
80102b30:	89 e5                	mov    %esp,%ebp
80102b32:	83 ec 14             	sub    $0x14,%esp
80102b35:	8b 45 08             	mov    0x8(%ebp),%eax
80102b38:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b3c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102b40:	89 c2                	mov    %eax,%edx
80102b42:	ec                   	in     (%dx),%al
80102b43:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102b46:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102b4a:	c9                   	leave  
80102b4b:	c3                   	ret    

80102b4c <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b4c:	55                   	push   %ebp
80102b4d:	89 e5                	mov    %esp,%ebp
80102b4f:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b52:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b59:	e8 d1 ff ff ff       	call   80102b2f <inb>
80102b5e:	0f b6 c0             	movzbl %al,%eax
80102b61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b67:	83 e0 01             	and    $0x1,%eax
80102b6a:	85 c0                	test   %eax,%eax
80102b6c:	75 0a                	jne    80102b78 <kbdgetc+0x2c>
    return -1;
80102b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b73:	e9 25 01 00 00       	jmp    80102c9d <kbdgetc+0x151>
  data = inb(KBDATAP);
80102b78:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102b7f:	e8 ab ff ff ff       	call   80102b2f <inb>
80102b84:	0f b6 c0             	movzbl %al,%eax
80102b87:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102b8a:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102b91:	75 17                	jne    80102baa <kbdgetc+0x5e>
    shift |= E0ESC;
80102b93:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102b98:	83 c8 40             	or     $0x40,%eax
80102b9b:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102ba0:	b8 00 00 00 00       	mov    $0x0,%eax
80102ba5:	e9 f3 00 00 00       	jmp    80102c9d <kbdgetc+0x151>
  } else if(data & 0x80){
80102baa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bad:	25 80 00 00 00       	and    $0x80,%eax
80102bb2:	85 c0                	test   %eax,%eax
80102bb4:	74 45                	je     80102bfb <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102bb6:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102bbb:	83 e0 40             	and    $0x40,%eax
80102bbe:	85 c0                	test   %eax,%eax
80102bc0:	75 08                	jne    80102bca <kbdgetc+0x7e>
80102bc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bc5:	83 e0 7f             	and    $0x7f,%eax
80102bc8:	eb 03                	jmp    80102bcd <kbdgetc+0x81>
80102bca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bcd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102bd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bd3:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102bd8:	0f b6 00             	movzbl (%eax),%eax
80102bdb:	83 c8 40             	or     $0x40,%eax
80102bde:	0f b6 c0             	movzbl %al,%eax
80102be1:	f7 d0                	not    %eax
80102be3:	89 c2                	mov    %eax,%edx
80102be5:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102bea:	21 d0                	and    %edx,%eax
80102bec:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102bf1:	b8 00 00 00 00       	mov    $0x0,%eax
80102bf6:	e9 a2 00 00 00       	jmp    80102c9d <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102bfb:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c00:	83 e0 40             	and    $0x40,%eax
80102c03:	85 c0                	test   %eax,%eax
80102c05:	74 14                	je     80102c1b <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c07:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c0e:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c13:	83 e0 bf             	and    $0xffffffbf,%eax
80102c16:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102c1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c1e:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c23:	0f b6 00             	movzbl (%eax),%eax
80102c26:	0f b6 d0             	movzbl %al,%edx
80102c29:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c2e:	09 d0                	or     %edx,%eax
80102c30:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102c35:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c38:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102c3d:	0f b6 00             	movzbl (%eax),%eax
80102c40:	0f b6 d0             	movzbl %al,%edx
80102c43:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c48:	31 d0                	xor    %edx,%eax
80102c4a:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c4f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c54:	83 e0 03             	and    $0x3,%eax
80102c57:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102c5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c61:	01 d0                	add    %edx,%eax
80102c63:	0f b6 00             	movzbl (%eax),%eax
80102c66:	0f b6 c0             	movzbl %al,%eax
80102c69:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c6c:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c71:	83 e0 08             	and    $0x8,%eax
80102c74:	85 c0                	test   %eax,%eax
80102c76:	74 22                	je     80102c9a <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102c78:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102c7c:	76 0c                	jbe    80102c8a <kbdgetc+0x13e>
80102c7e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102c82:	77 06                	ja     80102c8a <kbdgetc+0x13e>
      c += 'A' - 'a';
80102c84:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102c88:	eb 10                	jmp    80102c9a <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102c8a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102c8e:	76 0a                	jbe    80102c9a <kbdgetc+0x14e>
80102c90:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102c94:	77 04                	ja     80102c9a <kbdgetc+0x14e>
      c += 'a' - 'A';
80102c96:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102c9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102c9d:	c9                   	leave  
80102c9e:	c3                   	ret    

80102c9f <kbdintr>:

void
kbdintr(void)
{
80102c9f:	55                   	push   %ebp
80102ca0:	89 e5                	mov    %esp,%ebp
80102ca2:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102ca5:	c7 04 24 4c 2b 10 80 	movl   $0x80102b4c,(%esp)
80102cac:	e8 fc da ff ff       	call   801007ad <consoleintr>
}
80102cb1:	c9                   	leave  
80102cb2:	c3                   	ret    

80102cb3 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cb3:	55                   	push   %ebp
80102cb4:	89 e5                	mov    %esp,%ebp
80102cb6:	83 ec 14             	sub    $0x14,%esp
80102cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80102cbc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cc0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cc4:	89 c2                	mov    %eax,%edx
80102cc6:	ec                   	in     (%dx),%al
80102cc7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cca:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cce:	c9                   	leave  
80102ccf:	c3                   	ret    

80102cd0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102cd0:	55                   	push   %ebp
80102cd1:	89 e5                	mov    %esp,%ebp
80102cd3:	83 ec 08             	sub    $0x8,%esp
80102cd6:	8b 55 08             	mov    0x8(%ebp),%edx
80102cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cdc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ce0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ce3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ce7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ceb:	ee                   	out    %al,(%dx)
}
80102cec:	c9                   	leave  
80102ced:	c3                   	ret    

80102cee <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102cee:	55                   	push   %ebp
80102cef:	89 e5                	mov    %esp,%ebp
80102cf1:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102cf4:	9c                   	pushf  
80102cf5:	58                   	pop    %eax
80102cf6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102cf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102cfc:	c9                   	leave  
80102cfd:	c3                   	ret    

80102cfe <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102cfe:	55                   	push   %ebp
80102cff:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d01:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102d06:	8b 55 08             	mov    0x8(%ebp),%edx
80102d09:	c1 e2 02             	shl    $0x2,%edx
80102d0c:	01 c2                	add    %eax,%edx
80102d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d11:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d13:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102d18:	83 c0 20             	add    $0x20,%eax
80102d1b:	8b 00                	mov    (%eax),%eax
}
80102d1d:	5d                   	pop    %ebp
80102d1e:	c3                   	ret    

80102d1f <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d1f:	55                   	push   %ebp
80102d20:	89 e5                	mov    %esp,%ebp
80102d22:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d25:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102d2a:	85 c0                	test   %eax,%eax
80102d2c:	75 05                	jne    80102d33 <lapicinit+0x14>
    return;
80102d2e:	e9 43 01 00 00       	jmp    80102e76 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d33:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d3a:	00 
80102d3b:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d42:	e8 b7 ff ff ff       	call   80102cfe <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d47:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d4e:	00 
80102d4f:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d56:	e8 a3 ff ff ff       	call   80102cfe <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d5b:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d62:	00 
80102d63:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d6a:	e8 8f ff ff ff       	call   80102cfe <lapicw>
  lapicw(TICR, 10000000); 
80102d6f:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d76:	00 
80102d77:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d7e:	e8 7b ff ff ff       	call   80102cfe <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102d83:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d8a:	00 
80102d8b:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102d92:	e8 67 ff ff ff       	call   80102cfe <lapicw>
  lapicw(LINT1, MASKED);
80102d97:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d9e:	00 
80102d9f:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102da6:	e8 53 ff ff ff       	call   80102cfe <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102dab:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102db0:	83 c0 30             	add    $0x30,%eax
80102db3:	8b 00                	mov    (%eax),%eax
80102db5:	c1 e8 10             	shr    $0x10,%eax
80102db8:	0f b6 c0             	movzbl %al,%eax
80102dbb:	83 f8 03             	cmp    $0x3,%eax
80102dbe:	76 14                	jbe    80102dd4 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102dc0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dc7:	00 
80102dc8:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102dcf:	e8 2a ff ff ff       	call   80102cfe <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102dd4:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102ddb:	00 
80102ddc:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102de3:	e8 16 ff ff ff       	call   80102cfe <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102de8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102def:	00 
80102df0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102df7:	e8 02 ff ff ff       	call   80102cfe <lapicw>
  lapicw(ESR, 0);
80102dfc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e03:	00 
80102e04:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e0b:	e8 ee fe ff ff       	call   80102cfe <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e17:	00 
80102e18:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e1f:	e8 da fe ff ff       	call   80102cfe <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e2b:	00 
80102e2c:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e33:	e8 c6 fe ff ff       	call   80102cfe <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e38:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e3f:	00 
80102e40:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e47:	e8 b2 fe ff ff       	call   80102cfe <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e4c:	90                   	nop
80102e4d:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102e52:	05 00 03 00 00       	add    $0x300,%eax
80102e57:	8b 00                	mov    (%eax),%eax
80102e59:	25 00 10 00 00       	and    $0x1000,%eax
80102e5e:	85 c0                	test   %eax,%eax
80102e60:	75 eb                	jne    80102e4d <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e69:	00 
80102e6a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e71:	e8 88 fe ff ff       	call   80102cfe <lapicw>
}
80102e76:	c9                   	leave  
80102e77:	c3                   	ret    

80102e78 <cpunum>:

int
cpunum(void)
{
80102e78:	55                   	push   %ebp
80102e79:	89 e5                	mov    %esp,%ebp
80102e7b:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102e7e:	e8 6b fe ff ff       	call   80102cee <readeflags>
80102e83:	25 00 02 00 00       	and    $0x200,%eax
80102e88:	85 c0                	test   %eax,%eax
80102e8a:	74 25                	je     80102eb1 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102e8c:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80102e91:	8d 50 01             	lea    0x1(%eax),%edx
80102e94:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
80102e9a:	85 c0                	test   %eax,%eax
80102e9c:	75 13                	jne    80102eb1 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102e9e:	8b 45 04             	mov    0x4(%ebp),%eax
80102ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ea5:	c7 04 24 b0 8b 10 80 	movl   $0x80108bb0,(%esp)
80102eac:	e8 ef d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102eb1:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102eb6:	85 c0                	test   %eax,%eax
80102eb8:	74 0f                	je     80102ec9 <cpunum+0x51>
    return lapic[ID]>>24;
80102eba:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102ebf:	83 c0 20             	add    $0x20,%eax
80102ec2:	8b 00                	mov    (%eax),%eax
80102ec4:	c1 e8 18             	shr    $0x18,%eax
80102ec7:	eb 05                	jmp    80102ece <cpunum+0x56>
  return 0;
80102ec9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102ece:	c9                   	leave  
80102ecf:	c3                   	ret    

80102ed0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102ed0:	55                   	push   %ebp
80102ed1:	89 e5                	mov    %esp,%ebp
80102ed3:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102ed6:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102edb:	85 c0                	test   %eax,%eax
80102edd:	74 14                	je     80102ef3 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102edf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee6:	00 
80102ee7:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102eee:	e8 0b fe ff ff       	call   80102cfe <lapicw>
}
80102ef3:	c9                   	leave  
80102ef4:	c3                   	ret    

80102ef5 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102ef5:	55                   	push   %ebp
80102ef6:	89 e5                	mov    %esp,%ebp
}
80102ef8:	5d                   	pop    %ebp
80102ef9:	c3                   	ret    

80102efa <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102efa:	55                   	push   %ebp
80102efb:	89 e5                	mov    %esp,%ebp
80102efd:	83 ec 1c             	sub    $0x1c,%esp
80102f00:	8b 45 08             	mov    0x8(%ebp),%eax
80102f03:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f06:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f0d:	00 
80102f0e:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f15:	e8 b6 fd ff ff       	call   80102cd0 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f1a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f21:	00 
80102f22:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f29:	e8 a2 fd ff ff       	call   80102cd0 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f2e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f35:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f38:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f40:	8d 50 02             	lea    0x2(%eax),%edx
80102f43:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f46:	c1 e8 04             	shr    $0x4,%eax
80102f49:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f4c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f50:	c1 e0 18             	shl    $0x18,%eax
80102f53:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f57:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f5e:	e8 9b fd ff ff       	call   80102cfe <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102f63:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f6a:	00 
80102f6b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f72:	e8 87 fd ff ff       	call   80102cfe <lapicw>
  microdelay(200);
80102f77:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f7e:	e8 72 ff ff ff       	call   80102ef5 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102f83:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102f8a:	00 
80102f8b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f92:	e8 67 fd ff ff       	call   80102cfe <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102f97:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102f9e:	e8 52 ff ff ff       	call   80102ef5 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fa3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102faa:	eb 40                	jmp    80102fec <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102fac:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fb0:	c1 e0 18             	shl    $0x18,%eax
80102fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fb7:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fbe:	e8 3b fd ff ff       	call   80102cfe <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fc6:	c1 e8 0c             	shr    $0xc,%eax
80102fc9:	80 cc 06             	or     $0x6,%ah
80102fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fd0:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fd7:	e8 22 fd ff ff       	call   80102cfe <lapicw>
    microdelay(200);
80102fdc:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fe3:	e8 0d ff ff ff       	call   80102ef5 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fe8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102fec:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102ff0:	7e ba                	jle    80102fac <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80102ff2:	c9                   	leave  
80102ff3:	c3                   	ret    

80102ff4 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102ff4:	55                   	push   %ebp
80102ff5:	89 e5                	mov    %esp,%ebp
80102ff7:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80102ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80102ffd:	0f b6 c0             	movzbl %al,%eax
80103000:	89 44 24 04          	mov    %eax,0x4(%esp)
80103004:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010300b:	e8 c0 fc ff ff       	call   80102cd0 <outb>
  microdelay(200);
80103010:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103017:	e8 d9 fe ff ff       	call   80102ef5 <microdelay>

  return inb(CMOS_RETURN);
8010301c:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103023:	e8 8b fc ff ff       	call   80102cb3 <inb>
80103028:	0f b6 c0             	movzbl %al,%eax
}
8010302b:	c9                   	leave  
8010302c:	c3                   	ret    

8010302d <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010302d:	55                   	push   %ebp
8010302e:	89 e5                	mov    %esp,%ebp
80103030:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103033:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010303a:	e8 b5 ff ff ff       	call   80102ff4 <cmos_read>
8010303f:	8b 55 08             	mov    0x8(%ebp),%edx
80103042:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103044:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010304b:	e8 a4 ff ff ff       	call   80102ff4 <cmos_read>
80103050:	8b 55 08             	mov    0x8(%ebp),%edx
80103053:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103056:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010305d:	e8 92 ff ff ff       	call   80102ff4 <cmos_read>
80103062:	8b 55 08             	mov    0x8(%ebp),%edx
80103065:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103068:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010306f:	e8 80 ff ff ff       	call   80102ff4 <cmos_read>
80103074:	8b 55 08             	mov    0x8(%ebp),%edx
80103077:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010307a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103081:	e8 6e ff ff ff       	call   80102ff4 <cmos_read>
80103086:	8b 55 08             	mov    0x8(%ebp),%edx
80103089:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010308c:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103093:	e8 5c ff ff ff       	call   80102ff4 <cmos_read>
80103098:	8b 55 08             	mov    0x8(%ebp),%edx
8010309b:	89 42 14             	mov    %eax,0x14(%edx)
}
8010309e:	c9                   	leave  
8010309f:	c3                   	ret    

801030a0 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801030a0:	55                   	push   %ebp
801030a1:	89 e5                	mov    %esp,%ebp
801030a3:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801030a6:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801030ad:	e8 42 ff ff ff       	call   80102ff4 <cmos_read>
801030b2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801030b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030b8:	83 e0 04             	and    $0x4,%eax
801030bb:	85 c0                	test   %eax,%eax
801030bd:	0f 94 c0             	sete   %al
801030c0:	0f b6 c0             	movzbl %al,%eax
801030c3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801030c6:	8d 45 d8             	lea    -0x28(%ebp),%eax
801030c9:	89 04 24             	mov    %eax,(%esp)
801030cc:	e8 5c ff ff ff       	call   8010302d <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801030d1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801030d8:	e8 17 ff ff ff       	call   80102ff4 <cmos_read>
801030dd:	25 80 00 00 00       	and    $0x80,%eax
801030e2:	85 c0                	test   %eax,%eax
801030e4:	74 02                	je     801030e8 <cmostime+0x48>
        continue;
801030e6:	eb 36                	jmp    8010311e <cmostime+0x7e>
    fill_rtcdate(&t2);
801030e8:	8d 45 c0             	lea    -0x40(%ebp),%eax
801030eb:	89 04 24             	mov    %eax,(%esp)
801030ee:	e8 3a ff ff ff       	call   8010302d <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801030f3:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801030fa:	00 
801030fb:	8d 45 c0             	lea    -0x40(%ebp),%eax
801030fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80103102:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103105:	89 04 24             	mov    %eax,(%esp)
80103108:	e8 f9 22 00 00       	call   80105406 <memcmp>
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 0d                	jne    8010311e <cmostime+0x7e>
      break;
80103111:	90                   	nop
  }

  // convert
  if (bcd) {
80103112:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103116:	0f 84 ac 00 00 00    	je     801031c8 <cmostime+0x128>
8010311c:	eb 02                	jmp    80103120 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010311e:	eb a6                	jmp    801030c6 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103120:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103123:	c1 e8 04             	shr    $0x4,%eax
80103126:	89 c2                	mov    %eax,%edx
80103128:	89 d0                	mov    %edx,%eax
8010312a:	c1 e0 02             	shl    $0x2,%eax
8010312d:	01 d0                	add    %edx,%eax
8010312f:	01 c0                	add    %eax,%eax
80103131:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103134:	83 e2 0f             	and    $0xf,%edx
80103137:	01 d0                	add    %edx,%eax
80103139:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010313c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010313f:	c1 e8 04             	shr    $0x4,%eax
80103142:	89 c2                	mov    %eax,%edx
80103144:	89 d0                	mov    %edx,%eax
80103146:	c1 e0 02             	shl    $0x2,%eax
80103149:	01 d0                	add    %edx,%eax
8010314b:	01 c0                	add    %eax,%eax
8010314d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103150:	83 e2 0f             	and    $0xf,%edx
80103153:	01 d0                	add    %edx,%eax
80103155:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103158:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010315b:	c1 e8 04             	shr    $0x4,%eax
8010315e:	89 c2                	mov    %eax,%edx
80103160:	89 d0                	mov    %edx,%eax
80103162:	c1 e0 02             	shl    $0x2,%eax
80103165:	01 d0                	add    %edx,%eax
80103167:	01 c0                	add    %eax,%eax
80103169:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010316c:	83 e2 0f             	and    $0xf,%edx
8010316f:	01 d0                	add    %edx,%eax
80103171:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103174:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103177:	c1 e8 04             	shr    $0x4,%eax
8010317a:	89 c2                	mov    %eax,%edx
8010317c:	89 d0                	mov    %edx,%eax
8010317e:	c1 e0 02             	shl    $0x2,%eax
80103181:	01 d0                	add    %edx,%eax
80103183:	01 c0                	add    %eax,%eax
80103185:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103188:	83 e2 0f             	and    $0xf,%edx
8010318b:	01 d0                	add    %edx,%eax
8010318d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103190:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103193:	c1 e8 04             	shr    $0x4,%eax
80103196:	89 c2                	mov    %eax,%edx
80103198:	89 d0                	mov    %edx,%eax
8010319a:	c1 e0 02             	shl    $0x2,%eax
8010319d:	01 d0                	add    %edx,%eax
8010319f:	01 c0                	add    %eax,%eax
801031a1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031a4:	83 e2 0f             	and    $0xf,%edx
801031a7:	01 d0                	add    %edx,%eax
801031a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801031ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031af:	c1 e8 04             	shr    $0x4,%eax
801031b2:	89 c2                	mov    %eax,%edx
801031b4:	89 d0                	mov    %edx,%eax
801031b6:	c1 e0 02             	shl    $0x2,%eax
801031b9:	01 d0                	add    %edx,%eax
801031bb:	01 c0                	add    %eax,%eax
801031bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031c0:	83 e2 0f             	and    $0xf,%edx
801031c3:	01 d0                	add    %edx,%eax
801031c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801031c8:	8b 45 08             	mov    0x8(%ebp),%eax
801031cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031ce:	89 10                	mov    %edx,(%eax)
801031d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031d3:	89 50 04             	mov    %edx,0x4(%eax)
801031d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031d9:	89 50 08             	mov    %edx,0x8(%eax)
801031dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801031df:	89 50 0c             	mov    %edx,0xc(%eax)
801031e2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031e5:	89 50 10             	mov    %edx,0x10(%eax)
801031e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031eb:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801031ee:	8b 45 08             	mov    0x8(%ebp),%eax
801031f1:	8b 40 14             	mov    0x14(%eax),%eax
801031f4:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801031fa:	8b 45 08             	mov    0x8(%ebp),%eax
801031fd:	89 50 14             	mov    %edx,0x14(%eax)
}
80103200:	c9                   	leave  
80103201:	c3                   	ret    

80103202 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103202:	55                   	push   %ebp
80103203:	89 e5                	mov    %esp,%ebp
80103205:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103208:	c7 44 24 04 dc 8b 10 	movl   $0x80108bdc,0x4(%esp)
8010320f:	80 
80103210:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103217:	e8 fe 1e 00 00       	call   8010511a <initlock>
  readsb(ROOTDEV, &sb);
8010321c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010321f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103223:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010322a:	e8 c2 e0 ff ff       	call   801012f1 <readsb>
  log.start = sb.size - sb.nlog;
8010322f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103235:	29 c2                	sub    %eax,%edx
80103237:	89 d0                	mov    %edx,%eax
80103239:	a3 94 32 11 80       	mov    %eax,0x80113294
  log.size = sb.nlog;
8010323e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103241:	a3 98 32 11 80       	mov    %eax,0x80113298
  log.dev = ROOTDEV;
80103246:	c7 05 a4 32 11 80 01 	movl   $0x1,0x801132a4
8010324d:	00 00 00 
  recover_from_log();
80103250:	e8 9a 01 00 00       	call   801033ef <recover_from_log>
}
80103255:	c9                   	leave  
80103256:	c3                   	ret    

80103257 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103257:	55                   	push   %ebp
80103258:	89 e5                	mov    %esp,%ebp
8010325a:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010325d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103264:	e9 8c 00 00 00       	jmp    801032f5 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103269:	8b 15 94 32 11 80    	mov    0x80113294,%edx
8010326f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103272:	01 d0                	add    %edx,%eax
80103274:	83 c0 01             	add    $0x1,%eax
80103277:	89 c2                	mov    %eax,%edx
80103279:	a1 a4 32 11 80       	mov    0x801132a4,%eax
8010327e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103282:	89 04 24             	mov    %eax,(%esp)
80103285:	e8 1c cf ff ff       	call   801001a6 <bread>
8010328a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010328d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103290:	83 c0 10             	add    $0x10,%eax
80103293:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
8010329a:	89 c2                	mov    %eax,%edx
8010329c:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801032a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801032a5:	89 04 24             	mov    %eax,(%esp)
801032a8:	e8 f9 ce ff ff       	call   801001a6 <bread>
801032ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801032b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032b3:	8d 50 18             	lea    0x18(%eax),%edx
801032b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032b9:	83 c0 18             	add    $0x18,%eax
801032bc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801032c3:	00 
801032c4:	89 54 24 04          	mov    %edx,0x4(%esp)
801032c8:	89 04 24             	mov    %eax,(%esp)
801032cb:	e8 8e 21 00 00       	call   8010545e <memmove>
    bwrite(dbuf);  // write dst to disk
801032d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032d3:	89 04 24             	mov    %eax,(%esp)
801032d6:	e8 02 cf ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801032db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032de:	89 04 24             	mov    %eax,(%esp)
801032e1:	e8 31 cf ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801032e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e9:	89 04 24             	mov    %eax,(%esp)
801032ec:	e8 26 cf ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f5:	a1 a8 32 11 80       	mov    0x801132a8,%eax
801032fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801032fd:	0f 8f 66 ff ff ff    	jg     80103269 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103303:	c9                   	leave  
80103304:	c3                   	ret    

80103305 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103305:	55                   	push   %ebp
80103306:	89 e5                	mov    %esp,%ebp
80103308:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010330b:	a1 94 32 11 80       	mov    0x80113294,%eax
80103310:	89 c2                	mov    %eax,%edx
80103312:	a1 a4 32 11 80       	mov    0x801132a4,%eax
80103317:	89 54 24 04          	mov    %edx,0x4(%esp)
8010331b:	89 04 24             	mov    %eax,(%esp)
8010331e:	e8 83 ce ff ff       	call   801001a6 <bread>
80103323:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103326:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103329:	83 c0 18             	add    $0x18,%eax
8010332c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010332f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103332:	8b 00                	mov    (%eax),%eax
80103334:	a3 a8 32 11 80       	mov    %eax,0x801132a8
  for (i = 0; i < log.lh.n; i++) {
80103339:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103340:	eb 1b                	jmp    8010335d <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103342:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103345:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103348:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010334c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010334f:	83 c2 10             	add    $0x10,%edx
80103352:	89 04 95 6c 32 11 80 	mov    %eax,-0x7feecd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103359:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010335d:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103362:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103365:	7f db                	jg     80103342 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103367:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010336a:	89 04 24             	mov    %eax,(%esp)
8010336d:	e8 a5 ce ff ff       	call   80100217 <brelse>
}
80103372:	c9                   	leave  
80103373:	c3                   	ret    

80103374 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103374:	55                   	push   %ebp
80103375:	89 e5                	mov    %esp,%ebp
80103377:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010337a:	a1 94 32 11 80       	mov    0x80113294,%eax
8010337f:	89 c2                	mov    %eax,%edx
80103381:	a1 a4 32 11 80       	mov    0x801132a4,%eax
80103386:	89 54 24 04          	mov    %edx,0x4(%esp)
8010338a:	89 04 24             	mov    %eax,(%esp)
8010338d:	e8 14 ce ff ff       	call   801001a6 <bread>
80103392:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103398:	83 c0 18             	add    $0x18,%eax
8010339b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010339e:	8b 15 a8 32 11 80    	mov    0x801132a8,%edx
801033a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033a7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033b0:	eb 1b                	jmp    801033cd <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801033b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b5:	83 c0 10             	add    $0x10,%eax
801033b8:	8b 0c 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%ecx
801033bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033c5:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801033c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033cd:	a1 a8 32 11 80       	mov    0x801132a8,%eax
801033d2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033d5:	7f db                	jg     801033b2 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801033d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033da:	89 04 24             	mov    %eax,(%esp)
801033dd:	e8 fb cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
801033e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e5:	89 04 24             	mov    %eax,(%esp)
801033e8:	e8 2a ce ff ff       	call   80100217 <brelse>
}
801033ed:	c9                   	leave  
801033ee:	c3                   	ret    

801033ef <recover_from_log>:

static void
recover_from_log(void)
{
801033ef:	55                   	push   %ebp
801033f0:	89 e5                	mov    %esp,%ebp
801033f2:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801033f5:	e8 0b ff ff ff       	call   80103305 <read_head>
  install_trans(); // if committed, copy from log to disk
801033fa:	e8 58 fe ff ff       	call   80103257 <install_trans>
  log.lh.n = 0;
801033ff:	c7 05 a8 32 11 80 00 	movl   $0x0,0x801132a8
80103406:	00 00 00 
  write_head(); // clear the log
80103409:	e8 66 ff ff ff       	call   80103374 <write_head>
}
8010340e:	c9                   	leave  
8010340f:	c3                   	ret    

80103410 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103410:	55                   	push   %ebp
80103411:	89 e5                	mov    %esp,%ebp
80103413:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103416:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
8010341d:	e8 19 1d 00 00       	call   8010513b <acquire>
  while(1){
    if(log.committing){
80103422:	a1 a0 32 11 80       	mov    0x801132a0,%eax
80103427:	85 c0                	test   %eax,%eax
80103429:	74 16                	je     80103441 <begin_op+0x31>
      sleep(&log, &log.lock);
8010342b:	c7 44 24 04 60 32 11 	movl   $0x80113260,0x4(%esp)
80103432:	80 
80103433:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
8010343a:	e8 6b 19 00 00       	call   80104daa <sleep>
8010343f:	eb 4f                	jmp    80103490 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103441:	8b 0d a8 32 11 80    	mov    0x801132a8,%ecx
80103447:	a1 9c 32 11 80       	mov    0x8011329c,%eax
8010344c:	8d 50 01             	lea    0x1(%eax),%edx
8010344f:	89 d0                	mov    %edx,%eax
80103451:	c1 e0 02             	shl    $0x2,%eax
80103454:	01 d0                	add    %edx,%eax
80103456:	01 c0                	add    %eax,%eax
80103458:	01 c8                	add    %ecx,%eax
8010345a:	83 f8 1e             	cmp    $0x1e,%eax
8010345d:	7e 16                	jle    80103475 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010345f:	c7 44 24 04 60 32 11 	movl   $0x80113260,0x4(%esp)
80103466:	80 
80103467:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
8010346e:	e8 37 19 00 00       	call   80104daa <sleep>
80103473:	eb 1b                	jmp    80103490 <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103475:	a1 9c 32 11 80       	mov    0x8011329c,%eax
8010347a:	83 c0 01             	add    $0x1,%eax
8010347d:	a3 9c 32 11 80       	mov    %eax,0x8011329c
      release(&log.lock);
80103482:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103489:	e8 0f 1d 00 00       	call   8010519d <release>
      break;
8010348e:	eb 02                	jmp    80103492 <begin_op+0x82>
    }
  }
80103490:	eb 90                	jmp    80103422 <begin_op+0x12>
}
80103492:	c9                   	leave  
80103493:	c3                   	ret    

80103494 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103494:	55                   	push   %ebp
80103495:	89 e5                	mov    %esp,%ebp
80103497:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010349a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801034a1:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801034a8:	e8 8e 1c 00 00       	call   8010513b <acquire>
  log.outstanding -= 1;
801034ad:	a1 9c 32 11 80       	mov    0x8011329c,%eax
801034b2:	83 e8 01             	sub    $0x1,%eax
801034b5:	a3 9c 32 11 80       	mov    %eax,0x8011329c
  if(log.committing)
801034ba:	a1 a0 32 11 80       	mov    0x801132a0,%eax
801034bf:	85 c0                	test   %eax,%eax
801034c1:	74 0c                	je     801034cf <end_op+0x3b>
    panic("log.committing");
801034c3:	c7 04 24 e0 8b 10 80 	movl   $0x80108be0,(%esp)
801034ca:	e8 6b d0 ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
801034cf:	a1 9c 32 11 80       	mov    0x8011329c,%eax
801034d4:	85 c0                	test   %eax,%eax
801034d6:	75 13                	jne    801034eb <end_op+0x57>
    do_commit = 1;
801034d8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801034df:	c7 05 a0 32 11 80 01 	movl   $0x1,0x801132a0
801034e6:	00 00 00 
801034e9:	eb 0c                	jmp    801034f7 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801034eb:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801034f2:	e8 fa 19 00 00       	call   80104ef1 <wakeup>
  }
  release(&log.lock);
801034f7:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801034fe:	e8 9a 1c 00 00       	call   8010519d <release>

  if(do_commit){
80103503:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103507:	74 33                	je     8010353c <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103509:	e8 de 00 00 00       	call   801035ec <commit>
    acquire(&log.lock);
8010350e:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103515:	e8 21 1c 00 00       	call   8010513b <acquire>
    log.committing = 0;
8010351a:	c7 05 a0 32 11 80 00 	movl   $0x0,0x801132a0
80103521:	00 00 00 
    wakeup(&log);
80103524:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
8010352b:	e8 c1 19 00 00       	call   80104ef1 <wakeup>
    release(&log.lock);
80103530:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103537:	e8 61 1c 00 00       	call   8010519d <release>
  }
}
8010353c:	c9                   	leave  
8010353d:	c3                   	ret    

8010353e <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010353e:	55                   	push   %ebp
8010353f:	89 e5                	mov    %esp,%ebp
80103541:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103544:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010354b:	e9 8c 00 00 00       	jmp    801035dc <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103550:	8b 15 94 32 11 80    	mov    0x80113294,%edx
80103556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103559:	01 d0                	add    %edx,%eax
8010355b:	83 c0 01             	add    $0x1,%eax
8010355e:	89 c2                	mov    %eax,%edx
80103560:	a1 a4 32 11 80       	mov    0x801132a4,%eax
80103565:	89 54 24 04          	mov    %edx,0x4(%esp)
80103569:	89 04 24             	mov    %eax,(%esp)
8010356c:	e8 35 cc ff ff       	call   801001a6 <bread>
80103571:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103577:	83 c0 10             	add    $0x10,%eax
8010357a:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
80103581:	89 c2                	mov    %eax,%edx
80103583:	a1 a4 32 11 80       	mov    0x801132a4,%eax
80103588:	89 54 24 04          	mov    %edx,0x4(%esp)
8010358c:	89 04 24             	mov    %eax,(%esp)
8010358f:	e8 12 cc ff ff       	call   801001a6 <bread>
80103594:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103597:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010359a:	8d 50 18             	lea    0x18(%eax),%edx
8010359d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035a0:	83 c0 18             	add    $0x18,%eax
801035a3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801035aa:	00 
801035ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801035af:	89 04 24             	mov    %eax,(%esp)
801035b2:	e8 a7 1e 00 00       	call   8010545e <memmove>
    bwrite(to);  // write the log
801035b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ba:	89 04 24             	mov    %eax,(%esp)
801035bd:	e8 1b cc ff ff       	call   801001dd <bwrite>
    brelse(from); 
801035c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035c5:	89 04 24             	mov    %eax,(%esp)
801035c8:	e8 4a cc ff ff       	call   80100217 <brelse>
    brelse(to);
801035cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035d0:	89 04 24             	mov    %eax,(%esp)
801035d3:	e8 3f cc ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035dc:	a1 a8 32 11 80       	mov    0x801132a8,%eax
801035e1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035e4:	0f 8f 66 ff ff ff    	jg     80103550 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801035ea:	c9                   	leave  
801035eb:	c3                   	ret    

801035ec <commit>:

static void
commit()
{
801035ec:	55                   	push   %ebp
801035ed:	89 e5                	mov    %esp,%ebp
801035ef:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801035f2:	a1 a8 32 11 80       	mov    0x801132a8,%eax
801035f7:	85 c0                	test   %eax,%eax
801035f9:	7e 1e                	jle    80103619 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801035fb:	e8 3e ff ff ff       	call   8010353e <write_log>
    write_head();    // Write header to disk -- the real commit
80103600:	e8 6f fd ff ff       	call   80103374 <write_head>
    install_trans(); // Now install writes to home locations
80103605:	e8 4d fc ff ff       	call   80103257 <install_trans>
    log.lh.n = 0; 
8010360a:	c7 05 a8 32 11 80 00 	movl   $0x0,0x801132a8
80103611:	00 00 00 
    write_head();    // Erase the transaction from the log
80103614:	e8 5b fd ff ff       	call   80103374 <write_head>
  }
}
80103619:	c9                   	leave  
8010361a:	c3                   	ret    

8010361b <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010361b:	55                   	push   %ebp
8010361c:	89 e5                	mov    %esp,%ebp
8010361e:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103621:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103626:	83 f8 1d             	cmp    $0x1d,%eax
80103629:	7f 12                	jg     8010363d <log_write+0x22>
8010362b:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103630:	8b 15 98 32 11 80    	mov    0x80113298,%edx
80103636:	83 ea 01             	sub    $0x1,%edx
80103639:	39 d0                	cmp    %edx,%eax
8010363b:	7c 0c                	jl     80103649 <log_write+0x2e>
    panic("too big a transaction");
8010363d:	c7 04 24 ef 8b 10 80 	movl   $0x80108bef,(%esp)
80103644:	e8 f1 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103649:	a1 9c 32 11 80       	mov    0x8011329c,%eax
8010364e:	85 c0                	test   %eax,%eax
80103650:	7f 0c                	jg     8010365e <log_write+0x43>
    panic("log_write outside of trans");
80103652:	c7 04 24 05 8c 10 80 	movl   $0x80108c05,(%esp)
80103659:	e8 dc ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010365e:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103665:	e8 d1 1a 00 00       	call   8010513b <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010366a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103671:	eb 1f                	jmp    80103692 <log_write+0x77>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103676:	83 c0 10             	add    $0x10,%eax
80103679:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
80103680:	89 c2                	mov    %eax,%edx
80103682:	8b 45 08             	mov    0x8(%ebp),%eax
80103685:	8b 40 08             	mov    0x8(%eax),%eax
80103688:	39 c2                	cmp    %eax,%edx
8010368a:	75 02                	jne    8010368e <log_write+0x73>
      break;
8010368c:	eb 0e                	jmp    8010369c <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010368e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103692:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103697:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010369a:	7f d7                	jg     80103673 <log_write+0x58>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
  }
  log.lh.sector[i] = b->sector;
8010369c:	8b 45 08             	mov    0x8(%ebp),%eax
8010369f:	8b 40 08             	mov    0x8(%eax),%eax
801036a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036a5:	83 c2 10             	add    $0x10,%edx
801036a8:	89 04 95 6c 32 11 80 	mov    %eax,-0x7feecd94(,%edx,4)
  if (i == log.lh.n)
801036af:	a1 a8 32 11 80       	mov    0x801132a8,%eax
801036b4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036b7:	75 0d                	jne    801036c6 <log_write+0xab>
    log.lh.n++;
801036b9:	a1 a8 32 11 80       	mov    0x801132a8,%eax
801036be:	83 c0 01             	add    $0x1,%eax
801036c1:	a3 a8 32 11 80       	mov    %eax,0x801132a8
  b->flags |= B_DIRTY; // prevent eviction
801036c6:	8b 45 08             	mov    0x8(%ebp),%eax
801036c9:	8b 00                	mov    (%eax),%eax
801036cb:	83 c8 04             	or     $0x4,%eax
801036ce:	89 c2                	mov    %eax,%edx
801036d0:	8b 45 08             	mov    0x8(%ebp),%eax
801036d3:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801036d5:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801036dc:	e8 bc 1a 00 00       	call   8010519d <release>
}
801036e1:	c9                   	leave  
801036e2:	c3                   	ret    

801036e3 <v2p>:
801036e3:	55                   	push   %ebp
801036e4:	89 e5                	mov    %esp,%ebp
801036e6:	8b 45 08             	mov    0x8(%ebp),%eax
801036e9:	05 00 00 00 80       	add    $0x80000000,%eax
801036ee:	5d                   	pop    %ebp
801036ef:	c3                   	ret    

801036f0 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	8b 45 08             	mov    0x8(%ebp),%eax
801036f6:	05 00 00 00 80       	add    $0x80000000,%eax
801036fb:	5d                   	pop    %ebp
801036fc:	c3                   	ret    

801036fd <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801036fd:	55                   	push   %ebp
801036fe:	89 e5                	mov    %esp,%ebp
80103700:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103703:	8b 55 08             	mov    0x8(%ebp),%edx
80103706:	8b 45 0c             	mov    0xc(%ebp),%eax
80103709:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010370c:	f0 87 02             	lock xchg %eax,(%edx)
8010370f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103712:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103715:	c9                   	leave  
80103716:	c3                   	ret    

80103717 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103717:	55                   	push   %ebp
80103718:	89 e5                	mov    %esp,%ebp
8010371a:	83 e4 f0             	and    $0xfffffff0,%esp
8010371d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103720:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103727:	80 
80103728:	c7 04 24 5c ee 11 80 	movl   $0x8011ee5c,(%esp)
8010372f:	e8 80 f2 ff ff       	call   801029b4 <kinit1>
  kvmalloc();      // kernel page table
80103734:	e8 1b 48 00 00       	call   80107f54 <kvmalloc>
  mpinit();        // collect info about this machine
80103739:	e8 50 04 00 00       	call   80103b8e <mpinit>
  lapicinit();
8010373e:	e8 dc f5 ff ff       	call   80102d1f <lapicinit>
  seginit();       // set up segments
80103743:	e8 9a 41 00 00       	call   801078e2 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103748:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010374e:	0f b6 00             	movzbl (%eax),%eax
80103751:	0f b6 c0             	movzbl %al,%eax
80103754:	89 44 24 04          	mov    %eax,0x4(%esp)
80103758:	c7 04 24 20 8c 10 80 	movl   $0x80108c20,(%esp)
8010375f:	e8 3c cc ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103764:	e8 8b 06 00 00       	call   80103df4 <picinit>
  ioapicinit();    // another interrupt controller
80103769:	e8 3c f1 ff ff       	call   801028aa <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010376e:	e8 0e d3 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103773:	e8 b9 34 00 00       	call   80106c31 <uartinit>
  pinit();         // process table
80103778:	e8 b2 0b 00 00       	call   8010432f <pinit>
  tvinit();        // trap vectors
8010377d:	e8 61 30 00 00       	call   801067e3 <tvinit>
  binit();         // buffer cache
80103782:	e8 ad c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103787:	e8 7e d7 ff ff       	call   80100f0a <fileinit>
  iinit();         // inode cache
8010378c:	e8 13 de ff ff       	call   801015a4 <iinit>
  ideinit();       // disk
80103791:	e8 7d ed ff ff       	call   80102513 <ideinit>
  if(!ismp)
80103796:	a1 44 33 11 80       	mov    0x80113344,%eax
8010379b:	85 c0                	test   %eax,%eax
8010379d:	75 05                	jne    801037a4 <main+0x8d>
    timerinit();   // uniprocessor timer
8010379f:	e8 8a 2f 00 00       	call   8010672e <timerinit>
  startothers();   // start other processors
801037a4:	e8 7f 00 00 00       	call   80103828 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037a9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037b0:	8e 
801037b1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037b8:	e8 2f f2 ff ff       	call   801029ec <kinit2>
  userinit();      // first user process
801037bd:	e8 30 0d 00 00       	call   801044f2 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801037c2:	e8 1a 00 00 00       	call   801037e1 <mpmain>

801037c7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037c7:	55                   	push   %ebp
801037c8:	89 e5                	mov    %esp,%ebp
801037ca:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801037cd:	e8 99 47 00 00       	call   80107f6b <switchkvm>
  seginit();
801037d2:	e8 0b 41 00 00       	call   801078e2 <seginit>
  lapicinit();
801037d7:	e8 43 f5 ff ff       	call   80102d1f <lapicinit>
  mpmain();
801037dc:	e8 00 00 00 00       	call   801037e1 <mpmain>

801037e1 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801037e1:	55                   	push   %ebp
801037e2:	89 e5                	mov    %esp,%ebp
801037e4:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801037e7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037ed:	0f b6 00             	movzbl (%eax),%eax
801037f0:	0f b6 c0             	movzbl %al,%eax
801037f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801037f7:	c7 04 24 37 8c 10 80 	movl   $0x80108c37,(%esp)
801037fe:	e8 9d cb ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103803:	e8 4f 31 00 00       	call   80106957 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103808:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010380e:	05 a8 00 00 00       	add    $0xa8,%eax
80103813:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010381a:	00 
8010381b:	89 04 24             	mov    %eax,(%esp)
8010381e:	e8 da fe ff ff       	call   801036fd <xchg>
  scheduler();     // start running processes
80103823:	e8 6d 13 00 00       	call   80104b95 <scheduler>

80103828 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103828:	55                   	push   %ebp
80103829:	89 e5                	mov    %esp,%ebp
8010382b:	53                   	push   %ebx
8010382c:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010382f:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103836:	e8 b5 fe ff ff       	call   801036f0 <p2v>
8010383b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010383e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103843:	89 44 24 08          	mov    %eax,0x8(%esp)
80103847:	c7 44 24 04 0c c5 10 	movl   $0x8010c50c,0x4(%esp)
8010384e:	80 
8010384f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103852:	89 04 24             	mov    %eax,(%esp)
80103855:	e8 04 1c 00 00       	call   8010545e <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010385a:	c7 45 f4 60 33 11 80 	movl   $0x80113360,-0xc(%ebp)
80103861:	e9 8a 00 00 00       	jmp    801038f0 <startothers+0xc8>
    if(c == cpus+cpunum())  // We've started already.
80103866:	e8 0d f6 ff ff       	call   80102e78 <cpunum>
8010386b:	89 c2                	mov    %eax,%edx
8010386d:	89 d0                	mov    %edx,%eax
8010386f:	01 c0                	add    %eax,%eax
80103871:	01 d0                	add    %edx,%eax
80103873:	c1 e0 06             	shl    $0x6,%eax
80103876:	05 60 33 11 80       	add    $0x80113360,%eax
8010387b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010387e:	75 02                	jne    80103882 <startothers+0x5a>
      continue;
80103880:	eb 67                	jmp    801038e9 <startothers+0xc1>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103882:	e8 5b f2 ff ff       	call   80102ae2 <kalloc>
80103887:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010388a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010388d:	83 e8 04             	sub    $0x4,%eax
80103890:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103893:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103899:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010389b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010389e:	83 e8 08             	sub    $0x8,%eax
801038a1:	c7 00 c7 37 10 80    	movl   $0x801037c7,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038aa:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038ad:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
801038b4:	e8 2a fe ff ff       	call   801036e3 <v2p>
801038b9:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801038bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038be:	89 04 24             	mov    %eax,(%esp)
801038c1:	e8 1d fe ff ff       	call   801036e3 <v2p>
801038c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038c9:	0f b6 12             	movzbl (%edx),%edx
801038cc:	0f b6 d2             	movzbl %dl,%edx
801038cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801038d3:	89 14 24             	mov    %edx,(%esp)
801038d6:	e8 1f f6 ff ff       	call   80102efa <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038db:	90                   	nop
801038dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038df:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801038e5:	85 c0                	test   %eax,%eax
801038e7:	74 f3                	je     801038dc <startothers+0xb4>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801038e9:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
801038f0:	a1 60 39 11 80       	mov    0x80113960,%eax
801038f5:	89 c2                	mov    %eax,%edx
801038f7:	89 d0                	mov    %edx,%eax
801038f9:	01 c0                	add    %eax,%eax
801038fb:	01 d0                	add    %edx,%eax
801038fd:	c1 e0 06             	shl    $0x6,%eax
80103900:	05 60 33 11 80       	add    $0x80113360,%eax
80103905:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103908:	0f 87 58 ff ff ff    	ja     80103866 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010390e:	83 c4 24             	add    $0x24,%esp
80103911:	5b                   	pop    %ebx
80103912:	5d                   	pop    %ebp
80103913:	c3                   	ret    

80103914 <p2v>:
80103914:	55                   	push   %ebp
80103915:	89 e5                	mov    %esp,%ebp
80103917:	8b 45 08             	mov    0x8(%ebp),%eax
8010391a:	05 00 00 00 80       	add    $0x80000000,%eax
8010391f:	5d                   	pop    %ebp
80103920:	c3                   	ret    

80103921 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103921:	55                   	push   %ebp
80103922:	89 e5                	mov    %esp,%ebp
80103924:	83 ec 14             	sub    $0x14,%esp
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010392e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103932:	89 c2                	mov    %eax,%edx
80103934:	ec                   	in     (%dx),%al
80103935:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103938:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010393c:	c9                   	leave  
8010393d:	c3                   	ret    

8010393e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010393e:	55                   	push   %ebp
8010393f:	89 e5                	mov    %esp,%ebp
80103941:	83 ec 08             	sub    $0x8,%esp
80103944:	8b 55 08             	mov    0x8(%ebp),%edx
80103947:	8b 45 0c             	mov    0xc(%ebp),%eax
8010394a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010394e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103951:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103955:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103959:	ee                   	out    %al,(%dx)
}
8010395a:	c9                   	leave  
8010395b:	c3                   	ret    

8010395c <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
8010395c:	55                   	push   %ebp
8010395d:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
8010395f:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80103964:	89 c2                	mov    %eax,%edx
80103966:	b8 60 33 11 80       	mov    $0x80113360,%eax
8010396b:	29 c2                	sub    %eax,%edx
8010396d:	89 d0                	mov    %edx,%eax
8010396f:	c1 f8 06             	sar    $0x6,%eax
80103972:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}
80103978:	5d                   	pop    %ebp
80103979:	c3                   	ret    

8010397a <sum>:

static uchar
sum(uchar *addr, int len)
{
8010397a:	55                   	push   %ebp
8010397b:	89 e5                	mov    %esp,%ebp
8010397d:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103980:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103987:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010398e:	eb 15                	jmp    801039a5 <sum+0x2b>
    sum += addr[i];
80103990:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103993:	8b 45 08             	mov    0x8(%ebp),%eax
80103996:	01 d0                	add    %edx,%eax
80103998:	0f b6 00             	movzbl (%eax),%eax
8010399b:	0f b6 c0             	movzbl %al,%eax
8010399e:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039a8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039ab:	7c e3                	jl     80103990 <sum+0x16>
    sum += addr[i];
  return sum;
801039ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039b0:	c9                   	leave  
801039b1:	c3                   	ret    

801039b2 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039b2:	55                   	push   %ebp
801039b3:	89 e5                	mov    %esp,%ebp
801039b5:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801039b8:	8b 45 08             	mov    0x8(%ebp),%eax
801039bb:	89 04 24             	mov    %eax,(%esp)
801039be:	e8 51 ff ff ff       	call   80103914 <p2v>
801039c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039c6:	8b 55 0c             	mov    0xc(%ebp),%edx
801039c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039cc:	01 d0                	add    %edx,%eax
801039ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039d7:	eb 3f                	jmp    80103a18 <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039d9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039e0:	00 
801039e1:	c7 44 24 04 48 8c 10 	movl   $0x80108c48,0x4(%esp)
801039e8:	80 
801039e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ec:	89 04 24             	mov    %eax,(%esp)
801039ef:	e8 12 1a 00 00       	call   80105406 <memcmp>
801039f4:	85 c0                	test   %eax,%eax
801039f6:	75 1c                	jne    80103a14 <mpsearch1+0x62>
801039f8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801039ff:	00 
80103a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a03:	89 04 24             	mov    %eax,(%esp)
80103a06:	e8 6f ff ff ff       	call   8010397a <sum>
80103a0b:	84 c0                	test   %al,%al
80103a0d:	75 05                	jne    80103a14 <mpsearch1+0x62>
      return (struct mp*)p;
80103a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a12:	eb 11                	jmp    80103a25 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a14:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a1b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a1e:	72 b9                	jb     801039d9 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a20:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a25:	c9                   	leave  
80103a26:	c3                   	ret    

80103a27 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a27:	55                   	push   %ebp
80103a28:	89 e5                	mov    %esp,%ebp
80103a2a:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a2d:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a37:	83 c0 0f             	add    $0xf,%eax
80103a3a:	0f b6 00             	movzbl (%eax),%eax
80103a3d:	0f b6 c0             	movzbl %al,%eax
80103a40:	c1 e0 08             	shl    $0x8,%eax
80103a43:	89 c2                	mov    %eax,%edx
80103a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a48:	83 c0 0e             	add    $0xe,%eax
80103a4b:	0f b6 00             	movzbl (%eax),%eax
80103a4e:	0f b6 c0             	movzbl %al,%eax
80103a51:	09 d0                	or     %edx,%eax
80103a53:	c1 e0 04             	shl    $0x4,%eax
80103a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a5d:	74 21                	je     80103a80 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a5f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a66:	00 
80103a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a6a:	89 04 24             	mov    %eax,(%esp)
80103a6d:	e8 40 ff ff ff       	call   801039b2 <mpsearch1>
80103a72:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a75:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a79:	74 50                	je     80103acb <mpsearch+0xa4>
      return mp;
80103a7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a7e:	eb 5f                	jmp    80103adf <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a83:	83 c0 14             	add    $0x14,%eax
80103a86:	0f b6 00             	movzbl (%eax),%eax
80103a89:	0f b6 c0             	movzbl %al,%eax
80103a8c:	c1 e0 08             	shl    $0x8,%eax
80103a8f:	89 c2                	mov    %eax,%edx
80103a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a94:	83 c0 13             	add    $0x13,%eax
80103a97:	0f b6 00             	movzbl (%eax),%eax
80103a9a:	0f b6 c0             	movzbl %al,%eax
80103a9d:	09 d0                	or     %edx,%eax
80103a9f:	c1 e0 0a             	shl    $0xa,%eax
80103aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aa8:	2d 00 04 00 00       	sub    $0x400,%eax
80103aad:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ab4:	00 
80103ab5:	89 04 24             	mov    %eax,(%esp)
80103ab8:	e8 f5 fe ff ff       	call   801039b2 <mpsearch1>
80103abd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ac0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ac4:	74 05                	je     80103acb <mpsearch+0xa4>
      return mp;
80103ac6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ac9:	eb 14                	jmp    80103adf <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103acb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ad2:	00 
80103ad3:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103ada:	e8 d3 fe ff ff       	call   801039b2 <mpsearch1>
}
80103adf:	c9                   	leave  
80103ae0:	c3                   	ret    

80103ae1 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ae1:	55                   	push   %ebp
80103ae2:	89 e5                	mov    %esp,%ebp
80103ae4:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103ae7:	e8 3b ff ff ff       	call   80103a27 <mpsearch>
80103aec:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103af3:	74 0a                	je     80103aff <mpconfig+0x1e>
80103af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af8:	8b 40 04             	mov    0x4(%eax),%eax
80103afb:	85 c0                	test   %eax,%eax
80103afd:	75 0a                	jne    80103b09 <mpconfig+0x28>
    return 0;
80103aff:	b8 00 00 00 00       	mov    $0x0,%eax
80103b04:	e9 83 00 00 00       	jmp    80103b8c <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0c:	8b 40 04             	mov    0x4(%eax),%eax
80103b0f:	89 04 24             	mov    %eax,(%esp)
80103b12:	e8 fd fd ff ff       	call   80103914 <p2v>
80103b17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b1a:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b21:	00 
80103b22:	c7 44 24 04 4d 8c 10 	movl   $0x80108c4d,0x4(%esp)
80103b29:	80 
80103b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b2d:	89 04 24             	mov    %eax,(%esp)
80103b30:	e8 d1 18 00 00       	call   80105406 <memcmp>
80103b35:	85 c0                	test   %eax,%eax
80103b37:	74 07                	je     80103b40 <mpconfig+0x5f>
    return 0;
80103b39:	b8 00 00 00 00       	mov    $0x0,%eax
80103b3e:	eb 4c                	jmp    80103b8c <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b43:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b47:	3c 01                	cmp    $0x1,%al
80103b49:	74 12                	je     80103b5d <mpconfig+0x7c>
80103b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b4e:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b52:	3c 04                	cmp    $0x4,%al
80103b54:	74 07                	je     80103b5d <mpconfig+0x7c>
    return 0;
80103b56:	b8 00 00 00 00       	mov    $0x0,%eax
80103b5b:	eb 2f                	jmp    80103b8c <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b60:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b64:	0f b7 c0             	movzwl %ax,%eax
80103b67:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6e:	89 04 24             	mov    %eax,(%esp)
80103b71:	e8 04 fe ff ff       	call   8010397a <sum>
80103b76:	84 c0                	test   %al,%al
80103b78:	74 07                	je     80103b81 <mpconfig+0xa0>
    return 0;
80103b7a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b7f:	eb 0b                	jmp    80103b8c <mpconfig+0xab>
  *pmp = mp;
80103b81:	8b 45 08             	mov    0x8(%ebp),%eax
80103b84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b87:	89 10                	mov    %edx,(%eax)
  return conf;
80103b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b8c:	c9                   	leave  
80103b8d:	c3                   	ret    

80103b8e <mpinit>:

void
mpinit(void)
{
80103b8e:	55                   	push   %ebp
80103b8f:	89 e5                	mov    %esp,%ebp
80103b91:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103b94:	c7 05 44 c6 10 80 60 	movl   $0x80113360,0x8010c644
80103b9b:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103b9e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103ba1:	89 04 24             	mov    %eax,(%esp)
80103ba4:	e8 38 ff ff ff       	call   80103ae1 <mpconfig>
80103ba9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bb0:	75 05                	jne    80103bb7 <mpinit+0x29>
    return;
80103bb2:	e9 a4 01 00 00       	jmp    80103d5b <mpinit+0x1cd>
  ismp = 1;
80103bb7:	c7 05 44 33 11 80 01 	movl   $0x1,0x80113344
80103bbe:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc4:	8b 40 24             	mov    0x24(%eax),%eax
80103bc7:	a3 5c 32 11 80       	mov    %eax,0x8011325c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcf:	83 c0 2c             	add    $0x2c,%eax
80103bd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bdc:	0f b7 d0             	movzwl %ax,%edx
80103bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be2:	01 d0                	add    %edx,%eax
80103be4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103be7:	e9 fc 00 00 00       	jmp    80103ce8 <mpinit+0x15a>
    switch(*p){
80103bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bef:	0f b6 00             	movzbl (%eax),%eax
80103bf2:	0f b6 c0             	movzbl %al,%eax
80103bf5:	83 f8 04             	cmp    $0x4,%eax
80103bf8:	0f 87 c7 00 00 00    	ja     80103cc5 <mpinit+0x137>
80103bfe:	8b 04 85 90 8c 10 80 	mov    -0x7fef7370(,%eax,4),%eax
80103c05:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c10:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c14:	0f b6 d0             	movzbl %al,%edx
80103c17:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c1c:	39 c2                	cmp    %eax,%edx
80103c1e:	74 2d                	je     80103c4d <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c20:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c23:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c27:	0f b6 d0             	movzbl %al,%edx
80103c2a:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c2f:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c33:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c37:	c7 04 24 52 8c 10 80 	movl   $0x80108c52,(%esp)
80103c3e:	e8 5d c7 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103c43:	c7 05 44 33 11 80 00 	movl   $0x0,0x80113344
80103c4a:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c50:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c54:	0f b6 c0             	movzbl %al,%eax
80103c57:	83 e0 02             	and    $0x2,%eax
80103c5a:	85 c0                	test   %eax,%eax
80103c5c:	74 19                	je     80103c77 <mpinit+0xe9>
        bcpu = &cpus[ncpu];
80103c5e:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103c64:	89 d0                	mov    %edx,%eax
80103c66:	01 c0                	add    %eax,%eax
80103c68:	01 d0                	add    %edx,%eax
80103c6a:	c1 e0 06             	shl    $0x6,%eax
80103c6d:	05 60 33 11 80       	add    $0x80113360,%eax
80103c72:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80103c77:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103c7d:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c82:	89 c1                	mov    %eax,%ecx
80103c84:	89 d0                	mov    %edx,%eax
80103c86:	01 c0                	add    %eax,%eax
80103c88:	01 d0                	add    %edx,%eax
80103c8a:	c1 e0 06             	shl    $0x6,%eax
80103c8d:	05 60 33 11 80       	add    $0x80113360,%eax
80103c92:	88 08                	mov    %cl,(%eax)
      ncpu++;
80103c94:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c99:	83 c0 01             	add    $0x1,%eax
80103c9c:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103ca1:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103ca5:	eb 41                	jmp    80103ce8 <mpinit+0x15a>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103caa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103cad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cb0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cb4:	a2 40 33 11 80       	mov    %al,0x80113340
      p += sizeof(struct mpioapic);
80103cb9:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cbd:	eb 29                	jmp    80103ce8 <mpinit+0x15a>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cbf:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cc3:	eb 23                	jmp    80103ce8 <mpinit+0x15a>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc8:	0f b6 00             	movzbl (%eax),%eax
80103ccb:	0f b6 c0             	movzbl %al,%eax
80103cce:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cd2:	c7 04 24 70 8c 10 80 	movl   $0x80108c70,(%esp)
80103cd9:	e8 c2 c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103cde:	c7 05 44 33 11 80 00 	movl   $0x0,0x80113344
80103ce5:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ceb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cee:	0f 82 f8 fe ff ff    	jb     80103bec <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103cf4:	a1 44 33 11 80       	mov    0x80113344,%eax
80103cf9:	85 c0                	test   %eax,%eax
80103cfb:	75 1d                	jne    80103d1a <mpinit+0x18c>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103cfd:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103d04:	00 00 00 
    lapic = 0;
80103d07:	c7 05 5c 32 11 80 00 	movl   $0x0,0x8011325c
80103d0e:	00 00 00 
    ioapicid = 0;
80103d11:	c6 05 40 33 11 80 00 	movb   $0x0,0x80113340
    return;
80103d18:	eb 41                	jmp    80103d5b <mpinit+0x1cd>
  }

  if(mp->imcrp){
80103d1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d1d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d21:	84 c0                	test   %al,%al
80103d23:	74 36                	je     80103d5b <mpinit+0x1cd>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d25:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d2c:	00 
80103d2d:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d34:	e8 05 fc ff ff       	call   8010393e <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d39:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d40:	e8 dc fb ff ff       	call   80103921 <inb>
80103d45:	83 c8 01             	or     $0x1,%eax
80103d48:	0f b6 c0             	movzbl %al,%eax
80103d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d4f:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d56:	e8 e3 fb ff ff       	call   8010393e <outb>
  }
}
80103d5b:	c9                   	leave  
80103d5c:	c3                   	ret    

80103d5d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d5d:	55                   	push   %ebp
80103d5e:	89 e5                	mov    %esp,%ebp
80103d60:	83 ec 08             	sub    $0x8,%esp
80103d63:	8b 55 08             	mov    0x8(%ebp),%edx
80103d66:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d69:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d6d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d70:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d74:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d78:	ee                   	out    %al,(%dx)
}
80103d79:	c9                   	leave  
80103d7a:	c3                   	ret    

80103d7b <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d7b:	55                   	push   %ebp
80103d7c:	89 e5                	mov    %esp,%ebp
80103d7e:	83 ec 0c             	sub    $0xc,%esp
80103d81:	8b 45 08             	mov    0x8(%ebp),%eax
80103d84:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d88:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d8c:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103d92:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d96:	0f b6 c0             	movzbl %al,%eax
80103d99:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d9d:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103da4:	e8 b4 ff ff ff       	call   80103d5d <outb>
  outb(IO_PIC2+1, mask >> 8);
80103da9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dad:	66 c1 e8 08          	shr    $0x8,%ax
80103db1:	0f b6 c0             	movzbl %al,%eax
80103db4:	89 44 24 04          	mov    %eax,0x4(%esp)
80103db8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dbf:	e8 99 ff ff ff       	call   80103d5d <outb>
}
80103dc4:	c9                   	leave  
80103dc5:	c3                   	ret    

80103dc6 <picenable>:

void
picenable(int irq)
{
80103dc6:	55                   	push   %ebp
80103dc7:	89 e5                	mov    %esp,%ebp
80103dc9:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80103dcf:	ba 01 00 00 00       	mov    $0x1,%edx
80103dd4:	89 c1                	mov    %eax,%ecx
80103dd6:	d3 e2                	shl    %cl,%edx
80103dd8:	89 d0                	mov    %edx,%eax
80103dda:	f7 d0                	not    %eax
80103ddc:	89 c2                	mov    %eax,%edx
80103dde:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103de5:	21 d0                	and    %edx,%eax
80103de7:	0f b7 c0             	movzwl %ax,%eax
80103dea:	89 04 24             	mov    %eax,(%esp)
80103ded:	e8 89 ff ff ff       	call   80103d7b <picsetmask>
}
80103df2:	c9                   	leave  
80103df3:	c3                   	ret    

80103df4 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103df4:	55                   	push   %ebp
80103df5:	89 e5                	mov    %esp,%ebp
80103df7:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103dfa:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e01:	00 
80103e02:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e09:	e8 4f ff ff ff       	call   80103d5d <outb>
  outb(IO_PIC2+1, 0xFF);
80103e0e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e15:	00 
80103e16:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e1d:	e8 3b ff ff ff       	call   80103d5d <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e22:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e29:	00 
80103e2a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e31:	e8 27 ff ff ff       	call   80103d5d <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e36:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e3d:	00 
80103e3e:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e45:	e8 13 ff ff ff       	call   80103d5d <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e4a:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e51:	00 
80103e52:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e59:	e8 ff fe ff ff       	call   80103d5d <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e5e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e65:	00 
80103e66:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e6d:	e8 eb fe ff ff       	call   80103d5d <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e72:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e79:	00 
80103e7a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103e81:	e8 d7 fe ff ff       	call   80103d5d <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103e86:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103e8d:	00 
80103e8e:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e95:	e8 c3 fe ff ff       	call   80103d5d <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103e9a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103ea1:	00 
80103ea2:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ea9:	e8 af fe ff ff       	call   80103d5d <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103eae:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103eb5:	00 
80103eb6:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ebd:	e8 9b fe ff ff       	call   80103d5d <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103ec2:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ec9:	00 
80103eca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ed1:	e8 87 fe ff ff       	call   80103d5d <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ed6:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103edd:	00 
80103ede:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ee5:	e8 73 fe ff ff       	call   80103d5d <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103eea:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ef1:	00 
80103ef2:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ef9:	e8 5f fe ff ff       	call   80103d5d <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103efe:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f05:	00 
80103f06:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f0d:	e8 4b fe ff ff       	call   80103d5d <outb>

  if(irqmask != 0xFFFF)
80103f12:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f19:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f1d:	74 12                	je     80103f31 <picinit+0x13d>
    picsetmask(irqmask);
80103f1f:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f26:	0f b7 c0             	movzwl %ax,%eax
80103f29:	89 04 24             	mov    %eax,(%esp)
80103f2c:	e8 4a fe ff ff       	call   80103d7b <picsetmask>
}
80103f31:	c9                   	leave  
80103f32:	c3                   	ret    

80103f33 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f33:	55                   	push   %ebp
80103f34:	89 e5                	mov    %esp,%ebp
80103f36:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f40:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f49:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f4c:	8b 10                	mov    (%eax),%edx
80103f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f51:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f53:	e8 ce cf ff ff       	call   80100f26 <filealloc>
80103f58:	8b 55 08             	mov    0x8(%ebp),%edx
80103f5b:	89 02                	mov    %eax,(%edx)
80103f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f60:	8b 00                	mov    (%eax),%eax
80103f62:	85 c0                	test   %eax,%eax
80103f64:	0f 84 c8 00 00 00    	je     80104032 <pipealloc+0xff>
80103f6a:	e8 b7 cf ff ff       	call   80100f26 <filealloc>
80103f6f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f72:	89 02                	mov    %eax,(%edx)
80103f74:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f77:	8b 00                	mov    (%eax),%eax
80103f79:	85 c0                	test   %eax,%eax
80103f7b:	0f 84 b1 00 00 00    	je     80104032 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f81:	e8 5c eb ff ff       	call   80102ae2 <kalloc>
80103f86:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f89:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f8d:	75 05                	jne    80103f94 <pipealloc+0x61>
    goto bad;
80103f8f:	e9 9e 00 00 00       	jmp    80104032 <pipealloc+0xff>
  p->readopen = 1;
80103f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f97:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f9e:	00 00 00 
  p->writeopen = 1;
80103fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fa4:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103fab:	00 00 00 
  p->nwrite = 0;
80103fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb1:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fb8:	00 00 00 
  p->nread = 0;
80103fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fbe:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fc5:	00 00 00 
  initlock(&p->lock, "pipe");
80103fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fcb:	c7 44 24 04 a4 8c 10 	movl   $0x80108ca4,0x4(%esp)
80103fd2:	80 
80103fd3:	89 04 24             	mov    %eax,(%esp)
80103fd6:	e8 3f 11 00 00       	call   8010511a <initlock>
  (*f0)->type = FD_PIPE;
80103fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fde:	8b 00                	mov    (%eax),%eax
80103fe0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe9:	8b 00                	mov    (%eax),%eax
80103feb:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103fef:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff2:	8b 00                	mov    (%eax),%eax
80103ff4:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffb:	8b 00                	mov    (%eax),%eax
80103ffd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104000:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104003:	8b 45 0c             	mov    0xc(%ebp),%eax
80104006:	8b 00                	mov    (%eax),%eax
80104008:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010400e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104011:	8b 00                	mov    (%eax),%eax
80104013:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104017:	8b 45 0c             	mov    0xc(%ebp),%eax
8010401a:	8b 00                	mov    (%eax),%eax
8010401c:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104020:	8b 45 0c             	mov    0xc(%ebp),%eax
80104023:	8b 00                	mov    (%eax),%eax
80104025:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104028:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010402b:	b8 00 00 00 00       	mov    $0x0,%eax
80104030:	eb 42                	jmp    80104074 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80104032:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104036:	74 0b                	je     80104043 <pipealloc+0x110>
    kfree((char*)p);
80104038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403b:	89 04 24             	mov    %eax,(%esp)
8010403e:	e8 06 ea ff ff       	call   80102a49 <kfree>
  if(*f0)
80104043:	8b 45 08             	mov    0x8(%ebp),%eax
80104046:	8b 00                	mov    (%eax),%eax
80104048:	85 c0                	test   %eax,%eax
8010404a:	74 0d                	je     80104059 <pipealloc+0x126>
    fileclose(*f0);
8010404c:	8b 45 08             	mov    0x8(%ebp),%eax
8010404f:	8b 00                	mov    (%eax),%eax
80104051:	89 04 24             	mov    %eax,(%esp)
80104054:	e8 75 cf ff ff       	call   80100fce <fileclose>
  if(*f1)
80104059:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405c:	8b 00                	mov    (%eax),%eax
8010405e:	85 c0                	test   %eax,%eax
80104060:	74 0d                	je     8010406f <pipealloc+0x13c>
    fileclose(*f1);
80104062:	8b 45 0c             	mov    0xc(%ebp),%eax
80104065:	8b 00                	mov    (%eax),%eax
80104067:	89 04 24             	mov    %eax,(%esp)
8010406a:	e8 5f cf ff ff       	call   80100fce <fileclose>
  return -1;
8010406f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104074:	c9                   	leave  
80104075:	c3                   	ret    

80104076 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104076:	55                   	push   %ebp
80104077:	89 e5                	mov    %esp,%ebp
80104079:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
8010407c:	8b 45 08             	mov    0x8(%ebp),%eax
8010407f:	89 04 24             	mov    %eax,(%esp)
80104082:	e8 b4 10 00 00       	call   8010513b <acquire>
  if(writable){
80104087:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010408b:	74 1f                	je     801040ac <pipeclose+0x36>
    p->writeopen = 0;
8010408d:	8b 45 08             	mov    0x8(%ebp),%eax
80104090:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104097:	00 00 00 
    wakeup(&p->nread);
8010409a:	8b 45 08             	mov    0x8(%ebp),%eax
8010409d:	05 34 02 00 00       	add    $0x234,%eax
801040a2:	89 04 24             	mov    %eax,(%esp)
801040a5:	e8 47 0e 00 00       	call   80104ef1 <wakeup>
801040aa:	eb 1d                	jmp    801040c9 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801040ac:	8b 45 08             	mov    0x8(%ebp),%eax
801040af:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040b6:	00 00 00 
    wakeup(&p->nwrite);
801040b9:	8b 45 08             	mov    0x8(%ebp),%eax
801040bc:	05 38 02 00 00       	add    $0x238,%eax
801040c1:	89 04 24             	mov    %eax,(%esp)
801040c4:	e8 28 0e 00 00       	call   80104ef1 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040c9:	8b 45 08             	mov    0x8(%ebp),%eax
801040cc:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040d2:	85 c0                	test   %eax,%eax
801040d4:	75 25                	jne    801040fb <pipeclose+0x85>
801040d6:	8b 45 08             	mov    0x8(%ebp),%eax
801040d9:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040df:	85 c0                	test   %eax,%eax
801040e1:	75 18                	jne    801040fb <pipeclose+0x85>
    release(&p->lock);
801040e3:	8b 45 08             	mov    0x8(%ebp),%eax
801040e6:	89 04 24             	mov    %eax,(%esp)
801040e9:	e8 af 10 00 00       	call   8010519d <release>
    kfree((char*)p);
801040ee:	8b 45 08             	mov    0x8(%ebp),%eax
801040f1:	89 04 24             	mov    %eax,(%esp)
801040f4:	e8 50 e9 ff ff       	call   80102a49 <kfree>
801040f9:	eb 0b                	jmp    80104106 <pipeclose+0x90>
  } else
    release(&p->lock);
801040fb:	8b 45 08             	mov    0x8(%ebp),%eax
801040fe:	89 04 24             	mov    %eax,(%esp)
80104101:	e8 97 10 00 00       	call   8010519d <release>
}
80104106:	c9                   	leave  
80104107:	c3                   	ret    

80104108 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104108:	55                   	push   %ebp
80104109:	89 e5                	mov    %esp,%ebp
8010410b:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
8010410e:	8b 45 08             	mov    0x8(%ebp),%eax
80104111:	89 04 24             	mov    %eax,(%esp)
80104114:	e8 22 10 00 00       	call   8010513b <acquire>
  for(i = 0; i < n; i++){
80104119:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104120:	e9 a6 00 00 00       	jmp    801041cb <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104125:	eb 57                	jmp    8010417e <pipewrite+0x76>
        if(p->readopen == 0 || proc->killed){
80104127:	8b 45 08             	mov    0x8(%ebp),%eax
8010412a:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104130:	85 c0                	test   %eax,%eax
80104132:	74 0d                	je     80104141 <pipewrite+0x39>
80104134:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010413a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010413d:	85 c0                	test   %eax,%eax
8010413f:	74 15                	je     80104156 <pipewrite+0x4e>
        release(&p->lock);
80104141:	8b 45 08             	mov    0x8(%ebp),%eax
80104144:	89 04 24             	mov    %eax,(%esp)
80104147:	e8 51 10 00 00       	call   8010519d <release>
        return -1;
8010414c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104151:	e9 9f 00 00 00       	jmp    801041f5 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104156:	8b 45 08             	mov    0x8(%ebp),%eax
80104159:	05 34 02 00 00       	add    $0x234,%eax
8010415e:	89 04 24             	mov    %eax,(%esp)
80104161:	e8 8b 0d 00 00       	call   80104ef1 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104166:	8b 45 08             	mov    0x8(%ebp),%eax
80104169:	8b 55 08             	mov    0x8(%ebp),%edx
8010416c:	81 c2 38 02 00 00    	add    $0x238,%edx
80104172:	89 44 24 04          	mov    %eax,0x4(%esp)
80104176:	89 14 24             	mov    %edx,(%esp)
80104179:	e8 2c 0c 00 00       	call   80104daa <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010417e:	8b 45 08             	mov    0x8(%ebp),%eax
80104181:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104187:	8b 45 08             	mov    0x8(%ebp),%eax
8010418a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104190:	05 00 02 00 00       	add    $0x200,%eax
80104195:	39 c2                	cmp    %eax,%edx
80104197:	74 8e                	je     80104127 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104199:	8b 45 08             	mov    0x8(%ebp),%eax
8010419c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041a2:	8d 48 01             	lea    0x1(%eax),%ecx
801041a5:	8b 55 08             	mov    0x8(%ebp),%edx
801041a8:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801041ae:	25 ff 01 00 00       	and    $0x1ff,%eax
801041b3:	89 c1                	mov    %eax,%ecx
801041b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801041bb:	01 d0                	add    %edx,%eax
801041bd:	0f b6 10             	movzbl (%eax),%edx
801041c0:	8b 45 08             	mov    0x8(%ebp),%eax
801041c3:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ce:	3b 45 10             	cmp    0x10(%ebp),%eax
801041d1:	0f 8c 4e ff ff ff    	jl     80104125 <pipewrite+0x1d>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }

  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801041d7:	8b 45 08             	mov    0x8(%ebp),%eax
801041da:	05 34 02 00 00       	add    $0x234,%eax
801041df:	89 04 24             	mov    %eax,(%esp)
801041e2:	e8 0a 0d 00 00       	call   80104ef1 <wakeup>
  release(&p->lock);
801041e7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ea:	89 04 24             	mov    %eax,(%esp)
801041ed:	e8 ab 0f 00 00       	call   8010519d <release>

  return n;
801041f2:	8b 45 10             	mov    0x10(%ebp),%eax
}
801041f5:	c9                   	leave  
801041f6:	c3                   	ret    

801041f7 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801041f7:	55                   	push   %ebp
801041f8:	89 e5                	mov    %esp,%ebp
801041fa:	53                   	push   %ebx
801041fb:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104201:	89 04 24             	mov    %eax,(%esp)
80104204:	e8 32 0f 00 00       	call   8010513b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104209:	eb 3a                	jmp    80104245 <piperead+0x4e>
    if(proc->killed){
8010420b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104211:	8b 40 1c             	mov    0x1c(%eax),%eax
80104214:	85 c0                	test   %eax,%eax
80104216:	74 15                	je     8010422d <piperead+0x36>
      release(&p->lock);
80104218:	8b 45 08             	mov    0x8(%ebp),%eax
8010421b:	89 04 24             	mov    %eax,(%esp)
8010421e:	e8 7a 0f 00 00       	call   8010519d <release>
      return -1;
80104223:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104228:	e9 b5 00 00 00       	jmp    801042e2 <piperead+0xeb>
      }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010422d:	8b 45 08             	mov    0x8(%ebp),%eax
80104230:	8b 55 08             	mov    0x8(%ebp),%edx
80104233:	81 c2 34 02 00 00    	add    $0x234,%edx
80104239:	89 44 24 04          	mov    %eax,0x4(%esp)
8010423d:	89 14 24             	mov    %edx,(%esp)
80104240:	e8 65 0b 00 00       	call   80104daa <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104245:	8b 45 08             	mov    0x8(%ebp),%eax
80104248:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010424e:	8b 45 08             	mov    0x8(%ebp),%eax
80104251:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104257:	39 c2                	cmp    %eax,%edx
80104259:	75 0d                	jne    80104268 <piperead+0x71>
8010425b:	8b 45 08             	mov    0x8(%ebp),%eax
8010425e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104264:	85 c0                	test   %eax,%eax
80104266:	75 a3                	jne    8010420b <piperead+0x14>
      return -1;
      }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }

  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104268:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010426f:	eb 4b                	jmp    801042bc <piperead+0xc5>
    if(p->nread == p->nwrite)
80104271:	8b 45 08             	mov    0x8(%ebp),%eax
80104274:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010427a:	8b 45 08             	mov    0x8(%ebp),%eax
8010427d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104283:	39 c2                	cmp    %eax,%edx
80104285:	75 02                	jne    80104289 <piperead+0x92>
      break;
80104287:	eb 3b                	jmp    801042c4 <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104289:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010428c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010428f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104292:	8b 45 08             	mov    0x8(%ebp),%eax
80104295:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010429b:	8d 48 01             	lea    0x1(%eax),%ecx
8010429e:	8b 55 08             	mov    0x8(%ebp),%edx
801042a1:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801042a7:	25 ff 01 00 00       	and    $0x1ff,%eax
801042ac:	89 c2                	mov    %eax,%edx
801042ae:	8b 45 08             	mov    0x8(%ebp),%eax
801042b1:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801042b6:	88 03                	mov    %al,(%ebx)
      return -1;
      }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }

  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042bf:	3b 45 10             	cmp    0x10(%ebp),%eax
801042c2:	7c ad                	jl     80104271 <piperead+0x7a>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  //  cprintf("here pipe %d\n",i);
  }

  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042c4:	8b 45 08             	mov    0x8(%ebp),%eax
801042c7:	05 38 02 00 00       	add    $0x238,%eax
801042cc:	89 04 24             	mov    %eax,(%esp)
801042cf:	e8 1d 0c 00 00       	call   80104ef1 <wakeup>
  release(&p->lock);
801042d4:	8b 45 08             	mov    0x8(%ebp),%eax
801042d7:	89 04 24             	mov    %eax,(%esp)
801042da:	e8 be 0e 00 00       	call   8010519d <release>
  return i;
801042df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042e2:	83 c4 24             	add    $0x24,%esp
801042e5:	5b                   	pop    %ebx
801042e6:	5d                   	pop    %ebp
801042e7:	c3                   	ret    

801042e8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801042e8:	55                   	push   %ebp
801042e9:	89 e5                	mov    %esp,%ebp
801042eb:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042ee:	9c                   	pushf  
801042ef:	58                   	pop    %eax
801042f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801042f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801042f6:	c9                   	leave  
801042f7:	c3                   	ret    

801042f8 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801042f8:	55                   	push   %ebp
801042f9:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801042fb:	fb                   	sti    
}
801042fc:	5d                   	pop    %ebp
801042fd:	c3                   	ret    

801042fe <procIsReady>:
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

int procIsReady(struct proc * p){
801042fe:	55                   	push   %ebp
801042ff:	89 e5                	mov    %esp,%ebp

	if(p->state == ZOMBIE || p->state == UNUSED || p->state == EMBRYO){
80104301:	8b 45 08             	mov    0x8(%ebp),%eax
80104304:	8b 40 0c             	mov    0xc(%eax),%eax
80104307:	83 f8 05             	cmp    $0x5,%eax
8010430a:	74 15                	je     80104321 <procIsReady+0x23>
8010430c:	8b 45 08             	mov    0x8(%ebp),%eax
8010430f:	8b 40 0c             	mov    0xc(%eax),%eax
80104312:	85 c0                	test   %eax,%eax
80104314:	74 0b                	je     80104321 <procIsReady+0x23>
80104316:	8b 45 08             	mov    0x8(%ebp),%eax
80104319:	8b 40 0c             	mov    0xc(%eax),%eax
8010431c:	83 f8 01             	cmp    $0x1,%eax
8010431f:	75 07                	jne    80104328 <procIsReady+0x2a>
		return 0;
80104321:	b8 00 00 00 00       	mov    $0x0,%eax
80104326:	eb 05                	jmp    8010432d <procIsReady+0x2f>
	}
	return 1;
80104328:	b8 01 00 00 00       	mov    $0x1,%eax

}
8010432d:	5d                   	pop    %ebp
8010432e:	c3                   	ret    

8010432f <pinit>:


void
pinit(void)
{
8010432f:	55                   	push   %ebp
80104330:	89 e5                	mov    %esp,%ebp
80104332:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104335:	c7 44 24 04 a9 8c 10 	movl   $0x80108ca9,0x4(%esp)
8010433c:	80 
8010433d:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104344:	e8 d1 0d 00 00       	call   8010511a <initlock>
}
80104349:	c9                   	leave  
8010434a:	c3                   	ret    

8010434b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010434b:	55                   	push   %ebp
8010434c:	89 e5                	mov    %esp,%ebp
8010434e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  int i=0;
80104351:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  acquire(&ptable.lock);
80104358:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010435f:	e8 d7 0d 00 00       	call   8010513b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104364:	c7 45 f4 b4 c6 11 80 	movl   $0x8011c6b4,-0xc(%ebp)
8010436b:	e9 88 00 00 00       	jmp    801043f8 <allocproc+0xad>
    if(p->state == UNUSED)
80104370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104373:	8b 40 0c             	mov    0xc(%eax),%eax
80104376:	85 c0                	test   %eax,%eax
80104378:	75 76                	jne    801043f0 <allocproc+0xa5>
      goto found;
8010437a:	90                   	nop
    	i++;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010437b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437e:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->lock = &ptable.tTable[i].threadLock;
80104385:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104388:	69 c0 34 02 00 00    	imul   $0x234,%eax,%eax
8010438e:	83 c0 30             	add    $0x30,%eax
80104391:	05 80 39 11 80       	add    $0x80113980,%eax
80104396:	8d 50 04             	lea    0x4(%eax),%edx
80104399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439c:	89 50 78             	mov    %edx,0x78(%eax)
  p->threads = ptable.tTable[i].threads;
8010439f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043a2:	69 c0 34 02 00 00    	imul   $0x234,%eax,%eax
801043a8:	83 c0 60             	add    $0x60,%eax
801043ab:	05 80 39 11 80       	add    $0x80113980,%eax
801043b0:	8d 50 08             	lea    0x8(%eax),%edx
801043b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b6:	89 50 74             	mov    %edx,0x74(%eax)
  p->pid = nextpid++;
801043b9:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801043be:	8d 50 01             	lea    0x1(%eax),%edx
801043c1:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
801043c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ca:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801043cd:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801043d4:	e8 c4 0d 00 00       	call   8010519d <release>



  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043d9:	e8 04 e7 ff ff       	call   80102ae2 <kalloc>
801043de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043e1:	89 42 08             	mov    %eax,0x8(%edx)
801043e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e7:	8b 40 08             	mov    0x8(%eax),%eax
801043ea:	85 c0                	test   %eax,%eax
801043ec:	75 41                	jne    8010442f <allocproc+0xe4>
801043ee:	eb 2b                	jmp    8010441b <allocproc+0xd0>
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
    else
    	i++;
801043f0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  struct proc *p;
  char *sp;
  int i=0;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043f4:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801043f8:	81 7d f4 b4 e5 11 80 	cmpl   $0x8011e5b4,-0xc(%ebp)
801043ff:	0f 82 6b ff ff ff    	jb     80104370 <allocproc+0x25>
    if(p->state == UNUSED)
      goto found;
    else
    	i++;
  release(&ptable.lock);
80104405:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010440c:	e8 8c 0d 00 00       	call   8010519d <release>
  return 0;
80104411:	b8 00 00 00 00       	mov    $0x0,%eax
80104416:	e9 d5 00 00 00       	jmp    801044f0 <allocproc+0x1a5>



  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010441b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104425:	b8 00 00 00 00       	mov    $0x0,%eax
8010442a:	e9 c1 00 00 00       	jmp    801044f0 <allocproc+0x1a5>
  }
  sp = p->kstack + KSTACKSIZE;
8010442f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104432:	8b 40 08             	mov    0x8(%eax),%eax
80104435:	05 00 10 00 00       	add    $0x1000,%eax
8010443a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  initlock( p->lock, "threadLock");
8010443d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104440:	8b 40 78             	mov    0x78(%eax),%eax
80104443:	c7 44 24 04 b0 8c 10 	movl   $0x80108cb0,0x4(%esp)
8010444a:	80 
8010444b:	89 04 24             	mov    %eax,(%esp)
8010444e:	e8 c7 0c 00 00       	call   8010511a <initlock>
    for (i=0; i<NTHREAD; i++)
80104453:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010445a:	eb 19                	jmp    80104475 <allocproc+0x12a>
    {
  	  p->threads[i].state=UNUSED;
8010445c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445f:	8b 40 74             	mov    0x74(%eax),%eax
80104462:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104465:	c1 e2 05             	shl    $0x5,%edx
80104468:	01 d0                	add    %edx,%eax
8010446a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  initlock( p->lock, "threadLock");
    for (i=0; i<NTHREAD; i++)
80104471:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104475:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104479:	7e e1                	jle    8010445c <allocproc+0x111>
    {
  	  p->threads[i].state=UNUSED;
    }

  struct kthread* t= p->threads;
8010447b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447e:	8b 40 74             	mov    0x74(%eax),%eax
80104481:	89 45 e8             	mov    %eax,-0x18(%ebp)
  // Leave room for trap frame.
  sp -= sizeof *t->tf;
80104484:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  t->tf = (struct trapframe*)sp;
80104488:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010448b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010448e:	89 50 10             	mov    %edx,0x10(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104491:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80104495:	ba 9e 67 10 80       	mov    $0x8010679e,%edx
8010449a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010449d:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *t->context;
8010449f:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  t->context = (struct context*)sp;
801044a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801044a9:	89 50 14             	mov    %edx,0x14(%eax)
  memset(t->context, 0, sizeof *t->context);
801044ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044af:	8b 40 14             	mov    0x14(%eax),%eax
801044b2:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801044b9:	00 
801044ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044c1:	00 
801044c2:	89 04 24             	mov    %eax,(%esp)
801044c5:	e8 c5 0e 00 00       	call   8010538f <memset>
  t->context->eip = (uint)forkret;
801044ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044cd:	8b 40 14             	mov    0x14(%eax),%eax
801044d0:	ba 7e 4d 10 80       	mov    $0x80104d7e,%edx
801044d5:	89 50 10             	mov    %edx,0x10(%eax)
  t->kstack= p->kstack;
801044d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044db:	8b 50 08             	mov    0x8(%eax),%edx
801044de:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044e1:	89 10                	mov    %edx,(%eax)
  t->kernelStack=1;
801044e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044e6:	c7 40 1c 01 00 00 00 	movl   $0x1,0x1c(%eax)

  return p;
801044ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044f0:	c9                   	leave  
801044f1:	c3                   	ret    

801044f2 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801044f2:	55                   	push   %ebp
801044f3:	89 e5                	mov    %esp,%ebp
801044f5:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801044f8:	e8 4e fe ff ff       	call   8010434b <allocproc>
801044fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104503:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
80104508:	e8 8a 39 00 00       	call   80107e97 <setupkvm>
8010450d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104510:	89 42 04             	mov    %eax,0x4(%edx)
80104513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104516:	8b 40 04             	mov    0x4(%eax),%eax
80104519:	85 c0                	test   %eax,%eax
8010451b:	75 0c                	jne    80104529 <userinit+0x37>
    panic("userinit: out of memory?");
8010451d:	c7 04 24 bb 8c 10 80 	movl   $0x80108cbb,(%esp)
80104524:	e8 11 c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104529:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010452e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104531:	8b 40 04             	mov    0x4(%eax),%eax
80104534:	89 54 24 08          	mov    %edx,0x8(%esp)
80104538:	c7 44 24 04 e0 c4 10 	movl   $0x8010c4e0,0x4(%esp)
8010453f:	80 
80104540:	89 04 24             	mov    %eax,(%esp)
80104543:	e8 a7 3b 00 00       	call   801080ef <inituvm>
  p->sz = PGSIZE;
80104548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454b:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)

  struct kthread* t= p->threads;
80104551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104554:	8b 40 74             	mov    0x74(%eax),%eax
80104557:	89 45 f0             	mov    %eax,-0x10(%ebp)

  memset(t->tf, 0, sizeof(*t->tf));
8010455a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010455d:	8b 40 10             	mov    0x10(%eax),%eax
80104560:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104567:	00 
80104568:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010456f:	00 
80104570:	89 04 24             	mov    %eax,(%esp)
80104573:	e8 17 0e 00 00       	call   8010538f <memset>
  t->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104578:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010457b:	8b 40 10             	mov    0x10(%eax),%eax
8010457e:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  t->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104587:	8b 40 10             	mov    0x10(%eax),%eax
8010458a:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  t->tf->es = t->tf->ds;
80104590:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104593:	8b 40 10             	mov    0x10(%eax),%eax
80104596:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104599:	8b 52 10             	mov    0x10(%edx),%edx
8010459c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801045a0:	66 89 50 28          	mov    %dx,0x28(%eax)
  t->tf->ss = t->tf->ds;
801045a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045a7:	8b 40 10             	mov    0x10(%eax),%eax
801045aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045ad:	8b 52 10             	mov    0x10(%edx),%edx
801045b0:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801045b4:	66 89 50 48          	mov    %dx,0x48(%eax)
  t->tf->eflags = FL_IF;
801045b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045bb:	8b 40 10             	mov    0x10(%eax),%eax
801045be:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  t->tf->esp = PGSIZE;
801045c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045c8:	8b 40 10             	mov    0x10(%eax),%eax
801045cb:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  t->tf->eip = 0;  // beginning of initcode.S
801045d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045d5:	8b 40 10             	mov    0x10(%eax),%eax
801045d8:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801045df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e2:	83 c0 64             	add    $0x64,%eax
801045e5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801045ec:	00 
801045ed:	c7 44 24 04 d4 8c 10 	movl   $0x80108cd4,0x4(%esp)
801045f4:	80 
801045f5:	89 04 24             	mov    %eax,(%esp)
801045f8:	e8 b2 0f 00 00       	call   801055af <safestrcpy>
  p->cwd = namei("/");
801045fd:	c7 04 24 dd 8c 10 80 	movl   $0x80108cdd,(%esp)
80104604:	e8 fd dd ff ff       	call   80102406 <namei>
80104609:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010460c:	89 42 60             	mov    %eax,0x60(%edx)
  p->state = RUNNABLE;
8010460f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104612:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  t->state =  RUNNABLE;
80104619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010461c:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)
}
80104623:	c9                   	leave  
80104624:	c3                   	ret    

80104625 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104625:	55                   	push   %ebp
80104626:	89 e5                	mov    %esp,%ebp
80104628:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  //struct spinlock* lock =proc->lock;
  //  acquire( lock);
  sz = proc->sz;
8010462b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104631:	8b 00                	mov    (%eax),%eax
80104633:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(proc->lock);
80104636:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010463c:	8b 40 78             	mov    0x78(%eax),%eax
8010463f:	89 04 24             	mov    %eax,(%esp)
80104642:	e8 f4 0a 00 00       	call   8010513b <acquire>
  if(n > 0){
80104647:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010464b:	7e 45                	jle    80104692 <growproc+0x6d>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0){
8010464d:	8b 55 08             	mov    0x8(%ebp),%edx
80104650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104653:	01 c2                	add    %eax,%edx
80104655:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010465b:	8b 40 04             	mov    0x4(%eax),%eax
8010465e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104662:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104665:	89 54 24 04          	mov    %edx,0x4(%esp)
80104669:	89 04 24             	mov    %eax,(%esp)
8010466c:	e8 f4 3b 00 00       	call   80108265 <allocuvm>
80104671:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104674:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104678:	75 63                	jne    801046dd <growproc+0xb8>
      release(proc->lock);
8010467a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104680:	8b 40 78             	mov    0x78(%eax),%eax
80104683:	89 04 24             	mov    %eax,(%esp)
80104686:	e8 12 0b 00 00       	call   8010519d <release>
      return -1;
8010468b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104690:	eb 7a                	jmp    8010470c <growproc+0xe7>
    }
  } else if(n < 0){
80104692:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104696:	79 45                	jns    801046dd <growproc+0xb8>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0){
80104698:	8b 55 08             	mov    0x8(%ebp),%edx
8010469b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469e:	01 c2                	add    %eax,%edx
801046a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046a6:	8b 40 04             	mov    0x4(%eax),%eax
801046a9:	89 54 24 08          	mov    %edx,0x8(%esp)
801046ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801046b4:	89 04 24             	mov    %eax,(%esp)
801046b7:	e8 83 3c 00 00       	call   8010833f <deallocuvm>
801046bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046c3:	75 18                	jne    801046dd <growproc+0xb8>
    	release(proc->lock);
801046c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046cb:	8b 40 78             	mov    0x78(%eax),%eax
801046ce:	89 04 24             	mov    %eax,(%esp)
801046d1:	e8 c7 0a 00 00       	call   8010519d <release>
    	return -1;
801046d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046db:	eb 2f                	jmp    8010470c <growproc+0xe7>
    }
  }
  release(proc->lock);
801046dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e3:	8b 40 78             	mov    0x78(%eax),%eax
801046e6:	89 04 24             	mov    %eax,(%esp)
801046e9:	e8 af 0a 00 00       	call   8010519d <release>
  proc->sz = sz;
801046ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046f7:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801046f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ff:	89 04 24             	mov    %eax,(%esp)
80104702:	e8 81 38 00 00       	call   80107f88 <switchuvm>
//  release(lock);
  return 0;
80104707:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010470c:	c9                   	leave  
8010470d:	c3                   	ret    

8010470e <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010470e:	55                   	push   %ebp
8010470f:	89 e5                	mov    %esp,%ebp
80104711:	57                   	push   %edi
80104712:	56                   	push   %esi
80104713:	53                   	push   %ebx
80104714:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104717:	e8 2f fc ff ff       	call   8010434b <allocproc>
8010471c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010471f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104723:	75 0a                	jne    8010472f <fork+0x21>
    return -1;
80104725:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010472a:	e9 d6 01 00 00       	jmp    80104905 <fork+0x1f7>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010472f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104735:	8b 10                	mov    (%eax),%edx
80104737:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473d:	8b 40 04             	mov    0x4(%eax),%eax
80104740:	89 54 24 04          	mov    %edx,0x4(%esp)
80104744:	89 04 24             	mov    %eax,(%esp)
80104747:	e8 8f 3d 00 00       	call   801084db <copyuvm>
8010474c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010474f:	89 42 04             	mov    %eax,0x4(%edx)
80104752:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104755:	8b 40 04             	mov    0x4(%eax),%eax
80104758:	85 c0                	test   %eax,%eax
8010475a:	75 2c                	jne    80104788 <fork+0x7a>
    kfree(np->kstack);
8010475c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475f:	8b 40 08             	mov    0x8(%eax),%eax
80104762:	89 04 24             	mov    %eax,(%esp)
80104765:	e8 df e2 ff ff       	call   80102a49 <kfree>
    np->kstack = 0;
8010476a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010476d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104774:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104777:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010477e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104783:	e9 7d 01 00 00       	jmp    80104905 <fork+0x1f7>
  }
  np->sz = proc->sz;
80104788:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010478e:	8b 10                	mov    (%eax),%edx
80104790:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104793:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104795:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010479c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479f:	89 50 14             	mov    %edx,0x14(%eax)


  for (i=1; i<NTHREAD; i++)
801047a2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
801047a9:	eb 19                	jmp    801047c4 <fork+0xb6>
  {
	  np->threads[i].state=UNUSED;
801047ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ae:	8b 40 74             	mov    0x74(%eax),%eax
801047b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801047b4:	c1 e2 05             	shl    $0x5,%edx
801047b7:	01 d0                	add    %edx,%eax
801047b9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  }
  np->sz = proc->sz;
  np->parent = proc;


  for (i=1; i<NTHREAD; i++)
801047c0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801047c4:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801047c8:	7e e1                	jle    801047ab <fork+0x9d>
  {
	  np->threads[i].state=UNUSED;
  }
  np->threads[0].parent= np;
801047ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047cd:	8b 40 74             	mov    0x74(%eax),%eax
801047d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047d3:	89 50 0c             	mov    %edx,0xc(%eax)
  np->threads[0].kstack = thread->kstack;
801047d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d9:	8b 40 74             	mov    0x74(%eax),%eax
801047dc:	65 8b 15 08 00 00 00 	mov    %gs:0x8,%edx
801047e3:	8b 12                	mov    (%edx),%edx
801047e5:	89 10                	mov    %edx,(%eax)
  *np->threads[0].tf = *thread->tf;
801047e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ea:	8b 40 74             	mov    0x74(%eax),%eax
801047ed:	8b 50 10             	mov    0x10(%eax),%edx
801047f0:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801047f6:	8b 40 10             	mov    0x10(%eax),%eax
801047f9:	89 c3                	mov    %eax,%ebx
801047fb:	b8 13 00 00 00       	mov    $0x13,%eax
80104800:	89 d7                	mov    %edx,%edi
80104802:	89 de                	mov    %ebx,%esi
80104804:	89 c1                	mov    %eax,%ecx
80104806:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->threads[0].kernelStack=  thread->kernelStack;
80104808:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010480b:	8b 40 74             	mov    0x74(%eax),%eax
8010480e:	65 8b 15 08 00 00 00 	mov    %gs:0x8,%edx
80104815:	8b 52 1c             	mov    0x1c(%edx),%edx
80104818:	89 50 1c             	mov    %edx,0x1c(%eax)




  // Clear %eax so that fork returns 0 in the child.
  np->threads[0].tf->eax = 0;
8010481b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010481e:	8b 40 74             	mov    0x74(%eax),%eax
80104821:	8b 40 10             	mov    0x10(%eax),%eax
80104824:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010482b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104832:	eb 3a                	jmp    8010486e <fork+0x160>
    if(proc->ofile[i]){
80104834:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010483d:	83 c2 08             	add    $0x8,%edx
80104840:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104843:	85 c0                	test   %eax,%eax
80104845:	74 23                	je     8010486a <fork+0x15c>
      np->ofile[i] = filedup(proc->ofile[i]);
80104847:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010484d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104850:	83 c2 08             	add    $0x8,%edx
80104853:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104856:	89 04 24             	mov    %eax,(%esp)
80104859:	e8 28 c7 ff ff       	call   80100f86 <filedup>
8010485e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104861:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104864:	83 c1 08             	add    $0x8,%ecx
80104867:	89 04 8a             	mov    %eax,(%edx,%ecx,4)


  // Clear %eax so that fork returns 0 in the child.
  np->threads[0].tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010486a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010486e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104872:	7e c0                	jle    80104834 <fork+0x126>
    if(proc->ofile[i]){
      np->ofile[i] = filedup(proc->ofile[i]);

    }
  np->cwd = idup(proc->cwd);
80104874:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010487a:	8b 40 60             	mov    0x60(%eax),%eax
8010487d:	89 04 24             	mov    %eax,(%esp)
80104880:	e8 a4 cf ff ff       	call   80101829 <idup>
80104885:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104888:	89 42 60             	mov    %eax,0x60(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010488b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104891:	8d 50 64             	lea    0x64(%eax),%edx
80104894:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104897:	83 c0 64             	add    $0x64,%eax
8010489a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801048a1:	00 
801048a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801048a6:	89 04 24             	mov    %eax,(%esp)
801048a9:	e8 01 0d 00 00       	call   801055af <safestrcpy>
 
  pid = np->pid;
801048ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b1:	8b 40 10             	mov    0x10(%eax),%eax
801048b4:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048b7:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801048be:	e8 78 08 00 00       	call   8010513b <acquire>
  acquire(np->lock);
801048c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048c6:	8b 40 78             	mov    0x78(%eax),%eax
801048c9:	89 04 24             	mov    %eax,(%esp)
801048cc:	e8 6a 08 00 00       	call   8010513b <acquire>
  np->state = RUNNABLE;
801048d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  np->threads[0].state =  RUNNABLE;
801048db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048de:	8b 40 74             	mov    0x74(%eax),%eax
801048e1:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)
  release(np->lock);
801048e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048eb:	8b 40 78             	mov    0x78(%eax),%eax
801048ee:	89 04 24             	mov    %eax,(%esp)
801048f1:	e8 a7 08 00 00       	call   8010519d <release>
  release(&ptable.lock);
801048f6:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801048fd:	e8 9b 08 00 00       	call   8010519d <release>

  return pid;
80104902:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104905:	83 c4 2c             	add    $0x2c,%esp
80104908:	5b                   	pop    %ebx
80104909:	5e                   	pop    %esi
8010490a:	5f                   	pop    %edi
8010490b:	5d                   	pop    %ebp
8010490c:	c3                   	ret    

8010490d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010490d:	55                   	push   %ebp
8010490e:	89 e5                	mov    %esp,%ebp
80104910:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;
  int tid;
  if(proc == initproc)
80104913:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010491a:	a1 48 c6 10 80       	mov    0x8010c648,%eax
8010491f:	39 c2                	cmp    %eax,%edx
80104921:	75 0c                	jne    8010492f <exit+0x22>
    panic("init exiting");
80104923:	c7 04 24 df 8c 10 80 	movl   $0x80108cdf,(%esp)
8010492a:	e8 0b bc ff ff       	call   8010053a <panic>



  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010492f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104936:	eb 41                	jmp    80104979 <exit+0x6c>
    if(proc->ofile[fd]){
80104938:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010493e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104941:	83 c2 08             	add    $0x8,%edx
80104944:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104947:	85 c0                	test   %eax,%eax
80104949:	74 2a                	je     80104975 <exit+0x68>
      fileclose(proc->ofile[fd]);
8010494b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104951:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104954:	83 c2 08             	add    $0x8,%edx
80104957:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010495a:	89 04 24             	mov    %eax,(%esp)
8010495d:	e8 6c c6 ff ff       	call   80100fce <fileclose>
      proc->ofile[fd] = 0;
80104962:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104968:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010496b:	83 c2 08             	add    $0x8,%edx
8010496e:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
    panic("init exiting");



  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104975:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104979:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010497d:	7e b9                	jle    80104938 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010497f:	e8 8c ea ff ff       	call   80103410 <begin_op>
  iput(proc->cwd);
80104984:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010498a:	8b 40 60             	mov    0x60(%eax),%eax
8010498d:	89 04 24             	mov    %eax,(%esp)
80104990:	e8 79 d0 ff ff       	call   80101a0e <iput>
  end_op();
80104995:	e8 fa ea ff ff       	call   80103494 <end_op>
  proc->cwd = 0;
8010499a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a0:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)

  acquire(&ptable.lock);
801049a7:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801049ae:	e8 88 07 00 00       	call   8010513b <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801049b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b9:	8b 40 14             	mov    0x14(%eax),%eax
801049bc:	89 04 24             	mov    %eax,(%esp)
801049bf:	e8 a3 04 00 00       	call   80104e67 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049c4:	c7 45 f4 b4 c6 11 80 	movl   $0x8011c6b4,-0xc(%ebp)
801049cb:	eb 38                	jmp    80104a05 <exit+0xf8>
    if(p->parent == proc){
801049cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d0:	8b 50 14             	mov    0x14(%eax),%edx
801049d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d9:	39 c2                	cmp    %eax,%edx
801049db:	75 24                	jne    80104a01 <exit+0xf4>
      p->parent = initproc;
801049dd:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
801049e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e6:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ec:	8b 40 0c             	mov    0xc(%eax),%eax
801049ef:	83 f8 05             	cmp    $0x5,%eax
801049f2:	75 0d                	jne    80104a01 <exit+0xf4>
        wakeup1(initproc);
801049f4:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801049f9:	89 04 24             	mov    %eax,(%esp)
801049fc:	e8 66 04 00 00       	call   80104e67 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a01:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a05:	81 7d f4 b4 e5 11 80 	cmpl   $0x8011e5b4,-0xc(%ebp)
80104a0c:	72 bf                	jb     801049cd <exit+0xc0>
        wakeup1(initproc);
    }
  }

 // Jump into the scheduler, never to return.
  acquire(proc->lock);
80104a0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a14:	8b 40 78             	mov    0x78(%eax),%eax
80104a17:	89 04 24             	mov    %eax,(%esp)
80104a1a:	e8 1c 07 00 00       	call   8010513b <acquire>

   for (tid=0; tid< NTHREAD; tid++){
80104a1f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104a26:	eb 1c                	jmp    80104a44 <exit+0x137>
 	  proc->threads[tid].state= ZOMBIE;
80104a28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a2e:	8b 40 74             	mov    0x74(%eax),%eax
80104a31:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104a34:	c1 e2 05             	shl    $0x5,%edx
80104a37:	01 d0                	add    %edx,%eax
80104a39:	c7 40 04 05 00 00 00 	movl   $0x5,0x4(%eax)
  }

 // Jump into the scheduler, never to return.
  acquire(proc->lock);

   for (tid=0; tid< NTHREAD; tid++){
80104a40:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104a44:	83 7d ec 0f          	cmpl   $0xf,-0x14(%ebp)
80104a48:	7e de                	jle    80104a28 <exit+0x11b>
 	  proc->threads[tid].state= ZOMBIE;
   }


   release(proc->lock);
80104a4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a50:	8b 40 78             	mov    0x78(%eax),%eax
80104a53:	89 04 24             	mov    %eax,(%esp)
80104a56:	e8 42 07 00 00       	call   8010519d <release>
  thread->state= ZOMBIE;
80104a5b:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104a61:	c7 40 04 05 00 00 00 	movl   $0x5,0x4(%eax)
  proc->state = ZOMBIE;
80104a68:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a6e:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a75:	e8 fe 01 00 00       	call   80104c78 <sched>
  panic("zombie exit");
80104a7a:	c7 04 24 ec 8c 10 80 	movl   $0x80108cec,(%esp)
80104a81:	e8 b4 ba ff ff       	call   8010053a <panic>

80104a86 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a86:	55                   	push   %ebp
80104a87:	89 e5                	mov    %esp,%ebp
80104a89:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a8c:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104a93:	e8 a3 06 00 00       	call   8010513b <acquire>

  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a98:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a9f:	c7 45 f4 b4 c6 11 80 	movl   $0x8011c6b4,-0xc(%ebp)
80104aa6:	e9 9a 00 00 00       	jmp    80104b45 <wait+0xbf>
      if(p->parent != proc)
80104aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aae:	8b 50 14             	mov    0x14(%eax),%edx
80104ab1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ab7:	39 c2                	cmp    %eax,%edx
80104ab9:	74 05                	je     80104ac0 <wait+0x3a>
        continue;
80104abb:	e9 81 00 00 00       	jmp    80104b41 <wait+0xbb>
      havekids = 1;
80104ac0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aca:	8b 40 0c             	mov    0xc(%eax),%eax
80104acd:	83 f8 05             	cmp    $0x5,%eax
80104ad0:	75 6f                	jne    80104b41 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad5:	8b 40 10             	mov    0x10(%eax),%eax
80104ad8:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ade:	8b 40 08             	mov    0x8(%eax),%eax
80104ae1:	89 04 24             	mov    %eax,(%esp)
80104ae4:	e8 60 df ff ff       	call   80102a49 <kfree>
        p->kstack = 0;
80104ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af6:	8b 40 04             	mov    0x4(%eax),%eax
80104af9:	89 04 24             	mov    %eax,(%esp)
80104afc:	e8 fa 38 00 00       	call   801083fb <freevm>
        p->state = UNUSED;
80104b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b04:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b18:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b22:	c6 40 64 00          	movb   $0x0,0x64(%eax)
        p->killed = 0;
80104b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b29:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        release(&ptable.lock);
80104b30:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104b37:	e8 61 06 00 00       	call   8010519d <release>
        return pid;
80104b3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b3f:	eb 52                	jmp    80104b93 <wait+0x10d>
  acquire(&ptable.lock);

  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b41:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b45:	81 7d f4 b4 e5 11 80 	cmpl   $0x8011e5b4,-0xc(%ebp)
80104b4c:	0f 82 59 ff ff ff    	jb     80104aab <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b52:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b56:	74 0d                	je     80104b65 <wait+0xdf>
80104b58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b5e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104b61:	85 c0                	test   %eax,%eax
80104b63:	74 13                	je     80104b78 <wait+0xf2>
      release(&ptable.lock);
80104b65:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104b6c:	e8 2c 06 00 00       	call   8010519d <release>
      return -1;
80104b71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b76:	eb 1b                	jmp    80104b93 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b7e:	c7 44 24 04 80 39 11 	movl   $0x80113980,0x4(%esp)
80104b85:	80 
80104b86:	89 04 24             	mov    %eax,(%esp)
80104b89:	e8 1c 02 00 00       	call   80104daa <sleep>
  }
80104b8e:	e9 05 ff ff ff       	jmp    80104a98 <wait+0x12>
  return -1;
}
80104b93:	c9                   	leave  
80104b94:	c3                   	ret    

80104b95 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b95:	55                   	push   %ebp
80104b96:	89 e5                	mov    %esp,%ebp
80104b98:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct kthread *t;
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b9b:	e8 58 f7 ff ff       	call   801042f8 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104ba0:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104ba7:	e8 8f 05 00 00       	call   8010513b <acquire>

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bac:	c7 45 f4 b4 c6 11 80 	movl   $0x8011c6b4,-0xc(%ebp)
80104bb3:	e9 a2 00 00 00       	jmp    80104c5a <scheduler+0xc5>
    	proc = p;
80104bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbb:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
    	if(! procIsReady(p))
80104bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc4:	89 04 24             	mov    %eax,(%esp)
80104bc7:	e8 32 f7 ff ff       	call   801042fe <procIsReady>
80104bcc:	85 c0                	test   %eax,%eax
80104bce:	75 05                	jne    80104bd5 <scheduler+0x40>
    		continue;
80104bd0:	e9 81 00 00 00       	jmp    80104c56 <scheduler+0xc1>

    	for (t=p->threads; t< &p->threads[NTHREAD]; t++ )
80104bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd8:	8b 40 74             	mov    0x74(%eax),%eax
80104bdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104bde:	eb 5b                	jmp    80104c3b <scheduler+0xa6>
    	{
		  if(t->state !=  RUNNABLE)
80104be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104be3:	8b 40 04             	mov    0x4(%eax),%eax
80104be6:	83 f8 03             	cmp    $0x3,%eax
80104be9:	74 02                	je     80104bed <scheduler+0x58>
			continue;
80104beb:	eb 4a                	jmp    80104c37 <scheduler+0xa2>

		  // Switch to chosen process.  It is the process's job
		  // to release ptable.lock and then reacquire it
		  // before jumping back to us.

		  thread= t;
80104bed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bf0:	65 a3 08 00 00 00    	mov    %eax,%gs:0x8
		  switchuvm(p);
80104bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf9:	89 04 24             	mov    %eax,(%esp)
80104bfc:	e8 87 33 00 00       	call   80107f88 <switchuvm>
		  t->state = RUNNING;
80104c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c04:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)

		  // cprintf("pid: %d \n",proc->pid );
		  swtch(&cpu->scheduler, t->context);
80104c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c0e:	8b 40 14             	mov    0x14(%eax),%eax
80104c11:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c18:	83 c2 04             	add    $0x4,%edx
80104c1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c1f:	89 14 24             	mov    %edx,(%esp)
80104c22:	e8 f9 09 00 00       	call   80105620 <swtch>
		  switchkvm();
80104c27:	e8 3f 33 00 00       	call   80107f6b <switchkvm>

		  // Process is done running for now.
		  // It should have changed its p->state before coming back.
		  thread =0;
80104c2c:	65 c7 05 08 00 00 00 	movl   $0x0,%gs:0x8
80104c33:	00 00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    	proc = p;
    	if(! procIsReady(p))
    		continue;

    	for (t=p->threads; t< &p->threads[NTHREAD]; t++ )
80104c37:	83 45 f0 20          	addl   $0x20,-0x10(%ebp)
80104c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3e:	8b 40 74             	mov    0x74(%eax),%eax
80104c41:	05 00 02 00 00       	add    $0x200,%eax
80104c46:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104c49:	77 95                	ja     80104be0 <scheduler+0x4b>
		  // Process is done running for now.
		  // It should have changed its p->state before coming back.
		  thread =0;

    	}
		proc = 0;
80104c4b:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c52:	00 00 00 00 
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c56:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104c5a:	81 7d f4 b4 e5 11 80 	cmpl   $0x8011e5b4,-0xc(%ebp)
80104c61:	0f 82 51 ff ff ff    	jb     80104bb8 <scheduler+0x23>
		  thread =0;

    	}
		proc = 0;
    }
    release(&ptable.lock);
80104c67:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104c6e:	e8 2a 05 00 00       	call   8010519d <release>

  }
80104c73:	e9 23 ff ff ff       	jmp    80104b9b <scheduler+0x6>

80104c78 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c78:	55                   	push   %ebp
80104c79:	89 e5                	mov    %esp,%ebp
80104c7b:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c7e:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104c85:	e8 db 05 00 00       	call   80105265 <holding>
80104c8a:	85 c0                	test   %eax,%eax
80104c8c:	75 0c                	jne    80104c9a <sched+0x22>
    panic("sched ptable.lock");
80104c8e:	c7 04 24 f8 8c 10 80 	movl   $0x80108cf8,(%esp)
80104c95:	e8 a0 b8 ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104c9a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ca0:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104ca6:	83 f8 01             	cmp    $0x1,%eax
80104ca9:	74 0c                	je     80104cb7 <sched+0x3f>
    panic("sched locks");
80104cab:	c7 04 24 0a 8d 10 80 	movl   $0x80108d0a,(%esp)
80104cb2:	e8 83 b8 ff ff       	call   8010053a <panic>
  if(thread->state == RUNNING)
80104cb7:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104cbd:	8b 40 04             	mov    0x4(%eax),%eax
80104cc0:	83 f8 04             	cmp    $0x4,%eax
80104cc3:	75 0c                	jne    80104cd1 <sched+0x59>
    panic("sched running");
80104cc5:	c7 04 24 16 8d 10 80 	movl   $0x80108d16,(%esp)
80104ccc:	e8 69 b8 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104cd1:	e8 12 f6 ff ff       	call   801042e8 <readeflags>
80104cd6:	25 00 02 00 00       	and    $0x200,%eax
80104cdb:	85 c0                	test   %eax,%eax
80104cdd:	74 0c                	je     80104ceb <sched+0x73>
    panic("sched interruptible");
80104cdf:	c7 04 24 24 8d 10 80 	movl   $0x80108d24,(%esp)
80104ce6:	e8 4f b8 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104ceb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cf1:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104cf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&thread->context, cpu->scheduler);
80104cfa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d00:	8b 40 04             	mov    0x4(%eax),%eax
80104d03:	65 8b 15 08 00 00 00 	mov    %gs:0x8,%edx
80104d0a:	83 c2 14             	add    $0x14,%edx
80104d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d11:	89 14 24             	mov    %edx,(%esp)
80104d14:	e8 07 09 00 00       	call   80105620 <swtch>
  cpu->intena = intena;
80104d19:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d22:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)

}
80104d28:	c9                   	leave  
80104d29:	c3                   	ret    

80104d2a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d2a:	55                   	push   %ebp
80104d2b:	89 e5                	mov    %esp,%ebp
80104d2d:	83 ec 18             	sub    $0x18,%esp

  acquire(&ptable.lock);  //DOC: yieldlock
80104d30:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104d37:	e8 ff 03 00 00       	call   8010513b <acquire>
  acquire(proc->lock);
80104d3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d42:	8b 40 78             	mov    0x78(%eax),%eax
80104d45:	89 04 24             	mov    %eax,(%esp)
80104d48:	e8 ee 03 00 00       	call   8010513b <acquire>
  thread->state =  RUNNABLE;
80104d4d:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104d53:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)
  release(proc->lock);
80104d5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d60:	8b 40 78             	mov    0x78(%eax),%eax
80104d63:	89 04 24             	mov    %eax,(%esp)
80104d66:	e8 32 04 00 00       	call   8010519d <release>
  sched();
80104d6b:	e8 08 ff ff ff       	call   80104c78 <sched>
  release(&ptable.lock);
80104d70:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104d77:	e8 21 04 00 00       	call   8010519d <release>

}
80104d7c:	c9                   	leave  
80104d7d:	c3                   	ret    

80104d7e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d7e:	55                   	push   %ebp
80104d7f:	89 e5                	mov    %esp,%ebp
80104d81:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d84:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104d8b:	e8 0d 04 00 00       	call   8010519d <release>

  if (first) {
80104d90:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80104d95:	85 c0                	test   %eax,%eax
80104d97:	74 0f                	je     80104da8 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d99:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80104da0:	00 00 00 
    initlog();
80104da3:	e8 5a e4 ff ff       	call   80103202 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104da8:	c9                   	leave  
80104da9:	c3                   	ret    

80104daa <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104daa:	55                   	push   %ebp
80104dab:	89 e5                	mov    %esp,%ebp
80104dad:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104db0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104db6:	85 c0                	test   %eax,%eax
80104db8:	75 0c                	jne    80104dc6 <sleep+0x1c>
    panic("sleep");
80104dba:	c7 04 24 38 8d 10 80 	movl   $0x80108d38,(%esp)
80104dc1:	e8 74 b7 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104dc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104dca:	75 0c                	jne    80104dd8 <sleep+0x2e>
    panic("sleep without lk");
80104dcc:	c7 04 24 3e 8d 10 80 	movl   $0x80108d3e,(%esp)
80104dd3:	e8 62 b7 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104dd8:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104ddf:	74 17                	je     80104df8 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104de1:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104de8:	e8 4e 03 00 00       	call   8010513b <acquire>
    release(lk);
80104ded:	8b 45 0c             	mov    0xc(%ebp),%eax
80104df0:	89 04 24             	mov    %eax,(%esp)
80104df3:	e8 a5 03 00 00       	call   8010519d <release>
  }

  // Go to sleep.
  acquire(proc->lock);
80104df8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dfe:	8b 40 78             	mov    0x78(%eax),%eax
80104e01:	89 04 24             	mov    %eax,(%esp)
80104e04:	e8 32 03 00 00       	call   8010513b <acquire>

  thread->chan = chan;
80104e09:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104e0f:	8b 55 08             	mov    0x8(%ebp),%edx
80104e12:	89 50 18             	mov    %edx,0x18(%eax)
  thread->state = SLEEPING;
80104e15:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104e1b:	c7 40 04 02 00 00 00 	movl   $0x2,0x4(%eax)
  release(proc->lock);
80104e22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e28:	8b 40 78             	mov    0x78(%eax),%eax
80104e2b:	89 04 24             	mov    %eax,(%esp)
80104e2e:	e8 6a 03 00 00       	call   8010519d <release>
  sched();
80104e33:	e8 40 fe ff ff       	call   80104c78 <sched>

  // Tidy up.
  thread->chan = 0;
80104e38:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104e3e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e45:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104e4c:	74 17                	je     80104e65 <sleep+0xbb>
    release(&ptable.lock);
80104e4e:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104e55:	e8 43 03 00 00       	call   8010519d <release>
    acquire(lk);
80104e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e5d:	89 04 24             	mov    %eax,(%esp)
80104e60:	e8 d6 02 00 00       	call   8010513b <acquire>
  }
}
80104e65:	c9                   	leave  
80104e66:	c3                   	ret    

80104e67 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e67:	55                   	push   %ebp
80104e68:	89 e5                	mov    %esp,%ebp
80104e6a:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;

  struct kthread *t;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e6d:	c7 45 f4 b4 c6 11 80 	movl   $0x8011c6b4,-0xc(%ebp)
80104e74:	eb 70                	jmp    80104ee6 <wakeup1+0x7f>
	  if (! procIsReady(p))
80104e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e79:	89 04 24             	mov    %eax,(%esp)
80104e7c:	e8 7d f4 ff ff       	call   801042fe <procIsReady>
80104e81:	85 c0                	test   %eax,%eax
80104e83:	75 02                	jne    80104e87 <wakeup1+0x20>
		  	 continue;
80104e85:	eb 5b                	jmp    80104ee2 <wakeup1+0x7b>
	  acquire( p->lock);
80104e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8a:	8b 40 78             	mov    0x78(%eax),%eax
80104e8d:	89 04 24             	mov    %eax,(%esp)
80104e90:	e8 a6 02 00 00       	call   8010513b <acquire>

	  for(t= p->threads; t < &p->threads[NTHREAD]; t++){
80104e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e98:	8b 40 74             	mov    0x74(%eax),%eax
80104e9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104e9e:	eb 24                	jmp    80104ec4 <wakeup1+0x5d>

		  if(t->state == SLEEPING && t->chan == chan)
80104ea0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ea3:	8b 40 04             	mov    0x4(%eax),%eax
80104ea6:	83 f8 02             	cmp    $0x2,%eax
80104ea9:	75 15                	jne    80104ec0 <wakeup1+0x59>
80104eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eae:	8b 40 18             	mov    0x18(%eax),%eax
80104eb1:	3b 45 08             	cmp    0x8(%ebp),%eax
80104eb4:	75 0a                	jne    80104ec0 <wakeup1+0x59>
			  t->state =  RUNNABLE;
80104eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eb9:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
	  if (! procIsReady(p))
		  	 continue;
	  acquire( p->lock);

	  for(t= p->threads; t < &p->threads[NTHREAD]; t++){
80104ec0:	83 45 f0 20          	addl   $0x20,-0x10(%ebp)
80104ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec7:	8b 40 74             	mov    0x74(%eax),%eax
80104eca:	05 00 02 00 00       	add    $0x200,%eax
80104ecf:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104ed2:	77 cc                	ja     80104ea0 <wakeup1+0x39>

		  if(t->state == SLEEPING && t->chan == chan)
			  t->state =  RUNNABLE;

	  }
	  release(p->lock);
80104ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed7:	8b 40 78             	mov    0x78(%eax),%eax
80104eda:	89 04 24             	mov    %eax,(%esp)
80104edd:	e8 bb 02 00 00       	call   8010519d <release>
{

  struct proc *p;

  struct kthread *t;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ee2:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104ee6:	81 7d f4 b4 e5 11 80 	cmpl   $0x8011e5b4,-0xc(%ebp)
80104eed:	72 87                	jb     80104e76 <wakeup1+0xf>

	  }
	  release(p->lock);

  }
}
80104eef:	c9                   	leave  
80104ef0:	c3                   	ret    

80104ef1 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ef1:	55                   	push   %ebp
80104ef2:	89 e5                	mov    %esp,%ebp
80104ef4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104ef7:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104efe:	e8 38 02 00 00       	call   8010513b <acquire>

  wakeup1(chan);
80104f03:	8b 45 08             	mov    0x8(%ebp),%eax
80104f06:	89 04 24             	mov    %eax,(%esp)
80104f09:	e8 59 ff ff ff       	call   80104e67 <wakeup1>

  release(&ptable.lock);
80104f0e:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104f15:	e8 83 02 00 00       	call   8010519d <release>

}
80104f1a:	c9                   	leave  
80104f1b:	c3                   	ret    

80104f1c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f1c:	55                   	push   %ebp
80104f1d:	89 e5                	mov    %esp,%ebp
80104f1f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f22:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104f29:	e8 0d 02 00 00       	call   8010513b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f2e:	c7 45 f4 b4 c6 11 80 	movl   $0x8011c6b4,-0xc(%ebp)
80104f35:	eb 74                	jmp    80104fab <kill+0x8f>
    if(p->pid == pid){
80104f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3a:	8b 40 10             	mov    0x10(%eax),%eax
80104f3d:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f40:	75 65                	jne    80104fa7 <kill+0x8b>
      p->killed = 1;
80104f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f45:	c7 40 1c 01 00 00 00 	movl   $0x1,0x1c(%eax)
      // Wake process from sleep if necessary.
      int i;
      for (i=0; i<NTHREAD; i++){
80104f4c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104f53:	eb 39                	jmp    80104f8e <kill+0x72>
    	  p->killed =1;
80104f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f58:	c7 40 1c 01 00 00 00 	movl   $0x1,0x1c(%eax)
    	  if(p->threads[i].state == SLEEPING)
80104f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f62:	8b 40 74             	mov    0x74(%eax),%eax
80104f65:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f68:	c1 e2 05             	shl    $0x5,%edx
80104f6b:	01 d0                	add    %edx,%eax
80104f6d:	8b 40 04             	mov    0x4(%eax),%eax
80104f70:	83 f8 02             	cmp    $0x2,%eax
80104f73:	75 15                	jne    80104f8a <kill+0x6e>
    		  	 p->threads[i].state =  RUNNABLE;
80104f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f78:	8b 40 74             	mov    0x74(%eax),%eax
80104f7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f7e:	c1 e2 05             	shl    $0x5,%edx
80104f81:	01 d0                	add    %edx,%eax
80104f83:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      int i;
      for (i=0; i<NTHREAD; i++){
80104f8a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104f8e:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104f92:	7e c1                	jle    80104f55 <kill+0x39>
    	  p->killed =1;
    	  if(p->threads[i].state == SLEEPING)
    		  	 p->threads[i].state =  RUNNABLE;
      }
      release(&ptable.lock);
80104f94:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104f9b:	e8 fd 01 00 00       	call   8010519d <release>
      return 0;
80104fa0:	b8 00 00 00 00       	mov    $0x0,%eax
80104fa5:	eb 1e                	jmp    80104fc5 <kill+0xa9>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fa7:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104fab:	81 7d f4 b4 e5 11 80 	cmpl   $0x8011e5b4,-0xc(%ebp)
80104fb2:	72 83                	jb     80104f37 <kill+0x1b>
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104fb4:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104fbb:	e8 dd 01 00 00       	call   8010519d <release>
  return -1;
80104fc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fc5:	c9                   	leave  
80104fc6:	c3                   	ret    

80104fc7 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104fc7:	55                   	push   %ebp
80104fc8:	89 e5                	mov    %esp,%ebp
80104fca:	83 ec 58             	sub    $0x58,%esp
  struct proc *p;
  struct kthread *t;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fcd:	c7 45 f0 b4 c6 11 80 	movl   $0x8011c6b4,-0x10(%ebp)
80104fd4:	e9 fc 00 00 00       	jmp    801050d5 <procdump+0x10e>
	  for (t=p->threads; t< &p->threads[NTHREAD]; t++ )
80104fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fdc:	8b 40 74             	mov    0x74(%eax),%eax
80104fdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104fe2:	e9 d6 00 00 00       	jmp    801050bd <procdump+0xf6>
	  {
		if(t->state == UNUSED)
80104fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104fea:	8b 40 04             	mov    0x4(%eax),%eax
80104fed:	85 c0                	test   %eax,%eax
80104fef:	75 05                	jne    80104ff6 <procdump+0x2f>
		  continue;
80104ff1:	e9 c3 00 00 00       	jmp    801050b9 <procdump+0xf2>
		if(t->state >= 0 && t->state < NELEM(states) && states[p->state])
80104ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ff9:	8b 40 04             	mov    0x4(%eax),%eax
80104ffc:	83 f8 05             	cmp    $0x5,%eax
80104fff:	77 23                	ja     80105024 <procdump+0x5d>
80105001:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105004:	8b 40 0c             	mov    0xc(%eax),%eax
80105007:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
8010500e:	85 c0                	test   %eax,%eax
80105010:	74 12                	je     80105024 <procdump+0x5d>
		  state = states[t->state];
80105012:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105015:	8b 40 04             	mov    0x4(%eax),%eax
80105018:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
8010501f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80105022:	eb 07                	jmp    8010502b <procdump+0x64>
		else
		  state = "???";
80105024:	c7 45 e8 4f 8d 10 80 	movl   $0x80108d4f,-0x18(%ebp)
		cprintf("%d %s %s", p->pid, state, p->name);
8010502b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010502e:	8d 50 64             	lea    0x64(%eax),%edx
80105031:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105034:	8b 40 10             	mov    0x10(%eax),%eax
80105037:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010503b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010503e:	89 54 24 08          	mov    %edx,0x8(%esp)
80105042:	89 44 24 04          	mov    %eax,0x4(%esp)
80105046:	c7 04 24 53 8d 10 80 	movl   $0x80108d53,(%esp)
8010504d:	e8 4e b3 ff ff       	call   801003a0 <cprintf>
		if(t->state == SLEEPING){
80105052:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105055:	8b 40 04             	mov    0x4(%eax),%eax
80105058:	83 f8 02             	cmp    $0x2,%eax
8010505b:	75 50                	jne    801050ad <procdump+0xe6>
		  getcallerpcs((uint*)t->context->ebp+2, pc);
8010505d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105060:	8b 40 14             	mov    0x14(%eax),%eax
80105063:	8b 40 0c             	mov    0xc(%eax),%eax
80105066:	83 c0 08             	add    $0x8,%eax
80105069:	8d 55 c0             	lea    -0x40(%ebp),%edx
8010506c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105070:	89 04 24             	mov    %eax,(%esp)
80105073:	e8 74 01 00 00       	call   801051ec <getcallerpcs>
		  for(i=0; i<10 && pc[i] != 0; i++)
80105078:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010507f:	eb 1b                	jmp    8010509c <procdump+0xd5>
			cprintf(" %p", pc[i]);
80105081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105084:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105088:	89 44 24 04          	mov    %eax,0x4(%esp)
8010508c:	c7 04 24 5c 8d 10 80 	movl   $0x80108d5c,(%esp)
80105093:	e8 08 b3 ff ff       	call   801003a0 <cprintf>
		else
		  state = "???";
		cprintf("%d %s %s", p->pid, state, p->name);
		if(t->state == SLEEPING){
		  getcallerpcs((uint*)t->context->ebp+2, pc);
		  for(i=0; i<10 && pc[i] != 0; i++)
80105098:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010509c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050a0:	7f 0b                	jg     801050ad <procdump+0xe6>
801050a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a5:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
801050a9:	85 c0                	test   %eax,%eax
801050ab:	75 d4                	jne    80105081 <procdump+0xba>
			cprintf(" %p", pc[i]);

		}
		cprintf("\n");
801050ad:	c7 04 24 60 8d 10 80 	movl   $0x80108d60,(%esp)
801050b4:	e8 e7 b2 ff ff       	call   801003a0 <cprintf>
  struct kthread *t;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
	  for (t=p->threads; t< &p->threads[NTHREAD]; t++ )
801050b9:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
801050bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050c0:	8b 40 74             	mov    0x74(%eax),%eax
801050c3:	05 00 02 00 00       	add    $0x200,%eax
801050c8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801050cb:	0f 87 16 ff ff ff    	ja     80104fe7 <procdump+0x20>
  struct proc *p;
  struct kthread *t;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050d1:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
801050d5:	81 7d f0 b4 e5 11 80 	cmpl   $0x8011e5b4,-0x10(%ebp)
801050dc:	0f 82 f7 fe ff ff    	jb     80104fd9 <procdump+0x12>

		}
		cprintf("\n");
  	  }
  }
}
801050e2:	c9                   	leave  
801050e3:	c3                   	ret    

801050e4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801050e4:	55                   	push   %ebp
801050e5:	89 e5                	mov    %esp,%ebp
801050e7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801050ea:	9c                   	pushf  
801050eb:	58                   	pop    %eax
801050ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801050ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050f2:	c9                   	leave  
801050f3:	c3                   	ret    

801050f4 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801050f4:	55                   	push   %ebp
801050f5:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801050f7:	fa                   	cli    
}
801050f8:	5d                   	pop    %ebp
801050f9:	c3                   	ret    

801050fa <sti>:

static inline void
sti(void)
{
801050fa:	55                   	push   %ebp
801050fb:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801050fd:	fb                   	sti    
}
801050fe:	5d                   	pop    %ebp
801050ff:	c3                   	ret    

80105100 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105100:	55                   	push   %ebp
80105101:	89 e5                	mov    %esp,%ebp
80105103:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105106:	8b 55 08             	mov    0x8(%ebp),%edx
80105109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010510f:	f0 87 02             	lock xchg %eax,(%edx)
80105112:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105115:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105118:	c9                   	leave  
80105119:	c3                   	ret    

8010511a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010511a:	55                   	push   %ebp
8010511b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010511d:	8b 45 08             	mov    0x8(%ebp),%eax
80105120:	8b 55 0c             	mov    0xc(%ebp),%edx
80105123:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105126:	8b 45 08             	mov    0x8(%ebp),%eax
80105129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010512f:	8b 45 08             	mov    0x8(%ebp),%eax
80105132:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105139:	5d                   	pop    %ebp
8010513a:	c3                   	ret    

8010513b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010513b:	55                   	push   %ebp
8010513c:	89 e5                	mov    %esp,%ebp
8010513e:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105141:	e8 49 01 00 00       	call   8010528f <pushcli>
  if(holding(lk))
80105146:	8b 45 08             	mov    0x8(%ebp),%eax
80105149:	89 04 24             	mov    %eax,(%esp)
8010514c:	e8 14 01 00 00       	call   80105265 <holding>
80105151:	85 c0                	test   %eax,%eax
80105153:	74 0c                	je     80105161 <acquire+0x26>
    panic("acquire");
80105155:	c7 04 24 8c 8d 10 80 	movl   $0x80108d8c,(%esp)
8010515c:	e8 d9 b3 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105161:	90                   	nop
80105162:	8b 45 08             	mov    0x8(%ebp),%eax
80105165:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010516c:	00 
8010516d:	89 04 24             	mov    %eax,(%esp)
80105170:	e8 8b ff ff ff       	call   80105100 <xchg>
80105175:	85 c0                	test   %eax,%eax
80105177:	75 e9                	jne    80105162 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105179:	8b 45 08             	mov    0x8(%ebp),%eax
8010517c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105183:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105186:	8b 45 08             	mov    0x8(%ebp),%eax
80105189:	83 c0 0c             	add    $0xc,%eax
8010518c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105190:	8d 45 08             	lea    0x8(%ebp),%eax
80105193:	89 04 24             	mov    %eax,(%esp)
80105196:	e8 51 00 00 00       	call   801051ec <getcallerpcs>
}
8010519b:	c9                   	leave  
8010519c:	c3                   	ret    

8010519d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010519d:	55                   	push   %ebp
8010519e:	89 e5                	mov    %esp,%ebp
801051a0:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801051a3:	8b 45 08             	mov    0x8(%ebp),%eax
801051a6:	89 04 24             	mov    %eax,(%esp)
801051a9:	e8 b7 00 00 00       	call   80105265 <holding>
801051ae:	85 c0                	test   %eax,%eax
801051b0:	75 0c                	jne    801051be <release+0x21>
    panic("release");
801051b2:	c7 04 24 94 8d 10 80 	movl   $0x80108d94,(%esp)
801051b9:	e8 7c b3 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
801051be:	8b 45 08             	mov    0x8(%ebp),%eax
801051c1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801051c8:	8b 45 08             	mov    0x8(%ebp),%eax
801051cb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801051d2:	8b 45 08             	mov    0x8(%ebp),%eax
801051d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801051dc:	00 
801051dd:	89 04 24             	mov    %eax,(%esp)
801051e0:	e8 1b ff ff ff       	call   80105100 <xchg>

  popcli();
801051e5:	e8 e9 00 00 00       	call   801052d3 <popcli>
}
801051ea:	c9                   	leave  
801051eb:	c3                   	ret    

801051ec <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801051ec:	55                   	push   %ebp
801051ed:	89 e5                	mov    %esp,%ebp
801051ef:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801051f2:	8b 45 08             	mov    0x8(%ebp),%eax
801051f5:	83 e8 08             	sub    $0x8,%eax
801051f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801051fb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105202:	eb 38                	jmp    8010523c <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105204:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105208:	74 38                	je     80105242 <getcallerpcs+0x56>
8010520a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105211:	76 2f                	jbe    80105242 <getcallerpcs+0x56>
80105213:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105217:	74 29                	je     80105242 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105219:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010521c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105223:	8b 45 0c             	mov    0xc(%ebp),%eax
80105226:	01 c2                	add    %eax,%edx
80105228:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010522b:	8b 40 04             	mov    0x4(%eax),%eax
8010522e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105230:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105233:	8b 00                	mov    (%eax),%eax
80105235:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105238:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010523c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105240:	7e c2                	jle    80105204 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105242:	eb 19                	jmp    8010525d <getcallerpcs+0x71>
    pcs[i] = 0;
80105244:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105247:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010524e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105251:	01 d0                	add    %edx,%eax
80105253:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105259:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010525d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105261:	7e e1                	jle    80105244 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105263:	c9                   	leave  
80105264:	c3                   	ret    

80105265 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105265:	55                   	push   %ebp
80105266:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105268:	8b 45 08             	mov    0x8(%ebp),%eax
8010526b:	8b 00                	mov    (%eax),%eax
8010526d:	85 c0                	test   %eax,%eax
8010526f:	74 17                	je     80105288 <holding+0x23>
80105271:	8b 45 08             	mov    0x8(%ebp),%eax
80105274:	8b 50 08             	mov    0x8(%eax),%edx
80105277:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010527d:	39 c2                	cmp    %eax,%edx
8010527f:	75 07                	jne    80105288 <holding+0x23>
80105281:	b8 01 00 00 00       	mov    $0x1,%eax
80105286:	eb 05                	jmp    8010528d <holding+0x28>
80105288:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010528d:	5d                   	pop    %ebp
8010528e:	c3                   	ret    

8010528f <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010528f:	55                   	push   %ebp
80105290:	89 e5                	mov    %esp,%ebp
80105292:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105295:	e8 4a fe ff ff       	call   801050e4 <readeflags>
8010529a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010529d:	e8 52 fe ff ff       	call   801050f4 <cli>
  if(cpu->ncli++ == 0)
801052a2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801052a9:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801052af:	8d 48 01             	lea    0x1(%eax),%ecx
801052b2:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801052b8:	85 c0                	test   %eax,%eax
801052ba:	75 15                	jne    801052d1 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801052bc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052c2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052c5:	81 e2 00 02 00 00    	and    $0x200,%edx
801052cb:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801052d1:	c9                   	leave  
801052d2:	c3                   	ret    

801052d3 <popcli>:

void
popcli(void)
{
801052d3:	55                   	push   %ebp
801052d4:	89 e5                	mov    %esp,%ebp
801052d6:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801052d9:	e8 06 fe ff ff       	call   801050e4 <readeflags>
801052de:	25 00 02 00 00       	and    $0x200,%eax
801052e3:	85 c0                	test   %eax,%eax
801052e5:	74 0c                	je     801052f3 <popcli+0x20>
    panic("popcli - interruptible");
801052e7:	c7 04 24 9c 8d 10 80 	movl   $0x80108d9c,(%esp)
801052ee:	e8 47 b2 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
801052f3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052f9:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801052ff:	83 ea 01             	sub    $0x1,%edx
80105302:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105308:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010530e:	85 c0                	test   %eax,%eax
80105310:	79 0c                	jns    8010531e <popcli+0x4b>
    panic("popcli");
80105312:	c7 04 24 b3 8d 10 80 	movl   $0x80108db3,(%esp)
80105319:	e8 1c b2 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010531e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105324:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010532a:	85 c0                	test   %eax,%eax
8010532c:	75 15                	jne    80105343 <popcli+0x70>
8010532e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105334:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010533a:	85 c0                	test   %eax,%eax
8010533c:	74 05                	je     80105343 <popcli+0x70>
    sti();
8010533e:	e8 b7 fd ff ff       	call   801050fa <sti>
}
80105343:	c9                   	leave  
80105344:	c3                   	ret    

80105345 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105345:	55                   	push   %ebp
80105346:	89 e5                	mov    %esp,%ebp
80105348:	57                   	push   %edi
80105349:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010534a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010534d:	8b 55 10             	mov    0x10(%ebp),%edx
80105350:	8b 45 0c             	mov    0xc(%ebp),%eax
80105353:	89 cb                	mov    %ecx,%ebx
80105355:	89 df                	mov    %ebx,%edi
80105357:	89 d1                	mov    %edx,%ecx
80105359:	fc                   	cld    
8010535a:	f3 aa                	rep stos %al,%es:(%edi)
8010535c:	89 ca                	mov    %ecx,%edx
8010535e:	89 fb                	mov    %edi,%ebx
80105360:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105363:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105366:	5b                   	pop    %ebx
80105367:	5f                   	pop    %edi
80105368:	5d                   	pop    %ebp
80105369:	c3                   	ret    

8010536a <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010536a:	55                   	push   %ebp
8010536b:	89 e5                	mov    %esp,%ebp
8010536d:	57                   	push   %edi
8010536e:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010536f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105372:	8b 55 10             	mov    0x10(%ebp),%edx
80105375:	8b 45 0c             	mov    0xc(%ebp),%eax
80105378:	89 cb                	mov    %ecx,%ebx
8010537a:	89 df                	mov    %ebx,%edi
8010537c:	89 d1                	mov    %edx,%ecx
8010537e:	fc                   	cld    
8010537f:	f3 ab                	rep stos %eax,%es:(%edi)
80105381:	89 ca                	mov    %ecx,%edx
80105383:	89 fb                	mov    %edi,%ebx
80105385:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105388:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010538b:	5b                   	pop    %ebx
8010538c:	5f                   	pop    %edi
8010538d:	5d                   	pop    %ebp
8010538e:	c3                   	ret    

8010538f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010538f:	55                   	push   %ebp
80105390:	89 e5                	mov    %esp,%ebp
80105392:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105395:	8b 45 08             	mov    0x8(%ebp),%eax
80105398:	83 e0 03             	and    $0x3,%eax
8010539b:	85 c0                	test   %eax,%eax
8010539d:	75 49                	jne    801053e8 <memset+0x59>
8010539f:	8b 45 10             	mov    0x10(%ebp),%eax
801053a2:	83 e0 03             	and    $0x3,%eax
801053a5:	85 c0                	test   %eax,%eax
801053a7:	75 3f                	jne    801053e8 <memset+0x59>
    c &= 0xFF;
801053a9:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801053b0:	8b 45 10             	mov    0x10(%ebp),%eax
801053b3:	c1 e8 02             	shr    $0x2,%eax
801053b6:	89 c2                	mov    %eax,%edx
801053b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801053bb:	c1 e0 18             	shl    $0x18,%eax
801053be:	89 c1                	mov    %eax,%ecx
801053c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c3:	c1 e0 10             	shl    $0x10,%eax
801053c6:	09 c1                	or     %eax,%ecx
801053c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801053cb:	c1 e0 08             	shl    $0x8,%eax
801053ce:	09 c8                	or     %ecx,%eax
801053d0:	0b 45 0c             	or     0xc(%ebp),%eax
801053d3:	89 54 24 08          	mov    %edx,0x8(%esp)
801053d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801053db:	8b 45 08             	mov    0x8(%ebp),%eax
801053de:	89 04 24             	mov    %eax,(%esp)
801053e1:	e8 84 ff ff ff       	call   8010536a <stosl>
801053e6:	eb 19                	jmp    80105401 <memset+0x72>
  } else
    stosb(dst, c, n);
801053e8:	8b 45 10             	mov    0x10(%ebp),%eax
801053eb:	89 44 24 08          	mov    %eax,0x8(%esp)
801053ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801053f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801053f6:	8b 45 08             	mov    0x8(%ebp),%eax
801053f9:	89 04 24             	mov    %eax,(%esp)
801053fc:	e8 44 ff ff ff       	call   80105345 <stosb>
  return dst;
80105401:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105404:	c9                   	leave  
80105405:	c3                   	ret    

80105406 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105406:	55                   	push   %ebp
80105407:	89 e5                	mov    %esp,%ebp
80105409:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010540c:	8b 45 08             	mov    0x8(%ebp),%eax
8010540f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105412:	8b 45 0c             	mov    0xc(%ebp),%eax
80105415:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105418:	eb 30                	jmp    8010544a <memcmp+0x44>
    if(*s1 != *s2)
8010541a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010541d:	0f b6 10             	movzbl (%eax),%edx
80105420:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105423:	0f b6 00             	movzbl (%eax),%eax
80105426:	38 c2                	cmp    %al,%dl
80105428:	74 18                	je     80105442 <memcmp+0x3c>
      return *s1 - *s2;
8010542a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010542d:	0f b6 00             	movzbl (%eax),%eax
80105430:	0f b6 d0             	movzbl %al,%edx
80105433:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105436:	0f b6 00             	movzbl (%eax),%eax
80105439:	0f b6 c0             	movzbl %al,%eax
8010543c:	29 c2                	sub    %eax,%edx
8010543e:	89 d0                	mov    %edx,%eax
80105440:	eb 1a                	jmp    8010545c <memcmp+0x56>
    s1++, s2++;
80105442:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105446:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010544a:	8b 45 10             	mov    0x10(%ebp),%eax
8010544d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105450:	89 55 10             	mov    %edx,0x10(%ebp)
80105453:	85 c0                	test   %eax,%eax
80105455:	75 c3                	jne    8010541a <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105457:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010545c:	c9                   	leave  
8010545d:	c3                   	ret    

8010545e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010545e:	55                   	push   %ebp
8010545f:	89 e5                	mov    %esp,%ebp
80105461:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105464:	8b 45 0c             	mov    0xc(%ebp),%eax
80105467:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010546a:	8b 45 08             	mov    0x8(%ebp),%eax
8010546d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105470:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105473:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105476:	73 3d                	jae    801054b5 <memmove+0x57>
80105478:	8b 45 10             	mov    0x10(%ebp),%eax
8010547b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010547e:	01 d0                	add    %edx,%eax
80105480:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105483:	76 30                	jbe    801054b5 <memmove+0x57>
    s += n;
80105485:	8b 45 10             	mov    0x10(%ebp),%eax
80105488:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010548b:	8b 45 10             	mov    0x10(%ebp),%eax
8010548e:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105491:	eb 13                	jmp    801054a6 <memmove+0x48>
      *--d = *--s;
80105493:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105497:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010549b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010549e:	0f b6 10             	movzbl (%eax),%edx
801054a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054a4:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801054a6:	8b 45 10             	mov    0x10(%ebp),%eax
801054a9:	8d 50 ff             	lea    -0x1(%eax),%edx
801054ac:	89 55 10             	mov    %edx,0x10(%ebp)
801054af:	85 c0                	test   %eax,%eax
801054b1:	75 e0                	jne    80105493 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801054b3:	eb 26                	jmp    801054db <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801054b5:	eb 17                	jmp    801054ce <memmove+0x70>
      *d++ = *s++;
801054b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054ba:	8d 50 01             	lea    0x1(%eax),%edx
801054bd:	89 55 f8             	mov    %edx,-0x8(%ebp)
801054c0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054c3:	8d 4a 01             	lea    0x1(%edx),%ecx
801054c6:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801054c9:	0f b6 12             	movzbl (%edx),%edx
801054cc:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801054ce:	8b 45 10             	mov    0x10(%ebp),%eax
801054d1:	8d 50 ff             	lea    -0x1(%eax),%edx
801054d4:	89 55 10             	mov    %edx,0x10(%ebp)
801054d7:	85 c0                	test   %eax,%eax
801054d9:	75 dc                	jne    801054b7 <memmove+0x59>
      *d++ = *s++;

  return dst;
801054db:	8b 45 08             	mov    0x8(%ebp),%eax
}
801054de:	c9                   	leave  
801054df:	c3                   	ret    

801054e0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801054e0:	55                   	push   %ebp
801054e1:	89 e5                	mov    %esp,%ebp
801054e3:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801054e6:	8b 45 10             	mov    0x10(%ebp),%eax
801054e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801054ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801054f4:	8b 45 08             	mov    0x8(%ebp),%eax
801054f7:	89 04 24             	mov    %eax,(%esp)
801054fa:	e8 5f ff ff ff       	call   8010545e <memmove>
}
801054ff:	c9                   	leave  
80105500:	c3                   	ret    

80105501 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105501:	55                   	push   %ebp
80105502:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105504:	eb 0c                	jmp    80105512 <strncmp+0x11>
    n--, p++, q++;
80105506:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010550a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010550e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105512:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105516:	74 1a                	je     80105532 <strncmp+0x31>
80105518:	8b 45 08             	mov    0x8(%ebp),%eax
8010551b:	0f b6 00             	movzbl (%eax),%eax
8010551e:	84 c0                	test   %al,%al
80105520:	74 10                	je     80105532 <strncmp+0x31>
80105522:	8b 45 08             	mov    0x8(%ebp),%eax
80105525:	0f b6 10             	movzbl (%eax),%edx
80105528:	8b 45 0c             	mov    0xc(%ebp),%eax
8010552b:	0f b6 00             	movzbl (%eax),%eax
8010552e:	38 c2                	cmp    %al,%dl
80105530:	74 d4                	je     80105506 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105532:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105536:	75 07                	jne    8010553f <strncmp+0x3e>
    return 0;
80105538:	b8 00 00 00 00       	mov    $0x0,%eax
8010553d:	eb 16                	jmp    80105555 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010553f:	8b 45 08             	mov    0x8(%ebp),%eax
80105542:	0f b6 00             	movzbl (%eax),%eax
80105545:	0f b6 d0             	movzbl %al,%edx
80105548:	8b 45 0c             	mov    0xc(%ebp),%eax
8010554b:	0f b6 00             	movzbl (%eax),%eax
8010554e:	0f b6 c0             	movzbl %al,%eax
80105551:	29 c2                	sub    %eax,%edx
80105553:	89 d0                	mov    %edx,%eax
}
80105555:	5d                   	pop    %ebp
80105556:	c3                   	ret    

80105557 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105557:	55                   	push   %ebp
80105558:	89 e5                	mov    %esp,%ebp
8010555a:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010555d:	8b 45 08             	mov    0x8(%ebp),%eax
80105560:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105563:	90                   	nop
80105564:	8b 45 10             	mov    0x10(%ebp),%eax
80105567:	8d 50 ff             	lea    -0x1(%eax),%edx
8010556a:	89 55 10             	mov    %edx,0x10(%ebp)
8010556d:	85 c0                	test   %eax,%eax
8010556f:	7e 1e                	jle    8010558f <strncpy+0x38>
80105571:	8b 45 08             	mov    0x8(%ebp),%eax
80105574:	8d 50 01             	lea    0x1(%eax),%edx
80105577:	89 55 08             	mov    %edx,0x8(%ebp)
8010557a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010557d:	8d 4a 01             	lea    0x1(%edx),%ecx
80105580:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105583:	0f b6 12             	movzbl (%edx),%edx
80105586:	88 10                	mov    %dl,(%eax)
80105588:	0f b6 00             	movzbl (%eax),%eax
8010558b:	84 c0                	test   %al,%al
8010558d:	75 d5                	jne    80105564 <strncpy+0xd>
    ;
  while(n-- > 0)
8010558f:	eb 0c                	jmp    8010559d <strncpy+0x46>
    *s++ = 0;
80105591:	8b 45 08             	mov    0x8(%ebp),%eax
80105594:	8d 50 01             	lea    0x1(%eax),%edx
80105597:	89 55 08             	mov    %edx,0x8(%ebp)
8010559a:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010559d:	8b 45 10             	mov    0x10(%ebp),%eax
801055a0:	8d 50 ff             	lea    -0x1(%eax),%edx
801055a3:	89 55 10             	mov    %edx,0x10(%ebp)
801055a6:	85 c0                	test   %eax,%eax
801055a8:	7f e7                	jg     80105591 <strncpy+0x3a>
    *s++ = 0;
  return os;
801055aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055ad:	c9                   	leave  
801055ae:	c3                   	ret    

801055af <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801055af:	55                   	push   %ebp
801055b0:	89 e5                	mov    %esp,%ebp
801055b2:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801055b5:	8b 45 08             	mov    0x8(%ebp),%eax
801055b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801055bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055bf:	7f 05                	jg     801055c6 <safestrcpy+0x17>
    return os;
801055c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c4:	eb 31                	jmp    801055f7 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801055c6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ce:	7e 1e                	jle    801055ee <safestrcpy+0x3f>
801055d0:	8b 45 08             	mov    0x8(%ebp),%eax
801055d3:	8d 50 01             	lea    0x1(%eax),%edx
801055d6:	89 55 08             	mov    %edx,0x8(%ebp)
801055d9:	8b 55 0c             	mov    0xc(%ebp),%edx
801055dc:	8d 4a 01             	lea    0x1(%edx),%ecx
801055df:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801055e2:	0f b6 12             	movzbl (%edx),%edx
801055e5:	88 10                	mov    %dl,(%eax)
801055e7:	0f b6 00             	movzbl (%eax),%eax
801055ea:	84 c0                	test   %al,%al
801055ec:	75 d8                	jne    801055c6 <safestrcpy+0x17>
    ;
  *s = 0;
801055ee:	8b 45 08             	mov    0x8(%ebp),%eax
801055f1:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801055f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055f7:	c9                   	leave  
801055f8:	c3                   	ret    

801055f9 <strlen>:

int
strlen(const char *s)
{
801055f9:	55                   	push   %ebp
801055fa:	89 e5                	mov    %esp,%ebp
801055fc:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801055ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105606:	eb 04                	jmp    8010560c <strlen+0x13>
80105608:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010560c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010560f:	8b 45 08             	mov    0x8(%ebp),%eax
80105612:	01 d0                	add    %edx,%eax
80105614:	0f b6 00             	movzbl (%eax),%eax
80105617:	84 c0                	test   %al,%al
80105619:	75 ed                	jne    80105608 <strlen+0xf>
    ;
  return n;
8010561b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010561e:	c9                   	leave  
8010561f:	c3                   	ret    

80105620 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105620:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105624:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105628:	55                   	push   %ebp
  pushl %ebx
80105629:	53                   	push   %ebx
  pushl %esi
8010562a:	56                   	push   %esi
  pushl %edi
8010562b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010562c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010562e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105630:	5f                   	pop    %edi
  popl %esi
80105631:	5e                   	pop    %esi
  popl %ebx
80105632:	5b                   	pop    %ebx
  popl %ebp
80105633:	5d                   	pop    %ebp
  ret
80105634:	c3                   	ret    

80105635 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105635:	55                   	push   %ebp
80105636:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105638:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010563e:	8b 00                	mov    (%eax),%eax
80105640:	3b 45 08             	cmp    0x8(%ebp),%eax
80105643:	76 12                	jbe    80105657 <fetchint+0x22>
80105645:	8b 45 08             	mov    0x8(%ebp),%eax
80105648:	8d 50 04             	lea    0x4(%eax),%edx
8010564b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105651:	8b 00                	mov    (%eax),%eax
80105653:	39 c2                	cmp    %eax,%edx
80105655:	76 07                	jbe    8010565e <fetchint+0x29>
    return -1;
80105657:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010565c:	eb 0f                	jmp    8010566d <fetchint+0x38>
  *ip = *(int*)(addr);
8010565e:	8b 45 08             	mov    0x8(%ebp),%eax
80105661:	8b 10                	mov    (%eax),%edx
80105663:	8b 45 0c             	mov    0xc(%ebp),%eax
80105666:	89 10                	mov    %edx,(%eax)
  return 0;
80105668:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010566d:	5d                   	pop    %ebp
8010566e:	c3                   	ret    

8010566f <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010566f:	55                   	push   %ebp
80105670:	89 e5                	mov    %esp,%ebp
80105672:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105675:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010567b:	8b 00                	mov    (%eax),%eax
8010567d:	3b 45 08             	cmp    0x8(%ebp),%eax
80105680:	77 07                	ja     80105689 <fetchstr+0x1a>
    return -1;
80105682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105687:	eb 46                	jmp    801056cf <fetchstr+0x60>
  *pp = (char*)addr;
80105689:	8b 55 08             	mov    0x8(%ebp),%edx
8010568c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010568f:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105691:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105697:	8b 00                	mov    (%eax),%eax
80105699:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010569c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010569f:	8b 00                	mov    (%eax),%eax
801056a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
801056a4:	eb 1c                	jmp    801056c2 <fetchstr+0x53>
    if(*s == 0)
801056a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056a9:	0f b6 00             	movzbl (%eax),%eax
801056ac:	84 c0                	test   %al,%al
801056ae:	75 0e                	jne    801056be <fetchstr+0x4f>
      return s - *pp;
801056b0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b6:	8b 00                	mov    (%eax),%eax
801056b8:	29 c2                	sub    %eax,%edx
801056ba:	89 d0                	mov    %edx,%eax
801056bc:	eb 11                	jmp    801056cf <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801056be:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056c5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056c8:	72 dc                	jb     801056a6 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801056ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056cf:	c9                   	leave  
801056d0:	c3                   	ret    

801056d1 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801056d1:	55                   	push   %ebp
801056d2:	89 e5                	mov    %esp,%ebp
801056d4:	83 ec 08             	sub    $0x8,%esp
  return fetchint(thread->tf->esp + 4 + 4*n, ip);
801056d7:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801056dd:	8b 40 10             	mov    0x10(%eax),%eax
801056e0:	8b 50 44             	mov    0x44(%eax),%edx
801056e3:	8b 45 08             	mov    0x8(%ebp),%eax
801056e6:	c1 e0 02             	shl    $0x2,%eax
801056e9:	01 d0                	add    %edx,%eax
801056eb:	8d 50 04             	lea    0x4(%eax),%edx
801056ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801056f5:	89 14 24             	mov    %edx,(%esp)
801056f8:	e8 38 ff ff ff       	call   80105635 <fetchint>
}
801056fd:	c9                   	leave  
801056fe:	c3                   	ret    

801056ff <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801056ff:	55                   	push   %ebp
80105700:	89 e5                	mov    %esp,%ebp
80105702:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105705:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105708:	89 44 24 04          	mov    %eax,0x4(%esp)
8010570c:	8b 45 08             	mov    0x8(%ebp),%eax
8010570f:	89 04 24             	mov    %eax,(%esp)
80105712:	e8 ba ff ff ff       	call   801056d1 <argint>
80105717:	85 c0                	test   %eax,%eax
80105719:	79 07                	jns    80105722 <argptr+0x23>
    return -1;
8010571b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105720:	eb 3d                	jmp    8010575f <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105722:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105725:	89 c2                	mov    %eax,%edx
80105727:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010572d:	8b 00                	mov    (%eax),%eax
8010572f:	39 c2                	cmp    %eax,%edx
80105731:	73 16                	jae    80105749 <argptr+0x4a>
80105733:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105736:	89 c2                	mov    %eax,%edx
80105738:	8b 45 10             	mov    0x10(%ebp),%eax
8010573b:	01 c2                	add    %eax,%edx
8010573d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105743:	8b 00                	mov    (%eax),%eax
80105745:	39 c2                	cmp    %eax,%edx
80105747:	76 07                	jbe    80105750 <argptr+0x51>
    return -1;
80105749:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010574e:	eb 0f                	jmp    8010575f <argptr+0x60>
  *pp = (char*)i;
80105750:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105753:	89 c2                	mov    %eax,%edx
80105755:	8b 45 0c             	mov    0xc(%ebp),%eax
80105758:	89 10                	mov    %edx,(%eax)
  return 0;
8010575a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010575f:	c9                   	leave  
80105760:	c3                   	ret    

80105761 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105761:	55                   	push   %ebp
80105762:	89 e5                	mov    %esp,%ebp
80105764:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105767:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010576a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010576e:	8b 45 08             	mov    0x8(%ebp),%eax
80105771:	89 04 24             	mov    %eax,(%esp)
80105774:	e8 58 ff ff ff       	call   801056d1 <argint>
80105779:	85 c0                	test   %eax,%eax
8010577b:	79 07                	jns    80105784 <argstr+0x23>
    return -1;
8010577d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105782:	eb 12                	jmp    80105796 <argstr+0x35>
  return fetchstr(addr, pp);
80105784:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105787:	8b 55 0c             	mov    0xc(%ebp),%edx
8010578a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010578e:	89 04 24             	mov    %eax,(%esp)
80105791:	e8 d9 fe ff ff       	call   8010566f <fetchstr>
}
80105796:	c9                   	leave  
80105797:	c3                   	ret    

80105798 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105798:	55                   	push   %ebp
80105799:	89 e5                	mov    %esp,%ebp
8010579b:	53                   	push   %ebx
8010579c:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = thread->tf->eax;
8010579f:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801057a5:	8b 40 10             	mov    0x10(%eax),%eax
801057a8:	8b 40 1c             	mov    0x1c(%eax),%eax
801057ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801057ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057b2:	7e 30                	jle    801057e4 <syscall+0x4c>
801057b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b7:	83 f8 15             	cmp    $0x15,%eax
801057ba:	77 28                	ja     801057e4 <syscall+0x4c>
801057bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057bf:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801057c6:	85 c0                	test   %eax,%eax
801057c8:	74 1a                	je     801057e4 <syscall+0x4c>
	  thread->tf->eax = syscalls[num]();
801057ca:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801057d0:	8b 58 10             	mov    0x10(%eax),%ebx
801057d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d6:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801057dd:	ff d0                	call   *%eax
801057df:	89 43 1c             	mov    %eax,0x1c(%ebx)
801057e2:	eb 3d                	jmp    80105821 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801057e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057ea:	8d 48 64             	lea    0x64(%eax),%ecx
801057ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = thread->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
	  thread->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801057f3:	8b 40 10             	mov    0x10(%eax),%eax
801057f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
801057fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105801:	89 44 24 04          	mov    %eax,0x4(%esp)
80105805:	c7 04 24 ba 8d 10 80 	movl   $0x80108dba,(%esp)
8010580c:	e8 8f ab ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    thread->tf->eax = -1;
80105811:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80105817:	8b 40 10             	mov    0x10(%eax),%eax
8010581a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105821:	83 c4 24             	add    $0x24,%esp
80105824:	5b                   	pop    %ebx
80105825:	5d                   	pop    %ebp
80105826:	c3                   	ret    

80105827 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105827:	55                   	push   %ebp
80105828:	89 e5                	mov    %esp,%ebp
8010582a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010582d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105830:	89 44 24 04          	mov    %eax,0x4(%esp)
80105834:	8b 45 08             	mov    0x8(%ebp),%eax
80105837:	89 04 24             	mov    %eax,(%esp)
8010583a:	e8 92 fe ff ff       	call   801056d1 <argint>
8010583f:	85 c0                	test   %eax,%eax
80105841:	79 07                	jns    8010584a <argfd+0x23>
    return -1;
80105843:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105848:	eb 4f                	jmp    80105899 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010584a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584d:	85 c0                	test   %eax,%eax
8010584f:	78 20                	js     80105871 <argfd+0x4a>
80105851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105854:	83 f8 0f             	cmp    $0xf,%eax
80105857:	7f 18                	jg     80105871 <argfd+0x4a>
80105859:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010585f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105862:	83 c2 08             	add    $0x8,%edx
80105865:	8b 04 90             	mov    (%eax,%edx,4),%eax
80105868:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010586b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010586f:	75 07                	jne    80105878 <argfd+0x51>
    return -1;
80105871:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105876:	eb 21                	jmp    80105899 <argfd+0x72>
  if(pfd)
80105878:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010587c:	74 08                	je     80105886 <argfd+0x5f>
    *pfd = fd;
8010587e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105881:	8b 45 0c             	mov    0xc(%ebp),%eax
80105884:	89 10                	mov    %edx,(%eax)
  if(pf)
80105886:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010588a:	74 08                	je     80105894 <argfd+0x6d>
    *pf = f;
8010588c:	8b 45 10             	mov    0x10(%ebp),%eax
8010588f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105892:	89 10                	mov    %edx,(%eax)
  return 0;
80105894:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105899:	c9                   	leave  
8010589a:	c3                   	ret    

8010589b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010589b:	55                   	push   %ebp
8010589c:	89 e5                	mov    %esp,%ebp
8010589e:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801058a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801058a8:	eb 2e                	jmp    801058d8 <fdalloc+0x3d>
    if(proc->ofile[fd] == 0){
801058aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058b0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058b3:	83 c2 08             	add    $0x8,%edx
801058b6:	8b 04 90             	mov    (%eax,%edx,4),%eax
801058b9:	85 c0                	test   %eax,%eax
801058bb:	75 17                	jne    801058d4 <fdalloc+0x39>
      proc->ofile[fd] = f;
801058bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058c6:	8d 4a 08             	lea    0x8(%edx),%ecx
801058c9:	8b 55 08             	mov    0x8(%ebp),%edx
801058cc:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      return fd;
801058cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058d2:	eb 0f                	jmp    801058e3 <fdalloc+0x48>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801058d4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801058d8:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801058dc:	7e cc                	jle    801058aa <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801058de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058e3:	c9                   	leave  
801058e4:	c3                   	ret    

801058e5 <sys_dup>:

int
sys_dup(void)
{
801058e5:	55                   	push   %ebp
801058e6:	89 e5                	mov    %esp,%ebp
801058e8:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801058eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058ee:	89 44 24 08          	mov    %eax,0x8(%esp)
801058f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058f9:	00 
801058fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105901:	e8 21 ff ff ff       	call   80105827 <argfd>
80105906:	85 c0                	test   %eax,%eax
80105908:	79 07                	jns    80105911 <sys_dup+0x2c>
    return -1;
8010590a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010590f:	eb 29                	jmp    8010593a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105911:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105914:	89 04 24             	mov    %eax,(%esp)
80105917:	e8 7f ff ff ff       	call   8010589b <fdalloc>
8010591c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010591f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105923:	79 07                	jns    8010592c <sys_dup+0x47>
    return -1;
80105925:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592a:	eb 0e                	jmp    8010593a <sys_dup+0x55>
  filedup(f);
8010592c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592f:	89 04 24             	mov    %eax,(%esp)
80105932:	e8 4f b6 ff ff       	call   80100f86 <filedup>
  return fd;
80105937:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010593a:	c9                   	leave  
8010593b:	c3                   	ret    

8010593c <sys_read>:

int
sys_read(void)
{
8010593c:	55                   	push   %ebp
8010593d:	89 e5                	mov    %esp,%ebp
8010593f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105942:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105945:	89 44 24 08          	mov    %eax,0x8(%esp)
80105949:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105950:	00 
80105951:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105958:	e8 ca fe ff ff       	call   80105827 <argfd>
8010595d:	85 c0                	test   %eax,%eax
8010595f:	78 35                	js     80105996 <sys_read+0x5a>
80105961:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105964:	89 44 24 04          	mov    %eax,0x4(%esp)
80105968:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010596f:	e8 5d fd ff ff       	call   801056d1 <argint>
80105974:	85 c0                	test   %eax,%eax
80105976:	78 1e                	js     80105996 <sys_read+0x5a>
80105978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010597f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105982:	89 44 24 04          	mov    %eax,0x4(%esp)
80105986:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010598d:	e8 6d fd ff ff       	call   801056ff <argptr>
80105992:	85 c0                	test   %eax,%eax
80105994:	79 07                	jns    8010599d <sys_read+0x61>
    return -1;
80105996:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599b:	eb 19                	jmp    801059b6 <sys_read+0x7a>
  return fileread(f, p, n);
8010599d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059aa:	89 54 24 04          	mov    %edx,0x4(%esp)
801059ae:	89 04 24             	mov    %eax,(%esp)
801059b1:	e8 3d b7 ff ff       	call   801010f3 <fileread>
}
801059b6:	c9                   	leave  
801059b7:	c3                   	ret    

801059b8 <sys_write>:

int
sys_write(void)
{
801059b8:	55                   	push   %ebp
801059b9:	89 e5                	mov    %esp,%ebp
801059bb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059be:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059c1:	89 44 24 08          	mov    %eax,0x8(%esp)
801059c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059cc:	00 
801059cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059d4:	e8 4e fe ff ff       	call   80105827 <argfd>
801059d9:	85 c0                	test   %eax,%eax
801059db:	78 35                	js     80105a12 <sys_write+0x5a>
801059dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801059e4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801059eb:	e8 e1 fc ff ff       	call   801056d1 <argint>
801059f0:	85 c0                	test   %eax,%eax
801059f2:	78 1e                	js     80105a12 <sys_write+0x5a>
801059f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f7:	89 44 24 08          	mov    %eax,0x8(%esp)
801059fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a09:	e8 f1 fc ff ff       	call   801056ff <argptr>
80105a0e:	85 c0                	test   %eax,%eax
80105a10:	79 07                	jns    80105a19 <sys_write+0x61>
    return -1;
80105a12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a17:	eb 19                	jmp    80105a32 <sys_write+0x7a>
  return filewrite(f, p, n);
80105a19:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a1c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a22:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a26:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a2a:	89 04 24             	mov    %eax,(%esp)
80105a2d:	e8 7d b7 ff ff       	call   801011af <filewrite>
}
80105a32:	c9                   	leave  
80105a33:	c3                   	ret    

80105a34 <sys_close>:

int
sys_close(void)
{
80105a34:	55                   	push   %ebp
80105a35:	89 e5                	mov    %esp,%ebp
80105a37:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105a3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a3d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a41:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a44:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a4f:	e8 d3 fd ff ff       	call   80105827 <argfd>
80105a54:	85 c0                	test   %eax,%eax
80105a56:	79 07                	jns    80105a5f <sys_close+0x2b>
    return -1;
80105a58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a5d:	eb 23                	jmp    80105a82 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105a5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a68:	83 c2 08             	add    $0x8,%edx
80105a6b:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
  fileclose(f);
80105a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a75:	89 04 24             	mov    %eax,(%esp)
80105a78:	e8 51 b5 ff ff       	call   80100fce <fileclose>
  return 0;
80105a7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a82:	c9                   	leave  
80105a83:	c3                   	ret    

80105a84 <sys_fstat>:

int
sys_fstat(void)
{
80105a84:	55                   	push   %ebp
80105a85:	89 e5                	mov    %esp,%ebp
80105a87:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a8d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a98:	00 
80105a99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105aa0:	e8 82 fd ff ff       	call   80105827 <argfd>
80105aa5:	85 c0                	test   %eax,%eax
80105aa7:	78 1f                	js     80105ac8 <sys_fstat+0x44>
80105aa9:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105ab0:	00 
80105ab1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ab8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105abf:	e8 3b fc ff ff       	call   801056ff <argptr>
80105ac4:	85 c0                	test   %eax,%eax
80105ac6:	79 07                	jns    80105acf <sys_fstat+0x4b>
    return -1;
80105ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105acd:	eb 12                	jmp    80105ae1 <sys_fstat+0x5d>
  return filestat(f, st);
80105acf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad5:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ad9:	89 04 24             	mov    %eax,(%esp)
80105adc:	e8 c3 b5 ff ff       	call   801010a4 <filestat>
}
80105ae1:	c9                   	leave  
80105ae2:	c3                   	ret    

80105ae3 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ae3:	55                   	push   %ebp
80105ae4:	89 e5                	mov    %esp,%ebp
80105ae6:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105ae9:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105aec:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105af7:	e8 65 fc ff ff       	call   80105761 <argstr>
80105afc:	85 c0                	test   %eax,%eax
80105afe:	78 17                	js     80105b17 <sys_link+0x34>
80105b00:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b03:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b07:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b0e:	e8 4e fc ff ff       	call   80105761 <argstr>
80105b13:	85 c0                	test   %eax,%eax
80105b15:	79 0a                	jns    80105b21 <sys_link+0x3e>
    return -1;
80105b17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1c:	e9 42 01 00 00       	jmp    80105c63 <sys_link+0x180>

  begin_op();
80105b21:	e8 ea d8 ff ff       	call   80103410 <begin_op>
  if((ip = namei(old)) == 0){
80105b26:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105b29:	89 04 24             	mov    %eax,(%esp)
80105b2c:	e8 d5 c8 ff ff       	call   80102406 <namei>
80105b31:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b34:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b38:	75 0f                	jne    80105b49 <sys_link+0x66>
    end_op();
80105b3a:	e8 55 d9 ff ff       	call   80103494 <end_op>
    return -1;
80105b3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b44:	e9 1a 01 00 00       	jmp    80105c63 <sys_link+0x180>
  }

  ilock(ip);
80105b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b4c:	89 04 24             	mov    %eax,(%esp)
80105b4f:	e8 07 bd ff ff       	call   8010185b <ilock>
  if(ip->type == T_DIR){
80105b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b57:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b5b:	66 83 f8 01          	cmp    $0x1,%ax
80105b5f:	75 1a                	jne    80105b7b <sys_link+0x98>
    iunlockput(ip);
80105b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b64:	89 04 24             	mov    %eax,(%esp)
80105b67:	e8 73 bf ff ff       	call   80101adf <iunlockput>
    end_op();
80105b6c:	e8 23 d9 ff ff       	call   80103494 <end_op>
    return -1;
80105b71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b76:	e9 e8 00 00 00       	jmp    80105c63 <sys_link+0x180>
  }

  ip->nlink++;
80105b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b7e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b82:	8d 50 01             	lea    0x1(%eax),%edx
80105b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b88:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8f:	89 04 24             	mov    %eax,(%esp)
80105b92:	e8 08 bb ff ff       	call   8010169f <iupdate>
  iunlock(ip);
80105b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9a:	89 04 24             	mov    %eax,(%esp)
80105b9d:	e8 07 be ff ff       	call   801019a9 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105ba2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105ba5:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105ba8:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bac:	89 04 24             	mov    %eax,(%esp)
80105baf:	e8 74 c8 ff ff       	call   80102428 <nameiparent>
80105bb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bb7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bbb:	75 02                	jne    80105bbf <sys_link+0xdc>
    goto bad;
80105bbd:	eb 68                	jmp    80105c27 <sys_link+0x144>
  ilock(dp);
80105bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc2:	89 04 24             	mov    %eax,(%esp)
80105bc5:	e8 91 bc ff ff       	call   8010185b <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bcd:	8b 10                	mov    (%eax),%edx
80105bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd2:	8b 00                	mov    (%eax),%eax
80105bd4:	39 c2                	cmp    %eax,%edx
80105bd6:	75 20                	jne    80105bf8 <sys_link+0x115>
80105bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bdb:	8b 40 04             	mov    0x4(%eax),%eax
80105bde:	89 44 24 08          	mov    %eax,0x8(%esp)
80105be2:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105be5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bec:	89 04 24             	mov    %eax,(%esp)
80105bef:	e8 52 c5 ff ff       	call   80102146 <dirlink>
80105bf4:	85 c0                	test   %eax,%eax
80105bf6:	79 0d                	jns    80105c05 <sys_link+0x122>
    iunlockput(dp);
80105bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfb:	89 04 24             	mov    %eax,(%esp)
80105bfe:	e8 dc be ff ff       	call   80101adf <iunlockput>
    goto bad;
80105c03:	eb 22                	jmp    80105c27 <sys_link+0x144>
  }
  iunlockput(dp);
80105c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c08:	89 04 24             	mov    %eax,(%esp)
80105c0b:	e8 cf be ff ff       	call   80101adf <iunlockput>
  iput(ip);
80105c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c13:	89 04 24             	mov    %eax,(%esp)
80105c16:	e8 f3 bd ff ff       	call   80101a0e <iput>

  end_op();
80105c1b:	e8 74 d8 ff ff       	call   80103494 <end_op>

  return 0;
80105c20:	b8 00 00 00 00       	mov    $0x0,%eax
80105c25:	eb 3c                	jmp    80105c63 <sys_link+0x180>

bad:
  ilock(ip);
80105c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2a:	89 04 24             	mov    %eax,(%esp)
80105c2d:	e8 29 bc ff ff       	call   8010185b <ilock>
  ip->nlink--;
80105c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c35:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c39:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c46:	89 04 24             	mov    %eax,(%esp)
80105c49:	e8 51 ba ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
80105c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c51:	89 04 24             	mov    %eax,(%esp)
80105c54:	e8 86 be ff ff       	call   80101adf <iunlockput>
  end_op();
80105c59:	e8 36 d8 ff ff       	call   80103494 <end_op>
  return -1;
80105c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c63:	c9                   	leave  
80105c64:	c3                   	ret    

80105c65 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c65:	55                   	push   %ebp
80105c66:	89 e5                	mov    %esp,%ebp
80105c68:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c6b:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c72:	eb 4b                	jmp    80105cbf <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c77:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105c7e:	00 
80105c7f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c83:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c86:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80105c8d:	89 04 24             	mov    %eax,(%esp)
80105c90:	e8 d3 c0 ff ff       	call   80101d68 <readi>
80105c95:	83 f8 10             	cmp    $0x10,%eax
80105c98:	74 0c                	je     80105ca6 <isdirempty+0x41>
      panic("isdirempty: readi");
80105c9a:	c7 04 24 d6 8d 10 80 	movl   $0x80108dd6,(%esp)
80105ca1:	e8 94 a8 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105ca6:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105caa:	66 85 c0             	test   %ax,%ax
80105cad:	74 07                	je     80105cb6 <isdirempty+0x51>
      return 0;
80105caf:	b8 00 00 00 00       	mov    $0x0,%eax
80105cb4:	eb 1b                	jmp    80105cd1 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb9:	83 c0 10             	add    $0x10,%eax
80105cbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc5:	8b 40 18             	mov    0x18(%eax),%eax
80105cc8:	39 c2                	cmp    %eax,%edx
80105cca:	72 a8                	jb     80105c74 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105ccc:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105cd1:	c9                   	leave  
80105cd2:	c3                   	ret    

80105cd3 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105cd3:	55                   	push   %ebp
80105cd4:	89 e5                	mov    %esp,%ebp
80105cd6:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105cd9:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ce0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ce7:	e8 75 fa ff ff       	call   80105761 <argstr>
80105cec:	85 c0                	test   %eax,%eax
80105cee:	79 0a                	jns    80105cfa <sys_unlink+0x27>
    return -1;
80105cf0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf5:	e9 af 01 00 00       	jmp    80105ea9 <sys_unlink+0x1d6>

  begin_op();
80105cfa:	e8 11 d7 ff ff       	call   80103410 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105cff:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d02:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d05:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d09:	89 04 24             	mov    %eax,(%esp)
80105d0c:	e8 17 c7 ff ff       	call   80102428 <nameiparent>
80105d11:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d18:	75 0f                	jne    80105d29 <sys_unlink+0x56>
    end_op();
80105d1a:	e8 75 d7 ff ff       	call   80103494 <end_op>
    return -1;
80105d1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d24:	e9 80 01 00 00       	jmp    80105ea9 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2c:	89 04 24             	mov    %eax,(%esp)
80105d2f:	e8 27 bb ff ff       	call   8010185b <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105d34:	c7 44 24 04 e8 8d 10 	movl   $0x80108de8,0x4(%esp)
80105d3b:	80 
80105d3c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d3f:	89 04 24             	mov    %eax,(%esp)
80105d42:	e8 14 c3 ff ff       	call   8010205b <namecmp>
80105d47:	85 c0                	test   %eax,%eax
80105d49:	0f 84 45 01 00 00    	je     80105e94 <sys_unlink+0x1c1>
80105d4f:	c7 44 24 04 ea 8d 10 	movl   $0x80108dea,0x4(%esp)
80105d56:	80 
80105d57:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d5a:	89 04 24             	mov    %eax,(%esp)
80105d5d:	e8 f9 c2 ff ff       	call   8010205b <namecmp>
80105d62:	85 c0                	test   %eax,%eax
80105d64:	0f 84 2a 01 00 00    	je     80105e94 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d6a:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d6d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d71:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d74:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7b:	89 04 24             	mov    %eax,(%esp)
80105d7e:	e8 fa c2 ff ff       	call   8010207d <dirlookup>
80105d83:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d86:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d8a:	75 05                	jne    80105d91 <sys_unlink+0xbe>
    goto bad;
80105d8c:	e9 03 01 00 00       	jmp    80105e94 <sys_unlink+0x1c1>
  ilock(ip);
80105d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d94:	89 04 24             	mov    %eax,(%esp)
80105d97:	e8 bf ba ff ff       	call   8010185b <ilock>

  if(ip->nlink < 1)
80105d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d9f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105da3:	66 85 c0             	test   %ax,%ax
80105da6:	7f 0c                	jg     80105db4 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105da8:	c7 04 24 ed 8d 10 80 	movl   $0x80108ded,(%esp)
80105daf:	e8 86 a7 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105dbb:	66 83 f8 01          	cmp    $0x1,%ax
80105dbf:	75 1f                	jne    80105de0 <sys_unlink+0x10d>
80105dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc4:	89 04 24             	mov    %eax,(%esp)
80105dc7:	e8 99 fe ff ff       	call   80105c65 <isdirempty>
80105dcc:	85 c0                	test   %eax,%eax
80105dce:	75 10                	jne    80105de0 <sys_unlink+0x10d>
    iunlockput(ip);
80105dd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd3:	89 04 24             	mov    %eax,(%esp)
80105dd6:	e8 04 bd ff ff       	call   80101adf <iunlockput>
    goto bad;
80105ddb:	e9 b4 00 00 00       	jmp    80105e94 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105de0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105de7:	00 
80105de8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105def:	00 
80105df0:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105df3:	89 04 24             	mov    %eax,(%esp)
80105df6:	e8 94 f5 ff ff       	call   8010538f <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105dfb:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105dfe:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e05:	00 
80105e06:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e0a:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e14:	89 04 24             	mov    %eax,(%esp)
80105e17:	e8 b0 c0 ff ff       	call   80101ecc <writei>
80105e1c:	83 f8 10             	cmp    $0x10,%eax
80105e1f:	74 0c                	je     80105e2d <sys_unlink+0x15a>
    panic("unlink: writei");
80105e21:	c7 04 24 ff 8d 10 80 	movl   $0x80108dff,(%esp)
80105e28:	e8 0d a7 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e30:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e34:	66 83 f8 01          	cmp    $0x1,%ax
80105e38:	75 1c                	jne    80105e56 <sys_unlink+0x183>
    dp->nlink--;
80105e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e41:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e47:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4e:	89 04 24             	mov    %eax,(%esp)
80105e51:	e8 49 b8 ff ff       	call   8010169f <iupdate>
  }
  iunlockput(dp);
80105e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e59:	89 04 24             	mov    %eax,(%esp)
80105e5c:	e8 7e bc ff ff       	call   80101adf <iunlockput>

  ip->nlink--;
80105e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e64:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e68:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6e:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e75:	89 04 24             	mov    %eax,(%esp)
80105e78:	e8 22 b8 ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
80105e7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e80:	89 04 24             	mov    %eax,(%esp)
80105e83:	e8 57 bc ff ff       	call   80101adf <iunlockput>

  end_op();
80105e88:	e8 07 d6 ff ff       	call   80103494 <end_op>

  return 0;
80105e8d:	b8 00 00 00 00       	mov    $0x0,%eax
80105e92:	eb 15                	jmp    80105ea9 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e97:	89 04 24             	mov    %eax,(%esp)
80105e9a:	e8 40 bc ff ff       	call   80101adf <iunlockput>
  end_op();
80105e9f:	e8 f0 d5 ff ff       	call   80103494 <end_op>
  return -1;
80105ea4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ea9:	c9                   	leave  
80105eaa:	c3                   	ret    

80105eab <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105eab:	55                   	push   %ebp
80105eac:	89 e5                	mov    %esp,%ebp
80105eae:	83 ec 48             	sub    $0x48,%esp
80105eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105eb4:	8b 55 10             	mov    0x10(%ebp),%edx
80105eb7:	8b 45 14             	mov    0x14(%ebp),%eax
80105eba:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105ebe:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105ec2:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105ec6:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80105ed0:	89 04 24             	mov    %eax,(%esp)
80105ed3:	e8 50 c5 ff ff       	call   80102428 <nameiparent>
80105ed8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105edb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105edf:	75 0a                	jne    80105eeb <create+0x40>
    return 0;
80105ee1:	b8 00 00 00 00       	mov    $0x0,%eax
80105ee6:	e9 7e 01 00 00       	jmp    80106069 <create+0x1be>
  ilock(dp);
80105eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eee:	89 04 24             	mov    %eax,(%esp)
80105ef1:	e8 65 b9 ff ff       	call   8010185b <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105ef6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ef9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105efd:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f00:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f07:	89 04 24             	mov    %eax,(%esp)
80105f0a:	e8 6e c1 ff ff       	call   8010207d <dirlookup>
80105f0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f16:	74 47                	je     80105f5f <create+0xb4>
    iunlockput(dp);
80105f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1b:	89 04 24             	mov    %eax,(%esp)
80105f1e:	e8 bc bb ff ff       	call   80101adf <iunlockput>
    ilock(ip);
80105f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f26:	89 04 24             	mov    %eax,(%esp)
80105f29:	e8 2d b9 ff ff       	call   8010185b <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105f2e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105f33:	75 15                	jne    80105f4a <create+0x9f>
80105f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f38:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f3c:	66 83 f8 02          	cmp    $0x2,%ax
80105f40:	75 08                	jne    80105f4a <create+0x9f>
      return ip;
80105f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f45:	e9 1f 01 00 00       	jmp    80106069 <create+0x1be>
    iunlockput(ip);
80105f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f4d:	89 04 24             	mov    %eax,(%esp)
80105f50:	e8 8a bb ff ff       	call   80101adf <iunlockput>
    return 0;
80105f55:	b8 00 00 00 00       	mov    $0x0,%eax
80105f5a:	e9 0a 01 00 00       	jmp    80106069 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f5f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f66:	8b 00                	mov    (%eax),%eax
80105f68:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f6c:	89 04 24             	mov    %eax,(%esp)
80105f6f:	e8 4c b6 ff ff       	call   801015c0 <ialloc>
80105f74:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f7b:	75 0c                	jne    80105f89 <create+0xde>
    panic("create: ialloc");
80105f7d:	c7 04 24 0e 8e 10 80 	movl   $0x80108e0e,(%esp)
80105f84:	e8 b1 a5 ff ff       	call   8010053a <panic>

  ilock(ip);
80105f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f8c:	89 04 24             	mov    %eax,(%esp)
80105f8f:	e8 c7 b8 ff ff       	call   8010185b <ilock>
  ip->major = major;
80105f94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f97:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f9b:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa2:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105fa6:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fad:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb6:	89 04 24             	mov    %eax,(%esp)
80105fb9:	e8 e1 b6 ff ff       	call   8010169f <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105fbe:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105fc3:	75 6a                	jne    8010602f <create+0x184>
    dp->nlink++;  // for ".."
80105fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105fcc:	8d 50 01             	lea    0x1(%eax),%edx
80105fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd2:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd9:	89 04 24             	mov    %eax,(%esp)
80105fdc:	e8 be b6 ff ff       	call   8010169f <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe4:	8b 40 04             	mov    0x4(%eax),%eax
80105fe7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105feb:	c7 44 24 04 e8 8d 10 	movl   $0x80108de8,0x4(%esp)
80105ff2:	80 
80105ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff6:	89 04 24             	mov    %eax,(%esp)
80105ff9:	e8 48 c1 ff ff       	call   80102146 <dirlink>
80105ffe:	85 c0                	test   %eax,%eax
80106000:	78 21                	js     80106023 <create+0x178>
80106002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106005:	8b 40 04             	mov    0x4(%eax),%eax
80106008:	89 44 24 08          	mov    %eax,0x8(%esp)
8010600c:	c7 44 24 04 ea 8d 10 	movl   $0x80108dea,0x4(%esp)
80106013:	80 
80106014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106017:	89 04 24             	mov    %eax,(%esp)
8010601a:	e8 27 c1 ff ff       	call   80102146 <dirlink>
8010601f:	85 c0                	test   %eax,%eax
80106021:	79 0c                	jns    8010602f <create+0x184>
      panic("create dots");
80106023:	c7 04 24 1d 8e 10 80 	movl   $0x80108e1d,(%esp)
8010602a:	e8 0b a5 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010602f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106032:	8b 40 04             	mov    0x4(%eax),%eax
80106035:	89 44 24 08          	mov    %eax,0x8(%esp)
80106039:	8d 45 de             	lea    -0x22(%ebp),%eax
8010603c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106043:	89 04 24             	mov    %eax,(%esp)
80106046:	e8 fb c0 ff ff       	call   80102146 <dirlink>
8010604b:	85 c0                	test   %eax,%eax
8010604d:	79 0c                	jns    8010605b <create+0x1b0>
    panic("create: dirlink");
8010604f:	c7 04 24 29 8e 10 80 	movl   $0x80108e29,(%esp)
80106056:	e8 df a4 ff ff       	call   8010053a <panic>

  iunlockput(dp);
8010605b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605e:	89 04 24             	mov    %eax,(%esp)
80106061:	e8 79 ba ff ff       	call   80101adf <iunlockput>

  return ip;
80106066:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106069:	c9                   	leave  
8010606a:	c3                   	ret    

8010606b <sys_open>:

int
sys_open(void)
{
8010606b:	55                   	push   %ebp
8010606c:	89 e5                	mov    %esp,%ebp
8010606e:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106071:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106074:	89 44 24 04          	mov    %eax,0x4(%esp)
80106078:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010607f:	e8 dd f6 ff ff       	call   80105761 <argstr>
80106084:	85 c0                	test   %eax,%eax
80106086:	78 17                	js     8010609f <sys_open+0x34>
80106088:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010608b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010608f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106096:	e8 36 f6 ff ff       	call   801056d1 <argint>
8010609b:	85 c0                	test   %eax,%eax
8010609d:	79 0a                	jns    801060a9 <sys_open+0x3e>
    return -1;
8010609f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a4:	e9 5c 01 00 00       	jmp    80106205 <sys_open+0x19a>

  begin_op();
801060a9:	e8 62 d3 ff ff       	call   80103410 <begin_op>

  if(omode & O_CREATE){
801060ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060b1:	25 00 02 00 00       	and    $0x200,%eax
801060b6:	85 c0                	test   %eax,%eax
801060b8:	74 3b                	je     801060f5 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801060ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801060c4:	00 
801060c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801060cc:	00 
801060cd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801060d4:	00 
801060d5:	89 04 24             	mov    %eax,(%esp)
801060d8:	e8 ce fd ff ff       	call   80105eab <create>
801060dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801060e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060e4:	75 6b                	jne    80106151 <sys_open+0xe6>
      end_op();
801060e6:	e8 a9 d3 ff ff       	call   80103494 <end_op>
      return -1;
801060eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f0:	e9 10 01 00 00       	jmp    80106205 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
801060f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060f8:	89 04 24             	mov    %eax,(%esp)
801060fb:	e8 06 c3 ff ff       	call   80102406 <namei>
80106100:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106103:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106107:	75 0f                	jne    80106118 <sys_open+0xad>
      end_op();
80106109:	e8 86 d3 ff ff       	call   80103494 <end_op>
      return -1;
8010610e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106113:	e9 ed 00 00 00       	jmp    80106205 <sys_open+0x19a>
    }
    ilock(ip);
80106118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010611b:	89 04 24             	mov    %eax,(%esp)
8010611e:	e8 38 b7 ff ff       	call   8010185b <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106126:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010612a:	66 83 f8 01          	cmp    $0x1,%ax
8010612e:	75 21                	jne    80106151 <sys_open+0xe6>
80106130:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106133:	85 c0                	test   %eax,%eax
80106135:	74 1a                	je     80106151 <sys_open+0xe6>
      iunlockput(ip);
80106137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010613a:	89 04 24             	mov    %eax,(%esp)
8010613d:	e8 9d b9 ff ff       	call   80101adf <iunlockput>
      end_op();
80106142:	e8 4d d3 ff ff       	call   80103494 <end_op>
      return -1;
80106147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614c:	e9 b4 00 00 00       	jmp    80106205 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106151:	e8 d0 ad ff ff       	call   80100f26 <filealloc>
80106156:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106159:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010615d:	74 14                	je     80106173 <sys_open+0x108>
8010615f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106162:	89 04 24             	mov    %eax,(%esp)
80106165:	e8 31 f7 ff ff       	call   8010589b <fdalloc>
8010616a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010616d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106171:	79 28                	jns    8010619b <sys_open+0x130>
    if(f)
80106173:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106177:	74 0b                	je     80106184 <sys_open+0x119>
      fileclose(f);
80106179:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617c:	89 04 24             	mov    %eax,(%esp)
8010617f:	e8 4a ae ff ff       	call   80100fce <fileclose>
    iunlockput(ip);
80106184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106187:	89 04 24             	mov    %eax,(%esp)
8010618a:	e8 50 b9 ff ff       	call   80101adf <iunlockput>
    end_op();
8010618f:	e8 00 d3 ff ff       	call   80103494 <end_op>
    return -1;
80106194:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106199:	eb 6a                	jmp    80106205 <sys_open+0x19a>
  }
  iunlock(ip);
8010619b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619e:	89 04 24             	mov    %eax,(%esp)
801061a1:	e8 03 b8 ff ff       	call   801019a9 <iunlock>
  end_op();
801061a6:	e8 e9 d2 ff ff       	call   80103494 <end_op>

  f->type = FD_INODE;
801061ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ae:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801061b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061ba:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801061bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801061c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ca:	83 e0 01             	and    $0x1,%eax
801061cd:	85 c0                	test   %eax,%eax
801061cf:	0f 94 c0             	sete   %al
801061d2:	89 c2                	mov    %eax,%edx
801061d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d7:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801061da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061dd:	83 e0 01             	and    $0x1,%eax
801061e0:	85 c0                	test   %eax,%eax
801061e2:	75 0a                	jne    801061ee <sys_open+0x183>
801061e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061e7:	83 e0 02             	and    $0x2,%eax
801061ea:	85 c0                	test   %eax,%eax
801061ec:	74 07                	je     801061f5 <sys_open+0x18a>
801061ee:	b8 01 00 00 00       	mov    $0x1,%eax
801061f3:	eb 05                	jmp    801061fa <sys_open+0x18f>
801061f5:	b8 00 00 00 00       	mov    $0x0,%eax
801061fa:	89 c2                	mov    %eax,%edx
801061fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ff:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106202:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106205:	c9                   	leave  
80106206:	c3                   	ret    

80106207 <sys_mkdir>:

int
sys_mkdir(void)
{
80106207:	55                   	push   %ebp
80106208:	89 e5                	mov    %esp,%ebp
8010620a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010620d:	e8 fe d1 ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106212:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106215:	89 44 24 04          	mov    %eax,0x4(%esp)
80106219:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106220:	e8 3c f5 ff ff       	call   80105761 <argstr>
80106225:	85 c0                	test   %eax,%eax
80106227:	78 2c                	js     80106255 <sys_mkdir+0x4e>
80106229:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106233:	00 
80106234:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010623b:	00 
8010623c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106243:	00 
80106244:	89 04 24             	mov    %eax,(%esp)
80106247:	e8 5f fc ff ff       	call   80105eab <create>
8010624c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010624f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106253:	75 0c                	jne    80106261 <sys_mkdir+0x5a>
    end_op();
80106255:	e8 3a d2 ff ff       	call   80103494 <end_op>
    return -1;
8010625a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010625f:	eb 15                	jmp    80106276 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106264:	89 04 24             	mov    %eax,(%esp)
80106267:	e8 73 b8 ff ff       	call   80101adf <iunlockput>
  end_op();
8010626c:	e8 23 d2 ff ff       	call   80103494 <end_op>
  return 0;
80106271:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106276:	c9                   	leave  
80106277:	c3                   	ret    

80106278 <sys_mknod>:

int
sys_mknod(void)
{
80106278:	55                   	push   %ebp
80106279:	89 e5                	mov    %esp,%ebp
8010627b:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010627e:	e8 8d d1 ff ff       	call   80103410 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106283:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106286:	89 44 24 04          	mov    %eax,0x4(%esp)
8010628a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106291:	e8 cb f4 ff ff       	call   80105761 <argstr>
80106296:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106299:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010629d:	78 5e                	js     801062fd <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010629f:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801062a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062ad:	e8 1f f4 ff ff       	call   801056d1 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801062b2:	85 c0                	test   %eax,%eax
801062b4:	78 47                	js     801062fd <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801062b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801062bd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801062c4:	e8 08 f4 ff ff       	call   801056d1 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801062c9:	85 c0                	test   %eax,%eax
801062cb:	78 30                	js     801062fd <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801062cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062d0:	0f bf c8             	movswl %ax,%ecx
801062d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062d6:	0f bf d0             	movswl %ax,%edx
801062d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801062dc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801062e0:	89 54 24 08          	mov    %edx,0x8(%esp)
801062e4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801062eb:	00 
801062ec:	89 04 24             	mov    %eax,(%esp)
801062ef:	e8 b7 fb ff ff       	call   80105eab <create>
801062f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062fb:	75 0c                	jne    80106309 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801062fd:	e8 92 d1 ff ff       	call   80103494 <end_op>
    return -1;
80106302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106307:	eb 15                	jmp    8010631e <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106309:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010630c:	89 04 24             	mov    %eax,(%esp)
8010630f:	e8 cb b7 ff ff       	call   80101adf <iunlockput>
  end_op();
80106314:	e8 7b d1 ff ff       	call   80103494 <end_op>
  return 0;
80106319:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010631e:	c9                   	leave  
8010631f:	c3                   	ret    

80106320 <sys_chdir>:

int
sys_chdir(void)
{
80106320:	55                   	push   %ebp
80106321:	89 e5                	mov    %esp,%ebp
80106323:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106326:	e8 e5 d0 ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010632b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010632e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106332:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106339:	e8 23 f4 ff ff       	call   80105761 <argstr>
8010633e:	85 c0                	test   %eax,%eax
80106340:	78 14                	js     80106356 <sys_chdir+0x36>
80106342:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106345:	89 04 24             	mov    %eax,(%esp)
80106348:	e8 b9 c0 ff ff       	call   80102406 <namei>
8010634d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106350:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106354:	75 0c                	jne    80106362 <sys_chdir+0x42>
    end_op();
80106356:	e8 39 d1 ff ff       	call   80103494 <end_op>
    return -1;
8010635b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106360:	eb 61                	jmp    801063c3 <sys_chdir+0xa3>
  }
  ilock(ip);
80106362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106365:	89 04 24             	mov    %eax,(%esp)
80106368:	e8 ee b4 ff ff       	call   8010185b <ilock>
  if(ip->type != T_DIR){
8010636d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106370:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106374:	66 83 f8 01          	cmp    $0x1,%ax
80106378:	74 17                	je     80106391 <sys_chdir+0x71>
    iunlockput(ip);
8010637a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637d:	89 04 24             	mov    %eax,(%esp)
80106380:	e8 5a b7 ff ff       	call   80101adf <iunlockput>
    end_op();
80106385:	e8 0a d1 ff ff       	call   80103494 <end_op>
    return -1;
8010638a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010638f:	eb 32                	jmp    801063c3 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106394:	89 04 24             	mov    %eax,(%esp)
80106397:	e8 0d b6 ff ff       	call   801019a9 <iunlock>
  iput(proc->cwd);
8010639c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063a2:	8b 40 60             	mov    0x60(%eax),%eax
801063a5:	89 04 24             	mov    %eax,(%esp)
801063a8:	e8 61 b6 ff ff       	call   80101a0e <iput>
  end_op();
801063ad:	e8 e2 d0 ff ff       	call   80103494 <end_op>
  proc->cwd = ip;
801063b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063bb:	89 50 60             	mov    %edx,0x60(%eax)
  return 0;
801063be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063c3:	c9                   	leave  
801063c4:	c3                   	ret    

801063c5 <sys_exec>:

int
sys_exec(void)
{
801063c5:	55                   	push   %ebp
801063c6:	89 e5                	mov    %esp,%ebp
801063c8:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801063ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801063d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063dc:	e8 80 f3 ff ff       	call   80105761 <argstr>
801063e1:	85 c0                	test   %eax,%eax
801063e3:	78 1a                	js     801063ff <sys_exec+0x3a>
801063e5:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801063eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801063ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801063f6:	e8 d6 f2 ff ff       	call   801056d1 <argint>
801063fb:	85 c0                	test   %eax,%eax
801063fd:	79 0a                	jns    80106409 <sys_exec+0x44>
    return -1;
801063ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106404:	e9 c8 00 00 00       	jmp    801064d1 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
80106409:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106410:	00 
80106411:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106418:	00 
80106419:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010641f:	89 04 24             	mov    %eax,(%esp)
80106422:	e8 68 ef ff ff       	call   8010538f <memset>
  for(i=0;; i++){
80106427:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010642e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106431:	83 f8 1f             	cmp    $0x1f,%eax
80106434:	76 0a                	jbe    80106440 <sys_exec+0x7b>
      return -1;
80106436:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643b:	e9 91 00 00 00       	jmp    801064d1 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106443:	c1 e0 02             	shl    $0x2,%eax
80106446:	89 c2                	mov    %eax,%edx
80106448:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010644e:	01 c2                	add    %eax,%edx
80106450:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106456:	89 44 24 04          	mov    %eax,0x4(%esp)
8010645a:	89 14 24             	mov    %edx,(%esp)
8010645d:	e8 d3 f1 ff ff       	call   80105635 <fetchint>
80106462:	85 c0                	test   %eax,%eax
80106464:	79 07                	jns    8010646d <sys_exec+0xa8>
      return -1;
80106466:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010646b:	eb 64                	jmp    801064d1 <sys_exec+0x10c>
    if(uarg == 0){
8010646d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106473:	85 c0                	test   %eax,%eax
80106475:	75 26                	jne    8010649d <sys_exec+0xd8>
      argv[i] = 0;
80106477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647a:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106481:	00 00 00 00 
      break;
80106485:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106486:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106489:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010648f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106493:	89 04 24             	mov    %eax,(%esp)
80106496:	e8 54 a6 ff ff       	call   80100aef <exec>
8010649b:	eb 34                	jmp    801064d1 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010649d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064a6:	c1 e2 02             	shl    $0x2,%edx
801064a9:	01 c2                	add    %eax,%edx
801064ab:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801064b1:	89 54 24 04          	mov    %edx,0x4(%esp)
801064b5:	89 04 24             	mov    %eax,(%esp)
801064b8:	e8 b2 f1 ff ff       	call   8010566f <fetchstr>
801064bd:	85 c0                	test   %eax,%eax
801064bf:	79 07                	jns    801064c8 <sys_exec+0x103>
      return -1;
801064c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c6:	eb 09                	jmp    801064d1 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801064c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801064cc:	e9 5d ff ff ff       	jmp    8010642e <sys_exec+0x69>
  return exec(path, argv);
}
801064d1:	c9                   	leave  
801064d2:	c3                   	ret    

801064d3 <sys_pipe>:

int
sys_pipe(void)
{
801064d3:	55                   	push   %ebp
801064d4:	89 e5                	mov    %esp,%ebp
801064d6:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801064d9:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801064e0:	00 
801064e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801064e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064ef:	e8 0b f2 ff ff       	call   801056ff <argptr>
801064f4:	85 c0                	test   %eax,%eax
801064f6:	79 0a                	jns    80106502 <sys_pipe+0x2f>
    return -1;
801064f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064fd:	e9 9a 00 00 00       	jmp    8010659c <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106502:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106505:	89 44 24 04          	mov    %eax,0x4(%esp)
80106509:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010650c:	89 04 24             	mov    %eax,(%esp)
8010650f:	e8 1f da ff ff       	call   80103f33 <pipealloc>
80106514:	85 c0                	test   %eax,%eax
80106516:	79 07                	jns    8010651f <sys_pipe+0x4c>
    return -1;
80106518:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651d:	eb 7d                	jmp    8010659c <sys_pipe+0xc9>
  fd0 = -1;
8010651f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106526:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106529:	89 04 24             	mov    %eax,(%esp)
8010652c:	e8 6a f3 ff ff       	call   8010589b <fdalloc>
80106531:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106534:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106538:	78 14                	js     8010654e <sys_pipe+0x7b>
8010653a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010653d:	89 04 24             	mov    %eax,(%esp)
80106540:	e8 56 f3 ff ff       	call   8010589b <fdalloc>
80106545:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106548:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010654c:	79 36                	jns    80106584 <sys_pipe+0xb1>
    if(fd0 >= 0)
8010654e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106552:	78 13                	js     80106567 <sys_pipe+0x94>
      proc->ofile[fd0] = 0;
80106554:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010655a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010655d:	83 c2 08             	add    $0x8,%edx
80106560:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
    fileclose(rf);
80106567:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010656a:	89 04 24             	mov    %eax,(%esp)
8010656d:	e8 5c aa ff ff       	call   80100fce <fileclose>
    fileclose(wf);
80106572:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106575:	89 04 24             	mov    %eax,(%esp)
80106578:	e8 51 aa ff ff       	call   80100fce <fileclose>
    return -1;
8010657d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106582:	eb 18                	jmp    8010659c <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106584:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106587:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010658a:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010658c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010658f:	8d 50 04             	lea    0x4(%eax),%edx
80106592:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106595:	89 02                	mov    %eax,(%edx)
  return 0;
80106597:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010659c:	c9                   	leave  
8010659d:	c3                   	ret    

8010659e <sys_fork>:
#include "proc.h"
#include "kthread.h"

int
sys_fork(void)
{
8010659e:	55                   	push   %ebp
8010659f:	89 e5                	mov    %esp,%ebp
801065a1:	83 ec 08             	sub    $0x8,%esp
  return fork();
801065a4:	e8 65 e1 ff ff       	call   8010470e <fork>
}
801065a9:	c9                   	leave  
801065aa:	c3                   	ret    

801065ab <sys_exit>:

int
sys_exit(void)
{
801065ab:	55                   	push   %ebp
801065ac:	89 e5                	mov    %esp,%ebp
801065ae:	83 ec 08             	sub    $0x8,%esp
  exit();
801065b1:	e8 57 e3 ff ff       	call   8010490d <exit>
  return 0;  // not reached
801065b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065bb:	c9                   	leave  
801065bc:	c3                   	ret    

801065bd <sys_wait>:

int
sys_wait(void)
{
801065bd:	55                   	push   %ebp
801065be:	89 e5                	mov    %esp,%ebp
801065c0:	83 ec 08             	sub    $0x8,%esp
  return wait();
801065c3:	e8 be e4 ff ff       	call   80104a86 <wait>
}
801065c8:	c9                   	leave  
801065c9:	c3                   	ret    

801065ca <sys_kill>:

int
sys_kill(void)
{
801065ca:	55                   	push   %ebp
801065cb:	89 e5                	mov    %esp,%ebp
801065cd:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801065d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801065d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065de:	e8 ee f0 ff ff       	call   801056d1 <argint>
801065e3:	85 c0                	test   %eax,%eax
801065e5:	79 07                	jns    801065ee <sys_kill+0x24>
    return -1;
801065e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ec:	eb 0b                	jmp    801065f9 <sys_kill+0x2f>
  return kill(pid);
801065ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f1:	89 04 24             	mov    %eax,(%esp)
801065f4:	e8 23 e9 ff ff       	call   80104f1c <kill>
}
801065f9:	c9                   	leave  
801065fa:	c3                   	ret    

801065fb <sys_getpid>:

int
sys_getpid(void)
{
801065fb:	55                   	push   %ebp
801065fc:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801065fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106604:	8b 40 10             	mov    0x10(%eax),%eax
}
80106607:	5d                   	pop    %ebp
80106608:	c3                   	ret    

80106609 <sys_sbrk>:

int
sys_sbrk(void)
{
80106609:	55                   	push   %ebp
8010660a:	89 e5                	mov    %esp,%ebp
8010660c:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010660f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106612:	89 44 24 04          	mov    %eax,0x4(%esp)
80106616:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010661d:	e8 af f0 ff ff       	call   801056d1 <argint>
80106622:	85 c0                	test   %eax,%eax
80106624:	79 07                	jns    8010662d <sys_sbrk+0x24>
    return -1;
80106626:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010662b:	eb 24                	jmp    80106651 <sys_sbrk+0x48>
  addr = proc->sz;
8010662d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106633:	8b 00                	mov    (%eax),%eax
80106635:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if( growproc(n) < 0)
80106638:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010663b:	89 04 24             	mov    %eax,(%esp)
8010663e:	e8 e2 df ff ff       	call   80104625 <growproc>
80106643:	85 c0                	test   %eax,%eax
80106645:	79 07                	jns    8010664e <sys_sbrk+0x45>
    return -1;
80106647:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010664c:	eb 03                	jmp    80106651 <sys_sbrk+0x48>
  return addr;
8010664e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106651:	c9                   	leave  
80106652:	c3                   	ret    

80106653 <sys_sleep>:

int
sys_sleep(void)
{
80106653:	55                   	push   %ebp
80106654:	89 e5                	mov    %esp,%ebp
80106656:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106659:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010665c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106660:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106667:	e8 65 f0 ff ff       	call   801056d1 <argint>
8010666c:	85 c0                	test   %eax,%eax
8010666e:	79 07                	jns    80106677 <sys_sleep+0x24>
    return -1;
80106670:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106675:	eb 6c                	jmp    801066e3 <sys_sleep+0x90>
  acquire(&tickslock);
80106677:	c7 04 24 c0 e5 11 80 	movl   $0x8011e5c0,(%esp)
8010667e:	e8 b8 ea ff ff       	call   8010513b <acquire>
  ticks0 = ticks;
80106683:	a1 00 ee 11 80       	mov    0x8011ee00,%eax
80106688:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010668b:	eb 34                	jmp    801066c1 <sys_sleep+0x6e>
    if(proc->killed){
8010668d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106693:	8b 40 1c             	mov    0x1c(%eax),%eax
80106696:	85 c0                	test   %eax,%eax
80106698:	74 13                	je     801066ad <sys_sleep+0x5a>
      release(&tickslock);
8010669a:	c7 04 24 c0 e5 11 80 	movl   $0x8011e5c0,(%esp)
801066a1:	e8 f7 ea ff ff       	call   8010519d <release>
      return -1;
801066a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ab:	eb 36                	jmp    801066e3 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801066ad:	c7 44 24 04 c0 e5 11 	movl   $0x8011e5c0,0x4(%esp)
801066b4:	80 
801066b5:	c7 04 24 00 ee 11 80 	movl   $0x8011ee00,(%esp)
801066bc:	e8 e9 e6 ff ff       	call   80104daa <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801066c1:	a1 00 ee 11 80       	mov    0x8011ee00,%eax
801066c6:	2b 45 f4             	sub    -0xc(%ebp),%eax
801066c9:	89 c2                	mov    %eax,%edx
801066cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066ce:	39 c2                	cmp    %eax,%edx
801066d0:	72 bb                	jb     8010668d <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801066d2:	c7 04 24 c0 e5 11 80 	movl   $0x8011e5c0,(%esp)
801066d9:	e8 bf ea ff ff       	call   8010519d <release>
  return 0;
801066de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066e3:	c9                   	leave  
801066e4:	c3                   	ret    

801066e5 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801066e5:	55                   	push   %ebp
801066e6:	89 e5                	mov    %esp,%ebp
801066e8:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801066eb:	c7 04 24 c0 e5 11 80 	movl   $0x8011e5c0,(%esp)
801066f2:	e8 44 ea ff ff       	call   8010513b <acquire>
  xticks = ticks;
801066f7:	a1 00 ee 11 80       	mov    0x8011ee00,%eax
801066fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801066ff:	c7 04 24 c0 e5 11 80 	movl   $0x8011e5c0,(%esp)
80106706:	e8 92 ea ff ff       	call   8010519d <release>
  return xticks;
8010670b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010670e:	c9                   	leave  
8010670f:	c3                   	ret    

80106710 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106710:	55                   	push   %ebp
80106711:	89 e5                	mov    %esp,%ebp
80106713:	83 ec 08             	sub    $0x8,%esp
80106716:	8b 55 08             	mov    0x8(%ebp),%edx
80106719:	8b 45 0c             	mov    0xc(%ebp),%eax
8010671c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106720:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106723:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106727:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010672b:	ee                   	out    %al,(%dx)
}
8010672c:	c9                   	leave  
8010672d:	c3                   	ret    

8010672e <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010672e:	55                   	push   %ebp
8010672f:	89 e5                	mov    %esp,%ebp
80106731:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106734:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010673b:	00 
8010673c:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106743:	e8 c8 ff ff ff       	call   80106710 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106748:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
8010674f:	00 
80106750:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106757:	e8 b4 ff ff ff       	call   80106710 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
8010675c:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106763:	00 
80106764:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010676b:	e8 a0 ff ff ff       	call   80106710 <outb>
  picenable(IRQ_TIMER);
80106770:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106777:	e8 4a d6 ff ff       	call   80103dc6 <picenable>
}
8010677c:	c9                   	leave  
8010677d:	c3                   	ret    

8010677e <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010677e:	1e                   	push   %ds
  pushl %es
8010677f:	06                   	push   %es
  pushl %fs
80106780:	0f a0                	push   %fs
  pushl %gs
80106782:	0f a8                	push   %gs
  pushal
80106784:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106785:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106789:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010678b:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010678d:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106791:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106793:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106795:	54                   	push   %esp
  call trap
80106796:	e8 d8 01 00 00       	call   80106973 <trap>
  addl $4, %esp
8010679b:	83 c4 04             	add    $0x4,%esp

8010679e <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010679e:	61                   	popa   
  popl %gs
8010679f:	0f a9                	pop    %gs
  popl %fs
801067a1:	0f a1                	pop    %fs
  popl %es
801067a3:	07                   	pop    %es
  popl %ds
801067a4:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801067a5:	83 c4 08             	add    $0x8,%esp
  iret
801067a8:	cf                   	iret   

801067a9 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801067a9:	55                   	push   %ebp
801067aa:	89 e5                	mov    %esp,%ebp
801067ac:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801067af:	8b 45 0c             	mov    0xc(%ebp),%eax
801067b2:	83 e8 01             	sub    $0x1,%eax
801067b5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801067b9:	8b 45 08             	mov    0x8(%ebp),%eax
801067bc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801067c0:	8b 45 08             	mov    0x8(%ebp),%eax
801067c3:	c1 e8 10             	shr    $0x10,%eax
801067c6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801067ca:	8d 45 fa             	lea    -0x6(%ebp),%eax
801067cd:	0f 01 18             	lidtl  (%eax)
}
801067d0:	c9                   	leave  
801067d1:	c3                   	ret    

801067d2 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801067d2:	55                   	push   %ebp
801067d3:	89 e5                	mov    %esp,%ebp
801067d5:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801067d8:	0f 20 d0             	mov    %cr2,%eax
801067db:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801067de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801067e1:	c9                   	leave  
801067e2:	c3                   	ret    

801067e3 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801067e3:	55                   	push   %ebp
801067e4:	89 e5                	mov    %esp,%ebp
801067e6:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801067e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067f0:	e9 c3 00 00 00       	jmp    801068b8 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801067f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f8:	8b 04 85 98 c0 10 80 	mov    -0x7fef3f68(,%eax,4),%eax
801067ff:	89 c2                	mov    %eax,%edx
80106801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106804:	66 89 14 c5 00 e6 11 	mov    %dx,-0x7fee1a00(,%eax,8)
8010680b:	80 
8010680c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680f:	66 c7 04 c5 02 e6 11 	movw   $0x8,-0x7fee19fe(,%eax,8)
80106816:	80 08 00 
80106819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681c:	0f b6 14 c5 04 e6 11 	movzbl -0x7fee19fc(,%eax,8),%edx
80106823:	80 
80106824:	83 e2 e0             	and    $0xffffffe0,%edx
80106827:	88 14 c5 04 e6 11 80 	mov    %dl,-0x7fee19fc(,%eax,8)
8010682e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106831:	0f b6 14 c5 04 e6 11 	movzbl -0x7fee19fc(,%eax,8),%edx
80106838:	80 
80106839:	83 e2 1f             	and    $0x1f,%edx
8010683c:	88 14 c5 04 e6 11 80 	mov    %dl,-0x7fee19fc(,%eax,8)
80106843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106846:	0f b6 14 c5 05 e6 11 	movzbl -0x7fee19fb(,%eax,8),%edx
8010684d:	80 
8010684e:	83 e2 f0             	and    $0xfffffff0,%edx
80106851:	83 ca 0e             	or     $0xe,%edx
80106854:	88 14 c5 05 e6 11 80 	mov    %dl,-0x7fee19fb(,%eax,8)
8010685b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685e:	0f b6 14 c5 05 e6 11 	movzbl -0x7fee19fb(,%eax,8),%edx
80106865:	80 
80106866:	83 e2 ef             	and    $0xffffffef,%edx
80106869:	88 14 c5 05 e6 11 80 	mov    %dl,-0x7fee19fb(,%eax,8)
80106870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106873:	0f b6 14 c5 05 e6 11 	movzbl -0x7fee19fb(,%eax,8),%edx
8010687a:	80 
8010687b:	83 e2 9f             	and    $0xffffff9f,%edx
8010687e:	88 14 c5 05 e6 11 80 	mov    %dl,-0x7fee19fb(,%eax,8)
80106885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106888:	0f b6 14 c5 05 e6 11 	movzbl -0x7fee19fb(,%eax,8),%edx
8010688f:	80 
80106890:	83 ca 80             	or     $0xffffff80,%edx
80106893:	88 14 c5 05 e6 11 80 	mov    %dl,-0x7fee19fb(,%eax,8)
8010689a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689d:	8b 04 85 98 c0 10 80 	mov    -0x7fef3f68(,%eax,4),%eax
801068a4:	c1 e8 10             	shr    $0x10,%eax
801068a7:	89 c2                	mov    %eax,%edx
801068a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ac:	66 89 14 c5 06 e6 11 	mov    %dx,-0x7fee19fa(,%eax,8)
801068b3:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801068b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801068b8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801068bf:	0f 8e 30 ff ff ff    	jle    801067f5 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801068c5:	a1 98 c1 10 80       	mov    0x8010c198,%eax
801068ca:	66 a3 00 e8 11 80    	mov    %ax,0x8011e800
801068d0:	66 c7 05 02 e8 11 80 	movw   $0x8,0x8011e802
801068d7:	08 00 
801068d9:	0f b6 05 04 e8 11 80 	movzbl 0x8011e804,%eax
801068e0:	83 e0 e0             	and    $0xffffffe0,%eax
801068e3:	a2 04 e8 11 80       	mov    %al,0x8011e804
801068e8:	0f b6 05 04 e8 11 80 	movzbl 0x8011e804,%eax
801068ef:	83 e0 1f             	and    $0x1f,%eax
801068f2:	a2 04 e8 11 80       	mov    %al,0x8011e804
801068f7:	0f b6 05 05 e8 11 80 	movzbl 0x8011e805,%eax
801068fe:	83 c8 0f             	or     $0xf,%eax
80106901:	a2 05 e8 11 80       	mov    %al,0x8011e805
80106906:	0f b6 05 05 e8 11 80 	movzbl 0x8011e805,%eax
8010690d:	83 e0 ef             	and    $0xffffffef,%eax
80106910:	a2 05 e8 11 80       	mov    %al,0x8011e805
80106915:	0f b6 05 05 e8 11 80 	movzbl 0x8011e805,%eax
8010691c:	83 c8 60             	or     $0x60,%eax
8010691f:	a2 05 e8 11 80       	mov    %al,0x8011e805
80106924:	0f b6 05 05 e8 11 80 	movzbl 0x8011e805,%eax
8010692b:	83 c8 80             	or     $0xffffff80,%eax
8010692e:	a2 05 e8 11 80       	mov    %al,0x8011e805
80106933:	a1 98 c1 10 80       	mov    0x8010c198,%eax
80106938:	c1 e8 10             	shr    $0x10,%eax
8010693b:	66 a3 06 e8 11 80    	mov    %ax,0x8011e806
  
  initlock(&tickslock, "time");
80106941:	c7 44 24 04 3c 8e 10 	movl   $0x80108e3c,0x4(%esp)
80106948:	80 
80106949:	c7 04 24 c0 e5 11 80 	movl   $0x8011e5c0,(%esp)
80106950:	e8 c5 e7 ff ff       	call   8010511a <initlock>
}
80106955:	c9                   	leave  
80106956:	c3                   	ret    

80106957 <idtinit>:

void
idtinit(void)
{
80106957:	55                   	push   %ebp
80106958:	89 e5                	mov    %esp,%ebp
8010695a:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010695d:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106964:	00 
80106965:	c7 04 24 00 e6 11 80 	movl   $0x8011e600,(%esp)
8010696c:	e8 38 fe ff ff       	call   801067a9 <lidt>
}
80106971:	c9                   	leave  
80106972:	c3                   	ret    

80106973 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106973:	55                   	push   %ebp
80106974:	89 e5                	mov    %esp,%ebp
80106976:	57                   	push   %edi
80106977:	56                   	push   %esi
80106978:	53                   	push   %ebx
80106979:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
8010697c:	8b 45 08             	mov    0x8(%ebp),%eax
8010697f:	8b 40 30             	mov    0x30(%eax),%eax
80106982:	83 f8 40             	cmp    $0x40,%eax
80106985:	75 3f                	jne    801069c6 <trap+0x53>
    if(proc->killed)
80106987:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010698d:	8b 40 1c             	mov    0x1c(%eax),%eax
80106990:	85 c0                	test   %eax,%eax
80106992:	74 05                	je     80106999 <trap+0x26>
      exit();
80106994:	e8 74 df ff ff       	call   8010490d <exit>
    thread->tf = tf;
80106999:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
8010699f:	8b 55 08             	mov    0x8(%ebp),%edx
801069a2:	89 50 10             	mov    %edx,0x10(%eax)
    syscall();
801069a5:	e8 ee ed ff ff       	call   80105798 <syscall>
    if(proc->killed)
801069aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069b0:	8b 40 1c             	mov    0x1c(%eax),%eax
801069b3:	85 c0                	test   %eax,%eax
801069b5:	74 0a                	je     801069c1 <trap+0x4e>
      exit();
801069b7:	e8 51 df ff ff       	call   8010490d <exit>
    return;
801069bc:	e9 2d 02 00 00       	jmp    80106bee <trap+0x27b>
801069c1:	e9 28 02 00 00       	jmp    80106bee <trap+0x27b>
  }

  switch(tf->trapno){
801069c6:	8b 45 08             	mov    0x8(%ebp),%eax
801069c9:	8b 40 30             	mov    0x30(%eax),%eax
801069cc:	83 e8 20             	sub    $0x20,%eax
801069cf:	83 f8 1f             	cmp    $0x1f,%eax
801069d2:	0f 87 bc 00 00 00    	ja     80106a94 <trap+0x121>
801069d8:	8b 04 85 e4 8e 10 80 	mov    -0x7fef711c(,%eax,4),%eax
801069df:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801069e1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069e7:	0f b6 00             	movzbl (%eax),%eax
801069ea:	84 c0                	test   %al,%al
801069ec:	75 31                	jne    80106a1f <trap+0xac>
      acquire(&tickslock);
801069ee:	c7 04 24 c0 e5 11 80 	movl   $0x8011e5c0,(%esp)
801069f5:	e8 41 e7 ff ff       	call   8010513b <acquire>
      ticks++;
801069fa:	a1 00 ee 11 80       	mov    0x8011ee00,%eax
801069ff:	83 c0 01             	add    $0x1,%eax
80106a02:	a3 00 ee 11 80       	mov    %eax,0x8011ee00
      wakeup(&ticks);
80106a07:	c7 04 24 00 ee 11 80 	movl   $0x8011ee00,(%esp)
80106a0e:	e8 de e4 ff ff       	call   80104ef1 <wakeup>
      release(&tickslock);
80106a13:	c7 04 24 c0 e5 11 80 	movl   $0x8011e5c0,(%esp)
80106a1a:	e8 7e e7 ff ff       	call   8010519d <release>
    }
    lapiceoi();
80106a1f:	e8 ac c4 ff ff       	call   80102ed0 <lapiceoi>
    break;
80106a24:	e9 41 01 00 00       	jmp    80106b6a <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a29:	e8 b0 bc ff ff       	call   801026de <ideintr>
    lapiceoi();
80106a2e:	e8 9d c4 ff ff       	call   80102ed0 <lapiceoi>
    break;
80106a33:	e9 32 01 00 00       	jmp    80106b6a <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a38:	e8 62 c2 ff ff       	call   80102c9f <kbdintr>
    lapiceoi();
80106a3d:	e8 8e c4 ff ff       	call   80102ed0 <lapiceoi>
    break;
80106a42:	e9 23 01 00 00       	jmp    80106b6a <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a47:	e8 97 03 00 00       	call   80106de3 <uartintr>
    lapiceoi();
80106a4c:	e8 7f c4 ff ff       	call   80102ed0 <lapiceoi>
    break;
80106a51:	e9 14 01 00 00       	jmp    80106b6a <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a56:	8b 45 08             	mov    0x8(%ebp),%eax
80106a59:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a5f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a63:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106a66:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a6c:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a6f:	0f b6 c0             	movzbl %al,%eax
80106a72:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a76:	89 54 24 08          	mov    %edx,0x8(%esp)
80106a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a7e:	c7 04 24 44 8e 10 80 	movl   $0x80108e44,(%esp)
80106a85:	e8 16 99 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106a8a:	e8 41 c4 ff ff       	call   80102ed0 <lapiceoi>
    break;
80106a8f:	e9 d6 00 00 00       	jmp    80106b6a <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106a94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a9a:	85 c0                	test   %eax,%eax
80106a9c:	74 11                	je     80106aaf <trap+0x13c>
80106a9e:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106aa5:	0f b7 c0             	movzwl %ax,%eax
80106aa8:	83 e0 03             	and    $0x3,%eax
80106aab:	85 c0                	test   %eax,%eax
80106aad:	75 46                	jne    80106af5 <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106aaf:	e8 1e fd ff ff       	call   801067d2 <rcr2>
80106ab4:	8b 55 08             	mov    0x8(%ebp),%edx
80106ab7:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106aba:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106ac1:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ac4:	0f b6 ca             	movzbl %dl,%ecx
80106ac7:	8b 55 08             	mov    0x8(%ebp),%edx
80106aca:	8b 52 30             	mov    0x30(%edx),%edx
80106acd:	89 44 24 10          	mov    %eax,0x10(%esp)
80106ad1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106ad5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106ad9:	89 54 24 04          	mov    %edx,0x4(%esp)
80106add:	c7 04 24 68 8e 10 80 	movl   $0x80108e68,(%esp)
80106ae4:	e8 b7 98 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106ae9:	c7 04 24 9a 8e 10 80 	movl   $0x80108e9a,(%esp)
80106af0:	e8 45 9a ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106af5:	e8 d8 fc ff ff       	call   801067d2 <rcr2>
80106afa:	89 c2                	mov    %eax,%edx
80106afc:	8b 45 08             	mov    0x8(%ebp),%eax
80106aff:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b02:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b08:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b0b:	0f b6 f0             	movzbl %al,%esi
80106b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80106b11:	8b 58 34             	mov    0x34(%eax),%ebx
80106b14:	8b 45 08             	mov    0x8(%ebp),%eax
80106b17:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b20:	83 c0 64             	add    $0x64,%eax
80106b23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b2c:	8b 40 10             	mov    0x10(%eax),%eax
80106b2f:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106b33:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106b37:	89 74 24 14          	mov    %esi,0x14(%esp)
80106b3b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106b3f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b43:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106b46:	89 74 24 08          	mov    %esi,0x8(%esp)
80106b4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b4e:	c7 04 24 a0 8e 10 80 	movl   $0x80108ea0,(%esp)
80106b55:	e8 46 98 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106b5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b60:	c7 40 1c 01 00 00 00 	movl   $0x1,0x1c(%eax)
80106b67:	eb 01                	jmp    80106b6a <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106b69:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106b6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b70:	85 c0                	test   %eax,%eax
80106b72:	74 24                	je     80106b98 <trap+0x225>
80106b74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b7a:	8b 40 1c             	mov    0x1c(%eax),%eax
80106b7d:	85 c0                	test   %eax,%eax
80106b7f:	74 17                	je     80106b98 <trap+0x225>
80106b81:	8b 45 08             	mov    0x8(%ebp),%eax
80106b84:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b88:	0f b7 c0             	movzwl %ax,%eax
80106b8b:	83 e0 03             	and    $0x3,%eax
80106b8e:	83 f8 03             	cmp    $0x3,%eax
80106b91:	75 05                	jne    80106b98 <trap+0x225>
    exit();
80106b93:	e8 75 dd ff ff       	call   8010490d <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(thread && thread->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106b98:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80106b9e:	85 c0                	test   %eax,%eax
80106ba0:	74 1e                	je     80106bc0 <trap+0x24d>
80106ba2:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80106ba8:	8b 40 04             	mov    0x4(%eax),%eax
80106bab:	83 f8 04             	cmp    $0x4,%eax
80106bae:	75 10                	jne    80106bc0 <trap+0x24d>
80106bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb3:	8b 40 30             	mov    0x30(%eax),%eax
80106bb6:	83 f8 20             	cmp    $0x20,%eax
80106bb9:	75 05                	jne    80106bc0 <trap+0x24d>
    yield();
80106bbb:	e8 6a e1 ff ff       	call   80104d2a <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106bc0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bc6:	85 c0                	test   %eax,%eax
80106bc8:	74 24                	je     80106bee <trap+0x27b>
80106bca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bd0:	8b 40 1c             	mov    0x1c(%eax),%eax
80106bd3:	85 c0                	test   %eax,%eax
80106bd5:	74 17                	je     80106bee <trap+0x27b>
80106bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80106bda:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bde:	0f b7 c0             	movzwl %ax,%eax
80106be1:	83 e0 03             	and    $0x3,%eax
80106be4:	83 f8 03             	cmp    $0x3,%eax
80106be7:	75 05                	jne    80106bee <trap+0x27b>
    exit();
80106be9:	e8 1f dd ff ff       	call   8010490d <exit>
}
80106bee:	83 c4 3c             	add    $0x3c,%esp
80106bf1:	5b                   	pop    %ebx
80106bf2:	5e                   	pop    %esi
80106bf3:	5f                   	pop    %edi
80106bf4:	5d                   	pop    %ebp
80106bf5:	c3                   	ret    

80106bf6 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106bf6:	55                   	push   %ebp
80106bf7:	89 e5                	mov    %esp,%ebp
80106bf9:	83 ec 14             	sub    $0x14,%esp
80106bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80106bff:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c03:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106c07:	89 c2                	mov    %eax,%edx
80106c09:	ec                   	in     (%dx),%al
80106c0a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106c0d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106c11:	c9                   	leave  
80106c12:	c3                   	ret    

80106c13 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c13:	55                   	push   %ebp
80106c14:	89 e5                	mov    %esp,%ebp
80106c16:	83 ec 08             	sub    $0x8,%esp
80106c19:	8b 55 08             	mov    0x8(%ebp),%edx
80106c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c1f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c23:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c26:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c2a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c2e:	ee                   	out    %al,(%dx)
}
80106c2f:	c9                   	leave  
80106c30:	c3                   	ret    

80106c31 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c31:	55                   	push   %ebp
80106c32:	89 e5                	mov    %esp,%ebp
80106c34:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c3e:	00 
80106c3f:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106c46:	e8 c8 ff ff ff       	call   80106c13 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c4b:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106c52:	00 
80106c53:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c5a:	e8 b4 ff ff ff       	call   80106c13 <outb>
  outb(COM1+0, 115200/9600);
80106c5f:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106c66:	00 
80106c67:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c6e:	e8 a0 ff ff ff       	call   80106c13 <outb>
  outb(COM1+1, 0);
80106c73:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c7a:	00 
80106c7b:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106c82:	e8 8c ff ff ff       	call   80106c13 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c87:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106c8e:	00 
80106c8f:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c96:	e8 78 ff ff ff       	call   80106c13 <outb>
  outb(COM1+4, 0);
80106c9b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ca2:	00 
80106ca3:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106caa:	e8 64 ff ff ff       	call   80106c13 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106caf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106cb6:	00 
80106cb7:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106cbe:	e8 50 ff ff ff       	call   80106c13 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106cc3:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106cca:	e8 27 ff ff ff       	call   80106bf6 <inb>
80106ccf:	3c ff                	cmp    $0xff,%al
80106cd1:	75 02                	jne    80106cd5 <uartinit+0xa4>
    return;
80106cd3:	eb 6a                	jmp    80106d3f <uartinit+0x10e>
  uart = 1;
80106cd5:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80106cdc:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106cdf:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106ce6:	e8 0b ff ff ff       	call   80106bf6 <inb>
  inb(COM1+0);
80106ceb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cf2:	e8 ff fe ff ff       	call   80106bf6 <inb>
  picenable(IRQ_COM1);
80106cf7:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106cfe:	e8 c3 d0 ff ff       	call   80103dc6 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106d03:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d0a:	00 
80106d0b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d12:	e8 46 bc ff ff       	call   8010295d <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d17:	c7 45 f4 64 8f 10 80 	movl   $0x80108f64,-0xc(%ebp)
80106d1e:	eb 15                	jmp    80106d35 <uartinit+0x104>
    uartputc(*p);
80106d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d23:	0f b6 00             	movzbl (%eax),%eax
80106d26:	0f be c0             	movsbl %al,%eax
80106d29:	89 04 24             	mov    %eax,(%esp)
80106d2c:	e8 10 00 00 00       	call   80106d41 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d31:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d38:	0f b6 00             	movzbl (%eax),%eax
80106d3b:	84 c0                	test   %al,%al
80106d3d:	75 e1                	jne    80106d20 <uartinit+0xef>
    uartputc(*p);
}
80106d3f:	c9                   	leave  
80106d40:	c3                   	ret    

80106d41 <uartputc>:

void
uartputc(int c)
{
80106d41:	55                   	push   %ebp
80106d42:	89 e5                	mov    %esp,%ebp
80106d44:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106d47:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80106d4c:	85 c0                	test   %eax,%eax
80106d4e:	75 02                	jne    80106d52 <uartputc+0x11>
    return;
80106d50:	eb 4b                	jmp    80106d9d <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d59:	eb 10                	jmp    80106d6b <uartputc+0x2a>
    microdelay(10);
80106d5b:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106d62:	e8 8e c1 ff ff       	call   80102ef5 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d6b:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d6f:	7f 16                	jg     80106d87 <uartputc+0x46>
80106d71:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d78:	e8 79 fe ff ff       	call   80106bf6 <inb>
80106d7d:	0f b6 c0             	movzbl %al,%eax
80106d80:	83 e0 20             	and    $0x20,%eax
80106d83:	85 c0                	test   %eax,%eax
80106d85:	74 d4                	je     80106d5b <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106d87:	8b 45 08             	mov    0x8(%ebp),%eax
80106d8a:	0f b6 c0             	movzbl %al,%eax
80106d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d91:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d98:	e8 76 fe ff ff       	call   80106c13 <outb>
}
80106d9d:	c9                   	leave  
80106d9e:	c3                   	ret    

80106d9f <uartgetc>:

static int
uartgetc(void)
{
80106d9f:	55                   	push   %ebp
80106da0:	89 e5                	mov    %esp,%ebp
80106da2:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106da5:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80106daa:	85 c0                	test   %eax,%eax
80106dac:	75 07                	jne    80106db5 <uartgetc+0x16>
    return -1;
80106dae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106db3:	eb 2c                	jmp    80106de1 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106db5:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106dbc:	e8 35 fe ff ff       	call   80106bf6 <inb>
80106dc1:	0f b6 c0             	movzbl %al,%eax
80106dc4:	83 e0 01             	and    $0x1,%eax
80106dc7:	85 c0                	test   %eax,%eax
80106dc9:	75 07                	jne    80106dd2 <uartgetc+0x33>
    return -1;
80106dcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dd0:	eb 0f                	jmp    80106de1 <uartgetc+0x42>
  return inb(COM1+0);
80106dd2:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106dd9:	e8 18 fe ff ff       	call   80106bf6 <inb>
80106dde:	0f b6 c0             	movzbl %al,%eax
}
80106de1:	c9                   	leave  
80106de2:	c3                   	ret    

80106de3 <uartintr>:

void
uartintr(void)
{
80106de3:	55                   	push   %ebp
80106de4:	89 e5                	mov    %esp,%ebp
80106de6:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106de9:	c7 04 24 9f 6d 10 80 	movl   $0x80106d9f,(%esp)
80106df0:	e8 b8 99 ff ff       	call   801007ad <consoleintr>
}
80106df5:	c9                   	leave  
80106df6:	c3                   	ret    

80106df7 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106df7:	6a 00                	push   $0x0
  pushl $0
80106df9:	6a 00                	push   $0x0
  jmp alltraps
80106dfb:	e9 7e f9 ff ff       	jmp    8010677e <alltraps>

80106e00 <vector1>:
.globl vector1
vector1:
  pushl $0
80106e00:	6a 00                	push   $0x0
  pushl $1
80106e02:	6a 01                	push   $0x1
  jmp alltraps
80106e04:	e9 75 f9 ff ff       	jmp    8010677e <alltraps>

80106e09 <vector2>:
.globl vector2
vector2:
  pushl $0
80106e09:	6a 00                	push   $0x0
  pushl $2
80106e0b:	6a 02                	push   $0x2
  jmp alltraps
80106e0d:	e9 6c f9 ff ff       	jmp    8010677e <alltraps>

80106e12 <vector3>:
.globl vector3
vector3:
  pushl $0
80106e12:	6a 00                	push   $0x0
  pushl $3
80106e14:	6a 03                	push   $0x3
  jmp alltraps
80106e16:	e9 63 f9 ff ff       	jmp    8010677e <alltraps>

80106e1b <vector4>:
.globl vector4
vector4:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $4
80106e1d:	6a 04                	push   $0x4
  jmp alltraps
80106e1f:	e9 5a f9 ff ff       	jmp    8010677e <alltraps>

80106e24 <vector5>:
.globl vector5
vector5:
  pushl $0
80106e24:	6a 00                	push   $0x0
  pushl $5
80106e26:	6a 05                	push   $0x5
  jmp alltraps
80106e28:	e9 51 f9 ff ff       	jmp    8010677e <alltraps>

80106e2d <vector6>:
.globl vector6
vector6:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $6
80106e2f:	6a 06                	push   $0x6
  jmp alltraps
80106e31:	e9 48 f9 ff ff       	jmp    8010677e <alltraps>

80106e36 <vector7>:
.globl vector7
vector7:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $7
80106e38:	6a 07                	push   $0x7
  jmp alltraps
80106e3a:	e9 3f f9 ff ff       	jmp    8010677e <alltraps>

80106e3f <vector8>:
.globl vector8
vector8:
  pushl $8
80106e3f:	6a 08                	push   $0x8
  jmp alltraps
80106e41:	e9 38 f9 ff ff       	jmp    8010677e <alltraps>

80106e46 <vector9>:
.globl vector9
vector9:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $9
80106e48:	6a 09                	push   $0x9
  jmp alltraps
80106e4a:	e9 2f f9 ff ff       	jmp    8010677e <alltraps>

80106e4f <vector10>:
.globl vector10
vector10:
  pushl $10
80106e4f:	6a 0a                	push   $0xa
  jmp alltraps
80106e51:	e9 28 f9 ff ff       	jmp    8010677e <alltraps>

80106e56 <vector11>:
.globl vector11
vector11:
  pushl $11
80106e56:	6a 0b                	push   $0xb
  jmp alltraps
80106e58:	e9 21 f9 ff ff       	jmp    8010677e <alltraps>

80106e5d <vector12>:
.globl vector12
vector12:
  pushl $12
80106e5d:	6a 0c                	push   $0xc
  jmp alltraps
80106e5f:	e9 1a f9 ff ff       	jmp    8010677e <alltraps>

80106e64 <vector13>:
.globl vector13
vector13:
  pushl $13
80106e64:	6a 0d                	push   $0xd
  jmp alltraps
80106e66:	e9 13 f9 ff ff       	jmp    8010677e <alltraps>

80106e6b <vector14>:
.globl vector14
vector14:
  pushl $14
80106e6b:	6a 0e                	push   $0xe
  jmp alltraps
80106e6d:	e9 0c f9 ff ff       	jmp    8010677e <alltraps>

80106e72 <vector15>:
.globl vector15
vector15:
  pushl $0
80106e72:	6a 00                	push   $0x0
  pushl $15
80106e74:	6a 0f                	push   $0xf
  jmp alltraps
80106e76:	e9 03 f9 ff ff       	jmp    8010677e <alltraps>

80106e7b <vector16>:
.globl vector16
vector16:
  pushl $0
80106e7b:	6a 00                	push   $0x0
  pushl $16
80106e7d:	6a 10                	push   $0x10
  jmp alltraps
80106e7f:	e9 fa f8 ff ff       	jmp    8010677e <alltraps>

80106e84 <vector17>:
.globl vector17
vector17:
  pushl $17
80106e84:	6a 11                	push   $0x11
  jmp alltraps
80106e86:	e9 f3 f8 ff ff       	jmp    8010677e <alltraps>

80106e8b <vector18>:
.globl vector18
vector18:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $18
80106e8d:	6a 12                	push   $0x12
  jmp alltraps
80106e8f:	e9 ea f8 ff ff       	jmp    8010677e <alltraps>

80106e94 <vector19>:
.globl vector19
vector19:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $19
80106e96:	6a 13                	push   $0x13
  jmp alltraps
80106e98:	e9 e1 f8 ff ff       	jmp    8010677e <alltraps>

80106e9d <vector20>:
.globl vector20
vector20:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $20
80106e9f:	6a 14                	push   $0x14
  jmp alltraps
80106ea1:	e9 d8 f8 ff ff       	jmp    8010677e <alltraps>

80106ea6 <vector21>:
.globl vector21
vector21:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $21
80106ea8:	6a 15                	push   $0x15
  jmp alltraps
80106eaa:	e9 cf f8 ff ff       	jmp    8010677e <alltraps>

80106eaf <vector22>:
.globl vector22
vector22:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $22
80106eb1:	6a 16                	push   $0x16
  jmp alltraps
80106eb3:	e9 c6 f8 ff ff       	jmp    8010677e <alltraps>

80106eb8 <vector23>:
.globl vector23
vector23:
  pushl $0
80106eb8:	6a 00                	push   $0x0
  pushl $23
80106eba:	6a 17                	push   $0x17
  jmp alltraps
80106ebc:	e9 bd f8 ff ff       	jmp    8010677e <alltraps>

80106ec1 <vector24>:
.globl vector24
vector24:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $24
80106ec3:	6a 18                	push   $0x18
  jmp alltraps
80106ec5:	e9 b4 f8 ff ff       	jmp    8010677e <alltraps>

80106eca <vector25>:
.globl vector25
vector25:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $25
80106ecc:	6a 19                	push   $0x19
  jmp alltraps
80106ece:	e9 ab f8 ff ff       	jmp    8010677e <alltraps>

80106ed3 <vector26>:
.globl vector26
vector26:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $26
80106ed5:	6a 1a                	push   $0x1a
  jmp alltraps
80106ed7:	e9 a2 f8 ff ff       	jmp    8010677e <alltraps>

80106edc <vector27>:
.globl vector27
vector27:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $27
80106ede:	6a 1b                	push   $0x1b
  jmp alltraps
80106ee0:	e9 99 f8 ff ff       	jmp    8010677e <alltraps>

80106ee5 <vector28>:
.globl vector28
vector28:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $28
80106ee7:	6a 1c                	push   $0x1c
  jmp alltraps
80106ee9:	e9 90 f8 ff ff       	jmp    8010677e <alltraps>

80106eee <vector29>:
.globl vector29
vector29:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $29
80106ef0:	6a 1d                	push   $0x1d
  jmp alltraps
80106ef2:	e9 87 f8 ff ff       	jmp    8010677e <alltraps>

80106ef7 <vector30>:
.globl vector30
vector30:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $30
80106ef9:	6a 1e                	push   $0x1e
  jmp alltraps
80106efb:	e9 7e f8 ff ff       	jmp    8010677e <alltraps>

80106f00 <vector31>:
.globl vector31
vector31:
  pushl $0
80106f00:	6a 00                	push   $0x0
  pushl $31
80106f02:	6a 1f                	push   $0x1f
  jmp alltraps
80106f04:	e9 75 f8 ff ff       	jmp    8010677e <alltraps>

80106f09 <vector32>:
.globl vector32
vector32:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $32
80106f0b:	6a 20                	push   $0x20
  jmp alltraps
80106f0d:	e9 6c f8 ff ff       	jmp    8010677e <alltraps>

80106f12 <vector33>:
.globl vector33
vector33:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $33
80106f14:	6a 21                	push   $0x21
  jmp alltraps
80106f16:	e9 63 f8 ff ff       	jmp    8010677e <alltraps>

80106f1b <vector34>:
.globl vector34
vector34:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $34
80106f1d:	6a 22                	push   $0x22
  jmp alltraps
80106f1f:	e9 5a f8 ff ff       	jmp    8010677e <alltraps>

80106f24 <vector35>:
.globl vector35
vector35:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $35
80106f26:	6a 23                	push   $0x23
  jmp alltraps
80106f28:	e9 51 f8 ff ff       	jmp    8010677e <alltraps>

80106f2d <vector36>:
.globl vector36
vector36:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $36
80106f2f:	6a 24                	push   $0x24
  jmp alltraps
80106f31:	e9 48 f8 ff ff       	jmp    8010677e <alltraps>

80106f36 <vector37>:
.globl vector37
vector37:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $37
80106f38:	6a 25                	push   $0x25
  jmp alltraps
80106f3a:	e9 3f f8 ff ff       	jmp    8010677e <alltraps>

80106f3f <vector38>:
.globl vector38
vector38:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $38
80106f41:	6a 26                	push   $0x26
  jmp alltraps
80106f43:	e9 36 f8 ff ff       	jmp    8010677e <alltraps>

80106f48 <vector39>:
.globl vector39
vector39:
  pushl $0
80106f48:	6a 00                	push   $0x0
  pushl $39
80106f4a:	6a 27                	push   $0x27
  jmp alltraps
80106f4c:	e9 2d f8 ff ff       	jmp    8010677e <alltraps>

80106f51 <vector40>:
.globl vector40
vector40:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $40
80106f53:	6a 28                	push   $0x28
  jmp alltraps
80106f55:	e9 24 f8 ff ff       	jmp    8010677e <alltraps>

80106f5a <vector41>:
.globl vector41
vector41:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $41
80106f5c:	6a 29                	push   $0x29
  jmp alltraps
80106f5e:	e9 1b f8 ff ff       	jmp    8010677e <alltraps>

80106f63 <vector42>:
.globl vector42
vector42:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $42
80106f65:	6a 2a                	push   $0x2a
  jmp alltraps
80106f67:	e9 12 f8 ff ff       	jmp    8010677e <alltraps>

80106f6c <vector43>:
.globl vector43
vector43:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $43
80106f6e:	6a 2b                	push   $0x2b
  jmp alltraps
80106f70:	e9 09 f8 ff ff       	jmp    8010677e <alltraps>

80106f75 <vector44>:
.globl vector44
vector44:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $44
80106f77:	6a 2c                	push   $0x2c
  jmp alltraps
80106f79:	e9 00 f8 ff ff       	jmp    8010677e <alltraps>

80106f7e <vector45>:
.globl vector45
vector45:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $45
80106f80:	6a 2d                	push   $0x2d
  jmp alltraps
80106f82:	e9 f7 f7 ff ff       	jmp    8010677e <alltraps>

80106f87 <vector46>:
.globl vector46
vector46:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $46
80106f89:	6a 2e                	push   $0x2e
  jmp alltraps
80106f8b:	e9 ee f7 ff ff       	jmp    8010677e <alltraps>

80106f90 <vector47>:
.globl vector47
vector47:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $47
80106f92:	6a 2f                	push   $0x2f
  jmp alltraps
80106f94:	e9 e5 f7 ff ff       	jmp    8010677e <alltraps>

80106f99 <vector48>:
.globl vector48
vector48:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $48
80106f9b:	6a 30                	push   $0x30
  jmp alltraps
80106f9d:	e9 dc f7 ff ff       	jmp    8010677e <alltraps>

80106fa2 <vector49>:
.globl vector49
vector49:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $49
80106fa4:	6a 31                	push   $0x31
  jmp alltraps
80106fa6:	e9 d3 f7 ff ff       	jmp    8010677e <alltraps>

80106fab <vector50>:
.globl vector50
vector50:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $50
80106fad:	6a 32                	push   $0x32
  jmp alltraps
80106faf:	e9 ca f7 ff ff       	jmp    8010677e <alltraps>

80106fb4 <vector51>:
.globl vector51
vector51:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $51
80106fb6:	6a 33                	push   $0x33
  jmp alltraps
80106fb8:	e9 c1 f7 ff ff       	jmp    8010677e <alltraps>

80106fbd <vector52>:
.globl vector52
vector52:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $52
80106fbf:	6a 34                	push   $0x34
  jmp alltraps
80106fc1:	e9 b8 f7 ff ff       	jmp    8010677e <alltraps>

80106fc6 <vector53>:
.globl vector53
vector53:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $53
80106fc8:	6a 35                	push   $0x35
  jmp alltraps
80106fca:	e9 af f7 ff ff       	jmp    8010677e <alltraps>

80106fcf <vector54>:
.globl vector54
vector54:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $54
80106fd1:	6a 36                	push   $0x36
  jmp alltraps
80106fd3:	e9 a6 f7 ff ff       	jmp    8010677e <alltraps>

80106fd8 <vector55>:
.globl vector55
vector55:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $55
80106fda:	6a 37                	push   $0x37
  jmp alltraps
80106fdc:	e9 9d f7 ff ff       	jmp    8010677e <alltraps>

80106fe1 <vector56>:
.globl vector56
vector56:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $56
80106fe3:	6a 38                	push   $0x38
  jmp alltraps
80106fe5:	e9 94 f7 ff ff       	jmp    8010677e <alltraps>

80106fea <vector57>:
.globl vector57
vector57:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $57
80106fec:	6a 39                	push   $0x39
  jmp alltraps
80106fee:	e9 8b f7 ff ff       	jmp    8010677e <alltraps>

80106ff3 <vector58>:
.globl vector58
vector58:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $58
80106ff5:	6a 3a                	push   $0x3a
  jmp alltraps
80106ff7:	e9 82 f7 ff ff       	jmp    8010677e <alltraps>

80106ffc <vector59>:
.globl vector59
vector59:
  pushl $0
80106ffc:	6a 00                	push   $0x0
  pushl $59
80106ffe:	6a 3b                	push   $0x3b
  jmp alltraps
80107000:	e9 79 f7 ff ff       	jmp    8010677e <alltraps>

80107005 <vector60>:
.globl vector60
vector60:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $60
80107007:	6a 3c                	push   $0x3c
  jmp alltraps
80107009:	e9 70 f7 ff ff       	jmp    8010677e <alltraps>

8010700e <vector61>:
.globl vector61
vector61:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $61
80107010:	6a 3d                	push   $0x3d
  jmp alltraps
80107012:	e9 67 f7 ff ff       	jmp    8010677e <alltraps>

80107017 <vector62>:
.globl vector62
vector62:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $62
80107019:	6a 3e                	push   $0x3e
  jmp alltraps
8010701b:	e9 5e f7 ff ff       	jmp    8010677e <alltraps>

80107020 <vector63>:
.globl vector63
vector63:
  pushl $0
80107020:	6a 00                	push   $0x0
  pushl $63
80107022:	6a 3f                	push   $0x3f
  jmp alltraps
80107024:	e9 55 f7 ff ff       	jmp    8010677e <alltraps>

80107029 <vector64>:
.globl vector64
vector64:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $64
8010702b:	6a 40                	push   $0x40
  jmp alltraps
8010702d:	e9 4c f7 ff ff       	jmp    8010677e <alltraps>

80107032 <vector65>:
.globl vector65
vector65:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $65
80107034:	6a 41                	push   $0x41
  jmp alltraps
80107036:	e9 43 f7 ff ff       	jmp    8010677e <alltraps>

8010703b <vector66>:
.globl vector66
vector66:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $66
8010703d:	6a 42                	push   $0x42
  jmp alltraps
8010703f:	e9 3a f7 ff ff       	jmp    8010677e <alltraps>

80107044 <vector67>:
.globl vector67
vector67:
  pushl $0
80107044:	6a 00                	push   $0x0
  pushl $67
80107046:	6a 43                	push   $0x43
  jmp alltraps
80107048:	e9 31 f7 ff ff       	jmp    8010677e <alltraps>

8010704d <vector68>:
.globl vector68
vector68:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $68
8010704f:	6a 44                	push   $0x44
  jmp alltraps
80107051:	e9 28 f7 ff ff       	jmp    8010677e <alltraps>

80107056 <vector69>:
.globl vector69
vector69:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $69
80107058:	6a 45                	push   $0x45
  jmp alltraps
8010705a:	e9 1f f7 ff ff       	jmp    8010677e <alltraps>

8010705f <vector70>:
.globl vector70
vector70:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $70
80107061:	6a 46                	push   $0x46
  jmp alltraps
80107063:	e9 16 f7 ff ff       	jmp    8010677e <alltraps>

80107068 <vector71>:
.globl vector71
vector71:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $71
8010706a:	6a 47                	push   $0x47
  jmp alltraps
8010706c:	e9 0d f7 ff ff       	jmp    8010677e <alltraps>

80107071 <vector72>:
.globl vector72
vector72:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $72
80107073:	6a 48                	push   $0x48
  jmp alltraps
80107075:	e9 04 f7 ff ff       	jmp    8010677e <alltraps>

8010707a <vector73>:
.globl vector73
vector73:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $73
8010707c:	6a 49                	push   $0x49
  jmp alltraps
8010707e:	e9 fb f6 ff ff       	jmp    8010677e <alltraps>

80107083 <vector74>:
.globl vector74
vector74:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $74
80107085:	6a 4a                	push   $0x4a
  jmp alltraps
80107087:	e9 f2 f6 ff ff       	jmp    8010677e <alltraps>

8010708c <vector75>:
.globl vector75
vector75:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $75
8010708e:	6a 4b                	push   $0x4b
  jmp alltraps
80107090:	e9 e9 f6 ff ff       	jmp    8010677e <alltraps>

80107095 <vector76>:
.globl vector76
vector76:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $76
80107097:	6a 4c                	push   $0x4c
  jmp alltraps
80107099:	e9 e0 f6 ff ff       	jmp    8010677e <alltraps>

8010709e <vector77>:
.globl vector77
vector77:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $77
801070a0:	6a 4d                	push   $0x4d
  jmp alltraps
801070a2:	e9 d7 f6 ff ff       	jmp    8010677e <alltraps>

801070a7 <vector78>:
.globl vector78
vector78:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $78
801070a9:	6a 4e                	push   $0x4e
  jmp alltraps
801070ab:	e9 ce f6 ff ff       	jmp    8010677e <alltraps>

801070b0 <vector79>:
.globl vector79
vector79:
  pushl $0
801070b0:	6a 00                	push   $0x0
  pushl $79
801070b2:	6a 4f                	push   $0x4f
  jmp alltraps
801070b4:	e9 c5 f6 ff ff       	jmp    8010677e <alltraps>

801070b9 <vector80>:
.globl vector80
vector80:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $80
801070bb:	6a 50                	push   $0x50
  jmp alltraps
801070bd:	e9 bc f6 ff ff       	jmp    8010677e <alltraps>

801070c2 <vector81>:
.globl vector81
vector81:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $81
801070c4:	6a 51                	push   $0x51
  jmp alltraps
801070c6:	e9 b3 f6 ff ff       	jmp    8010677e <alltraps>

801070cb <vector82>:
.globl vector82
vector82:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $82
801070cd:	6a 52                	push   $0x52
  jmp alltraps
801070cf:	e9 aa f6 ff ff       	jmp    8010677e <alltraps>

801070d4 <vector83>:
.globl vector83
vector83:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $83
801070d6:	6a 53                	push   $0x53
  jmp alltraps
801070d8:	e9 a1 f6 ff ff       	jmp    8010677e <alltraps>

801070dd <vector84>:
.globl vector84
vector84:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $84
801070df:	6a 54                	push   $0x54
  jmp alltraps
801070e1:	e9 98 f6 ff ff       	jmp    8010677e <alltraps>

801070e6 <vector85>:
.globl vector85
vector85:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $85
801070e8:	6a 55                	push   $0x55
  jmp alltraps
801070ea:	e9 8f f6 ff ff       	jmp    8010677e <alltraps>

801070ef <vector86>:
.globl vector86
vector86:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $86
801070f1:	6a 56                	push   $0x56
  jmp alltraps
801070f3:	e9 86 f6 ff ff       	jmp    8010677e <alltraps>

801070f8 <vector87>:
.globl vector87
vector87:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $87
801070fa:	6a 57                	push   $0x57
  jmp alltraps
801070fc:	e9 7d f6 ff ff       	jmp    8010677e <alltraps>

80107101 <vector88>:
.globl vector88
vector88:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $88
80107103:	6a 58                	push   $0x58
  jmp alltraps
80107105:	e9 74 f6 ff ff       	jmp    8010677e <alltraps>

8010710a <vector89>:
.globl vector89
vector89:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $89
8010710c:	6a 59                	push   $0x59
  jmp alltraps
8010710e:	e9 6b f6 ff ff       	jmp    8010677e <alltraps>

80107113 <vector90>:
.globl vector90
vector90:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $90
80107115:	6a 5a                	push   $0x5a
  jmp alltraps
80107117:	e9 62 f6 ff ff       	jmp    8010677e <alltraps>

8010711c <vector91>:
.globl vector91
vector91:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $91
8010711e:	6a 5b                	push   $0x5b
  jmp alltraps
80107120:	e9 59 f6 ff ff       	jmp    8010677e <alltraps>

80107125 <vector92>:
.globl vector92
vector92:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $92
80107127:	6a 5c                	push   $0x5c
  jmp alltraps
80107129:	e9 50 f6 ff ff       	jmp    8010677e <alltraps>

8010712e <vector93>:
.globl vector93
vector93:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $93
80107130:	6a 5d                	push   $0x5d
  jmp alltraps
80107132:	e9 47 f6 ff ff       	jmp    8010677e <alltraps>

80107137 <vector94>:
.globl vector94
vector94:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $94
80107139:	6a 5e                	push   $0x5e
  jmp alltraps
8010713b:	e9 3e f6 ff ff       	jmp    8010677e <alltraps>

80107140 <vector95>:
.globl vector95
vector95:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $95
80107142:	6a 5f                	push   $0x5f
  jmp alltraps
80107144:	e9 35 f6 ff ff       	jmp    8010677e <alltraps>

80107149 <vector96>:
.globl vector96
vector96:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $96
8010714b:	6a 60                	push   $0x60
  jmp alltraps
8010714d:	e9 2c f6 ff ff       	jmp    8010677e <alltraps>

80107152 <vector97>:
.globl vector97
vector97:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $97
80107154:	6a 61                	push   $0x61
  jmp alltraps
80107156:	e9 23 f6 ff ff       	jmp    8010677e <alltraps>

8010715b <vector98>:
.globl vector98
vector98:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $98
8010715d:	6a 62                	push   $0x62
  jmp alltraps
8010715f:	e9 1a f6 ff ff       	jmp    8010677e <alltraps>

80107164 <vector99>:
.globl vector99
vector99:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $99
80107166:	6a 63                	push   $0x63
  jmp alltraps
80107168:	e9 11 f6 ff ff       	jmp    8010677e <alltraps>

8010716d <vector100>:
.globl vector100
vector100:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $100
8010716f:	6a 64                	push   $0x64
  jmp alltraps
80107171:	e9 08 f6 ff ff       	jmp    8010677e <alltraps>

80107176 <vector101>:
.globl vector101
vector101:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $101
80107178:	6a 65                	push   $0x65
  jmp alltraps
8010717a:	e9 ff f5 ff ff       	jmp    8010677e <alltraps>

8010717f <vector102>:
.globl vector102
vector102:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $102
80107181:	6a 66                	push   $0x66
  jmp alltraps
80107183:	e9 f6 f5 ff ff       	jmp    8010677e <alltraps>

80107188 <vector103>:
.globl vector103
vector103:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $103
8010718a:	6a 67                	push   $0x67
  jmp alltraps
8010718c:	e9 ed f5 ff ff       	jmp    8010677e <alltraps>

80107191 <vector104>:
.globl vector104
vector104:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $104
80107193:	6a 68                	push   $0x68
  jmp alltraps
80107195:	e9 e4 f5 ff ff       	jmp    8010677e <alltraps>

8010719a <vector105>:
.globl vector105
vector105:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $105
8010719c:	6a 69                	push   $0x69
  jmp alltraps
8010719e:	e9 db f5 ff ff       	jmp    8010677e <alltraps>

801071a3 <vector106>:
.globl vector106
vector106:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $106
801071a5:	6a 6a                	push   $0x6a
  jmp alltraps
801071a7:	e9 d2 f5 ff ff       	jmp    8010677e <alltraps>

801071ac <vector107>:
.globl vector107
vector107:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $107
801071ae:	6a 6b                	push   $0x6b
  jmp alltraps
801071b0:	e9 c9 f5 ff ff       	jmp    8010677e <alltraps>

801071b5 <vector108>:
.globl vector108
vector108:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $108
801071b7:	6a 6c                	push   $0x6c
  jmp alltraps
801071b9:	e9 c0 f5 ff ff       	jmp    8010677e <alltraps>

801071be <vector109>:
.globl vector109
vector109:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $109
801071c0:	6a 6d                	push   $0x6d
  jmp alltraps
801071c2:	e9 b7 f5 ff ff       	jmp    8010677e <alltraps>

801071c7 <vector110>:
.globl vector110
vector110:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $110
801071c9:	6a 6e                	push   $0x6e
  jmp alltraps
801071cb:	e9 ae f5 ff ff       	jmp    8010677e <alltraps>

801071d0 <vector111>:
.globl vector111
vector111:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $111
801071d2:	6a 6f                	push   $0x6f
  jmp alltraps
801071d4:	e9 a5 f5 ff ff       	jmp    8010677e <alltraps>

801071d9 <vector112>:
.globl vector112
vector112:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $112
801071db:	6a 70                	push   $0x70
  jmp alltraps
801071dd:	e9 9c f5 ff ff       	jmp    8010677e <alltraps>

801071e2 <vector113>:
.globl vector113
vector113:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $113
801071e4:	6a 71                	push   $0x71
  jmp alltraps
801071e6:	e9 93 f5 ff ff       	jmp    8010677e <alltraps>

801071eb <vector114>:
.globl vector114
vector114:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $114
801071ed:	6a 72                	push   $0x72
  jmp alltraps
801071ef:	e9 8a f5 ff ff       	jmp    8010677e <alltraps>

801071f4 <vector115>:
.globl vector115
vector115:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $115
801071f6:	6a 73                	push   $0x73
  jmp alltraps
801071f8:	e9 81 f5 ff ff       	jmp    8010677e <alltraps>

801071fd <vector116>:
.globl vector116
vector116:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $116
801071ff:	6a 74                	push   $0x74
  jmp alltraps
80107201:	e9 78 f5 ff ff       	jmp    8010677e <alltraps>

80107206 <vector117>:
.globl vector117
vector117:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $117
80107208:	6a 75                	push   $0x75
  jmp alltraps
8010720a:	e9 6f f5 ff ff       	jmp    8010677e <alltraps>

8010720f <vector118>:
.globl vector118
vector118:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $118
80107211:	6a 76                	push   $0x76
  jmp alltraps
80107213:	e9 66 f5 ff ff       	jmp    8010677e <alltraps>

80107218 <vector119>:
.globl vector119
vector119:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $119
8010721a:	6a 77                	push   $0x77
  jmp alltraps
8010721c:	e9 5d f5 ff ff       	jmp    8010677e <alltraps>

80107221 <vector120>:
.globl vector120
vector120:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $120
80107223:	6a 78                	push   $0x78
  jmp alltraps
80107225:	e9 54 f5 ff ff       	jmp    8010677e <alltraps>

8010722a <vector121>:
.globl vector121
vector121:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $121
8010722c:	6a 79                	push   $0x79
  jmp alltraps
8010722e:	e9 4b f5 ff ff       	jmp    8010677e <alltraps>

80107233 <vector122>:
.globl vector122
vector122:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $122
80107235:	6a 7a                	push   $0x7a
  jmp alltraps
80107237:	e9 42 f5 ff ff       	jmp    8010677e <alltraps>

8010723c <vector123>:
.globl vector123
vector123:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $123
8010723e:	6a 7b                	push   $0x7b
  jmp alltraps
80107240:	e9 39 f5 ff ff       	jmp    8010677e <alltraps>

80107245 <vector124>:
.globl vector124
vector124:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $124
80107247:	6a 7c                	push   $0x7c
  jmp alltraps
80107249:	e9 30 f5 ff ff       	jmp    8010677e <alltraps>

8010724e <vector125>:
.globl vector125
vector125:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $125
80107250:	6a 7d                	push   $0x7d
  jmp alltraps
80107252:	e9 27 f5 ff ff       	jmp    8010677e <alltraps>

80107257 <vector126>:
.globl vector126
vector126:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $126
80107259:	6a 7e                	push   $0x7e
  jmp alltraps
8010725b:	e9 1e f5 ff ff       	jmp    8010677e <alltraps>

80107260 <vector127>:
.globl vector127
vector127:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $127
80107262:	6a 7f                	push   $0x7f
  jmp alltraps
80107264:	e9 15 f5 ff ff       	jmp    8010677e <alltraps>

80107269 <vector128>:
.globl vector128
vector128:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $128
8010726b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107270:	e9 09 f5 ff ff       	jmp    8010677e <alltraps>

80107275 <vector129>:
.globl vector129
vector129:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $129
80107277:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010727c:	e9 fd f4 ff ff       	jmp    8010677e <alltraps>

80107281 <vector130>:
.globl vector130
vector130:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $130
80107283:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107288:	e9 f1 f4 ff ff       	jmp    8010677e <alltraps>

8010728d <vector131>:
.globl vector131
vector131:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $131
8010728f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107294:	e9 e5 f4 ff ff       	jmp    8010677e <alltraps>

80107299 <vector132>:
.globl vector132
vector132:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $132
8010729b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801072a0:	e9 d9 f4 ff ff       	jmp    8010677e <alltraps>

801072a5 <vector133>:
.globl vector133
vector133:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $133
801072a7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801072ac:	e9 cd f4 ff ff       	jmp    8010677e <alltraps>

801072b1 <vector134>:
.globl vector134
vector134:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $134
801072b3:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801072b8:	e9 c1 f4 ff ff       	jmp    8010677e <alltraps>

801072bd <vector135>:
.globl vector135
vector135:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $135
801072bf:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801072c4:	e9 b5 f4 ff ff       	jmp    8010677e <alltraps>

801072c9 <vector136>:
.globl vector136
vector136:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $136
801072cb:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801072d0:	e9 a9 f4 ff ff       	jmp    8010677e <alltraps>

801072d5 <vector137>:
.globl vector137
vector137:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $137
801072d7:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801072dc:	e9 9d f4 ff ff       	jmp    8010677e <alltraps>

801072e1 <vector138>:
.globl vector138
vector138:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $138
801072e3:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801072e8:	e9 91 f4 ff ff       	jmp    8010677e <alltraps>

801072ed <vector139>:
.globl vector139
vector139:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $139
801072ef:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801072f4:	e9 85 f4 ff ff       	jmp    8010677e <alltraps>

801072f9 <vector140>:
.globl vector140
vector140:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $140
801072fb:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107300:	e9 79 f4 ff ff       	jmp    8010677e <alltraps>

80107305 <vector141>:
.globl vector141
vector141:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $141
80107307:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010730c:	e9 6d f4 ff ff       	jmp    8010677e <alltraps>

80107311 <vector142>:
.globl vector142
vector142:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $142
80107313:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107318:	e9 61 f4 ff ff       	jmp    8010677e <alltraps>

8010731d <vector143>:
.globl vector143
vector143:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $143
8010731f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107324:	e9 55 f4 ff ff       	jmp    8010677e <alltraps>

80107329 <vector144>:
.globl vector144
vector144:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $144
8010732b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107330:	e9 49 f4 ff ff       	jmp    8010677e <alltraps>

80107335 <vector145>:
.globl vector145
vector145:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $145
80107337:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010733c:	e9 3d f4 ff ff       	jmp    8010677e <alltraps>

80107341 <vector146>:
.globl vector146
vector146:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $146
80107343:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107348:	e9 31 f4 ff ff       	jmp    8010677e <alltraps>

8010734d <vector147>:
.globl vector147
vector147:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $147
8010734f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107354:	e9 25 f4 ff ff       	jmp    8010677e <alltraps>

80107359 <vector148>:
.globl vector148
vector148:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $148
8010735b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107360:	e9 19 f4 ff ff       	jmp    8010677e <alltraps>

80107365 <vector149>:
.globl vector149
vector149:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $149
80107367:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010736c:	e9 0d f4 ff ff       	jmp    8010677e <alltraps>

80107371 <vector150>:
.globl vector150
vector150:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $150
80107373:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107378:	e9 01 f4 ff ff       	jmp    8010677e <alltraps>

8010737d <vector151>:
.globl vector151
vector151:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $151
8010737f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107384:	e9 f5 f3 ff ff       	jmp    8010677e <alltraps>

80107389 <vector152>:
.globl vector152
vector152:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $152
8010738b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107390:	e9 e9 f3 ff ff       	jmp    8010677e <alltraps>

80107395 <vector153>:
.globl vector153
vector153:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $153
80107397:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010739c:	e9 dd f3 ff ff       	jmp    8010677e <alltraps>

801073a1 <vector154>:
.globl vector154
vector154:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $154
801073a3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801073a8:	e9 d1 f3 ff ff       	jmp    8010677e <alltraps>

801073ad <vector155>:
.globl vector155
vector155:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $155
801073af:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801073b4:	e9 c5 f3 ff ff       	jmp    8010677e <alltraps>

801073b9 <vector156>:
.globl vector156
vector156:
  pushl $0
801073b9:	6a 00                	push   $0x0
  pushl $156
801073bb:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801073c0:	e9 b9 f3 ff ff       	jmp    8010677e <alltraps>

801073c5 <vector157>:
.globl vector157
vector157:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $157
801073c7:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801073cc:	e9 ad f3 ff ff       	jmp    8010677e <alltraps>

801073d1 <vector158>:
.globl vector158
vector158:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $158
801073d3:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801073d8:	e9 a1 f3 ff ff       	jmp    8010677e <alltraps>

801073dd <vector159>:
.globl vector159
vector159:
  pushl $0
801073dd:	6a 00                	push   $0x0
  pushl $159
801073df:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801073e4:	e9 95 f3 ff ff       	jmp    8010677e <alltraps>

801073e9 <vector160>:
.globl vector160
vector160:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $160
801073eb:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801073f0:	e9 89 f3 ff ff       	jmp    8010677e <alltraps>

801073f5 <vector161>:
.globl vector161
vector161:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $161
801073f7:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801073fc:	e9 7d f3 ff ff       	jmp    8010677e <alltraps>

80107401 <vector162>:
.globl vector162
vector162:
  pushl $0
80107401:	6a 00                	push   $0x0
  pushl $162
80107403:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107408:	e9 71 f3 ff ff       	jmp    8010677e <alltraps>

8010740d <vector163>:
.globl vector163
vector163:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $163
8010740f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107414:	e9 65 f3 ff ff       	jmp    8010677e <alltraps>

80107419 <vector164>:
.globl vector164
vector164:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $164
8010741b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107420:	e9 59 f3 ff ff       	jmp    8010677e <alltraps>

80107425 <vector165>:
.globl vector165
vector165:
  pushl $0
80107425:	6a 00                	push   $0x0
  pushl $165
80107427:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010742c:	e9 4d f3 ff ff       	jmp    8010677e <alltraps>

80107431 <vector166>:
.globl vector166
vector166:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $166
80107433:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107438:	e9 41 f3 ff ff       	jmp    8010677e <alltraps>

8010743d <vector167>:
.globl vector167
vector167:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $167
8010743f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107444:	e9 35 f3 ff ff       	jmp    8010677e <alltraps>

80107449 <vector168>:
.globl vector168
vector168:
  pushl $0
80107449:	6a 00                	push   $0x0
  pushl $168
8010744b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107450:	e9 29 f3 ff ff       	jmp    8010677e <alltraps>

80107455 <vector169>:
.globl vector169
vector169:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $169
80107457:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010745c:	e9 1d f3 ff ff       	jmp    8010677e <alltraps>

80107461 <vector170>:
.globl vector170
vector170:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $170
80107463:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107468:	e9 11 f3 ff ff       	jmp    8010677e <alltraps>

8010746d <vector171>:
.globl vector171
vector171:
  pushl $0
8010746d:	6a 00                	push   $0x0
  pushl $171
8010746f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107474:	e9 05 f3 ff ff       	jmp    8010677e <alltraps>

80107479 <vector172>:
.globl vector172
vector172:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $172
8010747b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107480:	e9 f9 f2 ff ff       	jmp    8010677e <alltraps>

80107485 <vector173>:
.globl vector173
vector173:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $173
80107487:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010748c:	e9 ed f2 ff ff       	jmp    8010677e <alltraps>

80107491 <vector174>:
.globl vector174
vector174:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $174
80107493:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107498:	e9 e1 f2 ff ff       	jmp    8010677e <alltraps>

8010749d <vector175>:
.globl vector175
vector175:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $175
8010749f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801074a4:	e9 d5 f2 ff ff       	jmp    8010677e <alltraps>

801074a9 <vector176>:
.globl vector176
vector176:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $176
801074ab:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801074b0:	e9 c9 f2 ff ff       	jmp    8010677e <alltraps>

801074b5 <vector177>:
.globl vector177
vector177:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $177
801074b7:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801074bc:	e9 bd f2 ff ff       	jmp    8010677e <alltraps>

801074c1 <vector178>:
.globl vector178
vector178:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $178
801074c3:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801074c8:	e9 b1 f2 ff ff       	jmp    8010677e <alltraps>

801074cd <vector179>:
.globl vector179
vector179:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $179
801074cf:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801074d4:	e9 a5 f2 ff ff       	jmp    8010677e <alltraps>

801074d9 <vector180>:
.globl vector180
vector180:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $180
801074db:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801074e0:	e9 99 f2 ff ff       	jmp    8010677e <alltraps>

801074e5 <vector181>:
.globl vector181
vector181:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $181
801074e7:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801074ec:	e9 8d f2 ff ff       	jmp    8010677e <alltraps>

801074f1 <vector182>:
.globl vector182
vector182:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $182
801074f3:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801074f8:	e9 81 f2 ff ff       	jmp    8010677e <alltraps>

801074fd <vector183>:
.globl vector183
vector183:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $183
801074ff:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107504:	e9 75 f2 ff ff       	jmp    8010677e <alltraps>

80107509 <vector184>:
.globl vector184
vector184:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $184
8010750b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107510:	e9 69 f2 ff ff       	jmp    8010677e <alltraps>

80107515 <vector185>:
.globl vector185
vector185:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $185
80107517:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010751c:	e9 5d f2 ff ff       	jmp    8010677e <alltraps>

80107521 <vector186>:
.globl vector186
vector186:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $186
80107523:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107528:	e9 51 f2 ff ff       	jmp    8010677e <alltraps>

8010752d <vector187>:
.globl vector187
vector187:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $187
8010752f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107534:	e9 45 f2 ff ff       	jmp    8010677e <alltraps>

80107539 <vector188>:
.globl vector188
vector188:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $188
8010753b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107540:	e9 39 f2 ff ff       	jmp    8010677e <alltraps>

80107545 <vector189>:
.globl vector189
vector189:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $189
80107547:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010754c:	e9 2d f2 ff ff       	jmp    8010677e <alltraps>

80107551 <vector190>:
.globl vector190
vector190:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $190
80107553:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107558:	e9 21 f2 ff ff       	jmp    8010677e <alltraps>

8010755d <vector191>:
.globl vector191
vector191:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $191
8010755f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107564:	e9 15 f2 ff ff       	jmp    8010677e <alltraps>

80107569 <vector192>:
.globl vector192
vector192:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $192
8010756b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107570:	e9 09 f2 ff ff       	jmp    8010677e <alltraps>

80107575 <vector193>:
.globl vector193
vector193:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $193
80107577:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010757c:	e9 fd f1 ff ff       	jmp    8010677e <alltraps>

80107581 <vector194>:
.globl vector194
vector194:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $194
80107583:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107588:	e9 f1 f1 ff ff       	jmp    8010677e <alltraps>

8010758d <vector195>:
.globl vector195
vector195:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $195
8010758f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107594:	e9 e5 f1 ff ff       	jmp    8010677e <alltraps>

80107599 <vector196>:
.globl vector196
vector196:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $196
8010759b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801075a0:	e9 d9 f1 ff ff       	jmp    8010677e <alltraps>

801075a5 <vector197>:
.globl vector197
vector197:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $197
801075a7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801075ac:	e9 cd f1 ff ff       	jmp    8010677e <alltraps>

801075b1 <vector198>:
.globl vector198
vector198:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $198
801075b3:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801075b8:	e9 c1 f1 ff ff       	jmp    8010677e <alltraps>

801075bd <vector199>:
.globl vector199
vector199:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $199
801075bf:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801075c4:	e9 b5 f1 ff ff       	jmp    8010677e <alltraps>

801075c9 <vector200>:
.globl vector200
vector200:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $200
801075cb:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801075d0:	e9 a9 f1 ff ff       	jmp    8010677e <alltraps>

801075d5 <vector201>:
.globl vector201
vector201:
  pushl $0
801075d5:	6a 00                	push   $0x0
  pushl $201
801075d7:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801075dc:	e9 9d f1 ff ff       	jmp    8010677e <alltraps>

801075e1 <vector202>:
.globl vector202
vector202:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $202
801075e3:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801075e8:	e9 91 f1 ff ff       	jmp    8010677e <alltraps>

801075ed <vector203>:
.globl vector203
vector203:
  pushl $0
801075ed:	6a 00                	push   $0x0
  pushl $203
801075ef:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801075f4:	e9 85 f1 ff ff       	jmp    8010677e <alltraps>

801075f9 <vector204>:
.globl vector204
vector204:
  pushl $0
801075f9:	6a 00                	push   $0x0
  pushl $204
801075fb:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107600:	e9 79 f1 ff ff       	jmp    8010677e <alltraps>

80107605 <vector205>:
.globl vector205
vector205:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $205
80107607:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010760c:	e9 6d f1 ff ff       	jmp    8010677e <alltraps>

80107611 <vector206>:
.globl vector206
vector206:
  pushl $0
80107611:	6a 00                	push   $0x0
  pushl $206
80107613:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107618:	e9 61 f1 ff ff       	jmp    8010677e <alltraps>

8010761d <vector207>:
.globl vector207
vector207:
  pushl $0
8010761d:	6a 00                	push   $0x0
  pushl $207
8010761f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107624:	e9 55 f1 ff ff       	jmp    8010677e <alltraps>

80107629 <vector208>:
.globl vector208
vector208:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $208
8010762b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107630:	e9 49 f1 ff ff       	jmp    8010677e <alltraps>

80107635 <vector209>:
.globl vector209
vector209:
  pushl $0
80107635:	6a 00                	push   $0x0
  pushl $209
80107637:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010763c:	e9 3d f1 ff ff       	jmp    8010677e <alltraps>

80107641 <vector210>:
.globl vector210
vector210:
  pushl $0
80107641:	6a 00                	push   $0x0
  pushl $210
80107643:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107648:	e9 31 f1 ff ff       	jmp    8010677e <alltraps>

8010764d <vector211>:
.globl vector211
vector211:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $211
8010764f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107654:	e9 25 f1 ff ff       	jmp    8010677e <alltraps>

80107659 <vector212>:
.globl vector212
vector212:
  pushl $0
80107659:	6a 00                	push   $0x0
  pushl $212
8010765b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107660:	e9 19 f1 ff ff       	jmp    8010677e <alltraps>

80107665 <vector213>:
.globl vector213
vector213:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $213
80107667:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010766c:	e9 0d f1 ff ff       	jmp    8010677e <alltraps>

80107671 <vector214>:
.globl vector214
vector214:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $214
80107673:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107678:	e9 01 f1 ff ff       	jmp    8010677e <alltraps>

8010767d <vector215>:
.globl vector215
vector215:
  pushl $0
8010767d:	6a 00                	push   $0x0
  pushl $215
8010767f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107684:	e9 f5 f0 ff ff       	jmp    8010677e <alltraps>

80107689 <vector216>:
.globl vector216
vector216:
  pushl $0
80107689:	6a 00                	push   $0x0
  pushl $216
8010768b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107690:	e9 e9 f0 ff ff       	jmp    8010677e <alltraps>

80107695 <vector217>:
.globl vector217
vector217:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $217
80107697:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010769c:	e9 dd f0 ff ff       	jmp    8010677e <alltraps>

801076a1 <vector218>:
.globl vector218
vector218:
  pushl $0
801076a1:	6a 00                	push   $0x0
  pushl $218
801076a3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801076a8:	e9 d1 f0 ff ff       	jmp    8010677e <alltraps>

801076ad <vector219>:
.globl vector219
vector219:
  pushl $0
801076ad:	6a 00                	push   $0x0
  pushl $219
801076af:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801076b4:	e9 c5 f0 ff ff       	jmp    8010677e <alltraps>

801076b9 <vector220>:
.globl vector220
vector220:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $220
801076bb:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801076c0:	e9 b9 f0 ff ff       	jmp    8010677e <alltraps>

801076c5 <vector221>:
.globl vector221
vector221:
  pushl $0
801076c5:	6a 00                	push   $0x0
  pushl $221
801076c7:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801076cc:	e9 ad f0 ff ff       	jmp    8010677e <alltraps>

801076d1 <vector222>:
.globl vector222
vector222:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $222
801076d3:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801076d8:	e9 a1 f0 ff ff       	jmp    8010677e <alltraps>

801076dd <vector223>:
.globl vector223
vector223:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $223
801076df:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801076e4:	e9 95 f0 ff ff       	jmp    8010677e <alltraps>

801076e9 <vector224>:
.globl vector224
vector224:
  pushl $0
801076e9:	6a 00                	push   $0x0
  pushl $224
801076eb:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801076f0:	e9 89 f0 ff ff       	jmp    8010677e <alltraps>

801076f5 <vector225>:
.globl vector225
vector225:
  pushl $0
801076f5:	6a 00                	push   $0x0
  pushl $225
801076f7:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801076fc:	e9 7d f0 ff ff       	jmp    8010677e <alltraps>

80107701 <vector226>:
.globl vector226
vector226:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $226
80107703:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107708:	e9 71 f0 ff ff       	jmp    8010677e <alltraps>

8010770d <vector227>:
.globl vector227
vector227:
  pushl $0
8010770d:	6a 00                	push   $0x0
  pushl $227
8010770f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107714:	e9 65 f0 ff ff       	jmp    8010677e <alltraps>

80107719 <vector228>:
.globl vector228
vector228:
  pushl $0
80107719:	6a 00                	push   $0x0
  pushl $228
8010771b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107720:	e9 59 f0 ff ff       	jmp    8010677e <alltraps>

80107725 <vector229>:
.globl vector229
vector229:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $229
80107727:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010772c:	e9 4d f0 ff ff       	jmp    8010677e <alltraps>

80107731 <vector230>:
.globl vector230
vector230:
  pushl $0
80107731:	6a 00                	push   $0x0
  pushl $230
80107733:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107738:	e9 41 f0 ff ff       	jmp    8010677e <alltraps>

8010773d <vector231>:
.globl vector231
vector231:
  pushl $0
8010773d:	6a 00                	push   $0x0
  pushl $231
8010773f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107744:	e9 35 f0 ff ff       	jmp    8010677e <alltraps>

80107749 <vector232>:
.globl vector232
vector232:
  pushl $0
80107749:	6a 00                	push   $0x0
  pushl $232
8010774b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107750:	e9 29 f0 ff ff       	jmp    8010677e <alltraps>

80107755 <vector233>:
.globl vector233
vector233:
  pushl $0
80107755:	6a 00                	push   $0x0
  pushl $233
80107757:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010775c:	e9 1d f0 ff ff       	jmp    8010677e <alltraps>

80107761 <vector234>:
.globl vector234
vector234:
  pushl $0
80107761:	6a 00                	push   $0x0
  pushl $234
80107763:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107768:	e9 11 f0 ff ff       	jmp    8010677e <alltraps>

8010776d <vector235>:
.globl vector235
vector235:
  pushl $0
8010776d:	6a 00                	push   $0x0
  pushl $235
8010776f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107774:	e9 05 f0 ff ff       	jmp    8010677e <alltraps>

80107779 <vector236>:
.globl vector236
vector236:
  pushl $0
80107779:	6a 00                	push   $0x0
  pushl $236
8010777b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107780:	e9 f9 ef ff ff       	jmp    8010677e <alltraps>

80107785 <vector237>:
.globl vector237
vector237:
  pushl $0
80107785:	6a 00                	push   $0x0
  pushl $237
80107787:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010778c:	e9 ed ef ff ff       	jmp    8010677e <alltraps>

80107791 <vector238>:
.globl vector238
vector238:
  pushl $0
80107791:	6a 00                	push   $0x0
  pushl $238
80107793:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107798:	e9 e1 ef ff ff       	jmp    8010677e <alltraps>

8010779d <vector239>:
.globl vector239
vector239:
  pushl $0
8010779d:	6a 00                	push   $0x0
  pushl $239
8010779f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801077a4:	e9 d5 ef ff ff       	jmp    8010677e <alltraps>

801077a9 <vector240>:
.globl vector240
vector240:
  pushl $0
801077a9:	6a 00                	push   $0x0
  pushl $240
801077ab:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801077b0:	e9 c9 ef ff ff       	jmp    8010677e <alltraps>

801077b5 <vector241>:
.globl vector241
vector241:
  pushl $0
801077b5:	6a 00                	push   $0x0
  pushl $241
801077b7:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801077bc:	e9 bd ef ff ff       	jmp    8010677e <alltraps>

801077c1 <vector242>:
.globl vector242
vector242:
  pushl $0
801077c1:	6a 00                	push   $0x0
  pushl $242
801077c3:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801077c8:	e9 b1 ef ff ff       	jmp    8010677e <alltraps>

801077cd <vector243>:
.globl vector243
vector243:
  pushl $0
801077cd:	6a 00                	push   $0x0
  pushl $243
801077cf:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801077d4:	e9 a5 ef ff ff       	jmp    8010677e <alltraps>

801077d9 <vector244>:
.globl vector244
vector244:
  pushl $0
801077d9:	6a 00                	push   $0x0
  pushl $244
801077db:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801077e0:	e9 99 ef ff ff       	jmp    8010677e <alltraps>

801077e5 <vector245>:
.globl vector245
vector245:
  pushl $0
801077e5:	6a 00                	push   $0x0
  pushl $245
801077e7:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801077ec:	e9 8d ef ff ff       	jmp    8010677e <alltraps>

801077f1 <vector246>:
.globl vector246
vector246:
  pushl $0
801077f1:	6a 00                	push   $0x0
  pushl $246
801077f3:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801077f8:	e9 81 ef ff ff       	jmp    8010677e <alltraps>

801077fd <vector247>:
.globl vector247
vector247:
  pushl $0
801077fd:	6a 00                	push   $0x0
  pushl $247
801077ff:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107804:	e9 75 ef ff ff       	jmp    8010677e <alltraps>

80107809 <vector248>:
.globl vector248
vector248:
  pushl $0
80107809:	6a 00                	push   $0x0
  pushl $248
8010780b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107810:	e9 69 ef ff ff       	jmp    8010677e <alltraps>

80107815 <vector249>:
.globl vector249
vector249:
  pushl $0
80107815:	6a 00                	push   $0x0
  pushl $249
80107817:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010781c:	e9 5d ef ff ff       	jmp    8010677e <alltraps>

80107821 <vector250>:
.globl vector250
vector250:
  pushl $0
80107821:	6a 00                	push   $0x0
  pushl $250
80107823:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107828:	e9 51 ef ff ff       	jmp    8010677e <alltraps>

8010782d <vector251>:
.globl vector251
vector251:
  pushl $0
8010782d:	6a 00                	push   $0x0
  pushl $251
8010782f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107834:	e9 45 ef ff ff       	jmp    8010677e <alltraps>

80107839 <vector252>:
.globl vector252
vector252:
  pushl $0
80107839:	6a 00                	push   $0x0
  pushl $252
8010783b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107840:	e9 39 ef ff ff       	jmp    8010677e <alltraps>

80107845 <vector253>:
.globl vector253
vector253:
  pushl $0
80107845:	6a 00                	push   $0x0
  pushl $253
80107847:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010784c:	e9 2d ef ff ff       	jmp    8010677e <alltraps>

80107851 <vector254>:
.globl vector254
vector254:
  pushl $0
80107851:	6a 00                	push   $0x0
  pushl $254
80107853:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107858:	e9 21 ef ff ff       	jmp    8010677e <alltraps>

8010785d <vector255>:
.globl vector255
vector255:
  pushl $0
8010785d:	6a 00                	push   $0x0
  pushl $255
8010785f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107864:	e9 15 ef ff ff       	jmp    8010677e <alltraps>

80107869 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107869:	55                   	push   %ebp
8010786a:	89 e5                	mov    %esp,%ebp
8010786c:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010786f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107872:	83 e8 01             	sub    $0x1,%eax
80107875:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107879:	8b 45 08             	mov    0x8(%ebp),%eax
8010787c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107880:	8b 45 08             	mov    0x8(%ebp),%eax
80107883:	c1 e8 10             	shr    $0x10,%eax
80107886:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010788a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010788d:	0f 01 10             	lgdtl  (%eax)
}
80107890:	c9                   	leave  
80107891:	c3                   	ret    

80107892 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107892:	55                   	push   %ebp
80107893:	89 e5                	mov    %esp,%ebp
80107895:	83 ec 04             	sub    $0x4,%esp
80107898:	8b 45 08             	mov    0x8(%ebp),%eax
8010789b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010789f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078a3:	0f 00 d8             	ltr    %ax
}
801078a6:	c9                   	leave  
801078a7:	c3                   	ret    

801078a8 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801078a8:	55                   	push   %ebp
801078a9:	89 e5                	mov    %esp,%ebp
801078ab:	83 ec 04             	sub    $0x4,%esp
801078ae:	8b 45 08             	mov    0x8(%ebp),%eax
801078b1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801078b5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078b9:	8e e8                	mov    %eax,%gs
}
801078bb:	c9                   	leave  
801078bc:	c3                   	ret    

801078bd <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801078bd:	55                   	push   %ebp
801078be:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801078c0:	8b 45 08             	mov    0x8(%ebp),%eax
801078c3:	0f 22 d8             	mov    %eax,%cr3
}
801078c6:	5d                   	pop    %ebp
801078c7:	c3                   	ret    

801078c8 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801078c8:	55                   	push   %ebp
801078c9:	89 e5                	mov    %esp,%ebp
801078cb:	8b 45 08             	mov    0x8(%ebp),%eax
801078ce:	05 00 00 00 80       	add    $0x80000000,%eax
801078d3:	5d                   	pop    %ebp
801078d4:	c3                   	ret    

801078d5 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801078d5:	55                   	push   %ebp
801078d6:	89 e5                	mov    %esp,%ebp
801078d8:	8b 45 08             	mov    0x8(%ebp),%eax
801078db:	05 00 00 00 80       	add    $0x80000000,%eax
801078e0:	5d                   	pop    %ebp
801078e1:	c3                   	ret    

801078e2 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801078e2:	55                   	push   %ebp
801078e3:	89 e5                	mov    %esp,%ebp
801078e5:	53                   	push   %ebx
801078e6:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801078e9:	e8 8a b5 ff ff       	call   80102e78 <cpunum>
801078ee:	89 c2                	mov    %eax,%edx
801078f0:	89 d0                	mov    %edx,%eax
801078f2:	01 c0                	add    %eax,%eax
801078f4:	01 d0                	add    %edx,%eax
801078f6:	c1 e0 06             	shl    $0x6,%eax
801078f9:	05 60 33 11 80       	add    $0x80113360,%eax
801078fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107904:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010790a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790d:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107916:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010791a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107921:	83 e2 f0             	and    $0xfffffff0,%edx
80107924:	83 ca 0a             	or     $0xa,%edx
80107927:	88 50 7d             	mov    %dl,0x7d(%eax)
8010792a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107931:	83 ca 10             	or     $0x10,%edx
80107934:	88 50 7d             	mov    %dl,0x7d(%eax)
80107937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010793e:	83 e2 9f             	and    $0xffffff9f,%edx
80107941:	88 50 7d             	mov    %dl,0x7d(%eax)
80107944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107947:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010794b:	83 ca 80             	or     $0xffffff80,%edx
8010794e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107954:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107958:	83 ca 0f             	or     $0xf,%edx
8010795b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010795e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107961:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107965:	83 e2 ef             	and    $0xffffffef,%edx
80107968:	88 50 7e             	mov    %dl,0x7e(%eax)
8010796b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107972:	83 e2 df             	and    $0xffffffdf,%edx
80107975:	88 50 7e             	mov    %dl,0x7e(%eax)
80107978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010797f:	83 ca 40             	or     $0x40,%edx
80107982:	88 50 7e             	mov    %dl,0x7e(%eax)
80107985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107988:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010798c:	83 ca 80             	or     $0xffffff80,%edx
8010798f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107995:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801079a3:	ff ff 
801079a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a8:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801079af:	00 00 
801079b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b4:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801079bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079be:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079c5:	83 e2 f0             	and    $0xfffffff0,%edx
801079c8:	83 ca 02             	or     $0x2,%edx
801079cb:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079db:	83 ca 10             	or     $0x10,%edx
801079de:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e7:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079ee:	83 e2 9f             	and    $0xffffff9f,%edx
801079f1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fa:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a01:	83 ca 80             	or     $0xffffff80,%edx
80107a04:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a14:	83 ca 0f             	or     $0xf,%edx
80107a17:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a20:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a27:	83 e2 ef             	and    $0xffffffef,%edx
80107a2a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a33:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a3a:	83 e2 df             	and    $0xffffffdf,%edx
80107a3d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a4d:	83 ca 40             	or     $0x40,%edx
80107a50:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a59:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a60:	83 ca 80             	or     $0xffffff80,%edx
80107a63:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6c:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a76:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107a7d:	ff ff 
80107a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a82:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a89:	00 00 
80107a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8e:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a98:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a9f:	83 e2 f0             	and    $0xfffffff0,%edx
80107aa2:	83 ca 0a             	or     $0xa,%edx
80107aa5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aae:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ab5:	83 ca 10             	or     $0x10,%edx
80107ab8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ac8:	83 ca 60             	or     $0x60,%edx
80107acb:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107adb:	83 ca 80             	or     $0xffffff80,%edx
80107ade:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107aee:	83 ca 0f             	or     $0xf,%edx
80107af1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afa:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b01:	83 e2 ef             	and    $0xffffffef,%edx
80107b04:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b14:	83 e2 df             	and    $0xffffffdf,%edx
80107b17:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b20:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b27:	83 ca 40             	or     $0x40,%edx
80107b2a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b33:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b3a:	83 ca 80             	or     $0xffffff80,%edx
80107b3d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b46:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b50:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107b57:	ff ff 
80107b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5c:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107b63:	00 00 
80107b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b68:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b72:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b79:	83 e2 f0             	and    $0xfffffff0,%edx
80107b7c:	83 ca 02             	or     $0x2,%edx
80107b7f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b88:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b8f:	83 ca 10             	or     $0x10,%edx
80107b92:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ba2:	83 ca 60             	or     $0x60,%edx
80107ba5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bae:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bb5:	83 ca 80             	or     $0xffffff80,%edx
80107bb8:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bc8:	83 ca 0f             	or     $0xf,%edx
80107bcb:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bdb:	83 e2 ef             	and    $0xffffffef,%edx
80107bde:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bee:	83 e2 df             	and    $0xffffffdf,%edx
80107bf1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfa:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c01:	83 ca 40             	or     $0x40,%edx
80107c04:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c14:	83 ca 80             	or     $0xffffff80,%edx
80107c17:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c20:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2a:	05 b4 00 00 00       	add    $0xb4,%eax
80107c2f:	89 c3                	mov    %eax,%ebx
80107c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c34:	05 b4 00 00 00       	add    $0xb4,%eax
80107c39:	c1 e8 10             	shr    $0x10,%eax
80107c3c:	89 c1                	mov    %eax,%ecx
80107c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c41:	05 b4 00 00 00       	add    $0xb4,%eax
80107c46:	c1 e8 18             	shr    $0x18,%eax
80107c49:	89 c2                	mov    %eax,%edx
80107c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4e:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107c55:	00 00 
80107c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5a:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c64:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6d:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c74:	83 e1 f0             	and    $0xfffffff0,%ecx
80107c77:	83 c9 02             	or     $0x2,%ecx
80107c7a:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c83:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c8a:	83 c9 10             	or     $0x10,%ecx
80107c8d:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c96:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c9d:	83 e1 9f             	and    $0xffffff9f,%ecx
80107ca0:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca9:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107cb0:	83 c9 80             	or     $0xffffff80,%ecx
80107cb3:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbc:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cc3:	83 e1 f0             	and    $0xfffffff0,%ecx
80107cc6:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccf:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cd6:	83 e1 ef             	and    $0xffffffef,%ecx
80107cd9:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce2:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ce9:	83 e1 df             	and    $0xffffffdf,%ecx
80107cec:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf5:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cfc:	83 c9 40             	or     $0x40,%ecx
80107cff:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d08:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d0f:	83 c9 80             	or     $0xffffff80,%ecx
80107d12:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1b:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d24:	83 c0 70             	add    $0x70,%eax
80107d27:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107d2e:	00 
80107d2f:	89 04 24             	mov    %eax,(%esp)
80107d32:	e8 32 fb ff ff       	call   80107869 <lgdt>
  loadgs(SEG_KCPU << 3);
80107d37:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107d3e:	e8 65 fb ff ff       	call   801078a8 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d46:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107d4c:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107d53:	00 00 00 00 
}
80107d57:	83 c4 24             	add    $0x24,%esp
80107d5a:	5b                   	pop    %ebx
80107d5b:	5d                   	pop    %ebp
80107d5c:	c3                   	ret    

80107d5d <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107d5d:	55                   	push   %ebp
80107d5e:	89 e5                	mov    %esp,%ebp
80107d60:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107d63:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d66:	c1 e8 16             	shr    $0x16,%eax
80107d69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d70:	8b 45 08             	mov    0x8(%ebp),%eax
80107d73:	01 d0                	add    %edx,%eax
80107d75:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d7b:	8b 00                	mov    (%eax),%eax
80107d7d:	83 e0 01             	and    $0x1,%eax
80107d80:	85 c0                	test   %eax,%eax
80107d82:	74 17                	je     80107d9b <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107d84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d87:	8b 00                	mov    (%eax),%eax
80107d89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d8e:	89 04 24             	mov    %eax,(%esp)
80107d91:	e8 3f fb ff ff       	call   801078d5 <p2v>
80107d96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d99:	eb 4b                	jmp    80107de6 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107d9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107d9f:	74 0e                	je     80107daf <walkpgdir+0x52>
80107da1:	e8 3c ad ff ff       	call   80102ae2 <kalloc>
80107da6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107da9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107dad:	75 07                	jne    80107db6 <walkpgdir+0x59>
      return 0;
80107daf:	b8 00 00 00 00       	mov    $0x0,%eax
80107db4:	eb 47                	jmp    80107dfd <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107db6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107dbd:	00 
80107dbe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107dc5:	00 
80107dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc9:	89 04 24             	mov    %eax,(%esp)
80107dcc:	e8 be d5 ff ff       	call   8010538f <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd4:	89 04 24             	mov    %eax,(%esp)
80107dd7:	e8 ec fa ff ff       	call   801078c8 <v2p>
80107ddc:	83 c8 07             	or     $0x7,%eax
80107ddf:	89 c2                	mov    %eax,%edx
80107de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107de4:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107de6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107de9:	c1 e8 0c             	shr    $0xc,%eax
80107dec:	25 ff 03 00 00       	and    $0x3ff,%eax
80107df1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfb:	01 d0                	add    %edx,%eax
}
80107dfd:	c9                   	leave  
80107dfe:	c3                   	ret    

80107dff <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107dff:	55                   	push   %ebp
80107e00:	89 e5                	mov    %esp,%ebp
80107e02:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107e05:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e10:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e13:	8b 45 10             	mov    0x10(%ebp),%eax
80107e16:	01 d0                	add    %edx,%eax
80107e18:	83 e8 01             	sub    $0x1,%eax
80107e1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e23:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107e2a:	00 
80107e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e32:	8b 45 08             	mov    0x8(%ebp),%eax
80107e35:	89 04 24             	mov    %eax,(%esp)
80107e38:	e8 20 ff ff ff       	call   80107d5d <walkpgdir>
80107e3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e40:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e44:	75 07                	jne    80107e4d <mappages+0x4e>
      return -1;
80107e46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e4b:	eb 48                	jmp    80107e95 <mappages+0x96>
    if(*pte & PTE_P)
80107e4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e50:	8b 00                	mov    (%eax),%eax
80107e52:	83 e0 01             	and    $0x1,%eax
80107e55:	85 c0                	test   %eax,%eax
80107e57:	74 0c                	je     80107e65 <mappages+0x66>
      panic("remap");
80107e59:	c7 04 24 6c 8f 10 80 	movl   $0x80108f6c,(%esp)
80107e60:	e8 d5 86 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107e65:	8b 45 18             	mov    0x18(%ebp),%eax
80107e68:	0b 45 14             	or     0x14(%ebp),%eax
80107e6b:	83 c8 01             	or     $0x1,%eax
80107e6e:	89 c2                	mov    %eax,%edx
80107e70:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e73:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e78:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107e7b:	75 08                	jne    80107e85 <mappages+0x86>
      break;
80107e7d:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107e7e:	b8 00 00 00 00       	mov    $0x0,%eax
80107e83:	eb 10                	jmp    80107e95 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107e85:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107e8c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107e93:	eb 8e                	jmp    80107e23 <mappages+0x24>
  return 0;
}
80107e95:	c9                   	leave  
80107e96:	c3                   	ret    

80107e97 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107e97:	55                   	push   %ebp
80107e98:	89 e5                	mov    %esp,%ebp
80107e9a:	53                   	push   %ebx
80107e9b:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107e9e:	e8 3f ac ff ff       	call   80102ae2 <kalloc>
80107ea3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ea6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107eaa:	75 0a                	jne    80107eb6 <setupkvm+0x1f>
    return 0;
80107eac:	b8 00 00 00 00       	mov    $0x0,%eax
80107eb1:	e9 98 00 00 00       	jmp    80107f4e <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107eb6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ebd:	00 
80107ebe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ec5:	00 
80107ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ec9:	89 04 24             	mov    %eax,(%esp)
80107ecc:	e8 be d4 ff ff       	call   8010538f <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107ed1:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107ed8:	e8 f8 f9 ff ff       	call   801078d5 <p2v>
80107edd:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107ee2:	76 0c                	jbe    80107ef0 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107ee4:	c7 04 24 72 8f 10 80 	movl   $0x80108f72,(%esp)
80107eeb:	e8 4a 86 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ef0:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80107ef7:	eb 49                	jmp    80107f42 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efc:	8b 48 0c             	mov    0xc(%eax),%ecx
80107eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f02:	8b 50 04             	mov    0x4(%eax),%edx
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	8b 58 08             	mov    0x8(%eax),%ebx
80107f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0e:	8b 40 04             	mov    0x4(%eax),%eax
80107f11:	29 c3                	sub    %eax,%ebx
80107f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f16:	8b 00                	mov    (%eax),%eax
80107f18:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107f1c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107f20:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107f24:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f2b:	89 04 24             	mov    %eax,(%esp)
80107f2e:	e8 cc fe ff ff       	call   80107dff <mappages>
80107f33:	85 c0                	test   %eax,%eax
80107f35:	79 07                	jns    80107f3e <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107f37:	b8 00 00 00 00       	mov    $0x0,%eax
80107f3c:	eb 10                	jmp    80107f4e <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f3e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107f42:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80107f49:	72 ae                	jb     80107ef9 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107f4e:	83 c4 34             	add    $0x34,%esp
80107f51:	5b                   	pop    %ebx
80107f52:	5d                   	pop    %ebp
80107f53:	c3                   	ret    

80107f54 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107f54:	55                   	push   %ebp
80107f55:	89 e5                	mov    %esp,%ebp
80107f57:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107f5a:	e8 38 ff ff ff       	call   80107e97 <setupkvm>
80107f5f:	a3 58 ee 11 80       	mov    %eax,0x8011ee58
  switchkvm();
80107f64:	e8 02 00 00 00       	call   80107f6b <switchkvm>
}
80107f69:	c9                   	leave  
80107f6a:	c3                   	ret    

80107f6b <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107f6b:	55                   	push   %ebp
80107f6c:	89 e5                	mov    %esp,%ebp
80107f6e:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107f71:	a1 58 ee 11 80       	mov    0x8011ee58,%eax
80107f76:	89 04 24             	mov    %eax,(%esp)
80107f79:	e8 4a f9 ff ff       	call   801078c8 <v2p>
80107f7e:	89 04 24             	mov    %eax,(%esp)
80107f81:	e8 37 f9 ff ff       	call   801078bd <lcr3>
}
80107f86:	c9                   	leave  
80107f87:	c3                   	ret    

80107f88 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107f88:	55                   	push   %ebp
80107f89:	89 e5                	mov    %esp,%ebp
80107f8b:	53                   	push   %ebx
80107f8c:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107f8f:	e8 fb d2 ff ff       	call   8010528f <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107f94:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f9a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fa1:	83 c2 08             	add    $0x8,%edx
80107fa4:	89 d3                	mov    %edx,%ebx
80107fa6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fad:	83 c2 08             	add    $0x8,%edx
80107fb0:	c1 ea 10             	shr    $0x10,%edx
80107fb3:	89 d1                	mov    %edx,%ecx
80107fb5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fbc:	83 c2 08             	add    $0x8,%edx
80107fbf:	c1 ea 18             	shr    $0x18,%edx
80107fc2:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107fc9:	67 00 
80107fcb:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107fd2:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107fd8:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107fdf:	83 e1 f0             	and    $0xfffffff0,%ecx
80107fe2:	83 c9 09             	or     $0x9,%ecx
80107fe5:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107feb:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ff2:	83 c9 10             	or     $0x10,%ecx
80107ff5:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ffb:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108002:	83 e1 9f             	and    $0xffffff9f,%ecx
80108005:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010800b:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108012:	83 c9 80             	or     $0xffffff80,%ecx
80108015:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010801b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108022:	83 e1 f0             	and    $0xfffffff0,%ecx
80108025:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010802b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108032:	83 e1 ef             	and    $0xffffffef,%ecx
80108035:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010803b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108042:	83 e1 df             	and    $0xffffffdf,%ecx
80108045:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010804b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108052:	83 c9 40             	or     $0x40,%ecx
80108055:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010805b:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108062:	83 e1 7f             	and    $0x7f,%ecx
80108065:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010806b:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108071:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108077:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010807e:	83 e2 ef             	and    $0xffffffef,%edx
80108081:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108087:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010808d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108093:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108099:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801080a0:	8b 52 08             	mov    0x8(%edx),%edx
801080a3:	81 c2 00 10 00 00    	add    $0x1000,%edx
801080a9:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801080ac:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801080b3:	e8 da f7 ff ff       	call   80107892 <ltr>
  if(p->pgdir == 0)
801080b8:	8b 45 08             	mov    0x8(%ebp),%eax
801080bb:	8b 40 04             	mov    0x4(%eax),%eax
801080be:	85 c0                	test   %eax,%eax
801080c0:	75 0c                	jne    801080ce <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801080c2:	c7 04 24 83 8f 10 80 	movl   $0x80108f83,(%esp)
801080c9:	e8 6c 84 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801080ce:	8b 45 08             	mov    0x8(%ebp),%eax
801080d1:	8b 40 04             	mov    0x4(%eax),%eax
801080d4:	89 04 24             	mov    %eax,(%esp)
801080d7:	e8 ec f7 ff ff       	call   801078c8 <v2p>
801080dc:	89 04 24             	mov    %eax,(%esp)
801080df:	e8 d9 f7 ff ff       	call   801078bd <lcr3>
  popcli();
801080e4:	e8 ea d1 ff ff       	call   801052d3 <popcli>
}
801080e9:	83 c4 14             	add    $0x14,%esp
801080ec:	5b                   	pop    %ebx
801080ed:	5d                   	pop    %ebp
801080ee:	c3                   	ret    

801080ef <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801080ef:	55                   	push   %ebp
801080f0:	89 e5                	mov    %esp,%ebp
801080f2:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801080f5:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801080fc:	76 0c                	jbe    8010810a <inituvm+0x1b>
    panic("inituvm: more than a page");
801080fe:	c7 04 24 97 8f 10 80 	movl   $0x80108f97,(%esp)
80108105:	e8 30 84 ff ff       	call   8010053a <panic>
  mem = kalloc();
8010810a:	e8 d3 a9 ff ff       	call   80102ae2 <kalloc>
8010810f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108112:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108119:	00 
8010811a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108121:	00 
80108122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108125:	89 04 24             	mov    %eax,(%esp)
80108128:	e8 62 d2 ff ff       	call   8010538f <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010812d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108130:	89 04 24             	mov    %eax,(%esp)
80108133:	e8 90 f7 ff ff       	call   801078c8 <v2p>
80108138:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010813f:	00 
80108140:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108144:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010814b:	00 
8010814c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108153:	00 
80108154:	8b 45 08             	mov    0x8(%ebp),%eax
80108157:	89 04 24             	mov    %eax,(%esp)
8010815a:	e8 a0 fc ff ff       	call   80107dff <mappages>
  memmove(mem, init, sz);
8010815f:	8b 45 10             	mov    0x10(%ebp),%eax
80108162:	89 44 24 08          	mov    %eax,0x8(%esp)
80108166:	8b 45 0c             	mov    0xc(%ebp),%eax
80108169:	89 44 24 04          	mov    %eax,0x4(%esp)
8010816d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108170:	89 04 24             	mov    %eax,(%esp)
80108173:	e8 e6 d2 ff ff       	call   8010545e <memmove>
}
80108178:	c9                   	leave  
80108179:	c3                   	ret    

8010817a <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010817a:	55                   	push   %ebp
8010817b:	89 e5                	mov    %esp,%ebp
8010817d:	53                   	push   %ebx
8010817e:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108181:	8b 45 0c             	mov    0xc(%ebp),%eax
80108184:	25 ff 0f 00 00       	and    $0xfff,%eax
80108189:	85 c0                	test   %eax,%eax
8010818b:	74 0c                	je     80108199 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010818d:	c7 04 24 b4 8f 10 80 	movl   $0x80108fb4,(%esp)
80108194:	e8 a1 83 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108199:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081a0:	e9 a9 00 00 00       	jmp    8010824e <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801081a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801081ab:	01 d0                	add    %edx,%eax
801081ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081b4:	00 
801081b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801081b9:	8b 45 08             	mov    0x8(%ebp),%eax
801081bc:	89 04 24             	mov    %eax,(%esp)
801081bf:	e8 99 fb ff ff       	call   80107d5d <walkpgdir>
801081c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081cb:	75 0c                	jne    801081d9 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801081cd:	c7 04 24 d7 8f 10 80 	movl   $0x80108fd7,(%esp)
801081d4:	e8 61 83 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801081d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081dc:	8b 00                	mov    (%eax),%eax
801081de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801081e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e9:	8b 55 18             	mov    0x18(%ebp),%edx
801081ec:	29 c2                	sub    %eax,%edx
801081ee:	89 d0                	mov    %edx,%eax
801081f0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801081f5:	77 0f                	ja     80108206 <loaduvm+0x8c>
      n = sz - i;
801081f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fa:	8b 55 18             	mov    0x18(%ebp),%edx
801081fd:	29 c2                	sub    %eax,%edx
801081ff:	89 d0                	mov    %edx,%eax
80108201:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108204:	eb 07                	jmp    8010820d <loaduvm+0x93>
    else
      n = PGSIZE;
80108206:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010820d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108210:	8b 55 14             	mov    0x14(%ebp),%edx
80108213:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108216:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108219:	89 04 24             	mov    %eax,(%esp)
8010821c:	e8 b4 f6 ff ff       	call   801078d5 <p2v>
80108221:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108224:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108228:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010822c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108230:	8b 45 10             	mov    0x10(%ebp),%eax
80108233:	89 04 24             	mov    %eax,(%esp)
80108236:	e8 2d 9b ff ff       	call   80101d68 <readi>
8010823b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010823e:	74 07                	je     80108247 <loaduvm+0xcd>
      return -1;
80108240:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108245:	eb 18                	jmp    8010825f <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108247:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010824e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108251:	3b 45 18             	cmp    0x18(%ebp),%eax
80108254:	0f 82 4b ff ff ff    	jb     801081a5 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010825a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010825f:	83 c4 24             	add    $0x24,%esp
80108262:	5b                   	pop    %ebx
80108263:	5d                   	pop    %ebp
80108264:	c3                   	ret    

80108265 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108265:	55                   	push   %ebp
80108266:	89 e5                	mov    %esp,%ebp
80108268:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010826b:	8b 45 10             	mov    0x10(%ebp),%eax
8010826e:	85 c0                	test   %eax,%eax
80108270:	79 0a                	jns    8010827c <allocuvm+0x17>
    return 0;
80108272:	b8 00 00 00 00       	mov    $0x0,%eax
80108277:	e9 c1 00 00 00       	jmp    8010833d <allocuvm+0xd8>
  if(newsz < oldsz)
8010827c:	8b 45 10             	mov    0x10(%ebp),%eax
8010827f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108282:	73 08                	jae    8010828c <allocuvm+0x27>
    return oldsz;
80108284:	8b 45 0c             	mov    0xc(%ebp),%eax
80108287:	e9 b1 00 00 00       	jmp    8010833d <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010828c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010828f:	05 ff 0f 00 00       	add    $0xfff,%eax
80108294:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108299:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010829c:	e9 8d 00 00 00       	jmp    8010832e <allocuvm+0xc9>
    mem = kalloc();
801082a1:	e8 3c a8 ff ff       	call   80102ae2 <kalloc>
801082a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801082a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082ad:	75 2c                	jne    801082db <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801082af:	c7 04 24 f5 8f 10 80 	movl   $0x80108ff5,(%esp)
801082b6:	e8 e5 80 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801082bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801082be:	89 44 24 08          	mov    %eax,0x8(%esp)
801082c2:	8b 45 10             	mov    0x10(%ebp),%eax
801082c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801082c9:	8b 45 08             	mov    0x8(%ebp),%eax
801082cc:	89 04 24             	mov    %eax,(%esp)
801082cf:	e8 6b 00 00 00       	call   8010833f <deallocuvm>
      return 0;
801082d4:	b8 00 00 00 00       	mov    $0x0,%eax
801082d9:	eb 62                	jmp    8010833d <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801082db:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082e2:	00 
801082e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082ea:	00 
801082eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ee:	89 04 24             	mov    %eax,(%esp)
801082f1:	e8 99 d0 ff ff       	call   8010538f <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801082f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f9:	89 04 24             	mov    %eax,(%esp)
801082fc:	e8 c7 f5 ff ff       	call   801078c8 <v2p>
80108301:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108304:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010830b:	00 
8010830c:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108310:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108317:	00 
80108318:	89 54 24 04          	mov    %edx,0x4(%esp)
8010831c:	8b 45 08             	mov    0x8(%ebp),%eax
8010831f:	89 04 24             	mov    %eax,(%esp)
80108322:	e8 d8 fa ff ff       	call   80107dff <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108327:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010832e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108331:	3b 45 10             	cmp    0x10(%ebp),%eax
80108334:	0f 82 67 ff ff ff    	jb     801082a1 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010833a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010833d:	c9                   	leave  
8010833e:	c3                   	ret    

8010833f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010833f:	55                   	push   %ebp
80108340:	89 e5                	mov    %esp,%ebp
80108342:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108345:	8b 45 10             	mov    0x10(%ebp),%eax
80108348:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010834b:	72 08                	jb     80108355 <deallocuvm+0x16>
    return oldsz;
8010834d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108350:	e9 a4 00 00 00       	jmp    801083f9 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108355:	8b 45 10             	mov    0x10(%ebp),%eax
80108358:	05 ff 0f 00 00       	add    $0xfff,%eax
8010835d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108362:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108365:	e9 80 00 00 00       	jmp    801083ea <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010836a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108374:	00 
80108375:	89 44 24 04          	mov    %eax,0x4(%esp)
80108379:	8b 45 08             	mov    0x8(%ebp),%eax
8010837c:	89 04 24             	mov    %eax,(%esp)
8010837f:	e8 d9 f9 ff ff       	call   80107d5d <walkpgdir>
80108384:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108387:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010838b:	75 09                	jne    80108396 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010838d:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108394:	eb 4d                	jmp    801083e3 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108396:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108399:	8b 00                	mov    (%eax),%eax
8010839b:	83 e0 01             	and    $0x1,%eax
8010839e:	85 c0                	test   %eax,%eax
801083a0:	74 41                	je     801083e3 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801083a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083a5:	8b 00                	mov    (%eax),%eax
801083a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801083af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083b3:	75 0c                	jne    801083c1 <deallocuvm+0x82>
        panic("kfree");
801083b5:	c7 04 24 0d 90 10 80 	movl   $0x8010900d,(%esp)
801083bc:	e8 79 81 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
801083c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083c4:	89 04 24             	mov    %eax,(%esp)
801083c7:	e8 09 f5 ff ff       	call   801078d5 <p2v>
801083cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801083cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083d2:	89 04 24             	mov    %eax,(%esp)
801083d5:	e8 6f a6 ff ff       	call   80102a49 <kfree>
      *pte = 0;
801083da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801083e3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ed:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083f0:	0f 82 74 ff ff ff    	jb     8010836a <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801083f6:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083f9:	c9                   	leave  
801083fa:	c3                   	ret    

801083fb <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801083fb:	55                   	push   %ebp
801083fc:	89 e5                	mov    %esp,%ebp
801083fe:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108401:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108405:	75 0c                	jne    80108413 <freevm+0x18>
    panic("freevm: no pgdir");
80108407:	c7 04 24 13 90 10 80 	movl   $0x80109013,(%esp)
8010840e:	e8 27 81 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108413:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010841a:	00 
8010841b:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108422:	80 
80108423:	8b 45 08             	mov    0x8(%ebp),%eax
80108426:	89 04 24             	mov    %eax,(%esp)
80108429:	e8 11 ff ff ff       	call   8010833f <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010842e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108435:	eb 48                	jmp    8010847f <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108441:	8b 45 08             	mov    0x8(%ebp),%eax
80108444:	01 d0                	add    %edx,%eax
80108446:	8b 00                	mov    (%eax),%eax
80108448:	83 e0 01             	and    $0x1,%eax
8010844b:	85 c0                	test   %eax,%eax
8010844d:	74 2c                	je     8010847b <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010844f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108452:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108459:	8b 45 08             	mov    0x8(%ebp),%eax
8010845c:	01 d0                	add    %edx,%eax
8010845e:	8b 00                	mov    (%eax),%eax
80108460:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108465:	89 04 24             	mov    %eax,(%esp)
80108468:	e8 68 f4 ff ff       	call   801078d5 <p2v>
8010846d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108470:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108473:	89 04 24             	mov    %eax,(%esp)
80108476:	e8 ce a5 ff ff       	call   80102a49 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010847b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010847f:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108486:	76 af                	jbe    80108437 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108488:	8b 45 08             	mov    0x8(%ebp),%eax
8010848b:	89 04 24             	mov    %eax,(%esp)
8010848e:	e8 b6 a5 ff ff       	call   80102a49 <kfree>
}
80108493:	c9                   	leave  
80108494:	c3                   	ret    

80108495 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108495:	55                   	push   %ebp
80108496:	89 e5                	mov    %esp,%ebp
80108498:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010849b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084a2:	00 
801084a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801084a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801084aa:	8b 45 08             	mov    0x8(%ebp),%eax
801084ad:	89 04 24             	mov    %eax,(%esp)
801084b0:	e8 a8 f8 ff ff       	call   80107d5d <walkpgdir>
801084b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801084b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801084bc:	75 0c                	jne    801084ca <clearpteu+0x35>
    panic("clearpteu");
801084be:	c7 04 24 24 90 10 80 	movl   $0x80109024,(%esp)
801084c5:	e8 70 80 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
801084ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cd:	8b 00                	mov    (%eax),%eax
801084cf:	83 e0 fb             	and    $0xfffffffb,%eax
801084d2:	89 c2                	mov    %eax,%edx
801084d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d7:	89 10                	mov    %edx,(%eax)
}
801084d9:	c9                   	leave  
801084da:	c3                   	ret    

801084db <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801084db:	55                   	push   %ebp
801084dc:	89 e5                	mov    %esp,%ebp
801084de:	53                   	push   %ebx
801084df:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801084e2:	e8 b0 f9 ff ff       	call   80107e97 <setupkvm>
801084e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084ee:	75 0a                	jne    801084fa <copyuvm+0x1f>
    return 0;
801084f0:	b8 00 00 00 00       	mov    $0x0,%eax
801084f5:	e9 fd 00 00 00       	jmp    801085f7 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801084fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108501:	e9 d0 00 00 00       	jmp    801085d6 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108509:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108510:	00 
80108511:	89 44 24 04          	mov    %eax,0x4(%esp)
80108515:	8b 45 08             	mov    0x8(%ebp),%eax
80108518:	89 04 24             	mov    %eax,(%esp)
8010851b:	e8 3d f8 ff ff       	call   80107d5d <walkpgdir>
80108520:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108523:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108527:	75 0c                	jne    80108535 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108529:	c7 04 24 2e 90 10 80 	movl   $0x8010902e,(%esp)
80108530:	e8 05 80 ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
80108535:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108538:	8b 00                	mov    (%eax),%eax
8010853a:	83 e0 01             	and    $0x1,%eax
8010853d:	85 c0                	test   %eax,%eax
8010853f:	75 0c                	jne    8010854d <copyuvm+0x72>
      panic("copyuvm: page not present");
80108541:	c7 04 24 48 90 10 80 	movl   $0x80109048,(%esp)
80108548:	e8 ed 7f ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
8010854d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108550:	8b 00                	mov    (%eax),%eax
80108552:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108557:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010855a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010855d:	8b 00                	mov    (%eax),%eax
8010855f:	25 ff 0f 00 00       	and    $0xfff,%eax
80108564:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108567:	e8 76 a5 ff ff       	call   80102ae2 <kalloc>
8010856c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010856f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108573:	75 02                	jne    80108577 <copyuvm+0x9c>
      goto bad;
80108575:	eb 70                	jmp    801085e7 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108577:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010857a:	89 04 24             	mov    %eax,(%esp)
8010857d:	e8 53 f3 ff ff       	call   801078d5 <p2v>
80108582:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108589:	00 
8010858a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010858e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108591:	89 04 24             	mov    %eax,(%esp)
80108594:	e8 c5 ce ff ff       	call   8010545e <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108599:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010859c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010859f:	89 04 24             	mov    %eax,(%esp)
801085a2:	e8 21 f3 ff ff       	call   801078c8 <v2p>
801085a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085aa:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801085ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
801085b2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085b9:	00 
801085ba:	89 54 24 04          	mov    %edx,0x4(%esp)
801085be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c1:	89 04 24             	mov    %eax,(%esp)
801085c4:	e8 36 f8 ff ff       	call   80107dff <mappages>
801085c9:	85 c0                	test   %eax,%eax
801085cb:	79 02                	jns    801085cf <copyuvm+0xf4>
      goto bad;
801085cd:	eb 18                	jmp    801085e7 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801085cf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085dc:	0f 82 24 ff ff ff    	jb     80108506 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801085e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e5:	eb 10                	jmp    801085f7 <copyuvm+0x11c>

bad:
  freevm(d);
801085e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085ea:	89 04 24             	mov    %eax,(%esp)
801085ed:	e8 09 fe ff ff       	call   801083fb <freevm>
  return 0;
801085f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085f7:	83 c4 44             	add    $0x44,%esp
801085fa:	5b                   	pop    %ebx
801085fb:	5d                   	pop    %ebp
801085fc:	c3                   	ret    

801085fd <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801085fd:	55                   	push   %ebp
801085fe:	89 e5                	mov    %esp,%ebp
80108600:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108603:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010860a:	00 
8010860b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010860e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108612:	8b 45 08             	mov    0x8(%ebp),%eax
80108615:	89 04 24             	mov    %eax,(%esp)
80108618:	e8 40 f7 ff ff       	call   80107d5d <walkpgdir>
8010861d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108623:	8b 00                	mov    (%eax),%eax
80108625:	83 e0 01             	and    $0x1,%eax
80108628:	85 c0                	test   %eax,%eax
8010862a:	75 07                	jne    80108633 <uva2ka+0x36>
    return 0;
8010862c:	b8 00 00 00 00       	mov    $0x0,%eax
80108631:	eb 25                	jmp    80108658 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108636:	8b 00                	mov    (%eax),%eax
80108638:	83 e0 04             	and    $0x4,%eax
8010863b:	85 c0                	test   %eax,%eax
8010863d:	75 07                	jne    80108646 <uva2ka+0x49>
    return 0;
8010863f:	b8 00 00 00 00       	mov    $0x0,%eax
80108644:	eb 12                	jmp    80108658 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108649:	8b 00                	mov    (%eax),%eax
8010864b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108650:	89 04 24             	mov    %eax,(%esp)
80108653:	e8 7d f2 ff ff       	call   801078d5 <p2v>
}
80108658:	c9                   	leave  
80108659:	c3                   	ret    

8010865a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010865a:	55                   	push   %ebp
8010865b:	89 e5                	mov    %esp,%ebp
8010865d:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108660:	8b 45 10             	mov    0x10(%ebp),%eax
80108663:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108666:	e9 87 00 00 00       	jmp    801086f2 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
8010866b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010866e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108673:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108676:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108679:	89 44 24 04          	mov    %eax,0x4(%esp)
8010867d:	8b 45 08             	mov    0x8(%ebp),%eax
80108680:	89 04 24             	mov    %eax,(%esp)
80108683:	e8 75 ff ff ff       	call   801085fd <uva2ka>
80108688:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010868b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010868f:	75 07                	jne    80108698 <copyout+0x3e>
      return -1;
80108691:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108696:	eb 69                	jmp    80108701 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108698:	8b 45 0c             	mov    0xc(%ebp),%eax
8010869b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010869e:	29 c2                	sub    %eax,%edx
801086a0:	89 d0                	mov    %edx,%eax
801086a2:	05 00 10 00 00       	add    $0x1000,%eax
801086a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801086aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086ad:	3b 45 14             	cmp    0x14(%ebp),%eax
801086b0:	76 06                	jbe    801086b8 <copyout+0x5e>
      n = len;
801086b2:	8b 45 14             	mov    0x14(%ebp),%eax
801086b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801086b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801086be:	29 c2                	sub    %eax,%edx
801086c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086c3:	01 c2                	add    %eax,%edx
801086c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086c8:	89 44 24 08          	mov    %eax,0x8(%esp)
801086cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801086d3:	89 14 24             	mov    %edx,(%esp)
801086d6:	e8 83 cd ff ff       	call   8010545e <memmove>
    len -= n;
801086db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086de:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801086e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086e4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801086e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086ea:	05 00 10 00 00       	add    $0x1000,%eax
801086ef:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801086f2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801086f6:	0f 85 6f ff ff ff    	jne    8010866b <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801086fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108701:	c9                   	leave  
80108702:	c3                   	ret    

80108703 <kthread_create>:
#include "kthread.h"



int
kthread_create(void*(*start_func)(), void* stack, uint stack_size){
80108703:	55                   	push   %ebp
80108704:	89 e5                	mov    %esp,%ebp
80108706:	83 ec 38             	sub    $0x38,%esp

	int i, index,found;
	struct kthread *t=0;
80108709:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
	char *sp;
	acquire(proc->lock);
80108710:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108716:	8b 40 78             	mov    0x78(%eax),%eax
80108719:	89 04 24             	mov    %eax,(%esp)
8010871c:	e8 1a ca ff ff       	call   8010513b <acquire>
	for (i=0; i<=NTHREAD; i++){
80108721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108728:	eb 3f                	jmp    80108769 <kthread_create+0x66>
		if ( proc->threads[i].state==UNUSED){
8010872a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108730:	8b 40 74             	mov    0x74(%eax),%eax
80108733:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108736:	c1 e2 05             	shl    $0x5,%edx
80108739:	01 d0                	add    %edx,%eax
8010873b:	8b 40 04             	mov    0x4(%eax),%eax
8010873e:	85 c0                	test   %eax,%eax
80108740:	75 23                	jne    80108765 <kthread_create+0x62>
			found=1;
80108742:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
			t= &proc->threads[i];
80108749:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010874f:	8b 40 74             	mov    0x74(%eax),%eax
80108752:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108755:	c1 e2 05             	shl    $0x5,%edx
80108758:	01 d0                	add    %edx,%eax
8010875a:	89 45 e8             	mov    %eax,-0x18(%ebp)
			index=i;
8010875d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108760:	89 45 f0             	mov    %eax,-0x10(%ebp)
			break;
80108763:	eb 0a                	jmp    8010876f <kthread_create+0x6c>

	int i, index,found;
	struct kthread *t=0;
	char *sp;
	acquire(proc->lock);
	for (i=0; i<=NTHREAD; i++){
80108765:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108769:	83 7d f4 10          	cmpl   $0x10,-0xc(%ebp)
8010876d:	7e bb                	jle    8010872a <kthread_create+0x27>
			index=i;
			break;
		}
	}

	if (!found){
8010876f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108773:	75 0a                	jne    8010877f <kthread_create+0x7c>
		return -1;
80108775:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010877a:	e9 96 00 00 00       	jmp    80108815 <kthread_create+0x112>
	}

	t->state =EMBRYO;
8010877f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108782:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)

	release(proc->lock);
80108789:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010878f:	8b 40 78             	mov    0x78(%eax),%eax
80108792:	89 04 24             	mov    %eax,(%esp)
80108795:	e8 03 ca ff ff       	call   8010519d <release>

	sp = t->kstack + stack_size;
8010879a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010879d:	8b 10                	mov    (%eax),%edx
8010879f:	8b 45 10             	mov    0x10(%ebp),%eax
801087a2:	01 d0                	add    %edx,%eax
801087a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Leave room for trap frame.
	sp -= sizeof *t->tf;
801087a7:	83 6d e4 4c          	subl   $0x4c,-0x1c(%ebp)
	t->tf = (struct trapframe*)sp;
801087ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801087b1:	89 50 10             	mov    %edx,0x10(%eax)

	// Set up new context to start executing at forkret,
	// which returns to trapret.

	sp -= sizeof *t->context;
801087b4:	83 6d e4 14          	subl   $0x14,-0x1c(%ebp)
	t->context = (struct context*)sp;
801087b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801087be:	89 50 14             	mov    %edx,0x14(%eax)
	memset(t->context, 0, sizeof *t->context);
801087c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087c4:	8b 40 14             	mov    0x14(%eax),%eax
801087c7:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801087ce:	00 
801087cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801087d6:	00 
801087d7:	89 04 24             	mov    %eax,(%esp)
801087da:	e8 b0 cb ff ff       	call   8010538f <memset>
	t->context->eip = (uint)start_func;
801087df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087e2:	8b 40 14             	mov    0x14(%eax),%eax
801087e5:	8b 55 08             	mov    0x8(%ebp),%edx
801087e8:	89 50 10             	mov    %edx,0x10(%eax)
	t->kstack= stack;
801087eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087ee:	8b 55 0c             	mov    0xc(%ebp),%edx
801087f1:	89 10                	mov    %edx,(%eax)
	t->kernelStack=0;
801087f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087f6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	t-> tid= index;
801087fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108800:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108803:	89 50 08             	mov    %edx,0x8(%eax)
	t->state =RUNNABLE;
80108806:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108809:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)

	return 1;
80108810:	b8 01 00 00 00       	mov    $0x1,%eax
}
80108815:	c9                   	leave  
80108816:	c3                   	ret    

80108817 <kthread_id>:

int kthread_id(){
80108817:	55                   	push   %ebp
80108818:	89 e5                	mov    %esp,%ebp

	return thread->tid;
8010881a:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80108820:	8b 40 08             	mov    0x8(%eax),%eax
}
80108823:	5d                   	pop    %ebp
80108824:	c3                   	ret    

80108825 <kthread_exit>:

void kthread_exit(){
80108825:	55                   	push   %ebp
80108826:	89 e5                	mov    %esp,%ebp
80108828:	83 ec 28             	sub    $0x28,%esp



	 int tid;
	 int found=0;
8010882b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)


	 acquire(proc->lock);
80108832:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108838:	8b 40 78             	mov    0x78(%eax),%eax
8010883b:	89 04 24             	mov    %eax,(%esp)
8010883e:	e8 f8 c8 ff ff       	call   8010513b <acquire>

	 thread->state= ZOMBIE;
80108843:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80108849:	c7 40 04 05 00 00 00 	movl   $0x5,0x4(%eax)
	 for (tid=0; tid< NTHREAD; tid++){
80108850:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108857:	eb 3e                	jmp    80108897 <kthread_exit+0x72>
	 	 if( proc->threads[tid].state!= ZOMBIE || proc->threads[tid].state!= UNUSED){
80108859:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010885f:	8b 40 74             	mov    0x74(%eax),%eax
80108862:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108865:	c1 e2 05             	shl    $0x5,%edx
80108868:	01 d0                	add    %edx,%eax
8010886a:	8b 40 04             	mov    0x4(%eax),%eax
8010886d:	83 f8 05             	cmp    $0x5,%eax
80108870:	75 18                	jne    8010888a <kthread_exit+0x65>
80108872:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108878:	8b 40 74             	mov    0x74(%eax),%eax
8010887b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010887e:	c1 e2 05             	shl    $0x5,%edx
80108881:	01 d0                	add    %edx,%eax
80108883:	8b 40 04             	mov    0x4(%eax),%eax
80108886:	85 c0                	test   %eax,%eax
80108888:	74 09                	je     80108893 <kthread_exit+0x6e>
	 		 found=1;
8010888a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	 		 break;
80108891:	eb 0a                	jmp    8010889d <kthread_exit+0x78>


	 acquire(proc->lock);

	 thread->state= ZOMBIE;
	 for (tid=0; tid< NTHREAD; tid++){
80108893:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108897:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010889b:	7e bc                	jle    80108859 <kthread_exit+0x34>
	 		 found=1;
	 		 break;
	 	 }
	 }

	 release(proc->lock);
8010889d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801088a3:	8b 40 78             	mov    0x78(%eax),%eax
801088a6:	89 04 24             	mov    %eax,(%esp)
801088a9:	e8 ef c8 ff ff       	call   8010519d <release>

	 if (!found){ // this was the last thread process needs to exit
801088ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801088b2:	75 05                	jne    801088b9 <kthread_exit+0x94>

		 exit();
801088b4:	e8 54 c0 ff ff       	call   8010490d <exit>
	 }

	 wakeup(thread);
801088b9:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801088bf:	89 04 24             	mov    %eax,(%esp)
801088c2:	e8 2a c6 ff ff       	call   80104ef1 <wakeup>

	 sched();
801088c7:	e8 ac c3 ff ff       	call   80104c78 <sched>
	 panic("zombie exit");
801088cc:	c7 04 24 62 90 10 80 	movl   $0x80109062,(%esp)
801088d3:	e8 62 7c ff ff       	call   8010053a <panic>

801088d8 <kthread_join>:
}

int kthread_join(int thread_id){
801088d8:	55                   	push   %ebp
801088d9:	89 e5                	mov    %esp,%ebp
801088db:	83 ec 28             	sub    $0x28,%esp


	  int found, tid;
	  struct kthread *t;
	  struct kthread *threadFound;
	  acquire(proc->lock);
801088de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801088e4:	8b 40 78             	mov    0x78(%eax),%eax
801088e7:	89 04 24             	mov    %eax,(%esp)
801088ea:	e8 4c c8 ff ff       	call   8010513b <acquire>

	  for(;;){
	    // Scan through table looking for zombie children.
	    found = 0;
801088ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	    for(t = proc->threads; t < &proc->threads[NTHREAD]; t++){
801088f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801088fc:	8b 40 74             	mov    0x74(%eax),%eax
801088ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108902:	eb 6e                	jmp    80108972 <kthread_join+0x9a>

	      if(t->tid != thread->tid)
80108904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108907:	8b 50 08             	mov    0x8(%eax),%edx
8010890a:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80108910:	8b 40 08             	mov    0x8(%eax),%eax
80108913:	39 c2                	cmp    %eax,%edx
80108915:	74 02                	je     80108919 <kthread_join+0x41>
	        continue;
80108917:	eb 55                	jmp    8010896e <kthread_join+0x96>
	      found = 1;
80108919:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	      threadFound= t;
80108920:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108923:	89 45 ec             	mov    %eax,-0x14(%ebp)
	      if(t->state == ZOMBIE){
80108926:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108929:	8b 40 04             	mov    0x4(%eax),%eax
8010892c:	83 f8 05             	cmp    $0x5,%eax
8010892f:	75 3d                	jne    8010896e <kthread_join+0x96>
	        // Found one.
	        tid = t->tid;
80108931:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108934:	8b 40 08             	mov    0x8(%eax),%eax
80108937:	89 45 e8             	mov    %eax,-0x18(%ebp)
	        t->state = UNUSED;
8010893a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010893d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	        t->tid = -1;
80108944:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108947:	c7 40 08 ff ff ff ff 	movl   $0xffffffff,0x8(%eax)
	        t->parent = 0;
8010894e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108951:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	        release(proc->lock);
80108958:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010895e:	8b 40 78             	mov    0x78(%eax),%eax
80108961:	89 04 24             	mov    %eax,(%esp)
80108964:	e8 34 c8 ff ff       	call   8010519d <release>
	        return tid;
80108969:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010896c:	eb 63                	jmp    801089d1 <kthread_join+0xf9>
	  acquire(proc->lock);

	  for(;;){
	    // Scan through table looking for zombie children.
	    found = 0;
	    for(t = proc->threads; t < &proc->threads[NTHREAD]; t++){
8010896e:	83 45 f0 20          	addl   $0x20,-0x10(%ebp)
80108972:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108978:	8b 40 74             	mov    0x74(%eax),%eax
8010897b:	05 00 02 00 00       	add    $0x200,%eax
80108980:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108983:	0f 87 7b ff ff ff    	ja     80108904 <kthread_join+0x2c>
	        return tid;
	      }
	    }

	    // No point waiting if we don't have any children.
	    if(!found || proc->killed){
80108989:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010898d:	74 0d                	je     8010899c <kthread_join+0xc4>
8010898f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108995:	8b 40 1c             	mov    0x1c(%eax),%eax
80108998:	85 c0                	test   %eax,%eax
8010899a:	74 18                	je     801089b4 <kthread_join+0xdc>
	      release(proc->lock);
8010899c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801089a2:	8b 40 78             	mov    0x78(%eax),%eax
801089a5:	89 04 24             	mov    %eax,(%esp)
801089a8:	e8 f0 c7 ff ff       	call   8010519d <release>
	      return -1;
801089ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089b2:	eb 1d                	jmp    801089d1 <kthread_join+0xf9>
	    }

	    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
	    sleep(threadFound, proc->lock);  //DOC: wait-sleep
801089b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801089ba:	8b 40 78             	mov    0x78(%eax),%eax
801089bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801089c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089c4:	89 04 24             	mov    %eax,(%esp)
801089c7:	e8 de c3 ff ff       	call   80104daa <sleep>
	  }
801089cc:	e9 1e ff ff ff       	jmp    801088ef <kthread_join+0x17>
	  return -1;
}
801089d1:	c9                   	leave  
801089d2:	c3                   	ret    
