Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 054756B0255
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 04:05:32 -0500 (EST)
Received: by lbbkw15 with SMTP id kw15so26000229lbb.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 01:05:31 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id o73si3995977lfb.9.2015.12.09.01.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 01:05:30 -0800 (PST)
Date: Wed, 9 Dec 2015 12:05:10 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 2/8] mm: memcontrol: remove double kmem page_counter init
Message-ID: <20151209090510.GL11488@esperanza>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1449599665-18047-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Dec 08, 2015 at 01:34:19PM -0500, Johannes Weiner wrote:
> The kmem page_counter's limit is initialized to PAGE_COUNTER_MAX
> inside mem_cgroup_css_online(). There is no need to repeat this
> from memcg_propagate_kmem().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
