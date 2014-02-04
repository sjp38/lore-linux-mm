Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 604A96B003D
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:42:46 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q58so4469857wes.10
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:42:45 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fu7si12561461wjb.118.2014.02.04.08.42.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:42:45 -0800 (PST)
Date: Tue, 4 Feb 2014 17:42:43 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 5/6] memcg, kmem: clean up memcg parameter handling
Message-ID: <20140204164243.GQ4890@dhcp22.suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-6-git-send-email-mhocko@suse.cz>
 <20140204163210.GQ6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140204163210.GQ6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 04-02-14 11:32:10, Johannes Weiner wrote:
> On Tue, Feb 04, 2014 at 02:28:59PM +0100, Michal Hocko wrote:
> > memcg_kmem_newpage_charge doesn't always set the given memcg parameter.
> 
> lol, I really don't get your patch order...

Ok, Ok, I've encountered this mess while double checking #2 and was too
lazy to rebasing again. I will move it to the front for the merge.

> > Some early escape paths skip setting *memcg while
> > __memcg_kmem_newpage_charge down the call chain sets *memcg even if no
> > memcg is charged due to other escape paths.
> > 
> > The current code is correct because the memcg is initialized to NULL
> > at the highest level in __alloc_pages_nodemask but this all is very
> > confusing and error prone. Let's make the semantic clear and move the
> > memcg parameter initialization to the highest level of kmem accounting
> > (memcg_kmem_newpage_charge).
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Patch looks good, though.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
