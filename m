Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EFBDC4151A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFF2C222CC
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rZ7V6+h+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFF2C222CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FB2B8E000D; Wed, 13 Feb 2019 17:42:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AAC98E0001; Wed, 13 Feb 2019 17:42:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C1188E000D; Wed, 13 Feb 2019 17:42:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 529ED8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:42:52 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id w15so6646017ita.1
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:42:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1rE3ENum9etw8FLEOLYubxTblJFLNuBz5iBEKWe/uDo=;
        b=A/UD5eZQmr6E/FITjgbQigJhYZlUQyK1jWndvMUkXdfMUuRwuoO4G+1eKSVVY1T5Gy
         kPnmAsN1Rnp8Odg1q5qSnKIZKQ8yvg/g9wiOUFAiYriIccaGlwETmroJQZyVqjkgK/FC
         r3LM8a1eOmAImsyij83fY3i99/d8ax+99vxIb8A9GprRIIuFjrRhWtZn25bXZRqaK2l+
         yGNCYwOKVlBY4bXVVJ3n2E9+7xKk2tdXFHByMQ2mWWhwJWmDz+Br08c6qo+8m9Cf8D4R
         RG+oDwqaQ2B9mhZgyu9ZZdbarwpH1kvpECnAnNr0YiNI6doY5ZSJkraY/9XpocIzWL2X
         9qDA==
X-Gm-Message-State: AHQUAuZCr+r6OnL8XmjI/OEYOnjregkAimPS++QAgfM9Ct4lD52+56lp
	vKpfxARMFk6hebtp/zNp6wbunqFNErKeRNu4GjC7dNJ8Ss0O5MnZrSHntaDFfgVZ/23IYCk7h+g
	pDvLMGD++/2r18NguHY2MRssYPOzI2buGXpGzAuK2PlDkVCmP2ZwPZ/ThfwAqt/BN3m8Mbp5JGU
	dcFNEm6QDse1MxKqtBm4MMYG7Ju/7R3lXY9FiV0e43ubKWcM+ahZjMB9mDQ17HKdQrLbK2KoMu2
	2ZIpP8bTWTTp+FVn1EWR3PQV6IAurvagsqkfoNs+GH4Ekal4t6AdQSHJGrBh3SbToCs0aPy6oBq
	9jeQcWnIQCFhsJ3uG/SUd/Ds6KcjtlJcM076grmIoCJoaWBN0BiErgSoSVFFdHRgXweFtyhAjXN
	4
X-Received: by 2002:a5d:8185:: with SMTP id u5mr366575ion.216.1550097772055;
        Wed, 13 Feb 2019 14:42:52 -0800 (PST)
X-Received: by 2002:a5d:8185:: with SMTP id u5mr366551ion.216.1550097771436;
        Wed, 13 Feb 2019 14:42:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097771; cv=none;
        d=google.com; s=arc-20160816;
        b=K3iqE2NggapMW7XBkO080l/iIv2Ufa+JY5AuWlrKoyEjJ9WQYbQCSESy1XUs+fCa0Z
         428/eSnoJS5lpvfWiYuTvSDhzQEAdPZJhOL7fLhgQUaxHzf5nrete4GTrOuTQpFbtHhi
         M9Se+i0CScFycjrH0zyRPMU0TAWN0ybSL9tZdpoAwSVAXopk7wilrY0LLvLmfMRHnlnE
         SU3G3q39pTOJJZG6CVJpBqPlZJGBCLWAodtkBGjRoHOwHgAtCm8B6W4YZSL7p+PNSybY
         c6qki0suGo6OTo2rybqY/OU9oJhZt2oRjQkz/HnPMMUd+PlkmLixGVnxtcIEPk29gvCq
         5ZmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1rE3ENum9etw8FLEOLYubxTblJFLNuBz5iBEKWe/uDo=;
        b=sTb7c7zr3d8pBo9ftD5+YkocsdCN0bMp/r3Ur9nd4IQMrQB+jG4chscWG2uDoXCMpa
         M/NLLx6G7llkJhBFwK8xHpw2wCiYtfhpH51CFKqn2IKK8K/JWJIyYAw9UOSNoO9bxnTD
         LsQlxcp4qRJ/y4gCV7sXwnKUlqau+mEi6v6i8y4E1REadCPFCqNPuPb/SqG6XwwExzrS
         bhraH6JO0T8qM2LSg/NnMIbMeK4taLosF9SbUtATFf7/GphKet7hdDGOTGO5hHBuzhZS
         UgECnAnwF+1VFWmoERl0qXbs2Hl9RQnBOOsoNlAxZjYCkJiGLaskamh5+qJ6q0CmDnEm
         ZhLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rZ7V6+h+;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m143sor1157904itm.23.2019.02.13.14.42.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:42:51 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rZ7V6+h+;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1rE3ENum9etw8FLEOLYubxTblJFLNuBz5iBEKWe/uDo=;
        b=rZ7V6+h+utXAZGJQoZDjA54bjjYcb7ywLdWYkYK0fi3mff9Dkdg+vxoqqTJMA/HIXH
         DV2KZ6iDhfzxbeh4uFhSNKgpV9rS8l2/lQIA9Wc6SR9Qj+41beo/LKzHrmKcPZOauyyH
         Jntvx5Hg70U633XKv8KFLOM+ulJXhWCqOBRVQnTpIOD/yDRmXSe/RpRI1xLc3mE/MrKa
         V44xvB1CUpZ2qZZzr8XeT21Kwtx6B8CVs89nRNMPDosV9bKK0VWnfQN3Otdjqgfo6p7W
         aAf0R5G3QMrCDHjfAlTpvDdUdMuCqN+ofqroGSqdDWgbB0fcZVPx3m+CWSlJnFMlkSeA
         N9RA==
