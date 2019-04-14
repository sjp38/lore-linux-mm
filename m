Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9306FC10F13
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 16:16:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DCE520880
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 16:16:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="gQ9mxgkM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DCE520880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA3F76B0005; Sun, 14 Apr 2019 12:16:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B52E26B0006; Sun, 14 Apr 2019 12:16:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A68666B0007; Sun, 14 Apr 2019 12:16:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F91B6B0005
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 12:16:41 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d16so9744264pll.21
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 09:16:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AmVc2Ys7kjMZPrGHDiRw74fv+p7eWkApGqt2G9I/vMY=;
        b=pl2tMSmG7Stw5wktbRK7tSOBMeMtWGYFcJQ3EXBJN1UZjaYnGOtvvL8yiQktmMMQ3j
         wuO8pTSqYrswfmXTBsOMP5tWbHO9m9jhGj8rNcGjln668PXZ+YjTYKYD4OhRuk3tYsUe
         IbLyIh1dZqM5XXkhA5rKoAb1oj/O4Sx0krk25CdhwQob46XYCq79jow9ZJqhFh9FglV4
         cEJPF+xfM5+V/CnjDqP1/ZV6agTZ2achDReWSonDsfiIxBu3HSDBrXGzU54GL/tASNty
         yVr4DrQwOQqWvjOYZinK5mEb2GfYRabSDG7iQt/w+h4bBafpw20GzOj7mK2KxywLrFtt
         mR3A==
X-Gm-Message-State: APjAAAVScKdHhouo8BTMf3pnso5QsU98biItvX4Vvdsh+K/mPVGN2qKs
	sGgq2JBWDWauACBry7jn/fcpg3JPx5D9wjuBHCEPvPUaar25+2J4oclNVRf7nNcrrD+Ut9AjXbS
	hkCQg4BkZj0qjGNXDQmCbP7U6vu2wD1XNtf0TWRwyIkY9PIMBu5MCgL13HJp4ifO1vA==
X-Received: by 2002:a62:ee0a:: with SMTP id e10mr70036342pfi.6.1555258600911;
        Sun, 14 Apr 2019 09:16:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxah7K8egQu6DMnA3VIkZMxL47078e+rgpB7YOIa/mrhB9bY0Svk/NgXKCELtZ8cqYDz07
X-Received: by 2002:a62:ee0a:: with SMTP id e10mr70036284pfi.6.1555258600105;
        Sun, 14 Apr 2019 09:16:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555258600; cv=none;
        d=google.com; s=arc-20160816;
        b=zcnzp4eQrW9g8aVcf8J7Rw6RqH9QeuIV+kknICXlc+j2nFEDqosSa/JJOZz0lEAd3d
         KdRV5JF3QxjZ+sARFxCEvyp2y68va5aYUiaBbIywj2IQiiBypLDyuv8GoO1bcdNFpRcH
         83vFj/EdJrexloIU3IRmZi+79zdCMAwPrRAvCGm3/+PzTYM4Ns+kkZ/PyM1Zqu1iW2Td
         2da/vvwBXXk5WhglFSWT6Gvpo4SG12BL4OjO7sFnfGJfHjERMroa4ob4Jux1SHCKitgK
         TDzN/rhJj0sMIk8Q1doCAAKQmS3poy9lERjf0Ejy/+OOAQI1HY0AWvgUscfgBURzHqvn
         JwNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AmVc2Ys7kjMZPrGHDiRw74fv+p7eWkApGqt2G9I/vMY=;
        b=p1oVZqACKWokrkAjzujsjZA0j9NbNlc15tUgRI6kizV8D+MX61azKuKPD1VgvxSnfX
         7MbUzEWNwImnd+CGtJV0PLF+hBUn/gSiu1sElK+/FwFIojdyKJ7/DwMsZiBNQiBQ1IPH
         e12090sCNW9JG9MRbDh+ytAJVw2e9bhm7WAB1TZppiBAJbdJGSEeg0kffAU76p/S7v9l
         n6S/V7F6CXMg4XmBHwWf9LXmUmUSJ5aHj4vWSCnia3xSsASItX2m3osmYeFO47KNLjYM
         91IYsqSbCloI45iF6gYyBucGL+FJ3utmggX6zYb3coXWtzpJV0TaOD7RKHxwyQypqwgx
         65TA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gQ9mxgkM;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j73si26633223pge.370.2019.04.14.09.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 09:16:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gQ9mxgkM;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 70D412175B
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 16:16:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555258599;
	bh=+Ku/5BjUoC4T6P/q2jGkMG43TTUSVUGvZJLf9C8ijZI=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=gQ9mxgkMp/q5HEu1w4NYo9Kf+rtmLe9ex7uPphPQEZOuEIIKJvED5doHqdRjz8w7V
	 Nwy44nkFslAD5WFaZOeKskQvdS/HRUdKf/tTX2h11f/sDAtiGkEcj6n18HoFlkmD2m
	 X7WfgHXxN8dnXpEf9ShFrB5PHRCCTbx9QFqiT0Og=
