Date: Mon, 30 Aug 2004 16:51:00 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on
 swap partition
Message-Id: <20040830165100.535e68e5.akpm@osdl.org>
In-Reply-To: <20040830221727.GE2955@logos.cnet>
References: <20040829033031.01c5f78c.akpm@osdl.org>
	<20040829141526.GC10955@suse.de>
	<20040829141718.GD10955@suse.de>
	<20040829131824.1b39f2e8.akpm@osdl.org>
	<20040829203011.GA11878@suse.de>
	<20040829135917.3e8ffed8.akpm@osdl.org>
	<20040830152025.GA2901@logos.cnet>
	<41336B6F.6050806@pandora.be>
	<20040830203339.GA2955@logos.cnet>
	<20040830153730.18e431c2.akpm@osdl.org>
	<20040830221727.GE2955@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: karl.vogel@pandora.be, axboe@suse.de, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> What you think of this, which tries to address your comments

Suggest you pass the scan_control structure down into pageout(), stick
`inflight' into struct scan_control and use some flag in scan_control to
ensure that we only throttle once per try_to_free_pages()/blaance_pgdat()
pass.

See, page reclaim is now, as much as possible, "batched".  Think of it as
operating in units of 32 pages at a time.  We should only examine the dirty
memory thresholds and throttle once per "batch", not once per page.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
