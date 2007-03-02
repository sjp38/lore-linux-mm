Date: Fri, 2 Mar 2007 09:07:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
Message-Id: <20070302090753.b06ed267.akpm@linux-foundation.org>
In-Reply-To: <20070302162023.GA4691@linux.intel.com>
References: <20070301101249.GA29351@skynet.ie>
	<20070301160915.6da876c5.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
	<45E7835A.8000908@in.ibm.com>
	<Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
	<20070301195943.8ceb221a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703012105080.3953@woody.linux-foundation.org>
	<20070302162023.GA4691@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mgross@linux.intel.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007 08:20:23 -0800 Mark Gross <mgross@linux.intel.com> wrote:

> > The whole DRAM power story is a bedtime story for gullible children. Don't 
> > fall for it. It's not realistic. The hardware support for it DOES NOT 
> > EXIST today, and probably won't for several years. And the real fix is 
> > elsewhere anyway (ie people will have to do a FBDIMM-2 interface, which 
> > is against the whole point of FBDIMM in the first place, but that's what 
> > you get when you ignore power in the first version!).
> >
> 
> Hardware support for some of this is coming this year in the ATCA space
> on the MPCBL0050.  The feature is a bit experimental, and
> power/performance benefits will be workload and configuration
> dependent.  Its not a bed time story.

What is the plan for software support?

Will it be possible to just power the DIMMs off?  I don't see much point in
some half-power non-destructive mode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
