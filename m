Date: Fri, 14 Apr 2006 13:53:45 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH 0/7] [RFC] Sizing zones and holes in an architecture independent manner V2
Message-ID: <20060414205345.GA1258@agluck-lia64.sc.intel.com>
References: <20060412232036.18862.84118.sendpatchset@skynet> <20060413095207.GA4047@skynet.ie> <20060413171942.GA15047@agluck-lia64.sc.intel.com> <20060413173008.GA19402@skynet.ie> <20060413174720.GA15183@agluck-lia64.sc.intel.com> <20060413191402.GA20606@skynet.ie> <20060413215358.GA15957@agluck-lia64.sc.intel.com> <20060414131235.GA19064@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060414131235.GA19064@skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: davej@codemonkey.org.uk, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, bob.picco@hp.com, ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 14, 2006 at 02:12:35PM +0100, Mel Gorman wrote:
> That appears fine, but I call add_active_range() after a GRANULEROUNDUP and
> GRANULEROUNDDOWN has taken place so that might be the problem, especially as
> all those ranges are aligned on a 16MiB boundary. The following patch calls
> add_active_range() before the rounding takes place. Can you try it out please?

That's good.  Now I see identical output before/after your patch for
the generic (DISCONTIG=y) kernel:

On node 0 totalpages: 259873
  DMA zone: 128931 pages, LIFO batch:7
  Normal zone: 130942 pages, LIFO batch:7

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
