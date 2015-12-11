Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0576C6B0256
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:26:06 -0500 (EST)
Received: by lfdl133 with SMTP id l133so84744622lfd.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:26:05 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ja1si11207823lbc.181.2015.12.11.11.26.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 11:26:04 -0800 (PST)
Date: Fri, 11 Dec 2015 14:25:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/7] swap.h: move memcg related stuff to the end of the
 file
Message-ID: <20151211192552.GC3773@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <72ad884dba8e3a9b13935bc0f27b2e46681c53c0.1449742561.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <72ad884dba8e3a9b13935bc0f27b2e46681c53c0.1449742561.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 10, 2015 at 02:39:17PM +0300, Vladimir Davydov wrote:
> The following patches will add more functions to the memcg section of
> include/linux/swap.h. Some of them will need values defined below the
> current location of the section. So let's move the section to the end of
> the file. No functional changes intended.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
