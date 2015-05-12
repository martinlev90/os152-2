
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
  10:	e8 9a 07 00 00       	call   7af <malloc>
  15:	89 44 24 1c          	mov    %eax,0x1c(%esp)

	int tid=
  19:	c7 44 24 08 a0 0f 00 	movl   $0xfa0,0x8(%esp)
  20:	00 
  21:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  25:	89 44 24 04          	mov    %eax,0x4(%esp)
  29:	c7 04 24 6c 00 00 00 	movl   $0x6c,(%esp)
  30:	e8 8e 03 00 00       	call   3c3 <kthread_create>
  35:	89 44 24 18          	mov    %eax,0x18(%esp)
	kthread_create( testfunc, stack0, MAX_STACK_SIZE);
	kthread_join(tid);
  39:	8b 44 24 18          	mov    0x18(%esp),%eax
  3d:	89 04 24             	mov    %eax,(%esp)
  40:	e8 96 03 00 00       	call   3db <kthread_join>
	printf(1,"i: %d %d\n",i,tid);
  45:	a1 2c 0b 00 00       	mov    0xb2c,%eax
  4a:	8b 54 24 18          	mov    0x18(%esp),%edx
  4e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  52:	89 44 24 08          	mov    %eax,0x8(%esp)
  56:	c7 44 24 04 8f 08 00 	movl   $0x88f,0x4(%esp)
  5d:	00 
  5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  65:	e8 59 04 00 00       	call   4c3 <printf>




	for(;;);
  6a:	eb fe                	jmp    6a <main+0x6a>

0000006c <testfunc>:
	kthread_exit();
	return 0;
}


