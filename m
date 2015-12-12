Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3DA6B0255
	for <linux-mm@kvack.org>; Sat, 12 Dec 2015 11:19:53 -0500 (EST)
Received: by pfnn128 with SMTP id n128so82013251pfn.0
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 08:19:53 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id xo14si4092760pac.167.2015.12.12.08.19.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Dec 2015 08:19:52 -0800 (PST)
Date: Sat, 12 Dec 2015 19:19:43 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 7/7] Documentation: cgroup: add memory.swap.{current,max}
 description
Message-ID: <20151212161943.GB28521@esperanza>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <24930f544e7e98a23a17c9adcacb9397b1b8cae7.1449742561.git.vdavydov@virtuozzo.com>
 <20151211194254.GF3773@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151211194254.GF3773@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 11, 2015 at 02:42:54PM -0500, Johannes Weiner wrote:
> On Thu, Dec 10, 2015 at 02:39:20PM +0300, Vladimir Davydov wrote:
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Can we include a blurb for R-5-1 of cgroups.txt as well to explain why
> cgroup2 has a new swap interface? I had already written something up
> in the past, pasted below, feel free to use it if you like. Otherwise,
> you had pretty good reasons in your swap controller changelog as well.

Will do in v2.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
