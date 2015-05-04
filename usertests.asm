
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <iputtest>:
int stdout = 1;

// does chdir() call iput(p->cwd) in a transaction?
void
iputtest(void)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "iput test\n");
       6:	a1 2c 63 00 00       	mov    0x632c,%eax
       b:	c7 44 24 04 4e 44 00 	movl   $0x444e,0x4(%esp)
      12:	00 
      13:	89 04 24             	mov    %eax,(%esp)
      16:	e8 51 40 00 00       	call   406c <printf>

  if(mkdir("iputdir") < 0){
      1b:	c7 04 24 59 44 00 00 	movl   $0x4459,(%esp)
      22:	e8 2d 3f 00 00       	call   3f54 <mkdir>
      27:	85 c0                	test   %eax,%eax
      29:	79 1a                	jns    45 <iputtest+0x45>
    printf(stdout, "mkdir failed\n");
      2b:	a1 2c 63 00 00       	mov    0x632c,%eax
      30:	c7 44 24 04 61 44 00 	movl   $0x4461,0x4(%esp)
      37:	00 
      38:	89 04 24             	mov    %eax,(%esp)
      3b:	e8 2c 40 00 00       	call   406c <printf>
    exit();
      40:	e8 a7 3e 00 00       	call   3eec <exit>
  }
  if(chdir("iputdir") < 0){
      45:	c7 04 24 59 44 00 00 	movl   $0x4459,(%esp)
      4c:	e8 0b 3f 00 00       	call   3f5c <chdir>
      51:	85 c0                	test   %eax,%eax
      53:	79 1a                	jns    6f <iputtest+0x6f>
    printf(stdout, "chdir iputdir failed\n");
      55:	a1 2c 63 00 00       	mov    0x632c,%eax
      5a:	c7 44 24 04 6f 44 00 	movl   $0x446f,0x4(%esp)
      61:	00 
      62:	89 04 24             	mov    %eax,(%esp)
      65:	e8 02 40 00 00       	call   406c <printf>
    exit();
      6a:	e8 7d 3e 00 00       	call   3eec <exit>
  }
  if(unlink("../iputdir") < 0){
      6f:	c7 04 24 85 44 00 00 	movl   $0x4485,(%esp)
      76:	e8 c1 3e 00 00       	call   3f3c <unlink>
      7b:	85 c0                	test   %eax,%eax
      7d:	79 1a                	jns    99 <iputtest+0x99>
    printf(stdout, "unlink ../iputdir failed\n");
      7f:	a1 2c 63 00 00       	mov    0x632c,%eax
      84:	c7 44 24 04 90 44 00 	movl   $0x4490,0x4(%esp)
      8b:	00 
      8c:	89 04 24             	mov    %eax,(%esp)
      8f:	e8 d8 3f 00 00       	call   406c <printf>
    exit();
      94:	e8 53 3e 00 00       	call   3eec <exit>
  }
  if(chdir("/") < 0){
      99:	c7 04 24 aa 44 00 00 	movl   $0x44aa,(%esp)
      a0:	e8 b7 3e 00 00       	call   3f5c <chdir>
      a5:	85 c0                	test   %eax,%eax
      a7:	79 1a                	jns    c3 <iputtest+0xc3>
    printf(stdout, "chdir / failed\n");
      a9:	a1 2c 63 00 00       	mov    0x632c,%eax
      ae:	c7 44 24 04 ac 44 00 	movl   $0x44ac,0x4(%esp)
      b5:	00 
      b6:	89 04 24             	mov    %eax,(%esp)
      b9:	e8 ae 3f 00 00       	call   406c <printf>
    exit();
      be:	e8 29 3e 00 00       	call   3eec <exit>
  }
  printf(stdout, "iput test ok\n");
      c3:	a1 2c 63 00 00       	mov    0x632c,%eax
      c8:	c7 44 24 04 bc 44 00 	movl   $0x44bc,0x4(%esp)
      cf:	00 
      d0:	89 04 24             	mov    %eax,(%esp)
      d3:	e8 94 3f 00 00       	call   406c <printf>
}
      d8:	c9                   	leave  
      d9:	c3                   	ret    

000000da <exitiputtest>:

// does exit() call iput(p->cwd) in a transaction?
void
exitiputtest(void)
{
      da:	55                   	push   %ebp
      db:	89 e5                	mov    %esp,%ebp
      dd:	83 ec 28             	sub    $0x28,%esp
  int pid;

  printf(stdout, "exitiput test\n");
      e0:	a1 2c 63 00 00       	mov    0x632c,%eax
      e5:	c7 44 24 04 ca 44 00 	movl   $0x44ca,0x4(%esp)
      ec:	00 
      ed:	89 04 24             	mov    %eax,(%esp)
      f0:	e8 77 3f 00 00       	call   406c <printf>

  pid = fork();
      f5:	e8 ea 3d 00 00       	call   3ee4 <fork>
      fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
      fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     101:	79 1a                	jns    11d <exitiputtest+0x43>
    printf(stdout, "fork failed\n");
     103:	a1 2c 63 00 00       	mov    0x632c,%eax
     108:	c7 44 24 04 d9 44 00 	movl   $0x44d9,0x4(%esp)
     10f:	00 
     110:	89 04 24             	mov    %eax,(%esp)
     113:	e8 54 3f 00 00       	call   406c <printf>
    exit();
     118:	e8 cf 3d 00 00       	call   3eec <exit>
  }
  if(pid == 0){
     11d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     121:	0f 85 83 00 00 00    	jne    1aa <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
     127:	c7 04 24 59 44 00 00 	movl   $0x4459,(%esp)
     12e:	e8 21 3e 00 00       	call   3f54 <mkdir>
     133:	85 c0                	test   %eax,%eax
     135:	79 1a                	jns    151 <exitiputtest+0x77>
      printf(stdout, "mkdir failed\n");
     137:	a1 2c 63 00 00       	mov    0x632c,%eax
     13c:	c7 44 24 04 61 44 00 	movl   $0x4461,0x4(%esp)
     143:	00 
     144:	89 04 24             	mov    %eax,(%esp)
     147:	e8 20 3f 00 00       	call   406c <printf>
      exit();
     14c:	e8 9b 3d 00 00       	call   3eec <exit>
    }
    if(chdir("iputdir") < 0){
     151:	c7 04 24 59 44 00 00 	movl   $0x4459,(%esp)
     158:	e8 ff 3d 00 00       	call   3f5c <chdir>
     15d:	85 c0                	test   %eax,%eax
     15f:	79 1a                	jns    17b <exitiputtest+0xa1>
      printf(stdout, "child chdir failed\n");
     161:	a1 2c 63 00 00       	mov    0x632c,%eax
     166:	c7 44 24 04 e6 44 00 	movl   $0x44e6,0x4(%esp)
     16d:	00 
     16e:	89 04 24             	mov    %eax,(%esp)
     171:	e8 f6 3e 00 00       	call   406c <printf>
      exit();
     176:	e8 71 3d 00 00       	call   3eec <exit>
    }
    if(unlink("../iputdir") < 0){
     17b:	c7 04 24 85 44 00 00 	movl   $0x4485,(%esp)
     182:	e8 b5 3d 00 00       	call   3f3c <unlink>
     187:	85 c0                	test   %eax,%eax
     189:	79 1a                	jns    1a5 <exitiputtest+0xcb>
      printf(stdout, "unlink ../iputdir failed\n");
     18b:	a1 2c 63 00 00       	mov    0x632c,%eax
     190:	c7 44 24 04 90 44 00 	movl   $0x4490,0x4(%esp)
     197:	00 
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 cc 3e 00 00       	call   406c <printf>
      exit();
     1a0:	e8 47 3d 00 00       	call   3eec <exit>
    }
    exit();
     1a5:	e8 42 3d 00 00       	call   3eec <exit>
  }
  wait();
     1aa:	e8 45 3d 00 00       	call   3ef4 <wait>
  printf(stdout, "exitiput test ok\n");
     1af:	a1 2c 63 00 00       	mov    0x632c,%eax
     1b4:	c7 44 24 04 fa 44 00 	movl   $0x44fa,0x4(%esp)
     1bb:	00 
     1bc:	89 04 24             	mov    %eax,(%esp)
     1bf:	e8 a8 3e 00 00       	call   406c <printf>
}
     1c4:	c9                   	leave  
     1c5:	c3                   	ret    

000001c6 <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(void)
{
     1c6:	55                   	push   %ebp
     1c7:	89 e5                	mov    %esp,%ebp
     1c9:	83 ec 28             	sub    $0x28,%esp
  int pid;

  printf(stdout, "openiput test\n");
     1cc:	a1 2c 63 00 00       	mov    0x632c,%eax
     1d1:	c7 44 24 04 0c 45 00 	movl   $0x450c,0x4(%esp)
     1d8:	00 
     1d9:	89 04 24             	mov    %eax,(%esp)
     1dc:	e8 8b 3e 00 00       	call   406c <printf>
  if(mkdir("oidir") < 0){
     1e1:	c7 04 24 1b 45 00 00 	movl   $0x451b,(%esp)
     1e8:	e8 67 3d 00 00       	call   3f54 <mkdir>
     1ed:	85 c0                	test   %eax,%eax
     1ef:	79 1a                	jns    20b <openiputtest+0x45>
    printf(stdout, "mkdir oidir failed\n");
     1f1:	a1 2c 63 00 00       	mov    0x632c,%eax
     1f6:	c7 44 24 04 21 45 00 	movl   $0x4521,0x4(%esp)
     1fd:	00 
     1fe:	89 04 24             	mov    %eax,(%esp)
     201:	e8 66 3e 00 00       	call   406c <printf>
    exit();
     206:	e8 e1 3c 00 00       	call   3eec <exit>
  }
  pid = fork();
     20b:	e8 d4 3c 00 00       	call   3ee4 <fork>
     210:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
     213:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     217:	79 1a                	jns    233 <openiputtest+0x6d>
    printf(stdout, "fork failed\n");
     219:	a1 2c 63 00 00       	mov    0x632c,%eax
     21e:	c7 44 24 04 d9 44 00 	movl   $0x44d9,0x4(%esp)
     225:	00 
     226:	89 04 24             	mov    %eax,(%esp)
     229:	e8 3e 3e 00 00       	call   406c <printf>
    exit();
     22e:	e8 b9 3c 00 00       	call   3eec <exit>
  }
  if(pid == 0){
     233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     237:	75 3c                	jne    275 <openiputtest+0xaf>
    int fd = open("oidir", O_RDWR);
     239:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     240:	00 
     241:	c7 04 24 1b 45 00 00 	movl   $0x451b,(%esp)
     248:	e8 df 3c 00 00       	call   3f2c <open>
     24d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0){
     250:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     254:	78 1a                	js     270 <openiputtest+0xaa>
      printf(stdout, "open directory for write succeeded\n");
     256:	a1 2c 63 00 00       	mov    0x632c,%eax
     25b:	c7 44 24 04 38 45 00 	movl   $0x4538,0x4(%esp)
     262:	00 
     263:	89 04 24             	mov    %eax,(%esp)
     266:	e8 01 3e 00 00       	call   406c <printf>
      exit();
     26b:	e8 7c 3c 00 00       	call   3eec <exit>
    }
    exit();
     270:	e8 77 3c 00 00       	call   3eec <exit>
  }
  sleep(1);
     275:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     27c:	e8 fb 3c 00 00       	call   3f7c <sleep>
  if(unlink("oidir") != 0){
     281:	c7 04 24 1b 45 00 00 	movl   $0x451b,(%esp)
     288:	e8 af 3c 00 00       	call   3f3c <unlink>
     28d:	85 c0                	test   %eax,%eax
     28f:	74 1a                	je     2ab <openiputtest+0xe5>
    printf(stdout, "unlink failed\n");
     291:	a1 2c 63 00 00       	mov    0x632c,%eax
     296:	c7 44 24 04 5c 45 00 	movl   $0x455c,0x4(%esp)
     29d:	00 
     29e:	89 04 24             	mov    %eax,(%esp)
     2a1:	e8 c6 3d 00 00       	call   406c <printf>
    exit();
     2a6:	e8 41 3c 00 00       	call   3eec <exit>
  }
  wait();
     2ab:	e8 44 3c 00 00       	call   3ef4 <wait>
  printf(stdout, "openiput test ok\n");
     2b0:	a1 2c 63 00 00       	mov    0x632c,%eax
     2b5:	c7 44 24 04 6b 45 00 	movl   $0x456b,0x4(%esp)
     2bc:	00 
     2bd:	89 04 24             	mov    %eax,(%esp)
     2c0:	e8 a7 3d 00 00       	call   406c <printf>
}
     2c5:	c9                   	leave  
     2c6:	c3                   	ret    

000002c7 <opentest>:

// simple file system tests

void
opentest(void)
{
     2c7:	55                   	push   %ebp
     2c8:	89 e5                	mov    %esp,%ebp
     2ca:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(stdout, "open test\n");
     2cd:	a1 2c 63 00 00       	mov    0x632c,%eax
     2d2:	c7 44 24 04 7d 45 00 	movl   $0x457d,0x4(%esp)
     2d9:	00 
     2da:	89 04 24             	mov    %eax,(%esp)
     2dd:	e8 8a 3d 00 00       	call   406c <printf>
  fd = open("echo", 0);
     2e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     2e9:	00 
     2ea:	c7 04 24 38 44 00 00 	movl   $0x4438,(%esp)
     2f1:	e8 36 3c 00 00       	call   3f2c <open>
     2f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
     2f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     2fd:	79 1a                	jns    319 <opentest+0x52>
    printf(stdout, "open echo failed!\n");
     2ff:	a1 2c 63 00 00       	mov    0x632c,%eax
     304:	c7 44 24 04 88 45 00 	movl   $0x4588,0x4(%esp)
     30b:	00 
     30c:	89 04 24             	mov    %eax,(%esp)
     30f:	e8 58 3d 00 00       	call   406c <printf>
    exit();
     314:	e8 d3 3b 00 00       	call   3eec <exit>
  }
  close(fd);
     319:	8b 45 f4             	mov    -0xc(%ebp),%eax
     31c:	89 04 24             	mov    %eax,(%esp)
     31f:	e8 f0 3b 00 00       	call   3f14 <close>
  fd = open("doesnotexist", 0);
     324:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     32b:	00 
     32c:	c7 04 24 9b 45 00 00 	movl   $0x459b,(%esp)
     333:	e8 f4 3b 00 00       	call   3f2c <open>
     338:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
     33b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     33f:	78 1a                	js     35b <opentest+0x94>
    printf(stdout, "open doesnotexist succeeded!\n");
     341:	a1 2c 63 00 00       	mov    0x632c,%eax
     346:	c7 44 24 04 a8 45 00 	movl   $0x45a8,0x4(%esp)
     34d:	00 
     34e:	89 04 24             	mov    %eax,(%esp)
     351:	e8 16 3d 00 00       	call   406c <printf>
    exit();
     356:	e8 91 3b 00 00       	call   3eec <exit>
  }
  printf(stdout, "open test ok\n");
     35b:	a1 2c 63 00 00       	mov    0x632c,%eax
     360:	c7 44 24 04 c6 45 00 	movl   $0x45c6,0x4(%esp)
     367:	00 
     368:	89 04 24             	mov    %eax,(%esp)
     36b:	e8 fc 3c 00 00       	call   406c <printf>
}
     370:	c9                   	leave  
     371:	c3                   	ret    

00000372 <writetest>:

void
writetest(void)
{
     372:	55                   	push   %ebp
     373:	89 e5                	mov    %esp,%ebp
     375:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int i;

  printf(stdout, "small file test\n");
     378:	a1 2c 63 00 00       	mov    0x632c,%eax
     37d:	c7 44 24 04 d4 45 00 	movl   $0x45d4,0x4(%esp)
     384:	00 
     385:	89 04 24             	mov    %eax,(%esp)
     388:	e8 df 3c 00 00       	call   406c <printf>
  fd = open("small", O_CREATE|O_RDWR);
     38d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     394:	00 
     395:	c7 04 24 e5 45 00 00 	movl   $0x45e5,(%esp)
     39c:	e8 8b 3b 00 00       	call   3f2c <open>
     3a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     3a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     3a8:	78 21                	js     3cb <writetest+0x59>
    printf(stdout, "creat small succeeded; ok\n");
     3aa:	a1 2c 63 00 00       	mov    0x632c,%eax
     3af:	c7 44 24 04 eb 45 00 	movl   $0x45eb,0x4(%esp)
     3b6:	00 
     3b7:	89 04 24             	mov    %eax,(%esp)
     3ba:	e8 ad 3c 00 00       	call   406c <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     3bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     3c6:	e9 a0 00 00 00       	jmp    46b <writetest+0xf9>
  printf(stdout, "small file test\n");
  fd = open("small", O_CREATE|O_RDWR);
  if(fd >= 0){
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
     3cb:	a1 2c 63 00 00       	mov    0x632c,%eax
     3d0:	c7 44 24 04 06 46 00 	movl   $0x4606,0x4(%esp)
     3d7:	00 
     3d8:	89 04 24             	mov    %eax,(%esp)
     3db:	e8 8c 3c 00 00       	call   406c <printf>
    exit();
     3e0:	e8 07 3b 00 00       	call   3eec <exit>
  }
  for(i = 0; i < 100; i++){
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     3e5:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     3ec:	00 
     3ed:	c7 44 24 04 22 46 00 	movl   $0x4622,0x4(%esp)
     3f4:	00 
     3f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     3f8:	89 04 24             	mov    %eax,(%esp)
     3fb:	e8 0c 3b 00 00       	call   3f0c <write>
     400:	83 f8 0a             	cmp    $0xa,%eax
     403:	74 21                	je     426 <writetest+0xb4>
      printf(stdout, "error: write aa %d new file failed\n", i);
     405:	a1 2c 63 00 00       	mov    0x632c,%eax
     40a:	8b 55 f4             	mov    -0xc(%ebp),%edx
     40d:	89 54 24 08          	mov    %edx,0x8(%esp)
     411:	c7 44 24 04 30 46 00 	movl   $0x4630,0x4(%esp)
     418:	00 
     419:	89 04 24             	mov    %eax,(%esp)
     41c:	e8 4b 3c 00 00       	call   406c <printf>
      exit();
     421:	e8 c6 3a 00 00       	call   3eec <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     426:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     42d:	00 
     42e:	c7 44 24 04 54 46 00 	movl   $0x4654,0x4(%esp)
     435:	00 
     436:	8b 45 f0             	mov    -0x10(%ebp),%eax
     439:	89 04 24             	mov    %eax,(%esp)
     43c:	e8 cb 3a 00 00       	call   3f0c <write>
     441:	83 f8 0a             	cmp    $0xa,%eax
     444:	74 21                	je     467 <writetest+0xf5>
      printf(stdout, "error: write bb %d new file failed\n", i);
     446:	a1 2c 63 00 00       	mov    0x632c,%eax
     44b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     44e:	89 54 24 08          	mov    %edx,0x8(%esp)
     452:	c7 44 24 04 60 46 00 	movl   $0x4660,0x4(%esp)
     459:	00 
     45a:	89 04 24             	mov    %eax,(%esp)
     45d:	e8 0a 3c 00 00       	call   406c <printf>
      exit();
     462:	e8 85 3a 00 00       	call   3eec <exit>
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     467:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     46b:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     46f:	0f 8e 70 ff ff ff    	jle    3e5 <writetest+0x73>
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
      exit();
    }
  }
  printf(stdout, "writes ok\n");
     475:	a1 2c 63 00 00       	mov    0x632c,%eax
     47a:	c7 44 24 04 84 46 00 	movl   $0x4684,0x4(%esp)
     481:	00 
     482:	89 04 24             	mov    %eax,(%esp)
     485:	e8 e2 3b 00 00       	call   406c <printf>
  close(fd);
     48a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     48d:	89 04 24             	mov    %eax,(%esp)
     490:	e8 7f 3a 00 00       	call   3f14 <close>
  fd = open("small", O_RDONLY);
     495:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     49c:	00 
     49d:	c7 04 24 e5 45 00 00 	movl   $0x45e5,(%esp)
     4a4:	e8 83 3a 00 00       	call   3f2c <open>
     4a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     4ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     4b0:	78 3e                	js     4f0 <writetest+0x17e>
    printf(stdout, "open small succeeded ok\n");
     4b2:	a1 2c 63 00 00       	mov    0x632c,%eax
     4b7:	c7 44 24 04 8f 46 00 	movl   $0x468f,0x4(%esp)
     4be:	00 
     4bf:	89 04 24             	mov    %eax,(%esp)
     4c2:	e8 a5 3b 00 00       	call   406c <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
     4c7:	c7 44 24 08 d0 07 00 	movl   $0x7d0,0x8(%esp)
     4ce:	00 
     4cf:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
     4d6:	00 
     4d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4da:	89 04 24             	mov    %eax,(%esp)
     4dd:	e8 22 3a 00 00       	call   3f04 <read>
     4e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(i == 2000){
     4e5:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
     4ec:	75 4e                	jne    53c <writetest+0x1ca>
     4ee:	eb 1a                	jmp    50a <writetest+0x198>
  close(fd);
  fd = open("small", O_RDONLY);
  if(fd >= 0){
    printf(stdout, "open small succeeded ok\n");
  } else {
    printf(stdout, "error: open small failed!\n");
     4f0:	a1 2c 63 00 00       	mov    0x632c,%eax
     4f5:	c7 44 24 04 a8 46 00 	movl   $0x46a8,0x4(%esp)
     4fc:	00 
     4fd:	89 04 24             	mov    %eax,(%esp)
     500:	e8 67 3b 00 00       	call   406c <printf>
    exit();
     505:	e8 e2 39 00 00       	call   3eec <exit>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
     50a:	a1 2c 63 00 00       	mov    0x632c,%eax
     50f:	c7 44 24 04 c3 46 00 	movl   $0x46c3,0x4(%esp)
     516:	00 
     517:	89 04 24             	mov    %eax,(%esp)
     51a:	e8 4d 3b 00 00       	call   406c <printf>
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
     51f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     522:	89 04 24             	mov    %eax,(%esp)
     525:	e8 ea 39 00 00       	call   3f14 <close>

  if(unlink("small") < 0){
     52a:	c7 04 24 e5 45 00 00 	movl   $0x45e5,(%esp)
     531:	e8 06 3a 00 00       	call   3f3c <unlink>
     536:	85 c0                	test   %eax,%eax
     538:	79 36                	jns    570 <writetest+0x1fe>
     53a:	eb 1a                	jmp    556 <writetest+0x1e4>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
  } else {
    printf(stdout, "read failed\n");
     53c:	a1 2c 63 00 00       	mov    0x632c,%eax
     541:	c7 44 24 04 d6 46 00 	movl   $0x46d6,0x4(%esp)
     548:	00 
     549:	89 04 24             	mov    %eax,(%esp)
     54c:	e8 1b 3b 00 00       	call   406c <printf>
    exit();
     551:	e8 96 39 00 00       	call   3eec <exit>
  }
  close(fd);

  if(unlink("small") < 0){
    printf(stdout, "unlink small failed\n");
     556:	a1 2c 63 00 00       	mov    0x632c,%eax
     55b:	c7 44 24 04 e3 46 00 	movl   $0x46e3,0x4(%esp)
     562:	00 
     563:	89 04 24             	mov    %eax,(%esp)
     566:	e8 01 3b 00 00       	call   406c <printf>
    exit();
     56b:	e8 7c 39 00 00       	call   3eec <exit>
  }
  printf(stdout, "small file test ok\n");
     570:	a1 2c 63 00 00       	mov    0x632c,%eax
     575:	c7 44 24 04 f8 46 00 	movl   $0x46f8,0x4(%esp)
     57c:	00 
     57d:	89 04 24             	mov    %eax,(%esp)
     580:	e8 e7 3a 00 00       	call   406c <printf>
}
     585:	c9                   	leave  
     586:	c3                   	ret    

00000587 <writetest1>:

void
writetest1(void)
{
     587:	55                   	push   %ebp
     588:	89 e5                	mov    %esp,%ebp
     58a:	83 ec 28             	sub    $0x28,%esp
  int i, fd, n;

  printf(stdout, "big files test\n");
     58d:	a1 2c 63 00 00       	mov    0x632c,%eax
     592:	c7 44 24 04 0c 47 00 	movl   $0x470c,0x4(%esp)
     599:	00 
     59a:	89 04 24             	mov    %eax,(%esp)
     59d:	e8 ca 3a 00 00       	call   406c <printf>

  fd = open("big", O_CREATE|O_RDWR);
     5a2:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     5a9:	00 
     5aa:	c7 04 24 1c 47 00 00 	movl   $0x471c,(%esp)
     5b1:	e8 76 39 00 00       	call   3f2c <open>
     5b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     5b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     5bd:	79 1a                	jns    5d9 <writetest1+0x52>
    printf(stdout, "error: creat big failed!\n");
     5bf:	a1 2c 63 00 00       	mov    0x632c,%eax
     5c4:	c7 44 24 04 20 47 00 	movl   $0x4720,0x4(%esp)
     5cb:	00 
     5cc:	89 04 24             	mov    %eax,(%esp)
     5cf:	e8 98 3a 00 00       	call   406c <printf>
    exit();
     5d4:	e8 13 39 00 00       	call   3eec <exit>
  }

  for(i = 0; i < MAXFILE; i++){
     5d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     5e0:	eb 51                	jmp    633 <writetest1+0xac>
    ((int*)buf)[0] = i;
     5e2:	b8 20 8b 00 00       	mov    $0x8b20,%eax
     5e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
     5ea:	89 10                	mov    %edx,(%eax)
    if(write(fd, buf, 512) != 512){
     5ec:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     5f3:	00 
     5f4:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
     5fb:	00 
     5fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
     5ff:	89 04 24             	mov    %eax,(%esp)
     602:	e8 05 39 00 00       	call   3f0c <write>
     607:	3d 00 02 00 00       	cmp    $0x200,%eax
     60c:	74 21                	je     62f <writetest1+0xa8>
      printf(stdout, "error: write big file failed\n", i);
     60e:	a1 2c 63 00 00       	mov    0x632c,%eax
     613:	8b 55 f4             	mov    -0xc(%ebp),%edx
     616:	89 54 24 08          	mov    %edx,0x8(%esp)
     61a:	c7 44 24 04 3a 47 00 	movl   $0x473a,0x4(%esp)
     621:	00 
     622:	89 04 24             	mov    %eax,(%esp)
     625:	e8 42 3a 00 00       	call   406c <printf>
      exit();
     62a:	e8 bd 38 00 00       	call   3eec <exit>
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
    exit();
  }

  for(i = 0; i < MAXFILE; i++){
     62f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     633:	8b 45 f4             	mov    -0xc(%ebp),%eax
     636:	3d 8b 00 00 00       	cmp    $0x8b,%eax
     63b:	76 a5                	jbe    5e2 <writetest1+0x5b>
      printf(stdout, "error: write big file failed\n", i);
      exit();
    }
  }

  close(fd);
     63d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     640:	89 04 24             	mov    %eax,(%esp)
     643:	e8 cc 38 00 00       	call   3f14 <close>

  fd = open("big", O_RDONLY);
     648:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     64f:	00 
     650:	c7 04 24 1c 47 00 00 	movl   $0x471c,(%esp)
     657:	e8 d0 38 00 00       	call   3f2c <open>
     65c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     65f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     663:	79 1a                	jns    67f <writetest1+0xf8>
    printf(stdout, "error: open big failed!\n");
     665:	a1 2c 63 00 00       	mov    0x632c,%eax
     66a:	c7 44 24 04 58 47 00 	movl   $0x4758,0x4(%esp)
     671:	00 
     672:	89 04 24             	mov    %eax,(%esp)
     675:	e8 f2 39 00 00       	call   406c <printf>
    exit();
     67a:	e8 6d 38 00 00       	call   3eec <exit>
  }

  n = 0;
     67f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(;;){
    i = read(fd, buf, 512);
     686:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     68d:	00 
     68e:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
     695:	00 
     696:	8b 45 ec             	mov    -0x14(%ebp),%eax
     699:	89 04 24             	mov    %eax,(%esp)
     69c:	e8 63 38 00 00       	call   3f04 <read>
     6a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i == 0){
     6a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     6a8:	75 4c                	jne    6f6 <writetest1+0x16f>
      if(n == MAXFILE - 1){
     6aa:	81 7d f0 8b 00 00 00 	cmpl   $0x8b,-0x10(%ebp)
     6b1:	75 21                	jne    6d4 <writetest1+0x14d>
        printf(stdout, "read only %d blocks from big", n);
     6b3:	a1 2c 63 00 00       	mov    0x632c,%eax
     6b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
     6bb:	89 54 24 08          	mov    %edx,0x8(%esp)
     6bf:	c7 44 24 04 71 47 00 	movl   $0x4771,0x4(%esp)
     6c6:	00 
     6c7:	89 04 24             	mov    %eax,(%esp)
     6ca:	e8 9d 39 00 00       	call   406c <printf>
        exit();
     6cf:	e8 18 38 00 00       	call   3eec <exit>
      }
      break;
     6d4:	90                   	nop
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
  }
  close(fd);
     6d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
     6d8:	89 04 24             	mov    %eax,(%esp)
     6db:	e8 34 38 00 00       	call   3f14 <close>
  if(unlink("big") < 0){
     6e0:	c7 04 24 1c 47 00 00 	movl   $0x471c,(%esp)
     6e7:	e8 50 38 00 00       	call   3f3c <unlink>
     6ec:	85 c0                	test   %eax,%eax
     6ee:	0f 89 87 00 00 00    	jns    77b <writetest1+0x1f4>
     6f4:	eb 6b                	jmp    761 <writetest1+0x1da>
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
    } else if(i != 512){
     6f6:	81 7d f4 00 02 00 00 	cmpl   $0x200,-0xc(%ebp)
     6fd:	74 21                	je     720 <writetest1+0x199>
      printf(stdout, "read failed %d\n", i);
     6ff:	a1 2c 63 00 00       	mov    0x632c,%eax
     704:	8b 55 f4             	mov    -0xc(%ebp),%edx
     707:	89 54 24 08          	mov    %edx,0x8(%esp)
     70b:	c7 44 24 04 8e 47 00 	movl   $0x478e,0x4(%esp)
     712:	00 
     713:	89 04 24             	mov    %eax,(%esp)
     716:	e8 51 39 00 00       	call   406c <printf>
      exit();
     71b:	e8 cc 37 00 00       	call   3eec <exit>
    }
    if(((int*)buf)[0] != n){
     720:	b8 20 8b 00 00       	mov    $0x8b20,%eax
     725:	8b 00                	mov    (%eax),%eax
     727:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     72a:	74 2c                	je     758 <writetest1+0x1d1>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
     72c:	b8 20 8b 00 00       	mov    $0x8b20,%eax
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
      printf(stdout, "read content of block %d is %d\n",
     731:	8b 10                	mov    (%eax),%edx
     733:	a1 2c 63 00 00       	mov    0x632c,%eax
     738:	89 54 24 0c          	mov    %edx,0xc(%esp)
     73c:	8b 55 f0             	mov    -0x10(%ebp),%edx
     73f:	89 54 24 08          	mov    %edx,0x8(%esp)
     743:	c7 44 24 04 a0 47 00 	movl   $0x47a0,0x4(%esp)
     74a:	00 
     74b:	89 04 24             	mov    %eax,(%esp)
     74e:	e8 19 39 00 00       	call   406c <printf>
             n, ((int*)buf)[0]);
      exit();
     753:	e8 94 37 00 00       	call   3eec <exit>
    }
    n++;
     758:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  }
     75c:	e9 25 ff ff ff       	jmp    686 <writetest1+0xff>
  close(fd);
  if(unlink("big") < 0){
    printf(stdout, "unlink big failed\n");
     761:	a1 2c 63 00 00       	mov    0x632c,%eax
     766:	c7 44 24 04 c0 47 00 	movl   $0x47c0,0x4(%esp)
     76d:	00 
     76e:	89 04 24             	mov    %eax,(%esp)
     771:	e8 f6 38 00 00       	call   406c <printf>
    exit();
     776:	e8 71 37 00 00       	call   3eec <exit>
  }
  printf(stdout, "big files ok\n");
     77b:	a1 2c 63 00 00       	mov    0x632c,%eax
     780:	c7 44 24 04 d3 47 00 	movl   $0x47d3,0x4(%esp)
     787:	00 
     788:	89 04 24             	mov    %eax,(%esp)
     78b:	e8 dc 38 00 00       	call   406c <printf>
}
     790:	c9                   	leave  
     791:	c3                   	ret    

00000792 <createtest>:

