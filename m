Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 18A226B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 10:50:55 -0400 (EDT)
Date: Fri, 10 Jul 2009 17:16:10 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
Message-ID: <20090710151610.GB356@random.random>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
 <20090707084750.GX2714@wotan.suse.de>
 <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com>
 <20090708173206.GN356@random.random>
 <Pine.LNX.4.64.0907101201280.2456@sister.anvils>
 <20090710134228.GX356@random.random>
 <9f3ffbd617047982a7aed71548a34f13.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9f3ffbd617047982a7aed71548a34f13.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, avi@redhat.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 10, 2009 at 11:12:38PM +0900, KAMEZAWA Hiroyuki wrote:
> BTW, ksm has no refcnt pingpong problem ?

Well sure it has, the refcount has to be increased when pages are
shared, just like for regular fork() on anonymous memory, but the
point is that you pay for it only when you're saving ram, so the
probability that is just pure overhead is lower than for the zero
page... it always depend on the app. I simply suggest in trying
it... perhaps zero page is way to go for your users.. they should
tell, not us...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
