Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B7F2D6B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 06:22:36 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so31480157pac.8
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 03:22:36 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ix10si22925654pbc.107.2015.01.12.03.22.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 03:22:35 -0800 (PST)
Date: Mon, 12 Jan 2015 14:22:27 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 3/3] mm: memcontrol: consolidate swap controller code
Message-ID: <20150112112227.GD384@esperanza>
References: <1420856041-27647-1-git-send-email-hannes@cmpxchg.org>
 <1420856041-27647-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1420856041-27647-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jan 09, 2015 at 09:14:01PM -0500, Johannes Weiner wrote:
> The swap controller code is scattered all over the file.  Gather all
> the code that isn't directly needed by the memory controller at the
> end of the file in its own CONFIG_MEMCG_SWAP section.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I was always wondering why it had to be scattered all over the place. I
guess we'll have to do the same for the kmem part.

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
