Date: Tue, 19 Sep 2006 10:50:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table V2
In-Reply-To: <45101EAE.2070303@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0609191049250.5879@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
 <20060918132818.603196e2.akpm@osdl.org> <Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com>
 <20060918161528.9714c30c.akpm@osdl.org> <Pine.LNX.4.64.0609181642210.30206@schroedinger.engr.sgi.com>
 <20060918165808.c410d1d4.akpm@osdl.org> <Pine.LNX.4.64.0609181711210.30365@schroedinger.engr.sgi.com>
 <20060918173134.d3850903.akpm@osdl.org> <Pine.LNX.4.64.0609182309050.3152@schroedinger.engr.sgi.com>
 <20060918233337.ef539a2b.akpm@osdl.org> <Pine.LNX.4.64.0609190709190.4787@schroedinger.engr.sgi.com>
 <20060919083851.75b26075.akpm@osdl.org> <Pine.LNX.4.64.0609190839370.5034@schroedinger.engr.sgi.com>
 <4510196A.5090306@yahoo.com.au> <45101EAE.2070303@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Sep 2006, Nick Piggin wrote:

> BTW. I wonder why gcc isn't using two shifts in your example? Not that
> I think it would be great even if it were, because subtle differences
> could cause that to become more shifts...

Perhaps multiply is highly optimized in contemporary processors and I am 
worrying too much about the multiply?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
