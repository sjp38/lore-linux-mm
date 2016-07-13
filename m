Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 752826B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 20:43:24 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so21647911lfi.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 17:43:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 8si7032558wmu.80.2016.07.12.17.43.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 17:43:23 -0700 (PDT)
Subject: Re: [PATCH 2/3] Update name field for all shrinker instances
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <68821d516aed9e248829d512eab88e381fd8ec60.1468051281.git.janani.rvchndrn@gmail.com>
From: Tony Jones <tonyj@suse.de>
Message-ID: <c4b7c9e8-ff21-0d58-98c9-54b064ca958a@suse.de>
Date: Tue, 12 Jul 2016 17:43:17 -0700
MIME-Version: 1.0
In-Reply-To: <68821d516aed9e248829d512eab88e381fd8ec60.1468051281.git.janani.rvchndrn@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On 07/09/2016 01:52 AM, Janani Ravichandran wrote:

> diff --git a/fs/super.c b/fs/super.c
> index d78b984..051073c 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -241,6 +241,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
>  	s->s_time_gran = 1000000000;
>  	s->cleancache_poolid = CLEANCACHE_NO_POOL;
>  
> +	s->s_shrink.name = "super_cache_shrinker";

my patchset made this a little more granular wrt superblock types by including type->name


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
