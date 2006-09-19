Message-ID: <45101EAE.2070303@yahoo.com.au>
Date: Wed, 20 Sep 2006 02:45:34 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Get rid of zone_table V2
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com> <20060918132818.603196e2.akpm@osdl.org> <Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com> <20060918161528.9714c30c.akpm@osdl.org> <Pine.LNX.4.64.0609181642210.30206@schroedinger.engr.sgi.com> <20060918165808.c410d1d4.akpm@osdl.org> <Pine.LNX.4.64.0609181711210.30365@schroedinger.engr.sgi.com> <20060918173134.d3850903.akpm@osdl.org> <Pine.LNX.4.64.0609182309050.3152@schroedinger.engr.sgi.com> <20060918233337.ef539a2b.akpm@osdl.org> <Pine.LNX.4.64.0609190709190.4787@schroedinger.engr.sgi.com> <20060919083851.75b26075.akpm@osdl.org> <Pine.LNX.4.64.0609190839370.5034@schroedinger.engr.sgi.com> <4510196A.5090306@yahoo.com.au>
In-Reply-To: <4510196A.5090306@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Christoph Lameter wrote:

>> Would be okay to grow the size of struct zone to the next power of 2 
>> bytes?
> 
> 
> I'd say yes: it is only memory we're talking about here, not cachelines,
> because the whole thing is cacheline aligned up the wazoo anyway. Let's
> see, on your example system that would take up an extra 896 bytes per
> struct zone... not too bad.
> 
> And it is a better solution than shrinking because it will work on all
> architectures and configurations.

BTW. I wonder why gcc isn't using two shifts in your example? Not that
I think it would be great even if it were, because subtle differences
could cause that to become more shifts...

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
