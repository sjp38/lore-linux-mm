Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B0A596B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 21:52:38 -0400 (EDT)
Received: by ti-out-0910.google.com with SMTP id u3so109155tia.8
        for <linux-mm@kvack.org>; Wed, 11 Mar 2009 18:52:35 -0700 (PDT)
Date: Thu, 12 Mar 2009 10:52:26 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may
  get wrongly discarded
Message-Id: <20090312105226.88df3f63.minchan.kim@barrios-desktop>
In-Reply-To: <20090312100049.43A3.A69D9226@jp.fujitsu.com>
References: <20090311170207.1795cad9.akpm@linux-foundation.org>
	<28c262360903111735s2b0c43a3pd48fcf8d55416ae3@mail.gmail.com>
	<20090312100049.43A3.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, dhowells@redhat.com, torvalds@linux-foundation.org, peterz@infradead.org, Enrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi, Kosaki-san. 

I think ramfs pages's unevictablility should not depend on CONFIG_UNEVICTABLE_LRU.
It would be better to remove dependency of CONFIG_UNEVICTABLE_LRU ?


How about this ? 
It's just RFC. It's not tested. 

That's because we can't reclaim that pages regardless of whether there is unevictable list or not
