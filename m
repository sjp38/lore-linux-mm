Subject: Re: [rtf] [patch] 2.3.99-pre6-3 overly swappy
References: <Pine.LNX.4.21.0004202247170.9178-100000@devserv.devel.redhat.com> <yttya67uyv9.fsf@vexeta.dc.fi.udc.es>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "21 Apr 2000 19:50:50 +0200"
Date: 22 Apr 2000 20:14:31 +0200
Message-ID: <yttzoqm0zqw.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

>>>>> "juan" == Juan J Quintela <quintela@fi.udc.es> writes:

juan> Hi,
juan> using only Ben patch, I have got the following Oops, the Oops
juan> happens just after a call to BUG():
juan> page_alloc.c::__free_pages_ok(): 110
                        
juan> if (PageLocked(page))
juan> BUG();  <- This one


Just one reboot later, using the same program as a test, but with the
patch from Rik, nor the Ben one, I get another
BUG in the same function, this time
page_alloc.c::__free_pages_ok(): 104
	if (page->mapping)
		BUG(); <- This one.

This time again, the machine was in trashing (heavy trashing).

Following the BUG(), two Oops that are attached.

As always, if you need more information or anything, let me know.

Later, Juan.

PS. Somebody tolds me that all the bugs could be caused by Bad Memory,
    21 hours and 18 passes of memtest86 find not a single error.


ksymoops 2.3.4 on i686 2.3.99-pre6r3.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.3.99-pre6r3/ (default)
     -m /boot/System.map-2.3.99-pre6r3 (default)

invalid operand: 0000
CPU:    0
EIP:    0010:[<c0129b89>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00013286
eax: 00000020   ebx: c1000170   ecx: 0000003b   edx: cf4a0480
esi: c1000170   edi: c33a7674   ebp: 00000000   esp: c14a1ef4
ds: 0018   es: 0018   ss: 0018
Process kswapd (pid: 2, stackpage=c14a1000)
Stack: c01dc3b0 c01dc67c 00000068 7419e000 c1000170 c33a7674 c32f5800 00aeb900 
       0049a200 c1408470 c6b60438 c0129243 c012927b 7419e000 74400000 c33a7674 
       74400000 00aeb900 c01294bf c32f5800 7419d000 c33a7674 00000004 c32f5800 
Call Trace: [<c01dc3b0>] [<c01dc67c>] [<c0129243>] [<c012927b>] [<c01294bf>] [<c012956b>] [<c012965e>] 
       [<c012972a>] [<c01297b5>] [<c0108df8>] 
Code: 0f 0b 83 c4 0c 89 f6 89 d8 2b 05 ec c2 21 c0 69 c0 39 8e e3 

>>EIP; c0129b89 <__free_pages_ok+49/2a0>   <=====
Trace; c01dc3b0 <tvecs+3644/1d794>
Trace; c01dc67c <tvecs+3910/1d794>
Trace; c0129243 <try_to_swap_out+83/1e0>
Trace; c012927b <try_to_swap_out+bb/1e0>
Trace; c01294bf <swap_out_vma+11f/190>
Trace; c012956b <swap_out_mm+3b/70>
Trace; c012965e <swap_out+be/110>
Trace; c012972a <do_try_to_free_pages+7a/90>
Trace; c01297b5 <kswapd+75/f0>
Trace; c0108df8 <kernel_thread+28/40>
Code;  c0129b89 <__free_pages_ok+49/2a0>
00000000 <_EIP>:
Code;  c0129b89 <__free_pages_ok+49/2a0>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c0129b8b <__free_pages_ok+4b/2a0>
   2:   83 c4 0c                  add    $0xc,%esp
Code;  c0129b8e <__free_pages_ok+4e/2a0>
   5:   89 f6                     mov    %esi,%esi
Code;  c0129b90 <__free_pages_ok+50/2a0>
   7:   89 d8                     mov    %ebx,%eax
Code;  c0129b92 <__free_pages_ok+52/2a0>
   9:   2b 05 ec c2 21 c0         sub    0xc021c2ec,%eax
Code;  c0129b98 <__free_pages_ok+58/2a0>
   f:   69 c0 39 8e e3 00         imul   $0xe38e39,%eax,%eax


and

ksymoops 2.3.4 on i686 2.3.99-pre6r3.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.3.99-pre6r3/ (default)
     -m /boot/System.map-2.3.99-pre6r3 (default)

invalid operand: 0000
CPU:    0
EIP:    0010:[<c0129b89>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010286
eax: 00000020   ebx: c10001b8   ecx: 00000022   edx: 00000000
esi: 00000058   edi: c8e31748   ebp: 00000000   esp: cac61ef4
ds: 0018   es: 0018   ss: 0018
Process test004 (pid: 2642, stackpage=cac61000)
Stack: c01dc3b0 c01dc67c 00000068 c10001b8 00000058 c8e31748 c365eea0 c1048008 
       c021c6b8 00000213 ffffffff 00400000 c012a513 00400000 00000058 c011f261 
       c10001b8 c32f5d80 7021a000 ce02fd80 08953000 c8e31748 74800000 00000000 
Call Trace: [<c01dc3b0>] [<c01dc67c>] [<c012a513>] [<c011f261>] [<c0121858>] [<c0114645>] [<c0119f81>] 
       [<c011a21e>] [<c010af4c>] 
Code: 0f 0b 83 c4 0c 89 f6 89 d8 2b 05 ec c2 21 c0 69 c0 39 8e e3 

>>EIP; c0129b89 <__free_pages_ok+49/2a0>   <=====
Trace; c01dc3b0 <tvecs+3644/1d794>
Trace; c01dc67c <tvecs+3910/1d794>
Trace; c012a513 <free_page_and_swap_cache+83/90>
Trace; c011f261 <zap_page_range+171/1f0>
Trace; c0121858 <exit_mmap+b8/120>
Trace; c0114645 <mmput+15/30>
Trace; c0119f81 <do_exit+c1/350>
Trace; c011a21e <sys_exit+e/10>
Trace; c010af4c <system_call+34/38>
Code;  c0129b89 <__free_pages_ok+49/2a0>
00000000 <_EIP>:
Code;  c0129b89 <__free_pages_ok+49/2a0>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c0129b8b <__free_pages_ok+4b/2a0>
   2:   83 c4 0c                  add    $0xc,%esp
Code;  c0129b8e <__free_pages_ok+4e/2a0>
   5:   89 f6                     mov    %esi,%esi
Code;  c0129b90 <__free_pages_ok+50/2a0>
   7:   89 d8                     mov    %ebx,%eax
Code;  c0129b92 <__free_pages_ok+52/2a0>
   9:   2b 05 ec c2 21 c0         sub    0xc021c2ec,%eax
Code;  c0129b98 <__free_pages_ok+58/2a0>
   f:   69 c0 39 8e e3 00         imul   $0xe38e39,%eax,%eax








-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