void
createtest(void)
{
     792:	55                   	push   %ebp
     793:	89 e5                	mov    %esp,%ebp
     795:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     798:	a1 2c 63 00 00       	mov    0x632c,%eax
     79d:	c7 44 24 04 e4 47 00 	movl   $0x47e4,0x4(%esp)
     7a4:	00 
     7a5:	89 04 24             	mov    %eax,(%esp)
     7a8:	e8 bf 38 00 00       	call   406c <printf>

  name[0] = 'a';
     7ad:	c6 05 20 ab 00 00 61 	movb   $0x61,0xab20
  name[2] = '\0';
     7b4:	c6 05 22 ab 00 00 00 	movb   $0x0,0xab22
  for(i = 0; i < 52; i++){
     7bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     7c2:	eb 31                	jmp    7f5 <createtest+0x63>
    name[1] = '0' + i;
     7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7c7:	83 c0 30             	add    $0x30,%eax
     7ca:	a2 21 ab 00 00       	mov    %al,0xab21
    fd = open(name, O_CREATE|O_RDWR);
     7cf:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     7d6:	00 
     7d7:	c7 04 24 20 ab 00 00 	movl   $0xab20,(%esp)
     7de:	e8 49 37 00 00       	call   3f2c <open>
     7e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(fd);
     7e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     7e9:	89 04 24             	mov    %eax,(%esp)
     7ec:	e8 23 37 00 00       	call   3f14 <close>

  printf(stdout, "many creates, followed by unlink test\n");

  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     7f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     7f5:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     7f9:	7e c9                	jle    7c4 <createtest+0x32>
    name[1] = '0' + i;
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
     7fb:	c6 05 20 ab 00 00 61 	movb   $0x61,0xab20
  name[2] = '\0';
     802:	c6 05 22 ab 00 00 00 	movb   $0x0,0xab22
  for(i = 0; i < 52; i++){
     809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     810:	eb 1b                	jmp    82d <createtest+0x9b>
    name[1] = '0' + i;
     812:	8b 45 f4             	mov    -0xc(%ebp),%eax
     815:	83 c0 30             	add    $0x30,%eax
     818:	a2 21 ab 00 00       	mov    %al,0xab21
    unlink(name);
     81d:	c7 04 24 20 ab 00 00 	movl   $0xab20,(%esp)
     824:	e8 13 37 00 00       	call   3f3c <unlink>
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     829:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     82d:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     831:	7e df                	jle    812 <createtest+0x80>
    name[1] = '0' + i;
    unlink(name);
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     833:	a1 2c 63 00 00       	mov    0x632c,%eax
     838:	c7 44 24 04 0c 48 00 	movl   $0x480c,0x4(%esp)
     83f:	00 
     840:	89 04 24             	mov    %eax,(%esp)
     843:	e8 24 38 00 00       	call   406c <printf>
}
     848:	c9                   	leave  
     849:	c3                   	ret    

0000084a <dirtest>:

void dirtest(void)
{
     84a:	55                   	push   %ebp
     84b:	89 e5                	mov    %esp,%ebp
     84d:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "mkdir test\n");
     850:	a1 2c 63 00 00       	mov    0x632c,%eax
     855:	c7 44 24 04 32 48 00 	movl   $0x4832,0x4(%esp)
     85c:	00 
     85d:	89 04 24             	mov    %eax,(%esp)
     860:	e8 07 38 00 00       	call   406c <printf>

  if(mkdir("dir0") < 0){
     865:	c7 04 24 3e 48 00 00 	movl   $0x483e,(%esp)
     86c:	e8 e3 36 00 00       	call   3f54 <mkdir>
     871:	85 c0                	test   %eax,%eax
     873:	79 1a                	jns    88f <dirtest+0x45>
    printf(stdout, "mkdir failed\n");
     875:	a1 2c 63 00 00       	mov    0x632c,%eax
     87a:	c7 44 24 04 61 44 00 	movl   $0x4461,0x4(%esp)
     881:	00 
     882:	89 04 24             	mov    %eax,(%esp)
     885:	e8 e2 37 00 00       	call   406c <printf>
    exit();
     88a:	e8 5d 36 00 00       	call   3eec <exit>
  }

  if(chdir("dir0") < 0){
     88f:	c7 04 24 3e 48 00 00 	movl   $0x483e,(%esp)
     896:	e8 c1 36 00 00       	call   3f5c <chdir>
     89b:	85 c0                	test   %eax,%eax
     89d:	79 1a                	jns    8b9 <dirtest+0x6f>
    printf(stdout, "chdir dir0 failed\n");
     89f:	a1 2c 63 00 00       	mov    0x632c,%eax
     8a4:	c7 44 24 04 43 48 00 	movl   $0x4843,0x4(%esp)
     8ab:	00 
     8ac:	89 04 24             	mov    %eax,(%esp)
     8af:	e8 b8 37 00 00       	call   406c <printf>
    exit();
     8b4:	e8 33 36 00 00       	call   3eec <exit>
  }

  if(chdir("..") < 0){
     8b9:	c7 04 24 56 48 00 00 	movl   $0x4856,(%esp)
     8c0:	e8 97 36 00 00       	call   3f5c <chdir>
     8c5:	85 c0                	test   %eax,%eax
     8c7:	79 1a                	jns    8e3 <dirtest+0x99>
    printf(stdout, "chdir .. failed\n");
     8c9:	a1 2c 63 00 00       	mov    0x632c,%eax
     8ce:	c7 44 24 04 59 48 00 	movl   $0x4859,0x4(%esp)
     8d5:	00 
     8d6:	89 04 24             	mov    %eax,(%esp)
     8d9:	e8 8e 37 00 00       	call   406c <printf>
    exit();
     8de:	e8 09 36 00 00       	call   3eec <exit>
  }

  if(unlink("dir0") < 0){
     8e3:	c7 04 24 3e 48 00 00 	movl   $0x483e,(%esp)
     8ea:	e8 4d 36 00 00       	call   3f3c <unlink>
     8ef:	85 c0                	test   %eax,%eax
     8f1:	79 1a                	jns    90d <dirtest+0xc3>
    printf(stdout, "unlink dir0 failed\n");
     8f3:	a1 2c 63 00 00       	mov    0x632c,%eax
     8f8:	c7 44 24 04 6a 48 00 	movl   $0x486a,0x4(%esp)
     8ff:	00 
     900:	89 04 24             	mov    %eax,(%esp)
     903:	e8 64 37 00 00       	call   406c <printf>
    exit();
     908:	e8 df 35 00 00       	call   3eec <exit>
  }
  printf(stdout, "mkdir test ok\n");
     90d:	a1 2c 63 00 00       	mov    0x632c,%eax
     912:	c7 44 24 04 7e 48 00 	movl   $0x487e,0x4(%esp)
     919:	00 
     91a:	89 04 24             	mov    %eax,(%esp)
     91d:	e8 4a 37 00 00       	call   406c <printf>
}
     922:	c9                   	leave  
     923:	c3                   	ret    

00000924 <exectest>:

void
exectest(void)
{
     924:	55                   	push   %ebp
     925:	89 e5                	mov    %esp,%ebp
     927:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "exec test\n");
     92a:	a1 2c 63 00 00       	mov    0x632c,%eax
     92f:	c7 44 24 04 8d 48 00 	movl   $0x488d,0x4(%esp)
     936:	00 
     937:	89 04 24             	mov    %eax,(%esp)
     93a:	e8 2d 37 00 00       	call   406c <printf>
  if(exec("echo", echoargv) < 0){
     93f:	c7 44 24 04 18 63 00 	movl   $0x6318,0x4(%esp)
     946:	00 
     947:	c7 04 24 38 44 00 00 	movl   $0x4438,(%esp)
     94e:	e8 d1 35 00 00       	call   3f24 <exec>
     953:	85 c0                	test   %eax,%eax
     955:	79 1a                	jns    971 <exectest+0x4d>
    printf(stdout, "exec echo failed\n");
     957:	a1 2c 63 00 00       	mov    0x632c,%eax
     95c:	c7 44 24 04 98 48 00 	movl   $0x4898,0x4(%esp)
     963:	00 
     964:	89 04 24             	mov    %eax,(%esp)
     967:	e8 00 37 00 00       	call   406c <printf>
    exit();
     96c:	e8 7b 35 00 00       	call   3eec <exit>
  }
}
     971:	c9                   	leave  
     972:	c3                   	ret    

00000973 <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     973:	55                   	push   %ebp
     974:	89 e5                	mov    %esp,%ebp
     976:	83 ec 38             	sub    $0x38,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     979:	8d 45 d8             	lea    -0x28(%ebp),%eax
     97c:	89 04 24             	mov    %eax,(%esp)
     97f:	e8 78 35 00 00       	call   3efc <pipe>
     984:	85 c0                	test   %eax,%eax
     986:	74 19                	je     9a1 <pipe1+0x2e>
    printf(1, "pipe() failed\n");
     988:	c7 44 24 04 aa 48 00 	movl   $0x48aa,0x4(%esp)
     98f:	00 
     990:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     997:	e8 d0 36 00 00       	call   406c <printf>
    exit();
     99c:	e8 4b 35 00 00       	call   3eec <exit>
  }
  pid = fork();
     9a1:	e8 3e 35 00 00       	call   3ee4 <fork>
     9a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  seq = 0;
     9a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(pid == 0){
     9b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     9b4:	0f 85 88 00 00 00    	jne    a42 <pipe1+0xcf>
    close(fds[0]);
     9ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
     9bd:	89 04 24             	mov    %eax,(%esp)
     9c0:	e8 4f 35 00 00       	call   3f14 <close>
    for(n = 0; n < 5; n++){
     9c5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     9cc:	eb 69                	jmp    a37 <pipe1+0xc4>
      for(i = 0; i < 1033; i++)
     9ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     9d5:	eb 18                	jmp    9ef <pipe1+0x7c>
        buf[i] = seq++;
     9d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9da:	8d 50 01             	lea    0x1(%eax),%edx
     9dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
     9e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
     9e3:	81 c2 20 8b 00 00    	add    $0x8b20,%edx
     9e9:	88 02                	mov    %al,(%edx)
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
     9eb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     9ef:	81 7d f0 08 04 00 00 	cmpl   $0x408,-0x10(%ebp)
     9f6:	7e df                	jle    9d7 <pipe1+0x64>
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
     9f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
     9fb:	c7 44 24 08 09 04 00 	movl   $0x409,0x8(%esp)
     a02:	00 
     a03:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
     a0a:	00 
     a0b:	89 04 24             	mov    %eax,(%esp)
     a0e:	e8 f9 34 00 00       	call   3f0c <write>
     a13:	3d 09 04 00 00       	cmp    $0x409,%eax
     a18:	74 19                	je     a33 <pipe1+0xc0>
        printf(1, "pipe1 oops 1\n");
     a1a:	c7 44 24 04 b9 48 00 	movl   $0x48b9,0x4(%esp)
     a21:	00 
     a22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a29:	e8 3e 36 00 00       	call   406c <printf>
        exit();
     a2e:	e8 b9 34 00 00       	call   3eec <exit>
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
     a33:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
     a37:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
     a3b:	7e 91                	jle    9ce <pipe1+0x5b>
      if(write(fds[1], buf, 1033) != 1033){
        printf(1, "pipe1 oops 1\n");
        exit();
      }
    }
    exit();
     a3d:	e8 aa 34 00 00       	call   3eec <exit>
  } else if(pid > 0){
     a42:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     a46:	0f 8e 18 01 00 00    	jle    b64 <pipe1+0x1f1>
    close(fds[1]);
     a4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     a4f:	89 04 24             	mov    %eax,(%esp)
     a52:	e8 bd 34 00 00       	call   3f14 <close>
    total = 0;
     a57:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    cc = 1;
     a5e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    while((n = read(fds[0], buf, cc)) > 0){
     a65:	e9 84 00 00 00       	jmp    aee <pipe1+0x17b>
      for(i = 0; i < n; i++){
     a6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     a71:	eb 59                	jmp    acc <pipe1+0x159>
    	  printf(1,"%", buf);
     a73:	c7 44 24 08 20 8b 00 	movl   $0x8b20,0x8(%esp)
     a7a:	00 
     a7b:	c7 44 24 04 c7 48 00 	movl   $0x48c7,0x4(%esp)
     a82:	00 
     a83:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a8a:	e8 dd 35 00 00       	call   406c <printf>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a92:	05 20 8b 00 00       	add    $0x8b20,%eax
     a97:	0f b6 00             	movzbl (%eax),%eax
     a9a:	0f be c8             	movsbl %al,%ecx
     a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     aa0:	8d 50 01             	lea    0x1(%eax),%edx
     aa3:	89 55 f4             	mov    %edx,-0xc(%ebp)
     aa6:	31 c8                	xor    %ecx,%eax
     aa8:	0f b6 c0             	movzbl %al,%eax
     aab:	85 c0                	test   %eax,%eax
     aad:	74 19                	je     ac8 <pipe1+0x155>
          printf(1, "pipe1 oops 2\n");
     aaf:	c7 44 24 04 c9 48 00 	movl   $0x48c9,0x4(%esp)
     ab6:	00 
     ab7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     abe:	e8 a9 35 00 00       	call   406c <printf>
     ac3:	e9 b5 00 00 00       	jmp    b7d <pipe1+0x20a>
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
     ac8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
     acf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     ad2:	7c 9f                	jl     a73 <pipe1+0x100>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
          return;
        }
      }
      total += n;
     ad4:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ad7:	01 45 e4             	add    %eax,-0x1c(%ebp)
      cc = cc * 2;
     ada:	d1 65 e8             	shll   -0x18(%ebp)
      if(cc > sizeof(buf))
     add:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ae0:	3d 00 20 00 00       	cmp    $0x2000,%eax
     ae5:	76 07                	jbe    aee <pipe1+0x17b>
        cc = sizeof(buf);
     ae7:	c7 45 e8 00 20 00 00 	movl   $0x2000,-0x18(%ebp)
    exit();
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
     aee:	8b 45 d8             	mov    -0x28(%ebp),%eax
     af1:	8b 55 e8             	mov    -0x18(%ebp),%edx
     af4:	89 54 24 08          	mov    %edx,0x8(%esp)
     af8:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
     aff:	00 
     b00:	89 04 24             	mov    %eax,(%esp)
     b03:	e8 fc 33 00 00       	call   3f04 <read>
     b08:	89 45 ec             	mov    %eax,-0x14(%ebp)
     b0b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     b0f:	0f 8f 55 ff ff ff    	jg     a6a <pipe1+0xf7>
      total += n;
      cc = cc * 2;
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033){
     b15:	81 7d e4 2d 14 00 00 	cmpl   $0x142d,-0x1c(%ebp)
     b1c:	74 20                	je     b3e <pipe1+0x1cb>
      printf(1, "pipe1 oops 3 total %d\n", total);
     b1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     b21:	89 44 24 08          	mov    %eax,0x8(%esp)
     b25:	c7 44 24 04 d7 48 00 	movl   $0x48d7,0x4(%esp)
     b2c:	00 
     b2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b34:	e8 33 35 00 00       	call   406c <printf>
      exit();
     b39:	e8 ae 33 00 00       	call   3eec <exit>
    }
    close(fds[0]);
     b3e:	8b 45 d8             	mov    -0x28(%ebp),%eax
     b41:	89 04 24             	mov    %eax,(%esp)
     b44:	e8 cb 33 00 00       	call   3f14 <close>
    wait();
     b49:	e8 a6 33 00 00       	call   3ef4 <wait>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
     b4e:	c7 44 24 04 fd 48 00 	movl   $0x48fd,0x4(%esp)
     b55:	00 
     b56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b5d:	e8 0a 35 00 00       	call   406c <printf>
     b62:	eb 19                	jmp    b7d <pipe1+0x20a>
      exit();
    }
    close(fds[0]);
    wait();
  } else {
    printf(1, "fork() failed\n");
     b64:	c7 44 24 04 ee 48 00 	movl   $0x48ee,0x4(%esp)
     b6b:	00 
     b6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b73:	e8 f4 34 00 00       	call   406c <printf>
    exit();
     b78:	e8 6f 33 00 00       	call   3eec <exit>
  }
  printf(1, "pipe1 ok\n");
}
     b7d:	c9                   	leave  
     b7e:	c3                   	ret    

00000b7f <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     b7f:	55                   	push   %ebp
     b80:	89 e5                	mov    %esp,%ebp
     b82:	83 ec 38             	sub    $0x38,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     b85:	c7 44 24 04 07 49 00 	movl   $0x4907,0x4(%esp)
     b8c:	00 
     b8d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b94:	e8 d3 34 00 00       	call   406c <printf>
  pid1 = fork();
     b99:	e8 46 33 00 00       	call   3ee4 <fork>
     b9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid1 == 0)
     ba1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ba5:	75 02                	jne    ba9 <preempt+0x2a>
    for(;;)
      ;
     ba7:	eb fe                	jmp    ba7 <preempt+0x28>

  pid2 = fork();
     ba9:	e8 36 33 00 00       	call   3ee4 <fork>
     bae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid2 == 0)
     bb1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     bb5:	75 02                	jne    bb9 <preempt+0x3a>
    for(;;)
      ;
     bb7:	eb fe                	jmp    bb7 <preempt+0x38>

  if( 0>pipe(pfds)){
     bb9:	8d 45 e0             	lea    -0x20(%ebp),%eax
     bbc:	89 04 24             	mov    %eax,(%esp)
     bbf:	e8 38 33 00 00       	call   3efc <pipe>
     bc4:	85 c0                	test   %eax,%eax
     bc6:	79 14                	jns    bdc <preempt+0x5d>
	  printf(1, "error pipe \n");
     bc8:	c7 44 24 04 11 49 00 	movl   $0x4911,0x4(%esp)
     bcf:	00 
     bd0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     bd7:	e8 90 34 00 00       	call   406c <printf>
  }

  pid3 = fork();
     bdc:	e8 03 33 00 00       	call   3ee4 <fork>
     be1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	printf(1,"here pipe ***\%d %d \n",pid2, pid3);
     be4:	8b 45 ec             	mov    -0x14(%ebp),%eax
     be7:	89 44 24 0c          	mov    %eax,0xc(%esp)
     beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bee:	89 44 24 08          	mov    %eax,0x8(%esp)
     bf2:	c7 44 24 04 1e 49 00 	movl   $0x491e,0x4(%esp)
     bf9:	00 
     bfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c01:	e8 66 34 00 00       	call   406c <printf>

  if(pid3 == 0){
     c06:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     c0a:	75 72                	jne    c7e <preempt+0xff>
    close(pfds[0]);
     c0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
     c0f:	89 04 24             	mov    %eax,(%esp)
     c12:	e8 fd 32 00 00       	call   3f14 <close>

    int k=0;
     c17:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

    if((k=write(pfds[1], "x", 1)) != 1)
     c1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c21:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     c28:	00 
     c29:	c7 44 24 04 33 49 00 	movl   $0x4933,0x4(%esp)
     c30:	00 
     c31:	89 04 24             	mov    %eax,(%esp)
     c34:	e8 d3 32 00 00       	call   3f0c <write>
     c39:	89 45 e8             	mov    %eax,-0x18(%ebp)
     c3c:	83 7d e8 01          	cmpl   $0x1,-0x18(%ebp)
     c40:	74 14                	je     c56 <preempt+0xd7>
      printf(1, "preempt write error");
     c42:	c7 44 24 04 35 49 00 	movl   $0x4935,0x4(%esp)
     c49:	00 
     c4a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c51:	e8 16 34 00 00       	call   406c <printf>

    printf(1,"*** %d", k);
     c56:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c59:	89 44 24 08          	mov    %eax,0x8(%esp)
     c5d:	c7 44 24 04 49 49 00 	movl   $0x4949,0x4(%esp)
     c64:	00 
     c65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c6c:	e8 fb 33 00 00       	call   406c <printf>
    close(pfds[1]);
     c71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c74:	89 04 24             	mov    %eax,(%esp)
     c77:	e8 98 32 00 00       	call   3f14 <close>

    for(;;)
      ;
     c7c:	eb fe                	jmp    c7c <preempt+0xfd>
  }

  close(pfds[1]);
     c7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c81:	89 04 24             	mov    %eax,(%esp)
     c84:	e8 8b 32 00 00       	call   3f14 <close>

  if(read(pfds[0], buf, sizeof(buf)) != 1){
     c89:	8b 45 e0             	mov    -0x20(%ebp),%eax
     c8c:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
     c93:	00 
     c94:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
     c9b:	00 
     c9c:	89 04 24             	mov    %eax,(%esp)
     c9f:	e8 60 32 00 00       	call   3f04 <read>
     ca4:	83 f8 01             	cmp    $0x1,%eax
     ca7:	74 19                	je     cc2 <preempt+0x143>
    printf(1, "preempt read error");
     ca9:	c7 44 24 04 50 49 00 	movl   $0x4950,0x4(%esp)
     cb0:	00 
     cb1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     cb8:	e8 af 33 00 00       	call   406c <printf>
     cbd:	e9 8b 00 00 00       	jmp    d4d <preempt+0x1ce>
    return;
  }
  printf(1, "father \n");
     cc2:	c7 44 24 04 63 49 00 	movl   $0x4963,0x4(%esp)
     cc9:	00 
     cca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     cd1:	e8 96 33 00 00       	call   406c <printf>
  close(pfds[0]);
     cd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
     cd9:	89 04 24             	mov    %eax,(%esp)
     cdc:	e8 33 32 00 00       	call   3f14 <close>

  printf(1, "kill... ");
     ce1:	c7 44 24 04 6c 49 00 	movl   $0x496c,0x4(%esp)
     ce8:	00 
     ce9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     cf0:	e8 77 33 00 00       	call   406c <printf>
  kill(pid1);
     cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     cf8:	89 04 24             	mov    %eax,(%esp)
     cfb:	e8 1c 32 00 00       	call   3f1c <kill>
  kill(pid2);
     d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
     d03:	89 04 24             	mov    %eax,(%esp)
     d06:	e8 11 32 00 00       	call   3f1c <kill>
  kill(pid3);
     d0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
     d0e:	89 04 24             	mov    %eax,(%esp)
     d11:	e8 06 32 00 00       	call   3f1c <kill>
  printf(1, "wait... ");
     d16:	c7 44 24 04 75 49 00 	movl   $0x4975,0x4(%esp)
     d1d:	00 
     d1e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d25:	e8 42 33 00 00       	call   406c <printf>
  wait();
     d2a:	e8 c5 31 00 00       	call   3ef4 <wait>
  wait();
     d2f:	e8 c0 31 00 00       	call   3ef4 <wait>
  wait();
     d34:	e8 bb 31 00 00       	call   3ef4 <wait>
  printf(1, "preempt ok\n");
     d39:	c7 44 24 04 7e 49 00 	movl   $0x497e,0x4(%esp)
     d40:	00 
     d41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d48:	e8 1f 33 00 00       	call   406c <printf>
}
     d4d:	c9                   	leave  
     d4e:	c3                   	ret    

00000d4f <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
     d4f:	55                   	push   %ebp
     d50:	89 e5                	mov    %esp,%ebp
     d52:	83 ec 28             	sub    $0x28,%esp
  int i, pid;

  for(i = 0; i < 100; i++){
     d55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     d5c:	eb 53                	jmp    db1 <exitwait+0x62>
    pid = fork();
     d5e:	e8 81 31 00 00       	call   3ee4 <fork>
     d63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0){
     d66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     d6a:	79 16                	jns    d82 <exitwait+0x33>
      printf(1, "fork failed\n");
     d6c:	c7 44 24 04 d9 44 00 	movl   $0x44d9,0x4(%esp)
     d73:	00 
     d74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d7b:	e8 ec 32 00 00       	call   406c <printf>
      return;
     d80:	eb 49                	jmp    dcb <exitwait+0x7c>
    }
    if(pid){
     d82:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     d86:	74 20                	je     da8 <exitwait+0x59>
      if(wait() != pid){
     d88:	e8 67 31 00 00       	call   3ef4 <wait>
     d8d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     d90:	74 1b                	je     dad <exitwait+0x5e>
        printf(1, "wait wrong pid\n");
     d92:	c7 44 24 04 8a 49 00 	movl   $0x498a,0x4(%esp)
     d99:	00 
     d9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     da1:	e8 c6 32 00 00       	call   406c <printf>
        return;
     da6:	eb 23                	jmp    dcb <exitwait+0x7c>
      }
    } else {
      exit();
     da8:	e8 3f 31 00 00       	call   3eec <exit>
void
exitwait(void)
{
  int i, pid;

  for(i = 0; i < 100; i++){
     dad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     db1:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     db5:	7e a7                	jle    d5e <exitwait+0xf>
      }
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
     db7:	c7 44 24 04 9a 49 00 	movl   $0x499a,0x4(%esp)
     dbe:	00 
     dbf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     dc6:	e8 a1 32 00 00       	call   406c <printf>
}
     dcb:	c9                   	leave  
     dcc:	c3                   	ret    

00000dcd <mem>:

void
mem(void)
{
     dcd:	55                   	push   %ebp
     dce:	89 e5                	mov    %esp,%ebp
     dd0:	83 ec 28             	sub    $0x28,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     dd3:	c7 44 24 04 a7 49 00 	movl   $0x49a7,0x4(%esp)
     dda:	00 
     ddb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     de2:	e8 85 32 00 00       	call   406c <printf>
  ppid = getpid();
     de7:	e8 80 31 00 00       	call   3f6c <getpid>
     dec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if((pid = fork()) == 0){
     def:	e8 f0 30 00 00       	call   3ee4 <fork>
     df4:	89 45 ec             	mov    %eax,-0x14(%ebp)
     df7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     dfb:	0f 85 aa 00 00 00    	jne    eab <mem+0xde>
    m1 = 0;
     e01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while((m2 = malloc(10001)) != 0){
     e08:	eb 0e                	jmp    e18 <mem+0x4b>
      *(char**)m2 = m1;
     e0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
     e0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     e10:	89 10                	mov    %edx,(%eax)
      m1 = m2;
     e12:	8b 45 e8             	mov    -0x18(%ebp),%eax
     e15:	89 45 f4             	mov    %eax,-0xc(%ebp)

  printf(1, "mem test\n");
  ppid = getpid();
  if((pid = fork()) == 0){
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
     e18:	c7 04 24 11 27 00 00 	movl   $0x2711,(%esp)
     e1f:	e8 34 35 00 00       	call   4358 <malloc>
     e24:	89 45 e8             	mov    %eax,-0x18(%ebp)
     e27:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     e2b:	75 dd                	jne    e0a <mem+0x3d>
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     e2d:	eb 19                	jmp    e48 <mem+0x7b>
      m2 = *(char**)m1;
     e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e32:	8b 00                	mov    (%eax),%eax
     e34:	89 45 e8             	mov    %eax,-0x18(%ebp)
      free(m1);
     e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e3a:	89 04 24             	mov    %eax,(%esp)
     e3d:	e8 dd 33 00 00       	call   421f <free>
      m1 = m2;
     e42:	8b 45 e8             	mov    -0x18(%ebp),%eax
     e45:	89 45 f4             	mov    %eax,-0xc(%ebp)
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     e48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     e4c:	75 e1                	jne    e2f <mem+0x62>
      m2 = *(char**)m1;
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
     e4e:	c7 04 24 00 50 00 00 	movl   $0x5000,(%esp)
     e55:	e8 fe 34 00 00       	call   4358 <malloc>
     e5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(m1 == 0){
     e5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     e61:	75 24                	jne    e87 <mem+0xba>
      printf(1, "couldn't allocate mem?!!\n");
     e63:	c7 44 24 04 b1 49 00 	movl   $0x49b1,0x4(%esp)
     e6a:	00 
     e6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e72:	e8 f5 31 00 00       	call   406c <printf>
      kill(ppid);
     e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e7a:	89 04 24             	mov    %eax,(%esp)
     e7d:	e8 9a 30 00 00       	call   3f1c <kill>
      exit();
     e82:	e8 65 30 00 00       	call   3eec <exit>
    }
    free(m1);
     e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e8a:	89 04 24             	mov    %eax,(%esp)
     e8d:	e8 8d 33 00 00       	call   421f <free>
    printf(1, "mem ok\n");
     e92:	c7 44 24 04 cb 49 00 	movl   $0x49cb,0x4(%esp)
     e99:	00 
     e9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ea1:	e8 c6 31 00 00       	call   406c <printf>
    exit();
     ea6:	e8 41 30 00 00       	call   3eec <exit>
  } else {
    wait();
     eab:	e8 44 30 00 00       	call   3ef4 <wait>
  }
}
     eb0:	c9                   	leave  
     eb1:	c3                   	ret    

00000eb2 <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     eb2:	55                   	push   %ebp
     eb3:	89 e5                	mov    %esp,%ebp
     eb5:	83 ec 48             	sub    $0x48,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
     eb8:	c7 44 24 04 d3 49 00 	movl   $0x49d3,0x4(%esp)
     ebf:	00 
     ec0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ec7:	e8 a0 31 00 00       	call   406c <printf>

  unlink("sharedfd");
     ecc:	c7 04 24 e2 49 00 00 	movl   $0x49e2,(%esp)
     ed3:	e8 64 30 00 00       	call   3f3c <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     ed8:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     edf:	00 
     ee0:	c7 04 24 e2 49 00 00 	movl   $0x49e2,(%esp)
     ee7:	e8 40 30 00 00       	call   3f2c <open>
     eec:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     eef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     ef3:	79 19                	jns    f0e <sharedfd+0x5c>
    printf(1, "fstests: cannot open sharedfd for writing");
     ef5:	c7 44 24 04 ec 49 00 	movl   $0x49ec,0x4(%esp)
     efc:	00 
     efd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f04:	e8 63 31 00 00       	call   406c <printf>
    return;
     f09:	e9 a0 01 00 00       	jmp    10ae <sharedfd+0x1fc>
  }
  pid = fork();
     f0e:	e8 d1 2f 00 00       	call   3ee4 <fork>
     f13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
     f16:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     f1a:	75 07                	jne    f23 <sharedfd+0x71>
     f1c:	b8 63 00 00 00       	mov    $0x63,%eax
     f21:	eb 05                	jmp    f28 <sharedfd+0x76>
     f23:	b8 70 00 00 00       	mov    $0x70,%eax
     f28:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     f2f:	00 
     f30:	89 44 24 04          	mov    %eax,0x4(%esp)
     f34:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     f37:	89 04 24             	mov    %eax,(%esp)
     f3a:	e8 00 2e 00 00       	call   3d3f <memset>
  for(i = 0; i < 1000; i++){
     f3f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     f46:	eb 39                	jmp    f81 <sharedfd+0xcf>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     f48:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     f4f:	00 
     f50:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     f53:	89 44 24 04          	mov    %eax,0x4(%esp)
     f57:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f5a:	89 04 24             	mov    %eax,(%esp)
     f5d:	e8 aa 2f 00 00       	call   3f0c <write>
     f62:	83 f8 0a             	cmp    $0xa,%eax
     f65:	74 16                	je     f7d <sharedfd+0xcb>
      printf(1, "fstests: write sharedfd failed\n");
     f67:	c7 44 24 04 18 4a 00 	movl   $0x4a18,0x4(%esp)
     f6e:	00 
     f6f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f76:	e8 f1 30 00 00       	call   406c <printf>
      break;
     f7b:	eb 0d                	jmp    f8a <sharedfd+0xd8>
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
  memset(buf, pid==0?'c':'p', sizeof(buf));
  for(i = 0; i < 1000; i++){
     f7d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     f81:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
     f88:	7e be                	jle    f48 <sharedfd+0x96>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
      printf(1, "fstests: write sharedfd failed\n");
      break;
    }
  }
  if(pid == 0)
     f8a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     f8e:	75 05                	jne    f95 <sharedfd+0xe3>
    exit();
     f90:	e8 57 2f 00 00       	call   3eec <exit>
  else
    wait();
     f95:	e8 5a 2f 00 00       	call   3ef4 <wait>
  close(fd);
     f9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f9d:	89 04 24             	mov    %eax,(%esp)
     fa0:	e8 6f 2f 00 00       	call   3f14 <close>
  fd = open("sharedfd", 0);
     fa5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     fac:	00 
     fad:	c7 04 24 e2 49 00 00 	movl   $0x49e2,(%esp)
     fb4:	e8 73 2f 00 00       	call   3f2c <open>
     fb9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     fbc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     fc0:	79 19                	jns    fdb <sharedfd+0x129>
    printf(1, "fstests: cannot open sharedfd for reading\n");
     fc2:	c7 44 24 04 38 4a 00 	movl   $0x4a38,0x4(%esp)
     fc9:	00 
     fca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fd1:	e8 96 30 00 00       	call   406c <printf>
    return;
     fd6:	e9 d3 00 00 00       	jmp    10ae <sharedfd+0x1fc>
  }
  nc = np = 0;
     fdb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     fe2:	8b 45 ec             	mov    -0x14(%ebp),%eax
     fe5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
     fe8:	eb 3b                	jmp    1025 <sharedfd+0x173>
    for(i = 0; i < sizeof(buf); i++){
     fea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     ff1:	eb 2a                	jmp    101d <sharedfd+0x16b>
      if(buf[i] == 'c')
     ff3:	8d 55 d6             	lea    -0x2a(%ebp),%edx
     ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ff9:	01 d0                	add    %edx,%eax
     ffb:	0f b6 00             	movzbl (%eax),%eax
     ffe:	3c 63                	cmp    $0x63,%al
    1000:	75 04                	jne    1006 <sharedfd+0x154>
        nc++;
    1002:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(buf[i] == 'p')
    1006:	8d 55 d6             	lea    -0x2a(%ebp),%edx
    1009:	8b 45 f4             	mov    -0xc(%ebp),%eax
    100c:	01 d0                	add    %edx,%eax
    100e:	0f b6 00             	movzbl (%eax),%eax
    1011:	3c 70                	cmp    $0x70,%al
    1013:	75 04                	jne    1019 <sharedfd+0x167>
        np++;
    1015:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
    1019:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1020:	83 f8 09             	cmp    $0x9,%eax
    1023:	76 ce                	jbe    ff3 <sharedfd+0x141>
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    1025:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    102c:	00 
    102d:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    1030:	89 44 24 04          	mov    %eax,0x4(%esp)
    1034:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1037:	89 04 24             	mov    %eax,(%esp)
    103a:	e8 c5 2e 00 00       	call   3f04 <read>
    103f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    1042:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    1046:	7f a2                	jg     fea <sharedfd+0x138>
        nc++;
      if(buf[i] == 'p')
        np++;
    }
  }
  close(fd);
    1048:	8b 45 e8             	mov    -0x18(%ebp),%eax
    104b:	89 04 24             	mov    %eax,(%esp)
    104e:	e8 c1 2e 00 00       	call   3f14 <close>
  unlink("sharedfd");
    1053:	c7 04 24 e2 49 00 00 	movl   $0x49e2,(%esp)
    105a:	e8 dd 2e 00 00       	call   3f3c <unlink>
  if(nc == 10000 && np == 10000){
    105f:	81 7d f0 10 27 00 00 	cmpl   $0x2710,-0x10(%ebp)
    1066:	75 1f                	jne    1087 <sharedfd+0x1d5>
    1068:	81 7d ec 10 27 00 00 	cmpl   $0x2710,-0x14(%ebp)
    106f:	75 16                	jne    1087 <sharedfd+0x1d5>
    printf(1, "sharedfd ok\n");
    1071:	c7 44 24 04 63 4a 00 	movl   $0x4a63,0x4(%esp)
    1078:	00 
    1079:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1080:	e8 e7 2f 00 00       	call   406c <printf>
    1085:	eb 27                	jmp    10ae <sharedfd+0x1fc>
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
    1087:	8b 45 ec             	mov    -0x14(%ebp),%eax
    108a:	89 44 24 0c          	mov    %eax,0xc(%esp)
    108e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1091:	89 44 24 08          	mov    %eax,0x8(%esp)
    1095:	c7 44 24 04 70 4a 00 	movl   $0x4a70,0x4(%esp)
    109c:	00 
    109d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10a4:	e8 c3 2f 00 00       	call   406c <printf>
    exit();
    10a9:	e8 3e 2e 00 00       	call   3eec <exit>
  }
}
    10ae:	c9                   	leave  
    10af:	c3                   	ret    

