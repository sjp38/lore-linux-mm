Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7515D6B0036
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:32:16 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id a15so4467372eae.23
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:32:16 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id x43si43327497eey.19.2014.02.04.08.32.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:32:15 -0800 (PST)
Date: Tue, 4 Feb 2014 11:32:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -v2 5/6] memcg, kmem: clean up memcg parameter handling
Message-ID: <20140204163210.GQ6963@cmpxchg.org>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-6-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391520540-17436-6-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Feb 04, 2014 at 02:28:59PM +0100, Michal Hocko wrote:
> memcg_kmem_newpage_charge doesn't always set the given memcg parameter.

lol, I really don't get your patch order...

> Some early escape paths skip setting *memcg while
> __memcg_kmem_newpage_charge down the call chain sets *memcg even if no
> memcg is charged due to other escape paths.
> 
> The current code is correct because the memcg is initialized to NULL
> at the highest level in __alloc_pages_nodemask but this all is very
> confusing and error prone. Let's make the semantic clear and move the
> memcg parameter initialization to the highest level of kmem accounting
> (memcg_kmem_newpage_charge).
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Patch looks good, though.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
