Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0C7876B0255
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 08:40:35 -0500 (EST)
Received: by wmww144 with SMTP id w144so25164021wmw.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 05:40:34 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id aq10si5536944wjc.240.2015.12.10.05.40.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 05:40:33 -0800 (PST)
Received: by wmec201 with SMTP id c201so25259467wme.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 05:40:33 -0800 (PST)
Date: Thu, 10 Dec 2015 14:40:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: memcontrol: reign in CONFIG space madness
Message-ID: <20151210134031.GN19496@dhcp22.suse.cz>
References: <20151209203004.GA5820@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151209203004.GA5820@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 09-12-15 15:30:04, Johannes Weiner wrote:
> Hey guys,
> 
> there has been quite a bit of trouble that stems from dividing our
> CONFIG space and having to provide real code and dummy functions
> correctly in all possible combinations. This is amplified by having
> the legacy mode and the cgroup2 mode in the same file sharing code.
> 
> The socket memory and kmem accounting series is a nightmare in that
> respect, and I'm still in the process of sorting it out. But no matter
> what the outcome there is going to be, what do you think about getting
> rid of the CONFIG_MEMCG[_LEGACY]_KMEM and CONFIG_INET stuff?

The code size difference after your recent patches is indeed not that
large but that is only because huge part of the kmem code is enabled by
default now. I have raised this in the reply to the respective patch.
This is ~8K of the code 1K for data. I do understand your reasoning
about the complications but this is quite a lot of code. CONFIG_INET
ifdefs are probably pointless - they do not add really much and most
configs will have it by default. The core for KMEM seems to be a
different thing to me. Maybe we can reorganize the code to make the
maintenance easier and still allow to enable KMEM accounting separately
for kernel size savy users?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
