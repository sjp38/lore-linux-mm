Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B630E6B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 16:49:28 -0400 (EDT)
Date: Fri, 1 May 2009 13:45:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
Message-Id: <20090501134528.be5f27b2.akpm@linux-foundation.org>
In-Reply-To: <49FB5623.3030403@redhat.com>
References: <20090428044426.GA5035@eskimo.com>
	<20090428192907.556f3a34@bree.surriel.com>
	<1240987349.4512.18.camel@laptop>
	<20090429114708.66114c03@cuia.bos.redhat.com>
	<20090430072057.GA4663@eskimo.com>
	<20090430174536.d0f438dd.akpm@linux-foundation.org>
	<20090430205936.0f8b29fc@riellaptop.surriel.com>
	<20090430181340.6f07421d.akpm@linux-foundation.org>
	<20090430215034.4748e615@riellaptop.surriel.com>
	<20090430195439.e02edc26.akpm@linux-foundation.org>
	<49FB01C1.6050204@redhat.com>
	<20090501123541.7983a8ae.akpm@linux-foundation.org>
	<49FB5623.3030403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: elladan@eskimo.com, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 01 May 2009 16:05:55 -0400
Rik van Riel <riel@redhat.com> wrote:

> Are you open to evaluating other methods that could lead, on
> desktop systems, to a behaviour similar to the one achieved
> by the preserve-mapped-pages mechanism?

Well..  it's more a matter of retaining what we've learnt (unless we
feel it's wrong, or technilogy change broke it) and carefully listening
to and responding to what's happening in out-there land.

The number of problem reports we're seeing from the LRU changes is
pretty low.  Hopefully that's because the number of problems _is_
low.

Given the low level of problem reports, the relative immaturity of the
code and our difficulty with determining what effect our changes will
have upon everyone, I'd have thought that sit-tight-and-wait-and-see
would be the prudent approach for the next few months.

otoh if you have a change and it proves good in your testing then sure,
sooner rather than later.

There, that was nice and waffly.

I still haven't forgotten prev_priority tho!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
