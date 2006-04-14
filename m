Date: Sat, 15 Apr 2006 00:50:37 +0100 (IST)
From: Mel Gorman <mel@skynet.ie>
Subject: Re: [PATCH 0/7] [RFC] Sizing zones and holes in an architecture
 independent manner V2
In-Reply-To: <200604150917.10596.ncunningham@cyclades.com>
Message-ID: <Pine.LNX.4.64.0604150033230.22940@skynet.skynet.ie>
References: <20060412232036.18862.84118.sendpatchset@skynet>
 <200604150917.10596.ncunningham@cyclades.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@cyclades.com>
Cc: davej@codemonkey.org.uk, tony.luck@intel.com, linuxppc-dev@ozlabs.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, bob.picco@hp.com, ak@suse.de, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 15 Apr 2006, Nigel Cunningham wrote:

> It looks to me like this code could be used by the software suspend code in
> our determinations of what pages to save

Potentially yes. Currently, the node map and related functions are marked 
__init so they become unavailable but that is not set in stone.

>, particularly in the context of
> memory hotplug support.

Right now during memory hot-add, the memory is not registered with 
add_active_range(), but it would be straight-forward to add the call to 
add_memory() of each architecture that supported hotplug for example.

> Just some food for thought at the moment; I'll see if
> I can come up with a patch when I have some time, but it might help justify
> getting this merged.
>

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
