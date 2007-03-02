Subject: Re: The performance and behaviour of the anti-fragmentation
	related patches
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20070301160915.6da876c5.akpm@linux-foundation.org>
References: <20070301101249.GA29351@skynet.ie>
	 <20070301160915.6da876c5.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 02 Mar 2007 05:50:57 -0800
Message-Id: <1172843457.3237.11.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-03-01 at 16:09 -0800, Andrew Morton wrote:
> And I'd judge that per-container RSS limits are of considerably more value
> than antifrag (in fact per-container RSS might be a superset of antifrag,
> in the sense that per-container RSS and containers could be abused to fix
> the i-cant-get-any-hugepages problem, dunno).


Hi,

the RSS thing is.. .funky.
I'm saying that because we have not been able to define what RSS means,
so before we expand how RSS is used that needs solving first.

This is relevant for the pagetable sharing patches: if RSS can exclude
shared, they're relatively easy. If RSS has to include shared always, we
have currently a problem because hugepages aren't part of RSS right now.

I would really really really like to see this unclarity sorted out on
the concept level before going through massive changes in the code based
on something so fundamentally unclear.

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
