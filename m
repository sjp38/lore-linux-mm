Received: from northrelay01.pok.ibm.com (northrelay01.pok.ibm.com [9.56.224.149])
	by e1.ny.us.ibm.com (8.12.2/8.12.2) with ESMTP id g6GHucg5033782
	for <linux-mm@kvack.org>; Tue, 16 Jul 2002 13:56:39 -0400
Received: from plars.austin.ibm.com (plars.austin.ibm.com [9.53.216.72])
	by northrelay01.pok.ibm.com (8.11.1m3/NCO/VER6.2) with ESMTP id g6GHuaD38058
	for <linux-mm@kvack.org>; Tue, 16 Jul 2002 13:56:36 -0400
Subject: [oops] 2.5.25+rmap+OptAwayPTE
From: Paul Larson <plars@austin.ibm.com>
Content-Type: multipart/mixed; boundary="=-QlvkcVwyIVZZLX4bSL4k"
Date: 16 Jul 2002 12:45:35 -0500
Message-Id: <1026841535.17328.39.camel@plars.austin.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-QlvkcVwyIVZZLX4bSL4k
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This is the output from the oops I was getting on the 8-way.  With
2.5.25 alone, same configuration it boots fine.  Add the patches and it
gives me this on boot.  I'll be happy to test any fixes for this or
additional patches.  Hope this is useful.

-Paul Larson





--=-QlvkcVwyIVZZLX4bSL4k
Content-Disposition: attachment; filename=rmap.oops
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; name=rmap.oops; charset=ISO-8859-1

ksymoops 2.4.5 on i686 2.4.18-mts.  Options used
     -V (default)
     -K (specified)
     -L (specified)
     -O (specified)
     -m System.map (specified)

