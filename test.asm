
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
 */
#include "types.h"
#include "user.h"


int main(){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp

	if( !fork()){
   9:	e8 2f 03 00 00       	call   33d <fork>
   e:	85 c0                	test   %eax,%eax
  10:	75 19                	jne    2b <main+0x2b>
		printf (1,"fork1\n");
  12:	c7 44 24 04 91 08 00 	movl   $0x891,0x4(%esp)
  19:	00 
  1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  21:	e8 9f 04 00 00       	call   4c5 <printf>
		exit();
  26:	e8 1a 03 00 00       	call   345 <exit>
	}
	printf (1,"father 1\n");
  2b:	c7 44 24 04 98 08 00 	movl   $0x898,0x4(%esp)
  32:	00 
  33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3a:	e8 86 04 00 00       	call   4c5 <printf>
	if( !fork()){
  3f:	e8 f9 02 00 00       	call   33d <fork>
  44:	85 c0                	test   %eax,%eax
  46:	75 16                	jne    5e <main+0x5e>
			printf (1,"fork2\n");
  48:	c7 44 24 04 a2 08 00 	movl   $0x8a2,0x4(%esp)
  4f:	00 
  50:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  57:	e8 69 04 00 00       	call   4c5 <printf>
			for(;;);
  5c:	eb fe                	jmp    5c <main+0x5c>
	}
	printf (1,"father 2\n");
  5e:	c7 44 24 04 a9 08 00 	movl   $0x8a9,0x4(%esp)
  65:	00 
  66:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  6d:	e8 53 04 00 00       	call   4c5 <printf>
	if( !fork()){
  72:	e8 c6 02 00 00       	call   33d <fork>
  77:	85 c0                	test   %eax,%eax
  79:	75 16                	jne    91 <main+0x91>
				printf (1,"fork3\n");
  7b:	c7 44 24 04 b3 08 00 	movl   $0x8b3,0x4(%esp)
  82:	00 
  83:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8a:	e8 36 04 00 00       	call   4c5 <printf>
				for(;;);
  8f:	eb fe                	jmp    8f <main+0x8f>
		}
	printf (1,"father 3\n");
  91:	c7 44 24 04 ba 08 00 	movl   $0x8ba,0x4(%esp)
  98:	00 
  99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a0:	e8 20 04 00 00       	call   4c5 <printf>
	if( !fork()){
  a5:	e8 93 02 00 00       	call   33d <fork>
  aa:	85 c0                	test   %eax,%eax
  ac:	75 16                	jne    c4 <main+0xc4>
				printf (1,"fork4\n");
  ae:	c7 44 24 04 c4 08 00 	movl   $0x8c4,0x4(%esp)
  b5:	00 
  b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  bd:	e8 03 04 00 00       	call   4c5 <printf>
				for(;;);
  c2:	eb fe                	jmp    c2 <main+0xc2>
		}
	printf (1,"father 4\n");
  c4:	c7 44 24 04 cb 08 00 	movl   $0x8cb,0x4(%esp)
  cb:	00 
  cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d3:	e8 ed 03 00 00       	call   4c5 <printf>
	exit();
  d8:	e8 68 02 00 00       	call   345 <exit>

000000dd <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  dd:	55                   	push   %ebp
  de:	89 e5                	mov    %esp,%ebp
  e0:	57                   	push   %edi
  e1:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  e5:	8b 55 10             	mov    0x10(%ebp),%edx
  e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  eb:	89 cb                	mov    %ecx,%ebx
  ed:	89 df                	mov    %ebx,%edi
  ef:	89 d1                	mov    %edx,%ecx
  f1:	fc                   	cld    
  f2:	f3 aa                	rep stos %al,%es:(%edi)
  f4:	89 ca                	mov    %ecx,%edx
  f6:	89 fb                	mov    %edi,%ebx
  f8:	89 5d 08             	mov    %ebx,0x8(%ebp)
  fb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  fe:	5b                   	pop    %ebx
  ff:	5f                   	pop    %edi
 100:	5d                   	pop    %ebp
 101:	c3                   	ret    

00000102 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 102:	55                   	push   %ebp
 103:	89 e5                	mov    %esp,%ebp
 105:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 10e:	90                   	nop
 10f:	8b 45 08             	mov    0x8(%ebp),%eax
 112:	8d 50 01             	lea    0x1(%eax),%edx
 115:	89 55 08             	mov    %edx,0x8(%ebp)
 118:	8b 55 0c             	mov    0xc(%ebp),%edx
 11b:	8d 4a 01             	lea    0x1(%edx),%ecx
 11e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 121:	0f b6 12             	movzbl (%edx),%edx
 124:	88 10                	mov    %dl,(%eax)
 126:	0f b6 00             	movzbl (%eax),%eax
 129:	84 c0                	test   %al,%al
 12b:	75 e2                	jne    10f <strcpy+0xd>
    ;
  return os;
 12d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 130:	c9                   	leave  
 131:	c3                   	ret    

00000132 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 132:	55                   	push   %ebp
 133:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 135:	eb 08                	jmp    13f <strcmp+0xd>
    p++, q++;
 137:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 13b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 13f:	8b 45 08             	mov    0x8(%ebp),%eax
 142:	0f b6 00             	movzbl (%eax),%eax
 145:	84 c0                	test   %al,%al
 147:	74 10                	je     159 <strcmp+0x27>
 149:	8b 45 08             	mov    0x8(%ebp),%eax
 14c:	0f b6 10             	movzbl (%eax),%edx
 14f:	8b 45 0c             	mov    0xc(%ebp),%eax
 152:	0f b6 00             	movzbl (%eax),%eax
 155:	38 c2                	cmp    %al,%dl
 157:	74 de                	je     137 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 159:	8b 45 08             	mov    0x8(%ebp),%eax
 15c:	0f b6 00             	movzbl (%eax),%eax
 15f:	0f b6 d0             	movzbl %al,%edx
 162:	8b 45 0c             	mov    0xc(%ebp),%eax
 165:	0f b6 00             	movzbl (%eax),%eax
 168:	0f b6 c0             	movzbl %al,%eax
 16b:	29 c2                	sub    %eax,%edx
 16d:	89 d0                	mov    %edx,%eax
}
 16f:	5d                   	pop    %ebp
 170:	c3                   	ret    

