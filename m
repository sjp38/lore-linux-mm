Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: hugetlb page patch for 2.5.48-bug fixes
Date: Sun, 24 Nov 2002 10:01:27 -0500
References: <25282B06EFB8D31198BF00508B66D4FA03EA5B14@fmsmsx114.fm.intel.com> <200211240944.10660.tomlins@cam.org> <20021124144905.GA18063@holomorphy.com>
In-Reply-To: <20021124144905.GA18063@holomorphy.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200211241001.27971.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: akpm@digeo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On November 24, 2002 09:49 am, William Lee Irwin III wrote:
> On Sun, Nov 24, 2002 at 09:44:10AM -0500, Ed Tomlinson wrote:
> > bounds: 0000
> > CPU:    0
> > EIP:    0060:[i8042_exit+155901274/-1072694240]    Not tainted
> > EFLAGS: 00010283
> > EIP is at 0x94ae13a
> > eax: dfdee040   ebx: c33151f4   ecx: c02b7ca2   edx: 094ae040
> > esi: dfdce000   edi: 00000056   ebp: dfdce000   esp: dfdcfe80
> > ds: 0068   es: 0068   ss: 0068
> > Process kswapd0 (pid: 5, threadinfo=dfdce000 task=c151f840)
> > Stack: 48094ae0 c015a7d8 c33151f4 dab225e0 c015965f c33151f4 dfdce000
> > 0000004d 00000056 c015836f dab225e0 000001d0 00000000 c01586b6 00000056
> > c0134b5c 00000056 000001d0 01ee7b30 00000000 000186fe dffee760 00000212
> > c02b6cb4 Call Trace:
> > [iput+88/128] iput+0x58/0x80
> > [prune_one_dentry+63/128] prune_one_dentry+0x3f/0x80
> > [prune_dcache+175/192] prune_dcache+0xaf/0xc0
> > [shrink_dcache_memory+54/64] shrink_dcache_memory+0x36/0x40
> > [shrink_slab+252/352] shrink_slab+0xfc/0x160
> > [balance_pgdat+243/352] balance_pgdat+0xf3/0x160
> > [kswapd+291/320] kswapd+0x123/0x140
>
> Okay, you've jumped into oblivion. What fs's were you using here?

reiserfs.  (sorry about the subject line)

Ed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
