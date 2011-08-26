Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E385C6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 15:42:50 -0400 (EDT)
Date: Fri, 26 Aug 2011 12:42:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: convert k{un}map_atomic(p, KM_type) to
 k{un}map_atomic(p)
Message-Id: <20110826124239.fc503491.akpm@linux-foundation.org>
In-Reply-To: <1314349096.26922.21.camel@twins>
References: <1314346676.6486.25.camel@minggr.sh.intel.com>
	<1314349096.26922.21.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Lin Ming <ming.m.lin@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org

On Fri, 26 Aug 2011 10:58:16 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Fri, 2011-08-26 at 16:17 +0800, Lin Ming wrote:
> > 
> > The KM_type parameter for kmap_atomic/kunmap_atomic is not used anymore
> > since commit 3e4d3af(mm: stack based kmap_atomic()).
> > 
> > So convert k{un}map_atomic(p, KM_type) to k{un}map_atomic(p).
> > Most conversion are done by below commands. Some are done by hand.
> > 
> > find . -type f | xargs sed -i 's/\(kmap_atomic(.*\),\ .*)/\1)/'
> > find . -type f | xargs sed -i 's/\(kunmap_atomic(.*\),\ .*)/\1)/'
> > 
> > Build and tested on 32/64bit x86 kernel(allyesconfig) with 3G memory.
> > 
> > ARM, MIPS, PowerPc and Sparc are build tested only with
> > CONFIG_HIGHMEM=y and CONFIG_HIGHMEM=n.
> > I don't have cross-compiler for other arches. 
> 
> yet-another-massive patch.. (you're the third or fourth to do so) if
> Andrew wants to take this one I won't mind, however previously he didn't
> want flag day patches..

I'm OK with cleaning all these up, but I suggest that we leave the
back-compatibility macros in place for a while, to make sure that
various stragglers get converted.  Extra marks will be awarded for
working out how to make unconverted code generate a compile warning ;)

Perhaps you could dust off your old patch and we'll bring it up to date?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
