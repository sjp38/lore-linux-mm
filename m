Date: Sun, 24 Sep 2006 17:31:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: One idea to free up page flags on NUMA
In-Reply-To: <200609240924.42382.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0609241730470.19511@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com>
 <200609232043.10434.ak@suse.de> <Pine.LNX.4.64.0609231845380.16383@schroedinger.engr.sgi.com>
 <200609240924.42382.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Sun, 24 Sep 2006, Andi Kleen wrote:

> > Hmmm... It only maps the kernel text segment?
> Only lowmem (normally upto ~900MB)
> 
> But virtual memory is very scarce so I don't know where a new map for mem_map
> would come from. Ok you could try to move the physical location of mem_map to 
> somewhere not in lowmem I suppose.

Right could be in highmem and thus would free up around 20 Megabytes of 
low memory.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
