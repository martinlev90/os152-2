
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
  10:	e8 7f 07 00 00       	call   794 <malloc>
  15:	89 44 24 1c          	mov    %eax,0x1c(%esp)

	int tid=
  19:	c7 44 24 08 a0 0f 00 	movl   $0xfa0,0x8(%esp)
  20:	00 
  21:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  25:	89 44 24 04          	mov    %eax,0x4(%esp)
  29:	c7 04 24 51 00 00 00 	movl   $0x51,(%esp)
  30:	e8 73 03 00 00       	call   3a8 <kthread_create>
  35:	89 44 24 18          	mov    %eax,0x18(%esp)
	kthread_create( testfunc, stack0, MAX_STACK_SIZE);
	kthread_join(tid);
  39:	8b 44 24 18          	mov    0x18(%esp),%eax
  3d:	89 04 24             	mov    %eax,(%esp)
  40:	e8 7b 03 00 00       	call   3c0 <kthread_join>




	//for(;;);
	kthread_exit();
  45:	e8 6e 03 00 00       	call   3b8 <kthread_exit>
	return 0;
  4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  4f:	c9                   	leave  
  50:	c3                   	ret    

00000051 <testfunc>:


void* testfunc(){
  51:	55                   	push   %ebp
  52:	89 e5                	mov    %esp,%ebp
  54:	83 ec 28             	sub    $0x28,%esp

	int k;
	for (k=0; k<10; k++){
  57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  5e:	eb 2e                	jmp    8e <testfunc+0x3d>

	printf(1, "thread is alive %d\n", ++i);
  60:	a1 0c 0b 00 00       	mov    0xb0c,%eax
  65:	83 c0 01             	add    $0x1,%eax
  68:	a3 0c 0b 00 00       	mov    %eax,0xb0c
  6d:	a1 0c 0b 00 00       	mov    0xb0c,%eax
  72:	89 44 24 08          	mov    %eax,0x8(%esp)
  76:	c7 44 24 04 74 08 00 	movl   $0x874,0x4(%esp)
  7d:	00 
  7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  85:	e8 1e 04 00 00       	call   4a8 <printf>


void* testfunc(){

	int k;
	for (k=0; k<10; k++){
  8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  92:	7e cc                	jle    60 <testfunc+0xf>
	printf(1, "thread is alive %d\n", ++i);
	}



	kthread_exit();
  94:	e8 1f 03 00 00       	call   3b8 <kthread_exit>
	return 0;
  99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  9e:	c9                   	leave  
  9f:	c3                   	ret    

000000a0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  a0:	55                   	push   %ebp
  a1:	89 e5                	mov    %esp,%ebp
  a3:	57                   	push   %edi
  a4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  a8:	8b 55 10             	mov    0x10(%ebp),%edx
  ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  ae:	89 cb                	mov    %ecx,%ebx
  b0:	89 df                	mov    %ebx,%edi
  b2:	89 d1                	mov    %edx,%ecx
  b4:	fc                   	cld    
  b5:	f3 aa                	rep stos %al,%es:(%edi)
  b7:	89 ca                	mov    %ecx,%edx
  b9:	89 fb                	mov    %edi,%ebx
  bb:	89 5d 08             	mov    %ebx,0x8(%ebp)
  be:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  c1:	5b                   	pop    %ebx
  c2:	5f                   	pop    %edi
  c3:	5d                   	pop    %ebp
  c4:	c3                   	ret    

000000c5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  c5:	55                   	push   %ebp
  c6:	89 e5                	mov    %esp,%ebp
  c8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  cb:	8b 45 08             	mov    0x8(%ebp),%eax
  ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  d1:	90                   	nop
  d2:	8b 45 08             	mov    0x8(%ebp),%eax
  d5:	8d 50 01             	lea    0x1(%eax),%edx
  d8:	89 55 08             	mov    %edx,0x8(%ebp)
  db:	8b 55 0c             	mov    0xc(%ebp),%edx
  de:	8d 4a 01             	lea    0x1(%edx),%ecx
  e1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  e4:	0f b6 12             	movzbl (%edx),%edx
  e7:	88 10                	mov    %dl,(%eax)
  e9:	0f b6 00             	movzbl (%eax),%eax
  ec:	84 c0                	test   %al,%al
  ee:	75 e2                	jne    d2 <strcpy+0xd>
    ;
  return os;
  f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f3:	c9                   	leave  
  f4:	c3                   	ret    

000000f5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f5:	55                   	push   %ebp
  f6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  f8:	eb 08                	jmp    102 <strcmp+0xd>
    p++, q++;
  fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  fe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 102:	8b 45 08             	mov    0x8(%ebp),%eax
 105:	0f b6 00             	movzbl (%eax),%eax
 108:	84 c0                	test   %al,%al
 10a:	74 10                	je     11c <strcmp+0x27>
 10c:	8b 45 08             	mov    0x8(%ebp),%eax
 10f:	0f b6 10             	movzbl (%eax),%edx
 112:	8b 45 0c             	mov    0xc(%ebp),%eax
 115:	0f b6 00             	movzbl (%eax),%eax
 118:	38 c2                	cmp    %al,%dl
 11a:	74 de                	je     fa <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	0f b6 00             	movzbl (%eax),%eax
 122:	0f b6 d0             	movzbl %al,%edx
 125:	8b 45 0c             	mov    0xc(%ebp),%eax
 128:	0f b6 00             	movzbl (%eax),%eax
 12b:	0f b6 c0             	movzbl %al,%eax
 12e:	29 c2                	sub    %eax,%edx
 130:	89 d0                	mov    %edx,%eax
}
 132:	5d                   	pop    %ebp
 133:	c3                   	ret    

00000134 <strlen>:

uint
strlen(char *s)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 13a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 141:	eb 04                	jmp    147 <strlen+0x13>
 143:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 147:	8b 55 fc             	mov    -0x4(%ebp),%edx
 14a:	8b 45 08             	mov    0x8(%ebp),%eax
 14d:	01 d0                	add    %edx,%eax
 14f:	0f b6 00             	movzbl (%eax),%eax
 152:	84 c0                	test   %al,%al
 154:	75 ed                	jne    143 <strlen+0xf>
    ;
  return n;
 156:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 159:	c9                   	leave  
 15a:	c3                   	ret    

0000015b <memset>:

void*
memset(void *dst, int c, uint n)
{
 15b:	55                   	push   %ebp
 15c:	89 e5                	mov    %esp,%ebp
 15e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 161:	8b 45 10             	mov    0x10(%ebp),%eax
 164:	89 44 24 08          	mov    %eax,0x8(%esp)
 168:	8b 45 0c             	mov    0xc(%ebp),%eax
 16b:	89 44 24 04          	mov    %eax,0x4(%esp)
 16f:	8b 45 08             	mov    0x8(%ebp),%eax
 172:	89 04 24             	mov    %eax,(%esp)
 175:	e8 26 ff ff ff       	call   a0 <stosb>
  return dst;
 17a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 17d:	c9                   	leave  
 17e:	c3                   	ret    

0000017f <strchr>:

char*
strchr(const char *s, char c)
{
 17f:	55                   	push   %ebp
 180:	89 e5                	mov    %esp,%ebp
 182:	83 ec 04             	sub    $0x4,%esp
 185:	8b 45 0c             	mov    0xc(%ebp),%eax
 188:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 18b:	eb 14                	jmp    1a1 <strchr+0x22>
    if(*s == c)
 18d:	8b 45 08             	mov    0x8(%ebp),%eax
 190:	0f b6 00             	movzbl (%eax),%eax
 193:	3a 45 fc             	cmp    -0x4(%ebp),%al
 196:	75 05                	jne    19d <strchr+0x1e>
      return (char*)s;
 198:	8b 45 08             	mov    0x8(%ebp),%eax
 19b:	eb 13                	jmp    1b0 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 19d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1a1:	8b 45 08             	mov    0x8(%ebp),%eax
 1a4:	0f b6 00             	movzbl (%eax),%eax
 1a7:	84 c0                	test   %al,%al
 1a9:	75 e2                	jne    18d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1b0:	c9                   	leave  
 1b1:	c3                   	ret    

000001b2 <gets>:

char*
gets(char *buf, int max)
{
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1bf:	eb 4c                	jmp    20d <gets+0x5b>
    cc = read(0, &c, 1);
 1c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1c8:	00 
 1c9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1cc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1d7:	e8 44 01 00 00       	call   320 <read>
 1dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1e3:	7f 02                	jg     1e7 <gets+0x35>
      break;
 1e5:	eb 31                	jmp    218 <gets+0x66>
    buf[i++] = c;
 1e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ea:	8d 50 01             	lea    0x1(%eax),%edx
 1ed:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1f0:	89 c2                	mov    %eax,%edx
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	01 c2                	add    %eax,%edx
 1f7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1fb:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1fd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 201:	3c 0a                	cmp    $0xa,%al
 203:	74 13                	je     218 <gets+0x66>
 205:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 209:	3c 0d                	cmp    $0xd,%al
 20b:	74 0b                	je     218 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 210:	83 c0 01             	add    $0x1,%eax
 213:	3b 45 0c             	cmp    0xc(%ebp),%eax
 216:	7c a9                	jl     1c1 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 218:	8b 55 f4             	mov    -0xc(%ebp),%edx
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	01 d0                	add    %edx,%eax
 220:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 223:	8b 45 08             	mov    0x8(%ebp),%eax
}
 226:	c9                   	leave  
 227:	c3                   	ret    

00000228 <stat>:

int
stat(char *n, struct stat *st)
{
 228:	55                   	push   %ebp
 229:	89 e5                	mov    %esp,%ebp
 22b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 235:	00 
 236:	8b 45 08             	mov    0x8(%ebp),%eax
 239:	89 04 24             	mov    %eax,(%esp)
 23c:	e8 07 01 00 00       	call   348 <open>
 241:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 244:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 248:	79 07                	jns    251 <stat+0x29>
    return -1;
 24a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 24f:	eb 23                	jmp    274 <stat+0x4c>
  r = fstat(fd, st);
 251:	8b 45 0c             	mov    0xc(%ebp),%eax
 254:	89 44 24 04          	mov    %eax,0x4(%esp)
 258:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25b:	89 04 24             	mov    %eax,(%esp)
 25e:	e8 fd 00 00 00       	call   360 <fstat>
 263:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 266:	8b 45 f4             	mov    -0xc(%ebp),%eax
 269:	89 04 24             	mov    %eax,(%esp)
 26c:	e8 bf 00 00 00       	call   330 <close>
  return r;
 271:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 274:	c9                   	leave  
 275:	c3                   	ret    

00000276 <atoi>:

int
atoi(const char *s)
{
 276:	55                   	push   %ebp
 277:	89 e5                	mov    %esp,%ebp
 279:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 27c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 283:	eb 25                	jmp    2aa <atoi+0x34>
    n = n*10 + *s++ - '0';
 285:	8b 55 fc             	mov    -0x4(%ebp),%edx
 288:	89 d0                	mov    %edx,%eax
 28a:	c1 e0 02             	shl    $0x2,%eax
 28d:	01 d0                	add    %edx,%eax
 28f:	01 c0                	add    %eax,%eax
 291:	89 c1                	mov    %eax,%ecx
 293:	8b 45 08             	mov    0x8(%ebp),%eax
 296:	8d 50 01             	lea    0x1(%eax),%edx
 299:	89 55 08             	mov    %edx,0x8(%ebp)
 29c:	0f b6 00             	movzbl (%eax),%eax
 29f:	0f be c0             	movsbl %al,%eax
 2a2:	01 c8                	add    %ecx,%eax
 2a4:	83 e8 30             	sub    $0x30,%eax
 2a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2aa:	8b 45 08             	mov    0x8(%ebp),%eax
 2ad:	0f b6 00             	movzbl (%eax),%eax
 2b0:	3c 2f                	cmp    $0x2f,%al
 2b2:	7e 0a                	jle    2be <atoi+0x48>
 2b4:	8b 45 08             	mov    0x8(%ebp),%eax
 2b7:	0f b6 00             	movzbl (%eax),%eax
 2ba:	3c 39                	cmp    $0x39,%al
 2bc:	7e c7                	jle    285 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2c1:	c9                   	leave  
 2c2:	c3                   	ret    

000002c3 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2c3:	55                   	push   %ebp
 2c4:	89 e5                	mov    %esp,%ebp
 2c6:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2c9:	8b 45 08             	mov    0x8(%ebp),%eax
 2cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2d5:	eb 17                	jmp    2ee <memmove+0x2b>
    *dst++ = *src++;
 2d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2da:	8d 50 01             	lea    0x1(%eax),%edx
 2dd:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2e0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2e3:	8d 4a 01             	lea    0x1(%edx),%ecx
 2e6:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2e9:	0f b6 12             	movzbl (%edx),%edx
 2ec:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2ee:	8b 45 10             	mov    0x10(%ebp),%eax
 2f1:	8d 50 ff             	lea    -0x1(%eax),%edx
 2f4:	89 55 10             	mov    %edx,0x10(%ebp)
 2f7:	85 c0                	test   %eax,%eax
 2f9:	7f dc                	jg     2d7 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2fb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2fe:	c9                   	leave  
 2ff:	c3                   	ret    

00000300 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 300:	b8 01 00 00 00       	mov    $0x1,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <exit>:
SYSCALL(exit)
 308:	b8 02 00 00 00       	mov    $0x2,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <wait>:
SYSCALL(wait)
 310:	b8 03 00 00 00       	mov    $0x3,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <pipe>:
SYSCALL(pipe)
 318:	b8 04 00 00 00       	mov    $0x4,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <read>:
SYSCALL(read)
 320:	b8 05 00 00 00       	mov    $0x5,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <write>:
SYSCALL(write)
 328:	b8 10 00 00 00       	mov    $0x10,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <close>:
SYSCALL(close)
 330:	b8 15 00 00 00       	mov    $0x15,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <kill>:
SYSCALL(kill)
 338:	b8 06 00 00 00       	mov    $0x6,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <exec>:
SYSCALL(exec)
 340:	b8 07 00 00 00       	mov    $0x7,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <open>:
SYSCALL(open)
 348:	b8 0f 00 00 00       	mov    $0xf,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <mknod>:
SYSCALL(mknod)
 350:	b8 11 00 00 00       	mov    $0x11,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <unlink>:
SYSCALL(unlink)
 358:	b8 12 00 00 00       	mov    $0x12,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <fstat>:
SYSCALL(fstat)
 360:	b8 08 00 00 00       	mov    $0x8,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <link>:
SYSCALL(link)
 368:	b8 13 00 00 00       	mov    $0x13,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <mkdir>:
SYSCALL(mkdir)
 370:	b8 14 00 00 00       	mov    $0x14,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <chdir>:
SYSCALL(chdir)
 378:	b8 09 00 00 00       	mov    $0x9,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <dup>:
SYSCALL(dup)
 380:	b8 0a 00 00 00       	mov    $0xa,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <getpid>:
SYSCALL(getpid)
 388:	b8 0b 00 00 00       	mov    $0xb,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <sbrk>:
SYSCALL(sbrk)
 390:	b8 0c 00 00 00       	mov    $0xc,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <sleep>:
SYSCALL(sleep)
 398:	b8 0d 00 00 00       	mov    $0xd,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <uptime>:
SYSCALL(uptime)
 3a0:	b8 0e 00 00 00       	mov    $0xe,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <kthread_create>:

SYSCALL(kthread_create)
 3a8:	b8 16 00 00 00       	mov    $0x16,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <kthread_id>:
SYSCALL(kthread_id)
 3b0:	b8 17 00 00 00       	mov    $0x17,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <kthread_exit>:
SYSCALL(kthread_exit)
 3b8:	b8 18 00 00 00       	mov    $0x18,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <kthread_join>:
SYSCALL(kthread_join)
 3c0:	b8 19 00 00 00       	mov    $0x19,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3c8:	55                   	push   %ebp
 3c9:	89 e5                	mov    %esp,%ebp
 3cb:	83 ec 18             	sub    $0x18,%esp
 3ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3d4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3db:	00 
 3dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3df:	89 44 24 04          	mov    %eax,0x4(%esp)
 3e3:	8b 45 08             	mov    0x8(%ebp),%eax
 3e6:	89 04 24             	mov    %eax,(%esp)
 3e9:	e8 3a ff ff ff       	call   328 <write>
}
 3ee:	c9                   	leave  
 3ef:	c3                   	ret    

000003f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	56                   	push   %esi
 3f4:	53                   	push   %ebx
 3f5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3f8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3ff:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 403:	74 17                	je     41c <printint+0x2c>
 405:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 409:	79 11                	jns    41c <printint+0x2c>
    neg = 1;
 40b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 412:	8b 45 0c             	mov    0xc(%ebp),%eax
 415:	f7 d8                	neg    %eax
 417:	89 45 ec             	mov    %eax,-0x14(%ebp)
 41a:	eb 06                	jmp    422 <printint+0x32>
  } else {
    x = xx;
 41c:	8b 45 0c             	mov    0xc(%ebp),%eax
 41f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 422:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 429:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 42c:	8d 41 01             	lea    0x1(%ecx),%eax
 42f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 432:	8b 5d 10             	mov    0x10(%ebp),%ebx
 435:	8b 45 ec             	mov    -0x14(%ebp),%eax
 438:	ba 00 00 00 00       	mov    $0x0,%edx
 43d:	f7 f3                	div    %ebx
 43f:	89 d0                	mov    %edx,%eax
 441:	0f b6 80 f8 0a 00 00 	movzbl 0xaf8(%eax),%eax
 448:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 44c:	8b 75 10             	mov    0x10(%ebp),%esi
 44f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 452:	ba 00 00 00 00       	mov    $0x0,%edx
 457:	f7 f6                	div    %esi
 459:	89 45 ec             	mov    %eax,-0x14(%ebp)
 45c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 460:	75 c7                	jne    429 <printint+0x39>
  if(neg)
 462:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 466:	74 10                	je     478 <printint+0x88>
    buf[i++] = '-';
 468:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46b:	8d 50 01             	lea    0x1(%eax),%edx
 46e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 471:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 476:	eb 1f                	jmp    497 <printint+0xa7>
 478:	eb 1d                	jmp    497 <printint+0xa7>
    putc(fd, buf[i]);
 47a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 47d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 480:	01 d0                	add    %edx,%eax
 482:	0f b6 00             	movzbl (%eax),%eax
 485:	0f be c0             	movsbl %al,%eax
 488:	89 44 24 04          	mov    %eax,0x4(%esp)
 48c:	8b 45 08             	mov    0x8(%ebp),%eax
 48f:	89 04 24             	mov    %eax,(%esp)
 492:	e8 31 ff ff ff       	call   3c8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 497:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 49b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 49f:	79 d9                	jns    47a <printint+0x8a>
    putc(fd, buf[i]);
}
 4a1:	83 c4 30             	add    $0x30,%esp
 4a4:	5b                   	pop    %ebx
 4a5:	5e                   	pop    %esi
 4a6:	5d                   	pop    %ebp
 4a7:	c3                   	ret    

000004a8 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4a8:	55                   	push   %ebp
 4a9:	89 e5                	mov    %esp,%ebp
 4ab:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4ae:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4b5:	8d 45 0c             	lea    0xc(%ebp),%eax
 4b8:	83 c0 04             	add    $0x4,%eax
 4bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4c5:	e9 7c 01 00 00       	jmp    646 <printf+0x19e>
    c = fmt[i] & 0xff;
 4ca:	8b 55 0c             	mov    0xc(%ebp),%edx
 4cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4d0:	01 d0                	add    %edx,%eax
 4d2:	0f b6 00             	movzbl (%eax),%eax
 4d5:	0f be c0             	movsbl %al,%eax
 4d8:	25 ff 00 00 00       	and    $0xff,%eax
 4dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4e0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4e4:	75 2c                	jne    512 <printf+0x6a>
      if(c == '%'){
 4e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4ea:	75 0c                	jne    4f8 <printf+0x50>
        state = '%';
 4ec:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4f3:	e9 4a 01 00 00       	jmp    642 <printf+0x19a>
      } else {
        putc(fd, c);
 4f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4fb:	0f be c0             	movsbl %al,%eax
 4fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 502:	8b 45 08             	mov    0x8(%ebp),%eax
 505:	89 04 24             	mov    %eax,(%esp)
 508:	e8 bb fe ff ff       	call   3c8 <putc>
 50d:	e9 30 01 00 00       	jmp    642 <printf+0x19a>
      }
    } else if(state == '%'){
 512:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 516:	0f 85 26 01 00 00    	jne    642 <printf+0x19a>
      if(c == 'd'){
 51c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 520:	75 2d                	jne    54f <printf+0xa7>
        printint(fd, *ap, 10, 1);
 522:	8b 45 e8             	mov    -0x18(%ebp),%eax
 525:	8b 00                	mov    (%eax),%eax
 527:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 52e:	00 
 52f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 536:	00 
 537:	89 44 24 04          	mov    %eax,0x4(%esp)
 53b:	8b 45 08             	mov    0x8(%ebp),%eax
 53e:	89 04 24             	mov    %eax,(%esp)
 541:	e8 aa fe ff ff       	call   3f0 <printint>
        ap++;
 546:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 54a:	e9 ec 00 00 00       	jmp    63b <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 54f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 553:	74 06                	je     55b <printf+0xb3>
 555:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 559:	75 2d                	jne    588 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 55b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55e:	8b 00                	mov    (%eax),%eax
 560:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 567:	00 
 568:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 56f:	00 
 570:	89 44 24 04          	mov    %eax,0x4(%esp)
 574:	8b 45 08             	mov    0x8(%ebp),%eax
 577:	89 04 24             	mov    %eax,(%esp)
 57a:	e8 71 fe ff ff       	call   3f0 <printint>
        ap++;
 57f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 583:	e9 b3 00 00 00       	jmp    63b <printf+0x193>
      } else if(c == 's'){
 588:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 58c:	75 45                	jne    5d3 <printf+0x12b>
        s = (char*)*ap;
 58e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 591:	8b 00                	mov    (%eax),%eax
 593:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 596:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 59a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 59e:	75 09                	jne    5a9 <printf+0x101>
          s = "(null)";
 5a0:	c7 45 f4 88 08 00 00 	movl   $0x888,-0xc(%ebp)
        while(*s != 0){
 5a7:	eb 1e                	jmp    5c7 <printf+0x11f>
 5a9:	eb 1c                	jmp    5c7 <printf+0x11f>
          putc(fd, *s);
 5ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ae:	0f b6 00             	movzbl (%eax),%eax
 5b1:	0f be c0             	movsbl %al,%eax
 5b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b8:	8b 45 08             	mov    0x8(%ebp),%eax
 5bb:	89 04 24             	mov    %eax,(%esp)
 5be:	e8 05 fe ff ff       	call   3c8 <putc>
          s++;
 5c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ca:	0f b6 00             	movzbl (%eax),%eax
 5cd:	84 c0                	test   %al,%al
 5cf:	75 da                	jne    5ab <printf+0x103>
 5d1:	eb 68                	jmp    63b <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5d3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5d7:	75 1d                	jne    5f6 <printf+0x14e>
        putc(fd, *ap);
 5d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5dc:	8b 00                	mov    (%eax),%eax
 5de:	0f be c0             	movsbl %al,%eax
 5e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e5:	8b 45 08             	mov    0x8(%ebp),%eax
 5e8:	89 04 24             	mov    %eax,(%esp)
 5eb:	e8 d8 fd ff ff       	call   3c8 <putc>
        ap++;
 5f0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f4:	eb 45                	jmp    63b <printf+0x193>
      } else if(c == '%'){
 5f6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5fa:	75 17                	jne    613 <printf+0x16b>
        putc(fd, c);
 5fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ff:	0f be c0             	movsbl %al,%eax
 602:	89 44 24 04          	mov    %eax,0x4(%esp)
 606:	8b 45 08             	mov    0x8(%ebp),%eax
 609:	89 04 24             	mov    %eax,(%esp)
 60c:	e8 b7 fd ff ff       	call   3c8 <putc>
 611:	eb 28                	jmp    63b <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 613:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 61a:	00 
 61b:	8b 45 08             	mov    0x8(%ebp),%eax
 61e:	89 04 24             	mov    %eax,(%esp)
 621:	e8 a2 fd ff ff       	call   3c8 <putc>
        putc(fd, c);
 626:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 629:	0f be c0             	movsbl %al,%eax
 62c:	89 44 24 04          	mov    %eax,0x4(%esp)
 630:	8b 45 08             	mov    0x8(%ebp),%eax
 633:	89 04 24             	mov    %eax,(%esp)
 636:	e8 8d fd ff ff       	call   3c8 <putc>
      }
      state = 0;
 63b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 642:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 646:	8b 55 0c             	mov    0xc(%ebp),%edx
 649:	8b 45 f0             	mov    -0x10(%ebp),%eax
 64c:	01 d0                	add    %edx,%eax
 64e:	0f b6 00             	movzbl (%eax),%eax
 651:	84 c0                	test   %al,%al
 653:	0f 85 71 fe ff ff    	jne    4ca <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 659:	c9                   	leave  
 65a:	c3                   	ret    

0000065b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 65b:	55                   	push   %ebp
 65c:	89 e5                	mov    %esp,%ebp
 65e:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 661:	8b 45 08             	mov    0x8(%ebp),%eax
 664:	83 e8 08             	sub    $0x8,%eax
 667:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 66a:	a1 18 0b 00 00       	mov    0xb18,%eax
 66f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 672:	eb 24                	jmp    698 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 674:	8b 45 fc             	mov    -0x4(%ebp),%eax
 677:	8b 00                	mov    (%eax),%eax
 679:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 67c:	77 12                	ja     690 <free+0x35>
 67e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 681:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 684:	77 24                	ja     6aa <free+0x4f>
 686:	8b 45 fc             	mov    -0x4(%ebp),%eax
 689:	8b 00                	mov    (%eax),%eax
 68b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 68e:	77 1a                	ja     6aa <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 690:	8b 45 fc             	mov    -0x4(%ebp),%eax
 693:	8b 00                	mov    (%eax),%eax
 695:	89 45 fc             	mov    %eax,-0x4(%ebp)
 698:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 69e:	76 d4                	jbe    674 <free+0x19>
 6a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a3:	8b 00                	mov    (%eax),%eax
 6a5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6a8:	76 ca                	jbe    674 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ad:	8b 40 04             	mov    0x4(%eax),%eax
 6b0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ba:	01 c2                	add    %eax,%edx
 6bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bf:	8b 00                	mov    (%eax),%eax
 6c1:	39 c2                	cmp    %eax,%edx
 6c3:	75 24                	jne    6e9 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c8:	8b 50 04             	mov    0x4(%eax),%edx
 6cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ce:	8b 00                	mov    (%eax),%eax
 6d0:	8b 40 04             	mov    0x4(%eax),%eax
 6d3:	01 c2                	add    %eax,%edx
 6d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d8:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6de:	8b 00                	mov    (%eax),%eax
 6e0:	8b 10                	mov    (%eax),%edx
 6e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e5:	89 10                	mov    %edx,(%eax)
 6e7:	eb 0a                	jmp    6f3 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ec:	8b 10                	mov    (%eax),%edx
 6ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f1:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f6:	8b 40 04             	mov    0x4(%eax),%eax
 6f9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 700:	8b 45 fc             	mov    -0x4(%ebp),%eax
 703:	01 d0                	add    %edx,%eax
 705:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 708:	75 20                	jne    72a <free+0xcf>
    p->s.size += bp->s.size;
 70a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70d:	8b 50 04             	mov    0x4(%eax),%edx
 710:	8b 45 f8             	mov    -0x8(%ebp),%eax
 713:	8b 40 04             	mov    0x4(%eax),%eax
 716:	01 c2                	add    %eax,%edx
 718:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 71e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 721:	8b 10                	mov    (%eax),%edx
 723:	8b 45 fc             	mov    -0x4(%ebp),%eax
 726:	89 10                	mov    %edx,(%eax)
 728:	eb 08                	jmp    732 <free+0xd7>
  } else
    p->s.ptr = bp;
 72a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 730:	89 10                	mov    %edx,(%eax)
  freep = p;
 732:	8b 45 fc             	mov    -0x4(%ebp),%eax
 735:	a3 18 0b 00 00       	mov    %eax,0xb18
}
 73a:	c9                   	leave  
 73b:	c3                   	ret    

0000073c <morecore>:

static Header*
morecore(uint nu)
{
 73c:	55                   	push   %ebp
 73d:	89 e5                	mov    %esp,%ebp
 73f:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 742:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 749:	77 07                	ja     752 <morecore+0x16>
    nu = 4096;
 74b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 752:	8b 45 08             	mov    0x8(%ebp),%eax
 755:	c1 e0 03             	shl    $0x3,%eax
 758:	89 04 24             	mov    %eax,(%esp)
 75b:	e8 30 fc ff ff       	call   390 <sbrk>
 760:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 763:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 767:	75 07                	jne    770 <morecore+0x34>
    return 0;
 769:	b8 00 00 00 00       	mov    $0x0,%eax
 76e:	eb 22                	jmp    792 <morecore+0x56>
  hp = (Header*)p;
 770:	8b 45 f4             	mov    -0xc(%ebp),%eax
 773:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 776:	8b 45 f0             	mov    -0x10(%ebp),%eax
 779:	8b 55 08             	mov    0x8(%ebp),%edx
 77c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 77f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 782:	83 c0 08             	add    $0x8,%eax
 785:	89 04 24             	mov    %eax,(%esp)
 788:	e8 ce fe ff ff       	call   65b <free>
  return freep;
 78d:	a1 18 0b 00 00       	mov    0xb18,%eax
}
 792:	c9                   	leave  
 793:	c3                   	ret    

00000794 <malloc>:

void*
malloc(uint nbytes)
{
 794:	55                   	push   %ebp
 795:	89 e5                	mov    %esp,%ebp
 797:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79a:	8b 45 08             	mov    0x8(%ebp),%eax
 79d:	83 c0 07             	add    $0x7,%eax
 7a0:	c1 e8 03             	shr    $0x3,%eax
 7a3:	83 c0 01             	add    $0x1,%eax
 7a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7a9:	a1 18 0b 00 00       	mov    0xb18,%eax
 7ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7b5:	75 23                	jne    7da <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7b7:	c7 45 f0 10 0b 00 00 	movl   $0xb10,-0x10(%ebp)
 7be:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c1:	a3 18 0b 00 00       	mov    %eax,0xb18
 7c6:	a1 18 0b 00 00       	mov    0xb18,%eax
 7cb:	a3 10 0b 00 00       	mov    %eax,0xb10
    base.s.size = 0;
 7d0:	c7 05 14 0b 00 00 00 	movl   $0x0,0xb14
 7d7:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dd:	8b 00                	mov    (%eax),%eax
 7df:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e5:	8b 40 04             	mov    0x4(%eax),%eax
 7e8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7eb:	72 4d                	jb     83a <malloc+0xa6>
      if(p->s.size == nunits)
 7ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f0:	8b 40 04             	mov    0x4(%eax),%eax
 7f3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7f6:	75 0c                	jne    804 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fb:	8b 10                	mov    (%eax),%edx
 7fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 800:	89 10                	mov    %edx,(%eax)
 802:	eb 26                	jmp    82a <malloc+0x96>
      else {
        p->s.size -= nunits;
 804:	8b 45 f4             	mov    -0xc(%ebp),%eax
 807:	8b 40 04             	mov    0x4(%eax),%eax
 80a:	2b 45 ec             	sub    -0x14(%ebp),%eax
 80d:	89 c2                	mov    %eax,%edx
 80f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 812:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 815:	8b 45 f4             	mov    -0xc(%ebp),%eax
 818:	8b 40 04             	mov    0x4(%eax),%eax
 81b:	c1 e0 03             	shl    $0x3,%eax
 81e:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 821:	8b 45 f4             	mov    -0xc(%ebp),%eax
 824:	8b 55 ec             	mov    -0x14(%ebp),%edx
 827:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 82a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82d:	a3 18 0b 00 00       	mov    %eax,0xb18
      return (void*)(p + 1);
 832:	8b 45 f4             	mov    -0xc(%ebp),%eax
 835:	83 c0 08             	add    $0x8,%eax
 838:	eb 38                	jmp    872 <malloc+0xde>
    }
    if(p == freep)
 83a:	a1 18 0b 00 00       	mov    0xb18,%eax
 83f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 842:	75 1b                	jne    85f <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 844:	8b 45 ec             	mov    -0x14(%ebp),%eax
 847:	89 04 24             	mov    %eax,(%esp)
 84a:	e8 ed fe ff ff       	call   73c <morecore>
 84f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 852:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 856:	75 07                	jne    85f <malloc+0xcb>
        return 0;
 858:	b8 00 00 00 00       	mov    $0x0,%eax
 85d:	eb 13                	jmp    872 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 862:	89 45 f0             	mov    %eax,-0x10(%ebp)
 865:	8b 45 f4             	mov    -0xc(%ebp),%eax
 868:	8b 00                	mov    (%eax),%eax
 86a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 86d:	e9 70 ff ff ff       	jmp    7e2 <malloc+0x4e>
}
 872:	c9                   	leave  
 873:	c3                   	ret    
