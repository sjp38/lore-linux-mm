Received: from jpaana by kalahari.s2.org with local (Exim 3.16 #1 (Debian))
	id 13Vf6T-0000u9-00
	for <linux-mm@kvack.org>; Sun, 03 Sep 2000 22:06:53 +0300
Subject: Oopses as discussed on irc
From: Jarno Paananen <jpaana@s2.org>
Date: 03 Sep 2000 22:06:53 +0300
Message-ID: <m3zolpb8he.fsf@kalahari.s2.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here are the ksymoops logs, first oops is kernel BUG at
filemap.c:67! and the second one kernel BUG at page_alloc.c:91!

// Jarno

ksymoops 2.3.4 on i686 2.4.0-test8.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.4.0-test8/ (default)
     -m /boot/System.map-2.4.0-test8 (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

Error (regular_file): read_system_map stat /boot/System.map-2.4.0-test8 failed
invalid operand: 0000
CPU:    0
EIP:    0010:[<c012205c>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: 0000001c   ebx: 00000000   ecx: c020fb8c   edx: 00000001
esi: c134b7f0   edi: cc7dd89c   ebp: 0000002e   esp: cca07e3c
ds: 0018   es: 0018   ss: 0018
Process WindowMaker (pid: 452, stackpage=cca07000)
Stack: c01df8a9 c01dfa68 00000043 00000000 c01226ed c134b7f0 c14aa5d0 00000000 
       c134b7f0 0000002e cc7dd89c c01227f3 c134b7f0 cc7dd89c 0000002e c14aa5d0 
       c01238b0 00000000 00000028 ccf864c0 c14aa5d0 00000001 c01239ec ccf864c0 
Call Trace: [<c01df8a9>] [<c01dfa68>] [<c01226ed>] [<c01227f3>] [<c01238b0>] [<c01239ec>] [<c01238b0>] 
       [<c0120a2f>] [<c0120b90>] [<c01117ef>] [<c0121662>] [<c0121a14>] [<c0121a59>] [<c010a5e4>] 
Code: 0f 0b 83 c4 0c 5b c3 8d b6 00 00 00 00 8d bc 27 00 00 00 00 

>>EIP; c012205c <do_brk+5ec/680>   <=====
Trace; c01df8a9 <sprintf+ac09/244a5>
Trace; c01dfa68 <sprintf+adc8/244a5>
Trace; c01226ed <generic_buffer_fdatasync+2ed/450>
Trace; c01227f3 <generic_buffer_fdatasync+3f3/450>
Trace; c01238b0 <filemap_nopage+0/340>
Trace; c01239ec <filemap_nopage+13c/340>
Trace; c01238b0 <filemap_nopage+0/340>
Trace; c0120a2f <vmtruncate+45f/7c0>
Trace; c0120b90 <vmtruncate+5c0/7c0>
Trace; c01117ef <__verify_write+22f/7c0>
Trace; c0121662 <find_vma+262/3b0>
Trace; c0121a14 <do_munmap+264/2c0>
Trace; c0121a59 <do_munmap+2a9/2c0>
Trace; c010a5e4 <__rwsem_wake+11d4/2410>
Code;  c012205c <do_brk+5ec/680>
00000000 <_EIP>:
Code;  c012205c <do_brk+5ec/680>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c012205e <do_brk+5ee/680>
   2:   83 c4 0c                  add    $0xc,%esp
Code;  c0122061 <do_brk+5f1/680>
   5:   5b                        pop    %ebx
Code;  c0122062 <do_brk+5f2/680>
   6:   c3                        ret    
Code;  c0122063 <do_brk+5f3/680>
   7:   8d b6 00 00 00 00         lea    0x0(%esi),%esi
Code;  c0122069 <do_brk+5f9/680>
   d:   8d bc 27 00 00 00 00      lea    0x0(%edi,1),%edi

invalid operand: 0000
CPU:    0
EIP:    0010:[<c01297b9>]
EFLAGS: 00013286
eax: 0000001f   ebx: c134b6e0   ecx: c020fb8c   edx: 00000001
esi: 000001c6   edi: cd1fb084   ebp: 00000000   esp: cc989f00
ds: 0018   es: 0018   ss: 0018
Process X (pid: 512, stackpage=cc989000)
Stack: c01e0e89 c01e1057 0000005b c134b6e0 000001c6 cd1fb084 cd1f88e8 c1044010 
       c0210c00 00003217 ffffffff 00005b3a c012a113 c012a540 005d8000 000001c6 
       c011f8fa c134b6e0 cc6d5a40 081d8000 ce85ef00 0030b000 cd1fb084 085d8000 
Call Trace: [<c01e0e89>] [<c01e1057>] [<c012a113>] [<c012a540>] [<c011f8fa>] [<c0121cf8>] [<c0116945>] 
       [<c011a462>] [<c011a5fe>] [<c010a4cf>] 
Code: 0f 0b 83 c4 0c 89 f6 89 d8 2b 05 20 08 21 c0 69 c0 f1 f0 f0 

>>EIP; c01297b9 <kmem_find_general_cachep+2089/25c0>   <=====
Trace; c01e0e89 <sprintf+c1e9/244a5>
Trace; c01e1057 <sprintf+c3b7/244a5>
Trace; c012a113 <__free_pages+13/20>
Trace; c012a540 <free_pages+420/1b10>
Trace; c011f8fa <request_module+5ba/6a0>
Trace; c0121cf8 <do_brk+288/680>
Trace; c0116945 <remove_wait_queue+275/1150>
Trace; c011a462 <exit_mm+322/cd0>
Trace; c011a5fe <exit_mm+4be/cd0>
Trace; c010a4cf <__rwsem_wake+10bf/2410>
Code;  c01297b9 <kmem_find_general_cachep+2089/25c0>
00000000 <_EIP>:
Code;  c01297b9 <kmem_find_general_cachep+2089/25c0>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c01297bb <kmem_find_general_cachep+208b/25c0>
   2:   83 c4 0c                  add    $0xc,%esp
Code;  c01297be <kmem_find_general_cachep+208e/25c0>
   5:   89 f6                     mov    %esi,%esi
Code;  c01297c0 <kmem_find_general_cachep+2090/25c0>
   7:   89 d8                     mov    %ebx,%eax
Code;  c01297c2 <kmem_find_general_cachep+2092/25c0>
   9:   2b 05 20 08 21 c0         sub    0xc0210820,%eax
Code;  c01297c8 <kmem_find_general_cachep+2098/25c0>
   f:   69 c0 f1 f0 f0 00         imul   $0xf0f0f1,%eax,%eax


1 warning and 1 error issued.  Results may not be reliable.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