Received: by mail-wm1-f47.google.com with SMTP id q16so17388122wmj.3
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 09:16:39 -0700 (PDT)
X-Received: by 2002:a1c:6c04:: with SMTP id h4mr19021074wmc.135.1555258598010;
 Sun, 14 Apr 2019 09:16:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190414155936.679808307@linutronix.de> <20190414160143.591255977@linutronix.de>
In-Reply-To: <20190414160143.591255977@linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Sun, 14 Apr 2019 09:16:26 -0700
X-Gmail-Original-Message-ID: <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com>
Message-ID: <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com>
Subject: Re: [patch V3 01/32] mm/slab: Fix broken stack trace storage
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
	Sean Christopherson <sean.j.christopherson@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 14, 2019 at 9:02 AM Thomas Gleixner <tglx@linutronix.de> wrote:
>
> kstack_end() is broken on interrupt stacks as they are not guaranteed to be
> sized THREAD_SIZE and THREAD_SIZE aligned.
>
> Use the stack tracer instead. Remove the pointless pointer increment at the
> end of the function while at it.
>
> Fixes: 98eb235b7feb ("[PATCH] page unmapping debug") - History tree
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: linux-mm@kvack.org
> ---
>  mm/slab.c |   28 ++++++++++++----------------
>  1 file changed, 12 insertions(+), 16 deletions(-)
>
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1470,33 +1470,29 @@ static bool is_debug_pagealloc_cache(str
>  static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
>                             unsigned long caller)
>  {
> -       int size = cachep->object_size;
> +       int size = cachep->object_size / sizeof(unsigned long);
>
>         addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
>
> -       if (size < 5 * sizeof(unsigned long))
> +       if (size < 5)
>                 return;
>
>         *addr++ = 0x12345678;
>         *addr++ = caller;
>         *addr++ = smp_processor_id();
> -       size -= 3 * sizeof(unsigned long);
> +#ifdef CONFIG_STACKTRACE
>         {
> -               unsigned long *sptr = &caller;
> -               unsigned long svalue;
> -
> -               while (!kstack_end(sptr)) {
> -                       svalue = *sptr++;
> -                       if (kernel_text_address(svalue)) {
> -                               *addr++ = svalue;
> -                               size -= sizeof(unsigned long);
> -                               if (size <= sizeof(unsigned long))
> -                                       break;
> -                       }
> -               }
> +               struct stack_trace trace = {
> +                       .max_entries    = size - 4;
> +                       .entries        = addr;
> +                       .skip           = 3;
> +               };

This looks correct, but I think that it would have been clearer if you
left the size -= 3 above.  You're still incrementing addr, but you're
not decrementing size, so they're out of sync and the resulting code
is hard to follow.

--Andy

