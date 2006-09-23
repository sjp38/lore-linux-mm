Date: Sat, 23 Sep 2006 09:39:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: One idea to free up page flags on NUMA
In-Reply-To: <200609231804.40348.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0609230937140.15303@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com>
 <200609231804.40348.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Sat, 23 Sep 2006, Andi Kleen wrote:

> And what would we use them for?

Maybe a container number?

Anyways the scheme also would reduce the number of lookups needed and 
thus the general footprint of the VM using sparse.

I just looked at the arch code for i386 and x86_64 and it seems that both 
already have page tables for all of memory. It seems that a virtual memmap 
like this would just eliminate sparse overhead and not add any additional 
page table overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
