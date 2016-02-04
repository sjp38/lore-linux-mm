Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id ADFF34403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 11:43:47 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id 65so50273580pfd.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 08:43:47 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ra6si17662498pab.90.2016.02.04.08.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 08:43:47 -0800 (PST)
Date: Thu, 4 Feb 2016 19:43:37 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v1 2/3] /proc/kpageflags: return KPF_SLAB for slab tail
 pages
Message-ID: <20160204164337.GB16895@esperanza>
References: <1454569683-17918-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1454569683-17918-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1454569683-17918-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Feb 04, 2016 at 04:08:02PM +0900, Naoya Horiguchi wrote:
> Currently /proc/kpageflags returns just KPF_COMPOUND_TAIL for slab tail pages,
> which is inconvenient when grasping how slab pages are distributed (userspace
> always needs to check which kind of tail pages by itself). This patch sets
> KPF_SLAB for such pages.
> 
> With this patch:
> 
>   $ grep Slab /proc/meminfo ; tools/vm/page-types -b slab
>   Slab:              64880 kB
>                flags      page-count       MB  symbolic-flags                     long-symbolic-flags
>   0x0000000000000080           16220       63  _______S__________________________________ slab
>                total           16220       63
> 
> 16220 pages equals to 64880 kB, so returned result is consistent with the
> global counter.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
