Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4F70D6B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 22:39:48 -0400 (EDT)
Received: by fxm12 with SMTP id 12so625090fxm.38
        for <linux-mm@kvack.org>; Wed, 06 May 2009 19:40:24 -0700 (PDT)
Date: Thu, 7 May 2009 11:40:16 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/7] proc: export more page flags in /proc/kpageflags
Message-Id: <20090507114016.40ee6577.minchan.kim@barrios-desktop>
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

On Thu, 07 May 2009 09:21:21 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> +	 * pseudo flags for the well known (anonymous) memory mapped pages
> +	 */
> +	if (!PageSlab(page) && page_mapped(page))
> +		u |= 1 << KPF_MMAP;
> +	if (PageAnon(page))
> +		u |= 1 << KPF_ANON;

Why do you check PageSlab on user pages ?
Is there any case that PageSlab == true && page_mapped == true ?

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
