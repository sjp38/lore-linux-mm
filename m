Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DE28C28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 12:13:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F37662070B
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 12:13:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pMj0t7O5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F37662070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C9AF6B0007; Sun,  9 Jun 2019 08:13:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 852BC6B0008; Sun,  9 Jun 2019 08:13:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71DAF6B000A; Sun,  9 Jun 2019 08:13:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0880C6B0007
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 08:13:33 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id b13so1342356lfa.3
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 05:13:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=dSKWqv48YjvTpHMzJ6cEr/B8IpdYkbZ87Fgmm26rJBw=;
        b=Zr9oPOMZ2oS0nFoapnkb64nMvlXHQ5evFBD9/aBnc+Tbqm9G9F3xcm7rv0bse9fOZ3
         4qvVUNTDTu/rPsf8P797n78Y8dCl1uXOOtT20xzYZuTWltMSGm14Mj2Lp29LQC2DX5MC
         eaRWZkIxVqlQhdL+0QbIErCuYlQq9dIOZpWVVHeUfmVX5MMj6Q0bSijuULnxqDrt7Y9J
         FvLaFN/mpYH6GQEeSrG9FFTe4Gvw5XrPUpmAKrgDUEkAW39+xf4AaM4utYkrwKtzVjm2
         9IHA2mf9P9fwULFmbK3nwhDk847eskJzfbMaCsb7MXM/tTk3aaMAoa4h/F0+8FO8aIwN
         ew4Q==
X-Gm-Message-State: APjAAAWlAWElgyVbFpJWbLhB8KRMVeNZlM5O3nyjdNkXppGcVb/6G9j2
	JnJZCAB2uW7mTdtCLFLSylCgAgB2+OFHuu4Nzb5yV4NTqT9JX4HCZuAagmpe7oUNYwRO92fEJav
	6rKknbFKZhdrsyxA8L56PlFXoux3rmzjG69UkGYo8uFOGTteI+4qVMSJiGZFlhl2ykw==
X-Received: by 2002:a2e:4e09:: with SMTP id c9mr20692702ljb.30.1560082412527;
        Sun, 09 Jun 2019 05:13:32 -0700 (PDT)
X-Received: by 2002:a2e:4e09:: with SMTP id c9mr20692673ljb.30.1560082411589;
        Sun, 09 Jun 2019 05:13:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560082411; cv=none;
        d=google.com; s=arc-20160816;
        b=kojV4o77mPvUurjhwP+6wxVyE+SQdZ8ZXXz8C+sNj4Z5mY+VFu6eQRpk0qpxOGk5ds
         85BaEKA3fgjw7FQqNvIodrlSz4ZhKXVVYIRMscGcmYzmFxIqF7FnVgkemKov9Q2ebeXY
         Pv70UIJa2vTKbNzN+NLZgzVTpGPsaEj/qk1Q09WNB2BSKvihPsBe7yhVs97VEVhHgq5c
         80X2tPcDg7mQhD/yuxl5m/aguvVE2m4k0iX5+50Thd7SaaO+5gYqQHlppRx2wi5dwBZF
         EwTFWrYDBg1/DvHlPw/Mv4wKwi1WPnUUN9pmIKBytgimFEGwBDpIISU4IWwcef7FmRLF
         ilVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=dSKWqv48YjvTpHMzJ6cEr/B8IpdYkbZ87Fgmm26rJBw=;
        b=id0/jlyJ+s93f2Vun2Cx3ptGJAV25Y56cbQBgLe744s+i/FzwenaAlrX38OgE7PO4T
         /QqnNaZ6E3p2Oa1A3gaQNiD804tUzGB7lDSxytu4AYwRnLAWwaKc/E0i7UHiWpRhWo92
         gC1DO6QShSLvglnVfs8EVlKSoHV52XCbYyLo4vRWtuXVqd5r5LrHe+M6BGZ1ryA0B+ou
         eHj8WcqzmGTfM1xciCGJtscYIESaNhftKQU/2PMAnXhaMrj56F4P8NfplkNodZ2q4dW6
         b2zXavblWoJa9DTxs73LU7juQTH3HDlKCyBtefxbjPuUqMg92ifxwPXl/L9coK2bmGSj
         sLSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pMj0t7O5;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7sor3550114ljh.26.2019.06.09.05.13.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 05:13:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pMj0t7O5;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=dSKWqv48YjvTpHMzJ6cEr/B8IpdYkbZ87Fgmm26rJBw=;
        b=pMj0t7O5EHRJlyEPeUXPVlEG+b9z/hIeBC5taQwe/qsd6JhvdJUyNGAyqEywm28mwV
         FSyOR5XxKyOL9TfhhQgPIXUu0xpjNy41S0bda15ykJzaAbBRAobLofPaf3yti3xoi8ih
         DIbHxtN4r85xSSPukC+eEDm7hzuauH7nnxUP57Ujcta5b+Ha1u/7saPIJroEdVJtxKqq
         h2Ry9LQ6OcBuTv+XdrUpYPdi+LGB5MgSvOhMkuudsx/c4qQGQ6L7wu/6ZJQOmHNmiWgF
         KqkvkML11VzMonJCNns7Xu2wp9XkhQCK3/crnjdKAtvXyEXOTZcI4oD2wVlifWZ/FnQq
         YtIw==
X-Google-Smtp-Source: APXvYqxYVrtnkOtcvtFEQ4emA5XTieW5HptukAIlK1bqxcK9dnvnWv3PlSpIjg8LSFhV9jh6AL+PIQ==
X-Received: by 2002:a2e:2411:: with SMTP id k17mr4072256ljk.136.1560082411340;
        Sun, 09 Jun 2019 05:13:31 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id p15sm1359619lji.80.2019.06.09.05.13.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 09 Jun 2019 05:13:30 -0700 (PDT)
Date: Sun, 9 Jun 2019 15:13:28 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 03/10] mm: rename slab delayed deactivation functions
 and fields
Message-ID: <20190609121328.xaumeyhu7an6qpru@esperanza>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605024454.1393507-4-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000373, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 07:44:47PM -0700, Roman Gushchin wrote:
> The delayed work/rcu deactivation infrastructure of non-root
> kmem_caches can be also used for asynchronous release of these
> objects. Let's get rid of the word "deactivation" in corresponding
> names to make the code look better after generalization.
> 
> It's easier to make the renaming first, so that the generalized
> code will look consistent from scratch.
> 
> Let's rename struct memcg_cache_params fields:
>   deact_fn -> work_fn
>   deact_rcu_head -> rcu_head
>   deact_work -> work
> 
> And RCU/delayed work callbacks in slab common code:
>   kmemcg_deactivate_rcufn -> kmemcg_rcufn
>   kmemcg_deactivate_workfn -> kmemcg_workfn
> 
> This patch contains no functional changes, only renamings.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

