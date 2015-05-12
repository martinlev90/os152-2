
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

int i=0;

void* testfunc();

int main(){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp


	void * stack0 = malloc(MAX_STACK_SIZE);
   9:	c7 04 24 a0 0f 00 00 	movl   $0xfa0,(%esp)
  10:	e8 6f 07 00 00       	call   784 <malloc>
  15:	89 44 24 1c          	mov    %eax,0x1c(%esp)

	//int tid=
	kthread_create( testfunc, stack0, MAX_STACK_SIZE);
  19:	c7 44 24 08 a0 0f 00 	movl   $0xfa0,0x8(%esp)
  20:	00 
  21:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  25:	89 44 24 04          	mov    %eax,0x4(%esp)
  29:	c7 04 24 41 00 00 00 	movl   $0x41,(%esp)
  30:	e8 63 03 00 00       	call   398 <kthread_create>




	//for(;;);
	kthread_exit();
  35:	e8 6e 03 00 00       	call   3a8 <kthread_exit>
	return 0;
  3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  3f:	c9                   	leave  
  40:	c3                   	ret    

00000041 <testfunc>:


void* testfunc(){
  41:	55                   	push   %ebp
  42:	89 e5                	mov    %esp,%ebp
  44:	83 ec 28             	sub    $0x28,%esp

	int k;
	for (k=0; k<10; k++){
  47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4e:	eb 2e                	jmp    7e <testfunc+0x3d>

	printf(1, "thread is alive %d\n", ++i);
  50:	a1 fc 0a 00 00       	mov    0xafc,%eax
  55:	83 c0 01             	add    $0x1,%eax
  58:	a3 fc 0a 00 00       	mov    %eax,0xafc
  5d:	a1 fc 0a 00 00       	mov    0xafc,%eax
  62:	89 44 24 08          	mov    %eax,0x8(%esp)
  66:	c7 44 24 04 64 08 00 	movl   $0x864,0x4(%esp)
  6d:	00 
  6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  75:	e8 1e 04 00 00       	call   498 <printf>


void* testfunc(){

	int k;
	for (k=0; k<10; k++){
  7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  7e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  82:	7e cc                	jle    50 <testfunc+0xf>
	printf(1, "thread is alive %d\n", ++i);
	}



	kthread_exit();
  84:	e8 1f 03 00 00       	call   3a8 <kthread_exit>
	return 0;
  89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8e:	c9                   	leave  
  8f:	c3                   	ret    

00000090 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  90:	55                   	push   %ebp
  91:	89 e5                	mov    %esp,%ebp
  93:	57                   	push   %edi
  94:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  98:	8b 55 10             	mov    0x10(%ebp),%edx
  9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  9e:	89 cb                	mov    %ecx,%ebx
  a0:	89 df                	mov    %ebx,%edi
  a2:	89 d1                	mov    %edx,%ecx
  a4:	fc                   	cld    
  a5:	f3 aa                	rep stos %al,%es:(%edi)
  a7:	89 ca                	mov    %ecx,%edx
  a9:	89 fb                	mov    %edi,%ebx
  ab:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ae:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  b1:	5b                   	pop    %ebx
  b2:	5f                   	pop    %edi
  b3:	5d                   	pop    %ebp
  b4:	c3                   	ret    

000000b5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  b5:	55                   	push   %ebp
  b6:	89 e5                	mov    %esp,%ebp
  b8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  bb:	8b 45 08             	mov    0x8(%ebp),%eax
  be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  c1:	90                   	nop
  c2:	8b 45 08             	mov    0x8(%ebp),%eax
  c5:	8d 50 01             	lea    0x1(%eax),%edx
  c8:	89 55 08             	mov    %edx,0x8(%ebp)
  cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  ce:	8d 4a 01             	lea    0x1(%edx),%ecx
  d1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  d4:	0f b6 12             	movzbl (%edx),%edx
  d7:	88 10                	mov    %dl,(%eax)
  d9:	0f b6 00             	movzbl (%eax),%eax
  dc:	84 c0                	test   %al,%al
  de:	75 e2                	jne    c2 <strcpy+0xd>
    ;
  return os;
  e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e3:	c9                   	leave  
  e4:	c3                   	ret    

000000e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e5:	55                   	push   %ebp
  e6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  e8:	eb 08                	jmp    f2 <strcmp+0xd>
    p++, q++;
  ea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  ee:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  f2:	8b 45 08             	mov    0x8(%ebp),%eax
  f5:	0f b6 00             	movzbl (%eax),%eax
  f8:	84 c0                	test   %al,%al
  fa:	74 10                	je     10c <strcmp+0x27>
  fc:	8b 45 08             	mov    0x8(%ebp),%eax
  ff:	0f b6 10             	movzbl (%eax),%edx
 102:	8b 45 0c             	mov    0xc(%ebp),%eax
 105:	0f b6 00             	movzbl (%eax),%eax
 108:	38 c2                	cmp    %al,%dl
 10a:	74 de                	je     ea <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 10c:	8b 45 08             	mov    0x8(%ebp),%eax
 10f:	0f b6 00             	movzbl (%eax),%eax
 112:	0f b6 d0             	movzbl %al,%edx
 115:	8b 45 0c             	mov    0xc(%ebp),%eax
 118:	0f b6 00             	movzbl (%eax),%eax
 11b:	0f b6 c0             	movzbl %al,%eax
 11e:	29 c2                	sub    %eax,%edx
 120:	89 d0                	mov    %edx,%eax
}
 122:	5d                   	pop    %ebp
 123:	c3                   	ret    

00000124 <strlen>:

uint
strlen(char *s)
{
 124:	55                   	push   %ebp
 125:	89 e5                	mov    %esp,%ebp
 127:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 12a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 131:	eb 04                	jmp    137 <strlen+0x13>
 133:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 137:	8b 55 fc             	mov    -0x4(%ebp),%edx
 13a:	8b 45 08             	mov    0x8(%ebp),%eax
 13d:	01 d0                	add    %edx,%eax
 13f:	0f b6 00             	movzbl (%eax),%eax
 142:	84 c0                	test   %al,%al
 144:	75 ed                	jne    133 <strlen+0xf>
    ;
  return n;
 146:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 149:	c9                   	leave  
 14a:	c3                   	ret    

0000014b <memset>:

void*
memset(void *dst, int c, uint n)
{
 14b:	55                   	push   %ebp
 14c:	89 e5                	mov    %esp,%ebp
 14e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 151:	8b 45 10             	mov    0x10(%ebp),%eax
 154:	89 44 24 08          	mov    %eax,0x8(%esp)
 158:	8b 45 0c             	mov    0xc(%ebp),%eax
 15b:	89 44 24 04          	mov    %eax,0x4(%esp)
 15f:	8b 45 08             	mov    0x8(%ebp),%eax
 162:	89 04 24             	mov    %eax,(%esp)
 165:	e8 26 ff ff ff       	call   90 <stosb>
  return dst;
 16a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 16d:	c9                   	leave  
 16e:	c3                   	ret    

0000016f <strchr>:

char*
strchr(const char *s, char c)
{
 16f:	55                   	push   %ebp
 170:	89 e5                	mov    %esp,%ebp
 172:	83 ec 04             	sub    $0x4,%esp
 175:	8b 45 0c             	mov    0xc(%ebp),%eax
 178:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 17b:	eb 14                	jmp    191 <strchr+0x22>
    if(*s == c)
 17d:	8b 45 08             	mov    0x8(%ebp),%eax
 180:	0f b6 00             	movzbl (%eax),%eax
 183:	3a 45 fc             	cmp    -0x4(%ebp),%al
 186:	75 05                	jne    18d <strchr+0x1e>
      return (char*)s;
 188:	8b 45 08             	mov    0x8(%ebp),%eax
 18b:	eb 13                	jmp    1a0 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 18d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 191:	8b 45 08             	mov    0x8(%ebp),%eax
 194:	0f b6 00             	movzbl (%eax),%eax
 197:	84 c0                	test   %al,%al
 199:	75 e2                	jne    17d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 19b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a0:	c9                   	leave  
 1a1:	c3                   	ret    

000001a2 <gets>:

char*
gets(char *buf, int max)
{
 1a2:	55                   	push   %ebp
 1a3:	89 e5                	mov    %esp,%ebp
 1a5:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1af:	eb 4c                	jmp    1fd <gets+0x5b>
    cc = read(0, &c, 1);
 1b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1b8:	00 
 1b9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1c7:	e8 44 01 00 00       	call   310 <read>
 1cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1d3:	7f 02                	jg     1d7 <gets+0x35>
      break;
 1d5:	eb 31                	jmp    208 <gets+0x66>
    buf[i++] = c;
 1d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1da:	8d 50 01             	lea    0x1(%eax),%edx
 1dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1e0:	89 c2                	mov    %eax,%edx
 1e2:	8b 45 08             	mov    0x8(%ebp),%eax
 1e5:	01 c2                	add    %eax,%edx
 1e7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1eb:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1ed:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f1:	3c 0a                	cmp    $0xa,%al
 1f3:	74 13                	je     208 <gets+0x66>
 1f5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f9:	3c 0d                	cmp    $0xd,%al
 1fb:	74 0b                	je     208 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 200:	83 c0 01             	add    $0x1,%eax
 203:	3b 45 0c             	cmp    0xc(%ebp),%eax
 206:	7c a9                	jl     1b1 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 208:	8b 55 f4             	mov    -0xc(%ebp),%edx
 20b:	8b 45 08             	mov    0x8(%ebp),%eax
 20e:	01 d0                	add    %edx,%eax
 210:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 213:	8b 45 08             	mov    0x8(%ebp),%eax
}
 216:	c9                   	leave  
 217:	c3                   	ret    

00000218 <stat>:

int
stat(char *n, struct stat *st)
{
 218:	55                   	push   %ebp
 219:	89 e5                	mov    %esp,%ebp
 21b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 225:	00 
 226:	8b 45 08             	mov    0x8(%ebp),%eax
 229:	89 04 24             	mov    %eax,(%esp)
 22c:	e8 07 01 00 00       	call   338 <open>
 231:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 234:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 238:	79 07                	jns    241 <stat+0x29>
    return -1;
 23a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 23f:	eb 23                	jmp    264 <stat+0x4c>
  r = fstat(fd, st);
 241:	8b 45 0c             	mov    0xc(%ebp),%eax
 244:	89 44 24 04          	mov    %eax,0x4(%esp)
 248:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24b:	89 04 24             	mov    %eax,(%esp)
 24e:	e8 fd 00 00 00       	call   350 <fstat>
 253:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 256:	8b 45 f4             	mov    -0xc(%ebp),%eax
 259:	89 04 24             	mov    %eax,(%esp)
 25c:	e8 bf 00 00 00       	call   320 <close>
  return r;
 261:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 264:	c9                   	leave  
 265:	c3                   	ret    

00000266 <atoi>:

int
atoi(const char *s)
{
 266:	55                   	push   %ebp
 267:	89 e5                	mov    %esp,%ebp
 269:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 26c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 273:	eb 25                	jmp    29a <atoi+0x34>
    n = n*10 + *s++ - '0';
 275:	8b 55 fc             	mov    -0x4(%ebp),%edx
 278:	89 d0                	mov    %edx,%eax
 27a:	c1 e0 02             	shl    $0x2,%eax
 27d:	01 d0                	add    %edx,%eax
 27f:	01 c0                	add    %eax,%eax
 281:	89 c1                	mov    %eax,%ecx
 283:	8b 45 08             	mov    0x8(%ebp),%eax
 286:	8d 50 01             	lea    0x1(%eax),%edx
 289:	89 55 08             	mov    %edx,0x8(%ebp)
 28c:	0f b6 00             	movzbl (%eax),%eax
 28f:	0f be c0             	movsbl %al,%eax
 292:	01 c8                	add    %ecx,%eax
 294:	83 e8 30             	sub    $0x30,%eax
 297:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
 29d:	0f b6 00             	movzbl (%eax),%eax
 2a0:	3c 2f                	cmp    $0x2f,%al
 2a2:	7e 0a                	jle    2ae <atoi+0x48>
 2a4:	8b 45 08             	mov    0x8(%ebp),%eax
 2a7:	0f b6 00             	movzbl (%eax),%eax
 2aa:	3c 39                	cmp    $0x39,%al
 2ac:	7e c7                	jle    275 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2b1:	c9                   	leave  
 2b2:	c3                   	ret    

000002b3 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2b3:	55                   	push   %ebp
 2b4:	89 e5                	mov    %esp,%ebp
 2b6:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2b9:	8b 45 08             	mov    0x8(%ebp),%eax
 2bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2c5:	eb 17                	jmp    2de <memmove+0x2b>
    *dst++ = *src++;
 2c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2ca:	8d 50 01             	lea    0x1(%eax),%edx
 2cd:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2d0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2d3:	8d 4a 01             	lea    0x1(%edx),%ecx
 2d6:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2d9:	0f b6 12             	movzbl (%edx),%edx
 2dc:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2de:	8b 45 10             	mov    0x10(%ebp),%eax
 2e1:	8d 50 ff             	lea    -0x1(%eax),%edx
 2e4:	89 55 10             	mov    %edx,0x10(%ebp)
 2e7:	85 c0                	test   %eax,%eax
 2e9:	7f dc                	jg     2c7 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ee:	c9                   	leave  
 2ef:	c3                   	ret    

000002f0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2f0:	b8 01 00 00 00       	mov    $0x1,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <exit>:
SYSCALL(exit)
 2f8:	b8 02 00 00 00       	mov    $0x2,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <wait>:
SYSCALL(wait)
 300:	b8 03 00 00 00       	mov    $0x3,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <pipe>:
SYSCALL(pipe)
 308:	b8 04 00 00 00       	mov    $0x4,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <read>:
SYSCALL(read)
 310:	b8 05 00 00 00       	mov    $0x5,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <write>:
SYSCALL(write)
 318:	b8 10 00 00 00       	mov    $0x10,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <close>:
SYSCALL(close)
 320:	b8 15 00 00 00       	mov    $0x15,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <kill>:
SYSCALL(kill)
 328:	b8 06 00 00 00       	mov    $0x6,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <exec>:
SYSCALL(exec)
 330:	b8 07 00 00 00       	mov    $0x7,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <open>:
SYSCALL(open)
 338:	b8 0f 00 00 00       	mov    $0xf,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <mknod>:
SYSCALL(mknod)
 340:	b8 11 00 00 00       	mov    $0x11,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <unlink>:
SYSCALL(unlink)
 348:	b8 12 00 00 00       	mov    $0x12,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <fstat>:
SYSCALL(fstat)
 350:	b8 08 00 00 00       	mov    $0x8,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <link>:
SYSCALL(link)
 358:	b8 13 00 00 00       	mov    $0x13,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <mkdir>:
SYSCALL(mkdir)
 360:	b8 14 00 00 00       	mov    $0x14,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <chdir>:
SYSCALL(chdir)
 368:	b8 09 00 00 00       	mov    $0x9,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <dup>:
SYSCALL(dup)
 370:	b8 0a 00 00 00       	mov    $0xa,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <getpid>:
SYSCALL(getpid)
 378:	b8 0b 00 00 00       	mov    $0xb,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <sbrk>:
SYSCALL(sbrk)
 380:	b8 0c 00 00 00       	mov    $0xc,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <sleep>:
SYSCALL(sleep)
 388:	b8 0d 00 00 00       	mov    $0xd,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <uptime>:
SYSCALL(uptime)
 390:	b8 0e 00 00 00       	mov    $0xe,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <kthread_create>:

SYSCALL(kthread_create)
 398:	b8 16 00 00 00       	mov    $0x16,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <kthread_id>:
SYSCALL(kthread_id)
 3a0:	b8 17 00 00 00       	mov    $0x17,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <kthread_exit>:
SYSCALL(kthread_exit)
 3a8:	b8 18 00 00 00       	mov    $0x18,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <kthread_join>:
SYSCALL(kthread_join)
 3b0:	b8 19 00 00 00       	mov    $0x19,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b8:	55                   	push   %ebp
 3b9:	89 e5                	mov    %esp,%ebp
 3bb:	83 ec 18             	sub    $0x18,%esp
 3be:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3c4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3cb:	00 
 3cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	89 04 24             	mov    %eax,(%esp)
 3d9:	e8 3a ff ff ff       	call   318 <write>
}
 3de:	c9                   	leave  
 3df:	c3                   	ret    

000003e0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	56                   	push   %esi
 3e4:	53                   	push   %ebx
 3e5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3ef:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3f3:	74 17                	je     40c <printint+0x2c>
 3f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3f9:	79 11                	jns    40c <printint+0x2c>
    neg = 1;
 3fb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 402:	8b 45 0c             	mov    0xc(%ebp),%eax
 405:	f7 d8                	neg    %eax
 407:	89 45 ec             	mov    %eax,-0x14(%ebp)
 40a:	eb 06                	jmp    412 <printint+0x32>
  } else {
    x = xx;
 40c:	8b 45 0c             	mov    0xc(%ebp),%eax
 40f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 412:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 419:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 41c:	8d 41 01             	lea    0x1(%ecx),%eax
 41f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 422:	8b 5d 10             	mov    0x10(%ebp),%ebx
 425:	8b 45 ec             	mov    -0x14(%ebp),%eax
 428:	ba 00 00 00 00       	mov    $0x0,%edx
 42d:	f7 f3                	div    %ebx
 42f:	89 d0                	mov    %edx,%eax
 431:	0f b6 80 e8 0a 00 00 	movzbl 0xae8(%eax),%eax
 438:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 43c:	8b 75 10             	mov    0x10(%ebp),%esi
 43f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 442:	ba 00 00 00 00       	mov    $0x0,%edx
 447:	f7 f6                	div    %esi
 449:	89 45 ec             	mov    %eax,-0x14(%ebp)
 44c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 450:	75 c7                	jne    419 <printint+0x39>
  if(neg)
 452:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 456:	74 10                	je     468 <printint+0x88>
    buf[i++] = '-';
 458:	8b 45 f4             	mov    -0xc(%ebp),%eax
 45b:	8d 50 01             	lea    0x1(%eax),%edx
 45e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 461:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 466:	eb 1f                	jmp    487 <printint+0xa7>
 468:	eb 1d                	jmp    487 <printint+0xa7>
    putc(fd, buf[i]);
 46a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 46d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 470:	01 d0                	add    %edx,%eax
 472:	0f b6 00             	movzbl (%eax),%eax
 475:	0f be c0             	movsbl %al,%eax
 478:	89 44 24 04          	mov    %eax,0x4(%esp)
 47c:	8b 45 08             	mov    0x8(%ebp),%eax
 47f:	89 04 24             	mov    %eax,(%esp)
 482:	e8 31 ff ff ff       	call   3b8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 487:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 48b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 48f:	79 d9                	jns    46a <printint+0x8a>
    putc(fd, buf[i]);
}
 491:	83 c4 30             	add    $0x30,%esp
 494:	5b                   	pop    %ebx
 495:	5e                   	pop    %esi
 496:	5d                   	pop    %ebp
 497:	c3                   	ret    

00000498 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 498:	55                   	push   %ebp
 499:	89 e5                	mov    %esp,%ebp
 49b:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 49e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4a5:	8d 45 0c             	lea    0xc(%ebp),%eax
 4a8:	83 c0 04             	add    $0x4,%eax
 4ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4ae:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4b5:	e9 7c 01 00 00       	jmp    636 <printf+0x19e>
    c = fmt[i] & 0xff;
 4ba:	8b 55 0c             	mov    0xc(%ebp),%edx
 4bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4c0:	01 d0                	add    %edx,%eax
 4c2:	0f b6 00             	movzbl (%eax),%eax
 4c5:	0f be c0             	movsbl %al,%eax
 4c8:	25 ff 00 00 00       	and    $0xff,%eax
 4cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4d0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4d4:	75 2c                	jne    502 <printf+0x6a>
      if(c == '%'){
 4d6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4da:	75 0c                	jne    4e8 <printf+0x50>
        state = '%';
 4dc:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4e3:	e9 4a 01 00 00       	jmp    632 <printf+0x19a>
      } else {
        putc(fd, c);
 4e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4eb:	0f be c0             	movsbl %al,%eax
 4ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f2:	8b 45 08             	mov    0x8(%ebp),%eax
 4f5:	89 04 24             	mov    %eax,(%esp)
 4f8:	e8 bb fe ff ff       	call   3b8 <putc>
 4fd:	e9 30 01 00 00       	jmp    632 <printf+0x19a>
      }
    } else if(state == '%'){
 502:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 506:	0f 85 26 01 00 00    	jne    632 <printf+0x19a>
      if(c == 'd'){
 50c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 510:	75 2d                	jne    53f <printf+0xa7>
        printint(fd, *ap, 10, 1);
 512:	8b 45 e8             	mov    -0x18(%ebp),%eax
 515:	8b 00                	mov    (%eax),%eax
 517:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 51e:	00 
 51f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 526:	00 
 527:	89 44 24 04          	mov    %eax,0x4(%esp)
 52b:	8b 45 08             	mov    0x8(%ebp),%eax
 52e:	89 04 24             	mov    %eax,(%esp)
 531:	e8 aa fe ff ff       	call   3e0 <printint>
        ap++;
 536:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 53a:	e9 ec 00 00 00       	jmp    62b <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 53f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 543:	74 06                	je     54b <printf+0xb3>
 545:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 549:	75 2d                	jne    578 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 54b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54e:	8b 00                	mov    (%eax),%eax
 550:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 557:	00 
 558:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 55f:	00 
 560:	89 44 24 04          	mov    %eax,0x4(%esp)
 564:	8b 45 08             	mov    0x8(%ebp),%eax
 567:	89 04 24             	mov    %eax,(%esp)
 56a:	e8 71 fe ff ff       	call   3e0 <printint>
        ap++;
 56f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 573:	e9 b3 00 00 00       	jmp    62b <printf+0x193>
      } else if(c == 's'){
 578:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 57c:	75 45                	jne    5c3 <printf+0x12b>
        s = (char*)*ap;
 57e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 581:	8b 00                	mov    (%eax),%eax
 583:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 586:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 58a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 58e:	75 09                	jne    599 <printf+0x101>
          s = "(null)";
 590:	c7 45 f4 78 08 00 00 	movl   $0x878,-0xc(%ebp)
        while(*s != 0){
 597:	eb 1e                	jmp    5b7 <printf+0x11f>
 599:	eb 1c                	jmp    5b7 <printf+0x11f>
          putc(fd, *s);
 59b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59e:	0f b6 00             	movzbl (%eax),%eax
 5a1:	0f be c0             	movsbl %al,%eax
 5a4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a8:	8b 45 08             	mov    0x8(%ebp),%eax
 5ab:	89 04 24             	mov    %eax,(%esp)
 5ae:	e8 05 fe ff ff       	call   3b8 <putc>
          s++;
 5b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ba:	0f b6 00             	movzbl (%eax),%eax
 5bd:	84 c0                	test   %al,%al
 5bf:	75 da                	jne    59b <printf+0x103>
 5c1:	eb 68                	jmp    62b <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5c3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5c7:	75 1d                	jne    5e6 <printf+0x14e>
        putc(fd, *ap);
 5c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5cc:	8b 00                	mov    (%eax),%eax
 5ce:	0f be c0             	movsbl %al,%eax
 5d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d5:	8b 45 08             	mov    0x8(%ebp),%eax
 5d8:	89 04 24             	mov    %eax,(%esp)
 5db:	e8 d8 fd ff ff       	call   3b8 <putc>
        ap++;
 5e0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e4:	eb 45                	jmp    62b <printf+0x193>
      } else if(c == '%'){
 5e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5ea:	75 17                	jne    603 <printf+0x16b>
        putc(fd, c);
 5ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ef:	0f be c0             	movsbl %al,%eax
 5f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f6:	8b 45 08             	mov    0x8(%ebp),%eax
 5f9:	89 04 24             	mov    %eax,(%esp)
 5fc:	e8 b7 fd ff ff       	call   3b8 <putc>
 601:	eb 28                	jmp    62b <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 603:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 60a:	00 
 60b:	8b 45 08             	mov    0x8(%ebp),%eax
 60e:	89 04 24             	mov    %eax,(%esp)
 611:	e8 a2 fd ff ff       	call   3b8 <putc>
        putc(fd, c);
 616:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 619:	0f be c0             	movsbl %al,%eax
 61c:	89 44 24 04          	mov    %eax,0x4(%esp)
 620:	8b 45 08             	mov    0x8(%ebp),%eax
 623:	89 04 24             	mov    %eax,(%esp)
 626:	e8 8d fd ff ff       	call   3b8 <putc>
      }
      state = 0;
 62b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 632:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 636:	8b 55 0c             	mov    0xc(%ebp),%edx
 639:	8b 45 f0             	mov    -0x10(%ebp),%eax
 63c:	01 d0                	add    %edx,%eax
 63e:	0f b6 00             	movzbl (%eax),%eax
 641:	84 c0                	test   %al,%al
 643:	0f 85 71 fe ff ff    	jne    4ba <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 649:	c9                   	leave  
 64a:	c3                   	ret    

0000064b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 64b:	55                   	push   %ebp
 64c:	89 e5                	mov    %esp,%ebp
 64e:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 651:	8b 45 08             	mov    0x8(%ebp),%eax
 654:	83 e8 08             	sub    $0x8,%eax
 657:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 65a:	a1 08 0b 00 00       	mov    0xb08,%eax
 65f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 662:	eb 24                	jmp    688 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 664:	8b 45 fc             	mov    -0x4(%ebp),%eax
 667:	8b 00                	mov    (%eax),%eax
 669:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 66c:	77 12                	ja     680 <free+0x35>
 66e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 671:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 674:	77 24                	ja     69a <free+0x4f>
 676:	8b 45 fc             	mov    -0x4(%ebp),%eax
 679:	8b 00                	mov    (%eax),%eax
 67b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 67e:	77 1a                	ja     69a <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 680:	8b 45 fc             	mov    -0x4(%ebp),%eax
 683:	8b 00                	mov    (%eax),%eax
 685:	89 45 fc             	mov    %eax,-0x4(%ebp)
 688:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 68e:	76 d4                	jbe    664 <free+0x19>
 690:	8b 45 fc             	mov    -0x4(%ebp),%eax
 693:	8b 00                	mov    (%eax),%eax
 695:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 698:	76 ca                	jbe    664 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 69a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69d:	8b 40 04             	mov    0x4(%eax),%eax
 6a0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6aa:	01 c2                	add    %eax,%edx
 6ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6af:	8b 00                	mov    (%eax),%eax
 6b1:	39 c2                	cmp    %eax,%edx
 6b3:	75 24                	jne    6d9 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b8:	8b 50 04             	mov    0x4(%eax),%edx
 6bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6be:	8b 00                	mov    (%eax),%eax
 6c0:	8b 40 04             	mov    0x4(%eax),%eax
 6c3:	01 c2                	add    %eax,%edx
 6c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c8:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ce:	8b 00                	mov    (%eax),%eax
 6d0:	8b 10                	mov    (%eax),%edx
 6d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d5:	89 10                	mov    %edx,(%eax)
 6d7:	eb 0a                	jmp    6e3 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dc:	8b 10                	mov    (%eax),%edx
 6de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e1:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e6:	8b 40 04             	mov    0x4(%eax),%eax
 6e9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f3:	01 d0                	add    %edx,%eax
 6f5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f8:	75 20                	jne    71a <free+0xcf>
    p->s.size += bp->s.size;
 6fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fd:	8b 50 04             	mov    0x4(%eax),%edx
 700:	8b 45 f8             	mov    -0x8(%ebp),%eax
 703:	8b 40 04             	mov    0x4(%eax),%eax
 706:	01 c2                	add    %eax,%edx
 708:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 70e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 711:	8b 10                	mov    (%eax),%edx
 713:	8b 45 fc             	mov    -0x4(%ebp),%eax
 716:	89 10                	mov    %edx,(%eax)
 718:	eb 08                	jmp    722 <free+0xd7>
  } else
    p->s.ptr = bp;
 71a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 720:	89 10                	mov    %edx,(%eax)
  freep = p;
 722:	8b 45 fc             	mov    -0x4(%ebp),%eax
 725:	a3 08 0b 00 00       	mov    %eax,0xb08
}
 72a:	c9                   	leave  
 72b:	c3                   	ret    

0000072c <morecore>:

static Header*
morecore(uint nu)
{
 72c:	55                   	push   %ebp
 72d:	89 e5                	mov    %esp,%ebp
 72f:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 732:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 739:	77 07                	ja     742 <morecore+0x16>
    nu = 4096;
 73b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 742:	8b 45 08             	mov    0x8(%ebp),%eax
 745:	c1 e0 03             	shl    $0x3,%eax
 748:	89 04 24             	mov    %eax,(%esp)
 74b:	e8 30 fc ff ff       	call   380 <sbrk>
 750:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 753:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 757:	75 07                	jne    760 <morecore+0x34>
    return 0;
 759:	b8 00 00 00 00       	mov    $0x0,%eax
 75e:	eb 22                	jmp    782 <morecore+0x56>
  hp = (Header*)p;
 760:	8b 45 f4             	mov    -0xc(%ebp),%eax
 763:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 766:	8b 45 f0             	mov    -0x10(%ebp),%eax
 769:	8b 55 08             	mov    0x8(%ebp),%edx
 76c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 76f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 772:	83 c0 08             	add    $0x8,%eax
 775:	89 04 24             	mov    %eax,(%esp)
 778:	e8 ce fe ff ff       	call   64b <free>
  return freep;
 77d:	a1 08 0b 00 00       	mov    0xb08,%eax
}
 782:	c9                   	leave  
 783:	c3                   	ret    

00000784 <malloc>:

void*
malloc(uint nbytes)
{
 784:	55                   	push   %ebp
 785:	89 e5                	mov    %esp,%ebp
 787:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 78a:	8b 45 08             	mov    0x8(%ebp),%eax
 78d:	83 c0 07             	add    $0x7,%eax
 790:	c1 e8 03             	shr    $0x3,%eax
 793:	83 c0 01             	add    $0x1,%eax
 796:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 799:	a1 08 0b 00 00       	mov    0xb08,%eax
 79e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7a5:	75 23                	jne    7ca <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7a7:	c7 45 f0 00 0b 00 00 	movl   $0xb00,-0x10(%ebp)
 7ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b1:	a3 08 0b 00 00       	mov    %eax,0xb08
 7b6:	a1 08 0b 00 00       	mov    0xb08,%eax
 7bb:	a3 00 0b 00 00       	mov    %eax,0xb00
    base.s.size = 0;
 7c0:	c7 05 04 0b 00 00 00 	movl   $0x0,0xb04
 7c7:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cd:	8b 00                	mov    (%eax),%eax
 7cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d5:	8b 40 04             	mov    0x4(%eax),%eax
 7d8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7db:	72 4d                	jb     82a <malloc+0xa6>
      if(p->s.size == nunits)
 7dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e0:	8b 40 04             	mov    0x4(%eax),%eax
 7e3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7e6:	75 0c                	jne    7f4 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7eb:	8b 10                	mov    (%eax),%edx
 7ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f0:	89 10                	mov    %edx,(%eax)
 7f2:	eb 26                	jmp    81a <malloc+0x96>
      else {
        p->s.size -= nunits;
 7f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f7:	8b 40 04             	mov    0x4(%eax),%eax
 7fa:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7fd:	89 c2                	mov    %eax,%edx
 7ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 802:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 805:	8b 45 f4             	mov    -0xc(%ebp),%eax
 808:	8b 40 04             	mov    0x4(%eax),%eax
 80b:	c1 e0 03             	shl    $0x3,%eax
 80e:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 811:	8b 45 f4             	mov    -0xc(%ebp),%eax
 814:	8b 55 ec             	mov    -0x14(%ebp),%edx
 817:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 81a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81d:	a3 08 0b 00 00       	mov    %eax,0xb08
      return (void*)(p + 1);
 822:	8b 45 f4             	mov    -0xc(%ebp),%eax
 825:	83 c0 08             	add    $0x8,%eax
 828:	eb 38                	jmp    862 <malloc+0xde>
    }
    if(p == freep)
 82a:	a1 08 0b 00 00       	mov    0xb08,%eax
 82f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 832:	75 1b                	jne    84f <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 834:	8b 45 ec             	mov    -0x14(%ebp),%eax
 837:	89 04 24             	mov    %eax,(%esp)
 83a:	e8 ed fe ff ff       	call   72c <morecore>
 83f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 842:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 846:	75 07                	jne    84f <malloc+0xcb>
        return 0;
 848:	b8 00 00 00 00       	mov    $0x0,%eax
 84d:	eb 13                	jmp    862 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	89 45 f0             	mov    %eax,-0x10(%ebp)
 855:	8b 45 f4             	mov    -0xc(%ebp),%eax
 858:	8b 00                	mov    (%eax),%eax
 85a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 85d:	e9 70 ff ff ff       	jmp    7d2 <malloc+0x4e>
}
 862:	c9                   	leave  
 863:	c3                   	ret    
