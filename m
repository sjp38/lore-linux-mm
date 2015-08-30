Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8846B0254
	for <linux-mm@kvack.org>; Sun, 30 Aug 2015 11:52:18 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so112127122pac.2
        for <linux-mm@kvack.org>; Sun, 30 Aug 2015 08:52:17 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id n9si20045851pdr.22.2015.08.30.08.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Aug 2015 08:52:17 -0700 (PDT)
Date: Sun, 30 Aug 2015 18:52:01 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150830155201.GQ9610@esperanza>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
 <20150828163611.GI9610@esperanza>
 <20150828164819.GL26785@mtj.duckdns.org>
 <20150828203231.GL9610@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150828203231.GL9610@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On Fri, Aug 28, 2015 at 11:32:31PM +0300, Vladimir Davydov wrote:
...
> From: Vladimir Davydov <vdavydov@parallels.com>
> Date: Fri, 28 Aug 2015 23:17:19 +0300
> Subject: [PATCH] mm/slub: don't bypass memcg reclaim for high-order page
>  allocation

Please ignore this patch. I'll rework and resend.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