000010b0 <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(void)
{
    10b0:	55                   	push   %ebp
    10b1:	89 e5                	mov    %esp,%ebp
    10b3:	83 ec 48             	sub    $0x48,%esp
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
    10b6:	c7 45 c8 85 4a 00 00 	movl   $0x4a85,-0x38(%ebp)
    10bd:	c7 45 cc 88 4a 00 00 	movl   $0x4a88,-0x34(%ebp)
    10c4:	c7 45 d0 8b 4a 00 00 	movl   $0x4a8b,-0x30(%ebp)
    10cb:	c7 45 d4 8e 4a 00 00 	movl   $0x4a8e,-0x2c(%ebp)
  char *fname;

  printf(1, "fourfiles test\n");
    10d2:	c7 44 24 04 91 4a 00 	movl   $0x4a91,0x4(%esp)
    10d9:	00 
    10da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10e1:	e8 86 2f 00 00       	call   406c <printf>

  for(pi = 0; pi < 4; pi++){
    10e6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    10ed:	e9 fc 00 00 00       	jmp    11ee <fourfiles+0x13e>
    fname = names[pi];
    10f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10f5:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    10f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    unlink(fname);
    10fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    10ff:	89 04 24             	mov    %eax,(%esp)
    1102:	e8 35 2e 00 00       	call   3f3c <unlink>

    pid = fork();
    1107:	e8 d8 2d 00 00       	call   3ee4 <fork>
    110c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(pid < 0){
    110f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    1113:	79 19                	jns    112e <fourfiles+0x7e>
      printf(1, "fork failed\n");
    1115:	c7 44 24 04 d9 44 00 	movl   $0x44d9,0x4(%esp)
    111c:	00 
    111d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1124:	e8 43 2f 00 00       	call   406c <printf>
      exit();
    1129:	e8 be 2d 00 00       	call   3eec <exit>
    }

    if(pid == 0){
    112e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    1132:	0f 85 b2 00 00 00    	jne    11ea <fourfiles+0x13a>
      fd = open(fname, O_CREATE | O_RDWR);
    1138:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    113f:	00 
    1140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1143:	89 04 24             	mov    %eax,(%esp)
    1146:	e8 e1 2d 00 00       	call   3f2c <open>
    114b:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if(fd < 0){
    114e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
    1152:	79 19                	jns    116d <fourfiles+0xbd>
        printf(1, "create failed\n");
    1154:	c7 44 24 04 a1 4a 00 	movl   $0x4aa1,0x4(%esp)
    115b:	00 
    115c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1163:	e8 04 2f 00 00       	call   406c <printf>
        exit();
    1168:	e8 7f 2d 00 00       	call   3eec <exit>
      }

      memset(buf, '0'+pi, 512);
    116d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1170:	83 c0 30             	add    $0x30,%eax
    1173:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    117a:	00 
    117b:	89 44 24 04          	mov    %eax,0x4(%esp)
    117f:	c7 04 24 20 8b 00 00 	movl   $0x8b20,(%esp)
    1186:	e8 b4 2b 00 00       	call   3d3f <memset>
      for(i = 0; i < 12; i++){
    118b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1192:	eb 4b                	jmp    11df <fourfiles+0x12f>
        if((n = write(fd, buf, 500)) != 500){
    1194:	c7 44 24 08 f4 01 00 	movl   $0x1f4,0x8(%esp)
    119b:	00 
    119c:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
    11a3:	00 
    11a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
    11a7:	89 04 24             	mov    %eax,(%esp)
    11aa:	e8 5d 2d 00 00       	call   3f0c <write>
    11af:	89 45 d8             	mov    %eax,-0x28(%ebp)
    11b2:	81 7d d8 f4 01 00 00 	cmpl   $0x1f4,-0x28(%ebp)
    11b9:	74 20                	je     11db <fourfiles+0x12b>
          printf(1, "write failed %d\n", n);
    11bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
    11be:	89 44 24 08          	mov    %eax,0x8(%esp)
    11c2:	c7 44 24 04 b0 4a 00 	movl   $0x4ab0,0x4(%esp)
    11c9:	00 
    11ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11d1:	e8 96 2e 00 00       	call   406c <printf>
          exit();
    11d6:	e8 11 2d 00 00       	call   3eec <exit>
        printf(1, "create failed\n");
        exit();
      }

      memset(buf, '0'+pi, 512);
      for(i = 0; i < 12; i++){
    11db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    11df:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
    11e3:	7e af                	jle    1194 <fourfiles+0xe4>
        if((n = write(fd, buf, 500)) != 500){
          printf(1, "write failed %d\n", n);
          exit();
        }
      }
      exit();
    11e5:	e8 02 2d 00 00       	call   3eec <exit>
  char *names[] = { "f0", "f1", "f2", "f3" };
  char *fname;

  printf(1, "fourfiles test\n");

  for(pi = 0; pi < 4; pi++){
    11ea:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    11ee:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    11f2:	0f 8e fa fe ff ff    	jle    10f2 <fourfiles+0x42>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    11f8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    11ff:	eb 09                	jmp    120a <fourfiles+0x15a>
    wait();
    1201:	e8 ee 2c 00 00       	call   3ef4 <wait>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    1206:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    120a:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    120e:	7e f1                	jle    1201 <fourfiles+0x151>
    wait();
  }

  for(i = 0; i < 2; i++){
    1210:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1217:	e9 dc 00 00 00       	jmp    12f8 <fourfiles+0x248>
    fname = names[i];
    121c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    121f:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    1223:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    fd = open(fname, 0);
    1226:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    122d:	00 
    122e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1231:	89 04 24             	mov    %eax,(%esp)
    1234:	e8 f3 2c 00 00       	call   3f2c <open>
    1239:	89 45 dc             	mov    %eax,-0x24(%ebp)

    total = 0;
    123c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    1243:	eb 4c                	jmp    1291 <fourfiles+0x1e1>
      for(j = 0; j < n; j++){
    1245:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    124c:	eb 35                	jmp    1283 <fourfiles+0x1d3>
        if(buf[j] != '0'+i){
    124e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1251:	05 20 8b 00 00       	add    $0x8b20,%eax
    1256:	0f b6 00             	movzbl (%eax),%eax
    1259:	0f be c0             	movsbl %al,%eax
    125c:	8b 55 f4             	mov    -0xc(%ebp),%edx
    125f:	83 c2 30             	add    $0x30,%edx
    1262:	39 d0                	cmp    %edx,%eax
    1264:	74 19                	je     127f <fourfiles+0x1cf>
          printf(1, "wrong char\n");
    1266:	c7 44 24 04 c1 4a 00 	movl   $0x4ac1,0x4(%esp)
    126d:	00 
    126e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1275:	e8 f2 2d 00 00       	call   406c <printf>
          exit();
    127a:	e8 6d 2c 00 00       	call   3eec <exit>
    fname = names[i];
    fd = open(fname, 0);

    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
    127f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1283:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1286:	3b 45 d8             	cmp    -0x28(%ebp),%eax
    1289:	7c c3                	jl     124e <fourfiles+0x19e>
        if(buf[j] != '0'+i){
          printf(1, "wrong char\n");
          exit();
        }
      }
      total += n;
    128b:	8b 45 d8             	mov    -0x28(%ebp),%eax
    128e:	01 45 ec             	add    %eax,-0x14(%ebp)
  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);

    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
    1291:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1298:	00 
    1299:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
    12a0:	00 
    12a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
    12a4:	89 04 24             	mov    %eax,(%esp)
    12a7:	e8 58 2c 00 00       	call   3f04 <read>
    12ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
    12af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
    12b3:	7f 90                	jg     1245 <fourfiles+0x195>
          exit();
        }
      }
      total += n;
    }
    close(fd);
    12b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
    12b8:	89 04 24             	mov    %eax,(%esp)
    12bb:	e8 54 2c 00 00       	call   3f14 <close>

    if(total != 12*500){
    12c0:	81 7d ec 70 17 00 00 	cmpl   $0x1770,-0x14(%ebp)
    12c7:	74 20                	je     12e9 <fourfiles+0x239>
      printf(1, "wrong length %d\n", total);
    12c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
    12cc:	89 44 24 08          	mov    %eax,0x8(%esp)
    12d0:	c7 44 24 04 cd 4a 00 	movl   $0x4acd,0x4(%esp)
    12d7:	00 
    12d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    12df:	e8 88 2d 00 00       	call   406c <printf>
      exit();
    12e4:	e8 03 2c 00 00       	call   3eec <exit>
    }
    unlink(fname);
    12e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12ec:	89 04 24             	mov    %eax,(%esp)
    12ef:	e8 48 2c 00 00       	call   3f3c <unlink>

  for(pi = 0; pi < 4; pi++){
    wait();
  }

  for(i = 0; i < 2; i++){
    12f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    12f8:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
    12fc:	0f 8e 1a ff ff ff    	jle    121c <fourfiles+0x16c>
      exit();
    }
    unlink(fname);
  }

  printf(1, "fourfiles ok\n");
    1302:	c7 44 24 04 de 4a 00 	movl   $0x4ade,0x4(%esp)
    1309:	00 
    130a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1311:	e8 56 2d 00 00       	call   406c <printf>
}
    1316:	c9                   	leave  
    1317:	c3                   	ret    

00001318 <createdelete>:

// four processes create and delete different files in same directory
void
createdelete(void)
{
    1318:	55                   	push   %ebp
    1319:	89 e5                	mov    %esp,%ebp
    131b:	83 ec 48             	sub    $0x48,%esp
  enum { N = 20 };
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");
    131e:	c7 44 24 04 ec 4a 00 	movl   $0x4aec,0x4(%esp)
    1325:	00 
    1326:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    132d:	e8 3a 2d 00 00       	call   406c <printf>

  for(pi = 0; pi < 4; pi++){
    1332:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1339:	e9 f4 00 00 00       	jmp    1432 <createdelete+0x11a>
    pid = fork();
    133e:	e8 a1 2b 00 00       	call   3ee4 <fork>
    1343:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    1346:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    134a:	79 19                	jns    1365 <createdelete+0x4d>
      printf(1, "fork failed\n");
    134c:	c7 44 24 04 d9 44 00 	movl   $0x44d9,0x4(%esp)
    1353:	00 
    1354:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    135b:	e8 0c 2d 00 00       	call   406c <printf>
      exit();
    1360:	e8 87 2b 00 00       	call   3eec <exit>
    }

    if(pid == 0){
    1365:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1369:	0f 85 bf 00 00 00    	jne    142e <createdelete+0x116>
      name[0] = 'p' + pi;
    136f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1372:	83 c0 70             	add    $0x70,%eax
    1375:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[2] = '\0';
    1378:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
      for(i = 0; i < N; i++){
    137c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1383:	e9 97 00 00 00       	jmp    141f <createdelete+0x107>
        name[1] = '0' + i;
    1388:	8b 45 f4             	mov    -0xc(%ebp),%eax
    138b:	83 c0 30             	add    $0x30,%eax
    138e:	88 45 c9             	mov    %al,-0x37(%ebp)
        fd = open(name, O_CREATE | O_RDWR);
    1391:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1398:	00 
    1399:	8d 45 c8             	lea    -0x38(%ebp),%eax
    139c:	89 04 24             	mov    %eax,(%esp)
    139f:	e8 88 2b 00 00       	call   3f2c <open>
    13a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(fd < 0){
    13a7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    13ab:	79 19                	jns    13c6 <createdelete+0xae>
          printf(1, "create failed\n");
    13ad:	c7 44 24 04 a1 4a 00 	movl   $0x4aa1,0x4(%esp)
    13b4:	00 
    13b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13bc:	e8 ab 2c 00 00       	call   406c <printf>
          exit();
    13c1:	e8 26 2b 00 00       	call   3eec <exit>
        }
        close(fd);
    13c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    13c9:	89 04 24             	mov    %eax,(%esp)
    13cc:	e8 43 2b 00 00       	call   3f14 <close>
        if(i > 0 && (i % 2 ) == 0){
    13d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    13d5:	7e 44                	jle    141b <createdelete+0x103>
    13d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13da:	83 e0 01             	and    $0x1,%eax
    13dd:	85 c0                	test   %eax,%eax
    13df:	75 3a                	jne    141b <createdelete+0x103>
          name[1] = '0' + (i / 2);
    13e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13e4:	89 c2                	mov    %eax,%edx
    13e6:	c1 ea 1f             	shr    $0x1f,%edx
    13e9:	01 d0                	add    %edx,%eax
    13eb:	d1 f8                	sar    %eax
    13ed:	83 c0 30             	add    $0x30,%eax
    13f0:	88 45 c9             	mov    %al,-0x37(%ebp)
          if(unlink(name) < 0){
    13f3:	8d 45 c8             	lea    -0x38(%ebp),%eax
    13f6:	89 04 24             	mov    %eax,(%esp)
    13f9:	e8 3e 2b 00 00       	call   3f3c <unlink>
    13fe:	85 c0                	test   %eax,%eax
    1400:	79 19                	jns    141b <createdelete+0x103>
            printf(1, "unlink failed\n");
    1402:	c7 44 24 04 5c 45 00 	movl   $0x455c,0x4(%esp)
    1409:	00 
    140a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1411:	e8 56 2c 00 00       	call   406c <printf>
            exit();
    1416:	e8 d1 2a 00 00       	call   3eec <exit>
    }

    if(pid == 0){
      name[0] = 'p' + pi;
      name[2] = '\0';
      for(i = 0; i < N; i++){
    141b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    141f:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    1423:	0f 8e 5f ff ff ff    	jle    1388 <createdelete+0x70>
            printf(1, "unlink failed\n");
            exit();
          }
        }
      }
      exit();
    1429:	e8 be 2a 00 00       	call   3eec <exit>
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");

  for(pi = 0; pi < 4; pi++){
    142e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1432:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    1436:	0f 8e 02 ff ff ff    	jle    133e <createdelete+0x26>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    143c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1443:	eb 09                	jmp    144e <createdelete+0x136>
    wait();
    1445:	e8 aa 2a 00 00       	call   3ef4 <wait>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    144a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    144e:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    1452:	7e f1                	jle    1445 <createdelete+0x12d>
    wait();
  }

  name[0] = name[1] = name[2] = 0;
    1454:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
    1458:	0f b6 45 ca          	movzbl -0x36(%ebp),%eax
    145c:	88 45 c9             	mov    %al,-0x37(%ebp)
    145f:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
    1463:	88 45 c8             	mov    %al,-0x38(%ebp)
  for(i = 0; i < N; i++){
    1466:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    146d:	e9 bb 00 00 00       	jmp    152d <createdelete+0x215>
    for(pi = 0; pi < 4; pi++){
    1472:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1479:	e9 a1 00 00 00       	jmp    151f <createdelete+0x207>
      name[0] = 'p' + pi;
    147e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1481:	83 c0 70             	add    $0x70,%eax
    1484:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    1487:	8b 45 f4             	mov    -0xc(%ebp),%eax
    148a:	83 c0 30             	add    $0x30,%eax
    148d:	88 45 c9             	mov    %al,-0x37(%ebp)
      fd = open(name, 0);
    1490:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1497:	00 
    1498:	8d 45 c8             	lea    -0x38(%ebp),%eax
    149b:	89 04 24             	mov    %eax,(%esp)
    149e:	e8 89 2a 00 00       	call   3f2c <open>
    14a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((i == 0 || i >= N/2) && fd < 0){
    14a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14aa:	74 06                	je     14b2 <createdelete+0x19a>
    14ac:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    14b0:	7e 26                	jle    14d8 <createdelete+0x1c0>
    14b2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    14b6:	79 20                	jns    14d8 <createdelete+0x1c0>
        printf(1, "oops createdelete %s didn't exist\n", name);
    14b8:	8d 45 c8             	lea    -0x38(%ebp),%eax
    14bb:	89 44 24 08          	mov    %eax,0x8(%esp)
    14bf:	c7 44 24 04 00 4b 00 	movl   $0x4b00,0x4(%esp)
    14c6:	00 
    14c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    14ce:	e8 99 2b 00 00       	call   406c <printf>
        exit();
    14d3:	e8 14 2a 00 00       	call   3eec <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    14d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14dc:	7e 2c                	jle    150a <createdelete+0x1f2>
    14de:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    14e2:	7f 26                	jg     150a <createdelete+0x1f2>
    14e4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    14e8:	78 20                	js     150a <createdelete+0x1f2>
        printf(1, "oops createdelete %s did exist\n", name);
    14ea:	8d 45 c8             	lea    -0x38(%ebp),%eax
    14ed:	89 44 24 08          	mov    %eax,0x8(%esp)
    14f1:	c7 44 24 04 24 4b 00 	movl   $0x4b24,0x4(%esp)
    14f8:	00 
    14f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1500:	e8 67 2b 00 00       	call   406c <printf>
        exit();
    1505:	e8 e2 29 00 00       	call   3eec <exit>
      }
      if(fd >= 0)
    150a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    150e:	78 0b                	js     151b <createdelete+0x203>
        close(fd);
    1510:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1513:	89 04 24             	mov    %eax,(%esp)
    1516:	e8 f9 29 00 00       	call   3f14 <close>
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    151b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    151f:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    1523:	0f 8e 55 ff ff ff    	jle    147e <createdelete+0x166>
  for(pi = 0; pi < 4; pi++){
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    1529:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    152d:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    1531:	0f 8e 3b ff ff ff    	jle    1472 <createdelete+0x15a>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    1537:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    153e:	eb 34                	jmp    1574 <createdelete+0x25c>
    for(pi = 0; pi < 4; pi++){
    1540:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1547:	eb 21                	jmp    156a <createdelete+0x252>
      name[0] = 'p' + i;
    1549:	8b 45 f4             	mov    -0xc(%ebp),%eax
    154c:	83 c0 70             	add    $0x70,%eax
    154f:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    1552:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1555:	83 c0 30             	add    $0x30,%eax
    1558:	88 45 c9             	mov    %al,-0x37(%ebp)
      unlink(name);
    155b:	8d 45 c8             	lea    -0x38(%ebp),%eax
    155e:	89 04 24             	mov    %eax,(%esp)
    1561:	e8 d6 29 00 00       	call   3f3c <unlink>
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    1566:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    156a:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    156e:	7e d9                	jle    1549 <createdelete+0x231>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    1570:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1574:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    1578:	7e c6                	jle    1540 <createdelete+0x228>
      name[1] = '0' + i;
      unlink(name);
    }
  }

  printf(1, "createdelete ok\n");
    157a:	c7 44 24 04 44 4b 00 	movl   $0x4b44,0x4(%esp)
    1581:	00 
    1582:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1589:	e8 de 2a 00 00       	call   406c <printf>
}
    158e:	c9                   	leave  
    158f:	c3                   	ret    

00001590 <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    1590:	55                   	push   %ebp
    1591:	89 e5                	mov    %esp,%ebp
    1593:	83 ec 28             	sub    $0x28,%esp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    1596:	c7 44 24 04 55 4b 00 	movl   $0x4b55,0x4(%esp)
    159d:	00 
    159e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15a5:	e8 c2 2a 00 00       	call   406c <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    15aa:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    15b1:	00 
    15b2:	c7 04 24 66 4b 00 00 	movl   $0x4b66,(%esp)
    15b9:	e8 6e 29 00 00       	call   3f2c <open>
    15be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    15c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15c5:	79 19                	jns    15e0 <unlinkread+0x50>
    printf(1, "create unlinkread failed\n");
    15c7:	c7 44 24 04 71 4b 00 	movl   $0x4b71,0x4(%esp)
    15ce:	00 
    15cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15d6:	e8 91 2a 00 00       	call   406c <printf>
    exit();
    15db:	e8 0c 29 00 00       	call   3eec <exit>
  }
  write(fd, "hello", 5);
    15e0:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    15e7:	00 
    15e8:	c7 44 24 04 8b 4b 00 	movl   $0x4b8b,0x4(%esp)
    15ef:	00 
    15f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15f3:	89 04 24             	mov    %eax,(%esp)
    15f6:	e8 11 29 00 00       	call   3f0c <write>
  close(fd);
    15fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15fe:	89 04 24             	mov    %eax,(%esp)
    1601:	e8 0e 29 00 00       	call   3f14 <close>

  fd = open("unlinkread", O_RDWR);
    1606:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    160d:	00 
    160e:	c7 04 24 66 4b 00 00 	movl   $0x4b66,(%esp)
    1615:	e8 12 29 00 00       	call   3f2c <open>
    161a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    161d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1621:	79 19                	jns    163c <unlinkread+0xac>
    printf(1, "open unlinkread failed\n");
    1623:	c7 44 24 04 91 4b 00 	movl   $0x4b91,0x4(%esp)
    162a:	00 
    162b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1632:	e8 35 2a 00 00       	call   406c <printf>
    exit();
    1637:	e8 b0 28 00 00       	call   3eec <exit>
  }
  if(unlink("unlinkread") != 0){
    163c:	c7 04 24 66 4b 00 00 	movl   $0x4b66,(%esp)
    1643:	e8 f4 28 00 00       	call   3f3c <unlink>
    1648:	85 c0                	test   %eax,%eax
    164a:	74 19                	je     1665 <unlinkread+0xd5>
    printf(1, "unlink unlinkread failed\n");
    164c:	c7 44 24 04 a9 4b 00 	movl   $0x4ba9,0x4(%esp)
    1653:	00 
    1654:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    165b:	e8 0c 2a 00 00       	call   406c <printf>
    exit();
    1660:	e8 87 28 00 00       	call   3eec <exit>
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    1665:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    166c:	00 
    166d:	c7 04 24 66 4b 00 00 	movl   $0x4b66,(%esp)
    1674:	e8 b3 28 00 00       	call   3f2c <open>
    1679:	89 45 f0             	mov    %eax,-0x10(%ebp)
  write(fd1, "yyy", 3);
    167c:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
    1683:	00 
    1684:	c7 44 24 04 c3 4b 00 	movl   $0x4bc3,0x4(%esp)
    168b:	00 
    168c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    168f:	89 04 24             	mov    %eax,(%esp)
    1692:	e8 75 28 00 00       	call   3f0c <write>
  close(fd1);
    1697:	8b 45 f0             	mov    -0x10(%ebp),%eax
    169a:	89 04 24             	mov    %eax,(%esp)
    169d:	e8 72 28 00 00       	call   3f14 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    16a2:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    16a9:	00 
    16aa:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
    16b1:	00 
    16b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16b5:	89 04 24             	mov    %eax,(%esp)
    16b8:	e8 47 28 00 00       	call   3f04 <read>
    16bd:	83 f8 05             	cmp    $0x5,%eax
    16c0:	74 19                	je     16db <unlinkread+0x14b>
    printf(1, "unlinkread read failed");
    16c2:	c7 44 24 04 c7 4b 00 	movl   $0x4bc7,0x4(%esp)
    16c9:	00 
    16ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16d1:	e8 96 29 00 00       	call   406c <printf>
    exit();
    16d6:	e8 11 28 00 00       	call   3eec <exit>
  }
  if(buf[0] != 'h'){
    16db:	0f b6 05 20 8b 00 00 	movzbl 0x8b20,%eax
    16e2:	3c 68                	cmp    $0x68,%al
    16e4:	74 19                	je     16ff <unlinkread+0x16f>
    printf(1, "unlinkread wrong data\n");
    16e6:	c7 44 24 04 de 4b 00 	movl   $0x4bde,0x4(%esp)
    16ed:	00 
    16ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16f5:	e8 72 29 00 00       	call   406c <printf>
    exit();
    16fa:	e8 ed 27 00 00       	call   3eec <exit>
  }
  if(write(fd, buf, 10) != 10){
    16ff:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1706:	00 
    1707:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
    170e:	00 
    170f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1712:	89 04 24             	mov    %eax,(%esp)
    1715:	e8 f2 27 00 00       	call   3f0c <write>
    171a:	83 f8 0a             	cmp    $0xa,%eax
    171d:	74 19                	je     1738 <unlinkread+0x1a8>
    printf(1, "unlinkread write failed\n");
    171f:	c7 44 24 04 f5 4b 00 	movl   $0x4bf5,0x4(%esp)
    1726:	00 
    1727:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    172e:	e8 39 29 00 00       	call   406c <printf>
    exit();
    1733:	e8 b4 27 00 00       	call   3eec <exit>
  }
  close(fd);
    1738:	8b 45 f4             	mov    -0xc(%ebp),%eax
    173b:	89 04 24             	mov    %eax,(%esp)
    173e:	e8 d1 27 00 00       	call   3f14 <close>
  unlink("unlinkread");
    1743:	c7 04 24 66 4b 00 00 	movl   $0x4b66,(%esp)
    174a:	e8 ed 27 00 00       	call   3f3c <unlink>
  printf(1, "unlinkread ok\n");
    174f:	c7 44 24 04 0e 4c 00 	movl   $0x4c0e,0x4(%esp)
    1756:	00 
    1757:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    175e:	e8 09 29 00 00       	call   406c <printf>
}
    1763:	c9                   	leave  
    1764:	c3                   	ret    

00001765 <linktest>:

void
linktest(void)
{
    1765:	55                   	push   %ebp
    1766:	89 e5                	mov    %esp,%ebp
    1768:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "linktest\n");
    176b:	c7 44 24 04 1d 4c 00 	movl   $0x4c1d,0x4(%esp)
    1772:	00 
    1773:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    177a:	e8 ed 28 00 00       	call   406c <printf>

  unlink("lf1");
    177f:	c7 04 24 27 4c 00 00 	movl   $0x4c27,(%esp)
    1786:	e8 b1 27 00 00       	call   3f3c <unlink>
  unlink("lf2");
    178b:	c7 04 24 2b 4c 00 00 	movl   $0x4c2b,(%esp)
    1792:	e8 a5 27 00 00       	call   3f3c <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    1797:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    179e:	00 
    179f:	c7 04 24 27 4c 00 00 	movl   $0x4c27,(%esp)
    17a6:	e8 81 27 00 00       	call   3f2c <open>
    17ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    17ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17b2:	79 19                	jns    17cd <linktest+0x68>
    printf(1, "create lf1 failed\n");
    17b4:	c7 44 24 04 2f 4c 00 	movl   $0x4c2f,0x4(%esp)
    17bb:	00 
    17bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17c3:	e8 a4 28 00 00       	call   406c <printf>
    exit();
    17c8:	e8 1f 27 00 00       	call   3eec <exit>
  }
  if(write(fd, "hello", 5) != 5){
    17cd:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    17d4:	00 
    17d5:	c7 44 24 04 8b 4b 00 	movl   $0x4b8b,0x4(%esp)
    17dc:	00 
    17dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e0:	89 04 24             	mov    %eax,(%esp)
    17e3:	e8 24 27 00 00       	call   3f0c <write>
    17e8:	83 f8 05             	cmp    $0x5,%eax
    17eb:	74 19                	je     1806 <linktest+0xa1>
    printf(1, "write lf1 failed\n");
    17ed:	c7 44 24 04 42 4c 00 	movl   $0x4c42,0x4(%esp)
    17f4:	00 
    17f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17fc:	e8 6b 28 00 00       	call   406c <printf>
    exit();
    1801:	e8 e6 26 00 00       	call   3eec <exit>
  }
  close(fd);
    1806:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1809:	89 04 24             	mov    %eax,(%esp)
    180c:	e8 03 27 00 00       	call   3f14 <close>

  if(link("lf1", "lf2") < 0){
    1811:	c7 44 24 04 2b 4c 00 	movl   $0x4c2b,0x4(%esp)
    1818:	00 
    1819:	c7 04 24 27 4c 00 00 	movl   $0x4c27,(%esp)
    1820:	e8 27 27 00 00       	call   3f4c <link>
    1825:	85 c0                	test   %eax,%eax
    1827:	79 19                	jns    1842 <linktest+0xdd>
    printf(1, "link lf1 lf2 failed\n");
    1829:	c7 44 24 04 54 4c 00 	movl   $0x4c54,0x4(%esp)
    1830:	00 
    1831:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1838:	e8 2f 28 00 00       	call   406c <printf>
    exit();
    183d:	e8 aa 26 00 00       	call   3eec <exit>
  }
  unlink("lf1");
    1842:	c7 04 24 27 4c 00 00 	movl   $0x4c27,(%esp)
    1849:	e8 ee 26 00 00       	call   3f3c <unlink>

  if(open("lf1", 0) >= 0){
    184e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1855:	00 
    1856:	c7 04 24 27 4c 00 00 	movl   $0x4c27,(%esp)
    185d:	e8 ca 26 00 00       	call   3f2c <open>
    1862:	85 c0                	test   %eax,%eax
    1864:	78 19                	js     187f <linktest+0x11a>
    printf(1, "unlinked lf1 but it is still there!\n");
    1866:	c7 44 24 04 6c 4c 00 	movl   $0x4c6c,0x4(%esp)
    186d:	00 
    186e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1875:	e8 f2 27 00 00       	call   406c <printf>
    exit();
    187a:	e8 6d 26 00 00       	call   3eec <exit>
  }

  fd = open("lf2", 0);
    187f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1886:	00 
    1887:	c7 04 24 2b 4c 00 00 	movl   $0x4c2b,(%esp)
    188e:	e8 99 26 00 00       	call   3f2c <open>
    1893:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1896:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    189a:	79 19                	jns    18b5 <linktest+0x150>
    printf(1, "open lf2 failed\n");
    189c:	c7 44 24 04 91 4c 00 	movl   $0x4c91,0x4(%esp)
    18a3:	00 
    18a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18ab:	e8 bc 27 00 00       	call   406c <printf>
    exit();
    18b0:	e8 37 26 00 00       	call   3eec <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    18b5:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    18bc:	00 
    18bd:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
    18c4:	00 
    18c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18c8:	89 04 24             	mov    %eax,(%esp)
    18cb:	e8 34 26 00 00       	call   3f04 <read>
    18d0:	83 f8 05             	cmp    $0x5,%eax
    18d3:	74 19                	je     18ee <linktest+0x189>
    printf(1, "read lf2 failed\n");
    18d5:	c7 44 24 04 a2 4c 00 	movl   $0x4ca2,0x4(%esp)
    18dc:	00 
    18dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18e4:	e8 83 27 00 00       	call   406c <printf>
    exit();
    18e9:	e8 fe 25 00 00       	call   3eec <exit>
  }
  close(fd);
    18ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18f1:	89 04 24             	mov    %eax,(%esp)
    18f4:	e8 1b 26 00 00       	call   3f14 <close>

  if(link("lf2", "lf2") >= 0){
    18f9:	c7 44 24 04 2b 4c 00 	movl   $0x4c2b,0x4(%esp)
    1900:	00 
    1901:	c7 04 24 2b 4c 00 00 	movl   $0x4c2b,(%esp)
    1908:	e8 3f 26 00 00       	call   3f4c <link>
    190d:	85 c0                	test   %eax,%eax
    190f:	78 19                	js     192a <linktest+0x1c5>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    1911:	c7 44 24 04 b3 4c 00 	movl   $0x4cb3,0x4(%esp)
    1918:	00 
    1919:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1920:	e8 47 27 00 00       	call   406c <printf>
    exit();
    1925:	e8 c2 25 00 00       	call   3eec <exit>
  }

  unlink("lf2");
    192a:	c7 04 24 2b 4c 00 00 	movl   $0x4c2b,(%esp)
    1931:	e8 06 26 00 00       	call   3f3c <unlink>
  if(link("lf2", "lf1") >= 0){
    1936:	c7 44 24 04 27 4c 00 	movl   $0x4c27,0x4(%esp)
    193d:	00 
    193e:	c7 04 24 2b 4c 00 00 	movl   $0x4c2b,(%esp)
    1945:	e8 02 26 00 00       	call   3f4c <link>
    194a:	85 c0                	test   %eax,%eax
    194c:	78 19                	js     1967 <linktest+0x202>
    printf(1, "link non-existant succeeded! oops\n");
    194e:	c7 44 24 04 d4 4c 00 	movl   $0x4cd4,0x4(%esp)
    1955:	00 
    1956:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    195d:	e8 0a 27 00 00       	call   406c <printf>
    exit();
    1962:	e8 85 25 00 00       	call   3eec <exit>
  }

  if(link(".", "lf1") >= 0){
    1967:	c7 44 24 04 27 4c 00 	movl   $0x4c27,0x4(%esp)
    196e:	00 
    196f:	c7 04 24 f7 4c 00 00 	movl   $0x4cf7,(%esp)
    1976:	e8 d1 25 00 00       	call   3f4c <link>
    197b:	85 c0                	test   %eax,%eax
    197d:	78 19                	js     1998 <linktest+0x233>
    printf(1, "link . lf1 succeeded! oops\n");
    197f:	c7 44 24 04 f9 4c 00 	movl   $0x4cf9,0x4(%esp)
    1986:	00 
    1987:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    198e:	e8 d9 26 00 00       	call   406c <printf>
    exit();
    1993:	e8 54 25 00 00       	call   3eec <exit>
  }

  printf(1, "linktest ok\n");
    1998:	c7 44 24 04 15 4d 00 	movl   $0x4d15,0x4(%esp)
    199f:	00 
    19a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    19a7:	e8 c0 26 00 00       	call   406c <printf>
}
    19ac:	c9                   	leave  
    19ad:	c3                   	ret    

