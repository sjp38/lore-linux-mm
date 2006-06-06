Date: Tue, 6 Jun 2006 16:43:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/5] Sizing zones and holes in an architecture
 independent manner V7
Message-Id: <20060606164311.27d4af98.akpm@osdl.org>
In-Reply-To: <20060606134710.21419.48239.sendpatchset@skynet.skynet.ie>
References: <20060606134710.21419.48239.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: davej@codemonkey.org.uk, tony.luck@intel.com, ak@suse.de, bob.picco@hp.com, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  6 Jun 2006 14:47:10 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> This is V7 of the patchset to size zones and memory holes in an
> architecture-independent manner.

I hope this won't deprive me of my 4 kbyte highmem zone.

I won't merge these patches for rc6-mm1 - we already have a few problems in
this area which I don't think anyone understands yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
