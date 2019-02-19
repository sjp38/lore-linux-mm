Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B835C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 18:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09E9A21479
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 18:11:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09E9A21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F2E58E0003; Tue, 19 Feb 2019 13:11:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A2A08E0002; Tue, 19 Feb 2019 13:11:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8695E8E0003; Tue, 19 Feb 2019 13:11:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4879D8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 13:11:40 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 143so14862420pgc.3
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 10:11:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=8trljMhUxj9RQgjcslAL5Kc3oZbD3saMNMec1brseHY=;
        b=rTfYzL3cEso3r1yKpo13ACFNLsNdmb1iMrjaPwevHuFMt5+v7m75H5lD0OBIc5ZJj7
         G7+JgTnZiNcj0ozvCq1u33pLRmPYYt4GGb6fjkMIdH1pHGxd9ZtRF0U+rsXutnLKYGzJ
         uSwnPchjCfWEfSaUlyLFz8/PE9fN80YpzHPfHG3LBRereZ5q3T5n1lM0uJHlgXupu3WP
         rmkePC6/6VZ/1q2yk4j3WC28UZFIJmtfFxx2AOUxskiLywk3KcuDjUbd8ifiLqTiJSJz
         /Bu3YU5kuZDe9qhQHXE3NrMUtDZ8x3zM/OkHAa+YObChca6GbtMlhffWfC8rbMOUvhC9
         j6Vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AHQUAuZUWWhS4KOlXbYtjXeR9OF0DPsLnhp2Pc56q/NjquMA3FUfbjeU
	grJXrxSQGlOmps1G+Ilf4iOYJAIucSA+SUEobqYKSmTRDtbjr6i0Qwll6Y4Bkp14ktiyzCPa//u
	9UUTr1a3htKSiZCr0TPcP3EXJCvtk7zCcFOdux1uBYcz8vh/ubPFphZIyGHQMAKi+nw==
X-Received: by 2002:a65:63c2:: with SMTP id n2mr15054299pgv.439.1550599899872;
        Tue, 19 Feb 2019 10:11:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibt1vZe7qsSPQo6rexhBjAv/239bVOMWF6fuYN53JUGNJlniWEhilWlvVwCHDZfroqNxocT
X-Received: by 2002:a65:63c2:: with SMTP id n2mr15054222pgv.439.1550599898938;
        Tue, 19 Feb 2019 10:11:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550599898; cv=none;
        d=google.com; s=arc-20160816;
        b=EI5CH38Tymi8dgc4UhS2NS/njAb02KN0Yw+V9FeG/KaLKh1uWnFv60+ZMbOMf2rg/6
         irFzHT7T48T9/CQuuwUV7uvu5WJymIb2vQwIt3oG1KtxN3Qt3V22/XyJQCI1oFUe+STD
         wzSt7SVNfNjv3lMxN7ZLXjT4z5ByX3KDz0Iuzsb5kdmqIDz70oSmr3t40hHwXbqx1Ia7
         VPJwA4Tyo3YblMfhYmd3gP2FG4KPZlScUTu0EJb9+fj5LJBkwGM2fivL+wUYO+zouVSU
         LXOTvWphEICo50QHBfIVQB1C0Iva99S06ffHmc11Nu+EQZTJABWleytlBBzDqyNCmu+8
         WqhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8trljMhUxj9RQgjcslAL5Kc3oZbD3saMNMec1brseHY=;
        b=qF+aTVmMi/b3hxQa+4ao/jG8IqfJg9nyEbZuJ2H1RrhuxWItixJUPR7GXtk2y/AC69
         iWnQlWF0iL/5A+DHZldeAGTMBUAp5K9jGyRFPKoLE5ZwI2hYRNz7Itw/npspNDpHAC7l
         IV4doWmLwQZDcAQg+S4DwzQOL9S3V18/+PfwMKJrMjnDplXypOkAPHN1PRE5DyHxIVzJ
         J7MxA6JD8GnLRiPUHvLQz4JJz2y9Uzs6lGjSw7tS+0wayyO/VzzGL4UNEsGnZPEJtNpU
         Fz2aLw8vPGObZYZTM9EZlTGtEsjALdDXCuIiqn+2Fx178PAB7k9ivnbwizE6YRbYbeOk
         c67Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id i8si16577918pgo.273.2019.02.19.10.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 10:11:38 -0800 (PST)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R731e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01424;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TKb7nk._1550599893;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TKb7nk._1550599893)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 20 Feb 2019 02:11:35 +0800
Subject: Re: [PATCH mmotm] mm: ksm: do not block on page lock when searching
 stable tree fix
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: ktkhai@virtuozzo.com, jhubbard@nvidia.com, aarcange@redhat.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <alpine.LSU.2.11.1902182122280.6914@eggly.anvils>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <b3df95be-be74-ec5d-5944-2491cff3e6f3@linux.alibaba.com>
Date: Tue, 19 Feb 2019 10:11:30 -0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1902182122280.6914@eggly.anvils>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/18/19 9:26 PM, Hugh Dickins wrote:
> I hit the kernel BUG at mm/ksm.c:809! quite easily under KSM swapping
> load.  That's the BUG_ON(age > 1) in remove_rmap_item_from_tree().
>
> There is a comment above it, but explaining in more detail: KSM saves
> effort by not fully maintaining the unstable tree like a proper RB
> tree throughout, but at the start of each pass forgetting the old tree
> and rebuilding anew from scratch. But that means that whenever it looks
> like we need to remove an item from the unstable tree, we have to check
> whether it has already been linked into the new tree this time around
> (hence rb_erase needed), or it's just a free-floating leftover from the
> previous tree.
>
> "age" 0 or 1 says which: but if it's more than 1, then something has
> gone wrong: cmp_and_merge_page() was forgetting to remove the item
> in the new EBUSY case.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> Fix to fold into
> mm-ksm-do-not-block-on-page-lock-when-searching-stable-tree.patch

Thanks for catching this. The fix looks good to me.

>
> I like that patch better now it has the mods suggested by John Hubbard;
> but what I'd still really prefer to do is to make the patch unnecessary,
> by reworking that window of KSM page migration so that there's just no
> need for stable_tree_search() to take page lock.  We would all prefer
> that.  However, each time I've gone to do so, it's turned out to need
> more care than I expected, and I run out of time.  So, let's go with
> what we have, and one day I might perhaps get back to it.

I agree it needs extra scrutiny to make the code lockless.

Regards,
Yang

>
>   mm/ksm.c |    7 +++----
>   1 file changed, 3 insertions(+), 4 deletions(-)
>
> --- mmotm/mm/ksm.c	2019-02-14 15:16:13.000000000 -0800
> +++ linux/mm/ksm.c	2019-02-18 20:36:44.707310427 -0800
> @@ -2082,10 +2082,6 @@ static void cmp_and_merge_page(struct pa
>   
>   	/* We first start with searching the page inside the stable tree */
>   	kpage = stable_tree_search(page);
> -
> -	if (PTR_ERR(kpage) == -EBUSY)
> -		return;
> -
>   	if (kpage == page && rmap_item->head == stable_node) {
>   		put_page(kpage);
>   		return;
> @@ -2094,6 +2090,9 @@ static void cmp_and_merge_page(struct pa
>   	remove_rmap_item_from_tree(rmap_item);
>   
>   	if (kpage) {
> +		if (PTR_ERR(kpage) == -EBUSY)
> +			return;
> +
>   		err = try_to_merge_with_ksm_page(rmap_item, page, kpage);
>   		if (!err) {
>   			/*

