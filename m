Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D314E6B01AC
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 17:41:00 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o5GLeuI3015486
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 14:40:56 -0700
Received: from pvb32 (pvb32.prod.google.com [10.241.209.96])
	by wpaz29.hot.corp.google.com with ESMTP id o5GLesIg009106
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 14:40:54 -0700
Received: by pvb32 with SMTP id 32so1810509pvb.12
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 14:40:54 -0700 (PDT)
Date: Wed, 16 Jun 2010 14:40:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/9] oom: rename badness() to oom_badness()
In-Reply-To: <20100616202920.72DA.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006161440360.11089@chino.kir.corp.google.com>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com> <20100616202920.72DA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jun 2010, KOSAKI Motohiro wrote:

> 
> badness() is wrong name because it's too generic name. rename it.
> 

This is already done in my badness heuristic rewrite, can we please focus 
on its review?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
