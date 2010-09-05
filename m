Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 159A86B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 18:00:44 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o85M0ibT009433
	for <linux-mm@kvack.org>; Sun, 5 Sep 2010 15:00:44 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by wpaz21.hot.corp.google.com with ESMTP id o85M0dji023789
	for <linux-mm@kvack.org>; Sun, 5 Sep 2010 15:00:42 -0700
Received: by pxi7 with SMTP id 7so2633606pxi.11
        for <linux-mm@kvack.org>; Sun, 05 Sep 2010 15:00:39 -0700 (PDT)
Date: Sun, 5 Sep 2010 15:00:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 14/14] mm: oom_kill: use IS_ERR() instead of strict
 checking
In-Reply-To: <1283711592-7669-1-git-send-email-segooon@gmail.com>
Message-ID: <alpine.DEB.2.00.1009051500200.5003@chino.kir.corp.google.com>
References: <1283711592-7669-1-git-send-email-segooon@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Kulikov Vasiliy <segooon@gmail.com>
Cc: kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 5 Sep 2010, Kulikov Vasiliy wrote:

> From: Vasiliy Kulikov <segooon@gmail.com>
> 
> Use IS_ERR() instead of strict checking.
> 
> Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
