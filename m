Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CDA56B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 10:14:13 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id g24so4638086iob.13
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 07:14:13 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0009.hostedemail.com. [216.40.44.9])
        by mx.google.com with ESMTPS id c93si6742813itd.133.2018.01.18.07.14.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 07:14:12 -0800 (PST)
Message-ID: <1516288446.14023.0.camel@perches.com>
Subject: Re: [PATCH-next] MEMCG: memcontrol: make local symbol static
From: Joe Perches <joe@perches.com>
Date: Thu, 18 Jan 2018 07:14:06 -0800
In-Reply-To: <20180118150805.18521-1-chrisadr@gentoo.org>
References: <20180118150805.18521-1-chrisadr@gentoo.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher =?ISO-8859-1?Q?D=EDaz?= Riveros <chrisadr@gentoo.org>, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On Thu, 2018-01-18 at 10:08 -0500, Christopher Diaz Riveros wrote:
> Fixes the following sparse warning:
> 
> mm/memcontrol.c:1097:14: warning:
>   symbol 'memcg1_stats' was not declared. Should it be static?
> 
> Signed-off-by: Christopher Diaz Riveros <chrisadr@gentoo.org>
> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
[]
> @@ -1094,7 +1094,7 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
>  	return false;
>  }
>  
> -unsigned int memcg1_stats[] = {
> +static unsigned int memcg1_stats[] = {

This should almost certainly be static const

>  	MEMCG_CACHE,
>  	MEMCG_RSS,
>  	MEMCG_RSS_HUGE,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
