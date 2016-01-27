Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id D44D16B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:47:49 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l65so156582679wmf.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:47:49 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gt8si10086719wjc.204.2016.01.27.10.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 10:47:48 -0800 (PST)
Date: Wed, 27 Jan 2016 13:47:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmpressure: Fix subtree pressure detection
Message-ID: <20160127184701.GA31360@cmpxchg.org>
References: <1453912137-25473-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453912137-25473-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 27, 2016 at 07:28:57PM +0300, Vladimir Davydov wrote:
> When vmpressure is called for the entire subtree under pressure we
> mistakenly use vmpressure->scanned instead of vmpressure->tree_scanned
> when checking if vmpressure work is to be scheduled. This results in
> suppressing all vmpressure events in the legacy cgroup hierarchy. Fix
> it.
> 
> Fixes: 8e8ae645249b ("mm: memcontrol: hook up vmpressure to socket pressure")
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
