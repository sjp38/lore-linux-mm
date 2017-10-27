Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9A3D6B025E
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 06:00:56 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f16so11169353ioe.1
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 03:00:56 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id f83si5062706ioj.242.2017.10.27.03.00.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 03:00:56 -0700 (PDT)
Date: Fri, 27 Oct 2017 05:00:54 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: extract common code for calculating total memory
 size
In-Reply-To: <1508971740-118317-2-git-send-email-yang.s@alibaba-inc.com>
Message-ID: <alpine.DEB.2.20.1710270459580.8922@nuc-kabylake>
References: <1508971740-118317-1-git-send-email-yang.s@alibaba-inc.com> <1508971740-118317-2-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 26 Oct 2017, Yang Shi wrote:

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 935c4d4..e21b81e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2050,6 +2050,31 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
>  static inline void zero_resv_unavail(void) {}
>  #endif
>
> +static inline void calc_mem_size(unsigned long *total, unsigned long *reserved,
> +				 unsigned long *highmem)
> +{

Huge incline function. This needs to go into mm/page_alloc.c or
mm/slab_common.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