000019ae <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    19ae:	55                   	push   %ebp
    19af:	89 e5                	mov    %esp,%ebp
    19b1:	83 ec 68             	sub    $0x68,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    19b4:	c7 44 24 04 22 4d 00 	movl   $0x4d22,0x4(%esp)
    19bb:	00 
    19bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    19c3:	e8 a4 26 00 00       	call   406c <printf>
  file[0] = 'C';
    19c8:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    19cc:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    19d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    19d7:	e9 f7 00 00 00       	jmp    1ad3 <concreate+0x125>
    file[1] = '0' + i;
    19dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    19df:	83 c0 30             	add    $0x30,%eax
    19e2:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    19e5:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19e8:	89 04 24             	mov    %eax,(%esp)
    19eb:	e8 4c 25 00 00       	call   3f3c <unlink>
    pid = fork();
    19f0:	e8 ef 24 00 00       	call   3ee4 <fork>
    19f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid && (i % 3) == 1){
    19f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    19fc:	74 3a                	je     1a38 <concreate+0x8a>
    19fe:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1a01:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1a06:	89 c8                	mov    %ecx,%eax
    1a08:	f7 ea                	imul   %edx
    1a0a:	89 c8                	mov    %ecx,%eax
    1a0c:	c1 f8 1f             	sar    $0x1f,%eax
    1a0f:	29 c2                	sub    %eax,%edx
    1a11:	89 d0                	mov    %edx,%eax
    1a13:	01 c0                	add    %eax,%eax
    1a15:	01 d0                	add    %edx,%eax
    1a17:	29 c1                	sub    %eax,%ecx
    1a19:	89 ca                	mov    %ecx,%edx
    1a1b:	83 fa 01             	cmp    $0x1,%edx
    1a1e:	75 18                	jne    1a38 <concreate+0x8a>
      link("C0", file);
    1a20:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1a23:	89 44 24 04          	mov    %eax,0x4(%esp)
    1a27:	c7 04 24 32 4d 00 00 	movl   $0x4d32,(%esp)
    1a2e:	e8 19 25 00 00       	call   3f4c <link>
    1a33:	e9 87 00 00 00       	jmp    1abf <concreate+0x111>
    } else if(pid == 0 && (i % 5) == 1){
    1a38:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1a3c:	75 3a                	jne    1a78 <concreate+0xca>
    1a3e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1a41:	ba 67 66 66 66       	mov    $0x66666667,%edx
    1a46:	89 c8                	mov    %ecx,%eax
    1a48:	f7 ea                	imul   %edx
    1a4a:	d1 fa                	sar    %edx
    1a4c:	89 c8                	mov    %ecx,%eax
    1a4e:	c1 f8 1f             	sar    $0x1f,%eax
    1a51:	29 c2                	sub    %eax,%edx
    1a53:	89 d0                	mov    %edx,%eax
    1a55:	c1 e0 02             	shl    $0x2,%eax
    1a58:	01 d0                	add    %edx,%eax
    1a5a:	29 c1                	sub    %eax,%ecx
    1a5c:	89 ca                	mov    %ecx,%edx
    1a5e:	83 fa 01             	cmp    $0x1,%edx
    1a61:	75 15                	jne    1a78 <concreate+0xca>
      link("C0", file);
    1a63:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1a66:	89 44 24 04          	mov    %eax,0x4(%esp)
    1a6a:	c7 04 24 32 4d 00 00 	movl   $0x4d32,(%esp)
    1a71:	e8 d6 24 00 00       	call   3f4c <link>
    1a76:	eb 47                	jmp    1abf <concreate+0x111>
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    1a78:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1a7f:	00 
    1a80:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1a83:	89 04 24             	mov    %eax,(%esp)
    1a86:	e8 a1 24 00 00       	call   3f2c <open>
    1a8b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(fd < 0){
    1a8e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1a92:	79 20                	jns    1ab4 <concreate+0x106>
        printf(1, "concreate create %s failed\n", file);
    1a94:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1a97:	89 44 24 08          	mov    %eax,0x8(%esp)
    1a9b:	c7 44 24 04 35 4d 00 	movl   $0x4d35,0x4(%esp)
    1aa2:	00 
    1aa3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1aaa:	e8 bd 25 00 00       	call   406c <printf>
        exit();
    1aaf:	e8 38 24 00 00       	call   3eec <exit>
      }
      close(fd);
    1ab4:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1ab7:	89 04 24             	mov    %eax,(%esp)
    1aba:	e8 55 24 00 00       	call   3f14 <close>
    }
    if(pid == 0)
    1abf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1ac3:	75 05                	jne    1aca <concreate+0x11c>
      exit();
    1ac5:	e8 22 24 00 00       	call   3eec <exit>
    else
      wait();
    1aca:	e8 25 24 00 00       	call   3ef4 <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    1acf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1ad3:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1ad7:	0f 8e ff fe ff ff    	jle    19dc <concreate+0x2e>
      exit();
    else
      wait();
  }

  memset(fa, 0, sizeof(fa));
    1add:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
    1ae4:	00 
    1ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1aec:	00 
    1aed:	8d 45 bd             	lea    -0x43(%ebp),%eax
    1af0:	89 04 24             	mov    %eax,(%esp)
    1af3:	e8 47 22 00 00       	call   3d3f <memset>
  fd = open(".", 0);
    1af8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1aff:	00 
    1b00:	c7 04 24 f7 4c 00 00 	movl   $0x4cf7,(%esp)
    1b07:	e8 20 24 00 00       	call   3f2c <open>
    1b0c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  n = 0;
    1b0f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  while(read(fd, &de, sizeof(de)) > 0){
    1b16:	e9 a1 00 00 00       	jmp    1bbc <concreate+0x20e>
    if(de.inum == 0)
    1b1b:	0f b7 45 ac          	movzwl -0x54(%ebp),%eax
    1b1f:	66 85 c0             	test   %ax,%ax
    1b22:	75 05                	jne    1b29 <concreate+0x17b>
      continue;
    1b24:	e9 93 00 00 00       	jmp    1bbc <concreate+0x20e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    1b29:	0f b6 45 ae          	movzbl -0x52(%ebp),%eax
    1b2d:	3c 43                	cmp    $0x43,%al
    1b2f:	0f 85 87 00 00 00    	jne    1bbc <concreate+0x20e>
    1b35:	0f b6 45 b0          	movzbl -0x50(%ebp),%eax
    1b39:	84 c0                	test   %al,%al
    1b3b:	75 7f                	jne    1bbc <concreate+0x20e>
      i = de.name[1] - '0';
    1b3d:	0f b6 45 af          	movzbl -0x51(%ebp),%eax
    1b41:	0f be c0             	movsbl %al,%eax
    1b44:	83 e8 30             	sub    $0x30,%eax
    1b47:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(i < 0 || i >= sizeof(fa)){
    1b4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1b4e:	78 08                	js     1b58 <concreate+0x1aa>
    1b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b53:	83 f8 27             	cmp    $0x27,%eax
    1b56:	76 23                	jbe    1b7b <concreate+0x1cd>
        printf(1, "concreate weird file %s\n", de.name);
    1b58:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1b5b:	83 c0 02             	add    $0x2,%eax
    1b5e:	89 44 24 08          	mov    %eax,0x8(%esp)
    1b62:	c7 44 24 04 51 4d 00 	movl   $0x4d51,0x4(%esp)
    1b69:	00 
    1b6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b71:	e8 f6 24 00 00       	call   406c <printf>
        exit();
    1b76:	e8 71 23 00 00       	call   3eec <exit>
      }
      if(fa[i]){
    1b7b:	8d 55 bd             	lea    -0x43(%ebp),%edx
    1b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b81:	01 d0                	add    %edx,%eax
    1b83:	0f b6 00             	movzbl (%eax),%eax
    1b86:	84 c0                	test   %al,%al
    1b88:	74 23                	je     1bad <concreate+0x1ff>
        printf(1, "concreate duplicate file %s\n", de.name);
    1b8a:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1b8d:	83 c0 02             	add    $0x2,%eax
    1b90:	89 44 24 08          	mov    %eax,0x8(%esp)
    1b94:	c7 44 24 04 6a 4d 00 	movl   $0x4d6a,0x4(%esp)
    1b9b:	00 
    1b9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ba3:	e8 c4 24 00 00       	call   406c <printf>
        exit();
    1ba8:	e8 3f 23 00 00       	call   3eec <exit>
      }
      fa[i] = 1;
    1bad:	8d 55 bd             	lea    -0x43(%ebp),%edx
    1bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1bb3:	01 d0                	add    %edx,%eax
    1bb5:	c6 00 01             	movb   $0x1,(%eax)
      n++;
    1bb8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  }

  memset(fa, 0, sizeof(fa));
  fd = open(".", 0);
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    1bbc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1bc3:	00 
    1bc4:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1bc7:	89 44 24 04          	mov    %eax,0x4(%esp)
    1bcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1bce:	89 04 24             	mov    %eax,(%esp)
    1bd1:	e8 2e 23 00 00       	call   3f04 <read>
    1bd6:	85 c0                	test   %eax,%eax
    1bd8:	0f 8f 3d ff ff ff    	jg     1b1b <concreate+0x16d>
      }
      fa[i] = 1;
      n++;
    }
  }
  close(fd);
    1bde:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1be1:	89 04 24             	mov    %eax,(%esp)
    1be4:	e8 2b 23 00 00       	call   3f14 <close>

  if(n != 40){
    1be9:	83 7d f0 28          	cmpl   $0x28,-0x10(%ebp)
    1bed:	74 19                	je     1c08 <concreate+0x25a>
    printf(1, "concreate not enough files in directory listing\n");
    1bef:	c7 44 24 04 88 4d 00 	movl   $0x4d88,0x4(%esp)
    1bf6:	00 
    1bf7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1bfe:	e8 69 24 00 00       	call   406c <printf>
    exit();
    1c03:	e8 e4 22 00 00       	call   3eec <exit>
  }

  for(i = 0; i < 40; i++){
    1c08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1c0f:	e9 2d 01 00 00       	jmp    1d41 <concreate+0x393>
    file[1] = '0' + i;
    1c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1c17:	83 c0 30             	add    $0x30,%eax
    1c1a:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    1c1d:	e8 c2 22 00 00       	call   3ee4 <fork>
    1c22:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    1c25:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1c29:	79 19                	jns    1c44 <concreate+0x296>
      printf(1, "fork failed\n");
    1c2b:	c7 44 24 04 d9 44 00 	movl   $0x44d9,0x4(%esp)
    1c32:	00 
    1c33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1c3a:	e8 2d 24 00 00       	call   406c <printf>
      exit();
    1c3f:	e8 a8 22 00 00       	call   3eec <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
    1c44:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1c47:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1c4c:	89 c8                	mov    %ecx,%eax
    1c4e:	f7 ea                	imul   %edx
    1c50:	89 c8                	mov    %ecx,%eax
    1c52:	c1 f8 1f             	sar    $0x1f,%eax
    1c55:	29 c2                	sub    %eax,%edx
    1c57:	89 d0                	mov    %edx,%eax
    1c59:	01 c0                	add    %eax,%eax
    1c5b:	01 d0                	add    %edx,%eax
    1c5d:	29 c1                	sub    %eax,%ecx
    1c5f:	89 ca                	mov    %ecx,%edx
    1c61:	85 d2                	test   %edx,%edx
    1c63:	75 06                	jne    1c6b <concreate+0x2bd>
    1c65:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1c69:	74 28                	je     1c93 <concreate+0x2e5>
       ((i % 3) == 1 && pid != 0)){
    1c6b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1c6e:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1c73:	89 c8                	mov    %ecx,%eax
    1c75:	f7 ea                	imul   %edx
    1c77:	89 c8                	mov    %ecx,%eax
    1c79:	c1 f8 1f             	sar    $0x1f,%eax
    1c7c:	29 c2                	sub    %eax,%edx
    1c7e:	89 d0                	mov    %edx,%eax
    1c80:	01 c0                	add    %eax,%eax
    1c82:	01 d0                	add    %edx,%eax
    1c84:	29 c1                	sub    %eax,%ecx
    1c86:	89 ca                	mov    %ecx,%edx
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      exit();
    }
    if(((i % 3) == 0 && pid == 0) ||
    1c88:	83 fa 01             	cmp    $0x1,%edx
    1c8b:	75 74                	jne    1d01 <concreate+0x353>
       ((i % 3) == 1 && pid != 0)){
    1c8d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1c91:	74 6e                	je     1d01 <concreate+0x353>
      close(open(file, 0));
    1c93:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1c9a:	00 
    1c9b:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c9e:	89 04 24             	mov    %eax,(%esp)
    1ca1:	e8 86 22 00 00       	call   3f2c <open>
    1ca6:	89 04 24             	mov    %eax,(%esp)
    1ca9:	e8 66 22 00 00       	call   3f14 <close>
      close(open(file, 0));
    1cae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1cb5:	00 
    1cb6:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1cb9:	89 04 24             	mov    %eax,(%esp)
    1cbc:	e8 6b 22 00 00       	call   3f2c <open>
    1cc1:	89 04 24             	mov    %eax,(%esp)
    1cc4:	e8 4b 22 00 00       	call   3f14 <close>
      close(open(file, 0));
    1cc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1cd0:	00 
    1cd1:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1cd4:	89 04 24             	mov    %eax,(%esp)
    1cd7:	e8 50 22 00 00       	call   3f2c <open>
    1cdc:	89 04 24             	mov    %eax,(%esp)
    1cdf:	e8 30 22 00 00       	call   3f14 <close>
      close(open(file, 0));
    1ce4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1ceb:	00 
    1cec:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1cef:	89 04 24             	mov    %eax,(%esp)
    1cf2:	e8 35 22 00 00       	call   3f2c <open>
    1cf7:	89 04 24             	mov    %eax,(%esp)
    1cfa:	e8 15 22 00 00       	call   3f14 <close>
    1cff:	eb 2c                	jmp    1d2d <concreate+0x37f>
    } else {
      unlink(file);
    1d01:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1d04:	89 04 24             	mov    %eax,(%esp)
    1d07:	e8 30 22 00 00       	call   3f3c <unlink>
      unlink(file);
    1d0c:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1d0f:	89 04 24             	mov    %eax,(%esp)
    1d12:	e8 25 22 00 00       	call   3f3c <unlink>
      unlink(file);
    1d17:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1d1a:	89 04 24             	mov    %eax,(%esp)
    1d1d:	e8 1a 22 00 00       	call   3f3c <unlink>
      unlink(file);
    1d22:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1d25:	89 04 24             	mov    %eax,(%esp)
    1d28:	e8 0f 22 00 00       	call   3f3c <unlink>
    }
    if(pid == 0)
    1d2d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1d31:	75 05                	jne    1d38 <concreate+0x38a>
      exit();
    1d33:	e8 b4 21 00 00       	call   3eec <exit>
    else
      wait();
    1d38:	e8 b7 21 00 00       	call   3ef4 <wait>
  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    exit();
  }

  for(i = 0; i < 40; i++){
    1d3d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1d41:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1d45:	0f 8e c9 fe ff ff    	jle    1c14 <concreate+0x266>
      exit();
    else
      wait();
  }

  printf(1, "concreate ok\n");
    1d4b:	c7 44 24 04 b9 4d 00 	movl   $0x4db9,0x4(%esp)
    1d52:	00 
    1d53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d5a:	e8 0d 23 00 00       	call   406c <printf>
}
    1d5f:	c9                   	leave  
    1d60:	c3                   	ret    

00001d61 <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    1d61:	55                   	push   %ebp
    1d62:	89 e5                	mov    %esp,%ebp
    1d64:	83 ec 28             	sub    $0x28,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    1d67:	c7 44 24 04 c7 4d 00 	movl   $0x4dc7,0x4(%esp)
    1d6e:	00 
    1d6f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d76:	e8 f1 22 00 00       	call   406c <printf>

  unlink("x");
    1d7b:	c7 04 24 33 49 00 00 	movl   $0x4933,(%esp)
    1d82:	e8 b5 21 00 00       	call   3f3c <unlink>
  pid = fork();
    1d87:	e8 58 21 00 00       	call   3ee4 <fork>
    1d8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid < 0){
    1d8f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1d93:	79 19                	jns    1dae <linkunlink+0x4d>
    printf(1, "fork failed\n");
    1d95:	c7 44 24 04 d9 44 00 	movl   $0x44d9,0x4(%esp)
    1d9c:	00 
    1d9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1da4:	e8 c3 22 00 00       	call   406c <printf>
    exit();
    1da9:	e8 3e 21 00 00       	call   3eec <exit>
  }

  unsigned int x = (pid ? 1 : 97);
    1dae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1db2:	74 07                	je     1dbb <linkunlink+0x5a>
    1db4:	b8 01 00 00 00       	mov    $0x1,%eax
    1db9:	eb 05                	jmp    1dc0 <linkunlink+0x5f>
    1dbb:	b8 61 00 00 00       	mov    $0x61,%eax
    1dc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; i < 100; i++){
    1dc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1dca:	e9 8e 00 00 00       	jmp    1e5d <linkunlink+0xfc>
    x = x * 1103515245 + 12345;
    1dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1dd2:	69 c0 6d 4e c6 41    	imul   $0x41c64e6d,%eax,%eax
    1dd8:	05 39 30 00 00       	add    $0x3039,%eax
    1ddd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((x % 3) == 0){
    1de0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1de3:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1de8:	89 c8                	mov    %ecx,%eax
    1dea:	f7 e2                	mul    %edx
    1dec:	d1 ea                	shr    %edx
    1dee:	89 d0                	mov    %edx,%eax
    1df0:	01 c0                	add    %eax,%eax
    1df2:	01 d0                	add    %edx,%eax
    1df4:	29 c1                	sub    %eax,%ecx
    1df6:	89 ca                	mov    %ecx,%edx
    1df8:	85 d2                	test   %edx,%edx
    1dfa:	75 1e                	jne    1e1a <linkunlink+0xb9>
      close(open("x", O_RDWR | O_CREATE));
    1dfc:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1e03:	00 
    1e04:	c7 04 24 33 49 00 00 	movl   $0x4933,(%esp)
    1e0b:	e8 1c 21 00 00       	call   3f2c <open>
    1e10:	89 04 24             	mov    %eax,(%esp)
    1e13:	e8 fc 20 00 00       	call   3f14 <close>
    1e18:	eb 3f                	jmp    1e59 <linkunlink+0xf8>
    } else if((x % 3) == 1){
    1e1a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1e1d:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1e22:	89 c8                	mov    %ecx,%eax
    1e24:	f7 e2                	mul    %edx
    1e26:	d1 ea                	shr    %edx
    1e28:	89 d0                	mov    %edx,%eax
    1e2a:	01 c0                	add    %eax,%eax
    1e2c:	01 d0                	add    %edx,%eax
    1e2e:	29 c1                	sub    %eax,%ecx
    1e30:	89 ca                	mov    %ecx,%edx
    1e32:	83 fa 01             	cmp    $0x1,%edx
    1e35:	75 16                	jne    1e4d <linkunlink+0xec>
      link("cat", "x");
    1e37:	c7 44 24 04 33 49 00 	movl   $0x4933,0x4(%esp)
    1e3e:	00 
    1e3f:	c7 04 24 d8 4d 00 00 	movl   $0x4dd8,(%esp)
    1e46:	e8 01 21 00 00       	call   3f4c <link>
    1e4b:	eb 0c                	jmp    1e59 <linkunlink+0xf8>
    } else {
      unlink("x");
    1e4d:	c7 04 24 33 49 00 00 	movl   $0x4933,(%esp)
    1e54:	e8 e3 20 00 00       	call   3f3c <unlink>
    printf(1, "fork failed\n");
    exit();
  }

  unsigned int x = (pid ? 1 : 97);
  for(i = 0; i < 100; i++){
    1e59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1e5d:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
    1e61:	0f 8e 68 ff ff ff    	jle    1dcf <linkunlink+0x6e>
    } else {
      unlink("x");
    }
  }

  if(pid)
    1e67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1e6b:	74 07                	je     1e74 <linkunlink+0x113>
    wait();
    1e6d:	e8 82 20 00 00       	call   3ef4 <wait>
    1e72:	eb 05                	jmp    1e79 <linkunlink+0x118>
  else 
    exit();
    1e74:	e8 73 20 00 00       	call   3eec <exit>

  printf(1, "linkunlink ok\n");
    1e79:	c7 44 24 04 dc 4d 00 	movl   $0x4ddc,0x4(%esp)
    1e80:	00 
    1e81:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e88:	e8 df 21 00 00       	call   406c <printf>
}
    1e8d:	c9                   	leave  
    1e8e:	c3                   	ret    

00001e8f <bigdir>:

// directory that uses indirect blocks
void
bigdir(void)
{
    1e8f:	55                   	push   %ebp
    1e90:	89 e5                	mov    %esp,%ebp
    1e92:	83 ec 38             	sub    $0x38,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    1e95:	c7 44 24 04 eb 4d 00 	movl   $0x4deb,0x4(%esp)
    1e9c:	00 
    1e9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ea4:	e8 c3 21 00 00       	call   406c <printf>
  unlink("bd");
    1ea9:	c7 04 24 f8 4d 00 00 	movl   $0x4df8,(%esp)
    1eb0:	e8 87 20 00 00       	call   3f3c <unlink>

  fd = open("bd", O_CREATE);
    1eb5:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    1ebc:	00 
    1ebd:	c7 04 24 f8 4d 00 00 	movl   $0x4df8,(%esp)
    1ec4:	e8 63 20 00 00       	call   3f2c <open>
    1ec9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd < 0){
    1ecc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1ed0:	79 19                	jns    1eeb <bigdir+0x5c>
    printf(1, "bigdir create failed\n");
    1ed2:	c7 44 24 04 fb 4d 00 	movl   $0x4dfb,0x4(%esp)
    1ed9:	00 
    1eda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ee1:	e8 86 21 00 00       	call   406c <printf>
    exit();
    1ee6:	e8 01 20 00 00       	call   3eec <exit>
  }
  close(fd);
    1eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1eee:	89 04 24             	mov    %eax,(%esp)
    1ef1:	e8 1e 20 00 00       	call   3f14 <close>

  for(i = 0; i < 500; i++){
    1ef6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1efd:	eb 64                	jmp    1f63 <bigdir+0xd4>
    name[0] = 'x';
    1eff:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    1f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1f06:	8d 50 3f             	lea    0x3f(%eax),%edx
    1f09:	85 c0                	test   %eax,%eax
    1f0b:	0f 48 c2             	cmovs  %edx,%eax
    1f0e:	c1 f8 06             	sar    $0x6,%eax
    1f11:	83 c0 30             	add    $0x30,%eax
    1f14:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    1f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1f1a:	99                   	cltd   
    1f1b:	c1 ea 1a             	shr    $0x1a,%edx
    1f1e:	01 d0                	add    %edx,%eax
    1f20:	83 e0 3f             	and    $0x3f,%eax
    1f23:	29 d0                	sub    %edx,%eax
    1f25:	83 c0 30             	add    $0x30,%eax
    1f28:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    1f2b:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(link("bd", name) != 0){
    1f2f:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    1f32:	89 44 24 04          	mov    %eax,0x4(%esp)
    1f36:	c7 04 24 f8 4d 00 00 	movl   $0x4df8,(%esp)
    1f3d:	e8 0a 20 00 00       	call   3f4c <link>
    1f42:	85 c0                	test   %eax,%eax
    1f44:	74 19                	je     1f5f <bigdir+0xd0>
      printf(1, "bigdir link failed\n");
    1f46:	c7 44 24 04 11 4e 00 	movl   $0x4e11,0x4(%esp)
    1f4d:	00 
    1f4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f55:	e8 12 21 00 00       	call   406c <printf>
      exit();
    1f5a:	e8 8d 1f 00 00       	call   3eec <exit>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);

  for(i = 0; i < 500; i++){
    1f5f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1f63:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    1f6a:	7e 93                	jle    1eff <bigdir+0x70>
      printf(1, "bigdir link failed\n");
      exit();
    }
  }

  unlink("bd");
    1f6c:	c7 04 24 f8 4d 00 00 	movl   $0x4df8,(%esp)
    1f73:	e8 c4 1f 00 00       	call   3f3c <unlink>
  for(i = 0; i < 500; i++){
    1f78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1f7f:	eb 5c                	jmp    1fdd <bigdir+0x14e>
    name[0] = 'x';
    1f81:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    1f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1f88:	8d 50 3f             	lea    0x3f(%eax),%edx
    1f8b:	85 c0                	test   %eax,%eax
    1f8d:	0f 48 c2             	cmovs  %edx,%eax
    1f90:	c1 f8 06             	sar    $0x6,%eax
    1f93:	83 c0 30             	add    $0x30,%eax
    1f96:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    1f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1f9c:	99                   	cltd   
    1f9d:	c1 ea 1a             	shr    $0x1a,%edx
    1fa0:	01 d0                	add    %edx,%eax
    1fa2:	83 e0 3f             	and    $0x3f,%eax
    1fa5:	29 d0                	sub    %edx,%eax
    1fa7:	83 c0 30             	add    $0x30,%eax
    1faa:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    1fad:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(unlink(name) != 0){
    1fb1:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    1fb4:	89 04 24             	mov    %eax,(%esp)
    1fb7:	e8 80 1f 00 00       	call   3f3c <unlink>
    1fbc:	85 c0                	test   %eax,%eax
    1fbe:	74 19                	je     1fd9 <bigdir+0x14a>
      printf(1, "bigdir unlink failed");
    1fc0:	c7 44 24 04 25 4e 00 	movl   $0x4e25,0x4(%esp)
    1fc7:	00 
    1fc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1fcf:	e8 98 20 00 00       	call   406c <printf>
      exit();
    1fd4:	e8 13 1f 00 00       	call   3eec <exit>
      exit();
    }
  }

  unlink("bd");
  for(i = 0; i < 500; i++){
    1fd9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1fdd:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    1fe4:	7e 9b                	jle    1f81 <bigdir+0xf2>
      printf(1, "bigdir unlink failed");
      exit();
    }
  }

  printf(1, "bigdir ok\n");
    1fe6:	c7 44 24 04 3a 4e 00 	movl   $0x4e3a,0x4(%esp)
    1fed:	00 
    1fee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ff5:	e8 72 20 00 00       	call   406c <printf>
}
    1ffa:	c9                   	leave  
    1ffb:	c3                   	ret    

00001ffc <subdir>:

