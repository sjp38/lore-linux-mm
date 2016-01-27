Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id CBBEC6B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:32:24 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id x125so5868812pfb.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 06:32:24 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id lo7si2918294pab.51.2016.01.27.06.32.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 06:32:24 -0800 (PST)
Date: Wed, 27 Jan 2016 17:32:13 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 2/5] mm: workingset: #define radix entry eviction mask
Message-ID: <20160127143213.GB9623@esperanza>
References: <1453842006-29265-1-git-send-email-hannes@cmpxchg.org>
 <1453842006-29265-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1453842006-29265-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 26, 2016 at 04:00:03PM -0500, Johannes Weiner wrote:
> This is a compile-time constant, no need to calculate it on refault.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
