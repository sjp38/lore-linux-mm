Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B5E726B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 03:58:40 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d4so6108318pgv.4
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 00:58:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88si4680761plf.291.2017.12.01.00.58.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 00:58:39 -0800 (PST)
Date: Fri, 1 Dec 2017 09:58:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] x86/numa: move setting parse numa node to num_add_memblk
Message-ID: <20171201085833.4hs6sgjvcokdrr35@dhcp22.suse.cz>
References: <1511946807-22024-1-git-send-email-zhongjiang@huawei.com>
 <5A211759.5080800@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A211759.5080800@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, lenb@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, richard.weiyang@gmail.com, pombredanne@nexb.com, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org

On Fri 01-12-17 16:48:25, zhong jiang wrote:
> +cc more mm maintainer.
> 
> Any one has any object.  please let me know.  

Please repost with the changelog which actually tells 1) what is the
problem 2) why do we need to address it and 3) how do we address it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