void
subdir(void)
{
    1ffc:	55                   	push   %ebp
    1ffd:	89 e5                	mov    %esp,%ebp
    1fff:	83 ec 28             	sub    $0x28,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    2002:	c7 44 24 04 45 4e 00 	movl   $0x4e45,0x4(%esp)
    2009:	00 
    200a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2011:	e8 56 20 00 00       	call   406c <printf>

  unlink("ff");
    2016:	c7 04 24 52 4e 00 00 	movl   $0x4e52,(%esp)
    201d:	e8 1a 1f 00 00       	call   3f3c <unlink>
  if(mkdir("dd") != 0){
    2022:	c7 04 24 55 4e 00 00 	movl   $0x4e55,(%esp)
    2029:	e8 26 1f 00 00       	call   3f54 <mkdir>
    202e:	85 c0                	test   %eax,%eax
    2030:	74 19                	je     204b <subdir+0x4f>
    printf(1, "subdir mkdir dd failed\n");
    2032:	c7 44 24 04 58 4e 00 	movl   $0x4e58,0x4(%esp)
    2039:	00 
    203a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2041:	e8 26 20 00 00       	call   406c <printf>
    exit();
    2046:	e8 a1 1e 00 00       	call   3eec <exit>
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    204b:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2052:	00 
    2053:	c7 04 24 70 4e 00 00 	movl   $0x4e70,(%esp)
    205a:	e8 cd 1e 00 00       	call   3f2c <open>
    205f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2062:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2066:	79 19                	jns    2081 <subdir+0x85>
    printf(1, "create dd/ff failed\n");
    2068:	c7 44 24 04 76 4e 00 	movl   $0x4e76,0x4(%esp)
    206f:	00 
    2070:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2077:	e8 f0 1f 00 00       	call   406c <printf>
    exit();
    207c:	e8 6b 1e 00 00       	call   3eec <exit>
  }
  write(fd, "ff", 2);
    2081:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    2088:	00 
    2089:	c7 44 24 04 52 4e 00 	movl   $0x4e52,0x4(%esp)
    2090:	00 
    2091:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2094:	89 04 24             	mov    %eax,(%esp)
    2097:	e8 70 1e 00 00       	call   3f0c <write>
  close(fd);
    209c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    209f:	89 04 24             	mov    %eax,(%esp)
    20a2:	e8 6d 1e 00 00       	call   3f14 <close>
  
  if(unlink("dd") >= 0){
    20a7:	c7 04 24 55 4e 00 00 	movl   $0x4e55,(%esp)
    20ae:	e8 89 1e 00 00       	call   3f3c <unlink>
    20b3:	85 c0                	test   %eax,%eax
    20b5:	78 19                	js     20d0 <subdir+0xd4>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    20b7:	c7 44 24 04 8c 4e 00 	movl   $0x4e8c,0x4(%esp)
    20be:	00 
    20bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    20c6:	e8 a1 1f 00 00       	call   406c <printf>
    exit();
    20cb:	e8 1c 1e 00 00       	call   3eec <exit>
  }

  if(mkdir("/dd/dd") != 0){
    20d0:	c7 04 24 b2 4e 00 00 	movl   $0x4eb2,(%esp)
    20d7:	e8 78 1e 00 00       	call   3f54 <mkdir>
    20dc:	85 c0                	test   %eax,%eax
    20de:	74 19                	je     20f9 <subdir+0xfd>
    printf(1, "subdir mkdir dd/dd failed\n");
    20e0:	c7 44 24 04 b9 4e 00 	movl   $0x4eb9,0x4(%esp)
    20e7:	00 
    20e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    20ef:	e8 78 1f 00 00       	call   406c <printf>
    exit();
    20f4:	e8 f3 1d 00 00       	call   3eec <exit>
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    20f9:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2100:	00 
    2101:	c7 04 24 d4 4e 00 00 	movl   $0x4ed4,(%esp)
    2108:	e8 1f 1e 00 00       	call   3f2c <open>
    210d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2110:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2114:	79 19                	jns    212f <subdir+0x133>
    printf(1, "create dd/dd/ff failed\n");
    2116:	c7 44 24 04 dd 4e 00 	movl   $0x4edd,0x4(%esp)
    211d:	00 
    211e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2125:	e8 42 1f 00 00       	call   406c <printf>
    exit();
    212a:	e8 bd 1d 00 00       	call   3eec <exit>
  }
  write(fd, "FF", 2);
    212f:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    2136:	00 
    2137:	c7 44 24 04 f5 4e 00 	movl   $0x4ef5,0x4(%esp)
    213e:	00 
    213f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2142:	89 04 24             	mov    %eax,(%esp)
    2145:	e8 c2 1d 00 00       	call   3f0c <write>
  close(fd);
    214a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    214d:	89 04 24             	mov    %eax,(%esp)
    2150:	e8 bf 1d 00 00       	call   3f14 <close>

  fd = open("dd/dd/../ff", 0);
    2155:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    215c:	00 
    215d:	c7 04 24 f8 4e 00 00 	movl   $0x4ef8,(%esp)
    2164:	e8 c3 1d 00 00       	call   3f2c <open>
    2169:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    216c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2170:	79 19                	jns    218b <subdir+0x18f>
    printf(1, "open dd/dd/../ff failed\n");
    2172:	c7 44 24 04 04 4f 00 	movl   $0x4f04,0x4(%esp)
    2179:	00 
    217a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2181:	e8 e6 1e 00 00       	call   406c <printf>
    exit();
    2186:	e8 61 1d 00 00       	call   3eec <exit>
  }
  cc = read(fd, buf, sizeof(buf));
    218b:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    2192:	00 
    2193:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
    219a:	00 
    219b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    219e:	89 04 24             	mov    %eax,(%esp)
    21a1:	e8 5e 1d 00 00       	call   3f04 <read>
    21a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(cc != 2 || buf[0] != 'f'){
    21a9:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
    21ad:	75 0b                	jne    21ba <subdir+0x1be>
    21af:	0f b6 05 20 8b 00 00 	movzbl 0x8b20,%eax
    21b6:	3c 66                	cmp    $0x66,%al
    21b8:	74 19                	je     21d3 <subdir+0x1d7>
    printf(1, "dd/dd/../ff wrong content\n");
    21ba:	c7 44 24 04 1d 4f 00 	movl   $0x4f1d,0x4(%esp)
    21c1:	00 
    21c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21c9:	e8 9e 1e 00 00       	call   406c <printf>
    exit();
    21ce:	e8 19 1d 00 00       	call   3eec <exit>
  }
  close(fd);
    21d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    21d6:	89 04 24             	mov    %eax,(%esp)
    21d9:	e8 36 1d 00 00       	call   3f14 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    21de:	c7 44 24 04 38 4f 00 	movl   $0x4f38,0x4(%esp)
    21e5:	00 
    21e6:	c7 04 24 d4 4e 00 00 	movl   $0x4ed4,(%esp)
    21ed:	e8 5a 1d 00 00       	call   3f4c <link>
    21f2:	85 c0                	test   %eax,%eax
    21f4:	74 19                	je     220f <subdir+0x213>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    21f6:	c7 44 24 04 44 4f 00 	movl   $0x4f44,0x4(%esp)
    21fd:	00 
    21fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2205:	e8 62 1e 00 00       	call   406c <printf>
    exit();
    220a:	e8 dd 1c 00 00       	call   3eec <exit>
  }

  if(unlink("dd/dd/ff") != 0){
    220f:	c7 04 24 d4 4e 00 00 	movl   $0x4ed4,(%esp)
    2216:	e8 21 1d 00 00       	call   3f3c <unlink>
    221b:	85 c0                	test   %eax,%eax
    221d:	74 19                	je     2238 <subdir+0x23c>
    printf(1, "unlink dd/dd/ff failed\n");
    221f:	c7 44 24 04 65 4f 00 	movl   $0x4f65,0x4(%esp)
    2226:	00 
    2227:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    222e:	e8 39 1e 00 00       	call   406c <printf>
    exit();
    2233:	e8 b4 1c 00 00       	call   3eec <exit>
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2238:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    223f:	00 
    2240:	c7 04 24 d4 4e 00 00 	movl   $0x4ed4,(%esp)
    2247:	e8 e0 1c 00 00       	call   3f2c <open>
    224c:	85 c0                	test   %eax,%eax
    224e:	78 19                	js     2269 <subdir+0x26d>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    2250:	c7 44 24 04 80 4f 00 	movl   $0x4f80,0x4(%esp)
    2257:	00 
    2258:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    225f:	e8 08 1e 00 00       	call   406c <printf>
    exit();
    2264:	e8 83 1c 00 00       	call   3eec <exit>
  }

  if(chdir("dd") != 0){
    2269:	c7 04 24 55 4e 00 00 	movl   $0x4e55,(%esp)
    2270:	e8 e7 1c 00 00       	call   3f5c <chdir>
    2275:	85 c0                	test   %eax,%eax
    2277:	74 19                	je     2292 <subdir+0x296>
    printf(1, "chdir dd failed\n");
    2279:	c7 44 24 04 a4 4f 00 	movl   $0x4fa4,0x4(%esp)
    2280:	00 
    2281:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2288:	e8 df 1d 00 00       	call   406c <printf>
    exit();
    228d:	e8 5a 1c 00 00       	call   3eec <exit>
  }
  if(chdir("dd/../../dd") != 0){
    2292:	c7 04 24 b5 4f 00 00 	movl   $0x4fb5,(%esp)
    2299:	e8 be 1c 00 00       	call   3f5c <chdir>
    229e:	85 c0                	test   %eax,%eax
    22a0:	74 19                	je     22bb <subdir+0x2bf>
    printf(1, "chdir dd/../../dd failed\n");
    22a2:	c7 44 24 04 c1 4f 00 	movl   $0x4fc1,0x4(%esp)
    22a9:	00 
    22aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22b1:	e8 b6 1d 00 00       	call   406c <printf>
    exit();
    22b6:	e8 31 1c 00 00       	call   3eec <exit>
  }
  if(chdir("dd/../../../dd") != 0){
    22bb:	c7 04 24 db 4f 00 00 	movl   $0x4fdb,(%esp)
    22c2:	e8 95 1c 00 00       	call   3f5c <chdir>
    22c7:	85 c0                	test   %eax,%eax
    22c9:	74 19                	je     22e4 <subdir+0x2e8>
    printf(1, "chdir dd/../../dd failed\n");
    22cb:	c7 44 24 04 c1 4f 00 	movl   $0x4fc1,0x4(%esp)
    22d2:	00 
    22d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22da:	e8 8d 1d 00 00       	call   406c <printf>
    exit();
    22df:	e8 08 1c 00 00       	call   3eec <exit>
  }
  if(chdir("./..") != 0){
    22e4:	c7 04 24 ea 4f 00 00 	movl   $0x4fea,(%esp)
    22eb:	e8 6c 1c 00 00       	call   3f5c <chdir>
    22f0:	85 c0                	test   %eax,%eax
    22f2:	74 19                	je     230d <subdir+0x311>
    printf(1, "chdir ./.. failed\n");
    22f4:	c7 44 24 04 ef 4f 00 	movl   $0x4fef,0x4(%esp)
    22fb:	00 
    22fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2303:	e8 64 1d 00 00       	call   406c <printf>
    exit();
    2308:	e8 df 1b 00 00       	call   3eec <exit>
  }

  fd = open("dd/dd/ffff", 0);
    230d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2314:	00 
    2315:	c7 04 24 38 4f 00 00 	movl   $0x4f38,(%esp)
    231c:	e8 0b 1c 00 00       	call   3f2c <open>
    2321:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2324:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2328:	79 19                	jns    2343 <subdir+0x347>
    printf(1, "open dd/dd/ffff failed\n");
    232a:	c7 44 24 04 02 50 00 	movl   $0x5002,0x4(%esp)
    2331:	00 
    2332:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2339:	e8 2e 1d 00 00       	call   406c <printf>
    exit();
    233e:	e8 a9 1b 00 00       	call   3eec <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    2343:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    234a:	00 
    234b:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
    2352:	00 
    2353:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2356:	89 04 24             	mov    %eax,(%esp)
    2359:	e8 a6 1b 00 00       	call   3f04 <read>
    235e:	83 f8 02             	cmp    $0x2,%eax
    2361:	74 19                	je     237c <subdir+0x380>
    printf(1, "read dd/dd/ffff wrong len\n");
    2363:	c7 44 24 04 1a 50 00 	movl   $0x501a,0x4(%esp)
    236a:	00 
    236b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2372:	e8 f5 1c 00 00       	call   406c <printf>
    exit();
    2377:	e8 70 1b 00 00       	call   3eec <exit>
  }
  close(fd);
    237c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    237f:	89 04 24             	mov    %eax,(%esp)
    2382:	e8 8d 1b 00 00       	call   3f14 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2387:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    238e:	00 
    238f:	c7 04 24 d4 4e 00 00 	movl   $0x4ed4,(%esp)
    2396:	e8 91 1b 00 00       	call   3f2c <open>
    239b:	85 c0                	test   %eax,%eax
    239d:	78 19                	js     23b8 <subdir+0x3bc>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    239f:	c7 44 24 04 38 50 00 	movl   $0x5038,0x4(%esp)
    23a6:	00 
    23a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23ae:	e8 b9 1c 00 00       	call   406c <printf>
    exit();
    23b3:	e8 34 1b 00 00       	call   3eec <exit>
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    23b8:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    23bf:	00 
    23c0:	c7 04 24 5d 50 00 00 	movl   $0x505d,(%esp)
    23c7:	e8 60 1b 00 00       	call   3f2c <open>
    23cc:	85 c0                	test   %eax,%eax
    23ce:	78 19                	js     23e9 <subdir+0x3ed>
    printf(1, "create dd/ff/ff succeeded!\n");
    23d0:	c7 44 24 04 66 50 00 	movl   $0x5066,0x4(%esp)
    23d7:	00 
    23d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23df:	e8 88 1c 00 00       	call   406c <printf>
    exit();
    23e4:	e8 03 1b 00 00       	call   3eec <exit>
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    23e9:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    23f0:	00 
    23f1:	c7 04 24 82 50 00 00 	movl   $0x5082,(%esp)
    23f8:	e8 2f 1b 00 00       	call   3f2c <open>
    23fd:	85 c0                	test   %eax,%eax
    23ff:	78 19                	js     241a <subdir+0x41e>
    printf(1, "create dd/xx/ff succeeded!\n");
    2401:	c7 44 24 04 8b 50 00 	movl   $0x508b,0x4(%esp)
    2408:	00 
    2409:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2410:	e8 57 1c 00 00       	call   406c <printf>
    exit();
    2415:	e8 d2 1a 00 00       	call   3eec <exit>
  }
  if(open("dd", O_CREATE) >= 0){
    241a:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2421:	00 
    2422:	c7 04 24 55 4e 00 00 	movl   $0x4e55,(%esp)
    2429:	e8 fe 1a 00 00       	call   3f2c <open>
    242e:	85 c0                	test   %eax,%eax
    2430:	78 19                	js     244b <subdir+0x44f>
    printf(1, "create dd succeeded!\n");
    2432:	c7 44 24 04 a7 50 00 	movl   $0x50a7,0x4(%esp)
    2439:	00 
    243a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2441:	e8 26 1c 00 00       	call   406c <printf>
    exit();
    2446:	e8 a1 1a 00 00       	call   3eec <exit>
  }
  if(open("dd", O_RDWR) >= 0){
    244b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    2452:	00 
    2453:	c7 04 24 55 4e 00 00 	movl   $0x4e55,(%esp)
    245a:	e8 cd 1a 00 00       	call   3f2c <open>
    245f:	85 c0                	test   %eax,%eax
    2461:	78 19                	js     247c <subdir+0x480>
    printf(1, "open dd rdwr succeeded!\n");
    2463:	c7 44 24 04 bd 50 00 	movl   $0x50bd,0x4(%esp)
    246a:	00 
    246b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2472:	e8 f5 1b 00 00       	call   406c <printf>
    exit();
    2477:	e8 70 1a 00 00       	call   3eec <exit>
  }
  if(open("dd", O_WRONLY) >= 0){
    247c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
    2483:	00 
    2484:	c7 04 24 55 4e 00 00 	movl   $0x4e55,(%esp)
    248b:	e8 9c 1a 00 00       	call   3f2c <open>
    2490:	85 c0                	test   %eax,%eax
    2492:	78 19                	js     24ad <subdir+0x4b1>
    printf(1, "open dd wronly succeeded!\n");
    2494:	c7 44 24 04 d6 50 00 	movl   $0x50d6,0x4(%esp)
    249b:	00 
    249c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24a3:	e8 c4 1b 00 00       	call   406c <printf>
    exit();
    24a8:	e8 3f 1a 00 00       	call   3eec <exit>
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    24ad:	c7 44 24 04 f1 50 00 	movl   $0x50f1,0x4(%esp)
    24b4:	00 
    24b5:	c7 04 24 5d 50 00 00 	movl   $0x505d,(%esp)
    24bc:	e8 8b 1a 00 00       	call   3f4c <link>
    24c1:	85 c0                	test   %eax,%eax
    24c3:	75 19                	jne    24de <subdir+0x4e2>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    24c5:	c7 44 24 04 fc 50 00 	movl   $0x50fc,0x4(%esp)
    24cc:	00 
    24cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24d4:	e8 93 1b 00 00       	call   406c <printf>
    exit();
    24d9:	e8 0e 1a 00 00       	call   3eec <exit>
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    24de:	c7 44 24 04 f1 50 00 	movl   $0x50f1,0x4(%esp)
    24e5:	00 
    24e6:	c7 04 24 82 50 00 00 	movl   $0x5082,(%esp)
    24ed:	e8 5a 1a 00 00       	call   3f4c <link>
    24f2:	85 c0                	test   %eax,%eax
    24f4:	75 19                	jne    250f <subdir+0x513>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    24f6:	c7 44 24 04 20 51 00 	movl   $0x5120,0x4(%esp)
    24fd:	00 
    24fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2505:	e8 62 1b 00 00       	call   406c <printf>
    exit();
    250a:	e8 dd 19 00 00       	call   3eec <exit>
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    250f:	c7 44 24 04 38 4f 00 	movl   $0x4f38,0x4(%esp)
    2516:	00 
    2517:	c7 04 24 70 4e 00 00 	movl   $0x4e70,(%esp)
    251e:	e8 29 1a 00 00       	call   3f4c <link>
    2523:	85 c0                	test   %eax,%eax
    2525:	75 19                	jne    2540 <subdir+0x544>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    2527:	c7 44 24 04 44 51 00 	movl   $0x5144,0x4(%esp)
    252e:	00 
    252f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2536:	e8 31 1b 00 00       	call   406c <printf>
    exit();
    253b:	e8 ac 19 00 00       	call   3eec <exit>
  }
  if(mkdir("dd/ff/ff") == 0){
    2540:	c7 04 24 5d 50 00 00 	movl   $0x505d,(%esp)
    2547:	e8 08 1a 00 00       	call   3f54 <mkdir>
    254c:	85 c0                	test   %eax,%eax
    254e:	75 19                	jne    2569 <subdir+0x56d>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    2550:	c7 44 24 04 66 51 00 	movl   $0x5166,0x4(%esp)
    2557:	00 
    2558:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    255f:	e8 08 1b 00 00       	call   406c <printf>
    exit();
    2564:	e8 83 19 00 00       	call   3eec <exit>
  }
  if(mkdir("dd/xx/ff") == 0){
    2569:	c7 04 24 82 50 00 00 	movl   $0x5082,(%esp)
    2570:	e8 df 19 00 00       	call   3f54 <mkdir>
    2575:	85 c0                	test   %eax,%eax
    2577:	75 19                	jne    2592 <subdir+0x596>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    2579:	c7 44 24 04 81 51 00 	movl   $0x5181,0x4(%esp)
    2580:	00 
    2581:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2588:	e8 df 1a 00 00       	call   406c <printf>
    exit();
    258d:	e8 5a 19 00 00       	call   3eec <exit>
  }
  if(mkdir("dd/dd/ffff") == 0){
    2592:	c7 04 24 38 4f 00 00 	movl   $0x4f38,(%esp)
    2599:	e8 b6 19 00 00       	call   3f54 <mkdir>
    259e:	85 c0                	test   %eax,%eax
    25a0:	75 19                	jne    25bb <subdir+0x5bf>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    25a2:	c7 44 24 04 9c 51 00 	movl   $0x519c,0x4(%esp)
    25a9:	00 
    25aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25b1:	e8 b6 1a 00 00       	call   406c <printf>
    exit();
    25b6:	e8 31 19 00 00       	call   3eec <exit>
  }
  if(unlink("dd/xx/ff") == 0){
    25bb:	c7 04 24 82 50 00 00 	movl   $0x5082,(%esp)
    25c2:	e8 75 19 00 00       	call   3f3c <unlink>
    25c7:	85 c0                	test   %eax,%eax
    25c9:	75 19                	jne    25e4 <subdir+0x5e8>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    25cb:	c7 44 24 04 b9 51 00 	movl   $0x51b9,0x4(%esp)
    25d2:	00 
    25d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25da:	e8 8d 1a 00 00       	call   406c <printf>
    exit();
    25df:	e8 08 19 00 00       	call   3eec <exit>
  }
  if(unlink("dd/ff/ff") == 0){
    25e4:	c7 04 24 5d 50 00 00 	movl   $0x505d,(%esp)
    25eb:	e8 4c 19 00 00       	call   3f3c <unlink>
    25f0:	85 c0                	test   %eax,%eax
    25f2:	75 19                	jne    260d <subdir+0x611>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    25f4:	c7 44 24 04 d5 51 00 	movl   $0x51d5,0x4(%esp)
    25fb:	00 
    25fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2603:	e8 64 1a 00 00       	call   406c <printf>
    exit();
    2608:	e8 df 18 00 00       	call   3eec <exit>
  }
  if(chdir("dd/ff") == 0){
    260d:	c7 04 24 70 4e 00 00 	movl   $0x4e70,(%esp)
    2614:	e8 43 19 00 00       	call   3f5c <chdir>
    2619:	85 c0                	test   %eax,%eax
    261b:	75 19                	jne    2636 <subdir+0x63a>
    printf(1, "chdir dd/ff succeeded!\n");
    261d:	c7 44 24 04 f1 51 00 	movl   $0x51f1,0x4(%esp)
    2624:	00 
    2625:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    262c:	e8 3b 1a 00 00       	call   406c <printf>
    exit();
    2631:	e8 b6 18 00 00       	call   3eec <exit>
  }
  if(chdir("dd/xx") == 0){
    2636:	c7 04 24 09 52 00 00 	movl   $0x5209,(%esp)
    263d:	e8 1a 19 00 00       	call   3f5c <chdir>
    2642:	85 c0                	test   %eax,%eax
    2644:	75 19                	jne    265f <subdir+0x663>
    printf(1, "chdir dd/xx succeeded!\n");
    2646:	c7 44 24 04 0f 52 00 	movl   $0x520f,0x4(%esp)
    264d:	00 
    264e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2655:	e8 12 1a 00 00       	call   406c <printf>
    exit();
    265a:	e8 8d 18 00 00       	call   3eec <exit>
  }

  if(unlink("dd/dd/ffff") != 0){
    265f:	c7 04 24 38 4f 00 00 	movl   $0x4f38,(%esp)
    2666:	e8 d1 18 00 00       	call   3f3c <unlink>
    266b:	85 c0                	test   %eax,%eax
    266d:	74 19                	je     2688 <subdir+0x68c>
    printf(1, "unlink dd/dd/ff failed\n");
    266f:	c7 44 24 04 65 4f 00 	movl   $0x4f65,0x4(%esp)
    2676:	00 
    2677:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    267e:	e8 e9 19 00 00       	call   406c <printf>
    exit();
    2683:	e8 64 18 00 00       	call   3eec <exit>
  }
  if(unlink("dd/ff") != 0){
    2688:	c7 04 24 70 4e 00 00 	movl   $0x4e70,(%esp)
    268f:	e8 a8 18 00 00       	call   3f3c <unlink>
    2694:	85 c0                	test   %eax,%eax
    2696:	74 19                	je     26b1 <subdir+0x6b5>
    printf(1, "unlink dd/ff failed\n");
    2698:	c7 44 24 04 27 52 00 	movl   $0x5227,0x4(%esp)
    269f:	00 
    26a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26a7:	e8 c0 19 00 00       	call   406c <printf>
    exit();
    26ac:	e8 3b 18 00 00       	call   3eec <exit>
  }
  if(unlink("dd") == 0){
    26b1:	c7 04 24 55 4e 00 00 	movl   $0x4e55,(%esp)
    26b8:	e8 7f 18 00 00       	call   3f3c <unlink>
    26bd:	85 c0                	test   %eax,%eax
    26bf:	75 19                	jne    26da <subdir+0x6de>
    printf(1, "unlink non-empty dd succeeded!\n");
    26c1:	c7 44 24 04 3c 52 00 	movl   $0x523c,0x4(%esp)
    26c8:	00 
    26c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26d0:	e8 97 19 00 00       	call   406c <printf>
    exit();
    26d5:	e8 12 18 00 00       	call   3eec <exit>
  }
  if(unlink("dd/dd") < 0){
    26da:	c7 04 24 5c 52 00 00 	movl   $0x525c,(%esp)
    26e1:	e8 56 18 00 00       	call   3f3c <unlink>
    26e6:	85 c0                	test   %eax,%eax
    26e8:	79 19                	jns    2703 <subdir+0x707>
    printf(1, "unlink dd/dd failed\n");
    26ea:	c7 44 24 04 62 52 00 	movl   $0x5262,0x4(%esp)
    26f1:	00 
    26f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26f9:	e8 6e 19 00 00       	call   406c <printf>
    exit();
    26fe:	e8 e9 17 00 00       	call   3eec <exit>
  }
  if(unlink("dd") < 0){
    2703:	c7 04 24 55 4e 00 00 	movl   $0x4e55,(%esp)
    270a:	e8 2d 18 00 00       	call   3f3c <unlink>
    270f:	85 c0                	test   %eax,%eax
    2711:	79 19                	jns    272c <subdir+0x730>
    printf(1, "unlink dd failed\n");
    2713:	c7 44 24 04 77 52 00 	movl   $0x5277,0x4(%esp)
    271a:	00 
    271b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2722:	e8 45 19 00 00       	call   406c <printf>
    exit();
    2727:	e8 c0 17 00 00       	call   3eec <exit>
  }

  printf(1, "subdir ok\n");
    272c:	c7 44 24 04 89 52 00 	movl   $0x5289,0x4(%esp)
    2733:	00 
    2734:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    273b:	e8 2c 19 00 00       	call   406c <printf>
}
    2740:	c9                   	leave  
    2741:	c3                   	ret    

00002742 <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    2742:	55                   	push   %ebp
    2743:	89 e5                	mov    %esp,%ebp
    2745:	83 ec 28             	sub    $0x28,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    2748:	c7 44 24 04 94 52 00 	movl   $0x5294,0x4(%esp)
    274f:	00 
    2750:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2757:	e8 10 19 00 00       	call   406c <printf>

  unlink("bigwrite");
    275c:	c7 04 24 a3 52 00 00 	movl   $0x52a3,(%esp)
    2763:	e8 d4 17 00 00       	call   3f3c <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    2768:	c7 45 f4 f3 01 00 00 	movl   $0x1f3,-0xc(%ebp)
    276f:	e9 b3 00 00 00       	jmp    2827 <bigwrite+0xe5>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    2774:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    277b:	00 
    277c:	c7 04 24 a3 52 00 00 	movl   $0x52a3,(%esp)
    2783:	e8 a4 17 00 00       	call   3f2c <open>
    2788:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fd < 0){
    278b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    278f:	79 19                	jns    27aa <bigwrite+0x68>
      printf(1, "cannot create bigwrite\n");
    2791:	c7 44 24 04 ac 52 00 	movl   $0x52ac,0x4(%esp)
    2798:	00 
    2799:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27a0:	e8 c7 18 00 00       	call   406c <printf>
      exit();
    27a5:	e8 42 17 00 00       	call   3eec <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
    27aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    27b1:	eb 50                	jmp    2803 <bigwrite+0xc1>
      int cc = write(fd, buf, sz);
    27b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    27b6:	89 44 24 08          	mov    %eax,0x8(%esp)
    27ba:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
    27c1:	00 
    27c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    27c5:	89 04 24             	mov    %eax,(%esp)
    27c8:	e8 3f 17 00 00       	call   3f0c <write>
    27cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(cc != sz){
    27d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
    27d3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    27d6:	74 27                	je     27ff <bigwrite+0xbd>
        printf(1, "write(%d) ret %d\n", sz, cc);
    27d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
    27db:	89 44 24 0c          	mov    %eax,0xc(%esp)
    27df:	8b 45 f4             	mov    -0xc(%ebp),%eax
    27e2:	89 44 24 08          	mov    %eax,0x8(%esp)
    27e6:	c7 44 24 04 c4 52 00 	movl   $0x52c4,0x4(%esp)
    27ed:	00 
    27ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27f5:	e8 72 18 00 00       	call   406c <printf>
        exit();
    27fa:	e8 ed 16 00 00       	call   3eec <exit>
    if(fd < 0){
      printf(1, "cannot create bigwrite\n");
      exit();
    }
    int i;
    for(i = 0; i < 2; i++){
    27ff:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    2803:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
    2807:	7e aa                	jle    27b3 <bigwrite+0x71>
      if(cc != sz){
        printf(1, "write(%d) ret %d\n", sz, cc);
        exit();
      }
    }
    close(fd);
    2809:	8b 45 ec             	mov    -0x14(%ebp),%eax
    280c:	89 04 24             	mov    %eax,(%esp)
    280f:	e8 00 17 00 00       	call   3f14 <close>
    unlink("bigwrite");
    2814:	c7 04 24 a3 52 00 00 	movl   $0x52a3,(%esp)
    281b:	e8 1c 17 00 00       	call   3f3c <unlink>
  int fd, sz;

  printf(1, "bigwrite test\n");

  unlink("bigwrite");
  for(sz = 499; sz < 12*512; sz += 471){
    2820:	81 45 f4 d7 01 00 00 	addl   $0x1d7,-0xc(%ebp)
    2827:	81 7d f4 ff 17 00 00 	cmpl   $0x17ff,-0xc(%ebp)
    282e:	0f 8e 40 ff ff ff    	jle    2774 <bigwrite+0x32>
    }
    close(fd);
    unlink("bigwrite");
  }

  printf(1, "bigwrite ok\n");
    2834:	c7 44 24 04 d6 52 00 	movl   $0x52d6,0x4(%esp)
    283b:	00 
    283c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2843:	e8 24 18 00 00       	call   406c <printf>
}
    2848:	c9                   	leave  
    2849:	c3                   	ret    

0000284a <bigfile>:

void
bigfile(void)
{
    284a:	55                   	push   %ebp
    284b:	89 e5                	mov    %esp,%ebp
    284d:	83 ec 28             	sub    $0x28,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    2850:	c7 44 24 04 e3 52 00 	movl   $0x52e3,0x4(%esp)
    2857:	00 
    2858:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    285f:	e8 08 18 00 00       	call   406c <printf>

  unlink("bigfile");
    2864:	c7 04 24 f1 52 00 00 	movl   $0x52f1,(%esp)
    286b:	e8 cc 16 00 00       	call   3f3c <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    2870:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2877:	00 
    2878:	c7 04 24 f1 52 00 00 	movl   $0x52f1,(%esp)
    287f:	e8 a8 16 00 00       	call   3f2c <open>
    2884:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    2887:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    288b:	79 19                	jns    28a6 <bigfile+0x5c>
    printf(1, "cannot create bigfile");
    288d:	c7 44 24 04 f9 52 00 	movl   $0x52f9,0x4(%esp)
    2894:	00 
    2895:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    289c:	e8 cb 17 00 00       	call   406c <printf>
    exit();
    28a1:	e8 46 16 00 00       	call   3eec <exit>
  }
  for(i = 0; i < 20; i++){
    28a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    28ad:	eb 5a                	jmp    2909 <bigfile+0xbf>
    memset(buf, i, 600);
    28af:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    28b6:	00 
    28b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    28ba:	89 44 24 04          	mov    %eax,0x4(%esp)
    28be:	c7 04 24 20 8b 00 00 	movl   $0x8b20,(%esp)
    28c5:	e8 75 14 00 00       	call   3d3f <memset>
    if(write(fd, buf, 600) != 600){
    28ca:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    28d1:	00 
    28d2:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
    28d9:	00 
    28da:	8b 45 ec             	mov    -0x14(%ebp),%eax
    28dd:	89 04 24             	mov    %eax,(%esp)
    28e0:	e8 27 16 00 00       	call   3f0c <write>
    28e5:	3d 58 02 00 00       	cmp    $0x258,%eax
    28ea:	74 19                	je     2905 <bigfile+0xbb>
      printf(1, "write bigfile failed\n");
    28ec:	c7 44 24 04 0f 53 00 	movl   $0x530f,0x4(%esp)
    28f3:	00 
    28f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28fb:	e8 6c 17 00 00       	call   406c <printf>
      exit();
    2900:	e8 e7 15 00 00       	call   3eec <exit>
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    exit();
  }
  for(i = 0; i < 20; i++){
    2905:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2909:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    290d:	7e a0                	jle    28af <bigfile+0x65>
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
      exit();
    }
  }
  close(fd);
    290f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2912:	89 04 24             	mov    %eax,(%esp)
    2915:	e8 fa 15 00 00       	call   3f14 <close>

  fd = open("bigfile", 0);
    291a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2921:	00 
    2922:	c7 04 24 f1 52 00 00 	movl   $0x52f1,(%esp)
    2929:	e8 fe 15 00 00       	call   3f2c <open>
    292e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    2931:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2935:	79 19                	jns    2950 <bigfile+0x106>
    printf(1, "cannot open bigfile\n");
    2937:	c7 44 24 04 25 53 00 	movl   $0x5325,0x4(%esp)
    293e:	00 
    293f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2946:	e8 21 17 00 00       	call   406c <printf>
    exit();
    294b:	e8 9c 15 00 00       	call   3eec <exit>
  }
  total = 0;
    2950:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(i = 0; ; i++){
    2957:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    cc = read(fd, buf, 300);
    295e:	c7 44 24 08 2c 01 00 	movl   $0x12c,0x8(%esp)
    2965:	00 
    2966:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
    296d:	00 
    296e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2971:	89 04 24             	mov    %eax,(%esp)
    2974:	e8 8b 15 00 00       	call   3f04 <read>
    2979:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(cc < 0){
    297c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2980:	79 19                	jns    299b <bigfile+0x151>
      printf(1, "read bigfile failed\n");
    2982:	c7 44 24 04 3a 53 00 	movl   $0x533a,0x4(%esp)
    2989:	00 
    298a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2991:	e8 d6 16 00 00       	call   406c <printf>
      exit();
    2996:	e8 51 15 00 00       	call   3eec <exit>
    }
    if(cc == 0)
    299b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    299f:	75 1b                	jne    29bc <bigfile+0x172>
      break;
    29a1:	90                   	nop
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
  close(fd);
    29a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    29a5:	89 04 24             	mov    %eax,(%esp)
    29a8:	e8 67 15 00 00       	call   3f14 <close>
  if(total != 20*600){
    29ad:	81 7d f0 e0 2e 00 00 	cmpl   $0x2ee0,-0x10(%ebp)
    29b4:	0f 84 99 00 00 00    	je     2a53 <bigfile+0x209>
    29ba:	eb 7e                	jmp    2a3a <bigfile+0x1f0>
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
      break;
    if(cc != 300){
    29bc:	81 7d e8 2c 01 00 00 	cmpl   $0x12c,-0x18(%ebp)
    29c3:	74 19                	je     29de <bigfile+0x194>
      printf(1, "short read bigfile\n");
    29c5:	c7 44 24 04 4f 53 00 	movl   $0x534f,0x4(%esp)
    29cc:	00 
    29cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29d4:	e8 93 16 00 00       	call   406c <printf>
      exit();
    29d9:	e8 0e 15 00 00       	call   3eec <exit>
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    29de:	0f b6 05 20 8b 00 00 	movzbl 0x8b20,%eax
    29e5:	0f be d0             	movsbl %al,%edx
    29e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    29eb:	89 c1                	mov    %eax,%ecx
    29ed:	c1 e9 1f             	shr    $0x1f,%ecx
    29f0:	01 c8                	add    %ecx,%eax
    29f2:	d1 f8                	sar    %eax
    29f4:	39 c2                	cmp    %eax,%edx
    29f6:	75 1a                	jne    2a12 <bigfile+0x1c8>
    29f8:	0f b6 05 4b 8c 00 00 	movzbl 0x8c4b,%eax
    29ff:	0f be d0             	movsbl %al,%edx
    2a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2a05:	89 c1                	mov    %eax,%ecx
    2a07:	c1 e9 1f             	shr    $0x1f,%ecx
    2a0a:	01 c8                	add    %ecx,%eax
    2a0c:	d1 f8                	sar    %eax
    2a0e:	39 c2                	cmp    %eax,%edx
    2a10:	74 19                	je     2a2b <bigfile+0x1e1>
      printf(1, "read bigfile wrong data\n");
    2a12:	c7 44 24 04 63 53 00 	movl   $0x5363,0x4(%esp)
    2a19:	00 
    2a1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a21:	e8 46 16 00 00       	call   406c <printf>
      exit();
    2a26:	e8 c1 14 00 00       	call   3eec <exit>
    }
    total += cc;
    2a2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2a2e:	01 45 f0             	add    %eax,-0x10(%ebp)
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    exit();
  }
  total = 0;
  for(i = 0; ; i++){
    2a31:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(buf[0] != i/2 || buf[299] != i/2){
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
    2a35:	e9 24 ff ff ff       	jmp    295e <bigfile+0x114>
  close(fd);
  if(total != 20*600){
    printf(1, "read bigfile wrong total\n");
    2a3a:	c7 44 24 04 7c 53 00 	movl   $0x537c,0x4(%esp)
    2a41:	00 
    2a42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a49:	e8 1e 16 00 00       	call   406c <printf>
    exit();
    2a4e:	e8 99 14 00 00       	call   3eec <exit>
  }
  unlink("bigfile");
    2a53:	c7 04 24 f1 52 00 00 	movl   $0x52f1,(%esp)
    2a5a:	e8 dd 14 00 00       	call   3f3c <unlink>

  printf(1, "bigfile test ok\n");
    2a5f:	c7 44 24 04 96 53 00 	movl   $0x5396,0x4(%esp)
    2a66:	00 
    2a67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a6e:	e8 f9 15 00 00       	call   406c <printf>
}
    2a73:	c9                   	leave  
    2a74:	c3                   	ret    

00002a75 <fourteen>:

void
fourteen(void)
{
    2a75:	55                   	push   %ebp
    2a76:	89 e5                	mov    %esp,%ebp
    2a78:	83 ec 28             	sub    $0x28,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    2a7b:	c7 44 24 04 a7 53 00 	movl   $0x53a7,0x4(%esp)
    2a82:	00 
    2a83:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a8a:	e8 dd 15 00 00       	call   406c <printf>

  if(mkdir("12345678901234") != 0){
    2a8f:	c7 04 24 b6 53 00 00 	movl   $0x53b6,(%esp)
    2a96:	e8 b9 14 00 00       	call   3f54 <mkdir>
    2a9b:	85 c0                	test   %eax,%eax
    2a9d:	74 19                	je     2ab8 <fourteen+0x43>
    printf(1, "mkdir 12345678901234 failed\n");
    2a9f:	c7 44 24 04 c5 53 00 	movl   $0x53c5,0x4(%esp)
    2aa6:	00 
    2aa7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2aae:	e8 b9 15 00 00       	call   406c <printf>
    exit();
    2ab3:	e8 34 14 00 00       	call   3eec <exit>
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    2ab8:	c7 04 24 e4 53 00 00 	movl   $0x53e4,(%esp)
    2abf:	e8 90 14 00 00       	call   3f54 <mkdir>
    2ac4:	85 c0                	test   %eax,%eax
    2ac6:	74 19                	je     2ae1 <fourteen+0x6c>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    2ac8:	c7 44 24 04 04 54 00 	movl   $0x5404,0x4(%esp)
    2acf:	00 
    2ad0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ad7:	e8 90 15 00 00       	call   406c <printf>
    exit();
    2adc:	e8 0b 14 00 00       	call   3eec <exit>
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2ae1:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2ae8:	00 
    2ae9:	c7 04 24 34 54 00 00 	movl   $0x5434,(%esp)
    2af0:	e8 37 14 00 00       	call   3f2c <open>
    2af5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2af8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2afc:	79 19                	jns    2b17 <fourteen+0xa2>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    2afe:	c7 44 24 04 64 54 00 	movl   $0x5464,0x4(%esp)
    2b05:	00 
    2b06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b0d:	e8 5a 15 00 00       	call   406c <printf>
    exit();
    2b12:	e8 d5 13 00 00       	call   3eec <exit>
  }
  close(fd);
    2b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2b1a:	89 04 24             	mov    %eax,(%esp)
    2b1d:	e8 f2 13 00 00       	call   3f14 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2b22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2b29:	00 
    2b2a:	c7 04 24 a4 54 00 00 	movl   $0x54a4,(%esp)
    2b31:	e8 f6 13 00 00       	call   3f2c <open>
    2b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2b39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2b3d:	79 19                	jns    2b58 <fourteen+0xe3>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    2b3f:	c7 44 24 04 d4 54 00 	movl   $0x54d4,0x4(%esp)
    2b46:	00 
    2b47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b4e:	e8 19 15 00 00       	call   406c <printf>
    exit();
    2b53:	e8 94 13 00 00       	call   3eec <exit>
  }
  close(fd);
    2b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2b5b:	89 04 24             	mov    %eax,(%esp)
    2b5e:	e8 b1 13 00 00       	call   3f14 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    2b63:	c7 04 24 0e 55 00 00 	movl   $0x550e,(%esp)
    2b6a:	e8 e5 13 00 00       	call   3f54 <mkdir>
    2b6f:	85 c0                	test   %eax,%eax
    2b71:	75 19                	jne    2b8c <fourteen+0x117>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    2b73:	c7 44 24 04 2c 55 00 	movl   $0x552c,0x4(%esp)
    2b7a:	00 
    2b7b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b82:	e8 e5 14 00 00       	call   406c <printf>
    exit();
    2b87:	e8 60 13 00 00       	call   3eec <exit>
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    2b8c:	c7 04 24 5c 55 00 00 	movl   $0x555c,(%esp)
    2b93:	e8 bc 13 00 00       	call   3f54 <mkdir>
    2b98:	85 c0                	test   %eax,%eax
    2b9a:	75 19                	jne    2bb5 <fourteen+0x140>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    2b9c:	c7 44 24 04 7c 55 00 	movl   $0x557c,0x4(%esp)
    2ba3:	00 
    2ba4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bab:	e8 bc 14 00 00       	call   406c <printf>
    exit();
    2bb0:	e8 37 13 00 00       	call   3eec <exit>
  }

  printf(1, "fourteen ok\n");
    2bb5:	c7 44 24 04 ad 55 00 	movl   $0x55ad,0x4(%esp)
    2bbc:	00 
    2bbd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bc4:	e8 a3 14 00 00       	call   406c <printf>
}
    2bc9:	c9                   	leave  
    2bca:	c3                   	ret    