00000171 <strlen>:

uint
strlen(char *s)
{
 171:	55                   	push   %ebp
 172:	89 e5                	mov    %esp,%ebp
 174:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 177:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 17e:	eb 04                	jmp    184 <strlen+0x13>
 180:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 184:	8b 55 fc             	mov    -0x4(%ebp),%edx
 187:	8b 45 08             	mov    0x8(%ebp),%eax
 18a:	01 d0                	add    %edx,%eax
 18c:	0f b6 00             	movzbl (%eax),%eax
 18f:	84 c0                	test   %al,%al
 191:	75 ed                	jne    180 <strlen+0xf>
    ;
  return n;
 193:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 196:	c9                   	leave  
 197:	c3                   	ret    

00000198 <memset>:

void*
memset(void *dst, int c, uint n)
{
 198:	55                   	push   %ebp
 199:	89 e5                	mov    %esp,%ebp
 19b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 19e:	8b 45 10             	mov    0x10(%ebp),%eax
 1a1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
 1af:	89 04 24             	mov    %eax,(%esp)
 1b2:	e8 26 ff ff ff       	call   dd <stosb>
  return dst;
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ba:	c9                   	leave  
 1bb:	c3                   	ret    

000001bc <strchr>:

char*
strchr(const char *s, char c)
{
 1bc:	55                   	push   %ebp
 1bd:	89 e5                	mov    %esp,%ebp
 1bf:	83 ec 04             	sub    $0x4,%esp
 1c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c5:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1c8:	eb 14                	jmp    1de <strchr+0x22>
    if(*s == c)
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	0f b6 00             	movzbl (%eax),%eax
 1d0:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1d3:	75 05                	jne    1da <strchr+0x1e>
      return (char*)s;
 1d5:	8b 45 08             	mov    0x8(%ebp),%eax
 1d8:	eb 13                	jmp    1ed <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1da:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	0f b6 00             	movzbl (%eax),%eax
 1e4:	84 c0                	test   %al,%al
 1e6:	75 e2                	jne    1ca <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1ed:	c9                   	leave  
 1ee:	c3                   	ret    

000001ef <gets>:

char*
gets(char *buf, int max)
{
 1ef:	55                   	push   %ebp
 1f0:	89 e5                	mov    %esp,%ebp
 1f2:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1fc:	eb 4c                	jmp    24a <gets+0x5b>
    cc = read(0, &c, 1);
 1fe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 205:	00 
 206:	8d 45 ef             	lea    -0x11(%ebp),%eax
 209:	89 44 24 04          	mov    %eax,0x4(%esp)
 20d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 214:	e8 44 01 00 00       	call   35d <read>
 219:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 21c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 220:	7f 02                	jg     224 <gets+0x35>
      break;
 222:	eb 31                	jmp    255 <gets+0x66>
    buf[i++] = c;
 224:	8b 45 f4             	mov    -0xc(%ebp),%eax
 227:	8d 50 01             	lea    0x1(%eax),%edx
 22a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 22d:	89 c2                	mov    %eax,%edx
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
 232:	01 c2                	add    %eax,%edx
 234:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 238:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 23a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 23e:	3c 0a                	cmp    $0xa,%al
 240:	74 13                	je     255 <gets+0x66>
 242:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 246:	3c 0d                	cmp    $0xd,%al
 248:	74 0b                	je     255 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 24a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24d:	83 c0 01             	add    $0x1,%eax
 250:	3b 45 0c             	cmp    0xc(%ebp),%eax
 253:	7c a9                	jl     1fe <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 255:	8b 55 f4             	mov    -0xc(%ebp),%edx
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	01 d0                	add    %edx,%eax
 25d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 260:	8b 45 08             	mov    0x8(%ebp),%eax
}
 263:	c9                   	leave  
 264:	c3                   	ret    

00000265 <stat>:

int
stat(char *n, struct stat *st)
{
 265:	55                   	push   %ebp
 266:	89 e5                	mov    %esp,%ebp
 268:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 26b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 272:	00 
 273:	8b 45 08             	mov    0x8(%ebp),%eax
 276:	89 04 24             	mov    %eax,(%esp)
 279:	e8 07 01 00 00       	call   385 <open>
 27e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 281:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 285:	79 07                	jns    28e <stat+0x29>
    return -1;
 287:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 28c:	eb 23                	jmp    2b1 <stat+0x4c>
  r = fstat(fd, st);
 28e:	8b 45 0c             	mov    0xc(%ebp),%eax
 291:	89 44 24 04          	mov    %eax,0x4(%esp)
 295:	8b 45 f4             	mov    -0xc(%ebp),%eax
 298:	89 04 24             	mov    %eax,(%esp)
 29b:	e8 fd 00 00 00       	call   39d <fstat>
 2a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a6:	89 04 24             	mov    %eax,(%esp)
 2a9:	e8 bf 00 00 00       	call   36d <close>
  return r;
 2ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2b1:	c9                   	leave  
 2b2:	c3                   	ret    

000002b3 <atoi>:

int
atoi(const char *s)
{
 2b3:	55                   	push   %ebp
 2b4:	89 e5                	mov    %esp,%ebp
 2b6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2b9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2c0:	eb 25                	jmp    2e7 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2c2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2c5:	89 d0                	mov    %edx,%eax
 2c7:	c1 e0 02             	shl    $0x2,%eax
 2ca:	01 d0                	add    %edx,%eax
 2cc:	01 c0                	add    %eax,%eax
 2ce:	89 c1                	mov    %eax,%ecx
 2d0:	8b 45 08             	mov    0x8(%ebp),%eax
 2d3:	8d 50 01             	lea    0x1(%eax),%edx
 2d6:	89 55 08             	mov    %edx,0x8(%ebp)
 2d9:	0f b6 00             	movzbl (%eax),%eax
 2dc:	0f be c0             	movsbl %al,%eax
 2df:	01 c8                	add    %ecx,%eax
 2e1:	83 e8 30             	sub    $0x30,%eax
 2e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ea:	0f b6 00             	movzbl (%eax),%eax
 2ed:	3c 2f                	cmp    $0x2f,%al
 2ef:	7e 0a                	jle    2fb <atoi+0x48>
 2f1:	8b 45 08             	mov    0x8(%ebp),%eax
 2f4:	0f b6 00             	movzbl (%eax),%eax
 2f7:	3c 39                	cmp    $0x39,%al
 2f9:	7e c7                	jle    2c2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2fe:	c9                   	leave  
 2ff:	c3                   	ret    

00000300 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 306:	8b 45 08             	mov    0x8(%ebp),%eax
 309:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 30c:	8b 45 0c             	mov    0xc(%ebp),%eax
 30f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 312:	eb 17                	jmp    32b <memmove+0x2b>
    *dst++ = *src++;
 314:	8b 45 fc             	mov    -0x4(%ebp),%eax
 317:	8d 50 01             	lea    0x1(%eax),%edx
 31a:	89 55 fc             	mov    %edx,-0x4(%ebp)
 31d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 320:	8d 4a 01             	lea    0x1(%edx),%ecx
 323:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 326:	0f b6 12             	movzbl (%edx),%edx
 329:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 32b:	8b 45 10             	mov    0x10(%ebp),%eax
 32e:	8d 50 ff             	lea    -0x1(%eax),%edx
 331:	89 55 10             	mov    %edx,0x10(%ebp)
 334:	85 c0                	test   %eax,%eax
 336:	7f dc                	jg     314 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 338:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33b:	c9                   	leave  
 33c:	c3                   	ret    

0000033d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 33d:	b8 01 00 00 00       	mov    $0x1,%eax
 342:	cd 40                	int    $0x40
 344:	c3                   	ret    

00000345 <exit>:
SYSCALL(exit)
 345:	b8 02 00 00 00       	mov    $0x2,%eax
 34a:	cd 40                	int    $0x40
 34c:	c3                   	ret    

0000034d <wait>:
SYSCALL(wait)
 34d:	b8 03 00 00 00       	mov    $0x3,%eax
 352:	cd 40                	int    $0x40
 354:	c3                   	ret    

00000355 <pipe>:
SYSCALL(pipe)
 355:	b8 04 00 00 00       	mov    $0x4,%eax
 35a:	cd 40                	int    $0x40
 35c:	c3                   	ret    

0000035d <read>:
SYSCALL(read)
 35d:	b8 05 00 00 00       	mov    $0x5,%eax
 362:	cd 40                	int    $0x40
 364:	c3                   	ret    

00000365 <write>:
SYSCALL(write)
 365:	b8 10 00 00 00       	mov    $0x10,%eax
 36a:	cd 40                	int    $0x40
 36c:	c3                   	ret    

0000036d <close>:
SYSCALL(close)
 36d:	b8 15 00 00 00       	mov    $0x15,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <kill>:
SYSCALL(kill)
 375:	b8 06 00 00 00       	mov    $0x6,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <exec>:
SYSCALL(exec)
 37d:	b8 07 00 00 00       	mov    $0x7,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <open>:
SYSCALL(open)
 385:	b8 0f 00 00 00       	mov    $0xf,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <mknod>:
SYSCALL(mknod)
 38d:	b8 11 00 00 00       	mov    $0x11,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <unlink>:
SYSCALL(unlink)
 395:	b8 12 00 00 00       	mov    $0x12,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <fstat>:
SYSCALL(fstat)
 39d:	b8 08 00 00 00       	mov    $0x8,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <link>:
SYSCALL(link)
 3a5:	b8 13 00 00 00       	mov    $0x13,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <mkdir>:
SYSCALL(mkdir)
 3ad:	b8 14 00 00 00       	mov    $0x14,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <chdir>:
SYSCALL(chdir)
 3b5:	b8 09 00 00 00       	mov    $0x9,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <dup>:
SYSCALL(dup)
 3bd:	b8 0a 00 00 00       	mov    $0xa,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <getpid>:
SYSCALL(getpid)
 3c5:	b8 0b 00 00 00       	mov    $0xb,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <sbrk>:
SYSCALL(sbrk)
 3cd:	b8 0c 00 00 00       	mov    $0xc,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <sleep>:
SYSCALL(sleep)
 3d5:	b8 0d 00 00 00       	mov    $0xd,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <uptime>:
SYSCALL(uptime)
 3dd:	b8 0e 00 00 00       	mov    $0xe,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3e5:	55                   	push   %ebp
 3e6:	89 e5                	mov    %esp,%ebp
 3e8:	83 ec 18             	sub    $0x18,%esp
 3eb:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ee:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3f1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3f8:	00 
 3f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 400:	8b 45 08             	mov    0x8(%ebp),%eax
 403:	89 04 24             	mov    %eax,(%esp)
 406:	e8 5a ff ff ff       	call   365 <write>
}
 40b:	c9                   	leave  
 40c:	c3                   	ret    

0000040d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 40d:	55                   	push   %ebp
 40e:	89 e5                	mov    %esp,%ebp
 410:	56                   	push   %esi
 411:	53                   	push   %ebx
 412:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 415:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 41c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 420:	74 17                	je     439 <printint+0x2c>
 422:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 426:	79 11                	jns    439 <printint+0x2c>
    neg = 1;
 428:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 42f:	8b 45 0c             	mov    0xc(%ebp),%eax
 432:	f7 d8                	neg    %eax
 434:	89 45 ec             	mov    %eax,-0x14(%ebp)
 437:	eb 06                	jmp    43f <printint+0x32>
  } else {
    x = xx;
 439:	8b 45 0c             	mov    0xc(%ebp),%eax
 43c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 43f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 446:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 449:	8d 41 01             	lea    0x1(%ecx),%eax
 44c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 44f:	8b 5d 10             	mov    0x10(%ebp),%ebx
 452:	8b 45 ec             	mov    -0x14(%ebp),%eax
 455:	ba 00 00 00 00       	mov    $0x0,%edx
 45a:	f7 f3                	div    %ebx
 45c:	89 d0                	mov    %edx,%eax
 45e:	0f b6 80 20 0b 00 00 	movzbl 0xb20(%eax),%eax
 465:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 469:	8b 75 10             	mov    0x10(%ebp),%esi
 46c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 46f:	ba 00 00 00 00       	mov    $0x0,%edx
 474:	f7 f6                	div    %esi
 476:	89 45 ec             	mov    %eax,-0x14(%ebp)
 479:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 47d:	75 c7                	jne    446 <printint+0x39>
  if(neg)
 47f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 483:	74 10                	je     495 <printint+0x88>
    buf[i++] = '-';
 485:	8b 45 f4             	mov    -0xc(%ebp),%eax
 488:	8d 50 01             	lea    0x1(%eax),%edx
 48b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 48e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 493:	eb 1f                	jmp    4b4 <printint+0xa7>
 495:	eb 1d                	jmp    4b4 <printint+0xa7>
    putc(fd, buf[i]);
 497:	8d 55 dc             	lea    -0x24(%ebp),%edx
 49a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49d:	01 d0                	add    %edx,%eax
 49f:	0f b6 00             	movzbl (%eax),%eax
 4a2:	0f be c0             	movsbl %al,%eax
 4a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 4a9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ac:	89 04 24             	mov    %eax,(%esp)
 4af:	e8 31 ff ff ff       	call   3e5 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4b4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4bc:	79 d9                	jns    497 <printint+0x8a>
    putc(fd, buf[i]);
}
 4be:	83 c4 30             	add    $0x30,%esp
 4c1:	5b                   	pop    %ebx
 4c2:	5e                   	pop    %esi
 4c3:	5d                   	pop    %ebp
 4c4:	c3                   	ret    

000004c5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4c5:	55                   	push   %ebp
 4c6:	89 e5                	mov    %esp,%ebp
 4c8:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4cb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4d2:	8d 45 0c             	lea    0xc(%ebp),%eax
 4d5:	83 c0 04             	add    $0x4,%eax
 4d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4db:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4e2:	e9 7c 01 00 00       	jmp    663 <printf+0x19e>
    c = fmt[i] & 0xff;
 4e7:	8b 55 0c             	mov    0xc(%ebp),%edx
 4ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4ed:	01 d0                	add    %edx,%eax
 4ef:	0f b6 00             	movzbl (%eax),%eax
 4f2:	0f be c0             	movsbl %al,%eax
 4f5:	25 ff 00 00 00       	and    $0xff,%eax
 4fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 501:	75 2c                	jne    52f <printf+0x6a>
      if(c == '%'){
 503:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 507:	75 0c                	jne    515 <printf+0x50>
        state = '%';
 509:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 510:	e9 4a 01 00 00       	jmp    65f <printf+0x19a>
      } else {
        putc(fd, c);
 515:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 518:	0f be c0             	movsbl %al,%eax
 51b:	89 44 24 04          	mov    %eax,0x4(%esp)
 51f:	8b 45 08             	mov    0x8(%ebp),%eax
 522:	89 04 24             	mov    %eax,(%esp)
 525:	e8 bb fe ff ff       	call   3e5 <putc>
 52a:	e9 30 01 00 00       	jmp    65f <printf+0x19a>
      }
    } else if(state == '%'){
 52f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 533:	0f 85 26 01 00 00    	jne    65f <printf+0x19a>
      if(c == 'd'){
 539:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 53d:	75 2d                	jne    56c <printf+0xa7>
        printint(fd, *ap, 10, 1);
 53f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 542:	8b 00                	mov    (%eax),%eax
 544:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 54b:	00 
 54c:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 553:	00 
 554:	89 44 24 04          	mov    %eax,0x4(%esp)
 558:	8b 45 08             	mov    0x8(%ebp),%eax
 55b:	89 04 24             	mov    %eax,(%esp)
 55e:	e8 aa fe ff ff       	call   40d <printint>
        ap++;
 563:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 567:	e9 ec 00 00 00       	jmp    658 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 56c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 570:	74 06                	je     578 <printf+0xb3>
 572:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 576:	75 2d                	jne    5a5 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 578:	8b 45 e8             	mov    -0x18(%ebp),%eax
 57b:	8b 00                	mov    (%eax),%eax
 57d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 584:	00 
 585:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 58c:	00 
 58d:	89 44 24 04          	mov    %eax,0x4(%esp)
 591:	8b 45 08             	mov    0x8(%ebp),%eax
 594:	89 04 24             	mov    %eax,(%esp)
 597:	e8 71 fe ff ff       	call   40d <printint>
        ap++;
 59c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a0:	e9 b3 00 00 00       	jmp    658 <printf+0x193>
      } else if(c == 's'){
 5a5:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5a9:	75 45                	jne    5f0 <printf+0x12b>
        s = (char*)*ap;
 5ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ae:	8b 00                	mov    (%eax),%eax
 5b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5b3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5bb:	75 09                	jne    5c6 <printf+0x101>
          s = "(null)";
 5bd:	c7 45 f4 d5 08 00 00 	movl   $0x8d5,-0xc(%ebp)
        while(*s != 0){
 5c4:	eb 1e                	jmp    5e4 <printf+0x11f>
 5c6:	eb 1c                	jmp    5e4 <printf+0x11f>
          putc(fd, *s);
 5c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5cb:	0f b6 00             	movzbl (%eax),%eax
 5ce:	0f be c0             	movsbl %al,%eax
 5d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d5:	8b 45 08             	mov    0x8(%ebp),%eax
 5d8:	89 04 24             	mov    %eax,(%esp)
 5db:	e8 05 fe ff ff       	call   3e5 <putc>
          s++;
 5e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e7:	0f b6 00             	movzbl (%eax),%eax
 5ea:	84 c0                	test   %al,%al
 5ec:	75 da                	jne    5c8 <printf+0x103>
 5ee:	eb 68                	jmp    658 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5f0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5f4:	75 1d                	jne    613 <printf+0x14e>
        putc(fd, *ap);
 5f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f9:	8b 00                	mov    (%eax),%eax
 5fb:	0f be c0             	movsbl %al,%eax
 5fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 602:	8b 45 08             	mov    0x8(%ebp),%eax
 605:	89 04 24             	mov    %eax,(%esp)
 608:	e8 d8 fd ff ff       	call   3e5 <putc>
        ap++;
 60d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 611:	eb 45                	jmp    658 <printf+0x193>
      } else if(c == '%'){
 613:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 617:	75 17                	jne    630 <printf+0x16b>
        putc(fd, c);
 619:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 61c:	0f be c0             	movsbl %al,%eax
 61f:	89 44 24 04          	mov    %eax,0x4(%esp)
 623:	8b 45 08             	mov    0x8(%ebp),%eax
 626:	89 04 24             	mov    %eax,(%esp)
 629:	e8 b7 fd ff ff       	call   3e5 <putc>
 62e:	eb 28                	jmp    658 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 630:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 637:	00 
 638:	8b 45 08             	mov    0x8(%ebp),%eax
 63b:	89 04 24             	mov    %eax,(%esp)
 63e:	e8 a2 fd ff ff       	call   3e5 <putc>
        putc(fd, c);
 643:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 646:	0f be c0             	movsbl %al,%eax
 649:	89 44 24 04          	mov    %eax,0x4(%esp)
 64d:	8b 45 08             	mov    0x8(%ebp),%eax
 650:	89 04 24             	mov    %eax,(%esp)
 653:	e8 8d fd ff ff       	call   3e5 <putc>
      }
      state = 0;
 658:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 65f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 663:	8b 55 0c             	mov    0xc(%ebp),%edx
 666:	8b 45 f0             	mov    -0x10(%ebp),%eax
 669:	01 d0                	add    %edx,%eax
 66b:	0f b6 00             	movzbl (%eax),%eax
 66e:	84 c0                	test   %al,%al
 670:	0f 85 71 fe ff ff    	jne    4e7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 676:	c9                   	leave  
 677:	c3                   	ret    

00000678 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 678:	55                   	push   %ebp
 679:	89 e5                	mov    %esp,%ebp
 67b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 67e:	8b 45 08             	mov    0x8(%ebp),%eax
 681:	83 e8 08             	sub    $0x8,%eax
 684:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 687:	a1 3c 0b 00 00       	mov    0xb3c,%eax
 68c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 68f:	eb 24                	jmp    6b5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 691:	8b 45 fc             	mov    -0x4(%ebp),%eax
 694:	8b 00                	mov    (%eax),%eax
 696:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 699:	77 12                	ja     6ad <free+0x35>
 69b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a1:	77 24                	ja     6c7 <free+0x4f>
 6a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a6:	8b 00                	mov    (%eax),%eax
 6a8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ab:	77 1a                	ja     6c7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b0:	8b 00                	mov    (%eax),%eax
 6b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6bb:	76 d4                	jbe    691 <free+0x19>
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	8b 00                	mov    (%eax),%eax
 6c2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6c5:	76 ca                	jbe    691 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ca:	8b 40 04             	mov    0x4(%eax),%eax
 6cd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d7:	01 c2                	add    %eax,%edx
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dc:	8b 00                	mov    (%eax),%eax
 6de:	39 c2                	cmp    %eax,%edx
 6e0:	75 24                	jne    706 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e5:	8b 50 04             	mov    0x4(%eax),%edx
 6e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6eb:	8b 00                	mov    (%eax),%eax
 6ed:	8b 40 04             	mov    0x4(%eax),%eax
 6f0:	01 c2                	add    %eax,%edx
 6f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fb:	8b 00                	mov    (%eax),%eax
 6fd:	8b 10                	mov    (%eax),%edx
 6ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 702:	89 10                	mov    %edx,(%eax)
 704:	eb 0a                	jmp    710 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 706:	8b 45 fc             	mov    -0x4(%ebp),%eax
 709:	8b 10                	mov    (%eax),%edx
 70b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 710:	8b 45 fc             	mov    -0x4(%ebp),%eax
 713:	8b 40 04             	mov    0x4(%eax),%eax
 716:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 71d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 720:	01 d0                	add    %edx,%eax
 722:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 725:	75 20                	jne    747 <free+0xcf>
    p->s.size += bp->s.size;
 727:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72a:	8b 50 04             	mov    0x4(%eax),%edx
 72d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 730:	8b 40 04             	mov    0x4(%eax),%eax
 733:	01 c2                	add    %eax,%edx
 735:	8b 45 fc             	mov    -0x4(%ebp),%eax
 738:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 73b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73e:	8b 10                	mov    (%eax),%edx
 740:	8b 45 fc             	mov    -0x4(%ebp),%eax
 743:	89 10                	mov    %edx,(%eax)
 745:	eb 08                	jmp    74f <free+0xd7>
  } else
    p->s.ptr = bp;
 747:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 74d:	89 10                	mov    %edx,(%eax)
  freep = p;
 74f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 752:	a3 3c 0b 00 00       	mov    %eax,0xb3c
}
 757:	c9                   	leave  
 758:	c3                   	ret    

00000759 <morecore>:

static Header*
morecore(uint nu)
{
 759:	55                   	push   %ebp
 75a:	89 e5                	mov    %esp,%ebp
 75c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 75f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 766:	77 07                	ja     76f <morecore+0x16>
    nu = 4096;
 768:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 76f:	8b 45 08             	mov    0x8(%ebp),%eax
 772:	c1 e0 03             	shl    $0x3,%eax
 775:	89 04 24             	mov    %eax,(%esp)
 778:	e8 50 fc ff ff       	call   3cd <sbrk>
 77d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 780:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 784:	75 07                	jne    78d <morecore+0x34>
    return 0;
 786:	b8 00 00 00 00       	mov    $0x0,%eax
 78b:	eb 22                	jmp    7af <morecore+0x56>
  hp = (Header*)p;
 78d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 790:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 793:	8b 45 f0             	mov    -0x10(%ebp),%eax
 796:	8b 55 08             	mov    0x8(%ebp),%edx
 799:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 79c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79f:	83 c0 08             	add    $0x8,%eax
 7a2:	89 04 24             	mov    %eax,(%esp)
 7a5:	e8 ce fe ff ff       	call   678 <free>
  return freep;
 7aa:	a1 3c 0b 00 00       	mov    0xb3c,%eax
}
 7af:	c9                   	leave  
 7b0:	c3                   	ret    

000007b1 <malloc>:

void*
malloc(uint nbytes)
{
 7b1:	55                   	push   %ebp
 7b2:	89 e5                	mov    %esp,%ebp
 7b4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ba:	83 c0 07             	add    $0x7,%eax
 7bd:	c1 e8 03             	shr    $0x3,%eax
 7c0:	83 c0 01             	add    $0x1,%eax
 7c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7c6:	a1 3c 0b 00 00       	mov    0xb3c,%eax
 7cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7d2:	75 23                	jne    7f7 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7d4:	c7 45 f0 34 0b 00 00 	movl   $0xb34,-0x10(%ebp)
 7db:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7de:	a3 3c 0b 00 00       	mov    %eax,0xb3c
 7e3:	a1 3c 0b 00 00       	mov    0xb3c,%eax
 7e8:	a3 34 0b 00 00       	mov    %eax,0xb34
    base.s.size = 0;
 7ed:	c7 05 38 0b 00 00 00 	movl   $0x0,0xb38
 7f4:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fa:	8b 00                	mov    (%eax),%eax
 7fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 802:	8b 40 04             	mov    0x4(%eax),%eax
 805:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 808:	72 4d                	jb     857 <malloc+0xa6>
      if(p->s.size == nunits)
 80a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80d:	8b 40 04             	mov    0x4(%eax),%eax
 810:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 813:	75 0c                	jne    821 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 815:	8b 45 f4             	mov    -0xc(%ebp),%eax
 818:	8b 10                	mov    (%eax),%edx
 81a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81d:	89 10                	mov    %edx,(%eax)
 81f:	eb 26                	jmp    847 <malloc+0x96>
      else {
        p->s.size -= nunits;
 821:	8b 45 f4             	mov    -0xc(%ebp),%eax
 824:	8b 40 04             	mov    0x4(%eax),%eax
 827:	2b 45 ec             	sub    -0x14(%ebp),%eax
 82a:	89 c2                	mov    %eax,%edx
 82c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 832:	8b 45 f4             	mov    -0xc(%ebp),%eax
 835:	8b 40 04             	mov    0x4(%eax),%eax
 838:	c1 e0 03             	shl    $0x3,%eax
 83b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 83e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 841:	8b 55 ec             	mov    -0x14(%ebp),%edx
 844:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 847:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84a:	a3 3c 0b 00 00       	mov    %eax,0xb3c
      return (void*)(p + 1);
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	83 c0 08             	add    $0x8,%eax
 855:	eb 38                	jmp    88f <malloc+0xde>
    }
    if(p == freep)
 857:	a1 3c 0b 00 00       	mov    0xb3c,%eax
 85c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 85f:	75 1b                	jne    87c <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 861:	8b 45 ec             	mov    -0x14(%ebp),%eax
 864:	89 04 24             	mov    %eax,(%esp)
 867:	e8 ed fe ff ff       	call   759 <morecore>
 86c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 86f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 873:	75 07                	jne    87c <malloc+0xcb>
        return 0;
 875:	b8 00 00 00 00       	mov    $0x0,%eax
 87a:	eb 13                	jmp    88f <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 882:	8b 45 f4             	mov    -0xc(%ebp),%eax
 885:	8b 00                	mov    (%eax),%eax
 887:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 88a:	e9 70 ff ff ff       	jmp    7ff <malloc+0x4e>
}
 88f:	c9                   	leave  
 890:	c3                   	ret    
