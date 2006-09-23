From: Andi Kleen <ak@suse.de>
Subject: Re: One idea to free up page flags on NUMA
Date: Sat, 23 Sep 2006 20:43:10 +0200
References: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com> <200609231804.40348.ak@suse.de> <Pine.LNX.4.64.0609230937140.15303@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609230937140.15303@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609232043.10434.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Saturday 23 September 2006 18:39, Christoph Lameter wrote:
> On Sat, 23 Sep 2006, Andi Kleen wrote:
> 
> > And what would we use them for?
> 
> Maybe a container number?
> 
> Anyways the scheme also would reduce the number of lookups needed and 
> thus the general footprint of the VM using sparse.

So far most users (distributions) are not using sparse yet anyways.
  
> I just looked at the arch code for i386 and x86_64 and it seems that both 
> already have page tables for all of memory. 

i386 doesn't map all of memory.

> It seems that a virtual memmap  
> like this would just eliminate sparse overhead and not add any additional 
> page table overhead.

You would have new mappings with new overhead, no?

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