00002bcb <rmdot>:

void
rmdot(void)
{
    2bcb:	55                   	push   %ebp
    2bcc:	89 e5                	mov    %esp,%ebp
    2bce:	83 ec 18             	sub    $0x18,%esp
  printf(1, "rmdot test\n");
    2bd1:	c7 44 24 04 ba 55 00 	movl   $0x55ba,0x4(%esp)
    2bd8:	00 
    2bd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2be0:	e8 87 14 00 00       	call   406c <printf>
  if(mkdir("dots") != 0){
    2be5:	c7 04 24 c6 55 00 00 	movl   $0x55c6,(%esp)
    2bec:	e8 63 13 00 00       	call   3f54 <mkdir>
    2bf1:	85 c0                	test   %eax,%eax
    2bf3:	74 19                	je     2c0e <rmdot+0x43>
    printf(1, "mkdir dots failed\n");
    2bf5:	c7 44 24 04 cb 55 00 	movl   $0x55cb,0x4(%esp)
    2bfc:	00 
    2bfd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c04:	e8 63 14 00 00       	call   406c <printf>
    exit();
    2c09:	e8 de 12 00 00       	call   3eec <exit>
  }
  if(chdir("dots") != 0){
    2c0e:	c7 04 24 c6 55 00 00 	movl   $0x55c6,(%esp)
    2c15:	e8 42 13 00 00       	call   3f5c <chdir>
    2c1a:	85 c0                	test   %eax,%eax
    2c1c:	74 19                	je     2c37 <rmdot+0x6c>
    printf(1, "chdir dots failed\n");
    2c1e:	c7 44 24 04 de 55 00 	movl   $0x55de,0x4(%esp)
    2c25:	00 
    2c26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c2d:	e8 3a 14 00 00       	call   406c <printf>
    exit();
    2c32:	e8 b5 12 00 00       	call   3eec <exit>
  }
  if(unlink(".") == 0){
    2c37:	c7 04 24 f7 4c 00 00 	movl   $0x4cf7,(%esp)
    2c3e:	e8 f9 12 00 00       	call   3f3c <unlink>
    2c43:	85 c0                	test   %eax,%eax
    2c45:	75 19                	jne    2c60 <rmdot+0x95>
    printf(1, "rm . worked!\n");
    2c47:	c7 44 24 04 f1 55 00 	movl   $0x55f1,0x4(%esp)
    2c4e:	00 
    2c4f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c56:	e8 11 14 00 00       	call   406c <printf>
    exit();
    2c5b:	e8 8c 12 00 00       	call   3eec <exit>
  }
  if(unlink("..") == 0){
    2c60:	c7 04 24 56 48 00 00 	movl   $0x4856,(%esp)
    2c67:	e8 d0 12 00 00       	call   3f3c <unlink>
    2c6c:	85 c0                	test   %eax,%eax
    2c6e:	75 19                	jne    2c89 <rmdot+0xbe>
    printf(1, "rm .. worked!\n");
    2c70:	c7 44 24 04 ff 55 00 	movl   $0x55ff,0x4(%esp)
    2c77:	00 
    2c78:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c7f:	e8 e8 13 00 00       	call   406c <printf>
    exit();
    2c84:	e8 63 12 00 00       	call   3eec <exit>
  }
  if(chdir("/") != 0){
    2c89:	c7 04 24 aa 44 00 00 	movl   $0x44aa,(%esp)
    2c90:	e8 c7 12 00 00       	call   3f5c <chdir>
    2c95:	85 c0                	test   %eax,%eax
    2c97:	74 19                	je     2cb2 <rmdot+0xe7>
    printf(1, "chdir / failed\n");
    2c99:	c7 44 24 04 ac 44 00 	movl   $0x44ac,0x4(%esp)
    2ca0:	00 
    2ca1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ca8:	e8 bf 13 00 00       	call   406c <printf>
    exit();
    2cad:	e8 3a 12 00 00       	call   3eec <exit>
  }
  if(unlink("dots/.") == 0){
    2cb2:	c7 04 24 0e 56 00 00 	movl   $0x560e,(%esp)
    2cb9:	e8 7e 12 00 00       	call   3f3c <unlink>
    2cbe:	85 c0                	test   %eax,%eax
    2cc0:	75 19                	jne    2cdb <rmdot+0x110>
    printf(1, "unlink dots/. worked!\n");
    2cc2:	c7 44 24 04 15 56 00 	movl   $0x5615,0x4(%esp)
    2cc9:	00 
    2cca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cd1:	e8 96 13 00 00       	call   406c <printf>
    exit();
    2cd6:	e8 11 12 00 00       	call   3eec <exit>
  }
  if(unlink("dots/..") == 0){
    2cdb:	c7 04 24 2c 56 00 00 	movl   $0x562c,(%esp)
    2ce2:	e8 55 12 00 00       	call   3f3c <unlink>
    2ce7:	85 c0                	test   %eax,%eax
    2ce9:	75 19                	jne    2d04 <rmdot+0x139>
    printf(1, "unlink dots/.. worked!\n");
    2ceb:	c7 44 24 04 34 56 00 	movl   $0x5634,0x4(%esp)
    2cf2:	00 
    2cf3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cfa:	e8 6d 13 00 00       	call   406c <printf>
    exit();
    2cff:	e8 e8 11 00 00       	call   3eec <exit>
  }
  if(unlink("dots") != 0){
    2d04:	c7 04 24 c6 55 00 00 	movl   $0x55c6,(%esp)
    2d0b:	e8 2c 12 00 00       	call   3f3c <unlink>
    2d10:	85 c0                	test   %eax,%eax
    2d12:	74 19                	je     2d2d <rmdot+0x162>
    printf(1, "unlink dots failed!\n");
    2d14:	c7 44 24 04 4c 56 00 	movl   $0x564c,0x4(%esp)
    2d1b:	00 
    2d1c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d23:	e8 44 13 00 00       	call   406c <printf>
    exit();
    2d28:	e8 bf 11 00 00       	call   3eec <exit>
  }
  printf(1, "rmdot ok\n");
    2d2d:	c7 44 24 04 61 56 00 	movl   $0x5661,0x4(%esp)
    2d34:	00 
    2d35:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d3c:	e8 2b 13 00 00       	call   406c <printf>
}
    2d41:	c9                   	leave  
    2d42:	c3                   	ret    

00002d43 <dirfile>:

void
dirfile(void)
{
    2d43:	55                   	push   %ebp
    2d44:	89 e5                	mov    %esp,%ebp
    2d46:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "dir vs file\n");
    2d49:	c7 44 24 04 6b 56 00 	movl   $0x566b,0x4(%esp)
    2d50:	00 
    2d51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d58:	e8 0f 13 00 00       	call   406c <printf>

  fd = open("dirfile", O_CREATE);
    2d5d:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2d64:	00 
    2d65:	c7 04 24 78 56 00 00 	movl   $0x5678,(%esp)
    2d6c:	e8 bb 11 00 00       	call   3f2c <open>
    2d71:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2d74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2d78:	79 19                	jns    2d93 <dirfile+0x50>
    printf(1, "create dirfile failed\n");
    2d7a:	c7 44 24 04 80 56 00 	movl   $0x5680,0x4(%esp)
    2d81:	00 
    2d82:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d89:	e8 de 12 00 00       	call   406c <printf>
    exit();
    2d8e:	e8 59 11 00 00       	call   3eec <exit>
  }
  close(fd);
    2d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2d96:	89 04 24             	mov    %eax,(%esp)
    2d99:	e8 76 11 00 00       	call   3f14 <close>
  if(chdir("dirfile") == 0){
    2d9e:	c7 04 24 78 56 00 00 	movl   $0x5678,(%esp)
    2da5:	e8 b2 11 00 00       	call   3f5c <chdir>
    2daa:	85 c0                	test   %eax,%eax
    2dac:	75 19                	jne    2dc7 <dirfile+0x84>
    printf(1, "chdir dirfile succeeded!\n");
    2dae:	c7 44 24 04 97 56 00 	movl   $0x5697,0x4(%esp)
    2db5:	00 
    2db6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2dbd:	e8 aa 12 00 00       	call   406c <printf>
    exit();
    2dc2:	e8 25 11 00 00       	call   3eec <exit>
  }
  fd = open("dirfile/xx", 0);
    2dc7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2dce:	00 
    2dcf:	c7 04 24 b1 56 00 00 	movl   $0x56b1,(%esp)
    2dd6:	e8 51 11 00 00       	call   3f2c <open>
    2ddb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2dde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2de2:	78 19                	js     2dfd <dirfile+0xba>
    printf(1, "create dirfile/xx succeeded!\n");
    2de4:	c7 44 24 04 bc 56 00 	movl   $0x56bc,0x4(%esp)
    2deb:	00 
    2dec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2df3:	e8 74 12 00 00       	call   406c <printf>
    exit();
    2df8:	e8 ef 10 00 00       	call   3eec <exit>
  }
  fd = open("dirfile/xx", O_CREATE);
    2dfd:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2e04:	00 
    2e05:	c7 04 24 b1 56 00 00 	movl   $0x56b1,(%esp)
    2e0c:	e8 1b 11 00 00       	call   3f2c <open>
    2e11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2e14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2e18:	78 19                	js     2e33 <dirfile+0xf0>
    printf(1, "create dirfile/xx succeeded!\n");
    2e1a:	c7 44 24 04 bc 56 00 	movl   $0x56bc,0x4(%esp)
    2e21:	00 
    2e22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e29:	e8 3e 12 00 00       	call   406c <printf>
    exit();
    2e2e:	e8 b9 10 00 00       	call   3eec <exit>
  }
  if(mkdir("dirfile/xx") == 0){
    2e33:	c7 04 24 b1 56 00 00 	movl   $0x56b1,(%esp)
    2e3a:	e8 15 11 00 00       	call   3f54 <mkdir>
    2e3f:	85 c0                	test   %eax,%eax
    2e41:	75 19                	jne    2e5c <dirfile+0x119>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    2e43:	c7 44 24 04 da 56 00 	movl   $0x56da,0x4(%esp)
    2e4a:	00 
    2e4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e52:	e8 15 12 00 00       	call   406c <printf>
    exit();
    2e57:	e8 90 10 00 00       	call   3eec <exit>
  }
  if(unlink("dirfile/xx") == 0){
    2e5c:	c7 04 24 b1 56 00 00 	movl   $0x56b1,(%esp)
    2e63:	e8 d4 10 00 00       	call   3f3c <unlink>
    2e68:	85 c0                	test   %eax,%eax
    2e6a:	75 19                	jne    2e85 <dirfile+0x142>
    printf(1, "unlink dirfile/xx succeeded!\n");
    2e6c:	c7 44 24 04 f7 56 00 	movl   $0x56f7,0x4(%esp)
    2e73:	00 
    2e74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e7b:	e8 ec 11 00 00       	call   406c <printf>
    exit();
    2e80:	e8 67 10 00 00       	call   3eec <exit>
  }
  if(link("README", "dirfile/xx") == 0){
    2e85:	c7 44 24 04 b1 56 00 	movl   $0x56b1,0x4(%esp)
    2e8c:	00 
    2e8d:	c7 04 24 15 57 00 00 	movl   $0x5715,(%esp)
    2e94:	e8 b3 10 00 00       	call   3f4c <link>
    2e99:	85 c0                	test   %eax,%eax
    2e9b:	75 19                	jne    2eb6 <dirfile+0x173>
    printf(1, "link to dirfile/xx succeeded!\n");
    2e9d:	c7 44 24 04 1c 57 00 	movl   $0x571c,0x4(%esp)
    2ea4:	00 
    2ea5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2eac:	e8 bb 11 00 00       	call   406c <printf>
    exit();
    2eb1:	e8 36 10 00 00       	call   3eec <exit>
  }
  if(unlink("dirfile") != 0){
    2eb6:	c7 04 24 78 56 00 00 	movl   $0x5678,(%esp)
    2ebd:	e8 7a 10 00 00       	call   3f3c <unlink>
    2ec2:	85 c0                	test   %eax,%eax
    2ec4:	74 19                	je     2edf <dirfile+0x19c>
    printf(1, "unlink dirfile failed!\n");
    2ec6:	c7 44 24 04 3b 57 00 	movl   $0x573b,0x4(%esp)
    2ecd:	00 
    2ece:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ed5:	e8 92 11 00 00       	call   406c <printf>
    exit();
    2eda:	e8 0d 10 00 00       	call   3eec <exit>
  }

  fd = open(".", O_RDWR);
    2edf:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    2ee6:	00 
    2ee7:	c7 04 24 f7 4c 00 00 	movl   $0x4cf7,(%esp)
    2eee:	e8 39 10 00 00       	call   3f2c <open>
    2ef3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2ef6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2efa:	78 19                	js     2f15 <dirfile+0x1d2>
    printf(1, "open . for writing succeeded!\n");
    2efc:	c7 44 24 04 54 57 00 	movl   $0x5754,0x4(%esp)
    2f03:	00 
    2f04:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f0b:	e8 5c 11 00 00       	call   406c <printf>
    exit();
    2f10:	e8 d7 0f 00 00       	call   3eec <exit>
  }
  fd = open(".", 0);
    2f15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2f1c:	00 
    2f1d:	c7 04 24 f7 4c 00 00 	movl   $0x4cf7,(%esp)
    2f24:	e8 03 10 00 00       	call   3f2c <open>
    2f29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(write(fd, "x", 1) > 0){
    2f2c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    2f33:	00 
    2f34:	c7 44 24 04 33 49 00 	movl   $0x4933,0x4(%esp)
    2f3b:	00 
    2f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2f3f:	89 04 24             	mov    %eax,(%esp)
    2f42:	e8 c5 0f 00 00       	call   3f0c <write>
    2f47:	85 c0                	test   %eax,%eax
    2f49:	7e 19                	jle    2f64 <dirfile+0x221>
    printf(1, "write . succeeded!\n");
    2f4b:	c7 44 24 04 73 57 00 	movl   $0x5773,0x4(%esp)
    2f52:	00 
    2f53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f5a:	e8 0d 11 00 00       	call   406c <printf>
    exit();
    2f5f:	e8 88 0f 00 00       	call   3eec <exit>
  }
  close(fd);
    2f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2f67:	89 04 24             	mov    %eax,(%esp)
    2f6a:	e8 a5 0f 00 00       	call   3f14 <close>

  printf(1, "dir vs file OK\n");
    2f6f:	c7 44 24 04 87 57 00 	movl   $0x5787,0x4(%esp)
    2f76:	00 
    2f77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f7e:	e8 e9 10 00 00       	call   406c <printf>
}
    2f83:	c9                   	leave  
    2f84:	c3                   	ret    

00002f85 <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    2f85:	55                   	push   %ebp
    2f86:	89 e5                	mov    %esp,%ebp
    2f88:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(1, "empty file name\n");
    2f8b:	c7 44 24 04 97 57 00 	movl   $0x5797,0x4(%esp)
    2f92:	00 
    2f93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f9a:	e8 cd 10 00 00       	call   406c <printf>

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2f9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2fa6:	e9 d2 00 00 00       	jmp    307d <iref+0xf8>
    if(mkdir("irefd") != 0){
    2fab:	c7 04 24 a8 57 00 00 	movl   $0x57a8,(%esp)
    2fb2:	e8 9d 0f 00 00       	call   3f54 <mkdir>
    2fb7:	85 c0                	test   %eax,%eax
    2fb9:	74 19                	je     2fd4 <iref+0x4f>
      printf(1, "mkdir irefd failed\n");
    2fbb:	c7 44 24 04 ae 57 00 	movl   $0x57ae,0x4(%esp)
    2fc2:	00 
    2fc3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2fca:	e8 9d 10 00 00       	call   406c <printf>
      exit();
    2fcf:	e8 18 0f 00 00       	call   3eec <exit>
    }
    if(chdir("irefd") != 0){
    2fd4:	c7 04 24 a8 57 00 00 	movl   $0x57a8,(%esp)
    2fdb:	e8 7c 0f 00 00       	call   3f5c <chdir>
    2fe0:	85 c0                	test   %eax,%eax
    2fe2:	74 19                	je     2ffd <iref+0x78>
      printf(1, "chdir irefd failed\n");
    2fe4:	c7 44 24 04 c2 57 00 	movl   $0x57c2,0x4(%esp)
    2feb:	00 
    2fec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ff3:	e8 74 10 00 00       	call   406c <printf>
      exit();
    2ff8:	e8 ef 0e 00 00       	call   3eec <exit>
    }

    mkdir("");
    2ffd:	c7 04 24 d6 57 00 00 	movl   $0x57d6,(%esp)
    3004:	e8 4b 0f 00 00       	call   3f54 <mkdir>
    link("README", "");
    3009:	c7 44 24 04 d6 57 00 	movl   $0x57d6,0x4(%esp)
    3010:	00 
    3011:	c7 04 24 15 57 00 00 	movl   $0x5715,(%esp)
    3018:	e8 2f 0f 00 00       	call   3f4c <link>
    fd = open("", O_CREATE);
    301d:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3024:	00 
    3025:	c7 04 24 d6 57 00 00 	movl   $0x57d6,(%esp)
    302c:	e8 fb 0e 00 00       	call   3f2c <open>
    3031:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    3034:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3038:	78 0b                	js     3045 <iref+0xc0>
      close(fd);
    303a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    303d:	89 04 24             	mov    %eax,(%esp)
    3040:	e8 cf 0e 00 00       	call   3f14 <close>
    fd = open("xx", O_CREATE);
    3045:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    304c:	00 
    304d:	c7 04 24 d7 57 00 00 	movl   $0x57d7,(%esp)
    3054:	e8 d3 0e 00 00       	call   3f2c <open>
    3059:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    305c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3060:	78 0b                	js     306d <iref+0xe8>
      close(fd);
    3062:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3065:	89 04 24             	mov    %eax,(%esp)
    3068:	e8 a7 0e 00 00       	call   3f14 <close>
    unlink("xx");
    306d:	c7 04 24 d7 57 00 00 	movl   $0x57d7,(%esp)
    3074:	e8 c3 0e 00 00       	call   3f3c <unlink>
  int i, fd;

  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    3079:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    307d:	83 7d f4 32          	cmpl   $0x32,-0xc(%ebp)
    3081:	0f 8e 24 ff ff ff    	jle    2fab <iref+0x26>
    if(fd >= 0)
      close(fd);
    unlink("xx");
  }

  chdir("/");
    3087:	c7 04 24 aa 44 00 00 	movl   $0x44aa,(%esp)
    308e:	e8 c9 0e 00 00       	call   3f5c <chdir>
  printf(1, "empty file name OK\n");
    3093:	c7 44 24 04 da 57 00 	movl   $0x57da,0x4(%esp)
    309a:	00 
    309b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30a2:	e8 c5 0f 00 00       	call   406c <printf>
}
    30a7:	c9                   	leave  
    30a8:	c3                   	ret    

000030a9 <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    30a9:	55                   	push   %ebp
    30aa:	89 e5                	mov    %esp,%ebp
    30ac:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
    30af:	c7 44 24 04 ee 57 00 	movl   $0x57ee,0x4(%esp)
    30b6:	00 
    30b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30be:	e8 a9 0f 00 00       	call   406c <printf>

  for(n=0; n<1000; n++){
    30c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    30ca:	eb 1f                	jmp    30eb <forktest+0x42>
    pid = fork();
    30cc:	e8 13 0e 00 00       	call   3ee4 <fork>
    30d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
    30d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    30d8:	79 02                	jns    30dc <forktest+0x33>
      break;
    30da:	eb 18                	jmp    30f4 <forktest+0x4b>
    if(pid == 0)
    30dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    30e0:	75 05                	jne    30e7 <forktest+0x3e>
      exit();
    30e2:	e8 05 0e 00 00       	call   3eec <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<1000; n++){
    30e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    30eb:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    30f2:	7e d8                	jle    30cc <forktest+0x23>
      break;
    if(pid == 0)
      exit();
  }
  
  if(n == 1000){
    30f4:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
    30fb:	75 19                	jne    3116 <forktest+0x6d>
    printf(1, "fork claimed to work 1000 times!\n");
    30fd:	c7 44 24 04 fc 57 00 	movl   $0x57fc,0x4(%esp)
    3104:	00 
    3105:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    310c:	e8 5b 0f 00 00       	call   406c <printf>
    exit();
    3111:	e8 d6 0d 00 00       	call   3eec <exit>
  }
  
  for(; n > 0; n--){
    3116:	eb 26                	jmp    313e <forktest+0x95>
    if(wait() < 0){
    3118:	e8 d7 0d 00 00       	call   3ef4 <wait>
    311d:	85 c0                	test   %eax,%eax
    311f:	79 19                	jns    313a <forktest+0x91>
      printf(1, "wait stopped early\n");
    3121:	c7 44 24 04 1e 58 00 	movl   $0x581e,0x4(%esp)
    3128:	00 
    3129:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3130:	e8 37 0f 00 00       	call   406c <printf>
      exit();
    3135:	e8 b2 0d 00 00       	call   3eec <exit>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }
  
  for(; n > 0; n--){
    313a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    313e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3142:	7f d4                	jg     3118 <forktest+0x6f>
      printf(1, "wait stopped early\n");
      exit();
    }
  }
  
  if(wait() != -1){
    3144:	e8 ab 0d 00 00       	call   3ef4 <wait>
    3149:	83 f8 ff             	cmp    $0xffffffff,%eax
    314c:	74 19                	je     3167 <forktest+0xbe>
    printf(1, "wait got too many\n");
    314e:	c7 44 24 04 32 58 00 	movl   $0x5832,0x4(%esp)
    3155:	00 
    3156:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    315d:	e8 0a 0f 00 00       	call   406c <printf>
    exit();
    3162:	e8 85 0d 00 00       	call   3eec <exit>
  }
  
  printf(1, "fork test OK\n");
    3167:	c7 44 24 04 45 58 00 	movl   $0x5845,0x4(%esp)
    316e:	00 
    316f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3176:	e8 f1 0e 00 00       	call   406c <printf>
}
    317b:	c9                   	leave  
    317c:	c3                   	ret    

0000317d <sbrktest>:

void
sbrktest(void)
{
    317d:	55                   	push   %ebp
    317e:	89 e5                	mov    %esp,%ebp
    3180:	53                   	push   %ebx
    3181:	81 ec 84 00 00 00    	sub    $0x84,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    3187:	a1 2c 63 00 00       	mov    0x632c,%eax
    318c:	c7 44 24 04 53 58 00 	movl   $0x5853,0x4(%esp)
    3193:	00 
    3194:	89 04 24             	mov    %eax,(%esp)
    3197:	e8 d0 0e 00 00       	call   406c <printf>
  oldbrk = sbrk(0);
    319c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    31a3:	e8 cc 0d 00 00       	call   3f74 <sbrk>
    31a8:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // can one sbrk() less than a page?
  a = sbrk(0);
    31ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    31b2:	e8 bd 0d 00 00       	call   3f74 <sbrk>
    31b7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  int i;
  for(i = 0; i < 5000; i++){ 
    31ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    31c1:	eb 59                	jmp    321c <sbrktest+0x9f>
    b = sbrk(1);
    31c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    31ca:	e8 a5 0d 00 00       	call   3f74 <sbrk>
    31cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(b != a){
    31d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    31d5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    31d8:	74 2f                	je     3209 <sbrktest+0x8c>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    31da:	a1 2c 63 00 00       	mov    0x632c,%eax
    31df:	8b 55 e8             	mov    -0x18(%ebp),%edx
    31e2:	89 54 24 10          	mov    %edx,0x10(%esp)
    31e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
    31e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
    31ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
    31f0:	89 54 24 08          	mov    %edx,0x8(%esp)
    31f4:	c7 44 24 04 5e 58 00 	movl   $0x585e,0x4(%esp)
    31fb:	00 
    31fc:	89 04 24             	mov    %eax,(%esp)
    31ff:	e8 68 0e 00 00       	call   406c <printf>
      exit();
    3204:	e8 e3 0c 00 00       	call   3eec <exit>
    }
    *b = 1;
    3209:	8b 45 e8             	mov    -0x18(%ebp),%eax
    320c:	c6 00 01             	movb   $0x1,(%eax)
    a = b + 1;
    320f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3212:	83 c0 01             	add    $0x1,%eax
    3215:	89 45 f4             	mov    %eax,-0xc(%ebp)

  // can one sbrk() less than a page?
  a = sbrk(0);

  int i;
  for(i = 0; i < 5000; i++){ 
    3218:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    321c:	81 7d f0 87 13 00 00 	cmpl   $0x1387,-0x10(%ebp)
    3223:	7e 9e                	jle    31c3 <sbrktest+0x46>
      exit();
    }
    *b = 1;
    a = b + 1;
  }
  pid = fork();
    3225:	e8 ba 0c 00 00       	call   3ee4 <fork>
    322a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(pid < 0){
    322d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    3231:	79 1a                	jns    324d <sbrktest+0xd0>
    printf(stdout, "sbrk test fork failed\n");
    3233:	a1 2c 63 00 00       	mov    0x632c,%eax
    3238:	c7 44 24 04 79 58 00 	movl   $0x5879,0x4(%esp)
    323f:	00 
    3240:	89 04 24             	mov    %eax,(%esp)
    3243:	e8 24 0e 00 00       	call   406c <printf>
    exit();
    3248:	e8 9f 0c 00 00       	call   3eec <exit>
  }
  c = sbrk(1);
    324d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3254:	e8 1b 0d 00 00       	call   3f74 <sbrk>
    3259:	89 45 e0             	mov    %eax,-0x20(%ebp)
  c = sbrk(1);
    325c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3263:	e8 0c 0d 00 00       	call   3f74 <sbrk>
    3268:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a + 1){
    326b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    326e:	83 c0 01             	add    $0x1,%eax
    3271:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    3274:	74 1a                	je     3290 <sbrktest+0x113>
    printf(stdout, "sbrk test failed post-fork\n");
    3276:	a1 2c 63 00 00       	mov    0x632c,%eax
    327b:	c7 44 24 04 90 58 00 	movl   $0x5890,0x4(%esp)
    3282:	00 
    3283:	89 04 24             	mov    %eax,(%esp)
    3286:	e8 e1 0d 00 00       	call   406c <printf>
    exit();
    328b:	e8 5c 0c 00 00       	call   3eec <exit>
  }
  if(pid == 0)
    3290:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    3294:	75 05                	jne    329b <sbrktest+0x11e>
    exit();
    3296:	e8 51 0c 00 00       	call   3eec <exit>
  wait();
    329b:	e8 54 0c 00 00       	call   3ef4 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    32a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    32a7:	e8 c8 0c 00 00       	call   3f74 <sbrk>
    32ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  amt = (BIG) - (uint)a;
    32af:	8b 45 f4             	mov    -0xc(%ebp),%eax
    32b2:	ba 00 00 40 06       	mov    $0x6400000,%edx
    32b7:	29 c2                	sub    %eax,%edx
    32b9:	89 d0                	mov    %edx,%eax
    32bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  p = sbrk(amt);
    32be:	8b 45 dc             	mov    -0x24(%ebp),%eax
    32c1:	89 04 24             	mov    %eax,(%esp)
    32c4:	e8 ab 0c 00 00       	call   3f74 <sbrk>
    32c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (p != a) { 
    32cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
    32cf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    32d2:	74 1a                	je     32ee <sbrktest+0x171>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    32d4:	a1 2c 63 00 00       	mov    0x632c,%eax
    32d9:	c7 44 24 04 ac 58 00 	movl   $0x58ac,0x4(%esp)
    32e0:	00 
    32e1:	89 04 24             	mov    %eax,(%esp)
    32e4:	e8 83 0d 00 00       	call   406c <printf>
    exit();
    32e9:	e8 fe 0b 00 00       	call   3eec <exit>
  }
  lastaddr = (char*) (BIG-1);
    32ee:	c7 45 d4 ff ff 3f 06 	movl   $0x63fffff,-0x2c(%ebp)
  *lastaddr = 99;
    32f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    32f8:	c6 00 63             	movb   $0x63,(%eax)

  // can one de-allocate?
  a = sbrk(0);
    32fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3302:	e8 6d 0c 00 00       	call   3f74 <sbrk>
    3307:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-4096);
    330a:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    3311:	e8 5e 0c 00 00       	call   3f74 <sbrk>
    3316:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c == (char*)0xffffffff){
    3319:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    331d:	75 1a                	jne    3339 <sbrktest+0x1bc>
    printf(stdout, "sbrk could not deallocate\n");
    331f:	a1 2c 63 00 00       	mov    0x632c,%eax
    3324:	c7 44 24 04 ea 58 00 	movl   $0x58ea,0x4(%esp)
    332b:	00 
    332c:	89 04 24             	mov    %eax,(%esp)
    332f:	e8 38 0d 00 00       	call   406c <printf>
    exit();
    3334:	e8 b3 0b 00 00       	call   3eec <exit>
  }
  c = sbrk(0);
    3339:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3340:	e8 2f 0c 00 00       	call   3f74 <sbrk>
    3345:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a - 4096){
    3348:	8b 45 f4             	mov    -0xc(%ebp),%eax
    334b:	2d 00 10 00 00       	sub    $0x1000,%eax
    3350:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    3353:	74 28                	je     337d <sbrktest+0x200>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    3355:	a1 2c 63 00 00       	mov    0x632c,%eax
    335a:	8b 55 e0             	mov    -0x20(%ebp),%edx
    335d:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3361:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3364:	89 54 24 08          	mov    %edx,0x8(%esp)
    3368:	c7 44 24 04 08 59 00 	movl   $0x5908,0x4(%esp)
    336f:	00 
    3370:	89 04 24             	mov    %eax,(%esp)
    3373:	e8 f4 0c 00 00       	call   406c <printf>
    exit();
    3378:	e8 6f 0b 00 00       	call   3eec <exit>
  }

  // can one re-allocate that page?
  a = sbrk(0);
    337d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3384:	e8 eb 0b 00 00       	call   3f74 <sbrk>
    3389:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(4096);
    338c:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    3393:	e8 dc 0b 00 00       	call   3f74 <sbrk>
    3398:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a || sbrk(0) != a + 4096){
    339b:	8b 45 e0             	mov    -0x20(%ebp),%eax
    339e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    33a1:	75 19                	jne    33bc <sbrktest+0x23f>
    33a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    33aa:	e8 c5 0b 00 00       	call   3f74 <sbrk>
    33af:	8b 55 f4             	mov    -0xc(%ebp),%edx
    33b2:	81 c2 00 10 00 00    	add    $0x1000,%edx
    33b8:	39 d0                	cmp    %edx,%eax
    33ba:	74 28                	je     33e4 <sbrktest+0x267>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    33bc:	a1 2c 63 00 00       	mov    0x632c,%eax
    33c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
    33c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
    33c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
    33cb:	89 54 24 08          	mov    %edx,0x8(%esp)
    33cf:	c7 44 24 04 40 59 00 	movl   $0x5940,0x4(%esp)
    33d6:	00 
    33d7:	89 04 24             	mov    %eax,(%esp)
    33da:	e8 8d 0c 00 00       	call   406c <printf>
    exit();
    33df:	e8 08 0b 00 00       	call   3eec <exit>
  }
  if(*lastaddr == 99){
    33e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    33e7:	0f b6 00             	movzbl (%eax),%eax
    33ea:	3c 63                	cmp    $0x63,%al
    33ec:	75 1a                	jne    3408 <sbrktest+0x28b>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    33ee:	a1 2c 63 00 00       	mov    0x632c,%eax
    33f3:	c7 44 24 04 68 59 00 	movl   $0x5968,0x4(%esp)
    33fa:	00 
    33fb:	89 04 24             	mov    %eax,(%esp)
    33fe:	e8 69 0c 00 00       	call   406c <printf>
    exit();
    3403:	e8 e4 0a 00 00       	call   3eec <exit>
  }

  a = sbrk(0);
    3408:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    340f:	e8 60 0b 00 00       	call   3f74 <sbrk>
    3414:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-(sbrk(0) - oldbrk));
    3417:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    341a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3421:	e8 4e 0b 00 00       	call   3f74 <sbrk>
    3426:	29 c3                	sub    %eax,%ebx
    3428:	89 d8                	mov    %ebx,%eax
    342a:	89 04 24             	mov    %eax,(%esp)
    342d:	e8 42 0b 00 00       	call   3f74 <sbrk>
    3432:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a){
    3435:	8b 45 e0             	mov    -0x20(%ebp),%eax
    3438:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    343b:	74 28                	je     3465 <sbrktest+0x2e8>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    343d:	a1 2c 63 00 00       	mov    0x632c,%eax
    3442:	8b 55 e0             	mov    -0x20(%ebp),%edx
    3445:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3449:	8b 55 f4             	mov    -0xc(%ebp),%edx
    344c:	89 54 24 08          	mov    %edx,0x8(%esp)
    3450:	c7 44 24 04 98 59 00 	movl   $0x5998,0x4(%esp)
    3457:	00 
    3458:	89 04 24             	mov    %eax,(%esp)
    345b:	e8 0c 0c 00 00       	call   406c <printf>
    exit();
    3460:	e8 87 0a 00 00       	call   3eec <exit>
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    3465:	c7 45 f4 00 00 00 80 	movl   $0x80000000,-0xc(%ebp)
    346c:	eb 7b                	jmp    34e9 <sbrktest+0x36c>
    ppid = getpid();
    346e:	e8 f9 0a 00 00       	call   3f6c <getpid>
    3473:	89 45 d0             	mov    %eax,-0x30(%ebp)
    pid = fork();
    3476:	e8 69 0a 00 00       	call   3ee4 <fork>
    347b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(pid < 0){
    347e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    3482:	79 1a                	jns    349e <sbrktest+0x321>
      printf(stdout, "fork failed\n");
    3484:	a1 2c 63 00 00       	mov    0x632c,%eax
    3489:	c7 44 24 04 d9 44 00 	movl   $0x44d9,0x4(%esp)
    3490:	00 
    3491:	89 04 24             	mov    %eax,(%esp)
    3494:	e8 d3 0b 00 00       	call   406c <printf>
      exit();
    3499:	e8 4e 0a 00 00       	call   3eec <exit>
    }
    if(pid == 0){
    349e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    34a2:	75 39                	jne    34dd <sbrktest+0x360>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    34a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    34a7:	0f b6 00             	movzbl (%eax),%eax
    34aa:	0f be d0             	movsbl %al,%edx
    34ad:	a1 2c 63 00 00       	mov    0x632c,%eax
    34b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
    34b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
    34b9:	89 54 24 08          	mov    %edx,0x8(%esp)
    34bd:	c7 44 24 04 b9 59 00 	movl   $0x59b9,0x4(%esp)
    34c4:	00 
    34c5:	89 04 24             	mov    %eax,(%esp)
    34c8:	e8 9f 0b 00 00       	call   406c <printf>
      kill(ppid);
    34cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
    34d0:	89 04 24             	mov    %eax,(%esp)
    34d3:	e8 44 0a 00 00       	call   3f1c <kill>
      exit();
    34d8:	e8 0f 0a 00 00       	call   3eec <exit>
    }
    wait();
    34dd:	e8 12 0a 00 00       	call   3ef4 <wait>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    exit();
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    34e2:	81 45 f4 50 c3 00 00 	addl   $0xc350,-0xc(%ebp)
    34e9:	81 7d f4 7f 84 1e 80 	cmpl   $0x801e847f,-0xc(%ebp)
    34f0:	0f 86 78 ff ff ff    	jbe    346e <sbrktest+0x2f1>
    wait();
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    34f6:	8d 45 c8             	lea    -0x38(%ebp),%eax
    34f9:	89 04 24             	mov    %eax,(%esp)
    34fc:	e8 fb 09 00 00       	call   3efc <pipe>
    3501:	85 c0                	test   %eax,%eax
    3503:	74 19                	je     351e <sbrktest+0x3a1>
    printf(1, "pipe() failed\n");
    3505:	c7 44 24 04 aa 48 00 	movl   $0x48aa,0x4(%esp)
    350c:	00 
    350d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3514:	e8 53 0b 00 00       	call   406c <printf>
    exit();
    3519:	e8 ce 09 00 00       	call   3eec <exit>
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    351e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    3525:	e9 87 00 00 00       	jmp    35b1 <sbrktest+0x434>
    if((pids[i] = fork()) == 0){
    352a:	e8 b5 09 00 00       	call   3ee4 <fork>
    352f:	8b 55 f0             	mov    -0x10(%ebp),%edx
    3532:	89 44 95 a0          	mov    %eax,-0x60(%ebp,%edx,4)
    3536:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3539:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    353d:	85 c0                	test   %eax,%eax
    353f:	75 46                	jne    3587 <sbrktest+0x40a>
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    3541:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3548:	e8 27 0a 00 00       	call   3f74 <sbrk>
    354d:	ba 00 00 40 06       	mov    $0x6400000,%edx
    3552:	29 c2                	sub    %eax,%edx
    3554:	89 d0                	mov    %edx,%eax
    3556:	89 04 24             	mov    %eax,(%esp)
    3559:	e8 16 0a 00 00       	call   3f74 <sbrk>
      write(fds[1], "x", 1);
    355e:	8b 45 cc             	mov    -0x34(%ebp),%eax
    3561:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3568:	00 
    3569:	c7 44 24 04 33 49 00 	movl   $0x4933,0x4(%esp)
    3570:	00 
    3571:	89 04 24             	mov    %eax,(%esp)
    3574:	e8 93 09 00 00       	call   3f0c <write>
      // sit around until killed
      for(;;) sleep(1000);
    3579:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
    3580:	e8 f7 09 00 00       	call   3f7c <sleep>
    3585:	eb f2                	jmp    3579 <sbrktest+0x3fc>
    }
    if(pids[i] != -1)
    3587:	8b 45 f0             	mov    -0x10(%ebp),%eax
    358a:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    358e:	83 f8 ff             	cmp    $0xffffffff,%eax
    3591:	74 1a                	je     35ad <sbrktest+0x430>
      read(fds[0], &scratch, 1);
    3593:	8b 45 c8             	mov    -0x38(%ebp),%eax
    3596:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    359d:	00 
    359e:	8d 55 9f             	lea    -0x61(%ebp),%edx
    35a1:	89 54 24 04          	mov    %edx,0x4(%esp)
    35a5:	89 04 24             	mov    %eax,(%esp)
    35a8:	e8 57 09 00 00       	call   3f04 <read>
  // failed allocation?
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    35ad:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    35b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    35b4:	83 f8 09             	cmp    $0x9,%eax
    35b7:	0f 86 6d ff ff ff    	jbe    352a <sbrktest+0x3ad>
    if(pids[i] != -1)
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    35bd:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    35c4:	e8 ab 09 00 00       	call   3f74 <sbrk>
    35c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    35cc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    35d3:	eb 26                	jmp    35fb <sbrktest+0x47e>
    if(pids[i] == -1)
    35d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    35d8:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    35dc:	83 f8 ff             	cmp    $0xffffffff,%eax
    35df:	75 02                	jne    35e3 <sbrktest+0x466>
      continue;
    35e1:	eb 14                	jmp    35f7 <sbrktest+0x47a>
    kill(pids[i]);
    35e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    35e6:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    35ea:	89 04 24             	mov    %eax,(%esp)
    35ed:	e8 2a 09 00 00       	call   3f1c <kill>
    wait();
    35f2:	e8 fd 08 00 00       	call   3ef4 <wait>
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    35f7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    35fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
    35fe:	83 f8 09             	cmp    $0x9,%eax
    3601:	76 d2                	jbe    35d5 <sbrktest+0x458>
    if(pids[i] == -1)
      continue;
    kill(pids[i]);
    wait();
  }
  if(c == (char*)0xffffffff){
    3603:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    3607:	75 1a                	jne    3623 <sbrktest+0x4a6>
    printf(stdout, "failed sbrk leaked memory\n");
    3609:	a1 2c 63 00 00       	mov    0x632c,%eax
    360e:	c7 44 24 04 d2 59 00 	movl   $0x59d2,0x4(%esp)
    3615:	00 
    3616:	89 04 24             	mov    %eax,(%esp)
    3619:	e8 4e 0a 00 00       	call   406c <printf>
    exit();
    361e:	e8 c9 08 00 00       	call   3eec <exit>
  }

  if(sbrk(0) > oldbrk)
    3623:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    362a:	e8 45 09 00 00       	call   3f74 <sbrk>
    362f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    3632:	76 1b                	jbe    364f <sbrktest+0x4d2>
    sbrk(-(sbrk(0) - oldbrk));
    3634:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    3637:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    363e:	e8 31 09 00 00       	call   3f74 <sbrk>
    3643:	29 c3                	sub    %eax,%ebx
    3645:	89 d8                	mov    %ebx,%eax
    3647:	89 04 24             	mov    %eax,(%esp)
    364a:	e8 25 09 00 00       	call   3f74 <sbrk>

  printf(stdout, "sbrk test OK\n");
    364f:	a1 2c 63 00 00       	mov    0x632c,%eax
    3654:	c7 44 24 04 ed 59 00 	movl   $0x59ed,0x4(%esp)
    365b:	00 
    365c:	89 04 24             	mov    %eax,(%esp)
    365f:	e8 08 0a 00 00       	call   406c <printf>
}
    3664:	81 c4 84 00 00 00    	add    $0x84,%esp
    366a:	5b                   	pop    %ebx
    366b:	5d                   	pop    %ebp
    366c:	c3                   	ret    