X-Google-Smtp-Source: AHgI3Ia37dWLigwy1iXWhfEBHuwjMxAIRQlHqD+nA8C5nqLiqJgOwL8GGfYyXhA7B/AkcXW13JbXtgKB2q8oxNDUA1w=
X-Received: by 2002:a24:2ed3:: with SMTP id i202mr291268ita.89.1550097770916;
 Wed, 13 Feb 2019 14:42:50 -0800 (PST)
MIME-Version: 1.0
References: <20190213204157.12570-1-jannh@google.com>
In-Reply-To: <20190213204157.12570-1-jannh@google.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 13 Feb 2019 14:42:39 -0800
Message-ID: <CAKgT0Uc7wheUjStv5a4BSNv_=-iu1Ttdj9f_10CdR_oc2BhVig@mail.gmail.com>
Subject: Re: [PATCH] mm: page_alloc: fix ref bias in page_frag_alloc() for
 1-byte allocs
To: Jann Horn <jannh@google.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pavel.tatashin@microsoft.com>, 
	Oscar Salvador <osalvador@suse.de>, Mel Gorman <mgorman@techsingularity.net>, 
	Aaron Lu <aaron.lu@intel.com>, Netdev <netdev@vger.kernel.org>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 12:42 PM Jann Horn <jannh@google.com> wrote:
>
> The basic idea behind ->pagecnt_bias is: If we pre-allocate the maximum
> number of references that we might need to create in the fastpath later,
> the bump-allocation fastpath only has to modify the non-atomic bias value
> that tracks the number of extra references we hold instead of the atomic
> refcount. The maximum number of allocations we can serve (under the
> assumption that no allocation is made with size 0) is nc->size, so that's
> the bias used.
>
> However, even when all memory in the allocation has been given away, a
> reference to the page is still held; and in the `offset < 0` slowpath, the
> page may be reused if everyone else has dropped their references.
> This means that the necessary number of references is actually
> `nc->size+1`.
>
> Luckily, from a quick grep, it looks like the only path that can call
> page_frag_alloc(fragsz=1) is TAP with the IFF_NAPI_FRAGS flag, which
> requires CAP_NET_ADMIN in the init namespace and is only intended to be
> used for kernel testing and fuzzing.

Actually that has me somewhat concerned. I wouldn't be surprised if
most drivers expect the netdev_alloc_frags call to at least output an
SKB_DATA_ALIGN sized value.

We probably should update __netdev_alloc_frag and __napi_alloc_frag so
that they will pass fragsz through SKB_DATA_ALIGN.

> To test for this issue, put a `WARN_ON(page_ref_count(page) == 0)` in the
> `offset < 0` path, below the virt_to_page() call, and then repeatedly call
> writev() on a TAP device with IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI,
> with a vector consisting of 15 elements containing 1 byte each.
>
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jannh@google.com>
> ---
>  mm/page_alloc.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 35fdde041f5c..46285d28e43b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4675,11 +4675,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
>                 /* Even if we own the page, we do not use atomic_set().
>                  * This would break get_page_unless_zero() users.
>                  */
> -               page_ref_add(page, size - 1);
> +               page_ref_add(page, size);
>
>                 /* reset page count bias and offset to start of new frag */
>                 nc->pfmemalloc = page_is_pfmemalloc(page);
> -               nc->pagecnt_bias = size;
> +               nc->pagecnt_bias = size + 1;
>                 nc->offset = size;
>         }
>
> @@ -4695,10 +4695,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
>                 size = nc->size;
>  #endif
>                 /* OK, page count is 0, we can safely set it */
> -               set_page_count(page, size);
> +               set_page_count(page, size + 1);
>
>                 /* reset page count bias and offset to start of new frag */
> -               nc->pagecnt_bias = size;
> +               nc->pagecnt_bias = size + 1;
>                 offset = size - fragsz;
>         }

If we already have to add a constant it might be better to just use
PAGE_FRAG_CACHE_MAX_SIZE + 1 in all these spots where you are having
to use "size + 1" instead of "size". That way we can avoid having to
add a constant to a register value and then program that value.
instead we can just assign the constant value right from the start.

