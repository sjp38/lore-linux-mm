Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCEE6B007E
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 04:58:24 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id c6so109088284qga.1
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 01:58:24 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0121.outbound.protection.outlook.com. [157.55.234.121])
        by mx.google.com with ESMTPS id o66si13058674qgd.91.2016.04.09.01.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 09 Apr 2016 01:58:23 -0700 (PDT)
Date: Sat, 9 Apr 2016 11:58:15 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: let v2 cgroups follow changes in system
 swappiness
Message-ID: <20160409085815.GB11428@esperanza>
References: <1460155744-15942-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1460155744-15942-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Apr 08, 2016 at 06:49:04PM -0400, Johannes Weiner wrote:
> Cgroup2 currently doesn't have a per-cgroup swappiness setting. We
> might want to add one later - that's a different discussion - but
> until we do, the cgroups should always follow the system setting.
> Otherwise it will be unchangeably set to whatever the ancestor
> inherited from the system setting at the time of cgroup creation.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: stable@vger.kernel.org # 4.5

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
