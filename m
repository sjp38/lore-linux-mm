Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9FB6B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 09:44:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i77so19765427wmh.10
        for <linux-mm@kvack.org>; Tue, 30 May 2017 06:44:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si13201928ede.244.2017.05.30.06.44.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 May 2017 06:44:58 -0700 (PDT)
Date: Tue, 30 May 2017 15:44:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: bump PGSTEAL*/PGSCAN*/ALLOCSTALL counters in memcg
 reclaim
Message-ID: <20170530134455.GH7969@dhcp22.suse.cz>
References: <1496062901-21456-1-git-send-email-guro@fb.com>
 <20170530122436.GE7969@dhcp22.suse.cz>
 <20170530132114.GA28148@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530132114.GA28148@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 30-05-17 14:21:14, Roman Gushchin wrote:
[...]
> But what about PGSTEAL*/PGSCAN* counters, isn't it better to make them
> reflect __all__ reclaim activity, no matter what was a root cause?

What would be the advantage? Those counters have always been global and
we should better have a strong reason to change that.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