0000366d <validateint>:

void
validateint(int *p)
{
    366d:	55                   	push   %ebp
    366e:	89 e5                	mov    %esp,%ebp
    3670:	53                   	push   %ebx
    3671:	83 ec 10             	sub    $0x10,%esp
  int res;
  asm("mov %%esp, %%ebx\n\t"
    3674:	b8 0d 00 00 00       	mov    $0xd,%eax
    3679:	8b 55 08             	mov    0x8(%ebp),%edx
    367c:	89 d1                	mov    %edx,%ecx
    367e:	89 e3                	mov    %esp,%ebx
    3680:	89 cc                	mov    %ecx,%esp
    3682:	cd 40                	int    $0x40
    3684:	89 dc                	mov    %ebx,%esp
    3686:	89 45 f8             	mov    %eax,-0x8(%ebp)
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    3689:	83 c4 10             	add    $0x10,%esp
    368c:	5b                   	pop    %ebx
    368d:	5d                   	pop    %ebp
    368e:	c3                   	ret    

0000368f <validatetest>:

void
validatetest(void)
{
    368f:	55                   	push   %ebp
    3690:	89 e5                	mov    %esp,%ebp
    3692:	83 ec 28             	sub    $0x28,%esp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    3695:	a1 2c 63 00 00       	mov    0x632c,%eax
    369a:	c7 44 24 04 fb 59 00 	movl   $0x59fb,0x4(%esp)
    36a1:	00 
    36a2:	89 04 24             	mov    %eax,(%esp)
    36a5:	e8 c2 09 00 00       	call   406c <printf>
  hi = 1100*1024;
    36aa:	c7 45 f0 00 30 11 00 	movl   $0x113000,-0x10(%ebp)

  for(p = 0; p <= (uint)hi; p += 4096){
    36b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    36b8:	eb 7f                	jmp    3739 <validatetest+0xaa>
    if((pid = fork()) == 0){
    36ba:	e8 25 08 00 00       	call   3ee4 <fork>
    36bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    36c2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    36c6:	75 10                	jne    36d8 <validatetest+0x49>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
    36c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    36cb:	89 04 24             	mov    %eax,(%esp)
    36ce:	e8 9a ff ff ff       	call   366d <validateint>
      exit();
    36d3:	e8 14 08 00 00       	call   3eec <exit>
    }
    sleep(0);
    36d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    36df:	e8 98 08 00 00       	call   3f7c <sleep>
    sleep(0);
    36e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    36eb:	e8 8c 08 00 00       	call   3f7c <sleep>
    kill(pid);
    36f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
    36f3:	89 04 24             	mov    %eax,(%esp)
    36f6:	e8 21 08 00 00       	call   3f1c <kill>
    wait();
    36fb:	e8 f4 07 00 00       	call   3ef4 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    3700:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3703:	89 44 24 04          	mov    %eax,0x4(%esp)
    3707:	c7 04 24 0a 5a 00 00 	movl   $0x5a0a,(%esp)
    370e:	e8 39 08 00 00       	call   3f4c <link>
    3713:	83 f8 ff             	cmp    $0xffffffff,%eax
    3716:	74 1a                	je     3732 <validatetest+0xa3>
      printf(stdout, "link should not succeed\n");
    3718:	a1 2c 63 00 00       	mov    0x632c,%eax
    371d:	c7 44 24 04 15 5a 00 	movl   $0x5a15,0x4(%esp)
    3724:	00 
    3725:	89 04 24             	mov    %eax,(%esp)
    3728:	e8 3f 09 00 00       	call   406c <printf>
      exit();
    372d:	e8 ba 07 00 00       	call   3eec <exit>
  uint p;

  printf(stdout, "validate test\n");
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    3732:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    3739:	8b 45 f0             	mov    -0x10(%ebp),%eax
    373c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    373f:	0f 83 75 ff ff ff    	jae    36ba <validatetest+0x2b>
      printf(stdout, "link should not succeed\n");
      exit();
    }
  }

  printf(stdout, "validate ok\n");
    3745:	a1 2c 63 00 00       	mov    0x632c,%eax
    374a:	c7 44 24 04 2e 5a 00 	movl   $0x5a2e,0x4(%esp)
    3751:	00 
    3752:	89 04 24             	mov    %eax,(%esp)
    3755:	e8 12 09 00 00       	call   406c <printf>
}
    375a:	c9                   	leave  
    375b:	c3                   	ret    

0000375c <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    375c:	55                   	push   %ebp
    375d:	89 e5                	mov    %esp,%ebp
    375f:	83 ec 28             	sub    $0x28,%esp
  int i;

  printf(stdout, "bss test\n");
    3762:	a1 2c 63 00 00       	mov    0x632c,%eax
    3767:	c7 44 24 04 3b 5a 00 	movl   $0x5a3b,0x4(%esp)
    376e:	00 
    376f:	89 04 24             	mov    %eax,(%esp)
    3772:	e8 f5 08 00 00       	call   406c <printf>
  for(i = 0; i < sizeof(uninit); i++){
    3777:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    377e:	eb 2d                	jmp    37ad <bsstest+0x51>
    if(uninit[i] != '\0'){
    3780:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3783:	05 00 64 00 00       	add    $0x6400,%eax
    3788:	0f b6 00             	movzbl (%eax),%eax
    378b:	84 c0                	test   %al,%al
    378d:	74 1a                	je     37a9 <bsstest+0x4d>
      printf(stdout, "bss test failed\n");
    378f:	a1 2c 63 00 00       	mov    0x632c,%eax
    3794:	c7 44 24 04 45 5a 00 	movl   $0x5a45,0x4(%esp)
    379b:	00 
    379c:	89 04 24             	mov    %eax,(%esp)
    379f:	e8 c8 08 00 00       	call   406c <printf>
      exit();
    37a4:	e8 43 07 00 00       	call   3eec <exit>
bsstest(void)
{
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
    37a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    37ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
    37b0:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    37b5:	76 c9                	jbe    3780 <bsstest+0x24>
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
      exit();
    }
  }
  printf(stdout, "bss test ok\n");
    37b7:	a1 2c 63 00 00       	mov    0x632c,%eax
    37bc:	c7 44 24 04 56 5a 00 	movl   $0x5a56,0x4(%esp)
    37c3:	00 
    37c4:	89 04 24             	mov    %eax,(%esp)
    37c7:	e8 a0 08 00 00       	call   406c <printf>
}
    37cc:	c9                   	leave  
    37cd:	c3                   	ret    

000037ce <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    37ce:	55                   	push   %ebp
    37cf:	89 e5                	mov    %esp,%ebp
    37d1:	83 ec 28             	sub    $0x28,%esp
  int pid, fd;

  unlink("bigarg-ok");
    37d4:	c7 04 24 63 5a 00 00 	movl   $0x5a63,(%esp)
    37db:	e8 5c 07 00 00       	call   3f3c <unlink>
  pid = fork();
    37e0:	e8 ff 06 00 00       	call   3ee4 <fork>
    37e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid == 0){
    37e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    37ec:	0f 85 90 00 00 00    	jne    3882 <bigargtest+0xb4>
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    37f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    37f9:	eb 12                	jmp    380d <bigargtest+0x3f>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    37fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    37fe:	c7 04 85 60 63 00 00 	movl   $0x5a70,0x6360(,%eax,4)
    3805:	70 5a 00 00 
  unlink("bigarg-ok");
  pid = fork();
  if(pid == 0){
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    3809:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    380d:	83 7d f4 1e          	cmpl   $0x1e,-0xc(%ebp)
    3811:	7e e8                	jle    37fb <bigargtest+0x2d>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    args[MAXARG-1] = 0;
    3813:	c7 05 dc 63 00 00 00 	movl   $0x0,0x63dc
    381a:	00 00 00 
    printf(stdout, "bigarg test\n");
    381d:	a1 2c 63 00 00       	mov    0x632c,%eax
    3822:	c7 44 24 04 4d 5b 00 	movl   $0x5b4d,0x4(%esp)
    3829:	00 
    382a:	89 04 24             	mov    %eax,(%esp)
    382d:	e8 3a 08 00 00       	call   406c <printf>
    exec("echo", args);
    3832:	c7 44 24 04 60 63 00 	movl   $0x6360,0x4(%esp)
    3839:	00 
    383a:	c7 04 24 38 44 00 00 	movl   $0x4438,(%esp)
    3841:	e8 de 06 00 00       	call   3f24 <exec>
    printf(stdout, "bigarg test ok\n");
    3846:	a1 2c 63 00 00       	mov    0x632c,%eax
    384b:	c7 44 24 04 5a 5b 00 	movl   $0x5b5a,0x4(%esp)
    3852:	00 
    3853:	89 04 24             	mov    %eax,(%esp)
    3856:	e8 11 08 00 00       	call   406c <printf>
    fd = open("bigarg-ok", O_CREATE);
    385b:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3862:	00 
    3863:	c7 04 24 63 5a 00 00 	movl   $0x5a63,(%esp)
    386a:	e8 bd 06 00 00       	call   3f2c <open>
    386f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    close(fd);
    3872:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3875:	89 04 24             	mov    %eax,(%esp)
    3878:	e8 97 06 00 00       	call   3f14 <close>
    exit();
    387d:	e8 6a 06 00 00       	call   3eec <exit>
  } else if(pid < 0){
    3882:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3886:	79 1a                	jns    38a2 <bigargtest+0xd4>
    printf(stdout, "bigargtest: fork failed\n");
    3888:	a1 2c 63 00 00       	mov    0x632c,%eax
    388d:	c7 44 24 04 6a 5b 00 	movl   $0x5b6a,0x4(%esp)
    3894:	00 
    3895:	89 04 24             	mov    %eax,(%esp)
    3898:	e8 cf 07 00 00       	call   406c <printf>
    exit();
    389d:	e8 4a 06 00 00       	call   3eec <exit>
  }
  wait();
    38a2:	e8 4d 06 00 00       	call   3ef4 <wait>
  fd = open("bigarg-ok", 0);
    38a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    38ae:	00 
    38af:	c7 04 24 63 5a 00 00 	movl   $0x5a63,(%esp)
    38b6:	e8 71 06 00 00       	call   3f2c <open>
    38bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    38be:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    38c2:	79 1a                	jns    38de <bigargtest+0x110>
    printf(stdout, "bigarg test failed!\n");
    38c4:	a1 2c 63 00 00       	mov    0x632c,%eax
    38c9:	c7 44 24 04 83 5b 00 	movl   $0x5b83,0x4(%esp)
    38d0:	00 
    38d1:	89 04 24             	mov    %eax,(%esp)
    38d4:	e8 93 07 00 00       	call   406c <printf>
    exit();
    38d9:	e8 0e 06 00 00       	call   3eec <exit>
  }
  close(fd);
    38de:	8b 45 ec             	mov    -0x14(%ebp),%eax
    38e1:	89 04 24             	mov    %eax,(%esp)
    38e4:	e8 2b 06 00 00       	call   3f14 <close>
  unlink("bigarg-ok");
    38e9:	c7 04 24 63 5a 00 00 	movl   $0x5a63,(%esp)
    38f0:	e8 47 06 00 00       	call   3f3c <unlink>
}
    38f5:	c9                   	leave  
    38f6:	c3                   	ret    

000038f7 <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    38f7:	55                   	push   %ebp
    38f8:	89 e5                	mov    %esp,%ebp
    38fa:	53                   	push   %ebx
    38fb:	83 ec 74             	sub    $0x74,%esp
  int nfiles;
  int fsblocks = 0;
    38fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  printf(1, "fsfull test\n");
    3905:	c7 44 24 04 98 5b 00 	movl   $0x5b98,0x4(%esp)
    390c:	00 
    390d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3914:	e8 53 07 00 00       	call   406c <printf>

  for(nfiles = 0; ; nfiles++){
    3919:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    char name[64];
    name[0] = 'f';
    3920:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    3924:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3927:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    392c:	89 c8                	mov    %ecx,%eax
    392e:	f7 ea                	imul   %edx
    3930:	c1 fa 06             	sar    $0x6,%edx
    3933:	89 c8                	mov    %ecx,%eax
    3935:	c1 f8 1f             	sar    $0x1f,%eax
    3938:	29 c2                	sub    %eax,%edx
    393a:	89 d0                	mov    %edx,%eax
    393c:	83 c0 30             	add    $0x30,%eax
    393f:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    3942:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3945:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    394a:	89 d8                	mov    %ebx,%eax
    394c:	f7 ea                	imul   %edx
    394e:	c1 fa 06             	sar    $0x6,%edx
    3951:	89 d8                	mov    %ebx,%eax
    3953:	c1 f8 1f             	sar    $0x1f,%eax
    3956:	89 d1                	mov    %edx,%ecx
    3958:	29 c1                	sub    %eax,%ecx
    395a:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    3960:	29 c3                	sub    %eax,%ebx
    3962:	89 d9                	mov    %ebx,%ecx
    3964:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3969:	89 c8                	mov    %ecx,%eax
    396b:	f7 ea                	imul   %edx
    396d:	c1 fa 05             	sar    $0x5,%edx
    3970:	89 c8                	mov    %ecx,%eax
    3972:	c1 f8 1f             	sar    $0x1f,%eax
    3975:	29 c2                	sub    %eax,%edx
    3977:	89 d0                	mov    %edx,%eax
    3979:	83 c0 30             	add    $0x30,%eax
    397c:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    397f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3982:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3987:	89 d8                	mov    %ebx,%eax
    3989:	f7 ea                	imul   %edx
    398b:	c1 fa 05             	sar    $0x5,%edx
    398e:	89 d8                	mov    %ebx,%eax
    3990:	c1 f8 1f             	sar    $0x1f,%eax
    3993:	89 d1                	mov    %edx,%ecx
    3995:	29 c1                	sub    %eax,%ecx
    3997:	6b c1 64             	imul   $0x64,%ecx,%eax
    399a:	29 c3                	sub    %eax,%ebx
    399c:	89 d9                	mov    %ebx,%ecx
    399e:	ba 67 66 66 66       	mov    $0x66666667,%edx
    39a3:	89 c8                	mov    %ecx,%eax
    39a5:	f7 ea                	imul   %edx
    39a7:	c1 fa 02             	sar    $0x2,%edx
    39aa:	89 c8                	mov    %ecx,%eax
    39ac:	c1 f8 1f             	sar    $0x1f,%eax
    39af:	29 c2                	sub    %eax,%edx
    39b1:	89 d0                	mov    %edx,%eax
    39b3:	83 c0 30             	add    $0x30,%eax
    39b6:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    39b9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    39bc:	ba 67 66 66 66       	mov    $0x66666667,%edx
    39c1:	89 c8                	mov    %ecx,%eax
    39c3:	f7 ea                	imul   %edx
    39c5:	c1 fa 02             	sar    $0x2,%edx
    39c8:	89 c8                	mov    %ecx,%eax
    39ca:	c1 f8 1f             	sar    $0x1f,%eax
    39cd:	29 c2                	sub    %eax,%edx
    39cf:	89 d0                	mov    %edx,%eax
    39d1:	c1 e0 02             	shl    $0x2,%eax
    39d4:	01 d0                	add    %edx,%eax
    39d6:	01 c0                	add    %eax,%eax
    39d8:	29 c1                	sub    %eax,%ecx
    39da:	89 ca                	mov    %ecx,%edx
    39dc:	89 d0                	mov    %edx,%eax
    39de:	83 c0 30             	add    $0x30,%eax
    39e1:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    39e4:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    printf(1, "writing %s\n", name);
    39e8:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    39eb:	89 44 24 08          	mov    %eax,0x8(%esp)
    39ef:	c7 44 24 04 a5 5b 00 	movl   $0x5ba5,0x4(%esp)
    39f6:	00 
    39f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    39fe:	e8 69 06 00 00       	call   406c <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    3a03:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    3a0a:	00 
    3a0b:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3a0e:	89 04 24             	mov    %eax,(%esp)
    3a11:	e8 16 05 00 00       	call   3f2c <open>
    3a16:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(fd < 0){
    3a19:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    3a1d:	79 1d                	jns    3a3c <fsfull+0x145>
      printf(1, "open %s failed\n", name);
    3a1f:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3a22:	89 44 24 08          	mov    %eax,0x8(%esp)
    3a26:	c7 44 24 04 b1 5b 00 	movl   $0x5bb1,0x4(%esp)
    3a2d:	00 
    3a2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3a35:	e8 32 06 00 00       	call   406c <printf>
      break;
    3a3a:	eb 74                	jmp    3ab0 <fsfull+0x1b9>
    }
    int total = 0;
    3a3c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while(1){
      int cc = write(fd, buf, 512);
    3a43:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    3a4a:	00 
    3a4b:	c7 44 24 04 20 8b 00 	movl   $0x8b20,0x4(%esp)
    3a52:	00 
    3a53:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3a56:	89 04 24             	mov    %eax,(%esp)
    3a59:	e8 ae 04 00 00       	call   3f0c <write>
    3a5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(cc < 512)
    3a61:	81 7d e4 ff 01 00 00 	cmpl   $0x1ff,-0x1c(%ebp)
    3a68:	7f 2f                	jg     3a99 <fsfull+0x1a2>
        break;
    3a6a:	90                   	nop
      total += cc;
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    3a6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3a6e:	89 44 24 08          	mov    %eax,0x8(%esp)
    3a72:	c7 44 24 04 c1 5b 00 	movl   $0x5bc1,0x4(%esp)
    3a79:	00 
    3a7a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3a81:	e8 e6 05 00 00       	call   406c <printf>
    close(fd);
    3a86:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3a89:	89 04 24             	mov    %eax,(%esp)
    3a8c:	e8 83 04 00 00       	call   3f14 <close>
    if(total == 0)
    3a91:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3a95:	75 10                	jne    3aa7 <fsfull+0x1b0>
    3a97:	eb 0c                	jmp    3aa5 <fsfull+0x1ae>
    int total = 0;
    while(1){
      int cc = write(fd, buf, 512);
      if(cc < 512)
        break;
      total += cc;
    3a99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3a9c:	01 45 ec             	add    %eax,-0x14(%ebp)
      fsblocks++;
    3a9f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    }
    3aa3:	eb 9e                	jmp    3a43 <fsfull+0x14c>
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
    3aa5:	eb 09                	jmp    3ab0 <fsfull+0x1b9>
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");

  for(nfiles = 0; ; nfiles++){
    3aa7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
  }
    3aab:	e9 70 fe ff ff       	jmp    3920 <fsfull+0x29>

  while(nfiles >= 0){
    3ab0:	e9 d7 00 00 00       	jmp    3b8c <fsfull+0x295>
    char name[64];
    name[0] = 'f';
    3ab5:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    3ab9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3abc:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3ac1:	89 c8                	mov    %ecx,%eax
    3ac3:	f7 ea                	imul   %edx
    3ac5:	c1 fa 06             	sar    $0x6,%edx
    3ac8:	89 c8                	mov    %ecx,%eax
    3aca:	c1 f8 1f             	sar    $0x1f,%eax
    3acd:	29 c2                	sub    %eax,%edx
    3acf:	89 d0                	mov    %edx,%eax
    3ad1:	83 c0 30             	add    $0x30,%eax
    3ad4:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    3ad7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3ada:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3adf:	89 d8                	mov    %ebx,%eax
    3ae1:	f7 ea                	imul   %edx
    3ae3:	c1 fa 06             	sar    $0x6,%edx
    3ae6:	89 d8                	mov    %ebx,%eax
    3ae8:	c1 f8 1f             	sar    $0x1f,%eax
    3aeb:	89 d1                	mov    %edx,%ecx
    3aed:	29 c1                	sub    %eax,%ecx
    3aef:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    3af5:	29 c3                	sub    %eax,%ebx
    3af7:	89 d9                	mov    %ebx,%ecx
    3af9:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3afe:	89 c8                	mov    %ecx,%eax
    3b00:	f7 ea                	imul   %edx
    3b02:	c1 fa 05             	sar    $0x5,%edx
    3b05:	89 c8                	mov    %ecx,%eax
    3b07:	c1 f8 1f             	sar    $0x1f,%eax
    3b0a:	29 c2                	sub    %eax,%edx
    3b0c:	89 d0                	mov    %edx,%eax
    3b0e:	83 c0 30             	add    $0x30,%eax
    3b11:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3b14:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3b17:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3b1c:	89 d8                	mov    %ebx,%eax
    3b1e:	f7 ea                	imul   %edx
    3b20:	c1 fa 05             	sar    $0x5,%edx
    3b23:	89 d8                	mov    %ebx,%eax
    3b25:	c1 f8 1f             	sar    $0x1f,%eax
    3b28:	89 d1                	mov    %edx,%ecx
    3b2a:	29 c1                	sub    %eax,%ecx
    3b2c:	6b c1 64             	imul   $0x64,%ecx,%eax
    3b2f:	29 c3                	sub    %eax,%ebx
    3b31:	89 d9                	mov    %ebx,%ecx
    3b33:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3b38:	89 c8                	mov    %ecx,%eax
    3b3a:	f7 ea                	imul   %edx
    3b3c:	c1 fa 02             	sar    $0x2,%edx
    3b3f:	89 c8                	mov    %ecx,%eax
    3b41:	c1 f8 1f             	sar    $0x1f,%eax
    3b44:	29 c2                	sub    %eax,%edx
    3b46:	89 d0                	mov    %edx,%eax
    3b48:	83 c0 30             	add    $0x30,%eax
    3b4b:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    3b4e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3b51:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3b56:	89 c8                	mov    %ecx,%eax
    3b58:	f7 ea                	imul   %edx
    3b5a:	c1 fa 02             	sar    $0x2,%edx
    3b5d:	89 c8                	mov    %ecx,%eax
    3b5f:	c1 f8 1f             	sar    $0x1f,%eax
    3b62:	29 c2                	sub    %eax,%edx
    3b64:	89 d0                	mov    %edx,%eax
    3b66:	c1 e0 02             	shl    $0x2,%eax
    3b69:	01 d0                	add    %edx,%eax
    3b6b:	01 c0                	add    %eax,%eax
    3b6d:	29 c1                	sub    %eax,%ecx
    3b6f:	89 ca                	mov    %ecx,%edx
    3b71:	89 d0                	mov    %edx,%eax
    3b73:	83 c0 30             	add    $0x30,%eax
    3b76:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    3b79:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    unlink(name);
    3b7d:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3b80:	89 04 24             	mov    %eax,(%esp)
    3b83:	e8 b4 03 00 00       	call   3f3c <unlink>
    nfiles--;
    3b88:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    close(fd);
    if(total == 0)
      break;
  }

  while(nfiles >= 0){
    3b8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3b90:	0f 89 1f ff ff ff    	jns    3ab5 <fsfull+0x1be>
    name[5] = '\0';
    unlink(name);
    nfiles--;
  }

  printf(1, "fsfull test finished\n");
    3b96:	c7 44 24 04 d1 5b 00 	movl   $0x5bd1,0x4(%esp)
    3b9d:	00 
    3b9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3ba5:	e8 c2 04 00 00       	call   406c <printf>
}
    3baa:	83 c4 74             	add    $0x74,%esp
    3bad:	5b                   	pop    %ebx
    3bae:	5d                   	pop    %ebp
    3baf:	c3                   	ret    

00003bb0 <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    3bb0:	55                   	push   %ebp
    3bb1:	89 e5                	mov    %esp,%ebp
  randstate = randstate * 1664525 + 1013904223;
    3bb3:	a1 30 63 00 00       	mov    0x6330,%eax
    3bb8:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
    3bbe:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
    3bc3:	a3 30 63 00 00       	mov    %eax,0x6330
  return randstate;
    3bc8:	a1 30 63 00 00       	mov    0x6330,%eax
}
    3bcd:	5d                   	pop    %ebp
    3bce:	c3                   	ret    

00003bcf <main>:

int
main(int argc, char *argv[])
{
    3bcf:	55                   	push   %ebp
    3bd0:	89 e5                	mov    %esp,%ebp
    3bd2:	83 e4 f0             	and    $0xfffffff0,%esp
    3bd5:	83 ec 10             	sub    $0x10,%esp
  printf(1, "usertests starting\n");
    3bd8:	c7 44 24 04 e7 5b 00 	movl   $0x5be7,0x4(%esp)
    3bdf:	00 
    3be0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3be7:	e8 80 04 00 00       	call   406c <printf>

  if(open("usertests.ran", 0) >= 0){
    3bec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3bf3:	00 
    3bf4:	c7 04 24 fb 5b 00 00 	movl   $0x5bfb,(%esp)
    3bfb:	e8 2c 03 00 00       	call   3f2c <open>
    3c00:	85 c0                	test   %eax,%eax
    3c02:	78 19                	js     3c1d <main+0x4e>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    3c04:	c7 44 24 04 0c 5c 00 	movl   $0x5c0c,0x4(%esp)
    3c0b:	00 
    3c0c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3c13:	e8 54 04 00 00       	call   406c <printf>
    exit();
    3c18:	e8 cf 02 00 00       	call   3eec <exit>
  }
  close(open("usertests.ran", O_CREATE));
    3c1d:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3c24:	00 
    3c25:	c7 04 24 fb 5b 00 00 	movl   $0x5bfb,(%esp)
    3c2c:	e8 fb 02 00 00       	call   3f2c <open>
    3c31:	89 04 24             	mov    %eax,(%esp)
    3c34:	e8 db 02 00 00       	call   3f14 <close>
  openiputtest();
  exitiputtest();
  iputtest();

  mem();*/
  pipe1();
    3c39:	e8 35 cd ff ff       	call   973 <pipe1>
  preempt();
    3c3e:	e8 3c cf ff ff       	call   b7f <preempt>
  exitwait();
    3c43:	e8 07 d1 ff ff       	call   d4f <exitwait>

  rmdot();
    3c48:	e8 7e ef ff ff       	call   2bcb <rmdot>
  fourteen();
    3c4d:	e8 23 ee ff ff       	call   2a75 <fourteen>
  bigfile();
    3c52:	e8 f3 eb ff ff       	call   284a <bigfile>
  subdir();
    3c57:	e8 a0 e3 ff ff       	call   1ffc <subdir>
  linktest();
    3c5c:	e8 04 db ff ff       	call   1765 <linktest>
  unlinkread();
    3c61:	e8 2a d9 ff ff       	call   1590 <unlinkread>
  dirfile();
    3c66:	e8 d8 f0 ff ff       	call   2d43 <dirfile>
  iref();
    3c6b:	e8 15 f3 ff ff       	call   2f85 <iref>
  forktest();
    3c70:	e8 34 f4 ff ff       	call   30a9 <forktest>
  bigdir(); // slow
    3c75:	e8 15 e2 ff ff       	call   1e8f <bigdir>
  exectest();
    3c7a:	e8 a5 cc ff ff       	call   924 <exectest>

  exit();
    3c7f:	e8 68 02 00 00       	call   3eec <exit>

00003c84 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    3c84:	55                   	push   %ebp
    3c85:	89 e5                	mov    %esp,%ebp
    3c87:	57                   	push   %edi
    3c88:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    3c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
    3c8c:	8b 55 10             	mov    0x10(%ebp),%edx
    3c8f:	8b 45 0c             	mov    0xc(%ebp),%eax
    3c92:	89 cb                	mov    %ecx,%ebx
    3c94:	89 df                	mov    %ebx,%edi
    3c96:	89 d1                	mov    %edx,%ecx
    3c98:	fc                   	cld    
    3c99:	f3 aa                	rep stos %al,%es:(%edi)
    3c9b:	89 ca                	mov    %ecx,%edx
    3c9d:	89 fb                	mov    %edi,%ebx
    3c9f:	89 5d 08             	mov    %ebx,0x8(%ebp)
    3ca2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    3ca5:	5b                   	pop    %ebx
    3ca6:	5f                   	pop    %edi
    3ca7:	5d                   	pop    %ebp
    3ca8:	c3                   	ret    

00003ca9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    3ca9:	55                   	push   %ebp
    3caa:	89 e5                	mov    %esp,%ebp
    3cac:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    3caf:	8b 45 08             	mov    0x8(%ebp),%eax
    3cb2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    3cb5:	90                   	nop
    3cb6:	8b 45 08             	mov    0x8(%ebp),%eax
    3cb9:	8d 50 01             	lea    0x1(%eax),%edx
    3cbc:	89 55 08             	mov    %edx,0x8(%ebp)
    3cbf:	8b 55 0c             	mov    0xc(%ebp),%edx
    3cc2:	8d 4a 01             	lea    0x1(%edx),%ecx
    3cc5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    3cc8:	0f b6 12             	movzbl (%edx),%edx
    3ccb:	88 10                	mov    %dl,(%eax)
    3ccd:	0f b6 00             	movzbl (%eax),%eax
    3cd0:	84 c0                	test   %al,%al
    3cd2:	75 e2                	jne    3cb6 <strcpy+0xd>
    ;
  return os;
    3cd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3cd7:	c9                   	leave  
    3cd8:	c3                   	ret    

00003cd9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    3cd9:	55                   	push   %ebp
    3cda:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    3cdc:	eb 08                	jmp    3ce6 <strcmp+0xd>
    p++, q++;
    3cde:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3ce2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    3ce6:	8b 45 08             	mov    0x8(%ebp),%eax
    3ce9:	0f b6 00             	movzbl (%eax),%eax
    3cec:	84 c0                	test   %al,%al
    3cee:	74 10                	je     3d00 <strcmp+0x27>
    3cf0:	8b 45 08             	mov    0x8(%ebp),%eax
    3cf3:	0f b6 10             	movzbl (%eax),%edx
    3cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
    3cf9:	0f b6 00             	movzbl (%eax),%eax
    3cfc:	38 c2                	cmp    %al,%dl
    3cfe:	74 de                	je     3cde <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    3d00:	8b 45 08             	mov    0x8(%ebp),%eax
    3d03:	0f b6 00             	movzbl (%eax),%eax
    3d06:	0f b6 d0             	movzbl %al,%edx
    3d09:	8b 45 0c             	mov    0xc(%ebp),%eax
    3d0c:	0f b6 00             	movzbl (%eax),%eax
    3d0f:	0f b6 c0             	movzbl %al,%eax
    3d12:	29 c2                	sub    %eax,%edx
    3d14:	89 d0                	mov    %edx,%eax
}
    3d16:	5d                   	pop    %ebp
    3d17:	c3                   	ret    