15488MB HIGHMEM available.
WARNING: MP table in the EBDA can be UNSAFE, contact linux-smp@vger.kernel.=
org if you experience SMP problems!
cpu: 0, clocks: 99991, slice: 3030
cpu: 7, clocks: 99991, slice: 3030
cpu: 5, clocks: 99991, slice: 3030
cpu: 6, clocks: 99991, slice: 3030
cpu: 2, clocks: 99991, slice: 3030
cpu: 4, clocks: 99991, slice: 3030
cpu: 1, clocks: 99991, slice: 3030
cpu: 3, clocks: 99991, slice: 3030
ds: no socket drivers loaded!
kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    5
EIP:    0010:[<c0133268>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: cbffd130   ebx: c03cba9c   ecx: cbffd130   edx: fffe5638
esi: 00000058   edi: 00000000   ebp: c03cb92c   esp: f7537c1c
ds: 0018   es: 0018   ss: 0018
Stack: cbffd130 c0127d50 c03cb92c f753cfd0 bfffc000 00004000 f7530f20 00000=
000=20
       cbffd130 c03cba9c 00000058 00000106 c03cb92c c012aefc cbffd130 f7967=
280=20
       f7537c9c f7537c68 c012c730 f753de60 f7536000 00000000 f753de60 c0116=
fe8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c012c730>] [<c0116fe8>] [<c014505e>=
]=20
   [<c014521d>] [<c015ae86>] [<c011504b>] [<c013a60b>] [<c015aa20>] [<c0145=
8fc>]=20
   [<c0145ba6>] [<c0146d3e>] [<c0105ba0>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbffd130 <END_OF_CODE+bbd9894/????>
>>ebx; c03cba9c <mmu_gathers+295c/ff80>
>>ecx; cbffd130 <END_OF_CODE+bbd9894/????>
>>edx; fffe5638 <END_OF_CODE+3fbc1d9c/????>
>>ebp; c03cb92c <mmu_gathers+27ec/ff80>
>>esp; f7537c1c <END_OF_CODE+37114380/????>

Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c012c730 <file_read_actor+0/f0>
Trace; c0116fe8 <mmput+48/70>
Trace; c014505e <exec_mmap+14e/170>
Trace; c014521d <flush_old_exec+9d/2d0>
Trace; c015ae86 <load_elf_binary+466/ad0>
Trace; c011504b <schedule+33b/3a0>
Trace; c013a60b <do_page_cache_readahead+eb/110>
Trace; c015aa20 <load_elf_binary+0/ad0>
Trace; c01458fc <search_binary_handler+8c/1c0>
Trace; c0145ba6 <do_execve+176/1f0>
Trace; c0146d3e <getname+5e/a0>
Trace; c0105ba0 <sys_execve+30/60>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

 kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    5
EIP:    0010:[<c0133268>]    Not tainted
EFLAGS: 00010286
eax: cbffd810   ebx: c03cbd44   ecx: cbffd810   edx: fffe5ff0
esi: 00000102   edi: 00000000   ebp: c03cb92c   esp: f753bc1c
ds: 0018   es: 0018   ss: 0018
Stack: cbffd810 c0127d50 c03cb92c f753cfb0 c19a001c c0345d00 00000202 fffff=
fff=20
       cbffd810 c03cbd44 00000102 00000107 c03cb92c c012aefc cbffd810 f7967=
280=20
       f753bc9c f753bc68 c012c730 f753ddc0 f753a000 00000000 f753ddc0 c0116=
fe8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c012c730>] [<c0116fe8>] [<c014505e>=
]=20
   [<c014521d>] [<c015ae86>] [<c0167630>] [<c013a4af>] [<c013a60b>] [<c015a=
a20>]=20
   [<c01458fc>] [<c0145ba6>] [<c0146d3e>] [<c0105ba0>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbffd810 <END_OF_CODE+bbd9f74/????>
>>ebx; c03cbd44 <mmu_gathers+2c04/ff80>
>>ecx; cbffd810 <END_OF_CODE+bbd9f74/????>
>>edx; fffe5ff0 <END_OF_CODE+3fbc2754/????>
>>ebp; c03cb92c <mmu_gathers+27ec/ff80>
>>esp; f753bc1c <END_OF_CODE+37118380/????>

Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c012c730 <file_read_actor+0/f0>
Trace; c0116fe8 <mmput+48/70>
Trace; c014505e <exec_mmap+14e/170>
Trace; c014521d <flush_old_exec+9d/2d0>
Trace; c015ae86 <load_elf_binary+466/ad0>
Trace; c0167630 <ext3_get_block+0/70>
Trace; c013a4af <read_pages+1f/90>
Trace; c013a60b <do_page_cache_readahead+eb/110>
Trace; c015aa20 <load_elf_binary+0/ad0>
Trace; c01458fc <search_binary_handler+8c/1c0>
Trace; c0145ba6 <do_execve+176/1f0>
Trace; c0146d3e <getname+5e/a0>
Trace; c0105ba0 <sys_execve+30/60>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

              Welcome to kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    5
EIP:    0010:[<c0133268>]    Not tainted
EFLAGS: 00010286
eax: cbffd600   ebx: c03cbab8   ecx: cbffd600   edx: fffe5678
esi: 0000005f   edi: 00000000   ebp: c03cb92c   esp: f7525c1c
ds: 0018   es: 0018   ss: 0018
Stack: cbffd600 c0127d50 c03cb92c f753cff0 c19a001c c0345d00 00000202 fffff=
fff=20
       cbffd600 c03cbab8 0000005f 0000011f c03cb92c c012aefc cbffd600 f7967=
280=20
       f7525c9c f7525c68 c012c730 f753df00 f7524000 00000000 f753df00 c0116=
fe8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c012c730>] [<c0116fe8>] [<c014505e>=
]=20
   [<c014521d>] [<c015ae86>] [<c0210c8e>] [<c0210dda>] [<c013a60b>] [<c015a=
a20>]=20
   [<c01458fc>] [<c0145ba6>] [<c0146d3e>] [<c0105ba0>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbffd600 <END_OF_CODE+bbd9d64/????>
>>ebx; c03cbab8 <mmu_gathers+2978/ff80>
>>ecx; cbffd600 <END_OF_CODE+bbd9d64/????>
>>edx; fffe5678 <END_OF_CODE+3fbc1ddc/????>
>>ebp; c03cb92c <mmu_gathers+27ec/ff80>
>>esp; f7525c1c <END_OF_CODE+37102380/????>

Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c012c730 <file_read_actor+0/f0>
Trace; c0116fe8 <mmput+48/70>
Trace; c014505e <exec_mmap+14e/170>
Trace; c014521d <flush_old_exec+9d/2d0>
Trace; c015ae86 <load_elf_binary+466/ad0>
Trace; c0210c8e <generic_unplug_device+6e/80>
Trace; c0210dda <blk_run_queues+7a/90>
Trace; c013a60b <do_page_cache_readahead+eb/110>
Trace; c015aa20 <load_elf_binary+0/ad0>
Trace; c01458fc <search_binary_handler+8c/1c0>
Trace; c0145ba6 <do_execve+176/1f0>
Trace; c0146d3e <getname+5e/a0>
Trace; c0105ba0 <sys_execve+30/60>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    0
EIP:  modprobe: modprobe: Can't open dependencies file /lib/modules/2.5.25/=
modules.dep (No such file or directory)
da5E.F L PArGiS:or i0t0y0:1-0128 e6
i:ul 16 10:36:37 C Ad0d0i00n0g0 20804 8  2e48dki :s 0wa0p0 00on0 0/0d e  ve=
/sbpda: 7c.0  3cP9ri14o0ri t  ye:s-3p:  efx7t5en21tsc1:1c
9140 f
 f7c40f1c1f6f2e0 8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c012c730>] [<c0116fe8>] [<c014505e>=
]=20
   [<c014521d>] [<c015ae86>] [<c011504b>] [<c013a60b>] [<c015aa20>] [<c0145=
8fc>]=20
   [<c0145ba6>] [<c0146d3e>] [<c0105ba0>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c012c730 <file_read_actor+0/f0>
Trace; c0116fe8 <mmput+48/70>
Trace; c014505e <exec_mmap+14e/170>
Trace; c014521d <flush_old_exec+9d/2d0>
Trace; c015ae86 <load_elf_binary+466/ad0>
Trace; c011504b <schedule+33b/3a0>
Trace; c013a60b <do_page_cache_readahead+eb/110>
Trace; c015aa20 <load_elf_binary+0/ad0>
Trace; c01458fc <search_binary_handler+8c/1c0>
Trace; c0145ba6 <do_execve+176/1f0>
Trace; c0146d3e <getname+5e/a0>
Trace; c0105ba0 <sys_execve+30/60>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>
   0:   0f 0b                     ud2a  =20
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

 kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    1
EIP:    0010:[<c0133268>]    Not tainted
EFLAGS: 00010286
eax: cbff9140   ebx: c03c996c   ecx: cbff9140   edx: fffc1278
esi: 00000008   edi: 00000000   ebp: c03c993c   esp: f7525f10
ds: 0018   es: 0018   ss: 0018
Stack: cbff9140 c0127d50 c03c993c f753cf90 bfffb000 00005000 f7526b40 00000=
000=20
       cbff9140 c03c996c 00000008 0000009a c03c993c c012aefc cbff9140 f7535=
940=20
       c011b1cf 00000282 f7535940 f753dd20 00000002 f79186e0 00000000 c0116=
fe8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c011b1cf>] [<c0116fe8>] [<c011bde4>=
]=20
   [<c0120c20>] [<c01150b0>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbff9140 <END_OF_CODE+bbd58a4/????>
>>ebx; c03c996c <mmu_gathers+82c/ff80>
>>ecx; cbff9140 <END_OF_CODE+bbd58a4/????>
>>edx; fffc1278 <END_OF_CODE+3fb9d9dc/????>
>>ebp; c03c993c <mmu_gathers+7fc/ff80>
>>esp; f7525f10 <END_OF_CODE+37102674/????>

Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c011b1cf <release_task+9f/b0>
Trace; c0116fe8 <mmput+48/70>
Trace; c011bde4 <do_exit+c4/2a0>
Trace; c0120c20 <process_timeout+0/10>
Trace; c01150b0 <default_wake_function+0/40>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    0
EIP:    0010:[<c0133268>]    Not tainted
EFLAGS: 00010282
eax: cbfe36ec   ebx: c03c92c0   ecx: cbfe36ec   edx: fffc1638
esi: 0000005c   edi: 00000000   ebp: c03c9140   esp: f74c5c1c
ds: 0018   es: 0018   ss: 0018
Stack: cbfe36ec c0127d50 c03c9140 f753cf10 bfffc000 00004000 f75261e0 00000=
000=20
       cbfe36ec c03c92c0 0000005c 00000128 c03c9140 c012aefc cbfe36ec f7967=
280=20
       f74c5c9c f74c5c68 c012c730 f753daa0 f74c4000 00000000 f753daa0 c0116=
fe8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c012c730>] [<c0116fe8>] [<c014505e>=
]=20
   [<c014521d>] [<c015ae86>] [<c0167630>] [<c013a4af>] [<c013a60b>] [<c015a=
a20>]=20
   [<c01458fc>] [<c0145ba6>] [<c0146d3e>] [<c0105ba0>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbfe36ec <END_OF_CODE+bbbfe50/????>
>>ebx; c03c92c0 <mmu_gathers+180/ff80>
>>ecx; cbfe36ec <END_OF_CODE+bbbfe50/????>
>>edx; fffc1638 <END_OF_CODE+3fb9dd9c/????>
>>ebp; c03c9140 <mmu_gathers+0/ff80>
>>esp; f74c5c1c <END_OF_CODE+370a2380/????>

Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c012c730 <file_read_actor+0/f0>
Trace; c0116fe8 <mmput+48/70>
Trace; c014505e <exec_mmap+14e/170>
Trace; c014521d <flush_old_exec+9d/2d0>
Trace; c015ae86 <load_elf_binary+466/ad0>
Trace; c0167630 <ext3_get_block+0/70>
Trace; c013a4af <read_pages+1f/90>
Trace; c013a60b <do_page_cache_readahead+eb/110>
Trace; c015aa20 <load_elf_binary+0/ad0>
Trace; c01458fc <search_binary_handler+8c/1c0>
Trace; c0145ba6 <do_execve+176/1f0>
Trace; c0146d3e <getname+5e/a0>
Trace; c0105ba0 <sys_execve+30/60>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

 kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    5
EIP:    0010:[<c0133268>]    Not tainted
EFLAGS: 00010286
eax: cbfe3c98   ebx: c03cbab4   ecx: cbfe3c98   edx: fffc1648
esi: 0000005e   edi: 00000000   ebp: c03cb92c   esp: f74cbf10
ds: 0018   es: 0018   ss: 0018
Stack: cbfe3c98 c0127d50 c03cb92c f753cf30 c19a001c c0345d00 00000207 fffff=
fff=20
       cbfe3c98 c03cbab4 0000005e 00000128 c03cb92c c012aefc cbfe3c98 00000=
002=20
       c011b1cf 00000282 00000000 f753db40 00000002 f79186e0 00008b00 c0116=
fe8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c011b1cf>] [<c0116fe8>] [<c011bde4>=
]=20
   [<c01064ce>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbfe3c98 <END_OF_CODE+bbc03fc/????>
>>ebx; c03cbab4 <mmu_gathers+2974/ff80>
>>ecx; cbfe3c98 <END_OF_CODE+bbc03fc/????>
>>edx; fffc1648 <END_OF_CODE+3fb9ddac/????>
>>ebp; c03cb92c <mmu_gathers+27ec/ff80>
>>esp; f74cbf10 <END_OF_CODE+370a8674/????>

Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c011b1cf <release_task+9f/b0>
Trace; c0116fe8 <mmput+48/70>
Trace; c011bde4 <do_exit+c4/2a0>
Trace; c01064ce <sys_sigreturn+fe/130>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

 kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    0
EIP:    0010:[<c0133268>]    Not tainted
EFLAGS: 00010282
eax: cbfe2e54   ebx: c03c92c0   ecx: cbfe2e54   edx: fffc1638
esi: 0000005c   edi: 00000000   ebp: c03c9140   esp: f74a3c1c
ds: 0018   es: 0018   ss: 0018
Stack: cbfe2e54 c0127d50 c03c9140 f753cf70 bfffc000 00004000 f74a44a0 00000=
000=20
       cbfe2e54 c03c92c0 0000005c 00000128 c03c9140 c012aefc cbfe2e54 f7967=
280=20
       f74a3c9c f74a3c68 c012c730 f753dc80 f74a2000 00000000 f753dc80 c0116=
fe8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c012c730>] [<c0116fe8>] [<c014505e>=
]=20
   [<c014521d>] [<c015ae86>] [<c0167630>] [<c013a4af>] [<c013a60b>] [<c015a=
a20>]=20
   [<c01458fc>] [<c0145ba6>] [<c0146d3e>] [<c0105ba0>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbfe2e54 <END_OF_CODE+bbbf5b8/????>
>>ebx; c03c92c0 <mmu_gathers+180/ff80>
>>ecx; cbfe2e54 <END_OF_CODE+bbbf5b8/????>
>>edx; fffc1638 <END_OF_CODE+3fb9dd9c/????>
>>ebp; c03c9140 <mmu_gathers+0/ff80>
>>esp; f74a3c1c <END_OF_CODE+37080380/????>

Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c012c730 <file_read_actor+0/f0>
Trace; c0116fe8 <mmput+48/70>
Trace; c014505e <exec_mmap+14e/170>
Trace; c014521d <flush_old_exec+9d/2d0>
Trace; c015ae86 <load_elf_binary+466/ad0>
Trace; c0167630 <ext3_get_block+0/70>
Trace; c013a4af <read_pages+1f/90>
Trace; c013a60b <do_page_cache_readahead+eb/110>
Trace; c015aa20 <load_elf_binary+0/ad0>
Trace; c01458fc <search_binary_handler+8c/1c0>
Trace; c0145ba6 <do_execve+176/1f0>
Trace; c0146d3e <getname+5e/a0>
Trace; c0105ba0 <sys_execve+30/60>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

 kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    5
EIP:    0010:[<c0133268>]    Not tainted
EFLAGS: 00010286
eax: cbfe30e8   ebx: c03cbab4   ecx: cbfe30e8   edx: fffc1648
esi: 0000005e   edi: 00000000   ebp: c03cb92c   esp: f74cbf10
ds: 0018   es: 0018   ss: 0018
Stack: cbfe30e8 c0127d50 c03cb92c f753cf50 c19a001c c0345d00 00000203 fffff=
fff=20
       cbfe30e8 c03cbab4 0000005e 00000128 c03cb92c c012aefc cbfe30e8 00000=
000=20
       c011b1cf 00000282 00000000 f753dbe0 00000002 f79186e0 00008b00 c0116=
fe8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c011b1cf>] [<c0116fe8>] [<c011bde4>=
]=20
   [<c01064ce>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbfe30e8 <END_OF_CODE+bbbf84c/????>
>>ebx; c03cbab4 <mmu_gathers+2974/ff80>
>>ecx; cbfe30e8 <END_OF_CODE+bbbf84c/????>
>>edx; fffc1648 <END_OF_CODE+3fb9ddac/????>
>>ebp; c03cb92c <mmu_gathers+27ec/ff80>
>>esp; f74cbf10 <END_OF_CODE+370a8674/????>

Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c011b1cf <release_task+9f/b0>
Trace; c0116fe8 <mmput+48/70>
Trace; c011bde4 <do_exit+c4/2a0>
Trace; c01064ce <sys_sigreturn+fe/130>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

 kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    0
EIP:    0010:[<c0133268>]    Not tainted
EFLAGS: 00010282
eax: cbfe2220   ebx: c03c92c0   ecx: cbfe2220   edx: fffc1638
esi: 0000005c   edi: 00000000   ebp: c03c9140   esp: f7499c1c
ds: 0018   es: 0018   ss: 0018
Stack: cbfe2220 c0127d50 c03c9140 f753ceb0 bfffc000 00004000 f74ad3c0 00000=
000=20
       cbfe2220 c03c92c0 0000005c 00000128 c03c9140 c012aefc cbfe2220 f7967=
280=20
       f7499c9c f7499c68 c012c730 f753d8c0 f7498000 00000000 f753d8c0 c0116=
fe8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c012c730>] [<c0116fe8>] [<c014505e>=
]=20
   [<c014521d>] [<c015ae86>] [<c0210c8e>] [<c0210dda>] [<c013a60b>] [<c015a=
a20>]=20
   [<c01458fc>] [<c0145ba6>] [<c0146d3e>] [<c0105ba0>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbfe2220 <END_OF_CODE+bbbe984/????>
>>ebx; c03c92c0 <mmu_gathers+180/ff80>
>>ecx; cbfe2220 <END_OF_CODE+bbbe984/????>
>>edx; fffc1638 <END_OF_CODE+3fb9dd9c/????>
>>ebp; c03c9140 <mmu_gathers+0/ff80>
>>esp; f7499c1c <END_OF_CODE+37076380/????>

Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c012c730 <file_read_actor+0/f0>
Trace; c0116fe8 <mmput+48/70>
Trace; c014505e <exec_mmap+14e/170>
Trace; c014521d <flush_old_exec+9d/2d0>
Trace; c015ae86 <load_elf_binary+466/ad0>
Trace; c0210c8e <generic_unplug_device+6e/80>
Trace; c0210dda <blk_run_queues+7a/90>
Trace; c013a60b <do_page_cache_readahead+eb/110>
Trace; c015aa20 <load_elf_binary+0/ad0>
Trace; c01458fc <search_binary_handler+8c/1c0>
Trace; c0145ba6 <do_execve+176/1f0>
Trace; c0146d3e <getname+5e/a0>
Trace; c0105ba0 <sys_execve+30/60>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

 kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    5
EIP:    0010:[<c0133268>]    Not tainted
EFLAGS: 00010286
eax: cbfe2698   ebx: c03cbab4   ecx: cbfe2698   edx: fffc1648
esi: 0000005e   edi: 00000000   ebp: c03cb92c   esp: f74cbf10
ds: 0018   es: 0018   ss: 0018
Stack: cbfe2698 c0127d50 c03cb92c f753cef0 c19a001c c0345d00 00000207 fffff=
fff=20
       cbfe2698 c03cbab4 0000005e 00000128 c03cb92c c012aefc cbfe2698 00000=
001=20
       c011b1cf 00000282 00000000 f753da00 00000002 f79186e0 00008b00 c0116=
fe8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c011b1cf>] [<c0116fe8>] [<c011bde4>=
]=20
   [<c01064ce>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbfe2698 <END_OF_CODE+bbbedfc/????>
>>ebx; c03cbab4 <mmu_gathers+2974/ff80>
>>ecx; cbfe2698 <END_OF_CODE+bbbedfc/????>
>>edx; fffc1648 <END_OF_CODE+3fb9ddac/????>
>>ebp; c03cb92c <mmu_gathers+27ec/ff80>
>>esp; f74cbf10 <END_OF_CODE+370a8674/????>

Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c011b1cf <release_task+9f/b0>
Trace; c0116fe8 <mmput+48/70>
Trace; c011bde4 <do_exit+c4/2a0>
Trace; c01064ce <sys_sigreturn+fe/130>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    1
EIP:    0010:[<c0133268>]    Not tainted
EFLAGS: 00010282
eax: cbff937c   ebx: c03c9b7c   ecx: cbff937c   edx: fffeeff8
esi: 0000008c   edi: 00000000   ebp: c03c993c   esp: f748dc1c
ds: 0018   es: 0018   ss: 0018
Stack: cbff937c 003c8000 c100001c cbfdefc4 c19a001c c0345d0c 00000206 fffff=
ffe=20
       cbff937c c03c9b7c 0000008c 00000090 c03c993c c012aefc cbff937c f7967=
280=20
       f748dc9c f748dc68 c012c730 f7956bc0 f748c000 00000000 f7956bc0 c0116=
fe8=20
Call Trace: [<c012aefc>] [<c012c730>] [<c0116fe8>] [<c014505e>] [<c014521d>=
]=20
   [<c015ae86>] [<c0167630>] [<c013a4af>] [<c013a60b>] [<c015aa20>] [<c0145=
8fc>]=20
   [<c0145ba6>] [<c0146d3e>] [<c0105ba0>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbff937c <END_OF_CODE+bbd5ae0/????>
>>ebx; c03c9b7c <mmu_gathers+a3c/ff80>
>>ecx; cbff937c <END_OF_CODE+bbd5ae0/????>
>>edx; fffeeff8 <END_OF_CODE+3fbcb75c/????>
>>ebp; c03c993c <mmu_gathers+7fc/ff80>
>>esp; f748dc1c <END_OF_CODE+3706a380/????>

Trace; c012aefc <exit_mmap+19c/220>
Trace; c012c730 <file_read_actor+0/f0>
Trace; c0116fe8 <mmput+48/70>
Trace; c014505e <exec_mmap+14e/170>
Trace; c014521d <flush_old_exec+9d/2d0>
Trace; c015ae86 <load_elf_binary+466/ad0>
Trace; c0167630 <ext3_get_block+0/70>
Trace; c013a4af <read_pages+1f/90>
Trace; c013a60b <do_page_cache_readahead+eb/110>
Trace; c015aa20 <load_elf_binary+0/ad0>
Trace; c01458fc <search_binary_handler+8c/1c0>
Trace; c0145ba6 <do_execve+176/1f0>
Trace; c0146d3e <getname+5e/a0>
Trace; c0105ba0 <sys_execve+30/60>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)

 kernel BUG at page_alloc.c:95!
invalid operand: 0000
CPU:    6
EIP:    0010:[<c0133268>]    Not tainted
EFLAGS: 00010286
eax: cbfe12d4   ebx: c03cc158   ecx: cbfe12d4   edx: fffc1278
esi: 00000008   edi: 00000000   ebp: c03cc128   esp: f74cbf10
ds: 0018   es: 0018   ss: 0018
Stack: cbfe12d4 c0127d50 c03cc128 f753ced0 bfffb000 00005000 f74add80 00000=
000=20
       cbfe12d4 c03cc158 00000008 000000a6 c03cc128 c012aefc cbfe12d4 f7535=
300=20
       c011b1cf 00000282 f7535300 f753d960 00000002 f79186e0 00000000 c0116=
fe8=20
Call Trace: [<c0127d50>] [<c012aefc>] [<c011b1cf>] [<c0116fe8>] [<c011bde4>=
]=20
   [<c0120c20>] [<c01150b0>] [<c0106fcb>]=20
Code: 0f 0b 5f 00 06 6f 2e c0 8b 0c 24 ba 04 00 00 00 8b 41 14 83=20


>>EIP; c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D

>>eax; cbfe12d4 <END_OF_CODE+bbbda38/????>
>>ebx; c03cc158 <mmu_gathers+3018/ff80>
>>ecx; cbfe12d4 <END_OF_CODE+bbbda38/????>
>>edx; fffc1278 <END_OF_CODE+3fb9d9dc/????>
>>ebp; c03cc128 <mmu_gathers+2fe8/ff80>
>>esp; f74cbf10 <END_OF_CODE+370a8674/????>

Trace; c0127d50 <unmap_page_range+40/60>
Trace; c012aefc <exit_mmap+19c/220>
Trace; c011b1cf <release_task+9f/b0>
Trace; c0116fe8 <mmput+48/70>
Trace; c011bde4 <do_exit+c4/2a0>
Trace; c0120c20 <process_timeout+0/10>
Trace; c01150b0 <default_wake_function+0/40>
Trace; c0106fcb <syscall_call+7/b>

Code;  c0133268 <__free_pages_ok+88/310>
00000000 <_EIP>:
Code;  c0133268 <__free_pages_ok+88/310>   <=3D=3D=3D=3D=3D
   0:   0f 0b                     ud2a      <=3D=3D=3D=3D=3D
Code;  c013326a <__free_pages_ok+8a/310>
   2:   5f                        pop    %edi
Code;  c013326b <__free_pages_ok+8b/310>
   3:   00 06                     add    %al,(%esi)
Code;  c013326d <__free_pages_ok+8d/310>
   5:   6f                        outsl  %ds:(%esi),(%dx)
Code;  c013326e <__free_pages_ok+8e/310>
   6:   2e c0 8b 0c 24 ba 04      rorb   $0x0,%cs:0x4ba240c(%ebx)
Code;  c0133275 <__free_pages_ok+95/310>
   d:   00=20
Code;  c0133276 <__free_pages_ok+96/310>
   e:   00 00                     add    %al,(%eax)
Code;  c0133278 <__free_pages_ok+98/310>
  10:   8b 41 14                  mov    0x14(%ecx),%eax
Code;  c013327b <__free_pages_ok+9b/310>
  13:   83 00 00                  addl   $0x0,(%eax)


--=-QlvkcVwyIVZZLX4bSL4k--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
