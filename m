Date: Thu, 1 Mar 2007 19:59:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
Message-Id: <20070301195943.8ceb221a.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
References: <20070301101249.GA29351@skynet.ie>
	<20070301160915.6da876c5.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
	<45E7835A.8000908@in.ibm.com>
	<Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Balbir Singh <balbir@in.ibm.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Mar 2007 19:44:27 -0800 (PST) Linus Torvalds <torvalds@linux-foundation.org> wrote:

> In other words, I really don't see a huge upside. I see *lots* of 
> downsides, but upsides? Not so much. Almost everybody who wants unplug 
> wants virtualization, and right now none of the "big virtualization" 
> people would want to have kernel-level anti-fragmentation anyway sicne 
> they'd need to do it on their own.

Agree with all that, but you're missing the other application: power
saving.  FBDIMMs take eight watts a pop.  If we can turn them off when the
system is unloaded we save either four or all eight watts (assuming we can
get Intel to part with the information which is needed to do this.  I fear
an ACPI method will ensue).

There's a whole lot of complexity and work in all of this, but 24*8 watts
is a lot of watts, and it's worth striving for.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
