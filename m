Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id A6BBE6B006C
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 16:07:56 -0500 (EST)
Received: by iecrl12 with SMTP id rl12so70683270iec.2
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 13:07:56 -0800 (PST)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id sd3si6672831igb.32.2015.03.04.13.07.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 13:07:56 -0800 (PST)
Received: by igjz20 with SMTP id z20so40208637igj.4
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 13:07:56 -0800 (PST)
Date: Wed, 4 Mar 2015 13:07:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg: make CONFIG_MEMCG depend on CONFIG_MMU
In-Reply-To: <20150304192836.GA952@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1503041304480.22344@chino.kir.corp.google.com>
References: <1425492428-27562-1-git-send-email-mhocko@suse.cz> <20150304190635.GC21350@phnom.home.cmpxchg.org> <20150304192836.GA952@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chen Gang <762976180@qq.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>

On Wed, 4 Mar 2015, Michal Hocko wrote:

> Does it really make sense to do this minor tweaks when the configuration
> is barely usable and we are not aware of anybody actually using it in
> the real life?
> 

If the memcg kmem extension continues to be improved, I'm wondering if 
anybody would want to use memcg only for kmem limiting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
