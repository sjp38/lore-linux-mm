Date: Fri, 22 Sep 2000 16:10:55 +0200
From: =?iso-8859-1?Q?Andr=E9_Dahlqvist?=
        <andre_dahlqvist@post.netlink.se>
Subject: Re: test9-pre5+t9p2-vmpatch VM deadlock during write-intensive workload
Message-ID: <20000922161055.A1088@post.netlink.se>
References: <Pine.LNX.4.21.0009221131110.12532-200000@debella.aszi.sztaki.hu> <Pine.LNX.4.21.0009220725590.4442-200000@duckman.distro.conectiva> <20000922151020.A653@post.netlink.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20000922151020.A653@post.netlink.se>; from andre_dahlqvist@post.netlink.se on Fri, Sep 22, 2000 at 03:10:20PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Molnar Ingo <mingo@debella.ikk.sztaki.hu>, "David S. Miller" <davem@redhat.com>, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I had to type the oops down by hand, but I will provide ksymoops
> output soon if you need it.

Let's hope I typed down the oops from the screen without misstakes. Here
is the ksymoops output:

ksymoops 2.3.4 on i586 2.4.0-test9.  Options used
     -V (default)
     -k 20000922143001.ksyms (specified)
     -l 20000922143001.modules (specified)
     -o /lib/modules/2.4.0-test9/ (default)
     -m /boot/System.map-2.4.0-test9 (default)

invalid operand: 0000
CPU:    0
EIP:    0010:[<c012c1be>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010086
eax: 0000001c   ebx: c31779e0     ecx: 00000000       edx: 00000082
esi: c11f6f80   edi: 00000008     ebp: 00000001       esp: c01f3eec
ds: 0018   es: 0018   ss: 0018
Process swapper (pid:0, stackpage=c01f3000)
Stack: c01bb465 c01bb79a 000002da c0150d3f e31779e0 00000001 c11f6480 00000046
       c1168360 c0248460 c01684e3 c11f6f80 00000001 c0248584 00000000 c11f6f80
       c02484a0 c016e563 00000001 c1168360 c02484a0 c1168360 00000286 c0169cc7
Call Trace: [<c01bb4b5>] [<c01bb79a>] [<c0150d3f>] [<c01684e3>]
[<c016e563>] [<c0169cc7>] [<c016e500>] [<c010a02c>] [<c010a18e>] [<c0107120>] [<c0108de0>]
[<c0107120>] [<c0107143>] [<c01071a7>] [<c0105000>]
                                      [<c0100192>]
Code: 0f 0b 83 c4 0c c3 57 56 53 86 74 24 10 8b 54 24 14 85 d2 74

>>EIP; c012c1be <end_buffer_io_bad+42/48>   <=====
Trace; c01bb4b5 <tvecs+36dd/cde8>
Trace; c01bb79a <tvecs+39c2/cde8>
Trace; c0150d3f <end_that_request_first+5f/b8>
Trace; c01684e3 <ide_end_request+27/74>
Trace; c016e563 <ide_dma_intr+63/9c>
Trace; c0169cc7 <ide_intr+fb/150>
Trace; c016e500 <ide_dma_intr+0/9c>
Trace; c010a02c <handle_IRQ_event+30/5c>
Trace; c010a18e <do_IRQ+6e/b0>
Trace; c0107120 <default_idle+0/28>
Trace; c0108de0 <ret_from_intr+0/20>
Trace; c0107120 <default_idle+0/28>
Trace; c0107143 <default_idle+23/28>
Trace; c01071a7 <cpu_idle+3f/54>
Trace; c0105000 <empty_bad_page+0/1000>
Trace; c0100192 <L6+0/2>
Code;  c012c1be <end_buffer_io_bad+42/48>
00000000 <_EIP>:
Code;  c012c1be <end_buffer_io_bad+42/48>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c012c1c0 <end_buffer_io_bad+44/48>
   2:   83 c4 0c                  add    $0xc,%esp
Code;  c012c1c3 <end_buffer_io_bad+47/48>
   5:   c3                        ret    
Code;  c012c1c4 <end_buffer_io_async+0/b4>
   6:   57                        push   %edi
Code;  c012c1c5 <end_buffer_io_async+1/b4>
   7:   56                        push   %esi
Code;  c012c1c6 <end_buffer_io_async+2/b4>
   8:   53                        push   %ebx
Code;  c012c1c7 <end_buffer_io_async+3/b4>
   9:   86 74 24 10               xchg   %dh,0x10(%esp,1)
Code;  c012c1cb <end_buffer_io_async+7/b4>
   d:   8b 54 24 14               mov    0x14(%esp,1),%edx
Code;  c012c1cf <end_buffer_io_async+b/b4>
  11:   85 d2                     test   %edx,%edx
Code;  c012c1d1 <end_buffer_io_async+d/b4>
  13:   74 00                     je     15 <_EIP+0x15> c012c1d3 <end_buffer_io_async+f/b4>

Aiee, killing interrupt handler
Kernel panic: Attempted to kill the idle task!
-- 

// Andre
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
