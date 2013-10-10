Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 485D46B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 06:25:01 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so2373879pdi.5
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 03:24:59 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1VUDQM-0000U3-Po
	for linux-mm@kvack.org; Thu, 10 Oct 2013 12:24:54 +0200
Received: from c-50-132-41-203.hsd1.wa.comcast.net ([50.132.41.203])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:24:54 +0200
Received: from eternaleye by c-50-132-41-203.hsd1.wa.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:24:54 +0200
From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: [RFC 0/4] cleancache: SSD backed cleancache backend
Date: Thu, 10 Oct 2013 10:24:36 +0000 (UTC)
Message-ID: <loom.20131010T122004-708@post.gmane.org>
References: <20130926141428.392345308@kernel.org> <20130926161401.GA3288@medulla.variantweb.net> <20131009115243.GA1198@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Theodore Ts'o <tytso <at> mit.edu> writes:

<snip>

> If we are to do page-level caching, we really need to change the VM to
> use something like IBM's Adaptive Replacement Cache[1], which allows
> us to track which pages have been more frequently used, so that we
> only cache those pages, as opposed to those that land in the cache
> once and then aren't used again.  (Consider what might happen if you
> are using clean cache and then the user does a full backup of the
> system.)
> 
> [1] http://en.wikipedia.org/wiki/Adaptive_replacement_cache

<snip>

It's a topic that's come up before, [2] is probably the best resource on the
web right now regarding efforts to change the page-replacement algorithm in
Linux. CAR/CART in particular are rather interesting. Seemingly not much
motion recently, though.

[1] NMF
[2] http://linux-mm.org/AdvancedPageReplacement

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
