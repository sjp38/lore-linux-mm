Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9146B0253
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 05:40:25 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id 65so11925909pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 02:40:25 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id bw10si8600392pab.22.2016.02.03.02.40.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 02:40:24 -0800 (PST)
Received: by mail-pf0-x234.google.com with SMTP id w123so11995744pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 02:40:24 -0800 (PST)
Date: Wed, 3 Feb 2016 19:41:36 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/workingset: do not forget to unlock page
Message-ID: <20160203104136.GA517@swordfish>
References: <1454493513-19316-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454493513-19316-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (02/03/16 18:58), Sergey Senozhatsky wrote:
> 
> Do not leave page locked (and RCU read side locked) when
> return from workingset_activation() due to disabled memcg
> or page not being a page_memcg().

d'oh... sorry, the commit message is simply insane.


apparently the patch fixes a new code
	mm-workingset-per-cgroup-cache-thrash-detection.patch added to -mm tree
	mm-simplify-lock_page_memcg.patch added to -mm tree


so if there is an option to fold this patch into mm-simplify-lock_page_memcg,
for example, as a -fix, then I wouldn't mind at all.



a better commit message
===8<====8<====
