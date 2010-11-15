Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 459348D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 07:38:50 -0500 (EST)
Date: Mon, 15 Nov 2010 13:38:46 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: BUG: Bad page state in process (current git)
Message-ID: <20101115123846.GA30047@arch.trippelsdorf.de>
References: <20101110152519.GA1626@arch.trippelsdorf.de>
 <20101110154057.GA2191@arch.trippelsdorf.de>
 <alpine.DEB.2.00.1011101534370.30164@router.home>
 <20101112122003.GA1572@arch.trippelsdorf.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101112122003.GA1572@arch.trippelsdorf.de>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 2010.11.12 at 13:20 +0100, Markus Trippelsdorf wrote:
> On 2010.11.10 at 15:46 -0600, Christoph Lameter wrote:
> > On Wed, 10 Nov 2010, Markus Trippelsdorf wrote:
> > 
> > > I found this in my dmesg:
> > > ACPI: Local APIC address 0xfee00000
> > >  [ffffea0000000000-ffffea0003ffffff] PMD -> [ffff8800d0000000-ffff8800d39fffff] on node 0
> > 
> > That only shows you how the memmap was virtually mapped.
> 
> Yes. Fortunately the BUG is gone since I pulled the upcoming drm fixes

No. I happend again today (with those fixes already applied):

BUG: Bad page state in process knode  pfn:7f0a8
page:ffffea0001bca4c0 count:0 mapcount:0 mapping:          (null) index:0x0
page flags: 0x4000000000000008(uptodate)
Pid: 18310, comm: knode Not tainted 2.6.37-rc1-00549-gae712bf-dirty #16
Call Trace:
 [<ffffffff810a9022>] ? bad_page+0x92/0xe0
 [<ffffffff810aa240>] ? get_page_from_freelist+0x4b0/0x570
 [<ffffffff8102e50e>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff810aa413>] ? __alloc_pages_nodemask+0x113/0x6b0
 [<ffffffff810a2dd4>] ? file_read_actor+0xc4/0x190
 [<ffffffff810a4a70>] ? generic_file_aio_read+0x560/0x6b0
 [<ffffffff810bdf8d>] ? handle_mm_fault+0x6bd/0x970
 [<ffffffff8104b1d0>] ? do_page_fault+0x120/0x410
 [<ffffffff810c3d85>] ? do_brk+0x275/0x360
 [<ffffffff81452d8f>] ? page_fault+0x1f/0x30
Disabling lock debugging due to kernel taint
-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
