Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B78066B0255
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 11:45:30 -0500 (EST)
Received: by wmww144 with SMTP id w144so84088165wmw.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 08:45:30 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g9si17703004wmd.73.2015.11.09.08.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 08:45:29 -0800 (PST)
Date: Mon, 9 Nov 2015 11:45:18 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/5] memcg/kmem: switch to white list policy
Message-ID: <20151109164518.GA23356@cmpxchg.org>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <20151109140832.GE8916@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151109140832.GE8916@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Nov 09, 2015 at 03:08:32PM +0100, Michal Hocko wrote:
> I am _all_ for this semantic I am just not sure what to do with the
> legacy kmem controller. Can we change its semantic? If we cannot do that
> we would have to distinguish legacy and unified hierarchies during
> runtime and add the flag automagically for the first one (that would
> however require to keep __GFP_NOACCOUNT as well) which is all as clear
> as mud. But maybe the workloads which are using kmem legacy API can cope
> with that.

I think we can make that change for the existing kmem accounting too,
simply because the whitelist should be covering all memory consumers
that actually matter for isolation in practice. Yes, there is a risk
for accidents, but we are not actually intending to change semantics.

> Anyway if we go this way then I think the kmem accounting would be safe
> to be enabled by default with the cgroup2.

Cool, I'm happy we're on the same page about this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
