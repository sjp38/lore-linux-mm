From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/5] Sizing zones and holes in an architecture independent manner V7
Date: Wed, 7 Jun 2006 17:20:22 +0200
References: <20060606134710.21419.48239.sendpatchset@skynet.skynet.ie> <200606071216.24640.ak@suse.de> <Pine.LNX.4.64.0606071118230.20653@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0606071118230.20653@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606071720.22242.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@osdl.org>, davej@codemonkey.org.uk, tony.luck@intel.com, bob.picco@hp.com, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Ok, while true, I'm not sure how it affects performance. The only "real" 
> value affected by present_pages is the number of patches that are 
> allocated in batches to the per-cpu allocator.

It affects the low/high water marks in the VM zone balancer.

Especially for the 16MB DMA zone it can make a difference if you
account 4MB kernel in there or not.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
