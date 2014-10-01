Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9196B0071
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 11:56:38 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id em10so1143775wid.7
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 08:56:37 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id b10si21201021wic.34.2014.10.01.08.56.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 08:56:37 -0700 (PDT)
Received: by mail-wi0-f169.google.com with SMTP id cc10so975893wib.0
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 08:56:37 -0700 (PDT)
Date: Wed, 1 Oct 2014 17:56:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcontrol Use #include <linux/uaccess.h>
Message-ID: <20141001155634.GB4405@dhcp22.suse.cz>
References: <1412178296-2972-1-git-send-email-paulmcquad@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1412178296-2972-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McQuade <paulmcquad@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, hannes@cmpxchg.org

On Wed 01-10-14 16:44:56, Paul McQuade wrote:
> Remove asm headers for linux headers

I think we do not need this header at all these days. There are no
direct operations on user memory in memcontrol.c.

> Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
> ---
>  mm/memcontrol.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 085dc6d..51dbe80 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -56,14 +56,14 @@
>  #include <linux/oom.h>
>  #include <linux/lockdep.h>
>  #include <linux/file.h>
> +#include <linux/uaccess.h>
> +
>  #include "internal.h"
>  #include <net/sock.h>
>  #include <net/ip.h>
>  #include <net/tcp_memcontrol.h>
>  #include "slab.h"
>  
> -#include <asm/uaccess.h>
> -
>  #include <trace/events/vmscan.h>
>  
>  struct cgroup_subsys memory_cgrp_subsys __read_mostly;
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
