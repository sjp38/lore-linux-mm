Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 434546B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 22:04:43 -0400 (EDT)
Received: by ewy8 with SMTP id 8so805126ewy.38
        for <linux-mm@kvack.org>; Wed, 06 May 2009 19:04:46 -0700 (PDT)
Date: Thu, 7 May 2009 11:04:31 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/7] proc: export more page flags in /proc/kpageflags
Message-Id: <20090507110431.b6a10746.minchan.kim@barrios-desktop>
In-Reply-To: <20090507014914.364045992@intel.com>
References: <20090507012116.996644836@intel.com>
	<20090507014914.364045992@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi, 

> +#ifdef CONFIG_MEMORY_FAILURE
> +	u |= kpf_copy_bit(k, KPF_HWPOISON,	PG_hwpoison);
> +#endif

Did mmtom merge memory failure feature?

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
