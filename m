Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60393C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 07:46:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED59D2146F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 07:46:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d1R5QsTY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED59D2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DEDD6B0005; Tue,  2 Jul 2019 03:46:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48CD48E0003; Tue,  2 Jul 2019 03:46:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37C9E8E0002; Tue,  2 Jul 2019 03:46:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id C61246B0005
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 03:45:59 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id o2so3256664lji.14
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 00:45:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5IrBPD0J3ThoKKFU4/FQRnog7nkm0QgrOR9tIqfG3FY=;
        b=YQooR681zGYTeCPCKybZmwDsbfpIA0PDKX+6L23JfV5+WTc8rZmElNn+DfyQzS8YVm
         NQdTkjGW0C5gr/wCoyWGPbvqGk2g0RSmM673jrKIrrL4aDfnQgjK1c8QGeCyouiq452V
         XZT0ZsWbAc6yT9EcRa6SvzXMJsgrdWKg+VSE6xhUGHURaVHP7bT/Io4IefupYQPPI+S3
         G13NZYCiVhToUA6jf3+WfExmfEekRgXwZs9YoJWaX33IF4qh09mwomqiFn2bWxEYxUaD
         MfWMdU4N9Aq9mHEHs296KqHg3r/iM36ykkVqvTLHar7ZDLpNLgd2oL2bxpdxAeWYTttC
         v9RQ==
X-Gm-Message-State: APjAAAVQpC7ZHE9Pd5VKtWm7GU5B2REqbfZQBnEcp6FaqiuNgkQIZjkw
	YaBU5P042PCnHmhAekGethyLlqTi+84QfIzPcMXDVrMyd1cwlRNPm/xddjKCLUVHe2pVhn2XEMm
	448koYiFst8MIo/HTBvUmYmP489u7jehCfj9a8gHFxk7WFyOvnEHLz6IVlHTV3joYFQ==
X-Received: by 2002:a2e:4794:: with SMTP id u142mr16679875lja.222.1562053558945;
        Tue, 02 Jul 2019 00:45:58 -0700 (PDT)
X-Received: by 2002:a2e:4794:: with SMTP id u142mr16679833lja.222.1562053558042;
        Tue, 02 Jul 2019 00:45:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562053558; cv=none;
        d=google.com; s=arc-20160816;
        b=UHh0RBVDr7XgreAiN3H1Bg+stdfpI/h/YKDNydTBt1vIeNHjtAs29Z34amRLK5IwJZ
         4+ub6BZ+7AMPkcPynPquSJ+3onB06Q6DozswTcPliPMTLM0+wAKNEJ+w74S3e7rsR+8w
         ZFF0y09ETzQ1souqD6urf1W7203k7gNgVMzNo2oScW48PbsU/RfwtujgrMvtdtNpssRh
         cD6Tsp9U/2Rgsg+CL94AkLphh4G+4skuUAxqE+PDfLYBHkNUKd9hCUZ7xaWgCLbWGL8h
         cIQjii1V34trT4WcKaewlR0X7ZTqALy2pfR5mVapkAuCDhBYBC5dfd4LrG4QU7OjrxoJ
         4xlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5IrBPD0J3ThoKKFU4/FQRnog7nkm0QgrOR9tIqfG3FY=;
        b=fxnGyrNncn7ua401fsLH2QYYmfiOb3NeDxfJCLsaDZcLkc7SBMmdRAWzSVkI96KvIg
         rzEB7YmjKCRrDqZRwYhDLSNvdNbzCV6L/m8iY0agq4pViguJk6XNNFtcpQy9igoqax/3
         Add9BCwCpQefb36aCvXl/IdFLsSIaqkjI0jiLvWdl3yVnBgMqfQ0aRLTZjW+2lcxJ6n5
         +PXV2t4AO8eNY+41j1GzhHoEHwrVEQ7R9QY9sY1GrIrM4nbiH2rpDf0JRdLqNtNnQwJu
         EwOvOG0oCfpDzz9hirWCDz2nTrSNPbZEyzLRn9I6beNudxo+fcF7Wp93Z8hllRQASbWO
         oECQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d1R5QsTY;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7sor6815888ljj.32.2019.07.02.00.45.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 00:45:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d1R5QsTY;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5IrBPD0J3ThoKKFU4/FQRnog7nkm0QgrOR9tIqfG3FY=;
        b=d1R5QsTYa5MTtTEHHeCBzlMg9hZoSTCrw52r1zZF5ZH3HtRyfd1fMwfCVSWnHKA2kG
         4yOBQgQwFxAfrJAoRCkpslMVYXq4M4qzZEhhN5eAueF6CDd47bf1YGy7CVMb4QD9NZ6N
         9FFBS5L6sLobrCnhGda6f/KzikGGytL1t7rQamquIJyhjAVuuWEx7we3wKkf24HvN7Nl
         6GDP08kRaJ2X8lBBU/kp/7dw40Kwc2TysdxBYOdxkhkWZwSAlHYNiQ6QQDdXumAjceiA
         re/bUmjD12UwXfzamlmxA5GbyLp1Ijx3uuJh4MGTHoBwxSrc7K+2vWPk15rDH77JGhPb
         yT2w==
X-Google-Smtp-Source: APXvYqxJ4w6Wee+ZufWo6q87k8jBVJa0des3If6bhXo6eBuX5YbcNlItTrHcH+egqRL+ObwM7oDMNYBaEiKXghKcdow=
X-Received: by 2002:a2e:86cc:: with SMTP id n12mr16247419ljj.146.1562053557722;
 Tue, 02 Jul 2019 00:45:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190701173042.221453-1-henryburns@google.com>
In-Reply-To: <20190701173042.221453-1-henryburns@google.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Tue, 2 Jul 2019 10:45:46 +0300
Message-ID: <CAMJBoFPbRcdZ+NnX17OQ-sOcCwe+ZAsxcDJoR0KDkgBY9WXvpg@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold: Fix z3fold_buddy_slots use after free
To: Henry Burns <henryburns@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, 
	Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Henry,

On Mon, Jul 1, 2019 at 8:31 PM Henry Burns <henryburns@google.com> wrote:
>
> Running z3fold stress testing with address sanitization
> showed zhdr->slots was being used after it was freed.
>
> z3fold_free(z3fold_pool, handle)
>   free_handle(handle)
>     kmem_cache_free(pool->c_handle, zhdr->slots)
>   release_z3fold_page_locked_list(kref)
>     __release_z3fold_page(zhdr, true)
>       zhdr_to_pool(zhdr)
>         slots_to_pool(zhdr->slots)  *BOOM*

Thanks for looking into this. I'm not entirely sure I'm all for
splitting free_handle() but let me think about it.

> Instead we split free_handle into two functions, release_handle()
> and free_slots(). We use release_handle() in place of free_handle(),
> and use free_slots() to call kmem_cache_free() after
> __release_z3fold_page() is done.

A little less intrusive solution would be to move backlink to pool
from slots back to z3fold_header. Looks like it was a bad idea from
the start.

Best regards,
   Vitaly

