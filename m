Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD736B0253
	for <linux-mm@kvack.org>; Mon, 16 May 2016 09:54:58 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id i5so177116074ige.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 06:54:58 -0700 (PDT)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [2001:558:fe16:19:96:114:154:171])
        by mx.google.com with ESMTPS id p74si25164681iod.206.2016.05.16.06.54.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 06:54:57 -0700 (PDT)
Date: Mon, 16 May 2016 08:54:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: unhide vmstat_text definition for CONFIG_SMP
In-Reply-To: <20160516073716.GB23146@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1605160854330.23895@east.gentwo.org>
References: <1462978517-2972312-1-git-send-email-arnd@arndb.de> <20160516073716.GB23146@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 16 May 2016, Michal Hocko wrote:

> I agree with Christoph that vmstat_refresh is PROC_FS only so we should
> fix it there. It is not like this would be generally reusable helper...
> Why don't we just do:

Looks good.

Acked-by: Christoph Lameter <cl@linux.com>

> ---
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 57a24e919907..c759b526287b 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1370,6 +1370,7 @@ static void refresh_vm_stats(struct work_struct *work)
>  	refresh_cpu_vm_stats(true);
>  }
>
> +#ifdef CONFIG_PROC_FS
>  int vmstat_refresh(struct ctl_table *table, int write,
>  		   void __user *buffer, size_t *lenp, loff_t *ppos)
>  {
> @@ -1422,6 +1423,7 @@ int vmstat_refresh(struct ctl_table *table, int write,
>  		*lenp = 0;
>  	return 0;
>  }
> +#endif
>
>  static void vmstat_update(struct work_struct *w)
>  {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
