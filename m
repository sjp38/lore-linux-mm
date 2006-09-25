From: Andi Kleen <ak@suse.de>
Subject: Re: One idea to free up page flags on NUMA
Date: Mon, 25 Sep 2006 05:04:58 +0200
References: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com> <200609240924.42382.ak@suse.de> <Pine.LNX.4.64.0609241730470.19511@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609241730470.19511@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609250504.58427.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Monday 25 September 2006 02:31, Christoph Lameter wrote:
> On Sun, 24 Sep 2006, Andi Kleen wrote:
> 
> > > Hmmm... It only maps the kernel text segment?
> > Only lowmem (normally upto ~900MB)
> > 
> > But virtual memory is very scarce so I don't know where a new map for mem_map
> > would come from. Ok you could try to move the physical location of mem_map to 
> > somewhere not in lowmem I suppose.
> 
> Right could be in highmem and thus would free up around 20 Megabytes of 
> low memory.

But won't the vmemmap need more than the 20MB?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