void* testfunc(){
  6c:	55                   	push   %ebp
  6d:	89 e5                	mov    %esp,%ebp
  6f:	83 ec 28             	sub    $0x28,%esp

	int k;
	for (k=0; k<10; k++){
  72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  79:	eb 2e                	jmp    a9 <testfunc+0x3d>

	printf(1, "thread is alive %d\n", ++i);
  7b:	a1 2c 0b 00 00       	mov    0xb2c,%eax
  80:	83 c0 01             	add    $0x1,%eax
  83:	a3 2c 0b 00 00       	mov    %eax,0xb2c
  88:	a1 2c 0b 00 00       	mov    0xb2c,%eax
  8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  91:	c7 44 24 04 99 08 00 	movl   $0x899,0x4(%esp)
  98:	00 
  99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a0:	e8 1e 04 00 00       	call   4c3 <printf>


void* testfunc(){

	int k;
	for (k=0; k<10; k++){
  a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  a9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  ad:	7e cc                	jle    7b <testfunc+0xf>
	printf(1, "thread is alive %d\n", ++i);
	}



	kthread_exit();
  af:	e8 1f 03 00 00       	call   3d3 <kthread_exit>
	return 0;
  b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  b9:	c9                   	leave  
  ba:	c3                   	ret    

000000bb <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  bb:	55                   	push   %ebp
  bc:	89 e5                	mov    %esp,%ebp
  be:	57                   	push   %edi
  bf:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  c3:	8b 55 10             	mov    0x10(%ebp),%edx
  c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  c9:	89 cb                	mov    %ecx,%ebx
  cb:	89 df                	mov    %ebx,%edi
  cd:	89 d1                	mov    %edx,%ecx
  cf:	fc                   	cld    
  d0:	f3 aa                	rep stos %al,%es:(%edi)
  d2:	89 ca                	mov    %ecx,%edx
  d4:	89 fb                	mov    %edi,%ebx
  d6:	89 5d 08             	mov    %ebx,0x8(%ebp)
  d9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  dc:	5b                   	pop    %ebx
  dd:	5f                   	pop    %edi
  de:	5d                   	pop    %ebp
  df:	c3                   	ret    

000000e0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  e0:	55                   	push   %ebp
  e1:	89 e5                	mov    %esp,%ebp
  e3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  e6:	8b 45 08             	mov    0x8(%ebp),%eax
  e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ec:	90                   	nop
  ed:	8b 45 08             	mov    0x8(%ebp),%eax
  f0:	8d 50 01             	lea    0x1(%eax),%edx
  f3:	89 55 08             	mov    %edx,0x8(%ebp)
  f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  fc:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  ff:	0f b6 12             	movzbl (%edx),%edx
 102:	88 10                	mov    %dl,(%eax)
 104:	0f b6 00             	movzbl (%eax),%eax
 107:	84 c0                	test   %al,%al
 109:	75 e2                	jne    ed <strcpy+0xd>
    ;
  return os;
 10b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 10e:	c9                   	leave  
 10f:	c3                   	ret    

00000110 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 113:	eb 08                	jmp    11d <strcmp+0xd>
    p++, q++;
 115:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 119:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	0f b6 00             	movzbl (%eax),%eax
 123:	84 c0                	test   %al,%al
 125:	74 10                	je     137 <strcmp+0x27>
 127:	8b 45 08             	mov    0x8(%ebp),%eax
 12a:	0f b6 10             	movzbl (%eax),%edx
 12d:	8b 45 0c             	mov    0xc(%ebp),%eax
 130:	0f b6 00             	movzbl (%eax),%eax
 133:	38 c2                	cmp    %al,%dl
 135:	74 de                	je     115 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 137:	8b 45 08             	mov    0x8(%ebp),%eax
 13a:	0f b6 00             	movzbl (%eax),%eax
 13d:	0f b6 d0             	movzbl %al,%edx
 140:	8b 45 0c             	mov    0xc(%ebp),%eax
 143:	0f b6 00             	movzbl (%eax),%eax
 146:	0f b6 c0             	movzbl %al,%eax
 149:	29 c2                	sub    %eax,%edx
 14b:	89 d0                	mov    %edx,%eax
}
 14d:	5d                   	pop    %ebp
 14e:	c3                   	ret    

0000014f <strlen>:

uint
strlen(char *s)
{
 14f:	55                   	push   %ebp
 150:	89 e5                	mov    %esp,%ebp
 152:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 155:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 15c:	eb 04                	jmp    162 <strlen+0x13>
 15e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 162:	8b 55 fc             	mov    -0x4(%ebp),%edx
 165:	8b 45 08             	mov    0x8(%ebp),%eax
 168:	01 d0                	add    %edx,%eax
 16a:	0f b6 00             	movzbl (%eax),%eax
 16d:	84 c0                	test   %al,%al
 16f:	75 ed                	jne    15e <strlen+0xf>
    ;
  return n;
 171:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 174:	c9                   	leave  
 175:	c3                   	ret    

00000176 <memset>:

void*
memset(void *dst, int c, uint n)
{
 176:	55                   	push   %ebp
 177:	89 e5                	mov    %esp,%ebp
 179:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 17c:	8b 45 10             	mov    0x10(%ebp),%eax
 17f:	89 44 24 08          	mov    %eax,0x8(%esp)
 183:	8b 45 0c             	mov    0xc(%ebp),%eax
 186:	89 44 24 04          	mov    %eax,0x4(%esp)
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	89 04 24             	mov    %eax,(%esp)
 190:	e8 26 ff ff ff       	call   bb <stosb>
  return dst;
 195:	8b 45 08             	mov    0x8(%ebp),%eax
}
 198:	c9                   	leave  
 199:	c3                   	ret    

0000019a <strchr>:

char*
strchr(const char *s, char c)
{
 19a:	55                   	push   %ebp
 19b:	89 e5                	mov    %esp,%ebp
 19d:	83 ec 04             	sub    $0x4,%esp
 1a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a3:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1a6:	eb 14                	jmp    1bc <strchr+0x22>
    if(*s == c)
 1a8:	8b 45 08             	mov    0x8(%ebp),%eax
 1ab:	0f b6 00             	movzbl (%eax),%eax
 1ae:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1b1:	75 05                	jne    1b8 <strchr+0x1e>
      return (char*)s;
 1b3:	8b 45 08             	mov    0x8(%ebp),%eax
 1b6:	eb 13                	jmp    1cb <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
 1bf:	0f b6 00             	movzbl (%eax),%eax
 1c2:	84 c0                	test   %al,%al
 1c4:	75 e2                	jne    1a8 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1cb:	c9                   	leave  
 1cc:	c3                   	ret    

000001cd <gets>:

char*
gets(char *buf, int max)
{
 1cd:	55                   	push   %ebp
 1ce:	89 e5                	mov    %esp,%ebp
 1d0:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1da:	eb 4c                	jmp    228 <gets+0x5b>
    cc = read(0, &c, 1);
 1dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1e3:	00 
 1e4:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 1eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1f2:	e8 44 01 00 00       	call   33b <read>
 1f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1fe:	7f 02                	jg     202 <gets+0x35>
      break;
 200:	eb 31                	jmp    233 <gets+0x66>
    buf[i++] = c;
 202:	8b 45 f4             	mov    -0xc(%ebp),%eax
 205:	8d 50 01             	lea    0x1(%eax),%edx
 208:	89 55 f4             	mov    %edx,-0xc(%ebp)
 20b:	89 c2                	mov    %eax,%edx
 20d:	8b 45 08             	mov    0x8(%ebp),%eax
 210:	01 c2                	add    %eax,%edx
 212:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 216:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 218:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 21c:	3c 0a                	cmp    $0xa,%al
 21e:	74 13                	je     233 <gets+0x66>
 220:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 224:	3c 0d                	cmp    $0xd,%al
 226:	74 0b                	je     233 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 228:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22b:	83 c0 01             	add    $0x1,%eax
 22e:	3b 45 0c             	cmp    0xc(%ebp),%eax
 231:	7c a9                	jl     1dc <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 233:	8b 55 f4             	mov    -0xc(%ebp),%edx
 236:	8b 45 08             	mov    0x8(%ebp),%eax
 239:	01 d0                	add    %edx,%eax
 23b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 23e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 241:	c9                   	leave  
 242:	c3                   	ret    

00000243 <stat>:

int
stat(char *n, struct stat *st)
{
 243:	55                   	push   %ebp
 244:	89 e5                	mov    %esp,%ebp
 246:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 249:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 250:	00 
 251:	8b 45 08             	mov    0x8(%ebp),%eax
 254:	89 04 24             	mov    %eax,(%esp)
 257:	e8 07 01 00 00       	call   363 <open>
 25c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 25f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 263:	79 07                	jns    26c <stat+0x29>
    return -1;
 265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 26a:	eb 23                	jmp    28f <stat+0x4c>
  r = fstat(fd, st);
 26c:	8b 45 0c             	mov    0xc(%ebp),%eax
 26f:	89 44 24 04          	mov    %eax,0x4(%esp)
 273:	8b 45 f4             	mov    -0xc(%ebp),%eax
 276:	89 04 24             	mov    %eax,(%esp)
 279:	e8 fd 00 00 00       	call   37b <fstat>
 27e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 281:	8b 45 f4             	mov    -0xc(%ebp),%eax
 284:	89 04 24             	mov    %eax,(%esp)
 287:	e8 bf 00 00 00       	call   34b <close>
  return r;
 28c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 28f:	c9                   	leave  
 290:	c3                   	ret    

00000291 <atoi>:

int
atoi(const char *s)
{
 291:	55                   	push   %ebp
 292:	89 e5                	mov    %esp,%ebp
 294:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 297:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 29e:	eb 25                	jmp    2c5 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2a0:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2a3:	89 d0                	mov    %edx,%eax
 2a5:	c1 e0 02             	shl    $0x2,%eax
 2a8:	01 d0                	add    %edx,%eax
 2aa:	01 c0                	add    %eax,%eax
 2ac:	89 c1                	mov    %eax,%ecx
 2ae:	8b 45 08             	mov    0x8(%ebp),%eax
 2b1:	8d 50 01             	lea    0x1(%eax),%edx
 2b4:	89 55 08             	mov    %edx,0x8(%ebp)
 2b7:	0f b6 00             	movzbl (%eax),%eax
 2ba:	0f be c0             	movsbl %al,%eax
 2bd:	01 c8                	add    %ecx,%eax
 2bf:	83 e8 30             	sub    $0x30,%eax
 2c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
 2c8:	0f b6 00             	movzbl (%eax),%eax
 2cb:	3c 2f                	cmp    $0x2f,%al
 2cd:	7e 0a                	jle    2d9 <atoi+0x48>
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
 2d2:	0f b6 00             	movzbl (%eax),%eax
 2d5:	3c 39                	cmp    $0x39,%al
 2d7:	7e c7                	jle    2a0 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2dc:	c9                   	leave  
 2dd:	c3                   	ret    

000002de <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2de:	55                   	push   %ebp
 2df:	89 e5                	mov    %esp,%ebp
 2e1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2f0:	eb 17                	jmp    309 <memmove+0x2b>
    *dst++ = *src++;
 2f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2f5:	8d 50 01             	lea    0x1(%eax),%edx
 2f8:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2fb:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2fe:	8d 4a 01             	lea    0x1(%edx),%ecx
 301:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 304:	0f b6 12             	movzbl (%edx),%edx
 307:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 309:	8b 45 10             	mov    0x10(%ebp),%eax
 30c:	8d 50 ff             	lea    -0x1(%eax),%edx
 30f:	89 55 10             	mov    %edx,0x10(%ebp)
 312:	85 c0                	test   %eax,%eax
 314:	7f dc                	jg     2f2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 316:	8b 45 08             	mov    0x8(%ebp),%eax
}
 319:	c9                   	leave  
 31a:	c3                   	ret    

0000031b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 31b:	b8 01 00 00 00       	mov    $0x1,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <exit>:
SYSCALL(exit)
 323:	b8 02 00 00 00       	mov    $0x2,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <wait>:
SYSCALL(wait)
 32b:	b8 03 00 00 00       	mov    $0x3,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <pipe>:
SYSCALL(pipe)
 333:	b8 04 00 00 00       	mov    $0x4,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <read>:
SYSCALL(read)
 33b:	b8 05 00 00 00       	mov    $0x5,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <write>:
SYSCALL(write)
 343:	b8 10 00 00 00       	mov    $0x10,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <close>:
SYSCALL(close)
 34b:	b8 15 00 00 00       	mov    $0x15,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <kill>:
SYSCALL(kill)
 353:	b8 06 00 00 00       	mov    $0x6,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <exec>:
SYSCALL(exec)
 35b:	b8 07 00 00 00       	mov    $0x7,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <open>:
SYSCALL(open)
 363:	b8 0f 00 00 00       	mov    $0xf,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <mknod>:
SYSCALL(mknod)
 36b:	b8 11 00 00 00       	mov    $0x11,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <unlink>:
SYSCALL(unlink)
 373:	b8 12 00 00 00       	mov    $0x12,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <fstat>:
SYSCALL(fstat)
 37b:	b8 08 00 00 00       	mov    $0x8,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <link>:
SYSCALL(link)
 383:	b8 13 00 00 00       	mov    $0x13,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <mkdir>:
SYSCALL(mkdir)
 38b:	b8 14 00 00 00       	mov    $0x14,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret    

00000393 <chdir>:
SYSCALL(chdir)
 393:	b8 09 00 00 00       	mov    $0x9,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	ret    

0000039b <dup>:
SYSCALL(dup)
 39b:	b8 0a 00 00 00       	mov    $0xa,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	ret    

000003a3 <getpid>:
SYSCALL(getpid)
 3a3:	b8 0b 00 00 00       	mov    $0xb,%eax
 3a8:	cd 40                	int    $0x40
 3aa:	c3                   	ret    

000003ab <sbrk>:
SYSCALL(sbrk)
 3ab:	b8 0c 00 00 00       	mov    $0xc,%eax
 3b0:	cd 40                	int    $0x40
 3b2:	c3                   	ret    

000003b3 <sleep>:
SYSCALL(sleep)
 3b3:	b8 0d 00 00 00       	mov    $0xd,%eax
 3b8:	cd 40                	int    $0x40
 3ba:	c3                   	ret    

000003bb <uptime>:
SYSCALL(uptime)
 3bb:	b8 0e 00 00 00       	mov    $0xe,%eax
 3c0:	cd 40                	int    $0x40
 3c2:	c3                   	ret    

000003c3 <kthread_create>:

SYSCALL(kthread_create)
 3c3:	b8 16 00 00 00       	mov    $0x16,%eax
 3c8:	cd 40                	int    $0x40
 3ca:	c3                   	ret    

000003cb <kthread_id>:
SYSCALL(kthread_id)
 3cb:	b8 17 00 00 00       	mov    $0x17,%eax
 3d0:	cd 40                	int    $0x40
 3d2:	c3                   	ret    

000003d3 <kthread_exit>:
SYSCALL(kthread_exit)
 3d3:	b8 18 00 00 00       	mov    $0x18,%eax
 3d8:	cd 40                	int    $0x40
 3da:	c3                   	ret    

000003db <kthread_join>:
SYSCALL(kthread_join)
 3db:	b8 19 00 00 00       	mov    $0x19,%eax
 3e0:	cd 40                	int    $0x40
 3e2:	c3                   	ret    

000003e3 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3e3:	55                   	push   %ebp
 3e4:	89 e5                	mov    %esp,%ebp
 3e6:	83 ec 18             	sub    $0x18,%esp
 3e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ec:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3ef:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3f6:	00 
 3f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3fa:	89 44 24 04          	mov    %eax,0x4(%esp)
 3fe:	8b 45 08             	mov    0x8(%ebp),%eax
 401:	89 04 24             	mov    %eax,(%esp)
 404:	e8 3a ff ff ff       	call   343 <write>
}
 409:	c9                   	leave  
 40a:	c3                   	ret    

0000040b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 40b:	55                   	push   %ebp
 40c:	89 e5                	mov    %esp,%ebp
 40e:	56                   	push   %esi
 40f:	53                   	push   %ebx
 410:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 413:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 41a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 41e:	74 17                	je     437 <printint+0x2c>
 420:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 424:	79 11                	jns    437 <printint+0x2c>
    neg = 1;
 426:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 42d:	8b 45 0c             	mov    0xc(%ebp),%eax
 430:	f7 d8                	neg    %eax
 432:	89 45 ec             	mov    %eax,-0x14(%ebp)
 435:	eb 06                	jmp    43d <printint+0x32>
  } else {
    x = xx;
 437:	8b 45 0c             	mov    0xc(%ebp),%eax
 43a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 43d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 444:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 447:	8d 41 01             	lea    0x1(%ecx),%eax
 44a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 44d:	8b 5d 10             	mov    0x10(%ebp),%ebx
 450:	8b 45 ec             	mov    -0x14(%ebp),%eax
 453:	ba 00 00 00 00       	mov    $0x0,%edx
 458:	f7 f3                	div    %ebx
 45a:	89 d0                	mov    %edx,%eax
 45c:	0f b6 80 18 0b 00 00 	movzbl 0xb18(%eax),%eax
 463:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 467:	8b 75 10             	mov    0x10(%ebp),%esi
 46a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 46d:	ba 00 00 00 00       	mov    $0x0,%edx
 472:	f7 f6                	div    %esi
 474:	89 45 ec             	mov    %eax,-0x14(%ebp)
 477:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 47b:	75 c7                	jne    444 <printint+0x39>
  if(neg)
 47d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 481:	74 10                	je     493 <printint+0x88>
    buf[i++] = '-';
 483:	8b 45 f4             	mov    -0xc(%ebp),%eax
 486:	8d 50 01             	lea    0x1(%eax),%edx
 489:	89 55 f4             	mov    %edx,-0xc(%ebp)
 48c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 491:	eb 1f                	jmp    4b2 <printint+0xa7>
 493:	eb 1d                	jmp    4b2 <printint+0xa7>
    putc(fd, buf[i]);
 495:	8d 55 dc             	lea    -0x24(%ebp),%edx
 498:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49b:	01 d0                	add    %edx,%eax
 49d:	0f b6 00             	movzbl (%eax),%eax
 4a0:	0f be c0             	movsbl %al,%eax
 4a3:	89 44 24 04          	mov    %eax,0x4(%esp)
 4a7:	8b 45 08             	mov    0x8(%ebp),%eax
 4aa:	89 04 24             	mov    %eax,(%esp)
 4ad:	e8 31 ff ff ff       	call   3e3 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4b2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ba:	79 d9                	jns    495 <printint+0x8a>
    putc(fd, buf[i]);
}
 4bc:	83 c4 30             	add    $0x30,%esp
 4bf:	5b                   	pop    %ebx
 4c0:	5e                   	pop    %esi
 4c1:	5d                   	pop    %ebp
 4c2:	c3                   	ret    

000004c3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4c3:	55                   	push   %ebp
 4c4:	89 e5                	mov    %esp,%ebp
 4c6:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4c9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4d0:	8d 45 0c             	lea    0xc(%ebp),%eax
 4d3:	83 c0 04             	add    $0x4,%eax
 4d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4d9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4e0:	e9 7c 01 00 00       	jmp    661 <printf+0x19e>
    c = fmt[i] & 0xff;
 4e5:	8b 55 0c             	mov    0xc(%ebp),%edx
 4e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4eb:	01 d0                	add    %edx,%eax
 4ed:	0f b6 00             	movzbl (%eax),%eax
 4f0:	0f be c0             	movsbl %al,%eax
 4f3:	25 ff 00 00 00       	and    $0xff,%eax
 4f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ff:	75 2c                	jne    52d <printf+0x6a>
      if(c == '%'){
 501:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 505:	75 0c                	jne    513 <printf+0x50>
        state = '%';
 507:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 50e:	e9 4a 01 00 00       	jmp    65d <printf+0x19a>
      } else {
        putc(fd, c);
 513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 516:	0f be c0             	movsbl %al,%eax
 519:	89 44 24 04          	mov    %eax,0x4(%esp)
 51d:	8b 45 08             	mov    0x8(%ebp),%eax
 520:	89 04 24             	mov    %eax,(%esp)
 523:	e8 bb fe ff ff       	call   3e3 <putc>
 528:	e9 30 01 00 00       	jmp    65d <printf+0x19a>
      }
    } else if(state == '%'){
 52d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 531:	0f 85 26 01 00 00    	jne    65d <printf+0x19a>
      if(c == 'd'){
 537:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 53b:	75 2d                	jne    56a <printf+0xa7>
        printint(fd, *ap, 10, 1);
 53d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 540:	8b 00                	mov    (%eax),%eax
 542:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 549:	00 
 54a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 551:	00 
 552:	89 44 24 04          	mov    %eax,0x4(%esp)
 556:	8b 45 08             	mov    0x8(%ebp),%eax
 559:	89 04 24             	mov    %eax,(%esp)
 55c:	e8 aa fe ff ff       	call   40b <printint>
        ap++;
 561:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 565:	e9 ec 00 00 00       	jmp    656 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 56a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 56e:	74 06                	je     576 <printf+0xb3>
 570:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 574:	75 2d                	jne    5a3 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 576:	8b 45 e8             	mov    -0x18(%ebp),%eax
 579:	8b 00                	mov    (%eax),%eax
 57b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 582:	00 
 583:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 58a:	00 
 58b:	89 44 24 04          	mov    %eax,0x4(%esp)
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
 592:	89 04 24             	mov    %eax,(%esp)
 595:	e8 71 fe ff ff       	call   40b <printint>
        ap++;
 59a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 59e:	e9 b3 00 00 00       	jmp    656 <printf+0x193>
      } else if(c == 's'){
 5a3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5a7:	75 45                	jne    5ee <printf+0x12b>
        s = (char*)*ap;
 5a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ac:	8b 00                	mov    (%eax),%eax
 5ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5b1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5b9:	75 09                	jne    5c4 <printf+0x101>
          s = "(null)";
 5bb:	c7 45 f4 ad 08 00 00 	movl   $0x8ad,-0xc(%ebp)
        while(*s != 0){
 5c2:	eb 1e                	jmp    5e2 <printf+0x11f>
 5c4:	eb 1c                	jmp    5e2 <printf+0x11f>
          putc(fd, *s);
 5c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c9:	0f b6 00             	movzbl (%eax),%eax
 5cc:	0f be c0             	movsbl %al,%eax
 5cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
 5d6:	89 04 24             	mov    %eax,(%esp)
 5d9:	e8 05 fe ff ff       	call   3e3 <putc>
          s++;
 5de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e5:	0f b6 00             	movzbl (%eax),%eax
 5e8:	84 c0                	test   %al,%al
 5ea:	75 da                	jne    5c6 <printf+0x103>
 5ec:	eb 68                	jmp    656 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5ee:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5f2:	75 1d                	jne    611 <printf+0x14e>
        putc(fd, *ap);
 5f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f7:	8b 00                	mov    (%eax),%eax
 5f9:	0f be c0             	movsbl %al,%eax
 5fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 600:	8b 45 08             	mov    0x8(%ebp),%eax
 603:	89 04 24             	mov    %eax,(%esp)
 606:	e8 d8 fd ff ff       	call   3e3 <putc>
        ap++;
 60b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 60f:	eb 45                	jmp    656 <printf+0x193>
      } else if(c == '%'){
 611:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 615:	75 17                	jne    62e <printf+0x16b>
        putc(fd, c);
 617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 61a:	0f be c0             	movsbl %al,%eax
 61d:	89 44 24 04          	mov    %eax,0x4(%esp)
 621:	8b 45 08             	mov    0x8(%ebp),%eax
 624:	89 04 24             	mov    %eax,(%esp)
 627:	e8 b7 fd ff ff       	call   3e3 <putc>
 62c:	eb 28                	jmp    656 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 62e:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 635:	00 
 636:	8b 45 08             	mov    0x8(%ebp),%eax
 639:	89 04 24             	mov    %eax,(%esp)
 63c:	e8 a2 fd ff ff       	call   3e3 <putc>
        putc(fd, c);
 641:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 644:	0f be c0             	movsbl %al,%eax
 647:	89 44 24 04          	mov    %eax,0x4(%esp)
 64b:	8b 45 08             	mov    0x8(%ebp),%eax
 64e:	89 04 24             	mov    %eax,(%esp)
 651:	e8 8d fd ff ff       	call   3e3 <putc>
      }
      state = 0;
 656:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 65d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 661:	8b 55 0c             	mov    0xc(%ebp),%edx
 664:	8b 45 f0             	mov    -0x10(%ebp),%eax
 667:	01 d0                	add    %edx,%eax
 669:	0f b6 00             	movzbl (%eax),%eax
 66c:	84 c0                	test   %al,%al
 66e:	0f 85 71 fe ff ff    	jne    4e5 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 674:	c9                   	leave  
 675:	c3                   	ret    

00000676 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 676:	55                   	push   %ebp
 677:	89 e5                	mov    %esp,%ebp
 679:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 67c:	8b 45 08             	mov    0x8(%ebp),%eax
 67f:	83 e8 08             	sub    $0x8,%eax
 682:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 685:	a1 38 0b 00 00       	mov    0xb38,%eax
 68a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 68d:	eb 24                	jmp    6b3 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 68f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 692:	8b 00                	mov    (%eax),%eax
 694:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 697:	77 12                	ja     6ab <free+0x35>
 699:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 69f:	77 24                	ja     6c5 <free+0x4f>
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a4:	8b 00                	mov    (%eax),%eax
 6a6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6a9:	77 1a                	ja     6c5 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ae:	8b 00                	mov    (%eax),%eax
 6b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6b9:	76 d4                	jbe    68f <free+0x19>
 6bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6be:	8b 00                	mov    (%eax),%eax
 6c0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6c3:	76 ca                	jbe    68f <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c8:	8b 40 04             	mov    0x4(%eax),%eax
 6cb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d5:	01 c2                	add    %eax,%edx
 6d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6da:	8b 00                	mov    (%eax),%eax
 6dc:	39 c2                	cmp    %eax,%edx
 6de:	75 24                	jne    704 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e3:	8b 50 04             	mov    0x4(%eax),%edx
 6e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e9:	8b 00                	mov    (%eax),%eax
 6eb:	8b 40 04             	mov    0x4(%eax),%eax
 6ee:	01 c2                	add    %eax,%edx
 6f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f9:	8b 00                	mov    (%eax),%eax
 6fb:	8b 10                	mov    (%eax),%edx
 6fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 700:	89 10                	mov    %edx,(%eax)
 702:	eb 0a                	jmp    70e <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 704:	8b 45 fc             	mov    -0x4(%ebp),%eax
 707:	8b 10                	mov    (%eax),%edx
 709:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70c:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 70e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 711:	8b 40 04             	mov    0x4(%eax),%eax
 714:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 71b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71e:	01 d0                	add    %edx,%eax
 720:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 723:	75 20                	jne    745 <free+0xcf>
    p->s.size += bp->s.size;
 725:	8b 45 fc             	mov    -0x4(%ebp),%eax
 728:	8b 50 04             	mov    0x4(%eax),%edx
 72b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72e:	8b 40 04             	mov    0x4(%eax),%eax
 731:	01 c2                	add    %eax,%edx
 733:	8b 45 fc             	mov    -0x4(%ebp),%eax
 736:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 739:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73c:	8b 10                	mov    (%eax),%edx
 73e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 741:	89 10                	mov    %edx,(%eax)
 743:	eb 08                	jmp    74d <free+0xd7>
  } else
    p->s.ptr = bp;
 745:	8b 45 fc             	mov    -0x4(%ebp),%eax
 748:	8b 55 f8             	mov    -0x8(%ebp),%edx
 74b:	89 10                	mov    %edx,(%eax)
  freep = p;
 74d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 750:	a3 38 0b 00 00       	mov    %eax,0xb38
}
 755:	c9                   	leave  
 756:	c3                   	ret    

00000757 <morecore>:

static Header*
morecore(uint nu)
{
 757:	55                   	push   %ebp
 758:	89 e5                	mov    %esp,%ebp
 75a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 75d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 764:	77 07                	ja     76d <morecore+0x16>
    nu = 4096;
 766:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 76d:	8b 45 08             	mov    0x8(%ebp),%eax
 770:	c1 e0 03             	shl    $0x3,%eax
 773:	89 04 24             	mov    %eax,(%esp)
 776:	e8 30 fc ff ff       	call   3ab <sbrk>
 77b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 77e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 782:	75 07                	jne    78b <morecore+0x34>
    return 0;
 784:	b8 00 00 00 00       	mov    $0x0,%eax
 789:	eb 22                	jmp    7ad <morecore+0x56>
  hp = (Header*)p;
 78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 791:	8b 45 f0             	mov    -0x10(%ebp),%eax
 794:	8b 55 08             	mov    0x8(%ebp),%edx
 797:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 79a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79d:	83 c0 08             	add    $0x8,%eax
 7a0:	89 04 24             	mov    %eax,(%esp)
 7a3:	e8 ce fe ff ff       	call   676 <free>
  return freep;
 7a8:	a1 38 0b 00 00       	mov    0xb38,%eax
}
 7ad:	c9                   	leave  
 7ae:	c3                   	ret    

000007af <malloc>:

void*
malloc(uint nbytes)
{
 7af:	55                   	push   %ebp
 7b0:	89 e5                	mov    %esp,%ebp
 7b2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b5:	8b 45 08             	mov    0x8(%ebp),%eax
 7b8:	83 c0 07             	add    $0x7,%eax
 7bb:	c1 e8 03             	shr    $0x3,%eax
 7be:	83 c0 01             	add    $0x1,%eax
 7c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7c4:	a1 38 0b 00 00       	mov    0xb38,%eax
 7c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7d0:	75 23                	jne    7f5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7d2:	c7 45 f0 30 0b 00 00 	movl   $0xb30,-0x10(%ebp)
 7d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dc:	a3 38 0b 00 00       	mov    %eax,0xb38
 7e1:	a1 38 0b 00 00       	mov    0xb38,%eax
 7e6:	a3 30 0b 00 00       	mov    %eax,0xb30
    base.s.size = 0;
 7eb:	c7 05 34 0b 00 00 00 	movl   $0x0,0xb34
 7f2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f8:	8b 00                	mov    (%eax),%eax
 7fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 800:	8b 40 04             	mov    0x4(%eax),%eax
 803:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 806:	72 4d                	jb     855 <malloc+0xa6>
      if(p->s.size == nunits)
 808:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80b:	8b 40 04             	mov    0x4(%eax),%eax
 80e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 811:	75 0c                	jne    81f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 813:	8b 45 f4             	mov    -0xc(%ebp),%eax
 816:	8b 10                	mov    (%eax),%edx
 818:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81b:	89 10                	mov    %edx,(%eax)
 81d:	eb 26                	jmp    845 <malloc+0x96>
      else {
        p->s.size -= nunits;
 81f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 822:	8b 40 04             	mov    0x4(%eax),%eax
 825:	2b 45 ec             	sub    -0x14(%ebp),%eax
 828:	89 c2                	mov    %eax,%edx
 82a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 830:	8b 45 f4             	mov    -0xc(%ebp),%eax
 833:	8b 40 04             	mov    0x4(%eax),%eax
 836:	c1 e0 03             	shl    $0x3,%eax
 839:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 842:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 845:	8b 45 f0             	mov    -0x10(%ebp),%eax
 848:	a3 38 0b 00 00       	mov    %eax,0xb38
      return (void*)(p + 1);
 84d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 850:	83 c0 08             	add    $0x8,%eax
 853:	eb 38                	jmp    88d <malloc+0xde>
    }
    if(p == freep)
 855:	a1 38 0b 00 00       	mov    0xb38,%eax
 85a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 85d:	75 1b                	jne    87a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 85f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 862:	89 04 24             	mov    %eax,(%esp)
 865:	e8 ed fe ff ff       	call   757 <morecore>
 86a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 86d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 871:	75 07                	jne    87a <malloc+0xcb>
        return 0;
 873:	b8 00 00 00 00       	mov    $0x0,%eax
 878:	eb 13                	jmp    88d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 880:	8b 45 f4             	mov    -0xc(%ebp),%eax
 883:	8b 00                	mov    (%eax),%eax
 885:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 888:	e9 70 ff ff ff       	jmp    7fd <malloc+0x4e>
}
 88d:	c9                   	leave  
 88e:	c3                   	ret    
