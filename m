Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C62C36B0292
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 16:09:47 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h191so20469650lfh.11
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 13:09:47 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id l12si426707ljb.266.2017.06.04.13.09.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 13:09:46 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id u62so7986650lfg.0
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 13:09:46 -0700 (PDT)
Date: Sun, 4 Jun 2017 23:09:42 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2] memcg: refactor mem_cgroup_resize_limit()
Message-ID: <20170604200942.GA23523@esperanza>
References: <20170601230212.30578-1-yuzhao@google.com>
 <20170604200437.17815-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170604200437.17815-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, n.borisov.lkml@gmail.com

On Sun, Jun 04, 2017 at 01:04:37PM -0700, Yu Zhao wrote:
> @@ -2498,22 +2449,24 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  		}
>  
>  		mutex_lock(&memcg_limit_mutex);
> -		if (limit < memcg->memory.limit) {
> +		inverted = memsw ? limit < memcg->memory.limit :
> +				   limit > memcg->memsw.limit;
> +		if (inverted)
>  			mutex_unlock(&memcg_limit_mutex);
>  			ret = -EINVAL;
>  			break;
>  		}

For some reason, I liked this patch more without this extra variable :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
