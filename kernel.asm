
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
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

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
8010003a:	c7 44 24 04 f0 8a 10 	movl   $0x80108af0,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100049:	e8 5d 50 00 00       	call   801050ab <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 15 11 80       	mov    0x80111594,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
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
801000b6:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801000bd:	e8 0a 50 00 00       	call   801050cc <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 15 11 80       	mov    0x80111594,%eax
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
801000fd:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100104:	e8 25 50 00 00       	call   8010512e <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 d6 10 	movl   $0x8010d680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 40 4c 00 00       	call   80104d64 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 15 11 80       	mov    0x80111590,%eax
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
80100175:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010017c:	e8 ad 4f 00 00       	call   8010512e <release>
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
8010018f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 f7 8a 10 80 	movl   $0x80108af7,(%esp)
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
801001ef:	c7 04 24 08 8b 10 80 	movl   $0x80108b08,(%esp)
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
80100229:	c7 04 24 0f 8b 10 80 	movl   $0x80108b0f,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010023c:	e8 8b 4e 00 00       	call   801050cc <acquire>

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
8010025f:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 15 11 80       	mov    0x80111594,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 15 11 80       	mov    %eax,0x80111594

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
8010029d:	e8 cb 4b 00 00       	call   80104e6d <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801002a9:	e8 80 4e 00 00       	call   8010512e <release>
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
801003a6:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
801003bb:	e8 0c 4d 00 00       	call   801050cc <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 16 8b 10 80 	movl   $0x80108b16,(%esp)
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
801004b0:	c7 45 ec 1f 8b 10 80 	movl   $0x80108b1f,-0x14(%ebp)
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
8010052c:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100533:	e8 f6 4b 00 00       	call   8010512e <release>
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
80100545:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 26 8b 10 80 	movl   $0x80108b26,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 35 8b 10 80 	movl   $0x80108b35,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 e9 4b 00 00       	call   8010517d <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 37 8b 10 80 	movl   $0x80108b37,(%esp)
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
801005be:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
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
801006b2:	e8 38 4d 00 00       	call   801053ef <memmove>
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
801006e1:	e8 3a 4c 00 00       	call   80105320 <memset>
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
80100756:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
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
80100776:	e8 18 66 00 00       	call   80106d93 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 0c 66 00 00       	call   80106d93 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 00 66 00 00       	call   80106d93 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 f3 65 00 00       	call   80106d93 <uartputc>
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
801007b3:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
801007ba:	e8 0d 49 00 00       	call   801050cc <acquire>
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
801007ea:	e8 69 47 00 00       	call   80104f58 <procdump>
      break;
801007ef:	e9 07 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 5c 18 11 80       	mov    %eax,0x8011185c
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
80100810:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100816:	a1 58 18 11 80       	mov    0x80111858,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	74 16                	je     80100835 <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100824:	83 e8 01             	sub    $0x1,%eax
80100827:	83 e0 7f             	and    $0x7f,%eax
8010082a:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
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
8010083a:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100840:	a1 58 18 11 80       	mov    0x80111858,%eax
80100845:	39 c2                	cmp    %eax,%edx
80100847:	74 1e                	je     80100867 <consoleintr+0xba>
        input.e--;
80100849:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010084e:	83 e8 01             	sub    $0x1,%eax
80100851:	a3 5c 18 11 80       	mov    %eax,0x8011185c
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
80100876:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
8010087c:	a1 54 18 11 80       	mov    0x80111854,%eax
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
8010089d:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008a2:	8d 50 01             	lea    0x1(%eax),%edx
801008a5:	89 15 5c 18 11 80    	mov    %edx,0x8011185c
801008ab:	83 e0 7f             	and    $0x7f,%eax
801008ae:	89 c2                	mov    %eax,%edx
801008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008b3:	88 82 d4 17 11 80    	mov    %al,-0x7feee82c(%edx)
        consputc(c);
801008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bc:	89 04 24             	mov    %eax,(%esp)
801008bf:	e8 8c fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c4:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008c8:	74 18                	je     801008e2 <consoleintr+0x135>
801008ca:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008ce:	74 12                	je     801008e2 <consoleintr+0x135>
801008d0:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008d5:	8b 15 54 18 11 80    	mov    0x80111854,%edx
801008db:	83 ea 80             	sub    $0xffffff80,%edx
801008de:	39 d0                	cmp    %edx,%eax
801008e0:	75 18                	jne    801008fa <consoleintr+0x14d>
          input.w = input.e;
801008e2:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008e7:	a3 58 18 11 80       	mov    %eax,0x80111858
          wakeup(&input.r);
801008ec:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
801008f3:	e8 75 45 00 00       	call   80104e6d <wakeup>
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
8010090d:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100914:	e8 15 48 00 00       	call   8010512e <release>
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
80100932:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100939:	e8 8e 47 00 00       	call   801050cc <acquire>
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
80100952:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100959:	e8 d0 47 00 00       	call   8010512e <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 f2 0e 00 00       	call   8010185b <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 a0 17 11 	movl   $0x801117a0,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
80100982:	e8 dd 43 00 00       	call   80104d64 <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100987:	8b 15 54 18 11 80    	mov    0x80111854,%edx
8010098d:	a1 58 18 11 80       	mov    0x80111858,%eax
80100992:	39 c2                	cmp    %eax,%edx
80100994:	74 af                	je     80100945 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100996:	a1 54 18 11 80       	mov    0x80111854,%eax
8010099b:	8d 50 01             	lea    0x1(%eax),%edx
8010099e:	89 15 54 18 11 80    	mov    %edx,0x80111854
801009a4:	83 e0 7f             	and    $0x7f,%eax
801009a7:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
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
801009c2:	a1 54 18 11 80       	mov    0x80111854,%eax
801009c7:	83 e8 01             	sub    $0x1,%eax
801009ca:	a3 54 18 11 80       	mov    %eax,0x80111854
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
801009f7:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
801009fe:	e8 2b 47 00 00       	call   8010512e <release>
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
80100a2b:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a32:	e8 95 46 00 00       	call   801050cc <acquire>
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
80100a65:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a6c:	e8 bd 46 00 00       	call   8010512e <release>
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
80100a87:	c7 44 24 04 3b 8b 10 	movl   $0x80108b3b,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a96:	e8 10 46 00 00       	call   801050ab <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 43 8b 10 	movl   $0x80108b43,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100aaa:	e8 fc 45 00 00       	call   801050ab <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aaf:	c7 05 0c 22 11 80 1a 	movl   $0x80100a1a,0x8011220c
80100ab6:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ab9:	c7 05 08 22 11 80 1b 	movl   $0x8010091b,0x80112208
80100ac0:	09 10 80 
  cons.locking = 1;
80100ac3:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
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
80100b73:	e8 71 73 00 00       	call   80107ee9 <setupkvm>
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
80100c14:	e8 9e 76 00 00       	call   801082b7 <allocuvm>
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
80100c52:	e8 75 75 00 00       	call   801081cc <loaduvm>
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
80100cc0:	e8 f2 75 00 00       	call   801082b7 <allocuvm>
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
80100ce5:	e8 fd 77 00 00       	call   801084e7 <clearpteu>
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
80100d1b:	e8 6a 48 00 00       	call   8010558a <strlen>
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
80100d44:	e8 41 48 00 00       	call   8010558a <strlen>
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
80100d74:	e8 33 79 00 00       	call   801086ac <copyout>
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
80100e1b:	e8 8c 78 00 00       	call   801086ac <copyout>
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
80100e73:	e8 c8 46 00 00       	call   80105540 <safestrcpy>

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
80100ec5:	e8 10 71 00 00       	call   80107fda <switchuvm>
  freevm(oldpgdir);
80100eca:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ecd:	89 04 24             	mov    %eax,(%esp)
80100ed0:	e8 78 75 00 00       	call   8010844d <freevm>
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
80100ee8:	e8 60 75 00 00       	call   8010844d <freevm>
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
80100f10:	c7 44 24 04 49 8b 10 	movl   $0x80108b49,0x4(%esp)
80100f17:	80 
80100f18:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f1f:	e8 87 41 00 00       	call   801050ab <initlock>
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
80100f2c:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f33:	e8 94 41 00 00       	call   801050cc <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f38:	c7 45 f4 94 18 11 80 	movl   $0x80111894,-0xc(%ebp)
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
80100f55:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f5c:	e8 cd 41 00 00       	call   8010512e <release>
      return f;
80100f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f64:	eb 1e                	jmp    80100f84 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f66:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f6a:	81 7d f4 f4 21 11 80 	cmpl   $0x801121f4,-0xc(%ebp)
80100f71:	72 ce                	jb     80100f41 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f73:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f7a:	e8 af 41 00 00       	call   8010512e <release>
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
80100f8c:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f93:	e8 34 41 00 00       	call   801050cc <acquire>
  if(f->ref < 1)
80100f98:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9b:	8b 40 04             	mov    0x4(%eax),%eax
80100f9e:	85 c0                	test   %eax,%eax
80100fa0:	7f 0c                	jg     80100fae <filedup+0x28>
    panic("filedup");
80100fa2:	c7 04 24 50 8b 10 80 	movl   $0x80108b50,(%esp)
80100fa9:	e8 8c f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fae:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb1:	8b 40 04             	mov    0x4(%eax),%eax
80100fb4:	8d 50 01             	lea    0x1(%eax),%edx
80100fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80100fba:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbd:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fc4:	e8 65 41 00 00       	call   8010512e <release>
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
80100fd4:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fdb:	e8 ec 40 00 00       	call   801050cc <acquire>
  if(f->ref < 1)
80100fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe3:	8b 40 04             	mov    0x4(%eax),%eax
80100fe6:	85 c0                	test   %eax,%eax
80100fe8:	7f 0c                	jg     80100ff6 <fileclose+0x28>
    panic("fileclose");
80100fea:	c7 04 24 58 8b 10 80 	movl   $0x80108b58,(%esp)
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
8010100f:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80101016:	e8 13 41 00 00       	call   8010512e <release>
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
80101059:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80101060:	e8 c9 40 00 00       	call   8010512e <release>
  
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
801011a1:	c7 04 24 62 8b 10 80 	movl   $0x80108b62,(%esp)
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
801012ad:	c7 04 24 6b 8b 10 80 	movl   $0x80108b6b,(%esp)
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
801012df:	c7 04 24 7b 8b 10 80 	movl   $0x80108b7b,(%esp)
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
80101325:	e8 c5 40 00 00       	call   801053ef <memmove>
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
8010136b:	e8 b0 3f 00 00       	call   80105320 <memset>
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
801014c8:	c7 04 24 85 8b 10 80 	movl   $0x80108b85,(%esp)
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
8010155a:	c7 04 24 9b 8b 10 80 	movl   $0x80108b9b,(%esp)
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
801015aa:	c7 44 24 04 ae 8b 10 	movl   $0x80108bae,0x4(%esp)
801015b1:	80 
801015b2:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801015b9:	e8 ed 3a 00 00       	call   801050ab <initlock>
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
8010163b:	e8 e0 3c 00 00       	call   80105320 <memset>
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
80101691:	c7 04 24 b5 8b 10 80 	movl   $0x80108bb5,(%esp)
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
8010173a:	e8 b0 3c 00 00       	call   801053ef <memmove>
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
8010175d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101764:	e8 63 39 00 00       	call   801050cc <acquire>

  // Is the inode already cached?
  empty = 0;
80101769:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101770:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
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
801017a7:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801017ae:	e8 7b 39 00 00       	call   8010512e <release>
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
801017d2:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
801017d9:	72 9e                	jb     80101779 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017df:	75 0c                	jne    801017ed <iget+0x96>
    panic("iget: no inodes");
801017e1:	c7 04 24 c7 8b 10 80 	movl   $0x80108bc7,(%esp)
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
80101818:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010181f:	e8 0a 39 00 00       	call   8010512e <release>

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
8010182f:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101836:	e8 91 38 00 00       	call   801050cc <acquire>
  ip->ref++;
8010183b:	8b 45 08             	mov    0x8(%ebp),%eax
8010183e:	8b 40 08             	mov    0x8(%eax),%eax
80101841:	8d 50 01             	lea    0x1(%eax),%edx
80101844:	8b 45 08             	mov    0x8(%ebp),%eax
80101847:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010184a:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101851:	e8 d8 38 00 00       	call   8010512e <release>
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
80101871:	c7 04 24 d7 8b 10 80 	movl   $0x80108bd7,(%esp)
80101878:	e8 bd ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010187d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101884:	e8 43 38 00 00       	call   801050cc <acquire>
  while(ip->flags & I_BUSY)
80101889:	eb 13                	jmp    8010189e <ilock+0x43>
    sleep(ip, &icache.lock);
8010188b:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80101892:	80 
80101893:	8b 45 08             	mov    0x8(%ebp),%eax
80101896:	89 04 24             	mov    %eax,(%esp)
80101899:	e8 c6 34 00 00       	call   80104d64 <sleep>

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
801018bc:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801018c3:	e8 66 38 00 00       	call   8010512e <release>

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
8010196e:	e8 7c 3a 00 00       	call   801053ef <memmove>
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
8010199b:	c7 04 24 dd 8b 10 80 	movl   $0x80108bdd,(%esp)
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
801019cc:	c7 04 24 ec 8b 10 80 	movl   $0x80108bec,(%esp)
801019d3:	e8 62 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019d8:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801019df:	e8 e8 36 00 00       	call   801050cc <acquire>
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
801019fb:	e8 6d 34 00 00       	call   80104e6d <wakeup>
  release(&icache.lock);
80101a00:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a07:	e8 22 37 00 00       	call   8010512e <release>
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
80101a14:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a1b:	e8 ac 36 00 00       	call   801050cc <acquire>
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
80101a59:	c7 04 24 f4 8b 10 80 	movl   $0x80108bf4,(%esp)
80101a60:	e8 d5 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a65:	8b 45 08             	mov    0x8(%ebp),%eax
80101a68:	8b 40 0c             	mov    0xc(%eax),%eax
80101a6b:	83 c8 01             	or     $0x1,%eax
80101a6e:	89 c2                	mov    %eax,%edx
80101a70:	8b 45 08             	mov    0x8(%ebp),%eax
80101a73:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a76:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a7d:	e8 ac 36 00 00       	call   8010512e <release>
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
80101aa1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101aa8:	e8 1f 36 00 00       	call   801050cc <acquire>
    ip->flags = 0;
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	89 04 24             	mov    %eax,(%esp)
80101abd:	e8 ab 33 00 00       	call   80104e6d <wakeup>
  }
  ip->ref--;
80101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac5:	8b 40 08             	mov    0x8(%eax),%eax
80101ac8:	8d 50 ff             	lea    -0x1(%eax),%edx
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ad1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101ad8:	e8 51 36 00 00       	call   8010512e <release>
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
80101bf8:	c7 04 24 fe 8b 10 80 	movl   $0x80108bfe,(%esp)
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
80101d9c:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101da3:	85 c0                	test   %eax,%eax
80101da5:	75 0a                	jne    80101db1 <readi+0x49>
      return -1;
80101da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dac:	e9 19 01 00 00       	jmp    80101eca <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101db1:	8b 45 08             	mov    0x8(%ebp),%eax
80101db4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101db8:	98                   	cwtl   
80101db9:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
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
80101e99:	e8 51 35 00 00       	call   801053ef <memmove>
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
80101f00:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80101f07:	85 c0                	test   %eax,%eax
80101f09:	75 0a                	jne    80101f15 <writei+0x49>
      return -1;
80101f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f10:	e9 44 01 00 00       	jmp    80102059 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f1c:	98                   	cwtl   
80101f1d:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
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
80101ff8:	e8 f2 33 00 00       	call   801053ef <memmove>
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
80102076:	e8 17 34 00 00       	call   80105492 <strncmp>
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
80102090:	c7 04 24 11 8c 10 80 	movl   $0x80108c11,(%esp)
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
801020ce:	c7 04 24 23 8c 10 80 	movl   $0x80108c23,(%esp)
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
801021b3:	c7 04 24 23 8c 10 80 	movl   $0x80108c23,(%esp)
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
801021f8:	e8 eb 32 00 00       	call   801054e8 <strncpy>
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
8010222a:	c7 04 24 30 8c 10 80 	movl   $0x80108c30,(%esp)
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
801022af:	e8 3b 31 00 00       	call   801053ef <memmove>
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
801022ca:	e8 20 31 00 00       	call   801053ef <memmove>
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
80102519:	c7 44 24 04 38 8c 10 	movl   $0x80108c38,0x4(%esp)
80102520:	80 
80102521:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102528:	e8 7e 2b 00 00       	call   801050ab <initlock>
  picenable(IRQ_IDE);
8010252d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102534:	e8 8d 18 00 00       	call   80103dc6 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102539:	a1 80 39 11 80       	mov    0x80113980,%eax
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
8010258a:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
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
801025c5:	c7 04 24 3c 8c 10 80 	movl   $0x80108c3c,(%esp)
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
801026e4:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801026eb:	e8 dc 29 00 00       	call   801050cc <acquire>
  if((b = idequeue) == 0){
801026f0:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801026f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801026fc:	75 11                	jne    8010270f <ideintr+0x31>
    release(&idelock);
801026fe:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102705:	e8 24 2a 00 00       	call   8010512e <release>
    // cprintf("spurious IDE interrupt\n");
    return;
8010270a:	e9 90 00 00 00       	jmp    8010279f <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010270f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102712:	8b 40 14             	mov    0x14(%eax),%eax
80102715:	a3 54 c6 10 80       	mov    %eax,0x8010c654

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
80102778:	e8 f0 26 00 00       	call   80104e6d <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010277d:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102782:	85 c0                	test   %eax,%eax
80102784:	74 0d                	je     80102793 <ideintr+0xb5>
    idestart(idequeue);
80102786:	a1 54 c6 10 80       	mov    0x8010c654,%eax
8010278b:	89 04 24             	mov    %eax,(%esp)
8010278e:	e8 26 fe ff ff       	call   801025b9 <idestart>

  release(&idelock);
80102793:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
8010279a:	e8 8f 29 00 00       	call   8010512e <release>
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
801027b3:	c7 04 24 45 8c 10 80 	movl   $0x80108c45,(%esp)
801027ba:	e8 7b dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027bf:	8b 45 08             	mov    0x8(%ebp),%eax
801027c2:	8b 00                	mov    (%eax),%eax
801027c4:	83 e0 06             	and    $0x6,%eax
801027c7:	83 f8 02             	cmp    $0x2,%eax
801027ca:	75 0c                	jne    801027d8 <iderw+0x37>
    panic("iderw: nothing to do");
801027cc:	c7 04 24 59 8c 10 80 	movl   $0x80108c59,(%esp)
801027d3:	e8 62 dd ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801027d8:	8b 45 08             	mov    0x8(%ebp),%eax
801027db:	8b 40 04             	mov    0x4(%eax),%eax
801027de:	85 c0                	test   %eax,%eax
801027e0:	74 15                	je     801027f7 <iderw+0x56>
801027e2:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801027e7:	85 c0                	test   %eax,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027eb:	c7 04 24 6e 8c 10 80 	movl   $0x80108c6e,(%esp)
801027f2:	e8 43 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801027f7:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801027fe:	e8 c9 28 00 00       	call   801050cc <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010280d:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
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
80102832:	a1 54 c6 10 80       	mov    0x8010c654,%eax
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
8010284b:	c7 44 24 04 20 c6 10 	movl   $0x8010c620,0x4(%esp)
80102852:	80 
80102853:	8b 45 08             	mov    0x8(%ebp),%eax
80102856:	89 04 24             	mov    %eax,(%esp)
80102859:	e8 06 25 00 00       	call   80104d64 <sleep>
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
8010286b:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102872:	e8 b7 28 00 00       	call   8010512e <release>
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
8010287c:	a1 34 32 11 80       	mov    0x80113234,%eax
80102881:	8b 55 08             	mov    0x8(%ebp),%edx
80102884:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102886:	a1 34 32 11 80       	mov    0x80113234,%eax
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
80102893:	a1 34 32 11 80       	mov    0x80113234,%eax
80102898:	8b 55 08             	mov    0x8(%ebp),%edx
8010289b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010289d:	a1 34 32 11 80       	mov    0x80113234,%eax
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
801028b0:	a1 64 33 11 80       	mov    0x80113364,%eax
801028b5:	85 c0                	test   %eax,%eax
801028b7:	75 05                	jne    801028be <ioapicinit+0x14>
    return;
801028b9:	e9 9d 00 00 00       	jmp    8010295b <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801028be:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
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
801028f1:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
801028f8:	0f b6 c0             	movzbl %al,%eax
801028fb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801028fe:	74 0c                	je     8010290c <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102900:	c7 04 24 8c 8c 10 80 	movl   $0x80108c8c,(%esp)
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
80102963:	a1 64 33 11 80       	mov    0x80113364,%eax
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
801029ba:	c7 44 24 04 be 8c 10 	movl   $0x80108cbe,0x4(%esp)
801029c1:	80 
801029c2:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
801029c9:	e8 dd 26 00 00       	call   801050ab <initlock>
  kmem.use_lock = 0;
801029ce:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
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
80102a04:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
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
80102a5b:	81 7d 08 7c f0 11 80 	cmpl   $0x8011f07c,0x8(%ebp)
80102a62:	72 12                	jb     80102a76 <kfree+0x2d>
80102a64:	8b 45 08             	mov    0x8(%ebp),%eax
80102a67:	89 04 24             	mov    %eax,(%esp)
80102a6a:	e8 38 ff ff ff       	call   801029a7 <v2p>
80102a6f:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a74:	76 0c                	jbe    80102a82 <kfree+0x39>
    panic("kfree");
80102a76:	c7 04 24 c3 8c 10 80 	movl   $0x80108cc3,(%esp)
80102a7d:	e8 b8 da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a82:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a89:	00 
80102a8a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a91:	00 
80102a92:	8b 45 08             	mov    0x8(%ebp),%eax
80102a95:	89 04 24             	mov    %eax,(%esp)
80102a98:	e8 83 28 00 00       	call   80105320 <memset>

  if(kmem.use_lock)
80102a9d:	a1 74 32 11 80       	mov    0x80113274,%eax
80102aa2:	85 c0                	test   %eax,%eax
80102aa4:	74 0c                	je     80102ab2 <kfree+0x69>
    acquire(&kmem.lock);
80102aa6:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102aad:	e8 1a 26 00 00       	call   801050cc <acquire>
  r = (struct run*)v;
80102ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ab8:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac1:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac6:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102acb:	a1 74 32 11 80       	mov    0x80113274,%eax
80102ad0:	85 c0                	test   %eax,%eax
80102ad2:	74 0c                	je     80102ae0 <kfree+0x97>
    release(&kmem.lock);
80102ad4:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102adb:	e8 4e 26 00 00       	call   8010512e <release>
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
80102ae8:	a1 74 32 11 80       	mov    0x80113274,%eax
80102aed:	85 c0                	test   %eax,%eax
80102aef:	74 0c                	je     80102afd <kalloc+0x1b>
    acquire(&kmem.lock);
80102af1:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102af8:	e8 cf 25 00 00       	call   801050cc <acquire>
  r = kmem.freelist;
80102afd:	a1 78 32 11 80       	mov    0x80113278,%eax
80102b02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b09:	74 0a                	je     80102b15 <kalloc+0x33>
    kmem.freelist = r->next;
80102b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0e:	8b 00                	mov    (%eax),%eax
80102b10:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102b15:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b1a:	85 c0                	test   %eax,%eax
80102b1c:	74 0c                	je     80102b2a <kalloc+0x48>
    release(&kmem.lock);
80102b1e:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102b25:	e8 04 26 00 00       	call   8010512e <release>
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
80102b93:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102b98:	83 c8 40             	or     $0x40,%eax
80102b9b:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
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
80102bb6:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
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
80102be5:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102bea:	21 d0                	and    %edx,%eax
80102bec:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102bf1:	b8 00 00 00 00       	mov    $0x0,%eax
80102bf6:	e9 a2 00 00 00       	jmp    80102c9d <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102bfb:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c00:	83 e0 40             	and    $0x40,%eax
80102c03:	85 c0                	test   %eax,%eax
80102c05:	74 14                	je     80102c1b <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c07:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c0e:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c13:	83 e0 bf             	and    $0xffffffbf,%eax
80102c16:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102c1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c1e:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c23:	0f b6 00             	movzbl (%eax),%eax
80102c26:	0f b6 d0             	movzbl %al,%edx
80102c29:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c2e:	09 d0                	or     %edx,%eax
80102c30:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102c35:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c38:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102c3d:	0f b6 00             	movzbl (%eax),%eax
80102c40:	0f b6 d0             	movzbl %al,%edx
80102c43:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c48:	31 d0                	xor    %edx,%eax
80102c4a:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c4f:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c54:	83 e0 03             	and    $0x3,%eax
80102c57:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102c5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c61:	01 d0                	add    %edx,%eax
80102c63:	0f b6 00             	movzbl (%eax),%eax
80102c66:	0f b6 c0             	movzbl %al,%eax
80102c69:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c6c:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
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
80102d01:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102d06:	8b 55 08             	mov    0x8(%ebp),%edx
80102d09:	c1 e2 02             	shl    $0x2,%edx
80102d0c:	01 c2                	add    %eax,%edx
80102d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d11:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d13:	a1 7c 32 11 80       	mov    0x8011327c,%eax
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
80102d25:	a1 7c 32 11 80       	mov    0x8011327c,%eax
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
80102dab:	a1 7c 32 11 80       	mov    0x8011327c,%eax
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
80102e4d:	a1 7c 32 11 80       	mov    0x8011327c,%eax
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
80102e8c:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102e91:	8d 50 01             	lea    0x1(%eax),%edx
80102e94:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80102e9a:	85 c0                	test   %eax,%eax
80102e9c:	75 13                	jne    80102eb1 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102e9e:	8b 45 04             	mov    0x4(%ebp),%eax
80102ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ea5:	c7 04 24 cc 8c 10 80 	movl   $0x80108ccc,(%esp)
80102eac:	e8 ef d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102eb1:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102eb6:	85 c0                	test   %eax,%eax
80102eb8:	74 0f                	je     80102ec9 <cpunum+0x51>
    return lapic[ID]>>24;
80102eba:	a1 7c 32 11 80       	mov    0x8011327c,%eax
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
80102ed6:	a1 7c 32 11 80       	mov    0x8011327c,%eax
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
80103108:	e8 8a 22 00 00       	call   80105397 <memcmp>
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
80103208:	c7 44 24 04 f8 8c 10 	movl   $0x80108cf8,0x4(%esp)
8010320f:	80 
80103210:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103217:	e8 8f 1e 00 00       	call   801050ab <initlock>
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
80103239:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
8010323e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103241:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = ROOTDEV;
80103246:	c7 05 c4 32 11 80 01 	movl   $0x1,0x801132c4
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
80103269:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
8010326f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103272:	01 d0                	add    %edx,%eax
80103274:	83 c0 01             	add    $0x1,%eax
80103277:	89 c2                	mov    %eax,%edx
80103279:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010327e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103282:	89 04 24             	mov    %eax,(%esp)
80103285:	e8 1c cf ff ff       	call   801001a6 <bread>
8010328a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010328d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103290:	83 c0 10             	add    $0x10,%eax
80103293:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010329a:	89 c2                	mov    %eax,%edx
8010329c:	a1 c4 32 11 80       	mov    0x801132c4,%eax
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
801032cb:	e8 1f 21 00 00       	call   801053ef <memmove>
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
801032f5:	a1 c8 32 11 80       	mov    0x801132c8,%eax
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
8010330b:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80103310:	89 c2                	mov    %eax,%edx
80103312:	a1 c4 32 11 80       	mov    0x801132c4,%eax
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
80103334:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
80103339:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103340:	eb 1b                	jmp    8010335d <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103342:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103345:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103348:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010334c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010334f:	83 c2 10             	add    $0x10,%edx
80103352:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103359:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010335d:	a1 c8 32 11 80       	mov    0x801132c8,%eax
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
8010337a:	a1 b4 32 11 80       	mov    0x801132b4,%eax
8010337f:	89 c2                	mov    %eax,%edx
80103381:	a1 c4 32 11 80       	mov    0x801132c4,%eax
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
8010339e:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
801033a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033a7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033b0:	eb 1b                	jmp    801033cd <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801033b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b5:	83 c0 10             	add    $0x10,%eax
801033b8:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
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
801033cd:	a1 c8 32 11 80       	mov    0x801132c8,%eax
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
801033ff:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
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
80103416:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010341d:	e8 aa 1c 00 00       	call   801050cc <acquire>
  while(1){
    if(log.committing){
80103422:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103427:	85 c0                	test   %eax,%eax
80103429:	74 16                	je     80103441 <begin_op+0x31>
      sleep(&log, &log.lock);
8010342b:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
80103432:	80 
80103433:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010343a:	e8 25 19 00 00       	call   80104d64 <sleep>
8010343f:	eb 4f                	jmp    80103490 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103441:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
80103447:	a1 bc 32 11 80       	mov    0x801132bc,%eax
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
8010345f:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
80103466:	80 
80103467:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010346e:	e8 f1 18 00 00       	call   80104d64 <sleep>
80103473:	eb 1b                	jmp    80103490 <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103475:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010347a:	83 c0 01             	add    $0x1,%eax
8010347d:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
80103482:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103489:	e8 a0 1c 00 00       	call   8010512e <release>
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
801034a1:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034a8:	e8 1f 1c 00 00       	call   801050cc <acquire>
  log.outstanding -= 1;
801034ad:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801034b2:	83 e8 01             	sub    $0x1,%eax
801034b5:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
801034ba:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801034bf:	85 c0                	test   %eax,%eax
801034c1:	74 0c                	je     801034cf <end_op+0x3b>
    panic("log.committing");
801034c3:	c7 04 24 fc 8c 10 80 	movl   $0x80108cfc,(%esp)
801034ca:	e8 6b d0 ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
801034cf:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801034d4:	85 c0                	test   %eax,%eax
801034d6:	75 13                	jne    801034eb <end_op+0x57>
    do_commit = 1;
801034d8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801034df:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
801034e6:	00 00 00 
801034e9:	eb 0c                	jmp    801034f7 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801034eb:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034f2:	e8 76 19 00 00       	call   80104e6d <wakeup>
  }
  release(&log.lock);
801034f7:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034fe:	e8 2b 1c 00 00       	call   8010512e <release>

  if(do_commit){
80103503:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103507:	74 33                	je     8010353c <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103509:	e8 de 00 00 00       	call   801035ec <commit>
    acquire(&log.lock);
8010350e:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103515:	e8 b2 1b 00 00       	call   801050cc <acquire>
    log.committing = 0;
8010351a:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103521:	00 00 00 
    wakeup(&log);
80103524:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010352b:	e8 3d 19 00 00       	call   80104e6d <wakeup>
    release(&log.lock);
80103530:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103537:	e8 f2 1b 00 00       	call   8010512e <release>
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
80103550:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103559:	01 d0                	add    %edx,%eax
8010355b:	83 c0 01             	add    $0x1,%eax
8010355e:	89 c2                	mov    %eax,%edx
80103560:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103565:	89 54 24 04          	mov    %edx,0x4(%esp)
80103569:	89 04 24             	mov    %eax,(%esp)
8010356c:	e8 35 cc ff ff       	call   801001a6 <bread>
80103571:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103577:	83 c0 10             	add    $0x10,%eax
8010357a:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103581:	89 c2                	mov    %eax,%edx
80103583:	a1 c4 32 11 80       	mov    0x801132c4,%eax
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
801035b2:	e8 38 1e 00 00       	call   801053ef <memmove>
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
801035dc:	a1 c8 32 11 80       	mov    0x801132c8,%eax
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
801035f2:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801035f7:	85 c0                	test   %eax,%eax
801035f9:	7e 1e                	jle    80103619 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801035fb:	e8 3e ff ff ff       	call   8010353e <write_log>
    write_head();    // Write header to disk -- the real commit
80103600:	e8 6f fd ff ff       	call   80103374 <write_head>
    install_trans(); // Now install writes to home locations
80103605:	e8 4d fc ff ff       	call   80103257 <install_trans>
    log.lh.n = 0; 
8010360a:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
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
80103621:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103626:	83 f8 1d             	cmp    $0x1d,%eax
80103629:	7f 12                	jg     8010363d <log_write+0x22>
8010362b:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103630:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
80103636:	83 ea 01             	sub    $0x1,%edx
80103639:	39 d0                	cmp    %edx,%eax
8010363b:	7c 0c                	jl     80103649 <log_write+0x2e>
    panic("too big a transaction");
8010363d:	c7 04 24 0b 8d 10 80 	movl   $0x80108d0b,(%esp)
80103644:	e8 f1 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103649:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010364e:	85 c0                	test   %eax,%eax
80103650:	7f 0c                	jg     8010365e <log_write+0x43>
    panic("log_write outside of trans");
80103652:	c7 04 24 21 8d 10 80 	movl   $0x80108d21,(%esp)
80103659:	e8 dc ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010365e:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103665:	e8 62 1a 00 00       	call   801050cc <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010366a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103671:	eb 1f                	jmp    80103692 <log_write+0x77>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103676:	83 c0 10             	add    $0x10,%eax
80103679:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
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
80103692:	a1 c8 32 11 80       	mov    0x801132c8,%eax
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
801036a8:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
  if (i == log.lh.n)
801036af:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036b4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036b7:	75 0d                	jne    801036c6 <log_write+0xab>
    log.lh.n++;
801036b9:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036be:	83 c0 01             	add    $0x1,%eax
801036c1:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801036c6:	8b 45 08             	mov    0x8(%ebp),%eax
801036c9:	8b 00                	mov    (%eax),%eax
801036cb:	83 c8 04             	or     $0x4,%eax
801036ce:	89 c2                	mov    %eax,%edx
801036d0:	8b 45 08             	mov    0x8(%ebp),%eax
801036d3:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801036d5:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801036dc:	e8 4d 1a 00 00       	call   8010512e <release>
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
80103728:	c7 04 24 7c f0 11 80 	movl   $0x8011f07c,(%esp)
8010372f:	e8 80 f2 ff ff       	call   801029b4 <kinit1>
  kvmalloc();      // kernel page table
80103734:	e8 6d 48 00 00       	call   80107fa6 <kvmalloc>
  mpinit();        // collect info about this machine
80103739:	e8 50 04 00 00       	call   80103b8e <mpinit>
  lapicinit();
8010373e:	e8 dc f5 ff ff       	call   80102d1f <lapicinit>
  seginit();       // set up segments
80103743:	e8 ec 41 00 00       	call   80107934 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103748:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010374e:	0f b6 00             	movzbl (%eax),%eax
80103751:	0f b6 c0             	movzbl %al,%eax
80103754:	89 44 24 04          	mov    %eax,0x4(%esp)
80103758:	c7 04 24 3c 8d 10 80 	movl   $0x80108d3c,(%esp)
8010375f:	e8 3c cc ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103764:	e8 8b 06 00 00       	call   80103df4 <picinit>
  ioapicinit();    // another interrupt controller
80103769:	e8 3c f1 ff ff       	call   801028aa <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010376e:	e8 0e d3 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103773:	e8 0b 35 00 00       	call   80106c83 <uartinit>
  pinit();         // process table
80103778:	e8 a8 0b 00 00       	call   80104325 <pinit>
  tvinit();        // trap vectors
8010377d:	e8 b3 30 00 00       	call   80106835 <tvinit>
  binit();         // buffer cache
80103782:	e8 ad c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103787:	e8 7e d7 ff ff       	call   80100f0a <fileinit>
  iinit();         // inode cache
8010378c:	e8 13 de ff ff       	call   801015a4 <iinit>
  ideinit();       // disk
80103791:	e8 7d ed ff ff       	call   80102513 <ideinit>
  if(!ismp)
80103796:	a1 64 33 11 80       	mov    0x80113364,%eax
8010379b:	85 c0                	test   %eax,%eax
8010379d:	75 05                	jne    801037a4 <main+0x8d>
    timerinit();   // uniprocessor timer
8010379f:	e8 dc 2f 00 00       	call   80106780 <timerinit>
  startothers();   // start other processors
801037a4:	e8 7f 00 00 00       	call   80103828 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037a9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037b0:	8e 
801037b1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037b8:	e8 2f f2 ff ff       	call   801029ec <kinit2>
  userinit();      // first user process
801037bd:	e8 20 0d 00 00       	call   801044e2 <userinit>
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
801037cd:	e8 eb 47 00 00       	call   80107fbd <switchkvm>
  seginit();
801037d2:	e8 5d 41 00 00       	call   80107934 <seginit>
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
801037f7:	c7 04 24 53 8d 10 80 	movl   $0x80108d53,(%esp)
801037fe:	e8 9d cb ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103803:	e8 a1 31 00 00       	call   801069a9 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103808:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010380e:	05 a8 00 00 00       	add    $0xa8,%eax
80103813:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010381a:	00 
8010381b:	89 04 24             	mov    %eax,(%esp)
8010381e:	e8 da fe ff ff       	call   801036fd <xchg>
  scheduler();     // start running processes
80103823:	e8 49 13 00 00       	call   80104b71 <scheduler>

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
80103847:	c7 44 24 04 30 c5 10 	movl   $0x8010c530,0x4(%esp)
8010384e:	80 
8010384f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103852:	89 04 24             	mov    %eax,(%esp)
80103855:	e8 95 1b 00 00       	call   801053ef <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010385a:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
80103861:	e9 8a 00 00 00       	jmp    801038f0 <startothers+0xc8>
    if(c == cpus+cpunum())  // We've started already.
80103866:	e8 0d f6 ff ff       	call   80102e78 <cpunum>
8010386b:	89 c2                	mov    %eax,%edx
8010386d:	89 d0                	mov    %edx,%eax
8010386f:	01 c0                	add    %eax,%eax
80103871:	01 d0                	add    %edx,%eax
80103873:	c1 e0 06             	shl    $0x6,%eax
80103876:	05 80 33 11 80       	add    $0x80113380,%eax
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
801038f0:	a1 80 39 11 80       	mov    0x80113980,%eax
801038f5:	89 c2                	mov    %eax,%edx
801038f7:	89 d0                	mov    %edx,%eax
801038f9:	01 c0                	add    %eax,%eax
801038fb:	01 d0                	add    %edx,%eax
801038fd:	c1 e0 06             	shl    $0x6,%eax
80103900:	05 80 33 11 80       	add    $0x80113380,%eax
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
8010395f:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103964:	89 c2                	mov    %eax,%edx
80103966:	b8 80 33 11 80       	mov    $0x80113380,%eax
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
801039e1:	c7 44 24 04 64 8d 10 	movl   $0x80108d64,0x4(%esp)
801039e8:	80 
801039e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ec:	89 04 24             	mov    %eax,(%esp)
801039ef:	e8 a3 19 00 00       	call   80105397 <memcmp>
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
80103b22:	c7 44 24 04 69 8d 10 	movl   $0x80108d69,0x4(%esp)
80103b29:	80 
80103b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b2d:	89 04 24             	mov    %eax,(%esp)
80103b30:	e8 62 18 00 00       	call   80105397 <memcmp>
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
80103b94:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
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
80103bb7:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103bbe:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc4:	8b 40 24             	mov    0x24(%eax),%eax
80103bc7:	a3 7c 32 11 80       	mov    %eax,0x8011327c
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
80103bfe:	8b 04 85 ac 8d 10 80 	mov    -0x7fef7254(,%eax,4),%eax
80103c05:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c10:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c14:	0f b6 d0             	movzbl %al,%edx
80103c17:	a1 80 39 11 80       	mov    0x80113980,%eax
80103c1c:	39 c2                	cmp    %eax,%edx
80103c1e:	74 2d                	je     80103c4d <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c20:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c23:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c27:	0f b6 d0             	movzbl %al,%edx
80103c2a:	a1 80 39 11 80       	mov    0x80113980,%eax
80103c2f:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c33:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c37:	c7 04 24 6e 8d 10 80 	movl   $0x80108d6e,(%esp)
80103c3e:	e8 5d c7 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103c43:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
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
80103c5e:	8b 15 80 39 11 80    	mov    0x80113980,%edx
80103c64:	89 d0                	mov    %edx,%eax
80103c66:	01 c0                	add    %eax,%eax
80103c68:	01 d0                	add    %edx,%eax
80103c6a:	c1 e0 06             	shl    $0x6,%eax
80103c6d:	05 80 33 11 80       	add    $0x80113380,%eax
80103c72:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103c77:	8b 15 80 39 11 80    	mov    0x80113980,%edx
80103c7d:	a1 80 39 11 80       	mov    0x80113980,%eax
80103c82:	89 c1                	mov    %eax,%ecx
80103c84:	89 d0                	mov    %edx,%eax
80103c86:	01 c0                	add    %eax,%eax
80103c88:	01 d0                	add    %edx,%eax
80103c8a:	c1 e0 06             	shl    $0x6,%eax
80103c8d:	05 80 33 11 80       	add    $0x80113380,%eax
80103c92:	88 08                	mov    %cl,(%eax)
      ncpu++;
80103c94:	a1 80 39 11 80       	mov    0x80113980,%eax
80103c99:	83 c0 01             	add    $0x1,%eax
80103c9c:	a3 80 39 11 80       	mov    %eax,0x80113980
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
80103cb4:	a2 60 33 11 80       	mov    %al,0x80113360
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
80103cd2:	c7 04 24 8c 8d 10 80 	movl   $0x80108d8c,(%esp)
80103cd9:	e8 c2 c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103cde:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
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
80103cf4:	a1 64 33 11 80       	mov    0x80113364,%eax
80103cf9:	85 c0                	test   %eax,%eax
80103cfb:	75 1d                	jne    80103d1a <mpinit+0x18c>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103cfd:	c7 05 80 39 11 80 01 	movl   $0x1,0x80113980
80103d04:	00 00 00 
    lapic = 0;
80103d07:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103d0e:	00 00 00 
    ioapicid = 0;
80103d11:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
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
80103fcb:	c7 44 24 04 c0 8d 10 	movl   $0x80108dc0,0x4(%esp)
80103fd2:	80 
80103fd3:	89 04 24             	mov    %eax,(%esp)
80103fd6:	e8 d0 10 00 00       	call   801050ab <initlock>
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
80104082:	e8 45 10 00 00       	call   801050cc <acquire>
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
801040a5:	e8 c3 0d 00 00       	call   80104e6d <wakeup>
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
801040c4:	e8 a4 0d 00 00       	call   80104e6d <wakeup>
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
801040e9:	e8 40 10 00 00       	call   8010512e <release>
    kfree((char*)p);
801040ee:	8b 45 08             	mov    0x8(%ebp),%eax
801040f1:	89 04 24             	mov    %eax,(%esp)
801040f4:	e8 50 e9 ff ff       	call   80102a49 <kfree>
801040f9:	eb 0b                	jmp    80104106 <pipeclose+0x90>
  } else
    release(&p->lock);
801040fb:	8b 45 08             	mov    0x8(%ebp),%eax
801040fe:	89 04 24             	mov    %eax,(%esp)
80104101:	e8 28 10 00 00       	call   8010512e <release>
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
80104114:	e8 b3 0f 00 00       	call   801050cc <acquire>
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
80104147:	e8 e2 0f 00 00       	call   8010512e <release>
        return -1;
8010414c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104151:	e9 9f 00 00 00       	jmp    801041f5 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104156:	8b 45 08             	mov    0x8(%ebp),%eax
80104159:	05 34 02 00 00       	add    $0x234,%eax
8010415e:	89 04 24             	mov    %eax,(%esp)
80104161:	e8 07 0d 00 00       	call   80104e6d <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104166:	8b 45 08             	mov    0x8(%ebp),%eax
80104169:	8b 55 08             	mov    0x8(%ebp),%edx
8010416c:	81 c2 38 02 00 00    	add    $0x238,%edx
80104172:	89 44 24 04          	mov    %eax,0x4(%esp)
80104176:	89 14 24             	mov    %edx,(%esp)
80104179:	e8 e6 0b 00 00       	call   80104d64 <sleep>
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
801041e2:	e8 86 0c 00 00       	call   80104e6d <wakeup>
  release(&p->lock);
801041e7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ea:	89 04 24             	mov    %eax,(%esp)
801041ed:	e8 3c 0f 00 00       	call   8010512e <release>

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
80104204:	e8 c3 0e 00 00       	call   801050cc <acquire>
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
8010421e:	e8 0b 0f 00 00       	call   8010512e <release>
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
80104240:	e8 1f 0b 00 00       	call   80104d64 <sleep>
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
801042cf:	e8 99 0b 00 00       	call   80104e6d <wakeup>
  release(&p->lock);
801042d4:	8b 45 08             	mov    0x8(%ebp),%eax
801042d7:	89 04 24             	mov    %eax,(%esp)
801042da:	e8 4f 0e 00 00       	call   8010512e <release>
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

	if(p->state == RUNNABLE  || p->state == RUNNING){
80104301:	8b 45 08             	mov    0x8(%ebp),%eax
80104304:	8b 40 0c             	mov    0xc(%eax),%eax
80104307:	83 f8 03             	cmp    $0x3,%eax
8010430a:	74 0b                	je     80104317 <procIsReady+0x19>
8010430c:	8b 45 08             	mov    0x8(%ebp),%eax
8010430f:	8b 40 0c             	mov    0xc(%eax),%eax
80104312:	83 f8 04             	cmp    $0x4,%eax
80104315:	75 07                	jne    8010431e <procIsReady+0x20>
		return 1;
80104317:	b8 01 00 00 00       	mov    $0x1,%eax
8010431c:	eb 05                	jmp    80104323 <procIsReady+0x25>
	}
	return 0;
8010431e:	b8 00 00 00 00       	mov    $0x0,%eax

}
80104323:	5d                   	pop    %ebp
80104324:	c3                   	ret    

80104325 <pinit>:


void
pinit(void)
{
80104325:	55                   	push   %ebp
80104326:	89 e5                	mov    %esp,%ebp
80104328:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
8010432b:	c7 44 24 04 c5 8d 10 	movl   $0x80108dc5,0x4(%esp)
80104332:	80 
80104333:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
8010433a:	e8 6c 0d 00 00       	call   801050ab <initlock>
}
8010433f:	c9                   	leave  
80104340:	c3                   	ret    

80104341 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104341:	55                   	push   %ebp
80104342:	89 e5                	mov    %esp,%ebp
80104344:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  int i=0;
80104347:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  acquire(&ptable.lock);
8010434e:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104355:	e8 72 0d 00 00       	call   801050cc <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010435a:	c7 45 f4 d4 c9 11 80 	movl   $0x8011c9d4,-0xc(%ebp)
80104361:	eb 72                	jmp    801043d5 <allocproc+0x94>
    if(p->state == UNUSED)
80104363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104366:	8b 40 0c             	mov    0xc(%eax),%eax
80104369:	85 c0                	test   %eax,%eax
8010436b:	75 60                	jne    801043cd <allocproc+0x8c>
      goto found;
8010436d:	90                   	nop
    	i++;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010436e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104371:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  //p->lock = &ptable.tTable[i].threadLock;
  p->threads = ptable.tTable[i].threads;
80104378:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010437b:	89 d0                	mov    %edx,%eax
8010437d:	c1 e0 03             	shl    $0x3,%eax
80104380:	01 d0                	add    %edx,%eax
80104382:	c1 e0 06             	shl    $0x6,%eax
80104385:	83 c0 30             	add    $0x30,%eax
80104388:	05 a0 39 11 80       	add    $0x801139a0,%eax
8010438d:	8d 50 04             	lea    0x4(%eax),%edx
80104390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104393:	89 50 74             	mov    %edx,0x74(%eax)
  p->pid = nextpid++;
80104396:	a1 04 c0 10 80       	mov    0x8010c004,%eax
8010439b:	8d 50 01             	lea    0x1(%eax),%edx
8010439e:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
801043a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043a7:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801043aa:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801043b1:	e8 78 0d 00 00       	call   8010512e <release>



  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043b6:	e8 27 e7 ff ff       	call   80102ae2 <kalloc>
801043bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043be:	89 42 08             	mov    %eax,0x8(%edx)
801043c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c4:	8b 40 08             	mov    0x8(%eax),%eax
801043c7:	85 c0                	test   %eax,%eax
801043c9:	75 3d                	jne    80104408 <allocproc+0xc7>
801043cb:	eb 27                	jmp    801043f4 <allocproc+0xb3>
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
    else
    	i++;
801043cd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  struct proc *p;
  char *sp;
  int i=0;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043d1:	83 45 f4 78          	addl   $0x78,-0xc(%ebp)
801043d5:	81 7d f4 d4 e7 11 80 	cmpl   $0x8011e7d4,-0xc(%ebp)
801043dc:	72 85                	jb     80104363 <allocproc+0x22>
    if(p->state == UNUSED)
      goto found;
    else
    	i++;
  release(&ptable.lock);
801043de:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801043e5:	e8 44 0d 00 00       	call   8010512e <release>
  return 0;
801043ea:	b8 00 00 00 00       	mov    $0x0,%eax
801043ef:	e9 ec 00 00 00       	jmp    801044e0 <allocproc+0x19f>



  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043fe:	b8 00 00 00 00       	mov    $0x0,%eax
80104403:	e9 d8 00 00 00       	jmp    801044e0 <allocproc+0x19f>
  }
  sp = p->kstack + KSTACKSIZE;
80104408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440b:	8b 40 08             	mov    0x8(%eax),%eax
8010440e:	05 00 10 00 00       	add    $0x1000,%eax
80104413:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  //initlock( p->lock, "threadLock");
    for (i=0; i<NTHREAD; i++)
80104416:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010441d:	eb 3c                	jmp    8010445b <allocproc+0x11a>
    {
  	  p->threads[i].state=UNUSED;
8010441f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104422:	8b 48 74             	mov    0x74(%eax),%ecx
80104425:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104428:	89 d0                	mov    %edx,%eax
8010442a:	c1 e0 03             	shl    $0x3,%eax
8010442d:	01 d0                	add    %edx,%eax
8010442f:	c1 e0 02             	shl    $0x2,%eax
80104432:	01 c8                	add    %ecx,%eax
80104434:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  	  p->threads[i].ptableLock=&ptable.lock;
8010443b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443e:	8b 48 74             	mov    0x74(%eax),%ecx
80104441:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104444:	89 d0                	mov    %edx,%eax
80104446:	c1 e0 03             	shl    $0x3,%eax
80104449:	01 d0                	add    %edx,%eax
8010444b:	c1 e0 02             	shl    $0x2,%eax
8010444e:	01 c8                	add    %ecx,%eax
80104450:	c7 40 1c a0 39 11 80 	movl   $0x801139a0,0x1c(%eax)
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  //initlock( p->lock, "threadLock");
    for (i=0; i<NTHREAD; i++)
80104457:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010445b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010445f:	7e be                	jle    8010441f <allocproc+0xde>
    {
  	  p->threads[i].state=UNUSED;
  	  p->threads[i].ptableLock=&ptable.lock;
    }

  struct kthread* t= p->threads;
80104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104464:	8b 40 74             	mov    0x74(%eax),%eax
80104467:	89 45 e8             	mov    %eax,-0x18(%ebp)
  // Leave room for trap frame.
  sp -= sizeof *t->tf;
8010446a:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  t->tf = (struct trapframe*)sp;
8010446e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104471:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104474:	89 50 10             	mov    %edx,0x10(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104477:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
8010447b:	ba f0 67 10 80       	mov    $0x801067f0,%edx
80104480:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104483:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *t->context;
80104485:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  t->context = (struct context*)sp;
80104489:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010448c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010448f:	89 50 14             	mov    %edx,0x14(%eax)
  memset(t->context, 0, sizeof *t->context);
80104492:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104495:	8b 40 14             	mov    0x14(%eax),%eax
80104498:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010449f:	00 
801044a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044a7:	00 
801044a8:	89 04 24             	mov    %eax,(%esp)
801044ab:	e8 70 0e 00 00       	call   80105320 <memset>
  t->context->eip = (uint)forkret;
801044b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044b3:	8b 40 14             	mov    0x14(%eax),%eax
801044b6:	ba 38 4d 10 80       	mov    $0x80104d38,%edx
801044bb:	89 50 10             	mov    %edx,0x10(%eax)
  t->kstack= p->kstack;
801044be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c1:	8b 50 08             	mov    0x8(%eax),%edx
801044c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044c7:	89 10                	mov    %edx,(%eax)
  t->kernelStack=1;
801044c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044cc:	c7 40 20 01 00 00 00 	movl   $0x1,0x20(%eax)
  t->ptableLock = &ptable.lock;
801044d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044d6:	c7 40 1c a0 39 11 80 	movl   $0x801139a0,0x1c(%eax)
  return p;
801044dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044e0:	c9                   	leave  
801044e1:	c3                   	ret    

801044e2 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801044e2:	55                   	push   %ebp
801044e3:	89 e5                	mov    %esp,%ebp
801044e5:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801044e8:	e8 54 fe ff ff       	call   80104341 <allocproc>
801044ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801044f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f3:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
801044f8:	e8 ec 39 00 00       	call   80107ee9 <setupkvm>
801044fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104500:	89 42 04             	mov    %eax,0x4(%edx)
80104503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104506:	8b 40 04             	mov    0x4(%eax),%eax
80104509:	85 c0                	test   %eax,%eax
8010450b:	75 0c                	jne    80104519 <userinit+0x37>
    panic("userinit: out of memory?");
8010450d:	c7 04 24 cc 8d 10 80 	movl   $0x80108dcc,(%esp)
80104514:	e8 21 c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104519:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010451e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104521:	8b 40 04             	mov    0x4(%eax),%eax
80104524:	89 54 24 08          	mov    %edx,0x8(%esp)
80104528:	c7 44 24 04 04 c5 10 	movl   $0x8010c504,0x4(%esp)
8010452f:	80 
80104530:	89 04 24             	mov    %eax,(%esp)
80104533:	e8 09 3c 00 00       	call   80108141 <inituvm>
  p->sz = PGSIZE;
80104538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453b:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)

  struct kthread* t= p->threads;
80104541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104544:	8b 40 74             	mov    0x74(%eax),%eax
80104547:	89 45 f0             	mov    %eax,-0x10(%ebp)

  memset(t->tf, 0, sizeof(*t->tf));
8010454a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010454d:	8b 40 10             	mov    0x10(%eax),%eax
80104550:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104557:	00 
80104558:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010455f:	00 
80104560:	89 04 24             	mov    %eax,(%esp)
80104563:	e8 b8 0d 00 00       	call   80105320 <memset>
  t->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104568:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010456b:	8b 40 10             	mov    0x10(%eax),%eax
8010456e:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  t->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104574:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104577:	8b 40 10             	mov    0x10(%eax),%eax
8010457a:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  t->tf->es = t->tf->ds;
80104580:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104583:	8b 40 10             	mov    0x10(%eax),%eax
80104586:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104589:	8b 52 10             	mov    0x10(%edx),%edx
8010458c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104590:	66 89 50 28          	mov    %dx,0x28(%eax)
  t->tf->ss = t->tf->ds;
80104594:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104597:	8b 40 10             	mov    0x10(%eax),%eax
8010459a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010459d:	8b 52 10             	mov    0x10(%edx),%edx
801045a0:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801045a4:	66 89 50 48          	mov    %dx,0x48(%eax)
  t->tf->eflags = FL_IF;
801045a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045ab:	8b 40 10             	mov    0x10(%eax),%eax
801045ae:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  t->tf->esp = PGSIZE;
801045b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045b8:	8b 40 10             	mov    0x10(%eax),%eax
801045bb:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  t->tf->eip = 0;  // beginning of initcode.S
801045c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045c5:	8b 40 10             	mov    0x10(%eax),%eax
801045c8:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801045cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d2:	83 c0 64             	add    $0x64,%eax
801045d5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801045dc:	00 
801045dd:	c7 44 24 04 e5 8d 10 	movl   $0x80108de5,0x4(%esp)
801045e4:	80 
801045e5:	89 04 24             	mov    %eax,(%esp)
801045e8:	e8 53 0f 00 00       	call   80105540 <safestrcpy>
  p->cwd = namei("/");
801045ed:	c7 04 24 ee 8d 10 80 	movl   $0x80108dee,(%esp)
801045f4:	e8 0d de ff ff       	call   80102406 <namei>
801045f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045fc:	89 42 60             	mov    %eax,0x60(%edx)
  p->state = RUNNABLE;
801045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104602:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  t->state =  RUNNABLE;
80104609:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010460c:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)
}
80104613:	c9                   	leave  
80104614:	c3                   	ret    

80104615 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104615:	55                   	push   %ebp
80104616:	89 e5                	mov    %esp,%ebp
80104618:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  //struct spinlock* lock =proc->lock;
  //  acquire( lock);
  sz = proc->sz;
8010461b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104621:	8b 00                	mov    (%eax),%eax
80104623:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(thread->ptableLock);
80104626:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
8010462c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010462f:	89 04 24             	mov    %eax,(%esp)
80104632:	e8 95 0a 00 00       	call   801050cc <acquire>
  if(n > 0){
80104637:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010463b:	7e 45                	jle    80104682 <growproc+0x6d>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0){
8010463d:	8b 55 08             	mov    0x8(%ebp),%edx
80104640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104643:	01 c2                	add    %eax,%edx
80104645:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010464b:	8b 40 04             	mov    0x4(%eax),%eax
8010464e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104655:	89 54 24 04          	mov    %edx,0x4(%esp)
80104659:	89 04 24             	mov    %eax,(%esp)
8010465c:	e8 56 3c 00 00       	call   801082b7 <allocuvm>
80104661:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104664:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104668:	75 63                	jne    801046cd <growproc+0xb8>
      release(thread->ptableLock);
8010466a:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104670:	8b 40 1c             	mov    0x1c(%eax),%eax
80104673:	89 04 24             	mov    %eax,(%esp)
80104676:	e8 b3 0a 00 00       	call   8010512e <release>
      return -1;
8010467b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104680:	eb 7a                	jmp    801046fc <growproc+0xe7>
    }
  } else if(n < 0){
80104682:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104686:	79 45                	jns    801046cd <growproc+0xb8>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0){
80104688:	8b 55 08             	mov    0x8(%ebp),%edx
8010468b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468e:	01 c2                	add    %eax,%edx
80104690:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104696:	8b 40 04             	mov    0x4(%eax),%eax
80104699:	89 54 24 08          	mov    %edx,0x8(%esp)
8010469d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046a0:	89 54 24 04          	mov    %edx,0x4(%esp)
801046a4:	89 04 24             	mov    %eax,(%esp)
801046a7:	e8 e5 3c 00 00       	call   80108391 <deallocuvm>
801046ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046b3:	75 18                	jne    801046cd <growproc+0xb8>
    	release(thread->ptableLock);
801046b5:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801046bb:	8b 40 1c             	mov    0x1c(%eax),%eax
801046be:	89 04 24             	mov    %eax,(%esp)
801046c1:	e8 68 0a 00 00       	call   8010512e <release>
    	return -1;
801046c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046cb:	eb 2f                	jmp    801046fc <growproc+0xe7>
    }
  }
  release(thread->ptableLock);
801046cd:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801046d3:	8b 40 1c             	mov    0x1c(%eax),%eax
801046d6:	89 04 24             	mov    %eax,(%esp)
801046d9:	e8 50 0a 00 00       	call   8010512e <release>
  proc->sz = sz;
801046de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046e7:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801046e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ef:	89 04 24             	mov    %eax,(%esp)
801046f2:	e8 e3 38 00 00       	call   80107fda <switchuvm>
//  release(lock);
  return 0;
801046f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046fc:	c9                   	leave  
801046fd:	c3                   	ret    

801046fe <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801046fe:	55                   	push   %ebp
801046ff:	89 e5                	mov    %esp,%ebp
80104701:	57                   	push   %edi
80104702:	56                   	push   %esi
80104703:	53                   	push   %ebx
80104704:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104707:	e8 35 fc ff ff       	call   80104341 <allocproc>
8010470c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010470f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104713:	75 0a                	jne    8010471f <fork+0x21>
    return -1;
80104715:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010471a:	e9 dd 01 00 00       	jmp    801048fc <fork+0x1fe>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010471f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104725:	8b 10                	mov    (%eax),%edx
80104727:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472d:	8b 40 04             	mov    0x4(%eax),%eax
80104730:	89 54 24 04          	mov    %edx,0x4(%esp)
80104734:	89 04 24             	mov    %eax,(%esp)
80104737:	e8 f1 3d 00 00       	call   8010852d <copyuvm>
8010473c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010473f:	89 42 04             	mov    %eax,0x4(%edx)
80104742:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104745:	8b 40 04             	mov    0x4(%eax),%eax
80104748:	85 c0                	test   %eax,%eax
8010474a:	75 2c                	jne    80104778 <fork+0x7a>
    kfree(np->kstack);
8010474c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010474f:	8b 40 08             	mov    0x8(%eax),%eax
80104752:	89 04 24             	mov    %eax,(%esp)
80104755:	e8 ef e2 ff ff       	call   80102a49 <kfree>
    np->kstack = 0;
8010475a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104764:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104767:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010476e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104773:	e9 84 01 00 00       	jmp    801048fc <fork+0x1fe>
  }
  np->sz = proc->sz;
80104778:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010477e:	8b 10                	mov    (%eax),%edx
80104780:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104783:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104785:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010478c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478f:	89 50 14             	mov    %edx,0x14(%eax)


  for (i=1; i<NTHREAD; i++)
80104792:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
80104799:	eb 3c                	jmp    801047d7 <fork+0xd9>
  {
	  np->threads[i].state=UNUSED;
8010479b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479e:	8b 48 74             	mov    0x74(%eax),%ecx
801047a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801047a4:	89 d0                	mov    %edx,%eax
801047a6:	c1 e0 03             	shl    $0x3,%eax
801047a9:	01 d0                	add    %edx,%eax
801047ab:	c1 e0 02             	shl    $0x2,%eax
801047ae:	01 c8                	add    %ecx,%eax
801047b0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	  np->threads[i].ptableLock=&ptable.lock;
801047b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ba:	8b 48 74             	mov    0x74(%eax),%ecx
801047bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801047c0:	89 d0                	mov    %edx,%eax
801047c2:	c1 e0 03             	shl    $0x3,%eax
801047c5:	01 d0                	add    %edx,%eax
801047c7:	c1 e0 02             	shl    $0x2,%eax
801047ca:	01 c8                	add    %ecx,%eax
801047cc:	c7 40 1c a0 39 11 80 	movl   $0x801139a0,0x1c(%eax)
  }
  np->sz = proc->sz;
  np->parent = proc;


  for (i=1; i<NTHREAD; i++)
801047d3:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801047d7:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801047db:	7e be                	jle    8010479b <fork+0x9d>
  {
	  np->threads[i].state=UNUSED;
	  np->threads[i].ptableLock=&ptable.lock;
  }
  np->threads[0].parent= np;
801047dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e0:	8b 40 74             	mov    0x74(%eax),%eax
801047e3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047e6:	89 50 0c             	mov    %edx,0xc(%eax)
  np->threads[0].kstack = thread->kstack;
801047e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ec:	8b 40 74             	mov    0x74(%eax),%eax
801047ef:	65 8b 15 08 00 00 00 	mov    %gs:0x8,%edx
801047f6:	8b 12                	mov    (%edx),%edx
801047f8:	89 10                	mov    %edx,(%eax)
  *np->threads[0].tf = *thread->tf;
801047fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047fd:	8b 40 74             	mov    0x74(%eax),%eax
80104800:	8b 50 10             	mov    0x10(%eax),%edx
80104803:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104809:	8b 40 10             	mov    0x10(%eax),%eax
8010480c:	89 c3                	mov    %eax,%ebx
8010480e:	b8 13 00 00 00       	mov    $0x13,%eax
80104813:	89 d7                	mov    %edx,%edi
80104815:	89 de                	mov    %ebx,%esi
80104817:	89 c1                	mov    %eax,%ecx
80104819:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->threads[0].kernelStack=  thread->kernelStack;
8010481b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010481e:	8b 40 74             	mov    0x74(%eax),%eax
80104821:	65 8b 15 08 00 00 00 	mov    %gs:0x8,%edx
80104828:	8b 52 20             	mov    0x20(%edx),%edx
8010482b:	89 50 20             	mov    %edx,0x20(%eax)




  // Clear %eax so that fork returns 0 in the child.
  np->threads[0].tf->eax = 0;
8010482e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104831:	8b 40 74             	mov    0x74(%eax),%eax
80104834:	8b 40 10             	mov    0x10(%eax),%eax
80104837:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010483e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104845:	eb 3a                	jmp    80104881 <fork+0x183>
    if(proc->ofile[i]){
80104847:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010484d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104850:	83 c2 08             	add    $0x8,%edx
80104853:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104856:	85 c0                	test   %eax,%eax
80104858:	74 23                	je     8010487d <fork+0x17f>
      np->ofile[i] = filedup(proc->ofile[i]);
8010485a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104860:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104863:	83 c2 08             	add    $0x8,%edx
80104866:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104869:	89 04 24             	mov    %eax,(%esp)
8010486c:	e8 15 c7 ff ff       	call   80100f86 <filedup>
80104871:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104874:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104877:	83 c1 08             	add    $0x8,%ecx
8010487a:	89 04 8a             	mov    %eax,(%edx,%ecx,4)


  // Clear %eax so that fork returns 0 in the child.
  np->threads[0].tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010487d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104881:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104885:	7e c0                	jle    80104847 <fork+0x149>
    if(proc->ofile[i]){
      np->ofile[i] = filedup(proc->ofile[i]);
    }
  np->cwd = idup(proc->cwd);
80104887:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010488d:	8b 40 60             	mov    0x60(%eax),%eax
80104890:	89 04 24             	mov    %eax,(%esp)
80104893:	e8 91 cf ff ff       	call   80101829 <idup>
80104898:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010489b:	89 42 60             	mov    %eax,0x60(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010489e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a4:	8d 50 64             	lea    0x64(%eax),%edx
801048a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048aa:	83 c0 64             	add    $0x64,%eax
801048ad:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801048b4:	00 
801048b5:	89 54 24 04          	mov    %edx,0x4(%esp)
801048b9:	89 04 24             	mov    %eax,(%esp)
801048bc:	e8 7f 0c 00 00       	call   80105540 <safestrcpy>
 
  pid = np->pid;
801048c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048c4:	8b 40 10             	mov    0x10(%eax),%eax
801048c7:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048ca:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801048d1:	e8 f6 07 00 00       	call   801050cc <acquire>

  np->state = RUNNABLE;
801048d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  np->threads[0].state =  RUNNABLE;
801048e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e3:	8b 40 74             	mov    0x74(%eax),%eax
801048e6:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)

  release(&ptable.lock);
801048ed:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801048f4:	e8 35 08 00 00       	call   8010512e <release>

  return pid;
801048f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048fc:	83 c4 2c             	add    $0x2c,%esp
801048ff:	5b                   	pop    %ebx
80104900:	5e                   	pop    %esi
80104901:	5f                   	pop    %edi
80104902:	5d                   	pop    %ebp
80104903:	c3                   	ret    

80104904 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104904:	55                   	push   %ebp
80104905:	89 e5                	mov    %esp,%ebp
80104907:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;
  int tid;
  if(proc == initproc)
8010490a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104911:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104916:	39 c2                	cmp    %eax,%edx
80104918:	75 0c                	jne    80104926 <exit+0x22>
    panic("init exiting");
8010491a:	c7 04 24 f0 8d 10 80 	movl   $0x80108df0,(%esp)
80104921:	e8 14 bc ff ff       	call   8010053a <panic>


  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104926:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010492d:	eb 41                	jmp    80104970 <exit+0x6c>
    if(proc->ofile[fd]){
8010492f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104935:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104938:	83 c2 08             	add    $0x8,%edx
8010493b:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010493e:	85 c0                	test   %eax,%eax
80104940:	74 2a                	je     8010496c <exit+0x68>
      fileclose(proc->ofile[fd]);
80104942:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104948:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010494b:	83 c2 08             	add    $0x8,%edx
8010494e:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104951:	89 04 24             	mov    %eax,(%esp)
80104954:	e8 75 c6 ff ff       	call   80100fce <fileclose>
      proc->ofile[fd] = 0;
80104959:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010495f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104962:	83 c2 08             	add    $0x8,%edx
80104965:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
  if(proc == initproc)
    panic("init exiting");


  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010496c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104970:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104974:	7e b9                	jle    8010492f <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104976:	e8 95 ea ff ff       	call   80103410 <begin_op>
  iput(proc->cwd);
8010497b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104981:	8b 40 60             	mov    0x60(%eax),%eax
80104984:	89 04 24             	mov    %eax,(%esp)
80104987:	e8 82 d0 ff ff       	call   80101a0e <iput>
  end_op();
8010498c:	e8 03 eb ff ff       	call   80103494 <end_op>
  proc->cwd = 0;
80104991:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104997:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)

  acquire(&ptable.lock);
8010499e:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801049a5:	e8 22 07 00 00       	call   801050cc <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801049aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b0:	8b 40 14             	mov    0x14(%eax),%eax
801049b3:	89 04 24             	mov    %eax,(%esp)
801049b6:	e8 44 04 00 00       	call   80104dff <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049bb:	c7 45 f4 d4 c9 11 80 	movl   $0x8011c9d4,-0xc(%ebp)
801049c2:	eb 38                	jmp    801049fc <exit+0xf8>
    if(p->parent == proc){
801049c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c7:	8b 50 14             	mov    0x14(%eax),%edx
801049ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d0:	39 c2                	cmp    %eax,%edx
801049d2:	75 24                	jne    801049f8 <exit+0xf4>
      p->parent = initproc;
801049d4:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
801049da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049dd:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e3:	8b 40 0c             	mov    0xc(%eax),%eax
801049e6:	83 f8 05             	cmp    $0x5,%eax
801049e9:	75 0d                	jne    801049f8 <exit+0xf4>
        wakeup1(initproc);
801049eb:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801049f0:	89 04 24             	mov    %eax,(%esp)
801049f3:	e8 07 04 00 00       	call   80104dff <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049f8:	83 45 f4 78          	addl   $0x78,-0xc(%ebp)
801049fc:	81 7d f4 d4 e7 11 80 	cmpl   $0x8011e7d4,-0xc(%ebp)
80104a03:	72 bf                	jb     801049c4 <exit+0xc0>
  }

 // Jump into the scheduler, never to return.


   for (tid=0; tid< NTHREAD; tid++){
80104a05:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104a0c:	eb 23                	jmp    80104a31 <exit+0x12d>
 	  proc->threads[tid].state= ZOMBIE;
80104a0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a14:	8b 48 74             	mov    0x74(%eax),%ecx
80104a17:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104a1a:	89 d0                	mov    %edx,%eax
80104a1c:	c1 e0 03             	shl    $0x3,%eax
80104a1f:	01 d0                	add    %edx,%eax
80104a21:	c1 e0 02             	shl    $0x2,%eax
80104a24:	01 c8                	add    %ecx,%eax
80104a26:	c7 40 04 05 00 00 00 	movl   $0x5,0x4(%eax)
  }

 // Jump into the scheduler, never to return.


   for (tid=0; tid< NTHREAD; tid++){
80104a2d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104a31:	83 7d ec 0f          	cmpl   $0xf,-0x14(%ebp)
80104a35:	7e d7                	jle    80104a0e <exit+0x10a>
 	  proc->threads[tid].state= ZOMBIE;
   }



  thread->state= ZOMBIE;
80104a37:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104a3d:	c7 40 04 05 00 00 00 	movl   $0x5,0x4(%eax)
  proc->state = ZOMBIE;
80104a44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a4a:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a51:	e8 fe 01 00 00       	call   80104c54 <sched>
  panic("zombie exit");
80104a56:	c7 04 24 fd 8d 10 80 	movl   $0x80108dfd,(%esp)
80104a5d:	e8 d8 ba ff ff       	call   8010053a <panic>

80104a62 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a62:	55                   	push   %ebp
80104a63:	89 e5                	mov    %esp,%ebp
80104a65:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a68:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104a6f:	e8 58 06 00 00       	call   801050cc <acquire>

  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a74:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a7b:	c7 45 f4 d4 c9 11 80 	movl   $0x8011c9d4,-0xc(%ebp)
80104a82:	e9 9a 00 00 00       	jmp    80104b21 <wait+0xbf>
      if(p->parent != proc)
80104a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8a:	8b 50 14             	mov    0x14(%eax),%edx
80104a8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a93:	39 c2                	cmp    %eax,%edx
80104a95:	74 05                	je     80104a9c <wait+0x3a>
        continue;
80104a97:	e9 81 00 00 00       	jmp    80104b1d <wait+0xbb>
      havekids = 1;
80104a9c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa6:	8b 40 0c             	mov    0xc(%eax),%eax
80104aa9:	83 f8 05             	cmp    $0x5,%eax
80104aac:	75 6f                	jne    80104b1d <wait+0xbb>
        // Found one.
        pid = p->pid;
80104aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab1:	8b 40 10             	mov    0x10(%eax),%eax
80104ab4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aba:	8b 40 08             	mov    0x8(%eax),%eax
80104abd:	89 04 24             	mov    %eax,(%esp)
80104ac0:	e8 84 df ff ff       	call   80102a49 <kfree>
        p->kstack = 0;
80104ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad2:	8b 40 04             	mov    0x4(%eax),%eax
80104ad5:	89 04 24             	mov    %eax,(%esp)
80104ad8:	e8 70 39 00 00       	call   8010844d <freevm>
        p->state = UNUSED;
80104add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aea:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afe:	c6 40 64 00          	movb   $0x0,0x64(%eax)
        p->killed = 0;
80104b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b05:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        release(&ptable.lock);
80104b0c:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104b13:	e8 16 06 00 00       	call   8010512e <release>
        return pid;
80104b18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b1b:	eb 52                	jmp    80104b6f <wait+0x10d>
  acquire(&ptable.lock);

  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b1d:	83 45 f4 78          	addl   $0x78,-0xc(%ebp)
80104b21:	81 7d f4 d4 e7 11 80 	cmpl   $0x8011e7d4,-0xc(%ebp)
80104b28:	0f 82 59 ff ff ff    	jb     80104a87 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b32:	74 0d                	je     80104b41 <wait+0xdf>
80104b34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b3a:	8b 40 1c             	mov    0x1c(%eax),%eax
80104b3d:	85 c0                	test   %eax,%eax
80104b3f:	74 13                	je     80104b54 <wait+0xf2>
      release(&ptable.lock);
80104b41:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104b48:	e8 e1 05 00 00       	call   8010512e <release>
      return -1;
80104b4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b52:	eb 1b                	jmp    80104b6f <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b5a:	c7 44 24 04 a0 39 11 	movl   $0x801139a0,0x4(%esp)
80104b61:	80 
80104b62:	89 04 24             	mov    %eax,(%esp)
80104b65:	e8 fa 01 00 00       	call   80104d64 <sleep>
  }
80104b6a:	e9 05 ff ff ff       	jmp    80104a74 <wait+0x12>
  return -1;
}
80104b6f:	c9                   	leave  
80104b70:	c3                   	ret    

80104b71 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b71:	55                   	push   %ebp
80104b72:	89 e5                	mov    %esp,%ebp
80104b74:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct kthread *t;
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b77:	e8 7c f7 ff ff       	call   801042f8 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b7c:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104b83:	e8 44 05 00 00       	call   801050cc <acquire>

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b88:	c7 45 f4 d4 c9 11 80 	movl   $0x8011c9d4,-0xc(%ebp)
80104b8f:	e9 a2 00 00 00       	jmp    80104c36 <scheduler+0xc5>

    	if(! procIsReady(p))
80104b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b97:	89 04 24             	mov    %eax,(%esp)
80104b9a:	e8 5f f7 ff ff       	call   801042fe <procIsReady>
80104b9f:	85 c0                	test   %eax,%eax
80104ba1:	75 05                	jne    80104ba8 <scheduler+0x37>
    		continue;
80104ba3:	e9 8a 00 00 00       	jmp    80104c32 <scheduler+0xc1>

    	for (t=p->threads; t< &p->threads[NTHREAD]; t++ )
80104ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bab:	8b 40 74             	mov    0x74(%eax),%eax
80104bae:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104bb1:	eb 6f                	jmp    80104c22 <scheduler+0xb1>
    	{
		  if(t->state !=  RUNNABLE)
80104bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bb6:	8b 40 04             	mov    0x4(%eax),%eax
80104bb9:	83 f8 03             	cmp    $0x3,%eax
80104bbc:	74 02                	je     80104bc0 <scheduler+0x4f>
			continue;
80104bbe:	eb 5e                	jmp    80104c1e <scheduler+0xad>

		  // Switch to chosen process.  It is the process's job
		  // to release ptable.lock and then reacquire it
		  // before jumping back to us.

		  thread= t;
80104bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bc3:	65 a3 08 00 00 00    	mov    %eax,%gs:0x8
		  proc = p;
80104bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcc:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
		  switchuvm(p);
80104bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd5:	89 04 24             	mov    %eax,(%esp)
80104bd8:	e8 fd 33 00 00       	call   80107fda <switchuvm>
		  t->state = RUNNING;
80104bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104be0:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)

		  // cprintf("pid: %d \n",proc->pid );
		  swtch(&cpu->scheduler, t->context);
80104be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bea:	8b 40 14             	mov    0x14(%eax),%eax
80104bed:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bf4:	83 c2 04             	add    $0x4,%edx
80104bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bfb:	89 14 24             	mov    %edx,(%esp)
80104bfe:	e8 ae 09 00 00       	call   801055b1 <swtch>
		  switchkvm();
80104c03:	e8 b5 33 00 00       	call   80107fbd <switchkvm>

		  // Process is done running for now.
		  // It should have changed its p->state before coming back.
		  thread =0;
80104c08:	65 c7 05 08 00 00 00 	movl   $0x0,%gs:0x8
80104c0f:	00 00 00 00 
		  proc = 0;
80104c13:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c1a:	00 00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){

    	if(! procIsReady(p))
    		continue;

    	for (t=p->threads; t< &p->threads[NTHREAD]; t++ )
80104c1e:	83 45 f0 24          	addl   $0x24,-0x10(%ebp)
80104c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c25:	8b 40 74             	mov    0x74(%eax),%eax
80104c28:	05 40 02 00 00       	add    $0x240,%eax
80104c2d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104c30:	77 81                	ja     80104bb3 <scheduler+0x42>
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c32:	83 45 f4 78          	addl   $0x78,-0xc(%ebp)
80104c36:	81 7d f4 d4 e7 11 80 	cmpl   $0x8011e7d4,-0xc(%ebp)
80104c3d:	0f 82 51 ff ff ff    	jb     80104b94 <scheduler+0x23>
		  proc = 0;

    	}

    }
    release(&ptable.lock);
80104c43:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104c4a:	e8 df 04 00 00       	call   8010512e <release>

  }
80104c4f:	e9 23 ff ff ff       	jmp    80104b77 <scheduler+0x6>

80104c54 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c54:	55                   	push   %ebp
80104c55:	89 e5                	mov    %esp,%ebp
80104c57:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c5a:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104c61:	e8 90 05 00 00       	call   801051f6 <holding>
80104c66:	85 c0                	test   %eax,%eax
80104c68:	75 0c                	jne    80104c76 <sched+0x22>
    panic("sched ptable.lock");
80104c6a:	c7 04 24 09 8e 10 80 	movl   $0x80108e09,(%esp)
80104c71:	e8 c4 b8 ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104c76:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c7c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c82:	83 f8 01             	cmp    $0x1,%eax
80104c85:	74 0c                	je     80104c93 <sched+0x3f>
    panic("sched locks");
80104c87:	c7 04 24 1b 8e 10 80 	movl   $0x80108e1b,(%esp)
80104c8e:	e8 a7 b8 ff ff       	call   8010053a <panic>
  if(thread->state == RUNNING)
80104c93:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104c99:	8b 40 04             	mov    0x4(%eax),%eax
80104c9c:	83 f8 04             	cmp    $0x4,%eax
80104c9f:	75 0c                	jne    80104cad <sched+0x59>
    panic("sched running");
80104ca1:	c7 04 24 27 8e 10 80 	movl   $0x80108e27,(%esp)
80104ca8:	e8 8d b8 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104cad:	e8 36 f6 ff ff       	call   801042e8 <readeflags>
80104cb2:	25 00 02 00 00       	and    $0x200,%eax
80104cb7:	85 c0                	test   %eax,%eax
80104cb9:	74 0c                	je     80104cc7 <sched+0x73>
    panic("sched interruptible");
80104cbb:	c7 04 24 35 8e 10 80 	movl   $0x80108e35,(%esp)
80104cc2:	e8 73 b8 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104cc7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ccd:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104cd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&thread->context, cpu->scheduler);
80104cd6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cdc:	8b 40 04             	mov    0x4(%eax),%eax
80104cdf:	65 8b 15 08 00 00 00 	mov    %gs:0x8,%edx
80104ce6:	83 c2 14             	add    $0x14,%edx
80104ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ced:	89 14 24             	mov    %edx,(%esp)
80104cf0:	e8 bc 08 00 00       	call   801055b1 <swtch>

  cpu->intena = intena;
80104cf5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cfb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cfe:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)

}
80104d04:	c9                   	leave  
80104d05:	c3                   	ret    

80104d06 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d06:	55                   	push   %ebp
80104d07:	89 e5                	mov    %esp,%ebp
80104d09:	83 ec 18             	sub    $0x18,%esp

  acquire(&ptable.lock);  //DOC: yieldlock
80104d0c:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104d13:	e8 b4 03 00 00       	call   801050cc <acquire>

  thread->state =  RUNNABLE;
80104d18:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104d1e:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)

  sched();
80104d25:	e8 2a ff ff ff       	call   80104c54 <sched>
  release(&ptable.lock);
80104d2a:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104d31:	e8 f8 03 00 00       	call   8010512e <release>

}
80104d36:	c9                   	leave  
80104d37:	c3                   	ret    

80104d38 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d38:	55                   	push   %ebp
80104d39:	89 e5                	mov    %esp,%ebp
80104d3b:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d3e:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104d45:	e8 e4 03 00 00       	call   8010512e <release>

  if (first) {
80104d4a:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80104d4f:	85 c0                	test   %eax,%eax
80104d51:	74 0f                	je     80104d62 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d53:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80104d5a:	00 00 00 
    initlog();
80104d5d:	e8 a0 e4 ff ff       	call   80103202 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d62:	c9                   	leave  
80104d63:	c3                   	ret    

80104d64 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d64:	55                   	push   %ebp
80104d65:	89 e5                	mov    %esp,%ebp
80104d67:	83 ec 18             	sub    $0x18,%esp


  if(proc == 0)
80104d6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d70:	85 c0                	test   %eax,%eax
80104d72:	75 0c                	jne    80104d80 <sleep+0x1c>
    panic("sleep");
80104d74:	c7 04 24 49 8e 10 80 	movl   $0x80108e49,(%esp)
80104d7b:	e8 ba b7 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104d80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d84:	75 0c                	jne    80104d92 <sleep+0x2e>
    panic("sleep without lk");
80104d86:	c7 04 24 4f 8e 10 80 	movl   $0x80108e4f,(%esp)
80104d8d:	e8 a8 b7 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d92:	81 7d 0c a0 39 11 80 	cmpl   $0x801139a0,0xc(%ebp)
80104d99:	74 17                	je     80104db2 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d9b:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104da2:	e8 25 03 00 00       	call   801050cc <acquire>
    release(lk);
80104da7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104daa:	89 04 24             	mov    %eax,(%esp)
80104dad:	e8 7c 03 00 00       	call   8010512e <release>
  // Go to sleep.




  thread->chan = chan;
80104db2:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104db8:	8b 55 08             	mov    0x8(%ebp),%edx
80104dbb:	89 50 18             	mov    %edx,0x18(%eax)
  thread->state = SLEEPING;
80104dbe:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104dc4:	c7 40 04 02 00 00 00 	movl   $0x2,0x4(%eax)


  sched();
80104dcb:	e8 84 fe ff ff       	call   80104c54 <sched>

  // Tidy up.

  thread->chan = 0;
80104dd0:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80104dd6:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)


  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ddd:	81 7d 0c a0 39 11 80 	cmpl   $0x801139a0,0xc(%ebp)
80104de4:	74 17                	je     80104dfd <sleep+0x99>
    release(&ptable.lock);
80104de6:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104ded:	e8 3c 03 00 00       	call   8010512e <release>
    acquire(lk);
80104df2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104df5:	89 04 24             	mov    %eax,(%esp)
80104df8:	e8 cf 02 00 00       	call   801050cc <acquire>
  }
}
80104dfd:	c9                   	leave  
80104dfe:	c3                   	ret    

80104dff <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104dff:	55                   	push   %ebp
80104e00:	89 e5                	mov    %esp,%ebp
80104e02:	83 ec 14             	sub    $0x14,%esp

  struct proc *p;

  struct kthread *t;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e05:	c7 45 fc d4 c9 11 80 	movl   $0x8011c9d4,-0x4(%ebp)
80104e0c:	eb 54                	jmp    80104e62 <wakeup1+0x63>

	  if (! procIsReady(p))
80104e0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e11:	89 04 24             	mov    %eax,(%esp)
80104e14:	e8 e5 f4 ff ff       	call   801042fe <procIsReady>
80104e19:	85 c0                	test   %eax,%eax
80104e1b:	75 02                	jne    80104e1f <wakeup1+0x20>
		  	 continue;
80104e1d:	eb 3f                	jmp    80104e5e <wakeup1+0x5f>



	  for(t= p->threads; t < &p->threads[NTHREAD]; t++){
80104e1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e22:	8b 40 74             	mov    0x74(%eax),%eax
80104e25:	89 45 f8             	mov    %eax,-0x8(%ebp)
80104e28:	eb 24                	jmp    80104e4e <wakeup1+0x4f>

		  if(t->state == SLEEPING && t->chan == chan){
80104e2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e2d:	8b 40 04             	mov    0x4(%eax),%eax
80104e30:	83 f8 02             	cmp    $0x2,%eax
80104e33:	75 15                	jne    80104e4a <wakeup1+0x4b>
80104e35:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e38:	8b 40 18             	mov    0x18(%eax),%eax
80104e3b:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e3e:	75 0a                	jne    80104e4a <wakeup1+0x4b>
			  t->state =  RUNNABLE;
80104e40:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e43:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)
	  if (! procIsReady(p))
		  	 continue;



	  for(t= p->threads; t < &p->threads[NTHREAD]; t++){
80104e4a:	83 45 f8 24          	addl   $0x24,-0x8(%ebp)
80104e4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e51:	8b 40 74             	mov    0x74(%eax),%eax
80104e54:	05 40 02 00 00       	add    $0x240,%eax
80104e59:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e5c:	77 cc                	ja     80104e2a <wakeup1+0x2b>

  struct proc *p;

  struct kthread *t;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e5e:	83 45 fc 78          	addl   $0x78,-0x4(%ebp)
80104e62:	81 7d fc d4 e7 11 80 	cmpl   $0x8011e7d4,-0x4(%ebp)
80104e69:	72 a3                	jb     80104e0e <wakeup1+0xf>
	  }



  }
}
80104e6b:	c9                   	leave  
80104e6c:	c3                   	ret    

80104e6d <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e6d:	55                   	push   %ebp
80104e6e:	89 e5                	mov    %esp,%ebp
80104e70:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104e73:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104e7a:	e8 4d 02 00 00       	call   801050cc <acquire>

  wakeup1(chan);
80104e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e82:	89 04 24             	mov    %eax,(%esp)
80104e85:	e8 75 ff ff ff       	call   80104dff <wakeup1>

  release(&ptable.lock);
80104e8a:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104e91:	e8 98 02 00 00       	call   8010512e <release>

}
80104e96:	c9                   	leave  
80104e97:	c3                   	ret    

80104e98 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e98:	55                   	push   %ebp
80104e99:	89 e5                	mov    %esp,%ebp
80104e9b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e9e:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104ea5:	e8 22 02 00 00       	call   801050cc <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104eaa:	c7 45 f4 d4 c9 11 80 	movl   $0x8011c9d4,-0xc(%ebp)
80104eb1:	e9 82 00 00 00       	jmp    80104f38 <kill+0xa0>
    if(p->pid == pid){
80104eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb9:	8b 40 10             	mov    0x10(%eax),%eax
80104ebc:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ebf:	75 73                	jne    80104f34 <kill+0x9c>
      p->killed = 1;
80104ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec4:	c7 40 1c 01 00 00 00 	movl   $0x1,0x1c(%eax)
      // Wake process from sleep if necessary.
      int i;
      for (i=0; i<NTHREAD; i++){
80104ecb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104ed2:	eb 47                	jmp    80104f1b <kill+0x83>
    	  p->killed =1;
80104ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed7:	c7 40 1c 01 00 00 00 	movl   $0x1,0x1c(%eax)
    	  if(p->threads[i].state == SLEEPING)
80104ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee1:	8b 48 74             	mov    0x74(%eax),%ecx
80104ee4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ee7:	89 d0                	mov    %edx,%eax
80104ee9:	c1 e0 03             	shl    $0x3,%eax
80104eec:	01 d0                	add    %edx,%eax
80104eee:	c1 e0 02             	shl    $0x2,%eax
80104ef1:	01 c8                	add    %ecx,%eax
80104ef3:	8b 40 04             	mov    0x4(%eax),%eax
80104ef6:	83 f8 02             	cmp    $0x2,%eax
80104ef9:	75 1c                	jne    80104f17 <kill+0x7f>
    		  	 p->threads[i].state =  RUNNABLE;
80104efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104efe:	8b 48 74             	mov    0x74(%eax),%ecx
80104f01:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f04:	89 d0                	mov    %edx,%eax
80104f06:	c1 e0 03             	shl    $0x3,%eax
80104f09:	01 d0                	add    %edx,%eax
80104f0b:	c1 e0 02             	shl    $0x2,%eax
80104f0e:	01 c8                	add    %ecx,%eax
80104f10:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      int i;
      for (i=0; i<NTHREAD; i++){
80104f17:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104f1b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104f1f:	7e b3                	jle    80104ed4 <kill+0x3c>
    	  p->killed =1;
    	  if(p->threads[i].state == SLEEPING)
    		  	 p->threads[i].state =  RUNNABLE;
      }
      release(&ptable.lock);
80104f21:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104f28:	e8 01 02 00 00       	call   8010512e <release>
      return 0;
80104f2d:	b8 00 00 00 00       	mov    $0x0,%eax
80104f32:	eb 22                	jmp    80104f56 <kill+0xbe>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f34:	83 45 f4 78          	addl   $0x78,-0xc(%ebp)
80104f38:	81 7d f4 d4 e7 11 80 	cmpl   $0x8011e7d4,-0xc(%ebp)
80104f3f:	0f 82 71 ff ff ff    	jb     80104eb6 <kill+0x1e>
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104f45:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80104f4c:	e8 dd 01 00 00       	call   8010512e <release>
  return -1;
80104f51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f56:	c9                   	leave  
80104f57:	c3                   	ret    

80104f58 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f58:	55                   	push   %ebp
80104f59:	89 e5                	mov    %esp,%ebp
80104f5b:	83 ec 58             	sub    $0x58,%esp
  struct proc *p;
  struct kthread *t;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f5e:	c7 45 f0 d4 c9 11 80 	movl   $0x8011c9d4,-0x10(%ebp)
80104f65:	e9 fc 00 00 00       	jmp    80105066 <procdump+0x10e>
	  for (t=p->threads; t< &p->threads[NTHREAD]; t++ )
80104f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f6d:	8b 40 74             	mov    0x74(%eax),%eax
80104f70:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f73:	e9 d6 00 00 00       	jmp    8010504e <procdump+0xf6>
	  {
		if(t->state == UNUSED)
80104f78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f7b:	8b 40 04             	mov    0x4(%eax),%eax
80104f7e:	85 c0                	test   %eax,%eax
80104f80:	75 05                	jne    80104f87 <procdump+0x2f>
		  continue;
80104f82:	e9 c3 00 00 00       	jmp    8010504a <procdump+0xf2>
		if(t->state >= 0 && t->state < NELEM(states) && states[p->state])
80104f87:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f8a:	8b 40 04             	mov    0x4(%eax),%eax
80104f8d:	83 f8 05             	cmp    $0x5,%eax
80104f90:	77 23                	ja     80104fb5 <procdump+0x5d>
80104f92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f95:	8b 40 0c             	mov    0xc(%eax),%eax
80104f98:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80104f9f:	85 c0                	test   %eax,%eax
80104fa1:	74 12                	je     80104fb5 <procdump+0x5d>
		  state = states[t->state];
80104fa3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104fa6:	8b 40 04             	mov    0x4(%eax),%eax
80104fa9:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80104fb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
80104fb3:	eb 07                	jmp    80104fbc <procdump+0x64>
		else
		  state = "???";
80104fb5:	c7 45 e8 60 8e 10 80 	movl   $0x80108e60,-0x18(%ebp)
		cprintf("%d %s %s", p->pid, state, p->name);
80104fbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fbf:	8d 50 64             	lea    0x64(%eax),%edx
80104fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc5:	8b 40 10             	mov    0x10(%eax),%eax
80104fc8:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104fcc:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104fcf:	89 54 24 08          	mov    %edx,0x8(%esp)
80104fd3:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fd7:	c7 04 24 64 8e 10 80 	movl   $0x80108e64,(%esp)
80104fde:	e8 bd b3 ff ff       	call   801003a0 <cprintf>
		if(t->state == SLEEPING){
80104fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104fe6:	8b 40 04             	mov    0x4(%eax),%eax
80104fe9:	83 f8 02             	cmp    $0x2,%eax
80104fec:	75 50                	jne    8010503e <procdump+0xe6>
		  getcallerpcs((uint*)t->context->ebp+2, pc);
80104fee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ff1:	8b 40 14             	mov    0x14(%eax),%eax
80104ff4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ff7:	83 c0 08             	add    $0x8,%eax
80104ffa:	8d 55 c0             	lea    -0x40(%ebp),%edx
80104ffd:	89 54 24 04          	mov    %edx,0x4(%esp)
80105001:	89 04 24             	mov    %eax,(%esp)
80105004:	e8 74 01 00 00       	call   8010517d <getcallerpcs>
		  for(i=0; i<10 && pc[i] != 0; i++)
80105009:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105010:	eb 1b                	jmp    8010502d <procdump+0xd5>
			cprintf(" %p", pc[i]);
80105012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105015:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105019:	89 44 24 04          	mov    %eax,0x4(%esp)
8010501d:	c7 04 24 6d 8e 10 80 	movl   $0x80108e6d,(%esp)
80105024:	e8 77 b3 ff ff       	call   801003a0 <cprintf>
		else
		  state = "???";
		cprintf("%d %s %s", p->pid, state, p->name);
		if(t->state == SLEEPING){
		  getcallerpcs((uint*)t->context->ebp+2, pc);
		  for(i=0; i<10 && pc[i] != 0; i++)
80105029:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010502d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105031:	7f 0b                	jg     8010503e <procdump+0xe6>
80105033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105036:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
8010503a:	85 c0                	test   %eax,%eax
8010503c:	75 d4                	jne    80105012 <procdump+0xba>
			cprintf(" %p", pc[i]);

		}
		cprintf("\n");
8010503e:	c7 04 24 71 8e 10 80 	movl   $0x80108e71,(%esp)
80105045:	e8 56 b3 ff ff       	call   801003a0 <cprintf>
  struct kthread *t;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
	  for (t=p->threads; t< &p->threads[NTHREAD]; t++ )
8010504a:	83 45 ec 24          	addl   $0x24,-0x14(%ebp)
8010504e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105051:	8b 40 74             	mov    0x74(%eax),%eax
80105054:	05 40 02 00 00       	add    $0x240,%eax
80105059:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010505c:	0f 87 16 ff ff ff    	ja     80104f78 <procdump+0x20>
  struct proc *p;
  struct kthread *t;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105062:	83 45 f0 78          	addl   $0x78,-0x10(%ebp)
80105066:	81 7d f0 d4 e7 11 80 	cmpl   $0x8011e7d4,-0x10(%ebp)
8010506d:	0f 82 f7 fe ff ff    	jb     80104f6a <procdump+0x12>

		}
		cprintf("\n");
  	  }
  }
}
80105073:	c9                   	leave  
80105074:	c3                   	ret    

80105075 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105075:	55                   	push   %ebp
80105076:	89 e5                	mov    %esp,%ebp
80105078:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010507b:	9c                   	pushf  
8010507c:	58                   	pop    %eax
8010507d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105080:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105083:	c9                   	leave  
80105084:	c3                   	ret    

80105085 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105085:	55                   	push   %ebp
80105086:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105088:	fa                   	cli    
}
80105089:	5d                   	pop    %ebp
8010508a:	c3                   	ret    

8010508b <sti>:

static inline void
sti(void)
{
8010508b:	55                   	push   %ebp
8010508c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010508e:	fb                   	sti    
}
8010508f:	5d                   	pop    %ebp
80105090:	c3                   	ret    

80105091 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105091:	55                   	push   %ebp
80105092:	89 e5                	mov    %esp,%ebp
80105094:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105097:	8b 55 08             	mov    0x8(%ebp),%edx
8010509a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010509d:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050a0:	f0 87 02             	lock xchg %eax,(%edx)
801050a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801050a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050a9:	c9                   	leave  
801050aa:	c3                   	ret    

801050ab <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801050ab:	55                   	push   %ebp
801050ac:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801050ae:	8b 45 08             	mov    0x8(%ebp),%eax
801050b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801050b4:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801050b7:	8b 45 08             	mov    0x8(%ebp),%eax
801050ba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801050c0:	8b 45 08             	mov    0x8(%ebp),%eax
801050c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801050ca:	5d                   	pop    %ebp
801050cb:	c3                   	ret    

801050cc <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801050cc:	55                   	push   %ebp
801050cd:	89 e5                	mov    %esp,%ebp
801050cf:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801050d2:	e8 49 01 00 00       	call   80105220 <pushcli>
  if(holding(lk))
801050d7:	8b 45 08             	mov    0x8(%ebp),%eax
801050da:	89 04 24             	mov    %eax,(%esp)
801050dd:	e8 14 01 00 00       	call   801051f6 <holding>
801050e2:	85 c0                	test   %eax,%eax
801050e4:	74 0c                	je     801050f2 <acquire+0x26>
    panic("acquire");
801050e6:	c7 04 24 9d 8e 10 80 	movl   $0x80108e9d,(%esp)
801050ed:	e8 48 b4 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801050f2:	90                   	nop
801050f3:	8b 45 08             	mov    0x8(%ebp),%eax
801050f6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801050fd:	00 
801050fe:	89 04 24             	mov    %eax,(%esp)
80105101:	e8 8b ff ff ff       	call   80105091 <xchg>
80105106:	85 c0                	test   %eax,%eax
80105108:	75 e9                	jne    801050f3 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010510a:	8b 45 08             	mov    0x8(%ebp),%eax
8010510d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105114:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105117:	8b 45 08             	mov    0x8(%ebp),%eax
8010511a:	83 c0 0c             	add    $0xc,%eax
8010511d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105121:	8d 45 08             	lea    0x8(%ebp),%eax
80105124:	89 04 24             	mov    %eax,(%esp)
80105127:	e8 51 00 00 00       	call   8010517d <getcallerpcs>
}
8010512c:	c9                   	leave  
8010512d:	c3                   	ret    

8010512e <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010512e:	55                   	push   %ebp
8010512f:	89 e5                	mov    %esp,%ebp
80105131:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105134:	8b 45 08             	mov    0x8(%ebp),%eax
80105137:	89 04 24             	mov    %eax,(%esp)
8010513a:	e8 b7 00 00 00       	call   801051f6 <holding>
8010513f:	85 c0                	test   %eax,%eax
80105141:	75 0c                	jne    8010514f <release+0x21>
    panic("release");
80105143:	c7 04 24 a5 8e 10 80 	movl   $0x80108ea5,(%esp)
8010514a:	e8 eb b3 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
8010514f:	8b 45 08             	mov    0x8(%ebp),%eax
80105152:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105159:	8b 45 08             	mov    0x8(%ebp),%eax
8010515c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105163:	8b 45 08             	mov    0x8(%ebp),%eax
80105166:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010516d:	00 
8010516e:	89 04 24             	mov    %eax,(%esp)
80105171:	e8 1b ff ff ff       	call   80105091 <xchg>

  popcli();
80105176:	e8 e9 00 00 00       	call   80105264 <popcli>
}
8010517b:	c9                   	leave  
8010517c:	c3                   	ret    

8010517d <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010517d:	55                   	push   %ebp
8010517e:	89 e5                	mov    %esp,%ebp
80105180:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105183:	8b 45 08             	mov    0x8(%ebp),%eax
80105186:	83 e8 08             	sub    $0x8,%eax
80105189:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010518c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105193:	eb 38                	jmp    801051cd <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105195:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105199:	74 38                	je     801051d3 <getcallerpcs+0x56>
8010519b:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801051a2:	76 2f                	jbe    801051d3 <getcallerpcs+0x56>
801051a4:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801051a8:	74 29                	je     801051d3 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
801051aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801051b7:	01 c2                	add    %eax,%edx
801051b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051bc:	8b 40 04             	mov    0x4(%eax),%eax
801051bf:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801051c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051c4:	8b 00                	mov    (%eax),%eax
801051c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801051c9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051cd:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051d1:	7e c2                	jle    80105195 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051d3:	eb 19                	jmp    801051ee <getcallerpcs+0x71>
    pcs[i] = 0;
801051d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051df:	8b 45 0c             	mov    0xc(%ebp),%eax
801051e2:	01 d0                	add    %edx,%eax
801051e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051ea:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051ee:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051f2:	7e e1                	jle    801051d5 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801051f4:	c9                   	leave  
801051f5:	c3                   	ret    

801051f6 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051f6:	55                   	push   %ebp
801051f7:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801051f9:	8b 45 08             	mov    0x8(%ebp),%eax
801051fc:	8b 00                	mov    (%eax),%eax
801051fe:	85 c0                	test   %eax,%eax
80105200:	74 17                	je     80105219 <holding+0x23>
80105202:	8b 45 08             	mov    0x8(%ebp),%eax
80105205:	8b 50 08             	mov    0x8(%eax),%edx
80105208:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010520e:	39 c2                	cmp    %eax,%edx
80105210:	75 07                	jne    80105219 <holding+0x23>
80105212:	b8 01 00 00 00       	mov    $0x1,%eax
80105217:	eb 05                	jmp    8010521e <holding+0x28>
80105219:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010521e:	5d                   	pop    %ebp
8010521f:	c3                   	ret    

80105220 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105220:	55                   	push   %ebp
80105221:	89 e5                	mov    %esp,%ebp
80105223:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105226:	e8 4a fe ff ff       	call   80105075 <readeflags>
8010522b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010522e:	e8 52 fe ff ff       	call   80105085 <cli>
  if(cpu->ncli++ == 0)
80105233:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010523a:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105240:	8d 48 01             	lea    0x1(%eax),%ecx
80105243:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105249:	85 c0                	test   %eax,%eax
8010524b:	75 15                	jne    80105262 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010524d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105253:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105256:	81 e2 00 02 00 00    	and    $0x200,%edx
8010525c:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105262:	c9                   	leave  
80105263:	c3                   	ret    

80105264 <popcli>:

void
popcli(void)
{
80105264:	55                   	push   %ebp
80105265:	89 e5                	mov    %esp,%ebp
80105267:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010526a:	e8 06 fe ff ff       	call   80105075 <readeflags>
8010526f:	25 00 02 00 00       	and    $0x200,%eax
80105274:	85 c0                	test   %eax,%eax
80105276:	74 0c                	je     80105284 <popcli+0x20>
    panic("popcli - interruptible");
80105278:	c7 04 24 ad 8e 10 80 	movl   $0x80108ead,(%esp)
8010527f:	e8 b6 b2 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105284:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010528a:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105290:	83 ea 01             	sub    $0x1,%edx
80105293:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105299:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010529f:	85 c0                	test   %eax,%eax
801052a1:	79 0c                	jns    801052af <popcli+0x4b>
    panic("popcli");
801052a3:	c7 04 24 c4 8e 10 80 	movl   $0x80108ec4,(%esp)
801052aa:	e8 8b b2 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
801052af:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052b5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801052bb:	85 c0                	test   %eax,%eax
801052bd:	75 15                	jne    801052d4 <popcli+0x70>
801052bf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052c5:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052cb:	85 c0                	test   %eax,%eax
801052cd:	74 05                	je     801052d4 <popcli+0x70>
    sti();
801052cf:	e8 b7 fd ff ff       	call   8010508b <sti>
}
801052d4:	c9                   	leave  
801052d5:	c3                   	ret    

801052d6 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801052d6:	55                   	push   %ebp
801052d7:	89 e5                	mov    %esp,%ebp
801052d9:	57                   	push   %edi
801052da:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052db:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052de:	8b 55 10             	mov    0x10(%ebp),%edx
801052e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e4:	89 cb                	mov    %ecx,%ebx
801052e6:	89 df                	mov    %ebx,%edi
801052e8:	89 d1                	mov    %edx,%ecx
801052ea:	fc                   	cld    
801052eb:	f3 aa                	rep stos %al,%es:(%edi)
801052ed:	89 ca                	mov    %ecx,%edx
801052ef:	89 fb                	mov    %edi,%ebx
801052f1:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052f4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052f7:	5b                   	pop    %ebx
801052f8:	5f                   	pop    %edi
801052f9:	5d                   	pop    %ebp
801052fa:	c3                   	ret    

801052fb <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801052fb:	55                   	push   %ebp
801052fc:	89 e5                	mov    %esp,%ebp
801052fe:	57                   	push   %edi
801052ff:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105300:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105303:	8b 55 10             	mov    0x10(%ebp),%edx
80105306:	8b 45 0c             	mov    0xc(%ebp),%eax
80105309:	89 cb                	mov    %ecx,%ebx
8010530b:	89 df                	mov    %ebx,%edi
8010530d:	89 d1                	mov    %edx,%ecx
8010530f:	fc                   	cld    
80105310:	f3 ab                	rep stos %eax,%es:(%edi)
80105312:	89 ca                	mov    %ecx,%edx
80105314:	89 fb                	mov    %edi,%ebx
80105316:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105319:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010531c:	5b                   	pop    %ebx
8010531d:	5f                   	pop    %edi
8010531e:	5d                   	pop    %ebp
8010531f:	c3                   	ret    

80105320 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105320:	55                   	push   %ebp
80105321:	89 e5                	mov    %esp,%ebp
80105323:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105326:	8b 45 08             	mov    0x8(%ebp),%eax
80105329:	83 e0 03             	and    $0x3,%eax
8010532c:	85 c0                	test   %eax,%eax
8010532e:	75 49                	jne    80105379 <memset+0x59>
80105330:	8b 45 10             	mov    0x10(%ebp),%eax
80105333:	83 e0 03             	and    $0x3,%eax
80105336:	85 c0                	test   %eax,%eax
80105338:	75 3f                	jne    80105379 <memset+0x59>
    c &= 0xFF;
8010533a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105341:	8b 45 10             	mov    0x10(%ebp),%eax
80105344:	c1 e8 02             	shr    $0x2,%eax
80105347:	89 c2                	mov    %eax,%edx
80105349:	8b 45 0c             	mov    0xc(%ebp),%eax
8010534c:	c1 e0 18             	shl    $0x18,%eax
8010534f:	89 c1                	mov    %eax,%ecx
80105351:	8b 45 0c             	mov    0xc(%ebp),%eax
80105354:	c1 e0 10             	shl    $0x10,%eax
80105357:	09 c1                	or     %eax,%ecx
80105359:	8b 45 0c             	mov    0xc(%ebp),%eax
8010535c:	c1 e0 08             	shl    $0x8,%eax
8010535f:	09 c8                	or     %ecx,%eax
80105361:	0b 45 0c             	or     0xc(%ebp),%eax
80105364:	89 54 24 08          	mov    %edx,0x8(%esp)
80105368:	89 44 24 04          	mov    %eax,0x4(%esp)
8010536c:	8b 45 08             	mov    0x8(%ebp),%eax
8010536f:	89 04 24             	mov    %eax,(%esp)
80105372:	e8 84 ff ff ff       	call   801052fb <stosl>
80105377:	eb 19                	jmp    80105392 <memset+0x72>
  } else
    stosb(dst, c, n);
80105379:	8b 45 10             	mov    0x10(%ebp),%eax
8010537c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105380:	8b 45 0c             	mov    0xc(%ebp),%eax
80105383:	89 44 24 04          	mov    %eax,0x4(%esp)
80105387:	8b 45 08             	mov    0x8(%ebp),%eax
8010538a:	89 04 24             	mov    %eax,(%esp)
8010538d:	e8 44 ff ff ff       	call   801052d6 <stosb>
  return dst;
80105392:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105395:	c9                   	leave  
80105396:	c3                   	ret    

80105397 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105397:	55                   	push   %ebp
80105398:	89 e5                	mov    %esp,%ebp
8010539a:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010539d:	8b 45 08             	mov    0x8(%ebp),%eax
801053a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801053a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053a6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801053a9:	eb 30                	jmp    801053db <memcmp+0x44>
    if(*s1 != *s2)
801053ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ae:	0f b6 10             	movzbl (%eax),%edx
801053b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053b4:	0f b6 00             	movzbl (%eax),%eax
801053b7:	38 c2                	cmp    %al,%dl
801053b9:	74 18                	je     801053d3 <memcmp+0x3c>
      return *s1 - *s2;
801053bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053be:	0f b6 00             	movzbl (%eax),%eax
801053c1:	0f b6 d0             	movzbl %al,%edx
801053c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053c7:	0f b6 00             	movzbl (%eax),%eax
801053ca:	0f b6 c0             	movzbl %al,%eax
801053cd:	29 c2                	sub    %eax,%edx
801053cf:	89 d0                	mov    %edx,%eax
801053d1:	eb 1a                	jmp    801053ed <memcmp+0x56>
    s1++, s2++;
801053d3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053d7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801053db:	8b 45 10             	mov    0x10(%ebp),%eax
801053de:	8d 50 ff             	lea    -0x1(%eax),%edx
801053e1:	89 55 10             	mov    %edx,0x10(%ebp)
801053e4:	85 c0                	test   %eax,%eax
801053e6:	75 c3                	jne    801053ab <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801053e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053ed:	c9                   	leave  
801053ee:	c3                   	ret    

801053ef <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053ef:	55                   	push   %ebp
801053f0:	89 e5                	mov    %esp,%ebp
801053f2:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801053f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053fb:	8b 45 08             	mov    0x8(%ebp),%eax
801053fe:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105401:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105404:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105407:	73 3d                	jae    80105446 <memmove+0x57>
80105409:	8b 45 10             	mov    0x10(%ebp),%eax
8010540c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010540f:	01 d0                	add    %edx,%eax
80105411:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105414:	76 30                	jbe    80105446 <memmove+0x57>
    s += n;
80105416:	8b 45 10             	mov    0x10(%ebp),%eax
80105419:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010541c:	8b 45 10             	mov    0x10(%ebp),%eax
8010541f:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105422:	eb 13                	jmp    80105437 <memmove+0x48>
      *--d = *--s;
80105424:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105428:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010542c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010542f:	0f b6 10             	movzbl (%eax),%edx
80105432:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105435:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105437:	8b 45 10             	mov    0x10(%ebp),%eax
8010543a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010543d:	89 55 10             	mov    %edx,0x10(%ebp)
80105440:	85 c0                	test   %eax,%eax
80105442:	75 e0                	jne    80105424 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105444:	eb 26                	jmp    8010546c <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105446:	eb 17                	jmp    8010545f <memmove+0x70>
      *d++ = *s++;
80105448:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010544b:	8d 50 01             	lea    0x1(%eax),%edx
8010544e:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105451:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105454:	8d 4a 01             	lea    0x1(%edx),%ecx
80105457:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010545a:	0f b6 12             	movzbl (%edx),%edx
8010545d:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010545f:	8b 45 10             	mov    0x10(%ebp),%eax
80105462:	8d 50 ff             	lea    -0x1(%eax),%edx
80105465:	89 55 10             	mov    %edx,0x10(%ebp)
80105468:	85 c0                	test   %eax,%eax
8010546a:	75 dc                	jne    80105448 <memmove+0x59>
      *d++ = *s++;

  return dst;
8010546c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010546f:	c9                   	leave  
80105470:	c3                   	ret    

80105471 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105471:	55                   	push   %ebp
80105472:	89 e5                	mov    %esp,%ebp
80105474:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105477:	8b 45 10             	mov    0x10(%ebp),%eax
8010547a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010547e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105481:	89 44 24 04          	mov    %eax,0x4(%esp)
80105485:	8b 45 08             	mov    0x8(%ebp),%eax
80105488:	89 04 24             	mov    %eax,(%esp)
8010548b:	e8 5f ff ff ff       	call   801053ef <memmove>
}
80105490:	c9                   	leave  
80105491:	c3                   	ret    

80105492 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105492:	55                   	push   %ebp
80105493:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105495:	eb 0c                	jmp    801054a3 <strncmp+0x11>
    n--, p++, q++;
80105497:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010549b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010549f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801054a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054a7:	74 1a                	je     801054c3 <strncmp+0x31>
801054a9:	8b 45 08             	mov    0x8(%ebp),%eax
801054ac:	0f b6 00             	movzbl (%eax),%eax
801054af:	84 c0                	test   %al,%al
801054b1:	74 10                	je     801054c3 <strncmp+0x31>
801054b3:	8b 45 08             	mov    0x8(%ebp),%eax
801054b6:	0f b6 10             	movzbl (%eax),%edx
801054b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801054bc:	0f b6 00             	movzbl (%eax),%eax
801054bf:	38 c2                	cmp    %al,%dl
801054c1:	74 d4                	je     80105497 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801054c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054c7:	75 07                	jne    801054d0 <strncmp+0x3e>
    return 0;
801054c9:	b8 00 00 00 00       	mov    $0x0,%eax
801054ce:	eb 16                	jmp    801054e6 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801054d0:	8b 45 08             	mov    0x8(%ebp),%eax
801054d3:	0f b6 00             	movzbl (%eax),%eax
801054d6:	0f b6 d0             	movzbl %al,%edx
801054d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801054dc:	0f b6 00             	movzbl (%eax),%eax
801054df:	0f b6 c0             	movzbl %al,%eax
801054e2:	29 c2                	sub    %eax,%edx
801054e4:	89 d0                	mov    %edx,%eax
}
801054e6:	5d                   	pop    %ebp
801054e7:	c3                   	ret    

801054e8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054e8:	55                   	push   %ebp
801054e9:	89 e5                	mov    %esp,%ebp
801054eb:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054ee:	8b 45 08             	mov    0x8(%ebp),%eax
801054f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801054f4:	90                   	nop
801054f5:	8b 45 10             	mov    0x10(%ebp),%eax
801054f8:	8d 50 ff             	lea    -0x1(%eax),%edx
801054fb:	89 55 10             	mov    %edx,0x10(%ebp)
801054fe:	85 c0                	test   %eax,%eax
80105500:	7e 1e                	jle    80105520 <strncpy+0x38>
80105502:	8b 45 08             	mov    0x8(%ebp),%eax
80105505:	8d 50 01             	lea    0x1(%eax),%edx
80105508:	89 55 08             	mov    %edx,0x8(%ebp)
8010550b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010550e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105511:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105514:	0f b6 12             	movzbl (%edx),%edx
80105517:	88 10                	mov    %dl,(%eax)
80105519:	0f b6 00             	movzbl (%eax),%eax
8010551c:	84 c0                	test   %al,%al
8010551e:	75 d5                	jne    801054f5 <strncpy+0xd>
    ;
  while(n-- > 0)
80105520:	eb 0c                	jmp    8010552e <strncpy+0x46>
    *s++ = 0;
80105522:	8b 45 08             	mov    0x8(%ebp),%eax
80105525:	8d 50 01             	lea    0x1(%eax),%edx
80105528:	89 55 08             	mov    %edx,0x8(%ebp)
8010552b:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010552e:	8b 45 10             	mov    0x10(%ebp),%eax
80105531:	8d 50 ff             	lea    -0x1(%eax),%edx
80105534:	89 55 10             	mov    %edx,0x10(%ebp)
80105537:	85 c0                	test   %eax,%eax
80105539:	7f e7                	jg     80105522 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010553b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010553e:	c9                   	leave  
8010553f:	c3                   	ret    

80105540 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105540:	55                   	push   %ebp
80105541:	89 e5                	mov    %esp,%ebp
80105543:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105546:	8b 45 08             	mov    0x8(%ebp),%eax
80105549:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010554c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105550:	7f 05                	jg     80105557 <safestrcpy+0x17>
    return os;
80105552:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105555:	eb 31                	jmp    80105588 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105557:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010555b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010555f:	7e 1e                	jle    8010557f <safestrcpy+0x3f>
80105561:	8b 45 08             	mov    0x8(%ebp),%eax
80105564:	8d 50 01             	lea    0x1(%eax),%edx
80105567:	89 55 08             	mov    %edx,0x8(%ebp)
8010556a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010556d:	8d 4a 01             	lea    0x1(%edx),%ecx
80105570:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105573:	0f b6 12             	movzbl (%edx),%edx
80105576:	88 10                	mov    %dl,(%eax)
80105578:	0f b6 00             	movzbl (%eax),%eax
8010557b:	84 c0                	test   %al,%al
8010557d:	75 d8                	jne    80105557 <safestrcpy+0x17>
    ;
  *s = 0;
8010557f:	8b 45 08             	mov    0x8(%ebp),%eax
80105582:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105585:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105588:	c9                   	leave  
80105589:	c3                   	ret    

8010558a <strlen>:

int
strlen(const char *s)
{
8010558a:	55                   	push   %ebp
8010558b:	89 e5                	mov    %esp,%ebp
8010558d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105590:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105597:	eb 04                	jmp    8010559d <strlen+0x13>
80105599:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010559d:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055a0:	8b 45 08             	mov    0x8(%ebp),%eax
801055a3:	01 d0                	add    %edx,%eax
801055a5:	0f b6 00             	movzbl (%eax),%eax
801055a8:	84 c0                	test   %al,%al
801055aa:	75 ed                	jne    80105599 <strlen+0xf>
    ;
  return n;
801055ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055af:	c9                   	leave  
801055b0:	c3                   	ret    

801055b1 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801055b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801055b5:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801055b9:	55                   	push   %ebp
  pushl %ebx
801055ba:	53                   	push   %ebx
  pushl %esi
801055bb:	56                   	push   %esi
  pushl %edi
801055bc:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801055bd:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055bf:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055c1:	5f                   	pop    %edi
  popl %esi
801055c2:	5e                   	pop    %esi
  popl %ebx
801055c3:	5b                   	pop    %ebx
  popl %ebp
801055c4:	5d                   	pop    %ebp
  ret
801055c5:	c3                   	ret    

801055c6 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801055c6:	55                   	push   %ebp
801055c7:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801055c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055cf:	8b 00                	mov    (%eax),%eax
801055d1:	3b 45 08             	cmp    0x8(%ebp),%eax
801055d4:	76 12                	jbe    801055e8 <fetchint+0x22>
801055d6:	8b 45 08             	mov    0x8(%ebp),%eax
801055d9:	8d 50 04             	lea    0x4(%eax),%edx
801055dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055e2:	8b 00                	mov    (%eax),%eax
801055e4:	39 c2                	cmp    %eax,%edx
801055e6:	76 07                	jbe    801055ef <fetchint+0x29>
    return -1;
801055e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ed:	eb 0f                	jmp    801055fe <fetchint+0x38>
  *ip = *(int*)(addr);
801055ef:	8b 45 08             	mov    0x8(%ebp),%eax
801055f2:	8b 10                	mov    (%eax),%edx
801055f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f7:	89 10                	mov    %edx,(%eax)
  return 0;
801055f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055fe:	5d                   	pop    %ebp
801055ff:	c3                   	ret    

80105600 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105600:	55                   	push   %ebp
80105601:	89 e5                	mov    %esp,%ebp
80105603:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105606:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010560c:	8b 00                	mov    (%eax),%eax
8010560e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105611:	77 07                	ja     8010561a <fetchstr+0x1a>
    return -1;
80105613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105618:	eb 46                	jmp    80105660 <fetchstr+0x60>
  *pp = (char*)addr;
8010561a:	8b 55 08             	mov    0x8(%ebp),%edx
8010561d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105620:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105622:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105628:	8b 00                	mov    (%eax),%eax
8010562a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010562d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105630:	8b 00                	mov    (%eax),%eax
80105632:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105635:	eb 1c                	jmp    80105653 <fetchstr+0x53>
    if(*s == 0)
80105637:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010563a:	0f b6 00             	movzbl (%eax),%eax
8010563d:	84 c0                	test   %al,%al
8010563f:	75 0e                	jne    8010564f <fetchstr+0x4f>
      return s - *pp;
80105641:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105644:	8b 45 0c             	mov    0xc(%ebp),%eax
80105647:	8b 00                	mov    (%eax),%eax
80105649:	29 c2                	sub    %eax,%edx
8010564b:	89 d0                	mov    %edx,%eax
8010564d:	eb 11                	jmp    80105660 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010564f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105653:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105656:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105659:	72 dc                	jb     80105637 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010565b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105660:	c9                   	leave  
80105661:	c3                   	ret    

80105662 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105662:	55                   	push   %ebp
80105663:	89 e5                	mov    %esp,%ebp
80105665:	83 ec 08             	sub    $0x8,%esp
  return fetchint(thread->tf->esp + 4 + 4*n, ip);
80105668:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
8010566e:	8b 40 10             	mov    0x10(%eax),%eax
80105671:	8b 50 44             	mov    0x44(%eax),%edx
80105674:	8b 45 08             	mov    0x8(%ebp),%eax
80105677:	c1 e0 02             	shl    $0x2,%eax
8010567a:	01 d0                	add    %edx,%eax
8010567c:	8d 50 04             	lea    0x4(%eax),%edx
8010567f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105682:	89 44 24 04          	mov    %eax,0x4(%esp)
80105686:	89 14 24             	mov    %edx,(%esp)
80105689:	e8 38 ff ff ff       	call   801055c6 <fetchint>
}
8010568e:	c9                   	leave  
8010568f:	c3                   	ret    

80105690 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105690:	55                   	push   %ebp
80105691:	89 e5                	mov    %esp,%ebp
80105693:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105696:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105699:	89 44 24 04          	mov    %eax,0x4(%esp)
8010569d:	8b 45 08             	mov    0x8(%ebp),%eax
801056a0:	89 04 24             	mov    %eax,(%esp)
801056a3:	e8 ba ff ff ff       	call   80105662 <argint>
801056a8:	85 c0                	test   %eax,%eax
801056aa:	79 07                	jns    801056b3 <argptr+0x23>
    return -1;
801056ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056b1:	eb 3d                	jmp    801056f0 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801056b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056b6:	89 c2                	mov    %eax,%edx
801056b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056be:	8b 00                	mov    (%eax),%eax
801056c0:	39 c2                	cmp    %eax,%edx
801056c2:	73 16                	jae    801056da <argptr+0x4a>
801056c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056c7:	89 c2                	mov    %eax,%edx
801056c9:	8b 45 10             	mov    0x10(%ebp),%eax
801056cc:	01 c2                	add    %eax,%edx
801056ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d4:	8b 00                	mov    (%eax),%eax
801056d6:	39 c2                	cmp    %eax,%edx
801056d8:	76 07                	jbe    801056e1 <argptr+0x51>
    return -1;
801056da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056df:	eb 0f                	jmp    801056f0 <argptr+0x60>
  *pp = (char*)i;
801056e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056e4:	89 c2                	mov    %eax,%edx
801056e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801056e9:	89 10                	mov    %edx,(%eax)
  return 0;
801056eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056f0:	c9                   	leave  
801056f1:	c3                   	ret    

801056f2 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801056f2:	55                   	push   %ebp
801056f3:	89 e5                	mov    %esp,%ebp
801056f5:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801056f8:	8d 45 fc             	lea    -0x4(%ebp),%eax
801056fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801056ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105702:	89 04 24             	mov    %eax,(%esp)
80105705:	e8 58 ff ff ff       	call   80105662 <argint>
8010570a:	85 c0                	test   %eax,%eax
8010570c:	79 07                	jns    80105715 <argstr+0x23>
    return -1;
8010570e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105713:	eb 12                	jmp    80105727 <argstr+0x35>
  return fetchstr(addr, pp);
80105715:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105718:	8b 55 0c             	mov    0xc(%ebp),%edx
8010571b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010571f:	89 04 24             	mov    %eax,(%esp)
80105722:	e8 d9 fe ff ff       	call   80105600 <fetchstr>
}
80105727:	c9                   	leave  
80105728:	c3                   	ret    

80105729 <syscall>:
[SYS_kthread_join]    	sys_kthread_join,
};

void
syscall(void)
{
80105729:	55                   	push   %ebp
8010572a:	89 e5                	mov    %esp,%ebp
8010572c:	53                   	push   %ebx
8010572d:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = thread->tf->eax;
80105730:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80105736:	8b 40 10             	mov    0x10(%eax),%eax
80105739:	8b 40 1c             	mov    0x1c(%eax),%eax
8010573c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010573f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105743:	7e 30                	jle    80105775 <syscall+0x4c>
80105745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105748:	83 f8 19             	cmp    $0x19,%eax
8010574b:	77 28                	ja     80105775 <syscall+0x4c>
8010574d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105750:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105757:	85 c0                	test   %eax,%eax
80105759:	74 1a                	je     80105775 <syscall+0x4c>
	  thread->tf->eax = syscalls[num]();
8010575b:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80105761:	8b 58 10             	mov    0x10(%eax),%ebx
80105764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105767:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010576e:	ff d0                	call   *%eax
80105770:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105773:	eb 3d                	jmp    801057b2 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105775:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010577b:	8d 48 64             	lea    0x64(%eax),%ecx
8010577e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = thread->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
	  thread->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105784:	8b 40 10             	mov    0x10(%eax),%eax
80105787:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010578a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010578e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105792:	89 44 24 04          	mov    %eax,0x4(%esp)
80105796:	c7 04 24 cb 8e 10 80 	movl   $0x80108ecb,(%esp)
8010579d:	e8 fe ab ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    thread->tf->eax = -1;
801057a2:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801057a8:	8b 40 10             	mov    0x10(%eax),%eax
801057ab:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801057b2:	83 c4 24             	add    $0x24,%esp
801057b5:	5b                   	pop    %ebx
801057b6:	5d                   	pop    %ebp
801057b7:	c3                   	ret    

801057b8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801057b8:	55                   	push   %ebp
801057b9:	89 e5                	mov    %esp,%ebp
801057bb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801057be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801057c5:	8b 45 08             	mov    0x8(%ebp),%eax
801057c8:	89 04 24             	mov    %eax,(%esp)
801057cb:	e8 92 fe ff ff       	call   80105662 <argint>
801057d0:	85 c0                	test   %eax,%eax
801057d2:	79 07                	jns    801057db <argfd+0x23>
    return -1;
801057d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d9:	eb 4f                	jmp    8010582a <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801057db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057de:	85 c0                	test   %eax,%eax
801057e0:	78 20                	js     80105802 <argfd+0x4a>
801057e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e5:	83 f8 0f             	cmp    $0xf,%eax
801057e8:	7f 18                	jg     80105802 <argfd+0x4a>
801057ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057f3:	83 c2 08             	add    $0x8,%edx
801057f6:	8b 04 90             	mov    (%eax,%edx,4),%eax
801057f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105800:	75 07                	jne    80105809 <argfd+0x51>
    return -1;
80105802:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105807:	eb 21                	jmp    8010582a <argfd+0x72>
  if(pfd)
80105809:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010580d:	74 08                	je     80105817 <argfd+0x5f>
    *pfd = fd;
8010580f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105812:	8b 45 0c             	mov    0xc(%ebp),%eax
80105815:	89 10                	mov    %edx,(%eax)
  if(pf)
80105817:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010581b:	74 08                	je     80105825 <argfd+0x6d>
    *pf = f;
8010581d:	8b 45 10             	mov    0x10(%ebp),%eax
80105820:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105823:	89 10                	mov    %edx,(%eax)
  return 0;
80105825:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010582a:	c9                   	leave  
8010582b:	c3                   	ret    

8010582c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010582c:	55                   	push   %ebp
8010582d:	89 e5                	mov    %esp,%ebp
8010582f:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105832:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105839:	eb 2e                	jmp    80105869 <fdalloc+0x3d>
    if(proc->ofile[fd] == 0){
8010583b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105841:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105844:	83 c2 08             	add    $0x8,%edx
80105847:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010584a:	85 c0                	test   %eax,%eax
8010584c:	75 17                	jne    80105865 <fdalloc+0x39>
      proc->ofile[fd] = f;
8010584e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105854:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105857:	8d 4a 08             	lea    0x8(%edx),%ecx
8010585a:	8b 55 08             	mov    0x8(%ebp),%edx
8010585d:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      return fd;
80105860:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105863:	eb 0f                	jmp    80105874 <fdalloc+0x48>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105865:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105869:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010586d:	7e cc                	jle    8010583b <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010586f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105874:	c9                   	leave  
80105875:	c3                   	ret    

80105876 <sys_dup>:

int
sys_dup(void)
{
80105876:	55                   	push   %ebp
80105877:	89 e5                	mov    %esp,%ebp
80105879:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010587c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010587f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105883:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010588a:	00 
8010588b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105892:	e8 21 ff ff ff       	call   801057b8 <argfd>
80105897:	85 c0                	test   %eax,%eax
80105899:	79 07                	jns    801058a2 <sys_dup+0x2c>
    return -1;
8010589b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a0:	eb 29                	jmp    801058cb <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801058a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a5:	89 04 24             	mov    %eax,(%esp)
801058a8:	e8 7f ff ff ff       	call   8010582c <fdalloc>
801058ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058b4:	79 07                	jns    801058bd <sys_dup+0x47>
    return -1;
801058b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058bb:	eb 0e                	jmp    801058cb <sys_dup+0x55>
  filedup(f);
801058bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c0:	89 04 24             	mov    %eax,(%esp)
801058c3:	e8 be b6 ff ff       	call   80100f86 <filedup>
  return fd;
801058c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801058cb:	c9                   	leave  
801058cc:	c3                   	ret    

801058cd <sys_read>:

int
sys_read(void)
{
801058cd:	55                   	push   %ebp
801058ce:	89 e5                	mov    %esp,%ebp
801058d0:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058d6:	89 44 24 08          	mov    %eax,0x8(%esp)
801058da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058e1:	00 
801058e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058e9:	e8 ca fe ff ff       	call   801057b8 <argfd>
801058ee:	85 c0                	test   %eax,%eax
801058f0:	78 35                	js     80105927 <sys_read+0x5a>
801058f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801058f9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105900:	e8 5d fd ff ff       	call   80105662 <argint>
80105905:	85 c0                	test   %eax,%eax
80105907:	78 1e                	js     80105927 <sys_read+0x5a>
80105909:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010590c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105910:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105913:	89 44 24 04          	mov    %eax,0x4(%esp)
80105917:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010591e:	e8 6d fd ff ff       	call   80105690 <argptr>
80105923:	85 c0                	test   %eax,%eax
80105925:	79 07                	jns    8010592e <sys_read+0x61>
    return -1;
80105927:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592c:	eb 19                	jmp    80105947 <sys_read+0x7a>
  return fileread(f, p, n);
8010592e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105931:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105937:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010593b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010593f:	89 04 24             	mov    %eax,(%esp)
80105942:	e8 ac b7 ff ff       	call   801010f3 <fileread>
}
80105947:	c9                   	leave  
80105948:	c3                   	ret    

80105949 <sys_write>:

int
sys_write(void)
{
80105949:	55                   	push   %ebp
8010594a:	89 e5                	mov    %esp,%ebp
8010594c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010594f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105952:	89 44 24 08          	mov    %eax,0x8(%esp)
80105956:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010595d:	00 
8010595e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105965:	e8 4e fe ff ff       	call   801057b8 <argfd>
8010596a:	85 c0                	test   %eax,%eax
8010596c:	78 35                	js     801059a3 <sys_write+0x5a>
8010596e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105971:	89 44 24 04          	mov    %eax,0x4(%esp)
80105975:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010597c:	e8 e1 fc ff ff       	call   80105662 <argint>
80105981:	85 c0                	test   %eax,%eax
80105983:	78 1e                	js     801059a3 <sys_write+0x5a>
80105985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105988:	89 44 24 08          	mov    %eax,0x8(%esp)
8010598c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010598f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105993:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010599a:	e8 f1 fc ff ff       	call   80105690 <argptr>
8010599f:	85 c0                	test   %eax,%eax
801059a1:	79 07                	jns    801059aa <sys_write+0x61>
    return -1;
801059a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059a8:	eb 19                	jmp    801059c3 <sys_write+0x7a>
  return filewrite(f, p, n);
801059aa:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801059bb:	89 04 24             	mov    %eax,(%esp)
801059be:	e8 ec b7 ff ff       	call   801011af <filewrite>
}
801059c3:	c9                   	leave  
801059c4:	c3                   	ret    

801059c5 <sys_close>:

int
sys_close(void)
{
801059c5:	55                   	push   %ebp
801059c6:	89 e5                	mov    %esp,%ebp
801059c8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801059cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059ce:	89 44 24 08          	mov    %eax,0x8(%esp)
801059d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801059d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059e0:	e8 d3 fd ff ff       	call   801057b8 <argfd>
801059e5:	85 c0                	test   %eax,%eax
801059e7:	79 07                	jns    801059f0 <sys_close+0x2b>
    return -1;
801059e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ee:	eb 23                	jmp    80105a13 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801059f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059f9:	83 c2 08             	add    $0x8,%edx
801059fc:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
  fileclose(f);
80105a03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a06:	89 04 24             	mov    %eax,(%esp)
80105a09:	e8 c0 b5 ff ff       	call   80100fce <fileclose>
  return 0;
80105a0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a13:	c9                   	leave  
80105a14:	c3                   	ret    

80105a15 <sys_fstat>:

int
sys_fstat(void)
{
80105a15:	55                   	push   %ebp
80105a16:	89 e5                	mov    %esp,%ebp
80105a18:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a1e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a29:	00 
80105a2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a31:	e8 82 fd ff ff       	call   801057b8 <argfd>
80105a36:	85 c0                	test   %eax,%eax
80105a38:	78 1f                	js     80105a59 <sys_fstat+0x44>
80105a3a:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105a41:	00 
80105a42:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a45:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a50:	e8 3b fc ff ff       	call   80105690 <argptr>
80105a55:	85 c0                	test   %eax,%eax
80105a57:	79 07                	jns    80105a60 <sys_fstat+0x4b>
    return -1;
80105a59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a5e:	eb 12                	jmp    80105a72 <sys_fstat+0x5d>
  return filestat(f, st);
80105a60:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a66:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a6a:	89 04 24             	mov    %eax,(%esp)
80105a6d:	e8 32 b6 ff ff       	call   801010a4 <filestat>
}
80105a72:	c9                   	leave  
80105a73:	c3                   	ret    

80105a74 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105a74:	55                   	push   %ebp
80105a75:	89 e5                	mov    %esp,%ebp
80105a77:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105a7a:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a88:	e8 65 fc ff ff       	call   801056f2 <argstr>
80105a8d:	85 c0                	test   %eax,%eax
80105a8f:	78 17                	js     80105aa8 <sys_link+0x34>
80105a91:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a94:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a9f:	e8 4e fc ff ff       	call   801056f2 <argstr>
80105aa4:	85 c0                	test   %eax,%eax
80105aa6:	79 0a                	jns    80105ab2 <sys_link+0x3e>
    return -1;
80105aa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aad:	e9 42 01 00 00       	jmp    80105bf4 <sys_link+0x180>

  begin_op();
80105ab2:	e8 59 d9 ff ff       	call   80103410 <begin_op>
  if((ip = namei(old)) == 0){
80105ab7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105aba:	89 04 24             	mov    %eax,(%esp)
80105abd:	e8 44 c9 ff ff       	call   80102406 <namei>
80105ac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ac5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ac9:	75 0f                	jne    80105ada <sys_link+0x66>
    end_op();
80105acb:	e8 c4 d9 ff ff       	call   80103494 <end_op>
    return -1;
80105ad0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad5:	e9 1a 01 00 00       	jmp    80105bf4 <sys_link+0x180>
  }

  ilock(ip);
80105ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105add:	89 04 24             	mov    %eax,(%esp)
80105ae0:	e8 76 bd ff ff       	call   8010185b <ilock>
  if(ip->type == T_DIR){
80105ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105aec:	66 83 f8 01          	cmp    $0x1,%ax
80105af0:	75 1a                	jne    80105b0c <sys_link+0x98>
    iunlockput(ip);
80105af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af5:	89 04 24             	mov    %eax,(%esp)
80105af8:	e8 e2 bf ff ff       	call   80101adf <iunlockput>
    end_op();
80105afd:	e8 92 d9 ff ff       	call   80103494 <end_op>
    return -1;
80105b02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b07:	e9 e8 00 00 00       	jmp    80105bf4 <sys_link+0x180>
  }

  ip->nlink++;
80105b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b13:	8d 50 01             	lea    0x1(%eax),%edx
80105b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b19:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b20:	89 04 24             	mov    %eax,(%esp)
80105b23:	e8 77 bb ff ff       	call   8010169f <iupdate>
  iunlock(ip);
80105b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2b:	89 04 24             	mov    %eax,(%esp)
80105b2e:	e8 76 be ff ff       	call   801019a9 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105b33:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b36:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b39:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b3d:	89 04 24             	mov    %eax,(%esp)
80105b40:	e8 e3 c8 ff ff       	call   80102428 <nameiparent>
80105b45:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b4c:	75 02                	jne    80105b50 <sys_link+0xdc>
    goto bad;
80105b4e:	eb 68                	jmp    80105bb8 <sys_link+0x144>
  ilock(dp);
80105b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b53:	89 04 24             	mov    %eax,(%esp)
80105b56:	e8 00 bd ff ff       	call   8010185b <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5e:	8b 10                	mov    (%eax),%edx
80105b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b63:	8b 00                	mov    (%eax),%eax
80105b65:	39 c2                	cmp    %eax,%edx
80105b67:	75 20                	jne    80105b89 <sys_link+0x115>
80105b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6c:	8b 40 04             	mov    0x4(%eax),%eax
80105b6f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b73:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105b76:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7d:	89 04 24             	mov    %eax,(%esp)
80105b80:	e8 c1 c5 ff ff       	call   80102146 <dirlink>
80105b85:	85 c0                	test   %eax,%eax
80105b87:	79 0d                	jns    80105b96 <sys_link+0x122>
    iunlockput(dp);
80105b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8c:	89 04 24             	mov    %eax,(%esp)
80105b8f:	e8 4b bf ff ff       	call   80101adf <iunlockput>
    goto bad;
80105b94:	eb 22                	jmp    80105bb8 <sys_link+0x144>
  }
  iunlockput(dp);
80105b96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b99:	89 04 24             	mov    %eax,(%esp)
80105b9c:	e8 3e bf ff ff       	call   80101adf <iunlockput>
  iput(ip);
80105ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba4:	89 04 24             	mov    %eax,(%esp)
80105ba7:	e8 62 be ff ff       	call   80101a0e <iput>

  end_op();
80105bac:	e8 e3 d8 ff ff       	call   80103494 <end_op>

  return 0;
80105bb1:	b8 00 00 00 00       	mov    $0x0,%eax
80105bb6:	eb 3c                	jmp    80105bf4 <sys_link+0x180>

bad:
  ilock(ip);
80105bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbb:	89 04 24             	mov    %eax,(%esp)
80105bbe:	e8 98 bc ff ff       	call   8010185b <ilock>
  ip->nlink--;
80105bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bca:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd0:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd7:	89 04 24             	mov    %eax,(%esp)
80105bda:	e8 c0 ba ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
80105bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be2:	89 04 24             	mov    %eax,(%esp)
80105be5:	e8 f5 be ff ff       	call   80101adf <iunlockput>
  end_op();
80105bea:	e8 a5 d8 ff ff       	call   80103494 <end_op>
  return -1;
80105bef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bf4:	c9                   	leave  
80105bf5:	c3                   	ret    

80105bf6 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105bf6:	55                   	push   %ebp
80105bf7:	89 e5                	mov    %esp,%ebp
80105bf9:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bfc:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c03:	eb 4b                	jmp    80105c50 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c08:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105c0f:	00 
80105c10:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c14:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c17:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1e:	89 04 24             	mov    %eax,(%esp)
80105c21:	e8 42 c1 ff ff       	call   80101d68 <readi>
80105c26:	83 f8 10             	cmp    $0x10,%eax
80105c29:	74 0c                	je     80105c37 <isdirempty+0x41>
      panic("isdirempty: readi");
80105c2b:	c7 04 24 e7 8e 10 80 	movl   $0x80108ee7,(%esp)
80105c32:	e8 03 a9 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105c37:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c3b:	66 85 c0             	test   %ax,%ax
80105c3e:	74 07                	je     80105c47 <isdirempty+0x51>
      return 0;
80105c40:	b8 00 00 00 00       	mov    $0x0,%eax
80105c45:	eb 1b                	jmp    80105c62 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4a:	83 c0 10             	add    $0x10,%eax
80105c4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c50:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c53:	8b 45 08             	mov    0x8(%ebp),%eax
80105c56:	8b 40 18             	mov    0x18(%eax),%eax
80105c59:	39 c2                	cmp    %eax,%edx
80105c5b:	72 a8                	jb     80105c05 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105c5d:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c62:	c9                   	leave  
80105c63:	c3                   	ret    

80105c64 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105c64:	55                   	push   %ebp
80105c65:	89 e5                	mov    %esp,%ebp
80105c67:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105c6a:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c78:	e8 75 fa ff ff       	call   801056f2 <argstr>
80105c7d:	85 c0                	test   %eax,%eax
80105c7f:	79 0a                	jns    80105c8b <sys_unlink+0x27>
    return -1;
80105c81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c86:	e9 af 01 00 00       	jmp    80105e3a <sys_unlink+0x1d6>

  begin_op();
80105c8b:	e8 80 d7 ff ff       	call   80103410 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c90:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c93:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c96:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c9a:	89 04 24             	mov    %eax,(%esp)
80105c9d:	e8 86 c7 ff ff       	call   80102428 <nameiparent>
80105ca2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ca5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ca9:	75 0f                	jne    80105cba <sys_unlink+0x56>
    end_op();
80105cab:	e8 e4 d7 ff ff       	call   80103494 <end_op>
    return -1;
80105cb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb5:	e9 80 01 00 00       	jmp    80105e3a <sys_unlink+0x1d6>
  }

  ilock(dp);
80105cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cbd:	89 04 24             	mov    %eax,(%esp)
80105cc0:	e8 96 bb ff ff       	call   8010185b <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105cc5:	c7 44 24 04 f9 8e 10 	movl   $0x80108ef9,0x4(%esp)
80105ccc:	80 
80105ccd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cd0:	89 04 24             	mov    %eax,(%esp)
80105cd3:	e8 83 c3 ff ff       	call   8010205b <namecmp>
80105cd8:	85 c0                	test   %eax,%eax
80105cda:	0f 84 45 01 00 00    	je     80105e25 <sys_unlink+0x1c1>
80105ce0:	c7 44 24 04 fb 8e 10 	movl   $0x80108efb,0x4(%esp)
80105ce7:	80 
80105ce8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ceb:	89 04 24             	mov    %eax,(%esp)
80105cee:	e8 68 c3 ff ff       	call   8010205b <namecmp>
80105cf3:	85 c0                	test   %eax,%eax
80105cf5:	0f 84 2a 01 00 00    	je     80105e25 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105cfb:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105cfe:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d02:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d05:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0c:	89 04 24             	mov    %eax,(%esp)
80105d0f:	e8 69 c3 ff ff       	call   8010207d <dirlookup>
80105d14:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d1b:	75 05                	jne    80105d22 <sys_unlink+0xbe>
    goto bad;
80105d1d:	e9 03 01 00 00       	jmp    80105e25 <sys_unlink+0x1c1>
  ilock(ip);
80105d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d25:	89 04 24             	mov    %eax,(%esp)
80105d28:	e8 2e bb ff ff       	call   8010185b <ilock>

  if(ip->nlink < 1)
80105d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d30:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d34:	66 85 c0             	test   %ax,%ax
80105d37:	7f 0c                	jg     80105d45 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105d39:	c7 04 24 fe 8e 10 80 	movl   $0x80108efe,(%esp)
80105d40:	e8 f5 a7 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d48:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d4c:	66 83 f8 01          	cmp    $0x1,%ax
80105d50:	75 1f                	jne    80105d71 <sys_unlink+0x10d>
80105d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d55:	89 04 24             	mov    %eax,(%esp)
80105d58:	e8 99 fe ff ff       	call   80105bf6 <isdirempty>
80105d5d:	85 c0                	test   %eax,%eax
80105d5f:	75 10                	jne    80105d71 <sys_unlink+0x10d>
    iunlockput(ip);
80105d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d64:	89 04 24             	mov    %eax,(%esp)
80105d67:	e8 73 bd ff ff       	call   80101adf <iunlockput>
    goto bad;
80105d6c:	e9 b4 00 00 00       	jmp    80105e25 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105d71:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105d78:	00 
80105d79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d80:	00 
80105d81:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d84:	89 04 24             	mov    %eax,(%esp)
80105d87:	e8 94 f5 ff ff       	call   80105320 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d8c:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d8f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d96:	00 
80105d97:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d9b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da5:	89 04 24             	mov    %eax,(%esp)
80105da8:	e8 1f c1 ff ff       	call   80101ecc <writei>
80105dad:	83 f8 10             	cmp    $0x10,%eax
80105db0:	74 0c                	je     80105dbe <sys_unlink+0x15a>
    panic("unlink: writei");
80105db2:	c7 04 24 10 8f 10 80 	movl   $0x80108f10,(%esp)
80105db9:	e8 7c a7 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105dc5:	66 83 f8 01          	cmp    $0x1,%ax
80105dc9:	75 1c                	jne    80105de7 <sys_unlink+0x183>
    dp->nlink--;
80105dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dce:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105dd2:	8d 50 ff             	lea    -0x1(%eax),%edx
80105dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddf:	89 04 24             	mov    %eax,(%esp)
80105de2:	e8 b8 b8 ff ff       	call   8010169f <iupdate>
  }
  iunlockput(dp);
80105de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dea:	89 04 24             	mov    %eax,(%esp)
80105ded:	e8 ed bc ff ff       	call   80101adf <iunlockput>

  ip->nlink--;
80105df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105df9:	8d 50 ff             	lea    -0x1(%eax),%edx
80105dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dff:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e06:	89 04 24             	mov    %eax,(%esp)
80105e09:	e8 91 b8 ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
80105e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e11:	89 04 24             	mov    %eax,(%esp)
80105e14:	e8 c6 bc ff ff       	call   80101adf <iunlockput>

  end_op();
80105e19:	e8 76 d6 ff ff       	call   80103494 <end_op>

  return 0;
80105e1e:	b8 00 00 00 00       	mov    $0x0,%eax
80105e23:	eb 15                	jmp    80105e3a <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e28:	89 04 24             	mov    %eax,(%esp)
80105e2b:	e8 af bc ff ff       	call   80101adf <iunlockput>
  end_op();
80105e30:	e8 5f d6 ff ff       	call   80103494 <end_op>
  return -1;
80105e35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e3a:	c9                   	leave  
80105e3b:	c3                   	ret    

80105e3c <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e3c:	55                   	push   %ebp
80105e3d:	89 e5                	mov    %esp,%ebp
80105e3f:	83 ec 48             	sub    $0x48,%esp
80105e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e45:	8b 55 10             	mov    0x10(%ebp),%edx
80105e48:	8b 45 14             	mov    0x14(%ebp),%eax
80105e4b:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e4f:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e53:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e57:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80105e61:	89 04 24             	mov    %eax,(%esp)
80105e64:	e8 bf c5 ff ff       	call   80102428 <nameiparent>
80105e69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e70:	75 0a                	jne    80105e7c <create+0x40>
    return 0;
80105e72:	b8 00 00 00 00       	mov    $0x0,%eax
80105e77:	e9 7e 01 00 00       	jmp    80105ffa <create+0x1be>
  ilock(dp);
80105e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7f:	89 04 24             	mov    %eax,(%esp)
80105e82:	e8 d4 b9 ff ff       	call   8010185b <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e87:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e8a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e8e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e91:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e98:	89 04 24             	mov    %eax,(%esp)
80105e9b:	e8 dd c1 ff ff       	call   8010207d <dirlookup>
80105ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ea3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ea7:	74 47                	je     80105ef0 <create+0xb4>
    iunlockput(dp);
80105ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eac:	89 04 24             	mov    %eax,(%esp)
80105eaf:	e8 2b bc ff ff       	call   80101adf <iunlockput>
    ilock(ip);
80105eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb7:	89 04 24             	mov    %eax,(%esp)
80105eba:	e8 9c b9 ff ff       	call   8010185b <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105ebf:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105ec4:	75 15                	jne    80105edb <create+0x9f>
80105ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ecd:	66 83 f8 02          	cmp    $0x2,%ax
80105ed1:	75 08                	jne    80105edb <create+0x9f>
      return ip;
80105ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed6:	e9 1f 01 00 00       	jmp    80105ffa <create+0x1be>
    iunlockput(ip);
80105edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ede:	89 04 24             	mov    %eax,(%esp)
80105ee1:	e8 f9 bb ff ff       	call   80101adf <iunlockput>
    return 0;
80105ee6:	b8 00 00 00 00       	mov    $0x0,%eax
80105eeb:	e9 0a 01 00 00       	jmp    80105ffa <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105ef0:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef7:	8b 00                	mov    (%eax),%eax
80105ef9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105efd:	89 04 24             	mov    %eax,(%esp)
80105f00:	e8 bb b6 ff ff       	call   801015c0 <ialloc>
80105f05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f0c:	75 0c                	jne    80105f1a <create+0xde>
    panic("create: ialloc");
80105f0e:	c7 04 24 1f 8f 10 80 	movl   $0x80108f1f,(%esp)
80105f15:	e8 20 a6 ff ff       	call   8010053a <panic>

  ilock(ip);
80105f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1d:	89 04 24             	mov    %eax,(%esp)
80105f20:	e8 36 b9 ff ff       	call   8010185b <ilock>
  ip->major = major;
80105f25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f28:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f2c:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f33:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f37:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f3e:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105f44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f47:	89 04 24             	mov    %eax,(%esp)
80105f4a:	e8 50 b7 ff ff       	call   8010169f <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105f4f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f54:	75 6a                	jne    80105fc0 <create+0x184>
    dp->nlink++;  // for ".."
80105f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f59:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f5d:	8d 50 01             	lea    0x1(%eax),%edx
80105f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f63:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f6a:	89 04 24             	mov    %eax,(%esp)
80105f6d:	e8 2d b7 ff ff       	call   8010169f <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f75:	8b 40 04             	mov    0x4(%eax),%eax
80105f78:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f7c:	c7 44 24 04 f9 8e 10 	movl   $0x80108ef9,0x4(%esp)
80105f83:	80 
80105f84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f87:	89 04 24             	mov    %eax,(%esp)
80105f8a:	e8 b7 c1 ff ff       	call   80102146 <dirlink>
80105f8f:	85 c0                	test   %eax,%eax
80105f91:	78 21                	js     80105fb4 <create+0x178>
80105f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f96:	8b 40 04             	mov    0x4(%eax),%eax
80105f99:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f9d:	c7 44 24 04 fb 8e 10 	movl   $0x80108efb,0x4(%esp)
80105fa4:	80 
80105fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa8:	89 04 24             	mov    %eax,(%esp)
80105fab:	e8 96 c1 ff ff       	call   80102146 <dirlink>
80105fb0:	85 c0                	test   %eax,%eax
80105fb2:	79 0c                	jns    80105fc0 <create+0x184>
      panic("create dots");
80105fb4:	c7 04 24 2e 8f 10 80 	movl   $0x80108f2e,(%esp)
80105fbb:	e8 7a a5 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc3:	8b 40 04             	mov    0x4(%eax),%eax
80105fc6:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fca:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd4:	89 04 24             	mov    %eax,(%esp)
80105fd7:	e8 6a c1 ff ff       	call   80102146 <dirlink>
80105fdc:	85 c0                	test   %eax,%eax
80105fde:	79 0c                	jns    80105fec <create+0x1b0>
    panic("create: dirlink");
80105fe0:	c7 04 24 3a 8f 10 80 	movl   $0x80108f3a,(%esp)
80105fe7:	e8 4e a5 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80105fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fef:	89 04 24             	mov    %eax,(%esp)
80105ff2:	e8 e8 ba ff ff       	call   80101adf <iunlockput>

  return ip;
80105ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105ffa:	c9                   	leave  
80105ffb:	c3                   	ret    

80105ffc <sys_open>:

int
sys_open(void)
{
80105ffc:	55                   	push   %ebp
80105ffd:	89 e5                	mov    %esp,%ebp
80105fff:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106002:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106005:	89 44 24 04          	mov    %eax,0x4(%esp)
80106009:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106010:	e8 dd f6 ff ff       	call   801056f2 <argstr>
80106015:	85 c0                	test   %eax,%eax
80106017:	78 17                	js     80106030 <sys_open+0x34>
80106019:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010601c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106020:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106027:	e8 36 f6 ff ff       	call   80105662 <argint>
8010602c:	85 c0                	test   %eax,%eax
8010602e:	79 0a                	jns    8010603a <sys_open+0x3e>
    return -1;
80106030:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106035:	e9 5c 01 00 00       	jmp    80106196 <sys_open+0x19a>

  begin_op();
8010603a:	e8 d1 d3 ff ff       	call   80103410 <begin_op>

  if(omode & O_CREATE){
8010603f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106042:	25 00 02 00 00       	and    $0x200,%eax
80106047:	85 c0                	test   %eax,%eax
80106049:	74 3b                	je     80106086 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010604b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010604e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106055:	00 
80106056:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010605d:	00 
8010605e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106065:	00 
80106066:	89 04 24             	mov    %eax,(%esp)
80106069:	e8 ce fd ff ff       	call   80105e3c <create>
8010606e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106071:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106075:	75 6b                	jne    801060e2 <sys_open+0xe6>
      end_op();
80106077:	e8 18 d4 ff ff       	call   80103494 <end_op>
      return -1;
8010607c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106081:	e9 10 01 00 00       	jmp    80106196 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80106086:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106089:	89 04 24             	mov    %eax,(%esp)
8010608c:	e8 75 c3 ff ff       	call   80102406 <namei>
80106091:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106094:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106098:	75 0f                	jne    801060a9 <sys_open+0xad>
      end_op();
8010609a:	e8 f5 d3 ff ff       	call   80103494 <end_op>
      return -1;
8010609f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a4:	e9 ed 00 00 00       	jmp    80106196 <sys_open+0x19a>
    }
    ilock(ip);
801060a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ac:	89 04 24             	mov    %eax,(%esp)
801060af:	e8 a7 b7 ff ff       	call   8010185b <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801060b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060bb:	66 83 f8 01          	cmp    $0x1,%ax
801060bf:	75 21                	jne    801060e2 <sys_open+0xe6>
801060c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060c4:	85 c0                	test   %eax,%eax
801060c6:	74 1a                	je     801060e2 <sys_open+0xe6>
      iunlockput(ip);
801060c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060cb:	89 04 24             	mov    %eax,(%esp)
801060ce:	e8 0c ba ff ff       	call   80101adf <iunlockput>
      end_op();
801060d3:	e8 bc d3 ff ff       	call   80103494 <end_op>
      return -1;
801060d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060dd:	e9 b4 00 00 00       	jmp    80106196 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801060e2:	e8 3f ae ff ff       	call   80100f26 <filealloc>
801060e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060ee:	74 14                	je     80106104 <sys_open+0x108>
801060f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f3:	89 04 24             	mov    %eax,(%esp)
801060f6:	e8 31 f7 ff ff       	call   8010582c <fdalloc>
801060fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
801060fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106102:	79 28                	jns    8010612c <sys_open+0x130>
    if(f)
80106104:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106108:	74 0b                	je     80106115 <sys_open+0x119>
      fileclose(f);
8010610a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010610d:	89 04 24             	mov    %eax,(%esp)
80106110:	e8 b9 ae ff ff       	call   80100fce <fileclose>
    iunlockput(ip);
80106115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106118:	89 04 24             	mov    %eax,(%esp)
8010611b:	e8 bf b9 ff ff       	call   80101adf <iunlockput>
    end_op();
80106120:	e8 6f d3 ff ff       	call   80103494 <end_op>
    return -1;
80106125:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010612a:	eb 6a                	jmp    80106196 <sys_open+0x19a>
  }
  iunlock(ip);
8010612c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010612f:	89 04 24             	mov    %eax,(%esp)
80106132:	e8 72 b8 ff ff       	call   801019a9 <iunlock>
  end_op();
80106137:	e8 58 d3 ff ff       	call   80103494 <end_op>

  f->type = FD_INODE;
8010613c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010613f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106145:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106148:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010614b:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010614e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106151:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106158:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010615b:	83 e0 01             	and    $0x1,%eax
8010615e:	85 c0                	test   %eax,%eax
80106160:	0f 94 c0             	sete   %al
80106163:	89 c2                	mov    %eax,%edx
80106165:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106168:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010616b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010616e:	83 e0 01             	and    $0x1,%eax
80106171:	85 c0                	test   %eax,%eax
80106173:	75 0a                	jne    8010617f <sys_open+0x183>
80106175:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106178:	83 e0 02             	and    $0x2,%eax
8010617b:	85 c0                	test   %eax,%eax
8010617d:	74 07                	je     80106186 <sys_open+0x18a>
8010617f:	b8 01 00 00 00       	mov    $0x1,%eax
80106184:	eb 05                	jmp    8010618b <sys_open+0x18f>
80106186:	b8 00 00 00 00       	mov    $0x0,%eax
8010618b:	89 c2                	mov    %eax,%edx
8010618d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106190:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106193:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106196:	c9                   	leave  
80106197:	c3                   	ret    

80106198 <sys_mkdir>:

int
sys_mkdir(void)
{
80106198:	55                   	push   %ebp
80106199:	89 e5                	mov    %esp,%ebp
8010619b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010619e:	e8 6d d2 ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801061a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801061aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061b1:	e8 3c f5 ff ff       	call   801056f2 <argstr>
801061b6:	85 c0                	test   %eax,%eax
801061b8:	78 2c                	js     801061e6 <sys_mkdir+0x4e>
801061ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801061c4:	00 
801061c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801061cc:	00 
801061cd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801061d4:	00 
801061d5:	89 04 24             	mov    %eax,(%esp)
801061d8:	e8 5f fc ff ff       	call   80105e3c <create>
801061dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061e4:	75 0c                	jne    801061f2 <sys_mkdir+0x5a>
    end_op();
801061e6:	e8 a9 d2 ff ff       	call   80103494 <end_op>
    return -1;
801061eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f0:	eb 15                	jmp    80106207 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801061f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f5:	89 04 24             	mov    %eax,(%esp)
801061f8:	e8 e2 b8 ff ff       	call   80101adf <iunlockput>
  end_op();
801061fd:	e8 92 d2 ff ff       	call   80103494 <end_op>
  return 0;
80106202:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106207:	c9                   	leave  
80106208:	c3                   	ret    

80106209 <sys_mknod>:

int
sys_mknod(void)
{
80106209:	55                   	push   %ebp
8010620a:	89 e5                	mov    %esp,%ebp
8010620c:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010620f:	e8 fc d1 ff ff       	call   80103410 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106214:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106217:	89 44 24 04          	mov    %eax,0x4(%esp)
8010621b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106222:	e8 cb f4 ff ff       	call   801056f2 <argstr>
80106227:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010622a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010622e:	78 5e                	js     8010628e <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106230:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106233:	89 44 24 04          	mov    %eax,0x4(%esp)
80106237:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010623e:	e8 1f f4 ff ff       	call   80105662 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106243:	85 c0                	test   %eax,%eax
80106245:	78 47                	js     8010628e <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106247:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010624a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010624e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106255:	e8 08 f4 ff ff       	call   80105662 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010625a:	85 c0                	test   %eax,%eax
8010625c:	78 30                	js     8010628e <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010625e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106261:	0f bf c8             	movswl %ax,%ecx
80106264:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106267:	0f bf d0             	movswl %ax,%edx
8010626a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010626d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106271:	89 54 24 08          	mov    %edx,0x8(%esp)
80106275:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010627c:	00 
8010627d:	89 04 24             	mov    %eax,(%esp)
80106280:	e8 b7 fb ff ff       	call   80105e3c <create>
80106285:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106288:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010628c:	75 0c                	jne    8010629a <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010628e:	e8 01 d2 ff ff       	call   80103494 <end_op>
    return -1;
80106293:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106298:	eb 15                	jmp    801062af <sys_mknod+0xa6>
  }
  iunlockput(ip);
8010629a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629d:	89 04 24             	mov    %eax,(%esp)
801062a0:	e8 3a b8 ff ff       	call   80101adf <iunlockput>
  end_op();
801062a5:	e8 ea d1 ff ff       	call   80103494 <end_op>
  return 0;
801062aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062af:	c9                   	leave  
801062b0:	c3                   	ret    

801062b1 <sys_chdir>:

int
sys_chdir(void)
{
801062b1:	55                   	push   %ebp
801062b2:	89 e5                	mov    %esp,%ebp
801062b4:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801062b7:	e8 54 d1 ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801062bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062ca:	e8 23 f4 ff ff       	call   801056f2 <argstr>
801062cf:	85 c0                	test   %eax,%eax
801062d1:	78 14                	js     801062e7 <sys_chdir+0x36>
801062d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062d6:	89 04 24             	mov    %eax,(%esp)
801062d9:	e8 28 c1 ff ff       	call   80102406 <namei>
801062de:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062e5:	75 0c                	jne    801062f3 <sys_chdir+0x42>
    end_op();
801062e7:	e8 a8 d1 ff ff       	call   80103494 <end_op>
    return -1;
801062ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f1:	eb 61                	jmp    80106354 <sys_chdir+0xa3>
  }
  ilock(ip);
801062f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f6:	89 04 24             	mov    %eax,(%esp)
801062f9:	e8 5d b5 ff ff       	call   8010185b <ilock>
  if(ip->type != T_DIR){
801062fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106301:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106305:	66 83 f8 01          	cmp    $0x1,%ax
80106309:	74 17                	je     80106322 <sys_chdir+0x71>
    iunlockput(ip);
8010630b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630e:	89 04 24             	mov    %eax,(%esp)
80106311:	e8 c9 b7 ff ff       	call   80101adf <iunlockput>
    end_op();
80106316:	e8 79 d1 ff ff       	call   80103494 <end_op>
    return -1;
8010631b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106320:	eb 32                	jmp    80106354 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106325:	89 04 24             	mov    %eax,(%esp)
80106328:	e8 7c b6 ff ff       	call   801019a9 <iunlock>
  iput(proc->cwd);
8010632d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106333:	8b 40 60             	mov    0x60(%eax),%eax
80106336:	89 04 24             	mov    %eax,(%esp)
80106339:	e8 d0 b6 ff ff       	call   80101a0e <iput>
  end_op();
8010633e:	e8 51 d1 ff ff       	call   80103494 <end_op>
  proc->cwd = ip;
80106343:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106349:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010634c:	89 50 60             	mov    %edx,0x60(%eax)
  return 0;
8010634f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106354:	c9                   	leave  
80106355:	c3                   	ret    

80106356 <sys_exec>:

int
sys_exec(void)
{
80106356:	55                   	push   %ebp
80106357:	89 e5                	mov    %esp,%ebp
80106359:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010635f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106362:	89 44 24 04          	mov    %eax,0x4(%esp)
80106366:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010636d:	e8 80 f3 ff ff       	call   801056f2 <argstr>
80106372:	85 c0                	test   %eax,%eax
80106374:	78 1a                	js     80106390 <sys_exec+0x3a>
80106376:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010637c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106380:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106387:	e8 d6 f2 ff ff       	call   80105662 <argint>
8010638c:	85 c0                	test   %eax,%eax
8010638e:	79 0a                	jns    8010639a <sys_exec+0x44>
    return -1;
80106390:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106395:	e9 c8 00 00 00       	jmp    80106462 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
8010639a:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801063a1:	00 
801063a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801063a9:	00 
801063aa:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063b0:	89 04 24             	mov    %eax,(%esp)
801063b3:	e8 68 ef ff ff       	call   80105320 <memset>
  for(i=0;; i++){
801063b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c2:	83 f8 1f             	cmp    $0x1f,%eax
801063c5:	76 0a                	jbe    801063d1 <sys_exec+0x7b>
      return -1;
801063c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063cc:	e9 91 00 00 00       	jmp    80106462 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801063d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d4:	c1 e0 02             	shl    $0x2,%eax
801063d7:	89 c2                	mov    %eax,%edx
801063d9:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801063df:	01 c2                	add    %eax,%edx
801063e1:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801063e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801063eb:	89 14 24             	mov    %edx,(%esp)
801063ee:	e8 d3 f1 ff ff       	call   801055c6 <fetchint>
801063f3:	85 c0                	test   %eax,%eax
801063f5:	79 07                	jns    801063fe <sys_exec+0xa8>
      return -1;
801063f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063fc:	eb 64                	jmp    80106462 <sys_exec+0x10c>
    if(uarg == 0){
801063fe:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106404:	85 c0                	test   %eax,%eax
80106406:	75 26                	jne    8010642e <sys_exec+0xd8>
      argv[i] = 0;
80106408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640b:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106412:	00 00 00 00 
      break;
80106416:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641a:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106420:	89 54 24 04          	mov    %edx,0x4(%esp)
80106424:	89 04 24             	mov    %eax,(%esp)
80106427:	e8 c3 a6 ff ff       	call   80100aef <exec>
8010642c:	eb 34                	jmp    80106462 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010642e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106434:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106437:	c1 e2 02             	shl    $0x2,%edx
8010643a:	01 c2                	add    %eax,%edx
8010643c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106442:	89 54 24 04          	mov    %edx,0x4(%esp)
80106446:	89 04 24             	mov    %eax,(%esp)
80106449:	e8 b2 f1 ff ff       	call   80105600 <fetchstr>
8010644e:	85 c0                	test   %eax,%eax
80106450:	79 07                	jns    80106459 <sys_exec+0x103>
      return -1;
80106452:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106457:	eb 09                	jmp    80106462 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106459:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010645d:	e9 5d ff ff ff       	jmp    801063bf <sys_exec+0x69>
  return exec(path, argv);
}
80106462:	c9                   	leave  
80106463:	c3                   	ret    

80106464 <sys_pipe>:

int
sys_pipe(void)
{
80106464:	55                   	push   %ebp
80106465:	89 e5                	mov    %esp,%ebp
80106467:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010646a:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106471:	00 
80106472:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106475:	89 44 24 04          	mov    %eax,0x4(%esp)
80106479:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106480:	e8 0b f2 ff ff       	call   80105690 <argptr>
80106485:	85 c0                	test   %eax,%eax
80106487:	79 0a                	jns    80106493 <sys_pipe+0x2f>
    return -1;
80106489:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648e:	e9 9a 00 00 00       	jmp    8010652d <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106493:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106496:	89 44 24 04          	mov    %eax,0x4(%esp)
8010649a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010649d:	89 04 24             	mov    %eax,(%esp)
801064a0:	e8 8e da ff ff       	call   80103f33 <pipealloc>
801064a5:	85 c0                	test   %eax,%eax
801064a7:	79 07                	jns    801064b0 <sys_pipe+0x4c>
    return -1;
801064a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ae:	eb 7d                	jmp    8010652d <sys_pipe+0xc9>
  fd0 = -1;
801064b0:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801064b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064ba:	89 04 24             	mov    %eax,(%esp)
801064bd:	e8 6a f3 ff ff       	call   8010582c <fdalloc>
801064c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064c9:	78 14                	js     801064df <sys_pipe+0x7b>
801064cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ce:	89 04 24             	mov    %eax,(%esp)
801064d1:	e8 56 f3 ff ff       	call   8010582c <fdalloc>
801064d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064dd:	79 36                	jns    80106515 <sys_pipe+0xb1>
    if(fd0 >= 0)
801064df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064e3:	78 13                	js     801064f8 <sys_pipe+0x94>
      proc->ofile[fd0] = 0;
801064e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064ee:	83 c2 08             	add    $0x8,%edx
801064f1:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
    fileclose(rf);
801064f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064fb:	89 04 24             	mov    %eax,(%esp)
801064fe:	e8 cb aa ff ff       	call   80100fce <fileclose>
    fileclose(wf);
80106503:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106506:	89 04 24             	mov    %eax,(%esp)
80106509:	e8 c0 aa ff ff       	call   80100fce <fileclose>
    return -1;
8010650e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106513:	eb 18                	jmp    8010652d <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106515:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106518:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010651b:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010651d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106520:	8d 50 04             	lea    0x4(%eax),%edx
80106523:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106526:	89 02                	mov    %eax,(%edx)
  return 0;
80106528:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010652d:	c9                   	leave  
8010652e:	c3                   	ret    

8010652f <sys_fork>:
#include "proc.h"
#include "kthread.h"

int
sys_fork(void)
{
8010652f:	55                   	push   %ebp
80106530:	89 e5                	mov    %esp,%ebp
80106532:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106535:	e8 c4 e1 ff ff       	call   801046fe <fork>
}
8010653a:	c9                   	leave  
8010653b:	c3                   	ret    

8010653c <sys_exit>:

int
sys_exit(void)
{
8010653c:	55                   	push   %ebp
8010653d:	89 e5                	mov    %esp,%ebp
8010653f:	83 ec 08             	sub    $0x8,%esp
  exit();
80106542:	e8 bd e3 ff ff       	call   80104904 <exit>
  return 0;  // not reached
80106547:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010654c:	c9                   	leave  
8010654d:	c3                   	ret    

8010654e <sys_wait>:

int
sys_wait(void)
{
8010654e:	55                   	push   %ebp
8010654f:	89 e5                	mov    %esp,%ebp
80106551:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106554:	e8 09 e5 ff ff       	call   80104a62 <wait>
}
80106559:	c9                   	leave  
8010655a:	c3                   	ret    

8010655b <sys_kill>:

int
sys_kill(void)
{
8010655b:	55                   	push   %ebp
8010655c:	89 e5                	mov    %esp,%ebp
8010655e:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106561:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106564:	89 44 24 04          	mov    %eax,0x4(%esp)
80106568:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010656f:	e8 ee f0 ff ff       	call   80105662 <argint>
80106574:	85 c0                	test   %eax,%eax
80106576:	79 07                	jns    8010657f <sys_kill+0x24>
    return -1;
80106578:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010657d:	eb 0b                	jmp    8010658a <sys_kill+0x2f>
  return kill(pid);
8010657f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106582:	89 04 24             	mov    %eax,(%esp)
80106585:	e8 0e e9 ff ff       	call   80104e98 <kill>
}
8010658a:	c9                   	leave  
8010658b:	c3                   	ret    

8010658c <sys_getpid>:

int
sys_getpid(void)
{
8010658c:	55                   	push   %ebp
8010658d:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010658f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106595:	8b 40 10             	mov    0x10(%eax),%eax
}
80106598:	5d                   	pop    %ebp
80106599:	c3                   	ret    

8010659a <sys_sbrk>:

int
sys_sbrk(void)
{
8010659a:	55                   	push   %ebp
8010659b:	89 e5                	mov    %esp,%ebp
8010659d:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801065a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801065a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065ae:	e8 af f0 ff ff       	call   80105662 <argint>
801065b3:	85 c0                	test   %eax,%eax
801065b5:	79 07                	jns    801065be <sys_sbrk+0x24>
    return -1;
801065b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065bc:	eb 24                	jmp    801065e2 <sys_sbrk+0x48>
  addr = proc->sz;
801065be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065c4:	8b 00                	mov    (%eax),%eax
801065c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if( growproc(n) < 0)
801065c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065cc:	89 04 24             	mov    %eax,(%esp)
801065cf:	e8 41 e0 ff ff       	call   80104615 <growproc>
801065d4:	85 c0                	test   %eax,%eax
801065d6:	79 07                	jns    801065df <sys_sbrk+0x45>
    return -1;
801065d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065dd:	eb 03                	jmp    801065e2 <sys_sbrk+0x48>
  return addr;
801065df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065e2:	c9                   	leave  
801065e3:	c3                   	ret    

801065e4 <sys_sleep>:

int
sys_sleep(void)
{
801065e4:	55                   	push   %ebp
801065e5:	89 e5                	mov    %esp,%ebp
801065e7:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801065ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801065f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065f8:	e8 65 f0 ff ff       	call   80105662 <argint>
801065fd:	85 c0                	test   %eax,%eax
801065ff:	79 07                	jns    80106608 <sys_sleep+0x24>
    return -1;
80106601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106606:	eb 6c                	jmp    80106674 <sys_sleep+0x90>
  acquire(&tickslock);
80106608:	c7 04 24 e0 e7 11 80 	movl   $0x8011e7e0,(%esp)
8010660f:	e8 b8 ea ff ff       	call   801050cc <acquire>
  ticks0 = ticks;
80106614:	a1 20 f0 11 80       	mov    0x8011f020,%eax
80106619:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010661c:	eb 34                	jmp    80106652 <sys_sleep+0x6e>
    if(proc->killed){
8010661e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106624:	8b 40 1c             	mov    0x1c(%eax),%eax
80106627:	85 c0                	test   %eax,%eax
80106629:	74 13                	je     8010663e <sys_sleep+0x5a>
      release(&tickslock);
8010662b:	c7 04 24 e0 e7 11 80 	movl   $0x8011e7e0,(%esp)
80106632:	e8 f7 ea ff ff       	call   8010512e <release>
      return -1;
80106637:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663c:	eb 36                	jmp    80106674 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010663e:	c7 44 24 04 e0 e7 11 	movl   $0x8011e7e0,0x4(%esp)
80106645:	80 
80106646:	c7 04 24 20 f0 11 80 	movl   $0x8011f020,(%esp)
8010664d:	e8 12 e7 ff ff       	call   80104d64 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106652:	a1 20 f0 11 80       	mov    0x8011f020,%eax
80106657:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010665a:	89 c2                	mov    %eax,%edx
8010665c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010665f:	39 c2                	cmp    %eax,%edx
80106661:	72 bb                	jb     8010661e <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106663:	c7 04 24 e0 e7 11 80 	movl   $0x8011e7e0,(%esp)
8010666a:	e8 bf ea ff ff       	call   8010512e <release>
  return 0;
8010666f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106674:	c9                   	leave  
80106675:	c3                   	ret    

80106676 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106676:	55                   	push   %ebp
80106677:	89 e5                	mov    %esp,%ebp
80106679:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010667c:	c7 04 24 e0 e7 11 80 	movl   $0x8011e7e0,(%esp)
80106683:	e8 44 ea ff ff       	call   801050cc <acquire>
  xticks = ticks;
80106688:	a1 20 f0 11 80       	mov    0x8011f020,%eax
8010668d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106690:	c7 04 24 e0 e7 11 80 	movl   $0x8011e7e0,(%esp)
80106697:	e8 92 ea ff ff       	call   8010512e <release>
  return xticks;
8010669c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010669f:	c9                   	leave  
801066a0:	c3                   	ret    

801066a1 <sys_kthread_create>:


int sys_kthread_create(void){
801066a1:	55                   	push   %ebp
801066a2:	89 e5                	mov    %esp,%ebp
801066a4:	83 ec 28             	sub    $0x28,%esp

	int start_func;
	int stack;
	int stack_size;

	if ( argint(0,&start_func)<0  || argint(1,&stack)<0  ||argint(2,&stack_size)<0 )
801066a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801066ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066b5:	e8 a8 ef ff ff       	call   80105662 <argint>
801066ba:	85 c0                	test   %eax,%eax
801066bc:	78 2e                	js     801066ec <sys_kthread_create+0x4b>
801066be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801066c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066cc:	e8 91 ef ff ff       	call   80105662 <argint>
801066d1:	85 c0                	test   %eax,%eax
801066d3:	78 17                	js     801066ec <sys_kthread_create+0x4b>
801066d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801066dc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801066e3:	e8 7a ef ff ff       	call   80105662 <argint>
801066e8:	85 c0                	test   %eax,%eax
801066ea:	79 07                	jns    801066f3 <sys_kthread_create+0x52>
		return -1;
801066ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f1:	eb 1d                	jmp    80106710 <sys_kthread_create+0x6f>


	return kthread_create((void *) start_func, (void *) stack, (uint) stack_size);
801066f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066f6:	89 c1                	mov    %eax,%ecx
801066f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066fb:	89 c2                	mov    %eax,%edx
801066fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106700:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106704:	89 54 24 04          	mov    %edx,0x4(%esp)
80106708:	89 04 24             	mov    %eax,(%esp)
8010670b:	e8 b4 20 00 00       	call   801087c4 <kthread_create>

}
80106710:	c9                   	leave  
80106711:	c3                   	ret    

80106712 <sys_kthread_id>:
int sys_kthread_id(void){
80106712:	55                   	push   %ebp
80106713:	89 e5                	mov    %esp,%ebp
80106715:	83 ec 08             	sub    $0x8,%esp
	return kthread_id();
80106718:	e8 25 22 00 00       	call   80108942 <kthread_id>
}
8010671d:	c9                   	leave  
8010671e:	c3                   	ret    

8010671f <sys_kthread_exit>:

int  sys_kthread_exit(void){
8010671f:	55                   	push   %ebp
80106720:	89 e5                	mov    %esp,%ebp
80106722:	83 ec 08             	sub    $0x8,%esp
	kthread_exit();
80106725:	e8 26 22 00 00       	call   80108950 <kthread_exit>
	return 0;
8010672a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010672f:	c9                   	leave  
80106730:	c3                   	ret    

80106731 <sys_kthread_join>:

int sys_kthread_join(void){
80106731:	55                   	push   %ebp
80106732:	89 e5                	mov    %esp,%ebp
80106734:	83 ec 28             	sub    $0x28,%esp

	int thread_id;

	if (argint(0, &thread_id)<0)
80106737:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010673a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010673e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106745:	e8 18 ef ff ff       	call   80105662 <argint>
8010674a:	85 c0                	test   %eax,%eax
8010674c:	79 07                	jns    80106755 <sys_kthread_join+0x24>
		return -1;
8010674e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106753:	eb 0b                	jmp    80106760 <sys_kthread_join+0x2f>

	return kthread_join(thread_id);
80106755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106758:	89 04 24             	mov    %eax,(%esp)
8010675b:	e8 9f 22 00 00       	call   801089ff <kthread_join>

}
80106760:	c9                   	leave  
80106761:	c3                   	ret    

80106762 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106762:	55                   	push   %ebp
80106763:	89 e5                	mov    %esp,%ebp
80106765:	83 ec 08             	sub    $0x8,%esp
80106768:	8b 55 08             	mov    0x8(%ebp),%edx
8010676b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010676e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106772:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106775:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106779:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010677d:	ee                   	out    %al,(%dx)
}
8010677e:	c9                   	leave  
8010677f:	c3                   	ret    

80106780 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106780:	55                   	push   %ebp
80106781:	89 e5                	mov    %esp,%ebp
80106783:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106786:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010678d:	00 
8010678e:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106795:	e8 c8 ff ff ff       	call   80106762 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010679a:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801067a1:	00 
801067a2:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801067a9:	e8 b4 ff ff ff       	call   80106762 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801067ae:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801067b5:	00 
801067b6:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801067bd:	e8 a0 ff ff ff       	call   80106762 <outb>
  picenable(IRQ_TIMER);
801067c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067c9:	e8 f8 d5 ff ff       	call   80103dc6 <picenable>
}
801067ce:	c9                   	leave  
801067cf:	c3                   	ret    

801067d0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801067d0:	1e                   	push   %ds
  pushl %es
801067d1:	06                   	push   %es
  pushl %fs
801067d2:	0f a0                	push   %fs
  pushl %gs
801067d4:	0f a8                	push   %gs
  pushal
801067d6:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801067d7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801067db:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801067dd:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801067df:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801067e3:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801067e5:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801067e7:	54                   	push   %esp
  call trap
801067e8:	e8 d8 01 00 00       	call   801069c5 <trap>
  addl $4, %esp
801067ed:	83 c4 04             	add    $0x4,%esp

801067f0 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801067f0:	61                   	popa   
  popl %gs
801067f1:	0f a9                	pop    %gs
  popl %fs
801067f3:	0f a1                	pop    %fs
  popl %es
801067f5:	07                   	pop    %es
  popl %ds
801067f6:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801067f7:	83 c4 08             	add    $0x8,%esp
  iret
801067fa:	cf                   	iret   

801067fb <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801067fb:	55                   	push   %ebp
801067fc:	89 e5                	mov    %esp,%ebp
801067fe:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106801:	8b 45 0c             	mov    0xc(%ebp),%eax
80106804:	83 e8 01             	sub    $0x1,%eax
80106807:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010680b:	8b 45 08             	mov    0x8(%ebp),%eax
8010680e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106812:	8b 45 08             	mov    0x8(%ebp),%eax
80106815:	c1 e8 10             	shr    $0x10,%eax
80106818:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010681c:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010681f:	0f 01 18             	lidtl  (%eax)
}
80106822:	c9                   	leave  
80106823:	c3                   	ret    

80106824 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106824:	55                   	push   %ebp
80106825:	89 e5                	mov    %esp,%ebp
80106827:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010682a:	0f 20 d0             	mov    %cr2,%eax
8010682d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106830:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106833:	c9                   	leave  
80106834:	c3                   	ret    

80106835 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106835:	55                   	push   %ebp
80106836:	89 e5                	mov    %esp,%ebp
80106838:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010683b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106842:	e9 c3 00 00 00       	jmp    8010690a <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684a:	8b 04 85 a8 c0 10 80 	mov    -0x7fef3f58(,%eax,4),%eax
80106851:	89 c2                	mov    %eax,%edx
80106853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106856:	66 89 14 c5 20 e8 11 	mov    %dx,-0x7fee17e0(,%eax,8)
8010685d:	80 
8010685e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106861:	66 c7 04 c5 22 e8 11 	movw   $0x8,-0x7fee17de(,%eax,8)
80106868:	80 08 00 
8010686b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010686e:	0f b6 14 c5 24 e8 11 	movzbl -0x7fee17dc(,%eax,8),%edx
80106875:	80 
80106876:	83 e2 e0             	and    $0xffffffe0,%edx
80106879:	88 14 c5 24 e8 11 80 	mov    %dl,-0x7fee17dc(,%eax,8)
80106880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106883:	0f b6 14 c5 24 e8 11 	movzbl -0x7fee17dc(,%eax,8),%edx
8010688a:	80 
8010688b:	83 e2 1f             	and    $0x1f,%edx
8010688e:	88 14 c5 24 e8 11 80 	mov    %dl,-0x7fee17dc(,%eax,8)
80106895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106898:	0f b6 14 c5 25 e8 11 	movzbl -0x7fee17db(,%eax,8),%edx
8010689f:	80 
801068a0:	83 e2 f0             	and    $0xfffffff0,%edx
801068a3:	83 ca 0e             	or     $0xe,%edx
801068a6:	88 14 c5 25 e8 11 80 	mov    %dl,-0x7fee17db(,%eax,8)
801068ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068b0:	0f b6 14 c5 25 e8 11 	movzbl -0x7fee17db(,%eax,8),%edx
801068b7:	80 
801068b8:	83 e2 ef             	and    $0xffffffef,%edx
801068bb:	88 14 c5 25 e8 11 80 	mov    %dl,-0x7fee17db(,%eax,8)
801068c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068c5:	0f b6 14 c5 25 e8 11 	movzbl -0x7fee17db(,%eax,8),%edx
801068cc:	80 
801068cd:	83 e2 9f             	and    $0xffffff9f,%edx
801068d0:	88 14 c5 25 e8 11 80 	mov    %dl,-0x7fee17db(,%eax,8)
801068d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068da:	0f b6 14 c5 25 e8 11 	movzbl -0x7fee17db(,%eax,8),%edx
801068e1:	80 
801068e2:	83 ca 80             	or     $0xffffff80,%edx
801068e5:	88 14 c5 25 e8 11 80 	mov    %dl,-0x7fee17db(,%eax,8)
801068ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ef:	8b 04 85 a8 c0 10 80 	mov    -0x7fef3f58(,%eax,4),%eax
801068f6:	c1 e8 10             	shr    $0x10,%eax
801068f9:	89 c2                	mov    %eax,%edx
801068fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068fe:	66 89 14 c5 26 e8 11 	mov    %dx,-0x7fee17da(,%eax,8)
80106905:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106906:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010690a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106911:	0f 8e 30 ff ff ff    	jle    80106847 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106917:	a1 a8 c1 10 80       	mov    0x8010c1a8,%eax
8010691c:	66 a3 20 ea 11 80    	mov    %ax,0x8011ea20
80106922:	66 c7 05 22 ea 11 80 	movw   $0x8,0x8011ea22
80106929:	08 00 
8010692b:	0f b6 05 24 ea 11 80 	movzbl 0x8011ea24,%eax
80106932:	83 e0 e0             	and    $0xffffffe0,%eax
80106935:	a2 24 ea 11 80       	mov    %al,0x8011ea24
8010693a:	0f b6 05 24 ea 11 80 	movzbl 0x8011ea24,%eax
80106941:	83 e0 1f             	and    $0x1f,%eax
80106944:	a2 24 ea 11 80       	mov    %al,0x8011ea24
80106949:	0f b6 05 25 ea 11 80 	movzbl 0x8011ea25,%eax
80106950:	83 c8 0f             	or     $0xf,%eax
80106953:	a2 25 ea 11 80       	mov    %al,0x8011ea25
80106958:	0f b6 05 25 ea 11 80 	movzbl 0x8011ea25,%eax
8010695f:	83 e0 ef             	and    $0xffffffef,%eax
80106962:	a2 25 ea 11 80       	mov    %al,0x8011ea25
80106967:	0f b6 05 25 ea 11 80 	movzbl 0x8011ea25,%eax
8010696e:	83 c8 60             	or     $0x60,%eax
80106971:	a2 25 ea 11 80       	mov    %al,0x8011ea25
80106976:	0f b6 05 25 ea 11 80 	movzbl 0x8011ea25,%eax
8010697d:	83 c8 80             	or     $0xffffff80,%eax
80106980:	a2 25 ea 11 80       	mov    %al,0x8011ea25
80106985:	a1 a8 c1 10 80       	mov    0x8010c1a8,%eax
8010698a:	c1 e8 10             	shr    $0x10,%eax
8010698d:	66 a3 26 ea 11 80    	mov    %ax,0x8011ea26
  
  initlock(&tickslock, "time");
80106993:	c7 44 24 04 4c 8f 10 	movl   $0x80108f4c,0x4(%esp)
8010699a:	80 
8010699b:	c7 04 24 e0 e7 11 80 	movl   $0x8011e7e0,(%esp)
801069a2:	e8 04 e7 ff ff       	call   801050ab <initlock>
}
801069a7:	c9                   	leave  
801069a8:	c3                   	ret    

801069a9 <idtinit>:

void
idtinit(void)
{
801069a9:	55                   	push   %ebp
801069aa:	89 e5                	mov    %esp,%ebp
801069ac:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801069af:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801069b6:	00 
801069b7:	c7 04 24 20 e8 11 80 	movl   $0x8011e820,(%esp)
801069be:	e8 38 fe ff ff       	call   801067fb <lidt>
}
801069c3:	c9                   	leave  
801069c4:	c3                   	ret    

801069c5 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801069c5:	55                   	push   %ebp
801069c6:	89 e5                	mov    %esp,%ebp
801069c8:	57                   	push   %edi
801069c9:	56                   	push   %esi
801069ca:	53                   	push   %ebx
801069cb:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
801069ce:	8b 45 08             	mov    0x8(%ebp),%eax
801069d1:	8b 40 30             	mov    0x30(%eax),%eax
801069d4:	83 f8 40             	cmp    $0x40,%eax
801069d7:	75 3f                	jne    80106a18 <trap+0x53>
    if(proc->killed)
801069d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069df:	8b 40 1c             	mov    0x1c(%eax),%eax
801069e2:	85 c0                	test   %eax,%eax
801069e4:	74 05                	je     801069eb <trap+0x26>
      exit();
801069e6:	e8 19 df ff ff       	call   80104904 <exit>
    thread->tf = tf;
801069eb:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801069f1:	8b 55 08             	mov    0x8(%ebp),%edx
801069f4:	89 50 10             	mov    %edx,0x10(%eax)
    syscall();
801069f7:	e8 2d ed ff ff       	call   80105729 <syscall>
    if(proc->killed)
801069fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a02:	8b 40 1c             	mov    0x1c(%eax),%eax
80106a05:	85 c0                	test   %eax,%eax
80106a07:	74 0a                	je     80106a13 <trap+0x4e>
      exit();
80106a09:	e8 f6 de ff ff       	call   80104904 <exit>
    return;
80106a0e:	e9 2d 02 00 00       	jmp    80106c40 <trap+0x27b>
80106a13:	e9 28 02 00 00       	jmp    80106c40 <trap+0x27b>
  }

  switch(tf->trapno){
80106a18:	8b 45 08             	mov    0x8(%ebp),%eax
80106a1b:	8b 40 30             	mov    0x30(%eax),%eax
80106a1e:	83 e8 20             	sub    $0x20,%eax
80106a21:	83 f8 1f             	cmp    $0x1f,%eax
80106a24:	0f 87 bc 00 00 00    	ja     80106ae6 <trap+0x121>
80106a2a:	8b 04 85 f4 8f 10 80 	mov    -0x7fef700c(,%eax,4),%eax
80106a31:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106a33:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a39:	0f b6 00             	movzbl (%eax),%eax
80106a3c:	84 c0                	test   %al,%al
80106a3e:	75 31                	jne    80106a71 <trap+0xac>
      acquire(&tickslock);
80106a40:	c7 04 24 e0 e7 11 80 	movl   $0x8011e7e0,(%esp)
80106a47:	e8 80 e6 ff ff       	call   801050cc <acquire>
      ticks++;
80106a4c:	a1 20 f0 11 80       	mov    0x8011f020,%eax
80106a51:	83 c0 01             	add    $0x1,%eax
80106a54:	a3 20 f0 11 80       	mov    %eax,0x8011f020
      wakeup(&ticks);
80106a59:	c7 04 24 20 f0 11 80 	movl   $0x8011f020,(%esp)
80106a60:	e8 08 e4 ff ff       	call   80104e6d <wakeup>
      release(&tickslock);
80106a65:	c7 04 24 e0 e7 11 80 	movl   $0x8011e7e0,(%esp)
80106a6c:	e8 bd e6 ff ff       	call   8010512e <release>
    }
    lapiceoi();
80106a71:	e8 5a c4 ff ff       	call   80102ed0 <lapiceoi>
    break;
80106a76:	e9 41 01 00 00       	jmp    80106bbc <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a7b:	e8 5e bc ff ff       	call   801026de <ideintr>
    lapiceoi();
80106a80:	e8 4b c4 ff ff       	call   80102ed0 <lapiceoi>
    break;
80106a85:	e9 32 01 00 00       	jmp    80106bbc <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a8a:	e8 10 c2 ff ff       	call   80102c9f <kbdintr>
    lapiceoi();
80106a8f:	e8 3c c4 ff ff       	call   80102ed0 <lapiceoi>
    break;
80106a94:	e9 23 01 00 00       	jmp    80106bbc <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a99:	e8 97 03 00 00       	call   80106e35 <uartintr>
    lapiceoi();
80106a9e:	e8 2d c4 ff ff       	call   80102ed0 <lapiceoi>
    break;
80106aa3:	e9 14 01 00 00       	jmp    80106bbc <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80106aab:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106aae:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ab5:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106ab8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106abe:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ac1:	0f b6 c0             	movzbl %al,%eax
80106ac4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ac8:	89 54 24 08          	mov    %edx,0x8(%esp)
80106acc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ad0:	c7 04 24 54 8f 10 80 	movl   $0x80108f54,(%esp)
80106ad7:	e8 c4 98 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106adc:	e8 ef c3 ff ff       	call   80102ed0 <lapiceoi>
    break;
80106ae1:	e9 d6 00 00 00       	jmp    80106bbc <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106ae6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aec:	85 c0                	test   %eax,%eax
80106aee:	74 11                	je     80106b01 <trap+0x13c>
80106af0:	8b 45 08             	mov    0x8(%ebp),%eax
80106af3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106af7:	0f b7 c0             	movzwl %ax,%eax
80106afa:	83 e0 03             	and    $0x3,%eax
80106afd:	85 c0                	test   %eax,%eax
80106aff:	75 46                	jne    80106b47 <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b01:	e8 1e fd ff ff       	call   80106824 <rcr2>
80106b06:	8b 55 08             	mov    0x8(%ebp),%edx
80106b09:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106b0c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106b13:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b16:	0f b6 ca             	movzbl %dl,%ecx
80106b19:	8b 55 08             	mov    0x8(%ebp),%edx
80106b1c:	8b 52 30             	mov    0x30(%edx),%edx
80106b1f:	89 44 24 10          	mov    %eax,0x10(%esp)
80106b23:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106b27:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106b2b:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b2f:	c7 04 24 78 8f 10 80 	movl   $0x80108f78,(%esp)
80106b36:	e8 65 98 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106b3b:	c7 04 24 aa 8f 10 80 	movl   $0x80108faa,(%esp)
80106b42:	e8 f3 99 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b47:	e8 d8 fc ff ff       	call   80106824 <rcr2>
80106b4c:	89 c2                	mov    %eax,%edx
80106b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80106b51:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b54:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b5a:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b5d:	0f b6 f0             	movzbl %al,%esi
80106b60:	8b 45 08             	mov    0x8(%ebp),%eax
80106b63:	8b 58 34             	mov    0x34(%eax),%ebx
80106b66:	8b 45 08             	mov    0x8(%ebp),%eax
80106b69:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b72:	83 c0 64             	add    $0x64,%eax
80106b75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b7e:	8b 40 10             	mov    0x10(%eax),%eax
80106b81:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106b85:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106b89:	89 74 24 14          	mov    %esi,0x14(%esp)
80106b8d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106b91:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b95:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106b98:	89 74 24 08          	mov    %esi,0x8(%esp)
80106b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ba0:	c7 04 24 b0 8f 10 80 	movl   $0x80108fb0,(%esp)
80106ba7:	e8 f4 97 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106bac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bb2:	c7 40 1c 01 00 00 00 	movl   $0x1,0x1c(%eax)
80106bb9:	eb 01                	jmp    80106bbc <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106bbb:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106bbc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bc2:	85 c0                	test   %eax,%eax
80106bc4:	74 24                	je     80106bea <trap+0x225>
80106bc6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bcc:	8b 40 1c             	mov    0x1c(%eax),%eax
80106bcf:	85 c0                	test   %eax,%eax
80106bd1:	74 17                	je     80106bea <trap+0x225>
80106bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80106bd6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bda:	0f b7 c0             	movzwl %ax,%eax
80106bdd:	83 e0 03             	and    $0x3,%eax
80106be0:	83 f8 03             	cmp    $0x3,%eax
80106be3:	75 05                	jne    80106bea <trap+0x225>
    exit();
80106be5:	e8 1a dd ff ff       	call   80104904 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(thread && thread->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106bea:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80106bf0:	85 c0                	test   %eax,%eax
80106bf2:	74 1e                	je     80106c12 <trap+0x24d>
80106bf4:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80106bfa:	8b 40 04             	mov    0x4(%eax),%eax
80106bfd:	83 f8 04             	cmp    $0x4,%eax
80106c00:	75 10                	jne    80106c12 <trap+0x24d>
80106c02:	8b 45 08             	mov    0x8(%ebp),%eax
80106c05:	8b 40 30             	mov    0x30(%eax),%eax
80106c08:	83 f8 20             	cmp    $0x20,%eax
80106c0b:	75 05                	jne    80106c12 <trap+0x24d>
    yield();
80106c0d:	e8 f4 e0 ff ff       	call   80104d06 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106c12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c18:	85 c0                	test   %eax,%eax
80106c1a:	74 24                	je     80106c40 <trap+0x27b>
80106c1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c22:	8b 40 1c             	mov    0x1c(%eax),%eax
80106c25:	85 c0                	test   %eax,%eax
80106c27:	74 17                	je     80106c40 <trap+0x27b>
80106c29:	8b 45 08             	mov    0x8(%ebp),%eax
80106c2c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c30:	0f b7 c0             	movzwl %ax,%eax
80106c33:	83 e0 03             	and    $0x3,%eax
80106c36:	83 f8 03             	cmp    $0x3,%eax
80106c39:	75 05                	jne    80106c40 <trap+0x27b>
    exit();
80106c3b:	e8 c4 dc ff ff       	call   80104904 <exit>
}
80106c40:	83 c4 3c             	add    $0x3c,%esp
80106c43:	5b                   	pop    %ebx
80106c44:	5e                   	pop    %esi
80106c45:	5f                   	pop    %edi
80106c46:	5d                   	pop    %ebp
80106c47:	c3                   	ret    

80106c48 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106c48:	55                   	push   %ebp
80106c49:	89 e5                	mov    %esp,%ebp
80106c4b:	83 ec 14             	sub    $0x14,%esp
80106c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80106c51:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c55:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106c59:	89 c2                	mov    %eax,%edx
80106c5b:	ec                   	in     (%dx),%al
80106c5c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106c5f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106c63:	c9                   	leave  
80106c64:	c3                   	ret    

80106c65 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c65:	55                   	push   %ebp
80106c66:	89 e5                	mov    %esp,%ebp
80106c68:	83 ec 08             	sub    $0x8,%esp
80106c6b:	8b 55 08             	mov    0x8(%ebp),%edx
80106c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c71:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c75:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c78:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c7c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c80:	ee                   	out    %al,(%dx)
}
80106c81:	c9                   	leave  
80106c82:	c3                   	ret    

80106c83 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c83:	55                   	push   %ebp
80106c84:	89 e5                	mov    %esp,%ebp
80106c86:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c90:	00 
80106c91:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106c98:	e8 c8 ff ff ff       	call   80106c65 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c9d:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106ca4:	00 
80106ca5:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106cac:	e8 b4 ff ff ff       	call   80106c65 <outb>
  outb(COM1+0, 115200/9600);
80106cb1:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106cb8:	00 
80106cb9:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cc0:	e8 a0 ff ff ff       	call   80106c65 <outb>
  outb(COM1+1, 0);
80106cc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ccc:	00 
80106ccd:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106cd4:	e8 8c ff ff ff       	call   80106c65 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106cd9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106ce0:	00 
80106ce1:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106ce8:	e8 78 ff ff ff       	call   80106c65 <outb>
  outb(COM1+4, 0);
80106ced:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106cf4:	00 
80106cf5:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106cfc:	e8 64 ff ff ff       	call   80106c65 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106d01:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106d08:	00 
80106d09:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106d10:	e8 50 ff ff ff       	call   80106c65 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106d15:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d1c:	e8 27 ff ff ff       	call   80106c48 <inb>
80106d21:	3c ff                	cmp    $0xff,%al
80106d23:	75 02                	jne    80106d27 <uartinit+0xa4>
    return;
80106d25:	eb 6a                	jmp    80106d91 <uartinit+0x10e>
  uart = 1;
80106d27:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80106d2e:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106d31:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106d38:	e8 0b ff ff ff       	call   80106c48 <inb>
  inb(COM1+0);
80106d3d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d44:	e8 ff fe ff ff       	call   80106c48 <inb>
  picenable(IRQ_COM1);
80106d49:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d50:	e8 71 d0 ff ff       	call   80103dc6 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106d55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d5c:	00 
80106d5d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d64:	e8 f4 bb ff ff       	call   8010295d <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d69:	c7 45 f4 74 90 10 80 	movl   $0x80109074,-0xc(%ebp)
80106d70:	eb 15                	jmp    80106d87 <uartinit+0x104>
    uartputc(*p);
80106d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d75:	0f b6 00             	movzbl (%eax),%eax
80106d78:	0f be c0             	movsbl %al,%eax
80106d7b:	89 04 24             	mov    %eax,(%esp)
80106d7e:	e8 10 00 00 00       	call   80106d93 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d83:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d8a:	0f b6 00             	movzbl (%eax),%eax
80106d8d:	84 c0                	test   %al,%al
80106d8f:	75 e1                	jne    80106d72 <uartinit+0xef>
    uartputc(*p);
}
80106d91:	c9                   	leave  
80106d92:	c3                   	ret    

80106d93 <uartputc>:

void
uartputc(int c)
{
80106d93:	55                   	push   %ebp
80106d94:	89 e5                	mov    %esp,%ebp
80106d96:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106d99:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80106d9e:	85 c0                	test   %eax,%eax
80106da0:	75 02                	jne    80106da4 <uartputc+0x11>
    return;
80106da2:	eb 4b                	jmp    80106def <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106da4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106dab:	eb 10                	jmp    80106dbd <uartputc+0x2a>
    microdelay(10);
80106dad:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106db4:	e8 3c c1 ff ff       	call   80102ef5 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106db9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106dbd:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106dc1:	7f 16                	jg     80106dd9 <uartputc+0x46>
80106dc3:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106dca:	e8 79 fe ff ff       	call   80106c48 <inb>
80106dcf:	0f b6 c0             	movzbl %al,%eax
80106dd2:	83 e0 20             	and    $0x20,%eax
80106dd5:	85 c0                	test   %eax,%eax
80106dd7:	74 d4                	je     80106dad <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80106ddc:	0f b6 c0             	movzbl %al,%eax
80106ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106de3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106dea:	e8 76 fe ff ff       	call   80106c65 <outb>
}
80106def:	c9                   	leave  
80106df0:	c3                   	ret    

80106df1 <uartgetc>:

static int
uartgetc(void)
{
80106df1:	55                   	push   %ebp
80106df2:	89 e5                	mov    %esp,%ebp
80106df4:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106df7:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80106dfc:	85 c0                	test   %eax,%eax
80106dfe:	75 07                	jne    80106e07 <uartgetc+0x16>
    return -1;
80106e00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e05:	eb 2c                	jmp    80106e33 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106e07:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e0e:	e8 35 fe ff ff       	call   80106c48 <inb>
80106e13:	0f b6 c0             	movzbl %al,%eax
80106e16:	83 e0 01             	and    $0x1,%eax
80106e19:	85 c0                	test   %eax,%eax
80106e1b:	75 07                	jne    80106e24 <uartgetc+0x33>
    return -1;
80106e1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e22:	eb 0f                	jmp    80106e33 <uartgetc+0x42>
  return inb(COM1+0);
80106e24:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e2b:	e8 18 fe ff ff       	call   80106c48 <inb>
80106e30:	0f b6 c0             	movzbl %al,%eax
}
80106e33:	c9                   	leave  
80106e34:	c3                   	ret    

80106e35 <uartintr>:

void
uartintr(void)
{
80106e35:	55                   	push   %ebp
80106e36:	89 e5                	mov    %esp,%ebp
80106e38:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106e3b:	c7 04 24 f1 6d 10 80 	movl   $0x80106df1,(%esp)
80106e42:	e8 66 99 ff ff       	call   801007ad <consoleintr>
}
80106e47:	c9                   	leave  
80106e48:	c3                   	ret    

80106e49 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $0
80106e4b:	6a 00                	push   $0x0
  jmp alltraps
80106e4d:	e9 7e f9 ff ff       	jmp    801067d0 <alltraps>

80106e52 <vector1>:
.globl vector1
vector1:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $1
80106e54:	6a 01                	push   $0x1
  jmp alltraps
80106e56:	e9 75 f9 ff ff       	jmp    801067d0 <alltraps>

80106e5b <vector2>:
.globl vector2
vector2:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $2
80106e5d:	6a 02                	push   $0x2
  jmp alltraps
80106e5f:	e9 6c f9 ff ff       	jmp    801067d0 <alltraps>

80106e64 <vector3>:
.globl vector3
vector3:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $3
80106e66:	6a 03                	push   $0x3
  jmp alltraps
80106e68:	e9 63 f9 ff ff       	jmp    801067d0 <alltraps>

80106e6d <vector4>:
.globl vector4
vector4:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $4
80106e6f:	6a 04                	push   $0x4
  jmp alltraps
80106e71:	e9 5a f9 ff ff       	jmp    801067d0 <alltraps>

80106e76 <vector5>:
.globl vector5
vector5:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $5
80106e78:	6a 05                	push   $0x5
  jmp alltraps
80106e7a:	e9 51 f9 ff ff       	jmp    801067d0 <alltraps>

80106e7f <vector6>:
.globl vector6
vector6:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $6
80106e81:	6a 06                	push   $0x6
  jmp alltraps
80106e83:	e9 48 f9 ff ff       	jmp    801067d0 <alltraps>

80106e88 <vector7>:
.globl vector7
vector7:
  pushl $0
80106e88:	6a 00                	push   $0x0
  pushl $7
80106e8a:	6a 07                	push   $0x7
  jmp alltraps
80106e8c:	e9 3f f9 ff ff       	jmp    801067d0 <alltraps>

80106e91 <vector8>:
.globl vector8
vector8:
  pushl $8
80106e91:	6a 08                	push   $0x8
  jmp alltraps
80106e93:	e9 38 f9 ff ff       	jmp    801067d0 <alltraps>

80106e98 <vector9>:
.globl vector9
vector9:
  pushl $0
80106e98:	6a 00                	push   $0x0
  pushl $9
80106e9a:	6a 09                	push   $0x9
  jmp alltraps
80106e9c:	e9 2f f9 ff ff       	jmp    801067d0 <alltraps>

80106ea1 <vector10>:
.globl vector10
vector10:
  pushl $10
80106ea1:	6a 0a                	push   $0xa
  jmp alltraps
80106ea3:	e9 28 f9 ff ff       	jmp    801067d0 <alltraps>

80106ea8 <vector11>:
.globl vector11
vector11:
  pushl $11
80106ea8:	6a 0b                	push   $0xb
  jmp alltraps
80106eaa:	e9 21 f9 ff ff       	jmp    801067d0 <alltraps>

80106eaf <vector12>:
.globl vector12
vector12:
  pushl $12
80106eaf:	6a 0c                	push   $0xc
  jmp alltraps
80106eb1:	e9 1a f9 ff ff       	jmp    801067d0 <alltraps>

80106eb6 <vector13>:
.globl vector13
vector13:
  pushl $13
80106eb6:	6a 0d                	push   $0xd
  jmp alltraps
80106eb8:	e9 13 f9 ff ff       	jmp    801067d0 <alltraps>

80106ebd <vector14>:
.globl vector14
vector14:
  pushl $14
80106ebd:	6a 0e                	push   $0xe
  jmp alltraps
80106ebf:	e9 0c f9 ff ff       	jmp    801067d0 <alltraps>

80106ec4 <vector15>:
.globl vector15
vector15:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $15
80106ec6:	6a 0f                	push   $0xf
  jmp alltraps
80106ec8:	e9 03 f9 ff ff       	jmp    801067d0 <alltraps>

80106ecd <vector16>:
.globl vector16
vector16:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $16
80106ecf:	6a 10                	push   $0x10
  jmp alltraps
80106ed1:	e9 fa f8 ff ff       	jmp    801067d0 <alltraps>

80106ed6 <vector17>:
.globl vector17
vector17:
  pushl $17
80106ed6:	6a 11                	push   $0x11
  jmp alltraps
80106ed8:	e9 f3 f8 ff ff       	jmp    801067d0 <alltraps>

80106edd <vector18>:
.globl vector18
vector18:
  pushl $0
80106edd:	6a 00                	push   $0x0
  pushl $18
80106edf:	6a 12                	push   $0x12
  jmp alltraps
80106ee1:	e9 ea f8 ff ff       	jmp    801067d0 <alltraps>

80106ee6 <vector19>:
.globl vector19
vector19:
  pushl $0
80106ee6:	6a 00                	push   $0x0
  pushl $19
80106ee8:	6a 13                	push   $0x13
  jmp alltraps
80106eea:	e9 e1 f8 ff ff       	jmp    801067d0 <alltraps>

80106eef <vector20>:
.globl vector20
vector20:
  pushl $0
80106eef:	6a 00                	push   $0x0
  pushl $20
80106ef1:	6a 14                	push   $0x14
  jmp alltraps
80106ef3:	e9 d8 f8 ff ff       	jmp    801067d0 <alltraps>

80106ef8 <vector21>:
.globl vector21
vector21:
  pushl $0
80106ef8:	6a 00                	push   $0x0
  pushl $21
80106efa:	6a 15                	push   $0x15
  jmp alltraps
80106efc:	e9 cf f8 ff ff       	jmp    801067d0 <alltraps>

80106f01 <vector22>:
.globl vector22
vector22:
  pushl $0
80106f01:	6a 00                	push   $0x0
  pushl $22
80106f03:	6a 16                	push   $0x16
  jmp alltraps
80106f05:	e9 c6 f8 ff ff       	jmp    801067d0 <alltraps>

80106f0a <vector23>:
.globl vector23
vector23:
  pushl $0
80106f0a:	6a 00                	push   $0x0
  pushl $23
80106f0c:	6a 17                	push   $0x17
  jmp alltraps
80106f0e:	e9 bd f8 ff ff       	jmp    801067d0 <alltraps>

80106f13 <vector24>:
.globl vector24
vector24:
  pushl $0
80106f13:	6a 00                	push   $0x0
  pushl $24
80106f15:	6a 18                	push   $0x18
  jmp alltraps
80106f17:	e9 b4 f8 ff ff       	jmp    801067d0 <alltraps>

80106f1c <vector25>:
.globl vector25
vector25:
  pushl $0
80106f1c:	6a 00                	push   $0x0
  pushl $25
80106f1e:	6a 19                	push   $0x19
  jmp alltraps
80106f20:	e9 ab f8 ff ff       	jmp    801067d0 <alltraps>

80106f25 <vector26>:
.globl vector26
vector26:
  pushl $0
80106f25:	6a 00                	push   $0x0
  pushl $26
80106f27:	6a 1a                	push   $0x1a
  jmp alltraps
80106f29:	e9 a2 f8 ff ff       	jmp    801067d0 <alltraps>

80106f2e <vector27>:
.globl vector27
vector27:
  pushl $0
80106f2e:	6a 00                	push   $0x0
  pushl $27
80106f30:	6a 1b                	push   $0x1b
  jmp alltraps
80106f32:	e9 99 f8 ff ff       	jmp    801067d0 <alltraps>

80106f37 <vector28>:
.globl vector28
vector28:
  pushl $0
80106f37:	6a 00                	push   $0x0
  pushl $28
80106f39:	6a 1c                	push   $0x1c
  jmp alltraps
80106f3b:	e9 90 f8 ff ff       	jmp    801067d0 <alltraps>

80106f40 <vector29>:
.globl vector29
vector29:
  pushl $0
80106f40:	6a 00                	push   $0x0
  pushl $29
80106f42:	6a 1d                	push   $0x1d
  jmp alltraps
80106f44:	e9 87 f8 ff ff       	jmp    801067d0 <alltraps>

80106f49 <vector30>:
.globl vector30
vector30:
  pushl $0
80106f49:	6a 00                	push   $0x0
  pushl $30
80106f4b:	6a 1e                	push   $0x1e
  jmp alltraps
80106f4d:	e9 7e f8 ff ff       	jmp    801067d0 <alltraps>

80106f52 <vector31>:
.globl vector31
vector31:
  pushl $0
80106f52:	6a 00                	push   $0x0
  pushl $31
80106f54:	6a 1f                	push   $0x1f
  jmp alltraps
80106f56:	e9 75 f8 ff ff       	jmp    801067d0 <alltraps>

80106f5b <vector32>:
.globl vector32
vector32:
  pushl $0
80106f5b:	6a 00                	push   $0x0
  pushl $32
80106f5d:	6a 20                	push   $0x20
  jmp alltraps
80106f5f:	e9 6c f8 ff ff       	jmp    801067d0 <alltraps>

80106f64 <vector33>:
.globl vector33
vector33:
  pushl $0
80106f64:	6a 00                	push   $0x0
  pushl $33
80106f66:	6a 21                	push   $0x21
  jmp alltraps
80106f68:	e9 63 f8 ff ff       	jmp    801067d0 <alltraps>

80106f6d <vector34>:
.globl vector34
vector34:
  pushl $0
80106f6d:	6a 00                	push   $0x0
  pushl $34
80106f6f:	6a 22                	push   $0x22
  jmp alltraps
80106f71:	e9 5a f8 ff ff       	jmp    801067d0 <alltraps>

80106f76 <vector35>:
.globl vector35
vector35:
  pushl $0
80106f76:	6a 00                	push   $0x0
  pushl $35
80106f78:	6a 23                	push   $0x23
  jmp alltraps
80106f7a:	e9 51 f8 ff ff       	jmp    801067d0 <alltraps>

80106f7f <vector36>:
.globl vector36
vector36:
  pushl $0
80106f7f:	6a 00                	push   $0x0
  pushl $36
80106f81:	6a 24                	push   $0x24
  jmp alltraps
80106f83:	e9 48 f8 ff ff       	jmp    801067d0 <alltraps>

80106f88 <vector37>:
.globl vector37
vector37:
  pushl $0
80106f88:	6a 00                	push   $0x0
  pushl $37
80106f8a:	6a 25                	push   $0x25
  jmp alltraps
80106f8c:	e9 3f f8 ff ff       	jmp    801067d0 <alltraps>

80106f91 <vector38>:
.globl vector38
vector38:
  pushl $0
80106f91:	6a 00                	push   $0x0
  pushl $38
80106f93:	6a 26                	push   $0x26
  jmp alltraps
80106f95:	e9 36 f8 ff ff       	jmp    801067d0 <alltraps>

80106f9a <vector39>:
.globl vector39
vector39:
  pushl $0
80106f9a:	6a 00                	push   $0x0
  pushl $39
80106f9c:	6a 27                	push   $0x27
  jmp alltraps
80106f9e:	e9 2d f8 ff ff       	jmp    801067d0 <alltraps>

80106fa3 <vector40>:
.globl vector40
vector40:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $40
80106fa5:	6a 28                	push   $0x28
  jmp alltraps
80106fa7:	e9 24 f8 ff ff       	jmp    801067d0 <alltraps>

80106fac <vector41>:
.globl vector41
vector41:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $41
80106fae:	6a 29                	push   $0x29
  jmp alltraps
80106fb0:	e9 1b f8 ff ff       	jmp    801067d0 <alltraps>

80106fb5 <vector42>:
.globl vector42
vector42:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $42
80106fb7:	6a 2a                	push   $0x2a
  jmp alltraps
80106fb9:	e9 12 f8 ff ff       	jmp    801067d0 <alltraps>

80106fbe <vector43>:
.globl vector43
vector43:
  pushl $0
80106fbe:	6a 00                	push   $0x0
  pushl $43
80106fc0:	6a 2b                	push   $0x2b
  jmp alltraps
80106fc2:	e9 09 f8 ff ff       	jmp    801067d0 <alltraps>

80106fc7 <vector44>:
.globl vector44
vector44:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $44
80106fc9:	6a 2c                	push   $0x2c
  jmp alltraps
80106fcb:	e9 00 f8 ff ff       	jmp    801067d0 <alltraps>

80106fd0 <vector45>:
.globl vector45
vector45:
  pushl $0
80106fd0:	6a 00                	push   $0x0
  pushl $45
80106fd2:	6a 2d                	push   $0x2d
  jmp alltraps
80106fd4:	e9 f7 f7 ff ff       	jmp    801067d0 <alltraps>

80106fd9 <vector46>:
.globl vector46
vector46:
  pushl $0
80106fd9:	6a 00                	push   $0x0
  pushl $46
80106fdb:	6a 2e                	push   $0x2e
  jmp alltraps
80106fdd:	e9 ee f7 ff ff       	jmp    801067d0 <alltraps>

80106fe2 <vector47>:
.globl vector47
vector47:
  pushl $0
80106fe2:	6a 00                	push   $0x0
  pushl $47
80106fe4:	6a 2f                	push   $0x2f
  jmp alltraps
80106fe6:	e9 e5 f7 ff ff       	jmp    801067d0 <alltraps>

80106feb <vector48>:
.globl vector48
vector48:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $48
80106fed:	6a 30                	push   $0x30
  jmp alltraps
80106fef:	e9 dc f7 ff ff       	jmp    801067d0 <alltraps>

80106ff4 <vector49>:
.globl vector49
vector49:
  pushl $0
80106ff4:	6a 00                	push   $0x0
  pushl $49
80106ff6:	6a 31                	push   $0x31
  jmp alltraps
80106ff8:	e9 d3 f7 ff ff       	jmp    801067d0 <alltraps>

80106ffd <vector50>:
.globl vector50
vector50:
  pushl $0
80106ffd:	6a 00                	push   $0x0
  pushl $50
80106fff:	6a 32                	push   $0x32
  jmp alltraps
80107001:	e9 ca f7 ff ff       	jmp    801067d0 <alltraps>

80107006 <vector51>:
.globl vector51
vector51:
  pushl $0
80107006:	6a 00                	push   $0x0
  pushl $51
80107008:	6a 33                	push   $0x33
  jmp alltraps
8010700a:	e9 c1 f7 ff ff       	jmp    801067d0 <alltraps>

8010700f <vector52>:
.globl vector52
vector52:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $52
80107011:	6a 34                	push   $0x34
  jmp alltraps
80107013:	e9 b8 f7 ff ff       	jmp    801067d0 <alltraps>

80107018 <vector53>:
.globl vector53
vector53:
  pushl $0
80107018:	6a 00                	push   $0x0
  pushl $53
8010701a:	6a 35                	push   $0x35
  jmp alltraps
8010701c:	e9 af f7 ff ff       	jmp    801067d0 <alltraps>

80107021 <vector54>:
.globl vector54
vector54:
  pushl $0
80107021:	6a 00                	push   $0x0
  pushl $54
80107023:	6a 36                	push   $0x36
  jmp alltraps
80107025:	e9 a6 f7 ff ff       	jmp    801067d0 <alltraps>

8010702a <vector55>:
.globl vector55
vector55:
  pushl $0
8010702a:	6a 00                	push   $0x0
  pushl $55
8010702c:	6a 37                	push   $0x37
  jmp alltraps
8010702e:	e9 9d f7 ff ff       	jmp    801067d0 <alltraps>

80107033 <vector56>:
.globl vector56
vector56:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $56
80107035:	6a 38                	push   $0x38
  jmp alltraps
80107037:	e9 94 f7 ff ff       	jmp    801067d0 <alltraps>

8010703c <vector57>:
.globl vector57
vector57:
  pushl $0
8010703c:	6a 00                	push   $0x0
  pushl $57
8010703e:	6a 39                	push   $0x39
  jmp alltraps
80107040:	e9 8b f7 ff ff       	jmp    801067d0 <alltraps>

80107045 <vector58>:
.globl vector58
vector58:
  pushl $0
80107045:	6a 00                	push   $0x0
  pushl $58
80107047:	6a 3a                	push   $0x3a
  jmp alltraps
80107049:	e9 82 f7 ff ff       	jmp    801067d0 <alltraps>

8010704e <vector59>:
.globl vector59
vector59:
  pushl $0
8010704e:	6a 00                	push   $0x0
  pushl $59
80107050:	6a 3b                	push   $0x3b
  jmp alltraps
80107052:	e9 79 f7 ff ff       	jmp    801067d0 <alltraps>

80107057 <vector60>:
.globl vector60
vector60:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $60
80107059:	6a 3c                	push   $0x3c
  jmp alltraps
8010705b:	e9 70 f7 ff ff       	jmp    801067d0 <alltraps>

80107060 <vector61>:
.globl vector61
vector61:
  pushl $0
80107060:	6a 00                	push   $0x0
  pushl $61
80107062:	6a 3d                	push   $0x3d
  jmp alltraps
80107064:	e9 67 f7 ff ff       	jmp    801067d0 <alltraps>

80107069 <vector62>:
.globl vector62
vector62:
  pushl $0
80107069:	6a 00                	push   $0x0
  pushl $62
8010706b:	6a 3e                	push   $0x3e
  jmp alltraps
8010706d:	e9 5e f7 ff ff       	jmp    801067d0 <alltraps>

80107072 <vector63>:
.globl vector63
vector63:
  pushl $0
80107072:	6a 00                	push   $0x0
  pushl $63
80107074:	6a 3f                	push   $0x3f
  jmp alltraps
80107076:	e9 55 f7 ff ff       	jmp    801067d0 <alltraps>

8010707b <vector64>:
.globl vector64
vector64:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $64
8010707d:	6a 40                	push   $0x40
  jmp alltraps
8010707f:	e9 4c f7 ff ff       	jmp    801067d0 <alltraps>

80107084 <vector65>:
.globl vector65
vector65:
  pushl $0
80107084:	6a 00                	push   $0x0
  pushl $65
80107086:	6a 41                	push   $0x41
  jmp alltraps
80107088:	e9 43 f7 ff ff       	jmp    801067d0 <alltraps>

8010708d <vector66>:
.globl vector66
vector66:
  pushl $0
8010708d:	6a 00                	push   $0x0
  pushl $66
8010708f:	6a 42                	push   $0x42
  jmp alltraps
80107091:	e9 3a f7 ff ff       	jmp    801067d0 <alltraps>

80107096 <vector67>:
.globl vector67
vector67:
  pushl $0
80107096:	6a 00                	push   $0x0
  pushl $67
80107098:	6a 43                	push   $0x43
  jmp alltraps
8010709a:	e9 31 f7 ff ff       	jmp    801067d0 <alltraps>

8010709f <vector68>:
.globl vector68
vector68:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $68
801070a1:	6a 44                	push   $0x44
  jmp alltraps
801070a3:	e9 28 f7 ff ff       	jmp    801067d0 <alltraps>

801070a8 <vector69>:
.globl vector69
vector69:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $69
801070aa:	6a 45                	push   $0x45
  jmp alltraps
801070ac:	e9 1f f7 ff ff       	jmp    801067d0 <alltraps>

801070b1 <vector70>:
.globl vector70
vector70:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $70
801070b3:	6a 46                	push   $0x46
  jmp alltraps
801070b5:	e9 16 f7 ff ff       	jmp    801067d0 <alltraps>

801070ba <vector71>:
.globl vector71
vector71:
  pushl $0
801070ba:	6a 00                	push   $0x0
  pushl $71
801070bc:	6a 47                	push   $0x47
  jmp alltraps
801070be:	e9 0d f7 ff ff       	jmp    801067d0 <alltraps>

801070c3 <vector72>:
.globl vector72
vector72:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $72
801070c5:	6a 48                	push   $0x48
  jmp alltraps
801070c7:	e9 04 f7 ff ff       	jmp    801067d0 <alltraps>

801070cc <vector73>:
.globl vector73
vector73:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $73
801070ce:	6a 49                	push   $0x49
  jmp alltraps
801070d0:	e9 fb f6 ff ff       	jmp    801067d0 <alltraps>

801070d5 <vector74>:
.globl vector74
vector74:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $74
801070d7:	6a 4a                	push   $0x4a
  jmp alltraps
801070d9:	e9 f2 f6 ff ff       	jmp    801067d0 <alltraps>

801070de <vector75>:
.globl vector75
vector75:
  pushl $0
801070de:	6a 00                	push   $0x0
  pushl $75
801070e0:	6a 4b                	push   $0x4b
  jmp alltraps
801070e2:	e9 e9 f6 ff ff       	jmp    801067d0 <alltraps>

801070e7 <vector76>:
.globl vector76
vector76:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $76
801070e9:	6a 4c                	push   $0x4c
  jmp alltraps
801070eb:	e9 e0 f6 ff ff       	jmp    801067d0 <alltraps>

801070f0 <vector77>:
.globl vector77
vector77:
  pushl $0
801070f0:	6a 00                	push   $0x0
  pushl $77
801070f2:	6a 4d                	push   $0x4d
  jmp alltraps
801070f4:	e9 d7 f6 ff ff       	jmp    801067d0 <alltraps>

801070f9 <vector78>:
.globl vector78
vector78:
  pushl $0
801070f9:	6a 00                	push   $0x0
  pushl $78
801070fb:	6a 4e                	push   $0x4e
  jmp alltraps
801070fd:	e9 ce f6 ff ff       	jmp    801067d0 <alltraps>

80107102 <vector79>:
.globl vector79
vector79:
  pushl $0
80107102:	6a 00                	push   $0x0
  pushl $79
80107104:	6a 4f                	push   $0x4f
  jmp alltraps
80107106:	e9 c5 f6 ff ff       	jmp    801067d0 <alltraps>

8010710b <vector80>:
.globl vector80
vector80:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $80
8010710d:	6a 50                	push   $0x50
  jmp alltraps
8010710f:	e9 bc f6 ff ff       	jmp    801067d0 <alltraps>

80107114 <vector81>:
.globl vector81
vector81:
  pushl $0
80107114:	6a 00                	push   $0x0
  pushl $81
80107116:	6a 51                	push   $0x51
  jmp alltraps
80107118:	e9 b3 f6 ff ff       	jmp    801067d0 <alltraps>

8010711d <vector82>:
.globl vector82
vector82:
  pushl $0
8010711d:	6a 00                	push   $0x0
  pushl $82
8010711f:	6a 52                	push   $0x52
  jmp alltraps
80107121:	e9 aa f6 ff ff       	jmp    801067d0 <alltraps>

80107126 <vector83>:
.globl vector83
vector83:
  pushl $0
80107126:	6a 00                	push   $0x0
  pushl $83
80107128:	6a 53                	push   $0x53
  jmp alltraps
8010712a:	e9 a1 f6 ff ff       	jmp    801067d0 <alltraps>

8010712f <vector84>:
.globl vector84
vector84:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $84
80107131:	6a 54                	push   $0x54
  jmp alltraps
80107133:	e9 98 f6 ff ff       	jmp    801067d0 <alltraps>

80107138 <vector85>:
.globl vector85
vector85:
  pushl $0
80107138:	6a 00                	push   $0x0
  pushl $85
8010713a:	6a 55                	push   $0x55
  jmp alltraps
8010713c:	e9 8f f6 ff ff       	jmp    801067d0 <alltraps>

80107141 <vector86>:
.globl vector86
vector86:
  pushl $0
80107141:	6a 00                	push   $0x0
  pushl $86
80107143:	6a 56                	push   $0x56
  jmp alltraps
80107145:	e9 86 f6 ff ff       	jmp    801067d0 <alltraps>

8010714a <vector87>:
.globl vector87
vector87:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $87
8010714c:	6a 57                	push   $0x57
  jmp alltraps
8010714e:	e9 7d f6 ff ff       	jmp    801067d0 <alltraps>

80107153 <vector88>:
.globl vector88
vector88:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $88
80107155:	6a 58                	push   $0x58
  jmp alltraps
80107157:	e9 74 f6 ff ff       	jmp    801067d0 <alltraps>

8010715c <vector89>:
.globl vector89
vector89:
  pushl $0
8010715c:	6a 00                	push   $0x0
  pushl $89
8010715e:	6a 59                	push   $0x59
  jmp alltraps
80107160:	e9 6b f6 ff ff       	jmp    801067d0 <alltraps>

80107165 <vector90>:
.globl vector90
vector90:
  pushl $0
80107165:	6a 00                	push   $0x0
  pushl $90
80107167:	6a 5a                	push   $0x5a
  jmp alltraps
80107169:	e9 62 f6 ff ff       	jmp    801067d0 <alltraps>

8010716e <vector91>:
.globl vector91
vector91:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $91
80107170:	6a 5b                	push   $0x5b
  jmp alltraps
80107172:	e9 59 f6 ff ff       	jmp    801067d0 <alltraps>

80107177 <vector92>:
.globl vector92
vector92:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $92
80107179:	6a 5c                	push   $0x5c
  jmp alltraps
8010717b:	e9 50 f6 ff ff       	jmp    801067d0 <alltraps>

80107180 <vector93>:
.globl vector93
vector93:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $93
80107182:	6a 5d                	push   $0x5d
  jmp alltraps
80107184:	e9 47 f6 ff ff       	jmp    801067d0 <alltraps>

80107189 <vector94>:
.globl vector94
vector94:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $94
8010718b:	6a 5e                	push   $0x5e
  jmp alltraps
8010718d:	e9 3e f6 ff ff       	jmp    801067d0 <alltraps>

80107192 <vector95>:
.globl vector95
vector95:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $95
80107194:	6a 5f                	push   $0x5f
  jmp alltraps
80107196:	e9 35 f6 ff ff       	jmp    801067d0 <alltraps>

8010719b <vector96>:
.globl vector96
vector96:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $96
8010719d:	6a 60                	push   $0x60
  jmp alltraps
8010719f:	e9 2c f6 ff ff       	jmp    801067d0 <alltraps>

801071a4 <vector97>:
.globl vector97
vector97:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $97
801071a6:	6a 61                	push   $0x61
  jmp alltraps
801071a8:	e9 23 f6 ff ff       	jmp    801067d0 <alltraps>

801071ad <vector98>:
.globl vector98
vector98:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $98
801071af:	6a 62                	push   $0x62
  jmp alltraps
801071b1:	e9 1a f6 ff ff       	jmp    801067d0 <alltraps>

801071b6 <vector99>:
.globl vector99
vector99:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $99
801071b8:	6a 63                	push   $0x63
  jmp alltraps
801071ba:	e9 11 f6 ff ff       	jmp    801067d0 <alltraps>

801071bf <vector100>:
.globl vector100
vector100:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $100
801071c1:	6a 64                	push   $0x64
  jmp alltraps
801071c3:	e9 08 f6 ff ff       	jmp    801067d0 <alltraps>

801071c8 <vector101>:
.globl vector101
vector101:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $101
801071ca:	6a 65                	push   $0x65
  jmp alltraps
801071cc:	e9 ff f5 ff ff       	jmp    801067d0 <alltraps>

801071d1 <vector102>:
.globl vector102
vector102:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $102
801071d3:	6a 66                	push   $0x66
  jmp alltraps
801071d5:	e9 f6 f5 ff ff       	jmp    801067d0 <alltraps>

801071da <vector103>:
.globl vector103
vector103:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $103
801071dc:	6a 67                	push   $0x67
  jmp alltraps
801071de:	e9 ed f5 ff ff       	jmp    801067d0 <alltraps>

801071e3 <vector104>:
.globl vector104
vector104:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $104
801071e5:	6a 68                	push   $0x68
  jmp alltraps
801071e7:	e9 e4 f5 ff ff       	jmp    801067d0 <alltraps>

801071ec <vector105>:
.globl vector105
vector105:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $105
801071ee:	6a 69                	push   $0x69
  jmp alltraps
801071f0:	e9 db f5 ff ff       	jmp    801067d0 <alltraps>

801071f5 <vector106>:
.globl vector106
vector106:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $106
801071f7:	6a 6a                	push   $0x6a
  jmp alltraps
801071f9:	e9 d2 f5 ff ff       	jmp    801067d0 <alltraps>

801071fe <vector107>:
.globl vector107
vector107:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $107
80107200:	6a 6b                	push   $0x6b
  jmp alltraps
80107202:	e9 c9 f5 ff ff       	jmp    801067d0 <alltraps>

80107207 <vector108>:
.globl vector108
vector108:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $108
80107209:	6a 6c                	push   $0x6c
  jmp alltraps
8010720b:	e9 c0 f5 ff ff       	jmp    801067d0 <alltraps>

80107210 <vector109>:
.globl vector109
vector109:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $109
80107212:	6a 6d                	push   $0x6d
  jmp alltraps
80107214:	e9 b7 f5 ff ff       	jmp    801067d0 <alltraps>

80107219 <vector110>:
.globl vector110
vector110:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $110
8010721b:	6a 6e                	push   $0x6e
  jmp alltraps
8010721d:	e9 ae f5 ff ff       	jmp    801067d0 <alltraps>

80107222 <vector111>:
.globl vector111
vector111:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $111
80107224:	6a 6f                	push   $0x6f
  jmp alltraps
80107226:	e9 a5 f5 ff ff       	jmp    801067d0 <alltraps>

8010722b <vector112>:
.globl vector112
vector112:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $112
8010722d:	6a 70                	push   $0x70
  jmp alltraps
8010722f:	e9 9c f5 ff ff       	jmp    801067d0 <alltraps>

80107234 <vector113>:
.globl vector113
vector113:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $113
80107236:	6a 71                	push   $0x71
  jmp alltraps
80107238:	e9 93 f5 ff ff       	jmp    801067d0 <alltraps>

8010723d <vector114>:
.globl vector114
vector114:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $114
8010723f:	6a 72                	push   $0x72
  jmp alltraps
80107241:	e9 8a f5 ff ff       	jmp    801067d0 <alltraps>

80107246 <vector115>:
.globl vector115
vector115:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $115
80107248:	6a 73                	push   $0x73
  jmp alltraps
8010724a:	e9 81 f5 ff ff       	jmp    801067d0 <alltraps>

8010724f <vector116>:
.globl vector116
vector116:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $116
80107251:	6a 74                	push   $0x74
  jmp alltraps
80107253:	e9 78 f5 ff ff       	jmp    801067d0 <alltraps>

80107258 <vector117>:
.globl vector117
vector117:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $117
8010725a:	6a 75                	push   $0x75
  jmp alltraps
8010725c:	e9 6f f5 ff ff       	jmp    801067d0 <alltraps>

80107261 <vector118>:
.globl vector118
vector118:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $118
80107263:	6a 76                	push   $0x76
  jmp alltraps
80107265:	e9 66 f5 ff ff       	jmp    801067d0 <alltraps>

8010726a <vector119>:
.globl vector119
vector119:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $119
8010726c:	6a 77                	push   $0x77
  jmp alltraps
8010726e:	e9 5d f5 ff ff       	jmp    801067d0 <alltraps>

80107273 <vector120>:
.globl vector120
vector120:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $120
80107275:	6a 78                	push   $0x78
  jmp alltraps
80107277:	e9 54 f5 ff ff       	jmp    801067d0 <alltraps>

8010727c <vector121>:
.globl vector121
vector121:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $121
8010727e:	6a 79                	push   $0x79
  jmp alltraps
80107280:	e9 4b f5 ff ff       	jmp    801067d0 <alltraps>

80107285 <vector122>:
.globl vector122
vector122:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $122
80107287:	6a 7a                	push   $0x7a
  jmp alltraps
80107289:	e9 42 f5 ff ff       	jmp    801067d0 <alltraps>

8010728e <vector123>:
.globl vector123
vector123:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $123
80107290:	6a 7b                	push   $0x7b
  jmp alltraps
80107292:	e9 39 f5 ff ff       	jmp    801067d0 <alltraps>

80107297 <vector124>:
.globl vector124
vector124:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $124
80107299:	6a 7c                	push   $0x7c
  jmp alltraps
8010729b:	e9 30 f5 ff ff       	jmp    801067d0 <alltraps>

801072a0 <vector125>:
.globl vector125
vector125:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $125
801072a2:	6a 7d                	push   $0x7d
  jmp alltraps
801072a4:	e9 27 f5 ff ff       	jmp    801067d0 <alltraps>

801072a9 <vector126>:
.globl vector126
vector126:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $126
801072ab:	6a 7e                	push   $0x7e
  jmp alltraps
801072ad:	e9 1e f5 ff ff       	jmp    801067d0 <alltraps>

801072b2 <vector127>:
.globl vector127
vector127:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $127
801072b4:	6a 7f                	push   $0x7f
  jmp alltraps
801072b6:	e9 15 f5 ff ff       	jmp    801067d0 <alltraps>

801072bb <vector128>:
.globl vector128
vector128:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $128
801072bd:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801072c2:	e9 09 f5 ff ff       	jmp    801067d0 <alltraps>

801072c7 <vector129>:
.globl vector129
vector129:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $129
801072c9:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801072ce:	e9 fd f4 ff ff       	jmp    801067d0 <alltraps>

801072d3 <vector130>:
.globl vector130
vector130:
  pushl $0
801072d3:	6a 00                	push   $0x0
  pushl $130
801072d5:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801072da:	e9 f1 f4 ff ff       	jmp    801067d0 <alltraps>

801072df <vector131>:
.globl vector131
vector131:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $131
801072e1:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801072e6:	e9 e5 f4 ff ff       	jmp    801067d0 <alltraps>

801072eb <vector132>:
.globl vector132
vector132:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $132
801072ed:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801072f2:	e9 d9 f4 ff ff       	jmp    801067d0 <alltraps>

801072f7 <vector133>:
.globl vector133
vector133:
  pushl $0
801072f7:	6a 00                	push   $0x0
  pushl $133
801072f9:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801072fe:	e9 cd f4 ff ff       	jmp    801067d0 <alltraps>

80107303 <vector134>:
.globl vector134
vector134:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $134
80107305:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010730a:	e9 c1 f4 ff ff       	jmp    801067d0 <alltraps>

8010730f <vector135>:
.globl vector135
vector135:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $135
80107311:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107316:	e9 b5 f4 ff ff       	jmp    801067d0 <alltraps>

8010731b <vector136>:
.globl vector136
vector136:
  pushl $0
8010731b:	6a 00                	push   $0x0
  pushl $136
8010731d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107322:	e9 a9 f4 ff ff       	jmp    801067d0 <alltraps>

80107327 <vector137>:
.globl vector137
vector137:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $137
80107329:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010732e:	e9 9d f4 ff ff       	jmp    801067d0 <alltraps>

80107333 <vector138>:
.globl vector138
vector138:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $138
80107335:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010733a:	e9 91 f4 ff ff       	jmp    801067d0 <alltraps>

8010733f <vector139>:
.globl vector139
vector139:
  pushl $0
8010733f:	6a 00                	push   $0x0
  pushl $139
80107341:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107346:	e9 85 f4 ff ff       	jmp    801067d0 <alltraps>

8010734b <vector140>:
.globl vector140
vector140:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $140
8010734d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107352:	e9 79 f4 ff ff       	jmp    801067d0 <alltraps>

80107357 <vector141>:
.globl vector141
vector141:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $141
80107359:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010735e:	e9 6d f4 ff ff       	jmp    801067d0 <alltraps>

80107363 <vector142>:
.globl vector142
vector142:
  pushl $0
80107363:	6a 00                	push   $0x0
  pushl $142
80107365:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010736a:	e9 61 f4 ff ff       	jmp    801067d0 <alltraps>

8010736f <vector143>:
.globl vector143
vector143:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $143
80107371:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107376:	e9 55 f4 ff ff       	jmp    801067d0 <alltraps>

8010737b <vector144>:
.globl vector144
vector144:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $144
8010737d:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107382:	e9 49 f4 ff ff       	jmp    801067d0 <alltraps>

80107387 <vector145>:
.globl vector145
vector145:
  pushl $0
80107387:	6a 00                	push   $0x0
  pushl $145
80107389:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010738e:	e9 3d f4 ff ff       	jmp    801067d0 <alltraps>

80107393 <vector146>:
.globl vector146
vector146:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $146
80107395:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010739a:	e9 31 f4 ff ff       	jmp    801067d0 <alltraps>

8010739f <vector147>:
.globl vector147
vector147:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $147
801073a1:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801073a6:	e9 25 f4 ff ff       	jmp    801067d0 <alltraps>

801073ab <vector148>:
.globl vector148
vector148:
  pushl $0
801073ab:	6a 00                	push   $0x0
  pushl $148
801073ad:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801073b2:	e9 19 f4 ff ff       	jmp    801067d0 <alltraps>

801073b7 <vector149>:
.globl vector149
vector149:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $149
801073b9:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801073be:	e9 0d f4 ff ff       	jmp    801067d0 <alltraps>

801073c3 <vector150>:
.globl vector150
vector150:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $150
801073c5:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801073ca:	e9 01 f4 ff ff       	jmp    801067d0 <alltraps>

801073cf <vector151>:
.globl vector151
vector151:
  pushl $0
801073cf:	6a 00                	push   $0x0
  pushl $151
801073d1:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801073d6:	e9 f5 f3 ff ff       	jmp    801067d0 <alltraps>

801073db <vector152>:
.globl vector152
vector152:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $152
801073dd:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801073e2:	e9 e9 f3 ff ff       	jmp    801067d0 <alltraps>

801073e7 <vector153>:
.globl vector153
vector153:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $153
801073e9:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801073ee:	e9 dd f3 ff ff       	jmp    801067d0 <alltraps>

801073f3 <vector154>:
.globl vector154
vector154:
  pushl $0
801073f3:	6a 00                	push   $0x0
  pushl $154
801073f5:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801073fa:	e9 d1 f3 ff ff       	jmp    801067d0 <alltraps>

801073ff <vector155>:
.globl vector155
vector155:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $155
80107401:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107406:	e9 c5 f3 ff ff       	jmp    801067d0 <alltraps>

8010740b <vector156>:
.globl vector156
vector156:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $156
8010740d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107412:	e9 b9 f3 ff ff       	jmp    801067d0 <alltraps>

80107417 <vector157>:
.globl vector157
vector157:
  pushl $0
80107417:	6a 00                	push   $0x0
  pushl $157
80107419:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010741e:	e9 ad f3 ff ff       	jmp    801067d0 <alltraps>

80107423 <vector158>:
.globl vector158
vector158:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $158
80107425:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010742a:	e9 a1 f3 ff ff       	jmp    801067d0 <alltraps>

8010742f <vector159>:
.globl vector159
vector159:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $159
80107431:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107436:	e9 95 f3 ff ff       	jmp    801067d0 <alltraps>

8010743b <vector160>:
.globl vector160
vector160:
  pushl $0
8010743b:	6a 00                	push   $0x0
  pushl $160
8010743d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107442:	e9 89 f3 ff ff       	jmp    801067d0 <alltraps>

80107447 <vector161>:
.globl vector161
vector161:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $161
80107449:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010744e:	e9 7d f3 ff ff       	jmp    801067d0 <alltraps>

80107453 <vector162>:
.globl vector162
vector162:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $162
80107455:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010745a:	e9 71 f3 ff ff       	jmp    801067d0 <alltraps>

8010745f <vector163>:
.globl vector163
vector163:
  pushl $0
8010745f:	6a 00                	push   $0x0
  pushl $163
80107461:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107466:	e9 65 f3 ff ff       	jmp    801067d0 <alltraps>

8010746b <vector164>:
.globl vector164
vector164:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $164
8010746d:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107472:	e9 59 f3 ff ff       	jmp    801067d0 <alltraps>

80107477 <vector165>:
.globl vector165
vector165:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $165
80107479:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010747e:	e9 4d f3 ff ff       	jmp    801067d0 <alltraps>

80107483 <vector166>:
.globl vector166
vector166:
  pushl $0
80107483:	6a 00                	push   $0x0
  pushl $166
80107485:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010748a:	e9 41 f3 ff ff       	jmp    801067d0 <alltraps>

8010748f <vector167>:
.globl vector167
vector167:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $167
80107491:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107496:	e9 35 f3 ff ff       	jmp    801067d0 <alltraps>

8010749b <vector168>:
.globl vector168
vector168:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $168
8010749d:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801074a2:	e9 29 f3 ff ff       	jmp    801067d0 <alltraps>

801074a7 <vector169>:
.globl vector169
vector169:
  pushl $0
801074a7:	6a 00                	push   $0x0
  pushl $169
801074a9:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801074ae:	e9 1d f3 ff ff       	jmp    801067d0 <alltraps>

801074b3 <vector170>:
.globl vector170
vector170:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $170
801074b5:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801074ba:	e9 11 f3 ff ff       	jmp    801067d0 <alltraps>

801074bf <vector171>:
.globl vector171
vector171:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $171
801074c1:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801074c6:	e9 05 f3 ff ff       	jmp    801067d0 <alltraps>

801074cb <vector172>:
.globl vector172
vector172:
  pushl $0
801074cb:	6a 00                	push   $0x0
  pushl $172
801074cd:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801074d2:	e9 f9 f2 ff ff       	jmp    801067d0 <alltraps>

801074d7 <vector173>:
.globl vector173
vector173:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $173
801074d9:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801074de:	e9 ed f2 ff ff       	jmp    801067d0 <alltraps>

801074e3 <vector174>:
.globl vector174
vector174:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $174
801074e5:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801074ea:	e9 e1 f2 ff ff       	jmp    801067d0 <alltraps>

801074ef <vector175>:
.globl vector175
vector175:
  pushl $0
801074ef:	6a 00                	push   $0x0
  pushl $175
801074f1:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801074f6:	e9 d5 f2 ff ff       	jmp    801067d0 <alltraps>

801074fb <vector176>:
.globl vector176
vector176:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $176
801074fd:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107502:	e9 c9 f2 ff ff       	jmp    801067d0 <alltraps>

80107507 <vector177>:
.globl vector177
vector177:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $177
80107509:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010750e:	e9 bd f2 ff ff       	jmp    801067d0 <alltraps>

80107513 <vector178>:
.globl vector178
vector178:
  pushl $0
80107513:	6a 00                	push   $0x0
  pushl $178
80107515:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010751a:	e9 b1 f2 ff ff       	jmp    801067d0 <alltraps>

8010751f <vector179>:
.globl vector179
vector179:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $179
80107521:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107526:	e9 a5 f2 ff ff       	jmp    801067d0 <alltraps>

8010752b <vector180>:
.globl vector180
vector180:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $180
8010752d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107532:	e9 99 f2 ff ff       	jmp    801067d0 <alltraps>

80107537 <vector181>:
.globl vector181
vector181:
  pushl $0
80107537:	6a 00                	push   $0x0
  pushl $181
80107539:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010753e:	e9 8d f2 ff ff       	jmp    801067d0 <alltraps>

80107543 <vector182>:
.globl vector182
vector182:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $182
80107545:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010754a:	e9 81 f2 ff ff       	jmp    801067d0 <alltraps>

8010754f <vector183>:
.globl vector183
vector183:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $183
80107551:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107556:	e9 75 f2 ff ff       	jmp    801067d0 <alltraps>

8010755b <vector184>:
.globl vector184
vector184:
  pushl $0
8010755b:	6a 00                	push   $0x0
  pushl $184
8010755d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107562:	e9 69 f2 ff ff       	jmp    801067d0 <alltraps>

80107567 <vector185>:
.globl vector185
vector185:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $185
80107569:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010756e:	e9 5d f2 ff ff       	jmp    801067d0 <alltraps>

80107573 <vector186>:
.globl vector186
vector186:
  pushl $0
80107573:	6a 00                	push   $0x0
  pushl $186
80107575:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010757a:	e9 51 f2 ff ff       	jmp    801067d0 <alltraps>

8010757f <vector187>:
.globl vector187
vector187:
  pushl $0
8010757f:	6a 00                	push   $0x0
  pushl $187
80107581:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107586:	e9 45 f2 ff ff       	jmp    801067d0 <alltraps>

8010758b <vector188>:
.globl vector188
vector188:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $188
8010758d:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107592:	e9 39 f2 ff ff       	jmp    801067d0 <alltraps>

80107597 <vector189>:
.globl vector189
vector189:
  pushl $0
80107597:	6a 00                	push   $0x0
  pushl $189
80107599:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010759e:	e9 2d f2 ff ff       	jmp    801067d0 <alltraps>

801075a3 <vector190>:
.globl vector190
vector190:
  pushl $0
801075a3:	6a 00                	push   $0x0
  pushl $190
801075a5:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801075aa:	e9 21 f2 ff ff       	jmp    801067d0 <alltraps>

801075af <vector191>:
.globl vector191
vector191:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $191
801075b1:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801075b6:	e9 15 f2 ff ff       	jmp    801067d0 <alltraps>

801075bb <vector192>:
.globl vector192
vector192:
  pushl $0
801075bb:	6a 00                	push   $0x0
  pushl $192
801075bd:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801075c2:	e9 09 f2 ff ff       	jmp    801067d0 <alltraps>

801075c7 <vector193>:
.globl vector193
vector193:
  pushl $0
801075c7:	6a 00                	push   $0x0
  pushl $193
801075c9:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801075ce:	e9 fd f1 ff ff       	jmp    801067d0 <alltraps>

801075d3 <vector194>:
.globl vector194
vector194:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $194
801075d5:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801075da:	e9 f1 f1 ff ff       	jmp    801067d0 <alltraps>

801075df <vector195>:
.globl vector195
vector195:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $195
801075e1:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801075e6:	e9 e5 f1 ff ff       	jmp    801067d0 <alltraps>

801075eb <vector196>:
.globl vector196
vector196:
  pushl $0
801075eb:	6a 00                	push   $0x0
  pushl $196
801075ed:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801075f2:	e9 d9 f1 ff ff       	jmp    801067d0 <alltraps>

801075f7 <vector197>:
.globl vector197
vector197:
  pushl $0
801075f7:	6a 00                	push   $0x0
  pushl $197
801075f9:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801075fe:	e9 cd f1 ff ff       	jmp    801067d0 <alltraps>

80107603 <vector198>:
.globl vector198
vector198:
  pushl $0
80107603:	6a 00                	push   $0x0
  pushl $198
80107605:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010760a:	e9 c1 f1 ff ff       	jmp    801067d0 <alltraps>

8010760f <vector199>:
.globl vector199
vector199:
  pushl $0
8010760f:	6a 00                	push   $0x0
  pushl $199
80107611:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107616:	e9 b5 f1 ff ff       	jmp    801067d0 <alltraps>

8010761b <vector200>:
.globl vector200
vector200:
  pushl $0
8010761b:	6a 00                	push   $0x0
  pushl $200
8010761d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107622:	e9 a9 f1 ff ff       	jmp    801067d0 <alltraps>

80107627 <vector201>:
.globl vector201
vector201:
  pushl $0
80107627:	6a 00                	push   $0x0
  pushl $201
80107629:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010762e:	e9 9d f1 ff ff       	jmp    801067d0 <alltraps>

80107633 <vector202>:
.globl vector202
vector202:
  pushl $0
80107633:	6a 00                	push   $0x0
  pushl $202
80107635:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010763a:	e9 91 f1 ff ff       	jmp    801067d0 <alltraps>

8010763f <vector203>:
.globl vector203
vector203:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $203
80107641:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107646:	e9 85 f1 ff ff       	jmp    801067d0 <alltraps>

8010764b <vector204>:
.globl vector204
vector204:
  pushl $0
8010764b:	6a 00                	push   $0x0
  pushl $204
8010764d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107652:	e9 79 f1 ff ff       	jmp    801067d0 <alltraps>

80107657 <vector205>:
.globl vector205
vector205:
  pushl $0
80107657:	6a 00                	push   $0x0
  pushl $205
80107659:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010765e:	e9 6d f1 ff ff       	jmp    801067d0 <alltraps>

80107663 <vector206>:
.globl vector206
vector206:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $206
80107665:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010766a:	e9 61 f1 ff ff       	jmp    801067d0 <alltraps>

8010766f <vector207>:
.globl vector207
vector207:
  pushl $0
8010766f:	6a 00                	push   $0x0
  pushl $207
80107671:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107676:	e9 55 f1 ff ff       	jmp    801067d0 <alltraps>

8010767b <vector208>:
.globl vector208
vector208:
  pushl $0
8010767b:	6a 00                	push   $0x0
  pushl $208
8010767d:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107682:	e9 49 f1 ff ff       	jmp    801067d0 <alltraps>

80107687 <vector209>:
.globl vector209
vector209:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $209
80107689:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010768e:	e9 3d f1 ff ff       	jmp    801067d0 <alltraps>

80107693 <vector210>:
.globl vector210
vector210:
  pushl $0
80107693:	6a 00                	push   $0x0
  pushl $210
80107695:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010769a:	e9 31 f1 ff ff       	jmp    801067d0 <alltraps>

8010769f <vector211>:
.globl vector211
vector211:
  pushl $0
8010769f:	6a 00                	push   $0x0
  pushl $211
801076a1:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801076a6:	e9 25 f1 ff ff       	jmp    801067d0 <alltraps>

801076ab <vector212>:
.globl vector212
vector212:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $212
801076ad:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801076b2:	e9 19 f1 ff ff       	jmp    801067d0 <alltraps>

801076b7 <vector213>:
.globl vector213
vector213:
  pushl $0
801076b7:	6a 00                	push   $0x0
  pushl $213
801076b9:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801076be:	e9 0d f1 ff ff       	jmp    801067d0 <alltraps>

801076c3 <vector214>:
.globl vector214
vector214:
  pushl $0
801076c3:	6a 00                	push   $0x0
  pushl $214
801076c5:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801076ca:	e9 01 f1 ff ff       	jmp    801067d0 <alltraps>

801076cf <vector215>:
.globl vector215
vector215:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $215
801076d1:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801076d6:	e9 f5 f0 ff ff       	jmp    801067d0 <alltraps>

801076db <vector216>:
.globl vector216
vector216:
  pushl $0
801076db:	6a 00                	push   $0x0
  pushl $216
801076dd:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801076e2:	e9 e9 f0 ff ff       	jmp    801067d0 <alltraps>

801076e7 <vector217>:
.globl vector217
vector217:
  pushl $0
801076e7:	6a 00                	push   $0x0
  pushl $217
801076e9:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801076ee:	e9 dd f0 ff ff       	jmp    801067d0 <alltraps>

801076f3 <vector218>:
.globl vector218
vector218:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $218
801076f5:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801076fa:	e9 d1 f0 ff ff       	jmp    801067d0 <alltraps>

801076ff <vector219>:
.globl vector219
vector219:
  pushl $0
801076ff:	6a 00                	push   $0x0
  pushl $219
80107701:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107706:	e9 c5 f0 ff ff       	jmp    801067d0 <alltraps>

8010770b <vector220>:
.globl vector220
vector220:
  pushl $0
8010770b:	6a 00                	push   $0x0
  pushl $220
8010770d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107712:	e9 b9 f0 ff ff       	jmp    801067d0 <alltraps>

80107717 <vector221>:
.globl vector221
vector221:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $221
80107719:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010771e:	e9 ad f0 ff ff       	jmp    801067d0 <alltraps>

80107723 <vector222>:
.globl vector222
vector222:
  pushl $0
80107723:	6a 00                	push   $0x0
  pushl $222
80107725:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010772a:	e9 a1 f0 ff ff       	jmp    801067d0 <alltraps>

8010772f <vector223>:
.globl vector223
vector223:
  pushl $0
8010772f:	6a 00                	push   $0x0
  pushl $223
80107731:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107736:	e9 95 f0 ff ff       	jmp    801067d0 <alltraps>

8010773b <vector224>:
.globl vector224
vector224:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $224
8010773d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107742:	e9 89 f0 ff ff       	jmp    801067d0 <alltraps>

80107747 <vector225>:
.globl vector225
vector225:
  pushl $0
80107747:	6a 00                	push   $0x0
  pushl $225
80107749:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010774e:	e9 7d f0 ff ff       	jmp    801067d0 <alltraps>

80107753 <vector226>:
.globl vector226
vector226:
  pushl $0
80107753:	6a 00                	push   $0x0
  pushl $226
80107755:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010775a:	e9 71 f0 ff ff       	jmp    801067d0 <alltraps>

8010775f <vector227>:
.globl vector227
vector227:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $227
80107761:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107766:	e9 65 f0 ff ff       	jmp    801067d0 <alltraps>

8010776b <vector228>:
.globl vector228
vector228:
  pushl $0
8010776b:	6a 00                	push   $0x0
  pushl $228
8010776d:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107772:	e9 59 f0 ff ff       	jmp    801067d0 <alltraps>

80107777 <vector229>:
.globl vector229
vector229:
  pushl $0
80107777:	6a 00                	push   $0x0
  pushl $229
80107779:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010777e:	e9 4d f0 ff ff       	jmp    801067d0 <alltraps>

80107783 <vector230>:
.globl vector230
vector230:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $230
80107785:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010778a:	e9 41 f0 ff ff       	jmp    801067d0 <alltraps>

8010778f <vector231>:
.globl vector231
vector231:
  pushl $0
8010778f:	6a 00                	push   $0x0
  pushl $231
80107791:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107796:	e9 35 f0 ff ff       	jmp    801067d0 <alltraps>

8010779b <vector232>:
.globl vector232
vector232:
  pushl $0
8010779b:	6a 00                	push   $0x0
  pushl $232
8010779d:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801077a2:	e9 29 f0 ff ff       	jmp    801067d0 <alltraps>

801077a7 <vector233>:
.globl vector233
vector233:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $233
801077a9:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801077ae:	e9 1d f0 ff ff       	jmp    801067d0 <alltraps>

801077b3 <vector234>:
.globl vector234
vector234:
  pushl $0
801077b3:	6a 00                	push   $0x0
  pushl $234
801077b5:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801077ba:	e9 11 f0 ff ff       	jmp    801067d0 <alltraps>

801077bf <vector235>:
.globl vector235
vector235:
  pushl $0
801077bf:	6a 00                	push   $0x0
  pushl $235
801077c1:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801077c6:	e9 05 f0 ff ff       	jmp    801067d0 <alltraps>

801077cb <vector236>:
.globl vector236
vector236:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $236
801077cd:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801077d2:	e9 f9 ef ff ff       	jmp    801067d0 <alltraps>

801077d7 <vector237>:
.globl vector237
vector237:
  pushl $0
801077d7:	6a 00                	push   $0x0
  pushl $237
801077d9:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801077de:	e9 ed ef ff ff       	jmp    801067d0 <alltraps>

801077e3 <vector238>:
.globl vector238
vector238:
  pushl $0
801077e3:	6a 00                	push   $0x0
  pushl $238
801077e5:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801077ea:	e9 e1 ef ff ff       	jmp    801067d0 <alltraps>

801077ef <vector239>:
.globl vector239
vector239:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $239
801077f1:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801077f6:	e9 d5 ef ff ff       	jmp    801067d0 <alltraps>

801077fb <vector240>:
.globl vector240
vector240:
  pushl $0
801077fb:	6a 00                	push   $0x0
  pushl $240
801077fd:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107802:	e9 c9 ef ff ff       	jmp    801067d0 <alltraps>

80107807 <vector241>:
.globl vector241
vector241:
  pushl $0
80107807:	6a 00                	push   $0x0
  pushl $241
80107809:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010780e:	e9 bd ef ff ff       	jmp    801067d0 <alltraps>

80107813 <vector242>:
.globl vector242
vector242:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $242
80107815:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010781a:	e9 b1 ef ff ff       	jmp    801067d0 <alltraps>

8010781f <vector243>:
.globl vector243
vector243:
  pushl $0
8010781f:	6a 00                	push   $0x0
  pushl $243
80107821:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107826:	e9 a5 ef ff ff       	jmp    801067d0 <alltraps>

8010782b <vector244>:
.globl vector244
vector244:
  pushl $0
8010782b:	6a 00                	push   $0x0
  pushl $244
8010782d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107832:	e9 99 ef ff ff       	jmp    801067d0 <alltraps>

80107837 <vector245>:
.globl vector245
vector245:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $245
80107839:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010783e:	e9 8d ef ff ff       	jmp    801067d0 <alltraps>

80107843 <vector246>:
.globl vector246
vector246:
  pushl $0
80107843:	6a 00                	push   $0x0
  pushl $246
80107845:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010784a:	e9 81 ef ff ff       	jmp    801067d0 <alltraps>

8010784f <vector247>:
.globl vector247
vector247:
  pushl $0
8010784f:	6a 00                	push   $0x0
  pushl $247
80107851:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107856:	e9 75 ef ff ff       	jmp    801067d0 <alltraps>

8010785b <vector248>:
.globl vector248
vector248:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $248
8010785d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107862:	e9 69 ef ff ff       	jmp    801067d0 <alltraps>

80107867 <vector249>:
.globl vector249
vector249:
  pushl $0
80107867:	6a 00                	push   $0x0
  pushl $249
80107869:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010786e:	e9 5d ef ff ff       	jmp    801067d0 <alltraps>

80107873 <vector250>:
.globl vector250
vector250:
  pushl $0
80107873:	6a 00                	push   $0x0
  pushl $250
80107875:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010787a:	e9 51 ef ff ff       	jmp    801067d0 <alltraps>

8010787f <vector251>:
.globl vector251
vector251:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $251
80107881:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107886:	e9 45 ef ff ff       	jmp    801067d0 <alltraps>

8010788b <vector252>:
.globl vector252
vector252:
  pushl $0
8010788b:	6a 00                	push   $0x0
  pushl $252
8010788d:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107892:	e9 39 ef ff ff       	jmp    801067d0 <alltraps>

80107897 <vector253>:
.globl vector253
vector253:
  pushl $0
80107897:	6a 00                	push   $0x0
  pushl $253
80107899:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010789e:	e9 2d ef ff ff       	jmp    801067d0 <alltraps>

801078a3 <vector254>:
.globl vector254
vector254:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $254
801078a5:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801078aa:	e9 21 ef ff ff       	jmp    801067d0 <alltraps>

801078af <vector255>:
.globl vector255
vector255:
  pushl $0
801078af:	6a 00                	push   $0x0
  pushl $255
801078b1:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801078b6:	e9 15 ef ff ff       	jmp    801067d0 <alltraps>

801078bb <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801078bb:	55                   	push   %ebp
801078bc:	89 e5                	mov    %esp,%ebp
801078be:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801078c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801078c4:	83 e8 01             	sub    $0x1,%eax
801078c7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801078cb:	8b 45 08             	mov    0x8(%ebp),%eax
801078ce:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801078d2:	8b 45 08             	mov    0x8(%ebp),%eax
801078d5:	c1 e8 10             	shr    $0x10,%eax
801078d8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801078dc:	8d 45 fa             	lea    -0x6(%ebp),%eax
801078df:	0f 01 10             	lgdtl  (%eax)
}
801078e2:	c9                   	leave  
801078e3:	c3                   	ret    

801078e4 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801078e4:	55                   	push   %ebp
801078e5:	89 e5                	mov    %esp,%ebp
801078e7:	83 ec 04             	sub    $0x4,%esp
801078ea:	8b 45 08             	mov    0x8(%ebp),%eax
801078ed:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801078f1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078f5:	0f 00 d8             	ltr    %ax
}
801078f8:	c9                   	leave  
801078f9:	c3                   	ret    

801078fa <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801078fa:	55                   	push   %ebp
801078fb:	89 e5                	mov    %esp,%ebp
801078fd:	83 ec 04             	sub    $0x4,%esp
80107900:	8b 45 08             	mov    0x8(%ebp),%eax
80107903:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107907:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010790b:	8e e8                	mov    %eax,%gs
}
8010790d:	c9                   	leave  
8010790e:	c3                   	ret    

8010790f <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010790f:	55                   	push   %ebp
80107910:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107912:	8b 45 08             	mov    0x8(%ebp),%eax
80107915:	0f 22 d8             	mov    %eax,%cr3
}
80107918:	5d                   	pop    %ebp
80107919:	c3                   	ret    

8010791a <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010791a:	55                   	push   %ebp
8010791b:	89 e5                	mov    %esp,%ebp
8010791d:	8b 45 08             	mov    0x8(%ebp),%eax
80107920:	05 00 00 00 80       	add    $0x80000000,%eax
80107925:	5d                   	pop    %ebp
80107926:	c3                   	ret    

80107927 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107927:	55                   	push   %ebp
80107928:	89 e5                	mov    %esp,%ebp
8010792a:	8b 45 08             	mov    0x8(%ebp),%eax
8010792d:	05 00 00 00 80       	add    $0x80000000,%eax
80107932:	5d                   	pop    %ebp
80107933:	c3                   	ret    

80107934 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107934:	55                   	push   %ebp
80107935:	89 e5                	mov    %esp,%ebp
80107937:	53                   	push   %ebx
80107938:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010793b:	e8 38 b5 ff ff       	call   80102e78 <cpunum>
80107940:	89 c2                	mov    %eax,%edx
80107942:	89 d0                	mov    %edx,%eax
80107944:	01 c0                	add    %eax,%eax
80107946:	01 d0                	add    %edx,%eax
80107948:	c1 e0 06             	shl    $0x6,%eax
8010794b:	05 80 33 11 80       	add    $0x80113380,%eax
80107950:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107956:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010795c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107968:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010796c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107973:	83 e2 f0             	and    $0xfffffff0,%edx
80107976:	83 ca 0a             	or     $0xa,%edx
80107979:	88 50 7d             	mov    %dl,0x7d(%eax)
8010797c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107983:	83 ca 10             	or     $0x10,%edx
80107986:	88 50 7d             	mov    %dl,0x7d(%eax)
80107989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107990:	83 e2 9f             	and    $0xffffff9f,%edx
80107993:	88 50 7d             	mov    %dl,0x7d(%eax)
80107996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107999:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010799d:	83 ca 80             	or     $0xffffff80,%edx
801079a0:	88 50 7d             	mov    %dl,0x7d(%eax)
801079a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079aa:	83 ca 0f             	or     $0xf,%edx
801079ad:	88 50 7e             	mov    %dl,0x7e(%eax)
801079b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079b7:	83 e2 ef             	and    $0xffffffef,%edx
801079ba:	88 50 7e             	mov    %dl,0x7e(%eax)
801079bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079c4:	83 e2 df             	and    $0xffffffdf,%edx
801079c7:	88 50 7e             	mov    %dl,0x7e(%eax)
801079ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079d1:	83 ca 40             	or     $0x40,%edx
801079d4:	88 50 7e             	mov    %dl,0x7e(%eax)
801079d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079da:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079de:	83 ca 80             	or     $0xffffff80,%edx
801079e1:	88 50 7e             	mov    %dl,0x7e(%eax)
801079e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e7:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801079eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ee:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801079f5:	ff ff 
801079f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fa:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107a01:	00 00 
80107a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a06:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a10:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a17:	83 e2 f0             	and    $0xfffffff0,%edx
80107a1a:	83 ca 02             	or     $0x2,%edx
80107a1d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a26:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a2d:	83 ca 10             	or     $0x10,%edx
80107a30:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a39:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a40:	83 e2 9f             	and    $0xffffff9f,%edx
80107a43:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a53:	83 ca 80             	or     $0xffffff80,%edx
80107a56:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a66:	83 ca 0f             	or     $0xf,%edx
80107a69:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a72:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a79:	83 e2 ef             	and    $0xffffffef,%edx
80107a7c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a85:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a8c:	83 e2 df             	and    $0xffffffdf,%edx
80107a8f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a98:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a9f:	83 ca 40             	or     $0x40,%edx
80107aa2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aab:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ab2:	83 ca 80             	or     $0xffffff80,%edx
80107ab5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abe:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac8:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107acf:	ff ff 
80107ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad4:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107adb:	00 00 
80107add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aea:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107af1:	83 e2 f0             	and    $0xfffffff0,%edx
80107af4:	83 ca 0a             	or     $0xa,%edx
80107af7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b00:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b07:	83 ca 10             	or     $0x10,%edx
80107b0a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b13:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b1a:	83 ca 60             	or     $0x60,%edx
80107b1d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b26:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b2d:	83 ca 80             	or     $0xffffff80,%edx
80107b30:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b39:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b40:	83 ca 0f             	or     $0xf,%edx
80107b43:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b53:	83 e2 ef             	and    $0xffffffef,%edx
80107b56:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b66:	83 e2 df             	and    $0xffffffdf,%edx
80107b69:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b72:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b79:	83 ca 40             	or     $0x40,%edx
80107b7c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b85:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b8c:	83 ca 80             	or     $0xffffff80,%edx
80107b8f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b98:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba2:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107ba9:	ff ff 
80107bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bae:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107bb5:	00 00 
80107bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bba:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bcb:	83 e2 f0             	and    $0xfffffff0,%edx
80107bce:	83 ca 02             	or     $0x2,%edx
80107bd1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bda:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107be1:	83 ca 10             	or     $0x10,%edx
80107be4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bed:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bf4:	83 ca 60             	or     $0x60,%edx
80107bf7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c00:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c07:	83 ca 80             	or     $0xffffff80,%edx
80107c0a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c1a:	83 ca 0f             	or     $0xf,%edx
80107c1d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c26:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c2d:	83 e2 ef             	and    $0xffffffef,%edx
80107c30:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c39:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c40:	83 e2 df             	and    $0xffffffdf,%edx
80107c43:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c53:	83 ca 40             	or     $0x40,%edx
80107c56:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c66:	83 ca 80             	or     $0xffffff80,%edx
80107c69:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c72:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7c:	05 b4 00 00 00       	add    $0xb4,%eax
80107c81:	89 c3                	mov    %eax,%ebx
80107c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c86:	05 b4 00 00 00       	add    $0xb4,%eax
80107c8b:	c1 e8 10             	shr    $0x10,%eax
80107c8e:	89 c1                	mov    %eax,%ecx
80107c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c93:	05 b4 00 00 00       	add    $0xb4,%eax
80107c98:	c1 e8 18             	shr    $0x18,%eax
80107c9b:	89 c2                	mov    %eax,%edx
80107c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca0:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107ca7:	00 00 
80107ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cac:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbf:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107cc6:	83 e1 f0             	and    $0xfffffff0,%ecx
80107cc9:	83 c9 02             	or     $0x2,%ecx
80107ccc:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd5:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107cdc:	83 c9 10             	or     $0x10,%ecx
80107cdf:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce8:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107cef:	83 e1 9f             	and    $0xffffff9f,%ecx
80107cf2:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfb:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107d02:	83 c9 80             	or     $0xffffff80,%ecx
80107d05:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d15:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d18:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d21:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d28:	83 e1 ef             	and    $0xffffffef,%ecx
80107d2b:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d34:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d3b:	83 e1 df             	and    $0xffffffdf,%ecx
80107d3e:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d47:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d4e:	83 c9 40             	or     $0x40,%ecx
80107d51:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d61:	83 c9 80             	or     $0xffffff80,%ecx
80107d64:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6d:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d76:	83 c0 70             	add    $0x70,%eax
80107d79:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107d80:	00 
80107d81:	89 04 24             	mov    %eax,(%esp)
80107d84:	e8 32 fb ff ff       	call   801078bb <lgdt>
  loadgs(SEG_KCPU << 3);
80107d89:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107d90:	e8 65 fb ff ff       	call   801078fa <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d98:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107d9e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107da5:	00 00 00 00 
}
80107da9:	83 c4 24             	add    $0x24,%esp
80107dac:	5b                   	pop    %ebx
80107dad:	5d                   	pop    %ebp
80107dae:	c3                   	ret    

80107daf <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107daf:	55                   	push   %ebp
80107db0:	89 e5                	mov    %esp,%ebp
80107db2:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107db5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107db8:	c1 e8 16             	shr    $0x16,%eax
80107dbb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80107dc5:	01 d0                	add    %edx,%eax
80107dc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107dca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dcd:	8b 00                	mov    (%eax),%eax
80107dcf:	83 e0 01             	and    $0x1,%eax
80107dd2:	85 c0                	test   %eax,%eax
80107dd4:	74 17                	je     80107ded <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dd9:	8b 00                	mov    (%eax),%eax
80107ddb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107de0:	89 04 24             	mov    %eax,(%esp)
80107de3:	e8 3f fb ff ff       	call   80107927 <p2v>
80107de8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107deb:	eb 4b                	jmp    80107e38 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ded:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107df1:	74 0e                	je     80107e01 <walkpgdir+0x52>
80107df3:	e8 ea ac ff ff       	call   80102ae2 <kalloc>
80107df8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107dfb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107dff:	75 07                	jne    80107e08 <walkpgdir+0x59>
      return 0;
80107e01:	b8 00 00 00 00       	mov    $0x0,%eax
80107e06:	eb 47                	jmp    80107e4f <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107e08:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e0f:	00 
80107e10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e17:	00 
80107e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1b:	89 04 24             	mov    %eax,(%esp)
80107e1e:	e8 fd d4 ff ff       	call   80105320 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e26:	89 04 24             	mov    %eax,(%esp)
80107e29:	e8 ec fa ff ff       	call   8010791a <v2p>
80107e2e:	83 c8 07             	or     $0x7,%eax
80107e31:	89 c2                	mov    %eax,%edx
80107e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e36:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107e38:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e3b:	c1 e8 0c             	shr    $0xc,%eax
80107e3e:	25 ff 03 00 00       	and    $0x3ff,%eax
80107e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4d:	01 d0                	add    %edx,%eax
}
80107e4f:	c9                   	leave  
80107e50:	c3                   	ret    

80107e51 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107e51:	55                   	push   %ebp
80107e52:	89 e5                	mov    %esp,%ebp
80107e54:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107e57:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e62:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e65:	8b 45 10             	mov    0x10(%ebp),%eax
80107e68:	01 d0                	add    %edx,%eax
80107e6a:	83 e8 01             	sub    $0x1,%eax
80107e6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e72:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e75:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107e7c:	00 
80107e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e80:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e84:	8b 45 08             	mov    0x8(%ebp),%eax
80107e87:	89 04 24             	mov    %eax,(%esp)
80107e8a:	e8 20 ff ff ff       	call   80107daf <walkpgdir>
80107e8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e92:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e96:	75 07                	jne    80107e9f <mappages+0x4e>
      return -1;
80107e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e9d:	eb 48                	jmp    80107ee7 <mappages+0x96>
    if(*pte & PTE_P)
80107e9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ea2:	8b 00                	mov    (%eax),%eax
80107ea4:	83 e0 01             	and    $0x1,%eax
80107ea7:	85 c0                	test   %eax,%eax
80107ea9:	74 0c                	je     80107eb7 <mappages+0x66>
      panic("remap");
80107eab:	c7 04 24 7c 90 10 80 	movl   $0x8010907c,(%esp)
80107eb2:	e8 83 86 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107eb7:	8b 45 18             	mov    0x18(%ebp),%eax
80107eba:	0b 45 14             	or     0x14(%ebp),%eax
80107ebd:	83 c8 01             	or     $0x1,%eax
80107ec0:	89 c2                	mov    %eax,%edx
80107ec2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ec5:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eca:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ecd:	75 08                	jne    80107ed7 <mappages+0x86>
      break;
80107ecf:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107ed0:	b8 00 00 00 00       	mov    $0x0,%eax
80107ed5:	eb 10                	jmp    80107ee7 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107ed7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107ede:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107ee5:	eb 8e                	jmp    80107e75 <mappages+0x24>
  return 0;
}
80107ee7:	c9                   	leave  
80107ee8:	c3                   	ret    

80107ee9 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107ee9:	55                   	push   %ebp
80107eea:	89 e5                	mov    %esp,%ebp
80107eec:	53                   	push   %ebx
80107eed:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ef0:	e8 ed ab ff ff       	call   80102ae2 <kalloc>
80107ef5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ef8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107efc:	75 0a                	jne    80107f08 <setupkvm+0x1f>
    return 0;
80107efe:	b8 00 00 00 00       	mov    $0x0,%eax
80107f03:	e9 98 00 00 00       	jmp    80107fa0 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107f08:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f0f:	00 
80107f10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f17:	00 
80107f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f1b:	89 04 24             	mov    %eax,(%esp)
80107f1e:	e8 fd d3 ff ff       	call   80105320 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107f23:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107f2a:	e8 f8 f9 ff ff       	call   80107927 <p2v>
80107f2f:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107f34:	76 0c                	jbe    80107f42 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107f36:	c7 04 24 82 90 10 80 	movl   $0x80109082,(%esp)
80107f3d:	e8 f8 85 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f42:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80107f49:	eb 49                	jmp    80107f94 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4e:	8b 48 0c             	mov    0xc(%eax),%ecx
80107f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f54:	8b 50 04             	mov    0x4(%eax),%edx
80107f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5a:	8b 58 08             	mov    0x8(%eax),%ebx
80107f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f60:	8b 40 04             	mov    0x4(%eax),%eax
80107f63:	29 c3                	sub    %eax,%ebx
80107f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f68:	8b 00                	mov    (%eax),%eax
80107f6a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107f6e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107f72:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107f76:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f7d:	89 04 24             	mov    %eax,(%esp)
80107f80:	e8 cc fe ff ff       	call   80107e51 <mappages>
80107f85:	85 c0                	test   %eax,%eax
80107f87:	79 07                	jns    80107f90 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107f89:	b8 00 00 00 00       	mov    $0x0,%eax
80107f8e:	eb 10                	jmp    80107fa0 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f90:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107f94:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80107f9b:	72 ae                	jb     80107f4b <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107fa0:	83 c4 34             	add    $0x34,%esp
80107fa3:	5b                   	pop    %ebx
80107fa4:	5d                   	pop    %ebp
80107fa5:	c3                   	ret    

80107fa6 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107fa6:	55                   	push   %ebp
80107fa7:	89 e5                	mov    %esp,%ebp
80107fa9:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107fac:	e8 38 ff ff ff       	call   80107ee9 <setupkvm>
80107fb1:	a3 78 f0 11 80       	mov    %eax,0x8011f078
  switchkvm();
80107fb6:	e8 02 00 00 00       	call   80107fbd <switchkvm>
}
80107fbb:	c9                   	leave  
80107fbc:	c3                   	ret    

80107fbd <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107fbd:	55                   	push   %ebp
80107fbe:	89 e5                	mov    %esp,%ebp
80107fc0:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107fc3:	a1 78 f0 11 80       	mov    0x8011f078,%eax
80107fc8:	89 04 24             	mov    %eax,(%esp)
80107fcb:	e8 4a f9 ff ff       	call   8010791a <v2p>
80107fd0:	89 04 24             	mov    %eax,(%esp)
80107fd3:	e8 37 f9 ff ff       	call   8010790f <lcr3>
}
80107fd8:	c9                   	leave  
80107fd9:	c3                   	ret    

80107fda <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107fda:	55                   	push   %ebp
80107fdb:	89 e5                	mov    %esp,%ebp
80107fdd:	53                   	push   %ebx
80107fde:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107fe1:	e8 3a d2 ff ff       	call   80105220 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107fe6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fec:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ff3:	83 c2 08             	add    $0x8,%edx
80107ff6:	89 d3                	mov    %edx,%ebx
80107ff8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fff:	83 c2 08             	add    $0x8,%edx
80108002:	c1 ea 10             	shr    $0x10,%edx
80108005:	89 d1                	mov    %edx,%ecx
80108007:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010800e:	83 c2 08             	add    $0x8,%edx
80108011:	c1 ea 18             	shr    $0x18,%edx
80108014:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010801b:	67 00 
8010801d:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108024:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
8010802a:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108031:	83 e1 f0             	and    $0xfffffff0,%ecx
80108034:	83 c9 09             	or     $0x9,%ecx
80108037:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010803d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108044:	83 c9 10             	or     $0x10,%ecx
80108047:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010804d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108054:	83 e1 9f             	and    $0xffffff9f,%ecx
80108057:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010805d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108064:	83 c9 80             	or     $0xffffff80,%ecx
80108067:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010806d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108074:	83 e1 f0             	and    $0xfffffff0,%ecx
80108077:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010807d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108084:	83 e1 ef             	and    $0xffffffef,%ecx
80108087:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010808d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108094:	83 e1 df             	and    $0xffffffdf,%ecx
80108097:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010809d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801080a4:	83 c9 40             	or     $0x40,%ecx
801080a7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801080ad:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801080b4:	83 e1 7f             	and    $0x7f,%ecx
801080b7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801080bd:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801080c3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080c9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801080d0:	83 e2 ef             	and    $0xffffffef,%edx
801080d3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801080d9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080df:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801080e5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080eb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801080f2:	8b 52 08             	mov    0x8(%edx),%edx
801080f5:	81 c2 00 10 00 00    	add    $0x1000,%edx
801080fb:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801080fe:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108105:	e8 da f7 ff ff       	call   801078e4 <ltr>
  if(p->pgdir == 0)
8010810a:	8b 45 08             	mov    0x8(%ebp),%eax
8010810d:	8b 40 04             	mov    0x4(%eax),%eax
80108110:	85 c0                	test   %eax,%eax
80108112:	75 0c                	jne    80108120 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108114:	c7 04 24 93 90 10 80 	movl   $0x80109093,(%esp)
8010811b:	e8 1a 84 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108120:	8b 45 08             	mov    0x8(%ebp),%eax
80108123:	8b 40 04             	mov    0x4(%eax),%eax
80108126:	89 04 24             	mov    %eax,(%esp)
80108129:	e8 ec f7 ff ff       	call   8010791a <v2p>
8010812e:	89 04 24             	mov    %eax,(%esp)
80108131:	e8 d9 f7 ff ff       	call   8010790f <lcr3>
  popcli();
80108136:	e8 29 d1 ff ff       	call   80105264 <popcli>
}
8010813b:	83 c4 14             	add    $0x14,%esp
8010813e:	5b                   	pop    %ebx
8010813f:	5d                   	pop    %ebp
80108140:	c3                   	ret    

80108141 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108141:	55                   	push   %ebp
80108142:	89 e5                	mov    %esp,%ebp
80108144:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108147:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010814e:	76 0c                	jbe    8010815c <inituvm+0x1b>
    panic("inituvm: more than a page");
80108150:	c7 04 24 a7 90 10 80 	movl   $0x801090a7,(%esp)
80108157:	e8 de 83 ff ff       	call   8010053a <panic>
  mem = kalloc();
8010815c:	e8 81 a9 ff ff       	call   80102ae2 <kalloc>
80108161:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108164:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010816b:	00 
8010816c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108173:	00 
80108174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108177:	89 04 24             	mov    %eax,(%esp)
8010817a:	e8 a1 d1 ff ff       	call   80105320 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010817f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108182:	89 04 24             	mov    %eax,(%esp)
80108185:	e8 90 f7 ff ff       	call   8010791a <v2p>
8010818a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108191:	00 
80108192:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108196:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010819d:	00 
8010819e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801081a5:	00 
801081a6:	8b 45 08             	mov    0x8(%ebp),%eax
801081a9:	89 04 24             	mov    %eax,(%esp)
801081ac:	e8 a0 fc ff ff       	call   80107e51 <mappages>
  memmove(mem, init, sz);
801081b1:	8b 45 10             	mov    0x10(%ebp),%eax
801081b4:	89 44 24 08          	mov    %eax,0x8(%esp)
801081b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801081bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801081bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c2:	89 04 24             	mov    %eax,(%esp)
801081c5:	e8 25 d2 ff ff       	call   801053ef <memmove>
}
801081ca:	c9                   	leave  
801081cb:	c3                   	ret    

801081cc <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801081cc:	55                   	push   %ebp
801081cd:	89 e5                	mov    %esp,%ebp
801081cf:	53                   	push   %ebx
801081d0:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801081d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801081d6:	25 ff 0f 00 00       	and    $0xfff,%eax
801081db:	85 c0                	test   %eax,%eax
801081dd:	74 0c                	je     801081eb <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801081df:	c7 04 24 c4 90 10 80 	movl   $0x801090c4,(%esp)
801081e6:	e8 4f 83 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
801081eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081f2:	e9 a9 00 00 00       	jmp    801082a0 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801081f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fa:	8b 55 0c             	mov    0xc(%ebp),%edx
801081fd:	01 d0                	add    %edx,%eax
801081ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108206:	00 
80108207:	89 44 24 04          	mov    %eax,0x4(%esp)
8010820b:	8b 45 08             	mov    0x8(%ebp),%eax
8010820e:	89 04 24             	mov    %eax,(%esp)
80108211:	e8 99 fb ff ff       	call   80107daf <walkpgdir>
80108216:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108219:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010821d:	75 0c                	jne    8010822b <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010821f:	c7 04 24 e7 90 10 80 	movl   $0x801090e7,(%esp)
80108226:	e8 0f 83 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
8010822b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010822e:	8b 00                	mov    (%eax),%eax
80108230:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108235:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108238:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823b:	8b 55 18             	mov    0x18(%ebp),%edx
8010823e:	29 c2                	sub    %eax,%edx
80108240:	89 d0                	mov    %edx,%eax
80108242:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108247:	77 0f                	ja     80108258 <loaduvm+0x8c>
      n = sz - i;
80108249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824c:	8b 55 18             	mov    0x18(%ebp),%edx
8010824f:	29 c2                	sub    %eax,%edx
80108251:	89 d0                	mov    %edx,%eax
80108253:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108256:	eb 07                	jmp    8010825f <loaduvm+0x93>
    else
      n = PGSIZE;
80108258:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010825f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108262:	8b 55 14             	mov    0x14(%ebp),%edx
80108265:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108268:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010826b:	89 04 24             	mov    %eax,(%esp)
8010826e:	e8 b4 f6 ff ff       	call   80107927 <p2v>
80108273:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108276:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010827a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010827e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108282:	8b 45 10             	mov    0x10(%ebp),%eax
80108285:	89 04 24             	mov    %eax,(%esp)
80108288:	e8 db 9a ff ff       	call   80101d68 <readi>
8010828d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108290:	74 07                	je     80108299 <loaduvm+0xcd>
      return -1;
80108292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108297:	eb 18                	jmp    801082b1 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108299:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a3:	3b 45 18             	cmp    0x18(%ebp),%eax
801082a6:	0f 82 4b ff ff ff    	jb     801081f7 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801082ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082b1:	83 c4 24             	add    $0x24,%esp
801082b4:	5b                   	pop    %ebx
801082b5:	5d                   	pop    %ebp
801082b6:	c3                   	ret    

801082b7 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082b7:	55                   	push   %ebp
801082b8:	89 e5                	mov    %esp,%ebp
801082ba:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801082bd:	8b 45 10             	mov    0x10(%ebp),%eax
801082c0:	85 c0                	test   %eax,%eax
801082c2:	79 0a                	jns    801082ce <allocuvm+0x17>
    return 0;
801082c4:	b8 00 00 00 00       	mov    $0x0,%eax
801082c9:	e9 c1 00 00 00       	jmp    8010838f <allocuvm+0xd8>
  if(newsz < oldsz)
801082ce:	8b 45 10             	mov    0x10(%ebp),%eax
801082d1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082d4:	73 08                	jae    801082de <allocuvm+0x27>
    return oldsz;
801082d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801082d9:	e9 b1 00 00 00       	jmp    8010838f <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801082de:	8b 45 0c             	mov    0xc(%ebp),%eax
801082e1:	05 ff 0f 00 00       	add    $0xfff,%eax
801082e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801082ee:	e9 8d 00 00 00       	jmp    80108380 <allocuvm+0xc9>
    mem = kalloc();
801082f3:	e8 ea a7 ff ff       	call   80102ae2 <kalloc>
801082f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801082fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082ff:	75 2c                	jne    8010832d <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108301:	c7 04 24 05 91 10 80 	movl   $0x80109105,(%esp)
80108308:	e8 93 80 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010830d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108310:	89 44 24 08          	mov    %eax,0x8(%esp)
80108314:	8b 45 10             	mov    0x10(%ebp),%eax
80108317:	89 44 24 04          	mov    %eax,0x4(%esp)
8010831b:	8b 45 08             	mov    0x8(%ebp),%eax
8010831e:	89 04 24             	mov    %eax,(%esp)
80108321:	e8 6b 00 00 00       	call   80108391 <deallocuvm>
      return 0;
80108326:	b8 00 00 00 00       	mov    $0x0,%eax
8010832b:	eb 62                	jmp    8010838f <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
8010832d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108334:	00 
80108335:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010833c:	00 
8010833d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108340:	89 04 24             	mov    %eax,(%esp)
80108343:	e8 d8 cf ff ff       	call   80105320 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108348:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010834b:	89 04 24             	mov    %eax,(%esp)
8010834e:	e8 c7 f5 ff ff       	call   8010791a <v2p>
80108353:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108356:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010835d:	00 
8010835e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108362:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108369:	00 
8010836a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010836e:	8b 45 08             	mov    0x8(%ebp),%eax
80108371:	89 04 24             	mov    %eax,(%esp)
80108374:	e8 d8 fa ff ff       	call   80107e51 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108379:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108383:	3b 45 10             	cmp    0x10(%ebp),%eax
80108386:	0f 82 67 ff ff ff    	jb     801082f3 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010838c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010838f:	c9                   	leave  
80108390:	c3                   	ret    

80108391 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108391:	55                   	push   %ebp
80108392:	89 e5                	mov    %esp,%ebp
80108394:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108397:	8b 45 10             	mov    0x10(%ebp),%eax
8010839a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010839d:	72 08                	jb     801083a7 <deallocuvm+0x16>
    return oldsz;
8010839f:	8b 45 0c             	mov    0xc(%ebp),%eax
801083a2:	e9 a4 00 00 00       	jmp    8010844b <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801083a7:	8b 45 10             	mov    0x10(%ebp),%eax
801083aa:	05 ff 0f 00 00       	add    $0xfff,%eax
801083af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801083b7:	e9 80 00 00 00       	jmp    8010843c <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801083bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083c6:	00 
801083c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801083cb:	8b 45 08             	mov    0x8(%ebp),%eax
801083ce:	89 04 24             	mov    %eax,(%esp)
801083d1:	e8 d9 f9 ff ff       	call   80107daf <walkpgdir>
801083d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801083d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083dd:	75 09                	jne    801083e8 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801083df:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801083e6:	eb 4d                	jmp    80108435 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801083e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083eb:	8b 00                	mov    (%eax),%eax
801083ed:	83 e0 01             	and    $0x1,%eax
801083f0:	85 c0                	test   %eax,%eax
801083f2:	74 41                	je     80108435 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801083f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083f7:	8b 00                	mov    (%eax),%eax
801083f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108401:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108405:	75 0c                	jne    80108413 <deallocuvm+0x82>
        panic("kfree");
80108407:	c7 04 24 1d 91 10 80 	movl   $0x8010911d,(%esp)
8010840e:	e8 27 81 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108413:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108416:	89 04 24             	mov    %eax,(%esp)
80108419:	e8 09 f5 ff ff       	call   80107927 <p2v>
8010841e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108421:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108424:	89 04 24             	mov    %eax,(%esp)
80108427:	e8 1d a6 ff ff       	call   80102a49 <kfree>
      *pte = 0;
8010842c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010842f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108435:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010843c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108442:	0f 82 74 ff ff ff    	jb     801083bc <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108448:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010844b:	c9                   	leave  
8010844c:	c3                   	ret    

8010844d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010844d:	55                   	push   %ebp
8010844e:	89 e5                	mov    %esp,%ebp
80108450:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108453:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108457:	75 0c                	jne    80108465 <freevm+0x18>
    panic("freevm: no pgdir");
80108459:	c7 04 24 23 91 10 80 	movl   $0x80109123,(%esp)
80108460:	e8 d5 80 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108465:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010846c:	00 
8010846d:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108474:	80 
80108475:	8b 45 08             	mov    0x8(%ebp),%eax
80108478:	89 04 24             	mov    %eax,(%esp)
8010847b:	e8 11 ff ff ff       	call   80108391 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108480:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108487:	eb 48                	jmp    801084d1 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108493:	8b 45 08             	mov    0x8(%ebp),%eax
80108496:	01 d0                	add    %edx,%eax
80108498:	8b 00                	mov    (%eax),%eax
8010849a:	83 e0 01             	and    $0x1,%eax
8010849d:	85 c0                	test   %eax,%eax
8010849f:	74 2c                	je     801084cd <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801084a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801084ab:	8b 45 08             	mov    0x8(%ebp),%eax
801084ae:	01 d0                	add    %edx,%eax
801084b0:	8b 00                	mov    (%eax),%eax
801084b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084b7:	89 04 24             	mov    %eax,(%esp)
801084ba:	e8 68 f4 ff ff       	call   80107927 <p2v>
801084bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801084c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c5:	89 04 24             	mov    %eax,(%esp)
801084c8:	e8 7c a5 ff ff       	call   80102a49 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801084cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084d1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801084d8:	76 af                	jbe    80108489 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801084da:	8b 45 08             	mov    0x8(%ebp),%eax
801084dd:	89 04 24             	mov    %eax,(%esp)
801084e0:	e8 64 a5 ff ff       	call   80102a49 <kfree>
}
801084e5:	c9                   	leave  
801084e6:	c3                   	ret    

801084e7 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801084e7:	55                   	push   %ebp
801084e8:	89 e5                	mov    %esp,%ebp
801084ea:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084f4:	00 
801084f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801084f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801084fc:	8b 45 08             	mov    0x8(%ebp),%eax
801084ff:	89 04 24             	mov    %eax,(%esp)
80108502:	e8 a8 f8 ff ff       	call   80107daf <walkpgdir>
80108507:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010850a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010850e:	75 0c                	jne    8010851c <clearpteu+0x35>
    panic("clearpteu");
80108510:	c7 04 24 34 91 10 80 	movl   $0x80109134,(%esp)
80108517:	e8 1e 80 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
8010851c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851f:	8b 00                	mov    (%eax),%eax
80108521:	83 e0 fb             	and    $0xfffffffb,%eax
80108524:	89 c2                	mov    %eax,%edx
80108526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108529:	89 10                	mov    %edx,(%eax)
}
8010852b:	c9                   	leave  
8010852c:	c3                   	ret    

8010852d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010852d:	55                   	push   %ebp
8010852e:	89 e5                	mov    %esp,%ebp
80108530:	53                   	push   %ebx
80108531:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108534:	e8 b0 f9 ff ff       	call   80107ee9 <setupkvm>
80108539:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010853c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108540:	75 0a                	jne    8010854c <copyuvm+0x1f>
    return 0;
80108542:	b8 00 00 00 00       	mov    $0x0,%eax
80108547:	e9 fd 00 00 00       	jmp    80108649 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010854c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108553:	e9 d0 00 00 00       	jmp    80108628 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108562:	00 
80108563:	89 44 24 04          	mov    %eax,0x4(%esp)
80108567:	8b 45 08             	mov    0x8(%ebp),%eax
8010856a:	89 04 24             	mov    %eax,(%esp)
8010856d:	e8 3d f8 ff ff       	call   80107daf <walkpgdir>
80108572:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108575:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108579:	75 0c                	jne    80108587 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
8010857b:	c7 04 24 3e 91 10 80 	movl   $0x8010913e,(%esp)
80108582:	e8 b3 7f ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
80108587:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010858a:	8b 00                	mov    (%eax),%eax
8010858c:	83 e0 01             	and    $0x1,%eax
8010858f:	85 c0                	test   %eax,%eax
80108591:	75 0c                	jne    8010859f <copyuvm+0x72>
      panic("copyuvm: page not present");
80108593:	c7 04 24 58 91 10 80 	movl   $0x80109158,(%esp)
8010859a:	e8 9b 7f ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
8010859f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085a2:	8b 00                	mov    (%eax),%eax
801085a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801085ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085af:	8b 00                	mov    (%eax),%eax
801085b1:	25 ff 0f 00 00       	and    $0xfff,%eax
801085b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801085b9:	e8 24 a5 ff ff       	call   80102ae2 <kalloc>
801085be:	89 45 e0             	mov    %eax,-0x20(%ebp)
801085c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801085c5:	75 02                	jne    801085c9 <copyuvm+0x9c>
      goto bad;
801085c7:	eb 70                	jmp    80108639 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
801085c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085cc:	89 04 24             	mov    %eax,(%esp)
801085cf:	e8 53 f3 ff ff       	call   80107927 <p2v>
801085d4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085db:	00 
801085dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801085e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801085e3:	89 04 24             	mov    %eax,(%esp)
801085e6:	e8 04 ce ff ff       	call   801053ef <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801085eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801085ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801085f1:	89 04 24             	mov    %eax,(%esp)
801085f4:	e8 21 f3 ff ff       	call   8010791a <v2p>
801085f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085fc:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108600:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108604:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010860b:	00 
8010860c:	89 54 24 04          	mov    %edx,0x4(%esp)
80108610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108613:	89 04 24             	mov    %eax,(%esp)
80108616:	e8 36 f8 ff ff       	call   80107e51 <mappages>
8010861b:	85 c0                	test   %eax,%eax
8010861d:	79 02                	jns    80108621 <copyuvm+0xf4>
      goto bad;
8010861f:	eb 18                	jmp    80108639 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108621:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010862e:	0f 82 24 ff ff ff    	jb     80108558 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108634:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108637:	eb 10                	jmp    80108649 <copyuvm+0x11c>

bad:
  freevm(d);
80108639:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010863c:	89 04 24             	mov    %eax,(%esp)
8010863f:	e8 09 fe ff ff       	call   8010844d <freevm>
  return 0;
80108644:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108649:	83 c4 44             	add    $0x44,%esp
8010864c:	5b                   	pop    %ebx
8010864d:	5d                   	pop    %ebp
8010864e:	c3                   	ret    

8010864f <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010864f:	55                   	push   %ebp
80108650:	89 e5                	mov    %esp,%ebp
80108652:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108655:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010865c:	00 
8010865d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108660:	89 44 24 04          	mov    %eax,0x4(%esp)
80108664:	8b 45 08             	mov    0x8(%ebp),%eax
80108667:	89 04 24             	mov    %eax,(%esp)
8010866a:	e8 40 f7 ff ff       	call   80107daf <walkpgdir>
8010866f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108675:	8b 00                	mov    (%eax),%eax
80108677:	83 e0 01             	and    $0x1,%eax
8010867a:	85 c0                	test   %eax,%eax
8010867c:	75 07                	jne    80108685 <uva2ka+0x36>
    return 0;
8010867e:	b8 00 00 00 00       	mov    $0x0,%eax
80108683:	eb 25                	jmp    801086aa <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108688:	8b 00                	mov    (%eax),%eax
8010868a:	83 e0 04             	and    $0x4,%eax
8010868d:	85 c0                	test   %eax,%eax
8010868f:	75 07                	jne    80108698 <uva2ka+0x49>
    return 0;
80108691:	b8 00 00 00 00       	mov    $0x0,%eax
80108696:	eb 12                	jmp    801086aa <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869b:	8b 00                	mov    (%eax),%eax
8010869d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086a2:	89 04 24             	mov    %eax,(%esp)
801086a5:	e8 7d f2 ff ff       	call   80107927 <p2v>
}
801086aa:	c9                   	leave  
801086ab:	c3                   	ret    

801086ac <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801086ac:	55                   	push   %ebp
801086ad:	89 e5                	mov    %esp,%ebp
801086af:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801086b2:	8b 45 10             	mov    0x10(%ebp),%eax
801086b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801086b8:	e9 87 00 00 00       	jmp    80108744 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801086bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801086c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801086c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801086cf:	8b 45 08             	mov    0x8(%ebp),%eax
801086d2:	89 04 24             	mov    %eax,(%esp)
801086d5:	e8 75 ff ff ff       	call   8010864f <uva2ka>
801086da:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801086dd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801086e1:	75 07                	jne    801086ea <copyout+0x3e>
      return -1;
801086e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801086e8:	eb 69                	jmp    80108753 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801086ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801086ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
801086f0:	29 c2                	sub    %eax,%edx
801086f2:	89 d0                	mov    %edx,%eax
801086f4:	05 00 10 00 00       	add    $0x1000,%eax
801086f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801086fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086ff:	3b 45 14             	cmp    0x14(%ebp),%eax
80108702:	76 06                	jbe    8010870a <copyout+0x5e>
      n = len;
80108704:	8b 45 14             	mov    0x14(%ebp),%eax
80108707:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010870a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010870d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108710:	29 c2                	sub    %eax,%edx
80108712:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108715:	01 c2                	add    %eax,%edx
80108717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010871a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010871e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108721:	89 44 24 04          	mov    %eax,0x4(%esp)
80108725:	89 14 24             	mov    %edx,(%esp)
80108728:	e8 c2 cc ff ff       	call   801053ef <memmove>
    len -= n;
8010872d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108730:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108733:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108736:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108739:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010873c:	05 00 10 00 00       	add    $0x1000,%eax
80108741:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108744:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108748:	0f 85 6f ff ff ff    	jne    801086bd <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010874e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108753:	c9                   	leave  
80108754:	c3                   	ret    

80108755 <wakeupThreads>:
extern void forkret(void);
extern void trapret(void);

void
wakeupThreads(void *chan)
{
80108755:	55                   	push   %ebp
80108756:	89 e5                	mov    %esp,%ebp
80108758:	83 ec 28             	sub    $0x28,%esp



  struct kthread *t;

  acquire( thread->ptableLock);
8010875b:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80108761:	8b 40 1c             	mov    0x1c(%eax),%eax
80108764:	89 04 24             	mov    %eax,(%esp)
80108767:	e8 60 c9 ff ff       	call   801050cc <acquire>

  for(t= proc->threads; t < &proc->threads[NTHREAD]; t++){
8010876c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108772:	8b 40 74             	mov    0x74(%eax),%eax
80108775:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108778:	eb 24                	jmp    8010879e <wakeupThreads+0x49>

		  if(t->state == SLEEPING && t->chan == chan){
8010877a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877d:	8b 40 04             	mov    0x4(%eax),%eax
80108780:	83 f8 02             	cmp    $0x2,%eax
80108783:	75 15                	jne    8010879a <wakeupThreads+0x45>
80108785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108788:	8b 40 18             	mov    0x18(%eax),%eax
8010878b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010878e:	75 0a                	jne    8010879a <wakeupThreads+0x45>
			  t->state =  RUNNABLE;
80108790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108793:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)

  struct kthread *t;

  acquire( thread->ptableLock);

  for(t= proc->threads; t < &proc->threads[NTHREAD]; t++){
8010879a:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
8010879e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801087a4:	8b 40 74             	mov    0x74(%eax),%eax
801087a7:	05 40 02 00 00       	add    $0x240,%eax
801087ac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801087af:	77 c9                	ja     8010877a <wakeupThreads+0x25>
			  t->state =  RUNNABLE;

			  }
   }

  release(thread->ptableLock);
801087b1:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801087b7:	8b 40 1c             	mov    0x1c(%eax),%eax
801087ba:	89 04 24             	mov    %eax,(%esp)
801087bd:	e8 6c c9 ff ff       	call   8010512e <release>


}
801087c2:	c9                   	leave  
801087c3:	c3                   	ret    

801087c4 <kthread_create>:


int
kthread_create(void*(*start_func)(), void* stack, uint stack_size){
801087c4:	55                   	push   %ebp
801087c5:	89 e5                	mov    %esp,%ebp
801087c7:	57                   	push   %edi
801087c8:	56                   	push   %esi
801087c9:	53                   	push   %ebx
801087ca:	83 ec 2c             	sub    $0x2c,%esp

	  struct kthread *t;
	  char *sp;

	  acquire(thread->ptableLock);
801087cd:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801087d3:	8b 40 1c             	mov    0x1c(%eax),%eax
801087d6:	89 04 24             	mov    %eax,(%esp)
801087d9:	e8 ee c8 ff ff       	call   801050cc <acquire>
	  for(t = proc->threads;t<&proc->threads[NTHREAD];t++){
801087de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801087e4:	8b 40 74             	mov    0x74(%eax),%eax
801087e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801087ea:	eb 53                	jmp    8010883f <kthread_create+0x7b>
	    if(t->state == UNUSED){
801087ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801087ef:	8b 40 04             	mov    0x4(%eax),%eax
801087f2:	85 c0                	test   %eax,%eax
801087f4:	75 45                	jne    8010883b <kthread_create+0x77>
	       goto found;
801087f6:	90                   	nop
	  }
	  release(thread->ptableLock);
	  return -1;

	  found:
	       t->state=EMBRYO;
801087f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801087fa:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	       t->tid= nexttid++;
80108801:	a1 00 c5 10 80       	mov    0x8010c500,%eax
80108806:	8d 50 01             	lea    0x1(%eax),%edx
80108809:	89 15 00 c5 10 80    	mov    %edx,0x8010c500
8010880f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108812:	89 42 08             	mov    %eax,0x8(%edx)
	       release(thread->ptableLock);
80108815:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
8010881b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010881e:	89 04 24             	mov    %eax,(%esp)
80108821:	e8 08 c9 ff ff       	call   8010512e <release>
	       if((t->kstack = kalloc()) == 0){
80108826:	e8 b7 a2 ff ff       	call   80102ae2 <kalloc>
8010882b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010882e:	89 02                	mov    %eax,(%edx)
80108830:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108833:	8b 00                	mov    (%eax),%eax
80108835:	85 c0                	test   %eax,%eax
80108837:	75 48                	jne    80108881 <kthread_create+0xbd>
80108839:	eb 32                	jmp    8010886d <kthread_create+0xa9>

	  struct kthread *t;
	  char *sp;

	  acquire(thread->ptableLock);
	  for(t = proc->threads;t<&proc->threads[NTHREAD];t++){
8010883b:	83 45 e4 24          	addl   $0x24,-0x1c(%ebp)
8010883f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108845:	8b 40 74             	mov    0x74(%eax),%eax
80108848:	05 40 02 00 00       	add    $0x240,%eax
8010884d:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80108850:	77 9a                	ja     801087ec <kthread_create+0x28>
	    if(t->state == UNUSED){
	       goto found;
	    }
	  }
	  release(thread->ptableLock);
80108852:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80108858:	8b 40 1c             	mov    0x1c(%eax),%eax
8010885b:	89 04 24             	mov    %eax,(%esp)
8010885e:	e8 cb c8 ff ff       	call   8010512e <release>
	  return -1;
80108863:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108868:	e9 cd 00 00 00       	jmp    8010893a <kthread_create+0x176>
	  found:
	       t->state=EMBRYO;
	       t->tid= nexttid++;
	       release(thread->ptableLock);
	       if((t->kstack = kalloc()) == 0){
	        t->state = UNUSED;
8010886d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108870:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	        return -1;
80108877:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010887c:	e9 b9 00 00 00       	jmp    8010893a <kthread_create+0x176>
	       }
	       sp = t->kstack + stack_size;//KSTACKSIZE;
80108881:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108884:	8b 10                	mov    (%eax),%edx
80108886:	8b 45 10             	mov    0x10(%ebp),%eax
80108889:	01 d0                	add    %edx,%eax
8010888b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	       sp -= sizeof *t->tf;
8010888e:	83 6d e0 4c          	subl   $0x4c,-0x20(%ebp)

	       t->tf = (struct trapframe*)sp ;
80108892:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108895:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108898:	89 50 10             	mov    %edx,0x10(%eax)
	       sp -= 4;
8010889b:	83 6d e0 04          	subl   $0x4,-0x20(%ebp)
	       *(uint*)sp = (uint)trapret;
8010889f:	ba f0 67 10 80       	mov    $0x801067f0,%edx
801088a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088a7:	89 10                	mov    %edx,(%eax)
	       sp -= sizeof *t->context;
801088a9:	83 6d e0 14          	subl   $0x14,-0x20(%ebp)
	       t->context = (struct context*)sp;
801088ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801088b3:	89 50 14             	mov    %edx,0x14(%eax)
	       memset(t->context, 0, sizeof *t->context);
801088b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088b9:	8b 40 14             	mov    0x14(%eax),%eax
801088bc:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801088c3:	00 
801088c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801088cb:	00 
801088cc:	89 04 24             	mov    %eax,(%esp)
801088cf:	e8 4c ca ff ff       	call   80105320 <memset>
	       //t->wait_time = 0;

	       t->context->eip = (uint)forkret;
801088d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088d7:	8b 40 14             	mov    0x14(%eax),%eax
801088da:	ba 38 4d 10 80       	mov    $0x80104d38,%edx
801088df:	89 50 10             	mov    %edx,0x10(%eax)
	       *t->tf=*thread->tf;
801088e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088e5:	8b 50 10             	mov    0x10(%eax),%edx
801088e8:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801088ee:	8b 40 10             	mov    0x10(%eax),%eax
801088f1:	89 c3                	mov    %eax,%ebx
801088f3:	b8 13 00 00 00       	mov    $0x13,%eax
801088f8:	89 d7                	mov    %edx,%edi
801088fa:	89 de                	mov    %ebx,%esi
801088fc:	89 c1                	mov    %eax,%ecx
801088fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	       t->tf->eip = (uint)start_func;
80108900:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108903:	8b 40 10             	mov    0x10(%eax),%eax
80108906:	8b 55 08             	mov    0x8(%ebp),%edx
80108909:	89 50 38             	mov    %edx,0x38(%eax)
	       t->tf->esp = (uint)(stack+stack_size);
8010890c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010890f:	8b 40 10             	mov    0x10(%eax),%eax
80108912:	8b 55 10             	mov    0x10(%ebp),%edx
80108915:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80108918:	01 ca                	add    %ecx,%edx
8010891a:	89 50 44             	mov    %edx,0x44(%eax)
	       t->parent = proc;
8010891d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108924:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108927:	89 50 0c             	mov    %edx,0xc(%eax)
	       t->state = RUNNABLE;
8010892a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010892d:	c7 40 04 03 00 00 00 	movl   $0x3,0x4(%eax)
	       return t->tid;
80108934:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108937:	8b 40 08             	mov    0x8(%eax),%eax
	t->tid = index;
	t->parent =proc;
	t->state =RUNNABLE;
	release(proc->lock);
	return t->tid;*/
}
8010893a:	83 c4 2c             	add    $0x2c,%esp
8010893d:	5b                   	pop    %ebx
8010893e:	5e                   	pop    %esi
8010893f:	5f                   	pop    %edi
80108940:	5d                   	pop    %ebp
80108941:	c3                   	ret    

80108942 <kthread_id>:

int kthread_id(){
80108942:	55                   	push   %ebp
80108943:	89 e5                	mov    %esp,%ebp

	return thread->tid;
80108945:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
8010894b:	8b 40 08             	mov    0x8(%eax),%eax
}
8010894e:	5d                   	pop    %ebp
8010894f:	c3                   	ret    

80108950 <kthread_exit>:

void kthread_exit(){
80108950:	55                   	push   %ebp
80108951:	89 e5                	mov    %esp,%ebp
80108953:	83 ec 28             	sub    $0x28,%esp



	 int tid;
	 int found=-1;
80108956:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)


	 acquire(thread->ptableLock);
8010895d:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80108963:	8b 40 1c             	mov    0x1c(%eax),%eax
80108966:	89 04 24             	mov    %eax,(%esp)
80108969:	e8 5e c7 ff ff       	call   801050cc <acquire>

	 thread->state= ZOMBIE;
8010896e:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80108974:	c7 40 04 05 00 00 00 	movl   $0x5,0x4(%eax)

	 for (tid=0; tid< NTHREAD; tid++){
8010897b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108982:	eb 4b                	jmp    801089cf <kthread_exit+0x7f>
	 	 if (!( proc->threads[tid].state== ZOMBIE || proc->threads[tid].state== UNUSED)){
80108984:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010898a:	8b 48 74             	mov    0x74(%eax),%ecx
8010898d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108990:	89 d0                	mov    %edx,%eax
80108992:	c1 e0 03             	shl    $0x3,%eax
80108995:	01 d0                	add    %edx,%eax
80108997:	c1 e0 02             	shl    $0x2,%eax
8010899a:	01 c8                	add    %ecx,%eax
8010899c:	8b 40 04             	mov    0x4(%eax),%eax
8010899f:	83 f8 05             	cmp    $0x5,%eax
801089a2:	74 27                	je     801089cb <kthread_exit+0x7b>
801089a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801089aa:	8b 48 74             	mov    0x74(%eax),%ecx
801089ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089b0:	89 d0                	mov    %edx,%eax
801089b2:	c1 e0 03             	shl    $0x3,%eax
801089b5:	01 d0                	add    %edx,%eax
801089b7:	c1 e0 02             	shl    $0x2,%eax
801089ba:	01 c8                	add    %ecx,%eax
801089bc:	8b 40 04             	mov    0x4(%eax),%eax
801089bf:	85 c0                	test   %eax,%eax
801089c1:	74 08                	je     801089cb <kthread_exit+0x7b>
	 		 found=tid;
801089c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	 		 break;
801089c9:	eb 0a                	jmp    801089d5 <kthread_exit+0x85>

	 acquire(thread->ptableLock);

	 thread->state= ZOMBIE;

	 for (tid=0; tid< NTHREAD; tid++){
801089cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801089cf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801089d3:	7e af                	jle    80108984 <kthread_exit+0x34>
	 	 }
	 }



	 if (found<0){ // this was the last thread process needs to exit
801089d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801089d9:	79 05                	jns    801089e0 <kthread_exit+0x90>

		 exit();
801089db:	e8 24 bf ff ff       	call   80104904 <exit>





	 wakeupThreads(thread);
801089e0:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
801089e6:	89 04 24             	mov    %eax,(%esp)
801089e9:	e8 67 fd ff ff       	call   80108755 <wakeupThreads>




	 sched();
801089ee:	e8 61 c2 ff ff       	call   80104c54 <sched>
	 panic("zombie exit");
801089f3:	c7 04 24 72 91 10 80 	movl   $0x80109172,(%esp)
801089fa:	e8 3b 7b ff ff       	call   8010053a <panic>

801089ff <kthread_join>:
}

int kthread_join(int thread_id){
801089ff:	55                   	push   %ebp
80108a00:	89 e5                	mov    %esp,%ebp
80108a02:	83 ec 28             	sub    $0x28,%esp
	//printf( "thread id : %d ", thread_id);
	  int found, tid;
	  struct kthread *t;
	  struct kthread *threadFound;

	  acquire(thread->ptableLock);
80108a05:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80108a0b:	8b 40 1c             	mov    0x1c(%eax),%eax
80108a0e:	89 04 24             	mov    %eax,(%esp)
80108a11:	e8 b6 c6 ff ff       	call   801050cc <acquire>

	  for(;;){
	    // Scan through table looking for zombie children.
	    found = 0;
80108a16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	    for(t = proc->threads; t < &proc->threads[NTHREAD]; t++){
80108a1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a23:	8b 40 74             	mov    0x74(%eax),%eax
80108a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a29:	eb 66                	jmp    80108a91 <kthread_join+0x92>

	      if(t->tid != thread_id)
80108a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a2e:	8b 40 08             	mov    0x8(%eax),%eax
80108a31:	3b 45 08             	cmp    0x8(%ebp),%eax
80108a34:	74 02                	je     80108a38 <kthread_join+0x39>
	        continue;
80108a36:	eb 55                	jmp    80108a8d <kthread_join+0x8e>
	      found = 1;
80108a38:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	      threadFound= t;
80108a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a42:	89 45 ec             	mov    %eax,-0x14(%ebp)

	      if(t->state == ZOMBIE){
80108a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a48:	8b 40 04             	mov    0x4(%eax),%eax
80108a4b:	83 f8 05             	cmp    $0x5,%eax
80108a4e:	75 3d                	jne    80108a8d <kthread_join+0x8e>
	        // Found one.
	        tid = t->tid;
80108a50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a53:	8b 40 08             	mov    0x8(%eax),%eax
80108a56:	89 45 e8             	mov    %eax,-0x18(%ebp)
	        t->state = UNUSED;
80108a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a5c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	        t->tid = -1;
80108a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a66:	c7 40 08 ff ff ff ff 	movl   $0xffffffff,0x8(%eax)
	        t->parent = 0;
80108a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a70:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)

	        release(thread->ptableLock);
80108a77:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80108a7d:	8b 40 1c             	mov    0x1c(%eax),%eax
80108a80:	89 04 24             	mov    %eax,(%esp)
80108a83:	e8 a6 c6 ff ff       	call   8010512e <release>
	        return tid;
80108a88:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a8b:	eb 5f                	jmp    80108aec <kthread_join+0xed>

	  for(;;){
	    // Scan through table looking for zombie children.
	    found = 0;

	    for(t = proc->threads; t < &proc->threads[NTHREAD]; t++){
80108a8d:	83 45 f0 24          	addl   $0x24,-0x10(%ebp)
80108a91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108a97:	8b 40 74             	mov    0x74(%eax),%eax
80108a9a:	05 40 02 00 00       	add    $0x240,%eax
80108a9f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108aa2:	77 87                	ja     80108a2b <kthread_join+0x2c>
	        return tid;
	      }
	    }


	    if(!found || proc->killed){
80108aa4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108aa8:	74 0d                	je     80108ab7 <kthread_join+0xb8>
80108aaa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108ab0:	8b 40 1c             	mov    0x1c(%eax),%eax
80108ab3:	85 c0                	test   %eax,%eax
80108ab5:	74 18                	je     80108acf <kthread_join+0xd0>

	      release(thread->ptableLock);
80108ab7:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80108abd:	8b 40 1c             	mov    0x1c(%eax),%eax
80108ac0:	89 04 24             	mov    %eax,(%esp)
80108ac3:	e8 66 c6 ff ff       	call   8010512e <release>
	      return -1;
80108ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108acd:	eb 1d                	jmp    80108aec <kthread_join+0xed>
	    // Wait for thread to exit.




	    sleep(threadFound, thread->ptableLock);  //DOC: wait-sleep
80108acf:	65 a1 08 00 00 00    	mov    %gs:0x8,%eax
80108ad5:	8b 40 1c             	mov    0x1c(%eax),%eax
80108ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
80108adc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108adf:	89 04 24             	mov    %eax,(%esp)
80108ae2:	e8 7d c2 ff ff       	call   80104d64 <sleep>

	  }
80108ae7:	e9 2a ff ff ff       	jmp    80108a16 <kthread_join+0x17>


	  return -1;
}
80108aec:	c9                   	leave  
80108aed:	c3                   	ret    
