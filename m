Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 5CD8C6B005A
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 14:10:55 -0500 (EST)
Date: Thu, 12 Jan 2012 20:10:53 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] mm: Remove NUMA_INTERLEAVE_HIT
Message-ID: <20120112191053.GF11715@one.firstfloor.org>
References: <1326380820.2442.186.camel@twins> <20120112182644.GE11715@one.firstfloor.org> <4F0F2E5A.3070602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F0F2E5A.3070602@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> This seems slightly strange reason to me. Almost useless/deprecated feature 
> removement broke ltp testsuite. But endusers never complained. Because they 

Don't know about that, but it sounds like a regression that should
have been reverted. Testing is important.

> never use testcases for development. 

It's a feature for developers. I originally added it for debugging
this code.

> So, May I clarify your intention? To 
> use Documention/feature-removal-schedule.txt solve your worry?

I just want it to stay so that the test suite keeps working.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
