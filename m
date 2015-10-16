Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 33B4C6B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 22:28:29 -0400 (EDT)
Received: by payp3 with SMTP id p3so57367621pay.1
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 19:28:28 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id xo10si26092999pbc.154.2015.10.15.19.28.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 19:28:28 -0700 (PDT)
Date: Fri, 16 Oct 2015 13:28:24 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2015-10-15-15-20 uploaded
Message-ID: <20151016132824.10d9ca6d@canb.auug.org.au>
In-Reply-To: <562026c3./QtjCX94PyaQABWQ%akpm@linux-foundation.org>
References: <562026c3./QtjCX94PyaQABWQ%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz

Hi Andrew,

On Thu, 15 Oct 2015 15:20:51 -0700 akpm@linux-foundation.org wrote:
>
> * msgrcv-use-freezable-blocking-call.patch
>   linux-next.patch
>   linux-next-rejects.patch
> * mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-nvem-fix.patch

This last one did not apply and seemed to have already been part of a
previous patch ... so I dropped it.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
