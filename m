Subject: Re: Hangs in 2.5.41-mm1
From: Paul Larson <plars@linuxtestproject.org>
In-Reply-To: <20021009210049.GH12432@holomorphy.com>
References: <1034188573.30975.40.camel@plars> <3DA48EEA.8100302C@digeo.com>
	<1034195372.30973.64.camel@plars>  <20021009210049.GH12432@holomorphy.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 09 Oct 2002 16:17:07 -0500
Message-Id: <1034198228.30973.70.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I got an oops out of it this time, after running it that test several
times, I retried case 2 and got this:

Unable to handle kernel paging request at virtual address 20b17050
 printing eip:
c0133a5b
*pde = 00000000
Oops: 0000

CPU:    3
EIP:    0060:[<c0133a5b>]    Not tainted
EFLAGS: 00010017
EIP is at cache_alloc_refill+0xbb/0x170
eax: 0000000c   ebx: f7ffba88   ecx: 20b17040   edx: 00000000
esi: 00000010   edi: cc16a800   ebp: f7ffba00   esp: f63a1ee4
ds: 0068   es: 0068   ss: 0068
Process crond (pid: 1239, threadinfo=f63a0000 task=f64d6100)
Stack: f7ffba90 00000282 f6b63720 0804f797 cc1dae00 c0133dab f7ffba00
000001d0
       00000001 00000000 00000001 c04a368c f7ffba00 c0158721 f7ffba00
000001d0
       cc1dae00 f6b63720 0804f797 f6baa2c0 c0158e6a cc1dae00 c014dfcf
cc1dae00
Call Trace:
 [<c0133dab>] kmem_cache_alloc+0x3b/0x50
 [<c0158721>] alloc_inode+0x31/0x170
 [<c0158e6a>] new_inode+0xa/0x60
 [<c014dfcf>] get_pipe_inode+0xf/0x90
 [<c014e082>] do_pipe+0x32/0x1e0
 [<c01240d9>] sys_rt_sigaction+0x69/0x90
 [<c010c9dd>] sys_pipe+0xd/0x40
 [<c0112d20>] do_page_fault+0x0/0x4a5
 [<c01071d3>] syscall_call+0x7/0xb

Code: 39 41 10 73 06 4e 83 fe ff 75 ba 8b 51 04 8b 01 89 50 04 89

Hopefully that will help a little.
Thanks,
Paul Larson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
