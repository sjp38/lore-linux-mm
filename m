Subject: Re: Memory problems with 2.3.99-pre6-7 (now pre6-final)
References: <ytt3do7h1yt.fsf@vexeta.dc.fi.udc.es>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "27 Apr 2000 19:45:46 +0200"
Date: 28 Apr 2000 00:34:32 +0200
Message-ID: <yttg0s7cgw7.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi
        I have obtained the same BUG() in page_alloc().
juan> kernel BUG at page_alloc.c:104!
juan> that is: 
juan> if (page->mapping)
juan> BUG();
juan> The actual Oops is:

I obtained three in one row, using like test:
  while(true); do time ./mmap002; done

mmap002 is the test that is in

http://carpanta.dc.fi.udc.es/~quintela/memtest/memtest-0.0.2.tar.gz

(the first version has a bug in mmap002 that don't work to find that bug)


The Oops is:

invalid operand: 0000
CPU:    0
EIP:    0010:[<c0125d09>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: 00000020   ebx: c1000170   ecx: 00000010   edx: 00000000
esi: c1000170   edi: 00000000   ebp: 0000004f   esp: c5fd7f44
ds: 0018   es: 0018   ss: 0018
Process kswapd (pid: 2, stackpage=c5fd7000)
Stack: c01c8d81 c01c8fcd 00000068 c1000170 c100018c c5fd7fa4 0000004f c1000198 
       c1000198 00000282 00000023 0000004f c011e3b7 00000009 00000006 00000004 
       c01fbbc0 c5fd7fac c5fd7fa4 00000004 00000000 00000000 c5fd7f9c c5fd7f9c 
Call Trace: [<c01c8d81>] [<c01c8fcd>] [<c011e3b7>] [<c012586b>] [<c012594a>] [<c0107474>] 
Code: 0f 0b 83 c4 0c 89 f6 89 f1 2b 0d ac b8 1f c0 8d 14 cd 00 00 
00000000 <_EIP>:
Code;  c0125d09 <__free_pages_ok+49/2fc>   <=====
   0:   0f 0b             ud2a      <=====
Code;  c0125d0b <__free_pages_ok+4b/2fc>
   2:   83 c4 0c          addl   $0xc,%esp
Code;  c0125d0e <__free_pages_ok+4e/2fc>
   5:   89 f6             movl   %esi,%esi
Code;  c0125d10 <__free_pages_ok+50/2fc>
   7:   89 f1             movl   %esi,%ecx
Code;  c0125d12 <__free_pages_ok+52/2fc>
   9:   2b 0d ac b8 1f    subl   0xc01fb8ac,%ecx
Code;  c0125d17 <__free_pages_ok+57/2fc>
   e:   c0 
Code;  c0125d18 <__free_pages_ok+58/2fc>
   f:   8d 14 cd 00 00    leal   0x0(,%ecx,8),%edx
Code;  c0125d1d <__free_pages_ok+5d/2fc>
  14:   00 00 


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
