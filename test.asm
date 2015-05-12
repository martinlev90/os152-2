
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

int i = 0;

void* testfunc();

int main() {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp

	void * stack0 = malloc(MAX_STACK_SIZE);
   9:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  10:	e8 a4 07 00 00       	call   7b9 <malloc>
  15:	89 44 24 1c          	mov    %eax,0x1c(%esp)

	int tid =
  19:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  20:	00 
  21:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  25:	89 44 24 04          	mov    %eax,0x4(%esp)
  29:	c7 04 24 76 00 00 00 	movl   $0x76,(%esp)
  30:	e8 98 03 00 00       	call   3cd <kthread_create>
  35:	89 44 24 18          	mov    %eax,0x18(%esp)
			kthread_create(testfunc, stack0, MAX_STACK_SIZE);
	printf(1, "i: %d %d\n", i, tid);
  39:	a1 3c 0b 00 00       	mov    0xb3c,%eax
  3e:	8b 54 24 18          	mov    0x18(%esp),%edx
  42:	89 54 24 0c          	mov    %edx,0xc(%esp)
  46:	89 44 24 08          	mov    %eax,0x8(%esp)
  4a:	c7 44 24 04 99 08 00 	movl   $0x899,0x4(%esp)
  51:	00 
  52:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  59:	e8 6f 04 00 00       	call   4cd <printf>
	kthread_join(tid);
  5e:	8b 44 24 18          	mov    0x18(%esp),%eax
  62:	89 04 24             	mov    %eax,(%esp)
  65:	e8 7b 03 00 00       	call   3e5 <kthread_join>
//	printf(1, "i: %d %d\n", i, tid);

	kthread_exit();
  6a:	e8 6e 03 00 00       	call   3dd <kthread_exit>
	//exit();
	return 0;
  6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  74:	c9                   	leave  
  75:	c3                   	ret    

00000076 <testfunc>:

void* testfunc() {
  76:	55                   	push   %ebp
  77:	89 e5                	mov    %esp,%ebp
  79:	83 ec 28             	sub    $0x28,%esp

	int k;
	for (k = 0; k < 10; k++) {
  7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  83:	eb 2e                	jmp    b3 <testfunc+0x3d>

		printf(1, "thread is alive %d\n", ++i);
  85:	a1 3c 0b 00 00       	mov    0xb3c,%eax
  8a:	83 c0 01             	add    $0x1,%eax
  8d:	a3 3c 0b 00 00       	mov    %eax,0xb3c
  92:	a1 3c 0b 00 00       	mov    0xb3c,%eax
  97:	89 44 24 08          	mov    %eax,0x8(%esp)
  9b:	c7 44 24 04 a3 08 00 	movl   $0x8a3,0x4(%esp)
  a2:	00 
  a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  aa:	e8 1e 04 00 00       	call   4cd <printf>
}

void* testfunc() {

	int k;
	for (k = 0; k < 10; k++) {
  af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  b3:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  b7:	7e cc                	jle    85 <testfunc+0xf>

		printf(1, "thread is alive %d\n", ++i);
	}

	kthread_exit();
  b9:	e8 1f 03 00 00       	call   3dd <kthread_exit>
	return 0;
  be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  c3:	c9                   	leave  
  c4:	c3                   	ret    

000000c5 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  c5:	55                   	push   %ebp
  c6:	89 e5                	mov    %esp,%ebp
  c8:	57                   	push   %edi
  c9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  cd:	8b 55 10             	mov    0x10(%ebp),%edx
  d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  d3:	89 cb                	mov    %ecx,%ebx
  d5:	89 df                	mov    %ebx,%edi
  d7:	89 d1                	mov    %edx,%ecx
  d9:	fc                   	cld    
  da:	f3 aa                	rep stos %al,%es:(%edi)
  dc:	89 ca                	mov    %ecx,%edx
  de:	89 fb                	mov    %edi,%ebx
  e0:	89 5d 08             	mov    %ebx,0x8(%ebp)
  e3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  e6:	5b                   	pop    %ebx
  e7:	5f                   	pop    %edi
  e8:	5d                   	pop    %ebp
  e9:	c3                   	ret    

000000ea <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  ea:	55                   	push   %ebp
  eb:	89 e5                	mov    %esp,%ebp
  ed:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  f0:	8b 45 08             	mov    0x8(%ebp),%eax
  f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  f6:	90                   	nop
  f7:	8b 45 08             	mov    0x8(%ebp),%eax
  fa:	8d 50 01             	lea    0x1(%eax),%edx
  fd:	89 55 08             	mov    %edx,0x8(%ebp)
 100:	8b 55 0c             	mov    0xc(%ebp),%edx
 103:	8d 4a 01             	lea    0x1(%edx),%ecx
 106:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 109:	0f b6 12             	movzbl (%edx),%edx
 10c:	88 10                	mov    %dl,(%eax)
 10e:	0f b6 00             	movzbl (%eax),%eax
 111:	84 c0                	test   %al,%al
 113:	75 e2                	jne    f7 <strcpy+0xd>
    ;
  return os;
 115:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 118:	c9                   	leave  
 119:	c3                   	ret    

0000011a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11a:	55                   	push   %ebp
 11b:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 11d:	eb 08                	jmp    127 <strcmp+0xd>
    p++, q++;
 11f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 123:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 127:	8b 45 08             	mov    0x8(%ebp),%eax
 12a:	0f b6 00             	movzbl (%eax),%eax
 12d:	84 c0                	test   %al,%al
 12f:	74 10                	je     141 <strcmp+0x27>
 131:	8b 45 08             	mov    0x8(%ebp),%eax
 134:	0f b6 10             	movzbl (%eax),%edx
 137:	8b 45 0c             	mov    0xc(%ebp),%eax
 13a:	0f b6 00             	movzbl (%eax),%eax
 13d:	38 c2                	cmp    %al,%dl
 13f:	74 de                	je     11f <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	0f b6 00             	movzbl (%eax),%eax
 147:	0f b6 d0             	movzbl %al,%edx
 14a:	8b 45 0c             	mov    0xc(%ebp),%eax
 14d:	0f b6 00             	movzbl (%eax),%eax
 150:	0f b6 c0             	movzbl %al,%eax
 153:	29 c2                	sub    %eax,%edx
 155:	89 d0                	mov    %edx,%eax
}
 157:	5d                   	pop    %ebp
 158:	c3                   	ret    

00000159 <strlen>:

uint
strlen(char *s)
{
 159:	55                   	push   %ebp
 15a:	89 e5                	mov    %esp,%ebp
 15c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 15f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 166:	eb 04                	jmp    16c <strlen+0x13>
 168:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 16c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 16f:	8b 45 08             	mov    0x8(%ebp),%eax
 172:	01 d0                	add    %edx,%eax
 174:	0f b6 00             	movzbl (%eax),%eax
 177:	84 c0                	test   %al,%al
 179:	75 ed                	jne    168 <strlen+0xf>
    ;
  return n;
 17b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 17e:	c9                   	leave  
 17f:	c3                   	ret    

00000180 <memset>:

void*
memset(void *dst, int c, uint n)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 186:	8b 45 10             	mov    0x10(%ebp),%eax
 189:	89 44 24 08          	mov    %eax,0x8(%esp)
 18d:	8b 45 0c             	mov    0xc(%ebp),%eax
 190:	89 44 24 04          	mov    %eax,0x4(%esp)
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	89 04 24             	mov    %eax,(%esp)
 19a:	e8 26 ff ff ff       	call   c5 <stosb>
  return dst;
 19f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1a2:	c9                   	leave  
 1a3:	c3                   	ret    

000001a4 <strchr>:

char*
strchr(const char *s, char c)
{
 1a4:	55                   	push   %ebp
 1a5:	89 e5                	mov    %esp,%ebp
 1a7:	83 ec 04             	sub    $0x4,%esp
 1aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ad:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1b0:	eb 14                	jmp    1c6 <strchr+0x22>
    if(*s == c)
 1b2:	8b 45 08             	mov    0x8(%ebp),%eax
 1b5:	0f b6 00             	movzbl (%eax),%eax
 1b8:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1bb:	75 05                	jne    1c2 <strchr+0x1e>
      return (char*)s;
 1bd:	8b 45 08             	mov    0x8(%ebp),%eax
 1c0:	eb 13                	jmp    1d5 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1c6:	8b 45 08             	mov    0x8(%ebp),%eax
 1c9:	0f b6 00             	movzbl (%eax),%eax
 1cc:	84 c0                	test   %al,%al
 1ce:	75 e2                	jne    1b2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1d5:	c9                   	leave  
 1d6:	c3                   	ret    

000001d7 <gets>:

char*
gets(char *buf, int max)
{
 1d7:	55                   	push   %ebp
 1d8:	89 e5                	mov    %esp,%ebp
 1da:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1e4:	eb 4c                	jmp    232 <gets+0x5b>
    cc = read(0, &c, 1);
 1e6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1ed:	00 
 1ee:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1f1:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1fc:	e8 44 01 00 00       	call   345 <read>
 201:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 204:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 208:	7f 02                	jg     20c <gets+0x35>
      break;
 20a:	eb 31                	jmp    23d <gets+0x66>
    buf[i++] = c;
 20c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20f:	8d 50 01             	lea    0x1(%eax),%edx
 212:	89 55 f4             	mov    %edx,-0xc(%ebp)
 215:	89 c2                	mov    %eax,%edx
 217:	8b 45 08             	mov    0x8(%ebp),%eax
 21a:	01 c2                	add    %eax,%edx
 21c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 220:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 222:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 226:	3c 0a                	cmp    $0xa,%al
 228:	74 13                	je     23d <gets+0x66>
 22a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 22e:	3c 0d                	cmp    $0xd,%al
 230:	74 0b                	je     23d <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 232:	8b 45 f4             	mov    -0xc(%ebp),%eax
 235:	83 c0 01             	add    $0x1,%eax
 238:	3b 45 0c             	cmp    0xc(%ebp),%eax
 23b:	7c a9                	jl     1e6 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 23d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 240:	8b 45 08             	mov    0x8(%ebp),%eax
 243:	01 d0                	add    %edx,%eax
 245:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 248:	8b 45 08             	mov    0x8(%ebp),%eax
}
 24b:	c9                   	leave  
 24c:	c3                   	ret    

0000024d <stat>:

int
stat(char *n, struct stat *st)
{
 24d:	55                   	push   %ebp
 24e:	89 e5                	mov    %esp,%ebp
 250:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 253:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 25a:	00 
 25b:	8b 45 08             	mov    0x8(%ebp),%eax
 25e:	89 04 24             	mov    %eax,(%esp)
 261:	e8 07 01 00 00       	call   36d <open>
 266:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 269:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 26d:	79 07                	jns    276 <stat+0x29>
    return -1;
 26f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 274:	eb 23                	jmp    299 <stat+0x4c>
  r = fstat(fd, st);
 276:	8b 45 0c             	mov    0xc(%ebp),%eax
 279:	89 44 24 04          	mov    %eax,0x4(%esp)
 27d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 280:	89 04 24             	mov    %eax,(%esp)
 283:	e8 fd 00 00 00       	call   385 <fstat>
 288:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 28b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28e:	89 04 24             	mov    %eax,(%esp)
 291:	e8 bf 00 00 00       	call   355 <close>
  return r;
 296:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 299:	c9                   	leave  
 29a:	c3                   	ret    

0000029b <atoi>:

int
atoi(const char *s)
{
 29b:	55                   	push   %ebp
 29c:	89 e5                	mov    %esp,%ebp
 29e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2a8:	eb 25                	jmp    2cf <atoi+0x34>
    n = n*10 + *s++ - '0';
 2aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2ad:	89 d0                	mov    %edx,%eax
 2af:	c1 e0 02             	shl    $0x2,%eax
 2b2:	01 d0                	add    %edx,%eax
 2b4:	01 c0                	add    %eax,%eax
 2b6:	89 c1                	mov    %eax,%ecx
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
 2bb:	8d 50 01             	lea    0x1(%eax),%edx
 2be:	89 55 08             	mov    %edx,0x8(%ebp)
 2c1:	0f b6 00             	movzbl (%eax),%eax
 2c4:	0f be c0             	movsbl %al,%eax
 2c7:	01 c8                	add    %ecx,%eax
 2c9:	83 e8 30             	sub    $0x30,%eax
 2cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
 2d2:	0f b6 00             	movzbl (%eax),%eax
 2d5:	3c 2f                	cmp    $0x2f,%al
 2d7:	7e 0a                	jle    2e3 <atoi+0x48>
 2d9:	8b 45 08             	mov    0x8(%ebp),%eax
 2dc:	0f b6 00             	movzbl (%eax),%eax
 2df:	3c 39                	cmp    $0x39,%al
 2e1:	7e c7                	jle    2aa <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2e6:	c9                   	leave  
 2e7:	c3                   	ret    

000002e8 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2e8:	55                   	push   %ebp
 2e9:	89 e5                	mov    %esp,%ebp
 2eb:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2ee:	8b 45 08             	mov    0x8(%ebp),%eax
 2f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2fa:	eb 17                	jmp    313 <memmove+0x2b>
    *dst++ = *src++;
 2fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2ff:	8d 50 01             	lea    0x1(%eax),%edx
 302:	89 55 fc             	mov    %edx,-0x4(%ebp)
 305:	8b 55 f8             	mov    -0x8(%ebp),%edx
 308:	8d 4a 01             	lea    0x1(%edx),%ecx
 30b:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 30e:	0f b6 12             	movzbl (%edx),%edx
 311:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 313:	8b 45 10             	mov    0x10(%ebp),%eax
 316:	8d 50 ff             	lea    -0x1(%eax),%edx
 319:	89 55 10             	mov    %edx,0x10(%ebp)
 31c:	85 c0                	test   %eax,%eax
 31e:	7f dc                	jg     2fc <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 320:	8b 45 08             	mov    0x8(%ebp),%eax
}
 323:	c9                   	leave  
 324:	c3                   	ret    

00000325 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 325:	b8 01 00 00 00       	mov    $0x1,%eax
 32a:	cd 40                	int    $0x40
 32c:	c3                   	ret    

0000032d <exit>:
SYSCALL(exit)
 32d:	b8 02 00 00 00       	mov    $0x2,%eax
 332:	cd 40                	int    $0x40
 334:	c3                   	ret    

00000335 <wait>:
SYSCALL(wait)
 335:	b8 03 00 00 00       	mov    $0x3,%eax
 33a:	cd 40                	int    $0x40
 33c:	c3                   	ret    

0000033d <pipe>:
SYSCALL(pipe)
 33d:	b8 04 00 00 00       	mov    $0x4,%eax
 342:	cd 40                	int    $0x40
 344:	c3                   	ret    

00000345 <read>:
SYSCALL(read)
 345:	b8 05 00 00 00       	mov    $0x5,%eax
 34a:	cd 40                	int    $0x40
 34c:	c3                   	ret    

0000034d <write>:
SYSCALL(write)
 34d:	b8 10 00 00 00       	mov    $0x10,%eax
 352:	cd 40                	int    $0x40
 354:	c3                   	ret    

00000355 <close>:
SYSCALL(close)
 355:	b8 15 00 00 00       	mov    $0x15,%eax
 35a:	cd 40                	int    $0x40
 35c:	c3                   	ret    

0000035d <kill>:
SYSCALL(kill)
 35d:	b8 06 00 00 00       	mov    $0x6,%eax
 362:	cd 40                	int    $0x40
 364:	c3                   	ret    

00000365 <exec>:
SYSCALL(exec)
 365:	b8 07 00 00 00       	mov    $0x7,%eax
 36a:	cd 40                	int    $0x40
 36c:	c3                   	ret    

0000036d <open>:
SYSCALL(open)
 36d:	b8 0f 00 00 00       	mov    $0xf,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <mknod>:
SYSCALL(mknod)
 375:	b8 11 00 00 00       	mov    $0x11,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <unlink>:
SYSCALL(unlink)
 37d:	b8 12 00 00 00       	mov    $0x12,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <fstat>:
SYSCALL(fstat)
 385:	b8 08 00 00 00       	mov    $0x8,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <link>:
SYSCALL(link)
 38d:	b8 13 00 00 00       	mov    $0x13,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <mkdir>:
SYSCALL(mkdir)
 395:	b8 14 00 00 00       	mov    $0x14,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <chdir>:
SYSCALL(chdir)
 39d:	b8 09 00 00 00       	mov    $0x9,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <dup>:
SYSCALL(dup)
 3a5:	b8 0a 00 00 00       	mov    $0xa,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <getpid>:
SYSCALL(getpid)
 3ad:	b8 0b 00 00 00       	mov    $0xb,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <sbrk>:
SYSCALL(sbrk)
 3b5:	b8 0c 00 00 00       	mov    $0xc,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <sleep>:
SYSCALL(sleep)
 3bd:	b8 0d 00 00 00       	mov    $0xd,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <uptime>:
SYSCALL(uptime)
 3c5:	b8 0e 00 00 00       	mov    $0xe,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <kthread_create>:

SYSCALL(kthread_create)
 3cd:	b8 16 00 00 00       	mov    $0x16,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <kthread_id>:
SYSCALL(kthread_id)
 3d5:	b8 17 00 00 00       	mov    $0x17,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <kthread_exit>:
SYSCALL(kthread_exit)
 3dd:	b8 18 00 00 00       	mov    $0x18,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <kthread_join>:
SYSCALL(kthread_join)
 3e5:	b8 19 00 00 00       	mov    $0x19,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3ed:	55                   	push   %ebp
 3ee:	89 e5                	mov    %esp,%ebp
 3f0:	83 ec 18             	sub    $0x18,%esp
 3f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f6:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3f9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 400:	00 
 401:	8d 45 f4             	lea    -0xc(%ebp),%eax
 404:	89 44 24 04          	mov    %eax,0x4(%esp)
 408:	8b 45 08             	mov    0x8(%ebp),%eax
 40b:	89 04 24             	mov    %eax,(%esp)
 40e:	e8 3a ff ff ff       	call   34d <write>
}
 413:	c9                   	leave  
 414:	c3                   	ret    

00000415 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 415:	55                   	push   %ebp
 416:	89 e5                	mov    %esp,%ebp
 418:	56                   	push   %esi
 419:	53                   	push   %ebx
 41a:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 41d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 424:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 428:	74 17                	je     441 <printint+0x2c>
 42a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 42e:	79 11                	jns    441 <printint+0x2c>
    neg = 1;
 430:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 437:	8b 45 0c             	mov    0xc(%ebp),%eax
 43a:	f7 d8                	neg    %eax
 43c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 43f:	eb 06                	jmp    447 <printint+0x32>
  } else {
    x = xx;
 441:	8b 45 0c             	mov    0xc(%ebp),%eax
 444:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 447:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 44e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 451:	8d 41 01             	lea    0x1(%ecx),%eax
 454:	89 45 f4             	mov    %eax,-0xc(%ebp)
 457:	8b 5d 10             	mov    0x10(%ebp),%ebx
 45a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 45d:	ba 00 00 00 00       	mov    $0x0,%edx
 462:	f7 f3                	div    %ebx
 464:	89 d0                	mov    %edx,%eax
 466:	0f b6 80 28 0b 00 00 	movzbl 0xb28(%eax),%eax
 46d:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 471:	8b 75 10             	mov    0x10(%ebp),%esi
 474:	8b 45 ec             	mov    -0x14(%ebp),%eax
 477:	ba 00 00 00 00       	mov    $0x0,%edx
 47c:	f7 f6                	div    %esi
 47e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 481:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 485:	75 c7                	jne    44e <printint+0x39>
  if(neg)
 487:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 48b:	74 10                	je     49d <printint+0x88>
    buf[i++] = '-';
 48d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 490:	8d 50 01             	lea    0x1(%eax),%edx
 493:	89 55 f4             	mov    %edx,-0xc(%ebp)
 496:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 49b:	eb 1f                	jmp    4bc <printint+0xa7>
 49d:	eb 1d                	jmp    4bc <printint+0xa7>
    putc(fd, buf[i]);
 49f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a5:	01 d0                	add    %edx,%eax
 4a7:	0f b6 00             	movzbl (%eax),%eax
 4aa:	0f be c0             	movsbl %al,%eax
 4ad:	89 44 24 04          	mov    %eax,0x4(%esp)
 4b1:	8b 45 08             	mov    0x8(%ebp),%eax
 4b4:	89 04 24             	mov    %eax,(%esp)
 4b7:	e8 31 ff ff ff       	call   3ed <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4bc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4c4:	79 d9                	jns    49f <printint+0x8a>
    putc(fd, buf[i]);
}
 4c6:	83 c4 30             	add    $0x30,%esp
 4c9:	5b                   	pop    %ebx
 4ca:	5e                   	pop    %esi
 4cb:	5d                   	pop    %ebp
 4cc:	c3                   	ret    

000004cd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4cd:	55                   	push   %ebp
 4ce:	89 e5                	mov    %esp,%ebp
 4d0:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4d3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4da:	8d 45 0c             	lea    0xc(%ebp),%eax
 4dd:	83 c0 04             	add    $0x4,%eax
 4e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4ea:	e9 7c 01 00 00       	jmp    66b <printf+0x19e>
    c = fmt[i] & 0xff;
 4ef:	8b 55 0c             	mov    0xc(%ebp),%edx
 4f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4f5:	01 d0                	add    %edx,%eax
 4f7:	0f b6 00             	movzbl (%eax),%eax
 4fa:	0f be c0             	movsbl %al,%eax
 4fd:	25 ff 00 00 00       	and    $0xff,%eax
 502:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 505:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 509:	75 2c                	jne    537 <printf+0x6a>
      if(c == '%'){
 50b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 50f:	75 0c                	jne    51d <printf+0x50>
        state = '%';
 511:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 518:	e9 4a 01 00 00       	jmp    667 <printf+0x19a>
      } else {
        putc(fd, c);
 51d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 520:	0f be c0             	movsbl %al,%eax
 523:	89 44 24 04          	mov    %eax,0x4(%esp)
 527:	8b 45 08             	mov    0x8(%ebp),%eax
 52a:	89 04 24             	mov    %eax,(%esp)
 52d:	e8 bb fe ff ff       	call   3ed <putc>
 532:	e9 30 01 00 00       	jmp    667 <printf+0x19a>
      }
    } else if(state == '%'){
 537:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 53b:	0f 85 26 01 00 00    	jne    667 <printf+0x19a>
      if(c == 'd'){
 541:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 545:	75 2d                	jne    574 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 547:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54a:	8b 00                	mov    (%eax),%eax
 54c:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 553:	00 
 554:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 55b:	00 
 55c:	89 44 24 04          	mov    %eax,0x4(%esp)
 560:	8b 45 08             	mov    0x8(%ebp),%eax
 563:	89 04 24             	mov    %eax,(%esp)
 566:	e8 aa fe ff ff       	call   415 <printint>
        ap++;
 56b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 56f:	e9 ec 00 00 00       	jmp    660 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 574:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 578:	74 06                	je     580 <printf+0xb3>
 57a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 57e:	75 2d                	jne    5ad <printf+0xe0>
        printint(fd, *ap, 16, 0);
 580:	8b 45 e8             	mov    -0x18(%ebp),%eax
 583:	8b 00                	mov    (%eax),%eax
 585:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 58c:	00 
 58d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 594:	00 
 595:	89 44 24 04          	mov    %eax,0x4(%esp)
 599:	8b 45 08             	mov    0x8(%ebp),%eax
 59c:	89 04 24             	mov    %eax,(%esp)
 59f:	e8 71 fe ff ff       	call   415 <printint>
        ap++;
 5a4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a8:	e9 b3 00 00 00       	jmp    660 <printf+0x193>
      } else if(c == 's'){
 5ad:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5b1:	75 45                	jne    5f8 <printf+0x12b>
        s = (char*)*ap;
 5b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b6:	8b 00                	mov    (%eax),%eax
 5b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5bb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c3:	75 09                	jne    5ce <printf+0x101>
          s = "(null)";
 5c5:	c7 45 f4 b7 08 00 00 	movl   $0x8b7,-0xc(%ebp)
        while(*s != 0){
 5cc:	eb 1e                	jmp    5ec <printf+0x11f>
 5ce:	eb 1c                	jmp    5ec <printf+0x11f>
          putc(fd, *s);
 5d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d3:	0f b6 00             	movzbl (%eax),%eax
 5d6:	0f be c0             	movsbl %al,%eax
 5d9:	89 44 24 04          	mov    %eax,0x4(%esp)
 5dd:	8b 45 08             	mov    0x8(%ebp),%eax
 5e0:	89 04 24             	mov    %eax,(%esp)
 5e3:	e8 05 fe ff ff       	call   3ed <putc>
          s++;
 5e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ef:	0f b6 00             	movzbl (%eax),%eax
 5f2:	84 c0                	test   %al,%al
 5f4:	75 da                	jne    5d0 <printf+0x103>
 5f6:	eb 68                	jmp    660 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5f8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5fc:	75 1d                	jne    61b <printf+0x14e>
        putc(fd, *ap);
 5fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
 601:	8b 00                	mov    (%eax),%eax
 603:	0f be c0             	movsbl %al,%eax
 606:	89 44 24 04          	mov    %eax,0x4(%esp)
 60a:	8b 45 08             	mov    0x8(%ebp),%eax
 60d:	89 04 24             	mov    %eax,(%esp)
 610:	e8 d8 fd ff ff       	call   3ed <putc>
        ap++;
 615:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 619:	eb 45                	jmp    660 <printf+0x193>
      } else if(c == '%'){
 61b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 61f:	75 17                	jne    638 <printf+0x16b>
        putc(fd, c);
 621:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 624:	0f be c0             	movsbl %al,%eax
 627:	89 44 24 04          	mov    %eax,0x4(%esp)
 62b:	8b 45 08             	mov    0x8(%ebp),%eax
 62e:	89 04 24             	mov    %eax,(%esp)
 631:	e8 b7 fd ff ff       	call   3ed <putc>
 636:	eb 28                	jmp    660 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 638:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 63f:	00 
 640:	8b 45 08             	mov    0x8(%ebp),%eax
 643:	89 04 24             	mov    %eax,(%esp)
 646:	e8 a2 fd ff ff       	call   3ed <putc>
        putc(fd, c);
 64b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64e:	0f be c0             	movsbl %al,%eax
 651:	89 44 24 04          	mov    %eax,0x4(%esp)
 655:	8b 45 08             	mov    0x8(%ebp),%eax
 658:	89 04 24             	mov    %eax,(%esp)
 65b:	e8 8d fd ff ff       	call   3ed <putc>
      }
      state = 0;
 660:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 667:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 66b:	8b 55 0c             	mov    0xc(%ebp),%edx
 66e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 671:	01 d0                	add    %edx,%eax
 673:	0f b6 00             	movzbl (%eax),%eax
 676:	84 c0                	test   %al,%al
 678:	0f 85 71 fe ff ff    	jne    4ef <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 67e:	c9                   	leave  
 67f:	c3                   	ret    

00000680 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 680:	55                   	push   %ebp
 681:	89 e5                	mov    %esp,%ebp
 683:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 686:	8b 45 08             	mov    0x8(%ebp),%eax
 689:	83 e8 08             	sub    $0x8,%eax
 68c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68f:	a1 48 0b 00 00       	mov    0xb48,%eax
 694:	89 45 fc             	mov    %eax,-0x4(%ebp)
 697:	eb 24                	jmp    6bd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	8b 00                	mov    (%eax),%eax
 69e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a1:	77 12                	ja     6b5 <free+0x35>
 6a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a9:	77 24                	ja     6cf <free+0x4f>
 6ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ae:	8b 00                	mov    (%eax),%eax
 6b0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6b3:	77 1a                	ja     6cf <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b8:	8b 00                	mov    (%eax),%eax
 6ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c3:	76 d4                	jbe    699 <free+0x19>
 6c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c8:	8b 00                	mov    (%eax),%eax
 6ca:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6cd:	76 ca                	jbe    699 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d2:	8b 40 04             	mov    0x4(%eax),%eax
 6d5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6df:	01 c2                	add    %eax,%edx
 6e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e4:	8b 00                	mov    (%eax),%eax
 6e6:	39 c2                	cmp    %eax,%edx
 6e8:	75 24                	jne    70e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ed:	8b 50 04             	mov    0x4(%eax),%edx
 6f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f3:	8b 00                	mov    (%eax),%eax
 6f5:	8b 40 04             	mov    0x4(%eax),%eax
 6f8:	01 c2                	add    %eax,%edx
 6fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 700:	8b 45 fc             	mov    -0x4(%ebp),%eax
 703:	8b 00                	mov    (%eax),%eax
 705:	8b 10                	mov    (%eax),%edx
 707:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70a:	89 10                	mov    %edx,(%eax)
 70c:	eb 0a                	jmp    718 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 70e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 711:	8b 10                	mov    (%eax),%edx
 713:	8b 45 f8             	mov    -0x8(%ebp),%eax
 716:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 718:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71b:	8b 40 04             	mov    0x4(%eax),%eax
 71e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 725:	8b 45 fc             	mov    -0x4(%ebp),%eax
 728:	01 d0                	add    %edx,%eax
 72a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 72d:	75 20                	jne    74f <free+0xcf>
    p->s.size += bp->s.size;
 72f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 732:	8b 50 04             	mov    0x4(%eax),%edx
 735:	8b 45 f8             	mov    -0x8(%ebp),%eax
 738:	8b 40 04             	mov    0x4(%eax),%eax
 73b:	01 c2                	add    %eax,%edx
 73d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 740:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 743:	8b 45 f8             	mov    -0x8(%ebp),%eax
 746:	8b 10                	mov    (%eax),%edx
 748:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74b:	89 10                	mov    %edx,(%eax)
 74d:	eb 08                	jmp    757 <free+0xd7>
  } else
    p->s.ptr = bp;
 74f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 752:	8b 55 f8             	mov    -0x8(%ebp),%edx
 755:	89 10                	mov    %edx,(%eax)
  freep = p;
 757:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75a:	a3 48 0b 00 00       	mov    %eax,0xb48
}
 75f:	c9                   	leave  
 760:	c3                   	ret    

00000761 <morecore>:

static Header*
morecore(uint nu)
{
 761:	55                   	push   %ebp
 762:	89 e5                	mov    %esp,%ebp
 764:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 767:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 76e:	77 07                	ja     777 <morecore+0x16>
    nu = 4096;
 770:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 777:	8b 45 08             	mov    0x8(%ebp),%eax
 77a:	c1 e0 03             	shl    $0x3,%eax
 77d:	89 04 24             	mov    %eax,(%esp)
 780:	e8 30 fc ff ff       	call   3b5 <sbrk>
 785:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 788:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 78c:	75 07                	jne    795 <morecore+0x34>
    return 0;
 78e:	b8 00 00 00 00       	mov    $0x0,%eax
 793:	eb 22                	jmp    7b7 <morecore+0x56>
  hp = (Header*)p;
 795:	8b 45 f4             	mov    -0xc(%ebp),%eax
 798:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 79b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79e:	8b 55 08             	mov    0x8(%ebp),%edx
 7a1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a7:	83 c0 08             	add    $0x8,%eax
 7aa:	89 04 24             	mov    %eax,(%esp)
 7ad:	e8 ce fe ff ff       	call   680 <free>
  return freep;
 7b2:	a1 48 0b 00 00       	mov    0xb48,%eax
}
 7b7:	c9                   	leave  
 7b8:	c3                   	ret    

000007b9 <malloc>:

void*
malloc(uint nbytes)
{
 7b9:	55                   	push   %ebp
 7ba:	89 e5                	mov    %esp,%ebp
 7bc:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7bf:	8b 45 08             	mov    0x8(%ebp),%eax
 7c2:	83 c0 07             	add    $0x7,%eax
 7c5:	c1 e8 03             	shr    $0x3,%eax
 7c8:	83 c0 01             	add    $0x1,%eax
 7cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7ce:	a1 48 0b 00 00       	mov    0xb48,%eax
 7d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7da:	75 23                	jne    7ff <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7dc:	c7 45 f0 40 0b 00 00 	movl   $0xb40,-0x10(%ebp)
 7e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e6:	a3 48 0b 00 00       	mov    %eax,0xb48
 7eb:	a1 48 0b 00 00       	mov    0xb48,%eax
 7f0:	a3 40 0b 00 00       	mov    %eax,0xb40
    base.s.size = 0;
 7f5:	c7 05 44 0b 00 00 00 	movl   $0x0,0xb44
 7fc:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 802:	8b 00                	mov    (%eax),%eax
 804:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 807:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80a:	8b 40 04             	mov    0x4(%eax),%eax
 80d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 810:	72 4d                	jb     85f <malloc+0xa6>
      if(p->s.size == nunits)
 812:	8b 45 f4             	mov    -0xc(%ebp),%eax
 815:	8b 40 04             	mov    0x4(%eax),%eax
 818:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 81b:	75 0c                	jne    829 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 81d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 820:	8b 10                	mov    (%eax),%edx
 822:	8b 45 f0             	mov    -0x10(%ebp),%eax
 825:	89 10                	mov    %edx,(%eax)
 827:	eb 26                	jmp    84f <malloc+0x96>
      else {
        p->s.size -= nunits;
 829:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82c:	8b 40 04             	mov    0x4(%eax),%eax
 82f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 832:	89 c2                	mov    %eax,%edx
 834:	8b 45 f4             	mov    -0xc(%ebp),%eax
 837:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 83a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83d:	8b 40 04             	mov    0x4(%eax),%eax
 840:	c1 e0 03             	shl    $0x3,%eax
 843:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 846:	8b 45 f4             	mov    -0xc(%ebp),%eax
 849:	8b 55 ec             	mov    -0x14(%ebp),%edx
 84c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 84f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 852:	a3 48 0b 00 00       	mov    %eax,0xb48
      return (void*)(p + 1);
 857:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85a:	83 c0 08             	add    $0x8,%eax
 85d:	eb 38                	jmp    897 <malloc+0xde>
    }
    if(p == freep)
 85f:	a1 48 0b 00 00       	mov    0xb48,%eax
 864:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 867:	75 1b                	jne    884 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 869:	8b 45 ec             	mov    -0x14(%ebp),%eax
 86c:	89 04 24             	mov    %eax,(%esp)
 86f:	e8 ed fe ff ff       	call   761 <morecore>
 874:	89 45 f4             	mov    %eax,-0xc(%ebp)
 877:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 87b:	75 07                	jne    884 <malloc+0xcb>
        return 0;
 87d:	b8 00 00 00 00       	mov    $0x0,%eax
 882:	eb 13                	jmp    897 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 884:	8b 45 f4             	mov    -0xc(%ebp),%eax
 887:	89 45 f0             	mov    %eax,-0x10(%ebp)
 88a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88d:	8b 00                	mov    (%eax),%eax
 88f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 892:	e9 70 ff ff ff       	jmp    807 <malloc+0x4e>
}
 897:	c9                   	leave  
 898:	c3                   	ret    