00003d18 <strlen>:

uint
strlen(char *s)
{
    3d18:	55                   	push   %ebp
    3d19:	89 e5                	mov    %esp,%ebp
    3d1b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    3d1e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    3d25:	eb 04                	jmp    3d2b <strlen+0x13>
    3d27:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    3d2b:	8b 55 fc             	mov    -0x4(%ebp),%edx
    3d2e:	8b 45 08             	mov    0x8(%ebp),%eax
    3d31:	01 d0                	add    %edx,%eax
    3d33:	0f b6 00             	movzbl (%eax),%eax
    3d36:	84 c0                	test   %al,%al
    3d38:	75 ed                	jne    3d27 <strlen+0xf>
    ;
  return n;
    3d3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3d3d:	c9                   	leave  
    3d3e:	c3                   	ret    

00003d3f <memset>:

void*
memset(void *dst, int c, uint n)
{
    3d3f:	55                   	push   %ebp
    3d40:	89 e5                	mov    %esp,%ebp
    3d42:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    3d45:	8b 45 10             	mov    0x10(%ebp),%eax
    3d48:	89 44 24 08          	mov    %eax,0x8(%esp)
    3d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
    3d4f:	89 44 24 04          	mov    %eax,0x4(%esp)
    3d53:	8b 45 08             	mov    0x8(%ebp),%eax
    3d56:	89 04 24             	mov    %eax,(%esp)
    3d59:	e8 26 ff ff ff       	call   3c84 <stosb>
  return dst;
    3d5e:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3d61:	c9                   	leave  
    3d62:	c3                   	ret    

00003d63 <strchr>:

char*
strchr(const char *s, char c)
{
    3d63:	55                   	push   %ebp
    3d64:	89 e5                	mov    %esp,%ebp
    3d66:	83 ec 04             	sub    $0x4,%esp
    3d69:	8b 45 0c             	mov    0xc(%ebp),%eax
    3d6c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    3d6f:	eb 14                	jmp    3d85 <strchr+0x22>
    if(*s == c)
    3d71:	8b 45 08             	mov    0x8(%ebp),%eax
    3d74:	0f b6 00             	movzbl (%eax),%eax
    3d77:	3a 45 fc             	cmp    -0x4(%ebp),%al
    3d7a:	75 05                	jne    3d81 <strchr+0x1e>
      return (char*)s;
    3d7c:	8b 45 08             	mov    0x8(%ebp),%eax
    3d7f:	eb 13                	jmp    3d94 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    3d81:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3d85:	8b 45 08             	mov    0x8(%ebp),%eax
    3d88:	0f b6 00             	movzbl (%eax),%eax
    3d8b:	84 c0                	test   %al,%al
    3d8d:	75 e2                	jne    3d71 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    3d8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
    3d94:	c9                   	leave  
    3d95:	c3                   	ret    

00003d96 <gets>:

char*
gets(char *buf, int max)
{
    3d96:	55                   	push   %ebp
    3d97:	89 e5                	mov    %esp,%ebp
    3d99:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3d9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3da3:	eb 4c                	jmp    3df1 <gets+0x5b>
    cc = read(0, &c, 1);
    3da5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3dac:	00 
    3dad:	8d 45 ef             	lea    -0x11(%ebp),%eax
    3db0:	89 44 24 04          	mov    %eax,0x4(%esp)
    3db4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3dbb:	e8 44 01 00 00       	call   3f04 <read>
    3dc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    3dc3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3dc7:	7f 02                	jg     3dcb <gets+0x35>
      break;
    3dc9:	eb 31                	jmp    3dfc <gets+0x66>
    buf[i++] = c;
    3dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3dce:	8d 50 01             	lea    0x1(%eax),%edx
    3dd1:	89 55 f4             	mov    %edx,-0xc(%ebp)
    3dd4:	89 c2                	mov    %eax,%edx
    3dd6:	8b 45 08             	mov    0x8(%ebp),%eax
    3dd9:	01 c2                	add    %eax,%edx
    3ddb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3ddf:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    3de1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3de5:	3c 0a                	cmp    $0xa,%al
    3de7:	74 13                	je     3dfc <gets+0x66>
    3de9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3ded:	3c 0d                	cmp    $0xd,%al
    3def:	74 0b                	je     3dfc <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3df4:	83 c0 01             	add    $0x1,%eax
    3df7:	3b 45 0c             	cmp    0xc(%ebp),%eax
    3dfa:	7c a9                	jl     3da5 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    3dfc:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3dff:	8b 45 08             	mov    0x8(%ebp),%eax
    3e02:	01 d0                	add    %edx,%eax
    3e04:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    3e07:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3e0a:	c9                   	leave  
    3e0b:	c3                   	ret    

00003e0c <stat>:

int
stat(char *n, struct stat *st)
{
    3e0c:	55                   	push   %ebp
    3e0d:	89 e5                	mov    %esp,%ebp
    3e0f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    3e12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3e19:	00 
    3e1a:	8b 45 08             	mov    0x8(%ebp),%eax
    3e1d:	89 04 24             	mov    %eax,(%esp)
    3e20:	e8 07 01 00 00       	call   3f2c <open>
    3e25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    3e28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3e2c:	79 07                	jns    3e35 <stat+0x29>
    return -1;
    3e2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    3e33:	eb 23                	jmp    3e58 <stat+0x4c>
  r = fstat(fd, st);
    3e35:	8b 45 0c             	mov    0xc(%ebp),%eax
    3e38:	89 44 24 04          	mov    %eax,0x4(%esp)
    3e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3e3f:	89 04 24             	mov    %eax,(%esp)
    3e42:	e8 fd 00 00 00       	call   3f44 <fstat>
    3e47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    3e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3e4d:	89 04 24             	mov    %eax,(%esp)
    3e50:	e8 bf 00 00 00       	call   3f14 <close>
  return r;
    3e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    3e58:	c9                   	leave  
    3e59:	c3                   	ret    

00003e5a <atoi>:

int
atoi(const char *s)
{
    3e5a:	55                   	push   %ebp
    3e5b:	89 e5                	mov    %esp,%ebp
    3e5d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    3e60:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    3e67:	eb 25                	jmp    3e8e <atoi+0x34>
    n = n*10 + *s++ - '0';
    3e69:	8b 55 fc             	mov    -0x4(%ebp),%edx
    3e6c:	89 d0                	mov    %edx,%eax
    3e6e:	c1 e0 02             	shl    $0x2,%eax
    3e71:	01 d0                	add    %edx,%eax
    3e73:	01 c0                	add    %eax,%eax
    3e75:	89 c1                	mov    %eax,%ecx
    3e77:	8b 45 08             	mov    0x8(%ebp),%eax
    3e7a:	8d 50 01             	lea    0x1(%eax),%edx
    3e7d:	89 55 08             	mov    %edx,0x8(%ebp)
    3e80:	0f b6 00             	movzbl (%eax),%eax
    3e83:	0f be c0             	movsbl %al,%eax
    3e86:	01 c8                	add    %ecx,%eax
    3e88:	83 e8 30             	sub    $0x30,%eax
    3e8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    3e8e:	8b 45 08             	mov    0x8(%ebp),%eax
    3e91:	0f b6 00             	movzbl (%eax),%eax
    3e94:	3c 2f                	cmp    $0x2f,%al
    3e96:	7e 0a                	jle    3ea2 <atoi+0x48>
    3e98:	8b 45 08             	mov    0x8(%ebp),%eax
    3e9b:	0f b6 00             	movzbl (%eax),%eax
    3e9e:	3c 39                	cmp    $0x39,%al
    3ea0:	7e c7                	jle    3e69 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    3ea2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3ea5:	c9                   	leave  
    3ea6:	c3                   	ret    

00003ea7 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    3ea7:	55                   	push   %ebp
    3ea8:	89 e5                	mov    %esp,%ebp
    3eaa:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    3ead:	8b 45 08             	mov    0x8(%ebp),%eax
    3eb0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    3eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
    3eb6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    3eb9:	eb 17                	jmp    3ed2 <memmove+0x2b>
    *dst++ = *src++;
    3ebb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    3ebe:	8d 50 01             	lea    0x1(%eax),%edx
    3ec1:	89 55 fc             	mov    %edx,-0x4(%ebp)
    3ec4:	8b 55 f8             	mov    -0x8(%ebp),%edx
    3ec7:	8d 4a 01             	lea    0x1(%edx),%ecx
    3eca:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    3ecd:	0f b6 12             	movzbl (%edx),%edx
    3ed0:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    3ed2:	8b 45 10             	mov    0x10(%ebp),%eax
    3ed5:	8d 50 ff             	lea    -0x1(%eax),%edx
    3ed8:	89 55 10             	mov    %edx,0x10(%ebp)
    3edb:	85 c0                	test   %eax,%eax
    3edd:	7f dc                	jg     3ebb <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    3edf:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3ee2:	c9                   	leave  
    3ee3:	c3                   	ret    

00003ee4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    3ee4:	b8 01 00 00 00       	mov    $0x1,%eax
    3ee9:	cd 40                	int    $0x40
    3eeb:	c3                   	ret    

00003eec <exit>:
SYSCALL(exit)
    3eec:	b8 02 00 00 00       	mov    $0x2,%eax
    3ef1:	cd 40                	int    $0x40
    3ef3:	c3                   	ret    

00003ef4 <wait>:
SYSCALL(wait)
    3ef4:	b8 03 00 00 00       	mov    $0x3,%eax
    3ef9:	cd 40                	int    $0x40
    3efb:	c3                   	ret    

00003efc <pipe>:
SYSCALL(pipe)
    3efc:	b8 04 00 00 00       	mov    $0x4,%eax
    3f01:	cd 40                	int    $0x40
    3f03:	c3                   	ret    

00003f04 <read>:
SYSCALL(read)
    3f04:	b8 05 00 00 00       	mov    $0x5,%eax
    3f09:	cd 40                	int    $0x40
    3f0b:	c3                   	ret    

00003f0c <write>:
SYSCALL(write)
    3f0c:	b8 10 00 00 00       	mov    $0x10,%eax
    3f11:	cd 40                	int    $0x40
    3f13:	c3                   	ret    

00003f14 <close>:
SYSCALL(close)
    3f14:	b8 15 00 00 00       	mov    $0x15,%eax
    3f19:	cd 40                	int    $0x40
    3f1b:	c3                   	ret    

00003f1c <kill>:
SYSCALL(kill)
    3f1c:	b8 06 00 00 00       	mov    $0x6,%eax
    3f21:	cd 40                	int    $0x40
    3f23:	c3                   	ret    

00003f24 <exec>:
SYSCALL(exec)
    3f24:	b8 07 00 00 00       	mov    $0x7,%eax
    3f29:	cd 40                	int    $0x40
    3f2b:	c3                   	ret    

00003f2c <open>:
SYSCALL(open)
    3f2c:	b8 0f 00 00 00       	mov    $0xf,%eax
    3f31:	cd 40                	int    $0x40
    3f33:	c3                   	ret    

00003f34 <mknod>:
SYSCALL(mknod)
    3f34:	b8 11 00 00 00       	mov    $0x11,%eax
    3f39:	cd 40                	int    $0x40
    3f3b:	c3                   	ret    

00003f3c <unlink>:
SYSCALL(unlink)
    3f3c:	b8 12 00 00 00       	mov    $0x12,%eax
    3f41:	cd 40                	int    $0x40
    3f43:	c3                   	ret    

00003f44 <fstat>:
SYSCALL(fstat)
    3f44:	b8 08 00 00 00       	mov    $0x8,%eax
    3f49:	cd 40                	int    $0x40
    3f4b:	c3                   	ret    

00003f4c <link>:
SYSCALL(link)
    3f4c:	b8 13 00 00 00       	mov    $0x13,%eax
    3f51:	cd 40                	int    $0x40
    3f53:	c3                   	ret    

00003f54 <mkdir>:
SYSCALL(mkdir)
    3f54:	b8 14 00 00 00       	mov    $0x14,%eax
    3f59:	cd 40                	int    $0x40
    3f5b:	c3                   	ret    

00003f5c <chdir>:
SYSCALL(chdir)
    3f5c:	b8 09 00 00 00       	mov    $0x9,%eax
    3f61:	cd 40                	int    $0x40
    3f63:	c3                   	ret    

00003f64 <dup>:
SYSCALL(dup)
    3f64:	b8 0a 00 00 00       	mov    $0xa,%eax
    3f69:	cd 40                	int    $0x40
    3f6b:	c3                   	ret    

00003f6c <getpid>:
SYSCALL(getpid)
    3f6c:	b8 0b 00 00 00       	mov    $0xb,%eax
    3f71:	cd 40                	int    $0x40
    3f73:	c3                   	ret    

00003f74 <sbrk>:
SYSCALL(sbrk)
    3f74:	b8 0c 00 00 00       	mov    $0xc,%eax
    3f79:	cd 40                	int    $0x40
    3f7b:	c3                   	ret    

00003f7c <sleep>:
SYSCALL(sleep)
    3f7c:	b8 0d 00 00 00       	mov    $0xd,%eax
    3f81:	cd 40                	int    $0x40
    3f83:	c3                   	ret    

00003f84 <uptime>:
SYSCALL(uptime)
    3f84:	b8 0e 00 00 00       	mov    $0xe,%eax
    3f89:	cd 40                	int    $0x40
    3f8b:	c3                   	ret    

00003f8c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    3f8c:	55                   	push   %ebp
    3f8d:	89 e5                	mov    %esp,%ebp
    3f8f:	83 ec 18             	sub    $0x18,%esp
    3f92:	8b 45 0c             	mov    0xc(%ebp),%eax
    3f95:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    3f98:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3f9f:	00 
    3fa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
    3fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
    3fa7:	8b 45 08             	mov    0x8(%ebp),%eax
    3faa:	89 04 24             	mov    %eax,(%esp)
    3fad:	e8 5a ff ff ff       	call   3f0c <write>
}
    3fb2:	c9                   	leave  
    3fb3:	c3                   	ret    

00003fb4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    3fb4:	55                   	push   %ebp
    3fb5:	89 e5                	mov    %esp,%ebp
    3fb7:	56                   	push   %esi
    3fb8:	53                   	push   %ebx
    3fb9:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    3fbc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    3fc3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    3fc7:	74 17                	je     3fe0 <printint+0x2c>
    3fc9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    3fcd:	79 11                	jns    3fe0 <printint+0x2c>
    neg = 1;
    3fcf:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    3fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
    3fd9:	f7 d8                	neg    %eax
    3fdb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    3fde:	eb 06                	jmp    3fe6 <printint+0x32>
  } else {
    x = xx;
    3fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
    3fe3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    3fe6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    3fed:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3ff0:	8d 41 01             	lea    0x1(%ecx),%eax
    3ff3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    3ff6:	8b 5d 10             	mov    0x10(%ebp),%ebx
    3ff9:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3ffc:	ba 00 00 00 00       	mov    $0x0,%edx
    4001:	f7 f3                	div    %ebx
    4003:	89 d0                	mov    %edx,%eax
    4005:	0f b6 80 34 63 00 00 	movzbl 0x6334(%eax),%eax
    400c:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    4010:	8b 75 10             	mov    0x10(%ebp),%esi
    4013:	8b 45 ec             	mov    -0x14(%ebp),%eax
    4016:	ba 00 00 00 00       	mov    $0x0,%edx
    401b:	f7 f6                	div    %esi
    401d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    4020:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    4024:	75 c7                	jne    3fed <printint+0x39>
  if(neg)
    4026:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    402a:	74 10                	je     403c <printint+0x88>
    buf[i++] = '-';
    402c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    402f:	8d 50 01             	lea    0x1(%eax),%edx
    4032:	89 55 f4             	mov    %edx,-0xc(%ebp)
    4035:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    403a:	eb 1f                	jmp    405b <printint+0xa7>
    403c:	eb 1d                	jmp    405b <printint+0xa7>
    putc(fd, buf[i]);
    403e:	8d 55 dc             	lea    -0x24(%ebp),%edx
    4041:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4044:	01 d0                	add    %edx,%eax
    4046:	0f b6 00             	movzbl (%eax),%eax
    4049:	0f be c0             	movsbl %al,%eax
    404c:	89 44 24 04          	mov    %eax,0x4(%esp)
    4050:	8b 45 08             	mov    0x8(%ebp),%eax
    4053:	89 04 24             	mov    %eax,(%esp)
    4056:	e8 31 ff ff ff       	call   3f8c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    405b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    405f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    4063:	79 d9                	jns    403e <printint+0x8a>
    putc(fd, buf[i]);
}
    4065:	83 c4 30             	add    $0x30,%esp
    4068:	5b                   	pop    %ebx
    4069:	5e                   	pop    %esi
    406a:	5d                   	pop    %ebp
    406b:	c3                   	ret    

0000406c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    406c:	55                   	push   %ebp
    406d:	89 e5                	mov    %esp,%ebp
    406f:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    4072:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    4079:	8d 45 0c             	lea    0xc(%ebp),%eax
    407c:	83 c0 04             	add    $0x4,%eax
    407f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    4082:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    4089:	e9 7c 01 00 00       	jmp    420a <printf+0x19e>
    c = fmt[i] & 0xff;
    408e:	8b 55 0c             	mov    0xc(%ebp),%edx
    4091:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4094:	01 d0                	add    %edx,%eax
    4096:	0f b6 00             	movzbl (%eax),%eax
    4099:	0f be c0             	movsbl %al,%eax
    409c:	25 ff 00 00 00       	and    $0xff,%eax
    40a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    40a4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    40a8:	75 2c                	jne    40d6 <printf+0x6a>
      if(c == '%'){
    40aa:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    40ae:	75 0c                	jne    40bc <printf+0x50>
        state = '%';
    40b0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    40b7:	e9 4a 01 00 00       	jmp    4206 <printf+0x19a>
      } else {
        putc(fd, c);
    40bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    40bf:	0f be c0             	movsbl %al,%eax
    40c2:	89 44 24 04          	mov    %eax,0x4(%esp)
    40c6:	8b 45 08             	mov    0x8(%ebp),%eax
    40c9:	89 04 24             	mov    %eax,(%esp)
    40cc:	e8 bb fe ff ff       	call   3f8c <putc>
    40d1:	e9 30 01 00 00       	jmp    4206 <printf+0x19a>
      }
    } else if(state == '%'){
    40d6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    40da:	0f 85 26 01 00 00    	jne    4206 <printf+0x19a>
      if(c == 'd'){
    40e0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    40e4:	75 2d                	jne    4113 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    40e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    40e9:	8b 00                	mov    (%eax),%eax
    40eb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    40f2:	00 
    40f3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    40fa:	00 
    40fb:	89 44 24 04          	mov    %eax,0x4(%esp)
    40ff:	8b 45 08             	mov    0x8(%ebp),%eax
    4102:	89 04 24             	mov    %eax,(%esp)
    4105:	e8 aa fe ff ff       	call   3fb4 <printint>
        ap++;
    410a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    410e:	e9 ec 00 00 00       	jmp    41ff <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    4113:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    4117:	74 06                	je     411f <printf+0xb3>
    4119:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    411d:	75 2d                	jne    414c <printf+0xe0>
        printint(fd, *ap, 16, 0);
    411f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    4122:	8b 00                	mov    (%eax),%eax
    4124:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    412b:	00 
    412c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    4133:	00 
    4134:	89 44 24 04          	mov    %eax,0x4(%esp)
    4138:	8b 45 08             	mov    0x8(%ebp),%eax
    413b:	89 04 24             	mov    %eax,(%esp)
    413e:	e8 71 fe ff ff       	call   3fb4 <printint>
        ap++;
    4143:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    4147:	e9 b3 00 00 00       	jmp    41ff <printf+0x193>
      } else if(c == 's'){
    414c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    4150:	75 45                	jne    4197 <printf+0x12b>
        s = (char*)*ap;
    4152:	8b 45 e8             	mov    -0x18(%ebp),%eax
    4155:	8b 00                	mov    (%eax),%eax
    4157:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    415a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    415e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    4162:	75 09                	jne    416d <printf+0x101>
          s = "(null)";
    4164:	c7 45 f4 36 5c 00 00 	movl   $0x5c36,-0xc(%ebp)
        while(*s != 0){
    416b:	eb 1e                	jmp    418b <printf+0x11f>
    416d:	eb 1c                	jmp    418b <printf+0x11f>
          putc(fd, *s);
    416f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4172:	0f b6 00             	movzbl (%eax),%eax
    4175:	0f be c0             	movsbl %al,%eax
    4178:	89 44 24 04          	mov    %eax,0x4(%esp)
    417c:	8b 45 08             	mov    0x8(%ebp),%eax
    417f:	89 04 24             	mov    %eax,(%esp)
    4182:	e8 05 fe ff ff       	call   3f8c <putc>
          s++;
    4187:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    418b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    418e:	0f b6 00             	movzbl (%eax),%eax
    4191:	84 c0                	test   %al,%al
    4193:	75 da                	jne    416f <printf+0x103>
    4195:	eb 68                	jmp    41ff <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    4197:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    419b:	75 1d                	jne    41ba <printf+0x14e>
        putc(fd, *ap);
    419d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    41a0:	8b 00                	mov    (%eax),%eax
    41a2:	0f be c0             	movsbl %al,%eax
    41a5:	89 44 24 04          	mov    %eax,0x4(%esp)
    41a9:	8b 45 08             	mov    0x8(%ebp),%eax
    41ac:	89 04 24             	mov    %eax,(%esp)
    41af:	e8 d8 fd ff ff       	call   3f8c <putc>
        ap++;
    41b4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    41b8:	eb 45                	jmp    41ff <printf+0x193>
      } else if(c == '%'){
    41ba:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    41be:	75 17                	jne    41d7 <printf+0x16b>
        putc(fd, c);
    41c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    41c3:	0f be c0             	movsbl %al,%eax
    41c6:	89 44 24 04          	mov    %eax,0x4(%esp)
    41ca:	8b 45 08             	mov    0x8(%ebp),%eax
    41cd:	89 04 24             	mov    %eax,(%esp)
    41d0:	e8 b7 fd ff ff       	call   3f8c <putc>
    41d5:	eb 28                	jmp    41ff <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    41d7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    41de:	00 
    41df:	8b 45 08             	mov    0x8(%ebp),%eax
    41e2:	89 04 24             	mov    %eax,(%esp)
    41e5:	e8 a2 fd ff ff       	call   3f8c <putc>
        putc(fd, c);
    41ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    41ed:	0f be c0             	movsbl %al,%eax
    41f0:	89 44 24 04          	mov    %eax,0x4(%esp)
    41f4:	8b 45 08             	mov    0x8(%ebp),%eax
    41f7:	89 04 24             	mov    %eax,(%esp)
    41fa:	e8 8d fd ff ff       	call   3f8c <putc>
      }
      state = 0;
    41ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    4206:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    420a:	8b 55 0c             	mov    0xc(%ebp),%edx
    420d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4210:	01 d0                	add    %edx,%eax
    4212:	0f b6 00             	movzbl (%eax),%eax
    4215:	84 c0                	test   %al,%al
    4217:	0f 85 71 fe ff ff    	jne    408e <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    421d:	c9                   	leave  
    421e:	c3                   	ret    

0000421f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    421f:	55                   	push   %ebp
    4220:	89 e5                	mov    %esp,%ebp
    4222:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    4225:	8b 45 08             	mov    0x8(%ebp),%eax
    4228:	83 e8 08             	sub    $0x8,%eax
    422b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    422e:	a1 e8 63 00 00       	mov    0x63e8,%eax
    4233:	89 45 fc             	mov    %eax,-0x4(%ebp)
    4236:	eb 24                	jmp    425c <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    4238:	8b 45 fc             	mov    -0x4(%ebp),%eax
    423b:	8b 00                	mov    (%eax),%eax
    423d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4240:	77 12                	ja     4254 <free+0x35>
    4242:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4245:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4248:	77 24                	ja     426e <free+0x4f>
    424a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    424d:	8b 00                	mov    (%eax),%eax
    424f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    4252:	77 1a                	ja     426e <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4254:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4257:	8b 00                	mov    (%eax),%eax
    4259:	89 45 fc             	mov    %eax,-0x4(%ebp)
    425c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    425f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4262:	76 d4                	jbe    4238 <free+0x19>
    4264:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4267:	8b 00                	mov    (%eax),%eax
    4269:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    426c:	76 ca                	jbe    4238 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    426e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4271:	8b 40 04             	mov    0x4(%eax),%eax
    4274:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    427b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    427e:	01 c2                	add    %eax,%edx
    4280:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4283:	8b 00                	mov    (%eax),%eax
    4285:	39 c2                	cmp    %eax,%edx
    4287:	75 24                	jne    42ad <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    4289:	8b 45 f8             	mov    -0x8(%ebp),%eax
    428c:	8b 50 04             	mov    0x4(%eax),%edx
    428f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4292:	8b 00                	mov    (%eax),%eax
    4294:	8b 40 04             	mov    0x4(%eax),%eax
    4297:	01 c2                	add    %eax,%edx
    4299:	8b 45 f8             	mov    -0x8(%ebp),%eax
    429c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    429f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42a2:	8b 00                	mov    (%eax),%eax
    42a4:	8b 10                	mov    (%eax),%edx
    42a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    42a9:	89 10                	mov    %edx,(%eax)
    42ab:	eb 0a                	jmp    42b7 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    42ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42b0:	8b 10                	mov    (%eax),%edx
    42b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    42b5:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    42b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42ba:	8b 40 04             	mov    0x4(%eax),%eax
    42bd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    42c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42c7:	01 d0                	add    %edx,%eax
    42c9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    42cc:	75 20                	jne    42ee <free+0xcf>
    p->s.size += bp->s.size;
    42ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42d1:	8b 50 04             	mov    0x4(%eax),%edx
    42d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    42d7:	8b 40 04             	mov    0x4(%eax),%eax
    42da:	01 c2                	add    %eax,%edx
    42dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42df:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    42e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    42e5:	8b 10                	mov    (%eax),%edx
    42e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42ea:	89 10                	mov    %edx,(%eax)
    42ec:	eb 08                	jmp    42f6 <free+0xd7>
  } else
    p->s.ptr = bp;
    42ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42f1:	8b 55 f8             	mov    -0x8(%ebp),%edx
    42f4:	89 10                	mov    %edx,(%eax)
  freep = p;
    42f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42f9:	a3 e8 63 00 00       	mov    %eax,0x63e8
}
    42fe:	c9                   	leave  
    42ff:	c3                   	ret    

00004300 <morecore>:

static Header*
morecore(uint nu)
{
    4300:	55                   	push   %ebp
    4301:	89 e5                	mov    %esp,%ebp
    4303:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    4306:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    430d:	77 07                	ja     4316 <morecore+0x16>
    nu = 4096;
    430f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    4316:	8b 45 08             	mov    0x8(%ebp),%eax
    4319:	c1 e0 03             	shl    $0x3,%eax
    431c:	89 04 24             	mov    %eax,(%esp)
    431f:	e8 50 fc ff ff       	call   3f74 <sbrk>
    4324:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    4327:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    432b:	75 07                	jne    4334 <morecore+0x34>
    return 0;
    432d:	b8 00 00 00 00       	mov    $0x0,%eax
    4332:	eb 22                	jmp    4356 <morecore+0x56>
  hp = (Header*)p;
    4334:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4337:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    433a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    433d:	8b 55 08             	mov    0x8(%ebp),%edx
    4340:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    4343:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4346:	83 c0 08             	add    $0x8,%eax
    4349:	89 04 24             	mov    %eax,(%esp)
    434c:	e8 ce fe ff ff       	call   421f <free>
  return freep;
    4351:	a1 e8 63 00 00       	mov    0x63e8,%eax
}
    4356:	c9                   	leave  
    4357:	c3                   	ret    

00004358 <malloc>:

void*
malloc(uint nbytes)
{
    4358:	55                   	push   %ebp
    4359:	89 e5                	mov    %esp,%ebp
    435b:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    435e:	8b 45 08             	mov    0x8(%ebp),%eax
    4361:	83 c0 07             	add    $0x7,%eax
    4364:	c1 e8 03             	shr    $0x3,%eax
    4367:	83 c0 01             	add    $0x1,%eax
    436a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    436d:	a1 e8 63 00 00       	mov    0x63e8,%eax
    4372:	89 45 f0             	mov    %eax,-0x10(%ebp)
    4375:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4379:	75 23                	jne    439e <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    437b:	c7 45 f0 e0 63 00 00 	movl   $0x63e0,-0x10(%ebp)
    4382:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4385:	a3 e8 63 00 00       	mov    %eax,0x63e8
    438a:	a1 e8 63 00 00       	mov    0x63e8,%eax
    438f:	a3 e0 63 00 00       	mov    %eax,0x63e0
    base.s.size = 0;
    4394:	c7 05 e4 63 00 00 00 	movl   $0x0,0x63e4
    439b:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    439e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    43a1:	8b 00                	mov    (%eax),%eax
    43a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    43a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43a9:	8b 40 04             	mov    0x4(%eax),%eax
    43ac:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    43af:	72 4d                	jb     43fe <malloc+0xa6>
      if(p->s.size == nunits)
    43b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43b4:	8b 40 04             	mov    0x4(%eax),%eax
    43b7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    43ba:	75 0c                	jne    43c8 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    43bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43bf:	8b 10                	mov    (%eax),%edx
    43c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    43c4:	89 10                	mov    %edx,(%eax)
    43c6:	eb 26                	jmp    43ee <malloc+0x96>
      else {
        p->s.size -= nunits;
    43c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43cb:	8b 40 04             	mov    0x4(%eax),%eax
    43ce:	2b 45 ec             	sub    -0x14(%ebp),%eax
    43d1:	89 c2                	mov    %eax,%edx
    43d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43d6:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    43d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43dc:	8b 40 04             	mov    0x4(%eax),%eax
    43df:	c1 e0 03             	shl    $0x3,%eax
    43e2:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    43e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
    43eb:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    43ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
    43f1:	a3 e8 63 00 00       	mov    %eax,0x63e8
      return (void*)(p + 1);
    43f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43f9:	83 c0 08             	add    $0x8,%eax
    43fc:	eb 38                	jmp    4436 <malloc+0xde>
    }
    if(p == freep)
    43fe:	a1 e8 63 00 00       	mov    0x63e8,%eax
    4403:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    4406:	75 1b                	jne    4423 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    4408:	8b 45 ec             	mov    -0x14(%ebp),%eax
    440b:	89 04 24             	mov    %eax,(%esp)
    440e:	e8 ed fe ff ff       	call   4300 <morecore>
    4413:	89 45 f4             	mov    %eax,-0xc(%ebp)
    4416:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    441a:	75 07                	jne    4423 <malloc+0xcb>
        return 0;
    441c:	b8 00 00 00 00       	mov    $0x0,%eax
    4421:	eb 13                	jmp    4436 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4423:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4426:	89 45 f0             	mov    %eax,-0x10(%ebp)
    4429:	8b 45 f4             	mov    -0xc(%ebp),%eax
    442c:	8b 00                	mov    (%eax),%eax
    442e:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    4431:	e9 70 ff ff ff       	jmp    43a6 <malloc+0x4e>
}
    4436:	c9                   	leave  
    4437:	c3                   	ret    
