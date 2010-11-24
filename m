Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 347626B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 19:18:01 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAO0HwhK010316
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 24 Nov 2010 09:17:58 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 630D245DE4E
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:17:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 38D8B45DE51
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:17:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A8281DB801B
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:17:58 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B3BF61DB8019
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:17:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH] fadvise support in rsync
In-Reply-To: <1290523792-6170-1-git-send-email-bgamari.foss@gmail.com>
References: <20101122103756.E236.A69D9226@jp.fujitsu.com> <1290523792-6170-1-git-send-email-bgamari.foss@gmail.com>
Message-Id: <20101124090749.7BE8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 24 Nov 2010 09:17:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, rsync@lists.samba.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

> Here is my attempt at adding fadvise support to rsync (against v3.0.7). I do
> this in both the sender (hinting after match_sums()) and the receiver (hinting
> after receive_data()). In principle we could get better granularity if this was
> hooked up within match_sums() (or even the map_ptr() interface) and the receive
> loop in receive_data(), but I wanted to keep things simple at first (any
> comments on these ideas?) . At the moment is for little more than testing.
> Considering the potential negative effects of using FADV_DONTNEED on older
> kernels, it is likely we will want this functionality off by default with a
> command line flag to enable.

Great!

As far as you don't hesitate userland app, we have no reason to hesitate
kernel change. We are only worry about to create no user interface. Because
it's maintainance nightmare.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
