Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AEB1C28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 12:29:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54D2E208E4
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 12:29:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mCVFoo7u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54D2E208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D04856B000D; Sun,  9 Jun 2019 08:29:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB3C96B0010; Sun,  9 Jun 2019 08:29:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA2F56B0266; Sun,  9 Jun 2019 08:29:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57A696B000D
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 08:29:12 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id 3so139901ljq.12
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 05:29:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=MXL4qzS5tDYfPtk0bERwMQ8xPqTAnXucMreBi2SqrNs=;
        b=jL1qb2DkiZpIKxBkRSHYLSU4PVQnkYiSOnas3cUZ554SLJvqmDlvn3GD80pH9XaGOQ
         uvnFpMx2wd+lPQEWD+iwInK9y5RO+1RUrkLgnFFiRPG8y6lOuXGC6NJfUS4a7bmhmkYN
         GDCsG7lcCBdsspXKAqO5N/ItUTWhZmqd1YApghww7lgM6ejd24+YqRwOsANHktmuh5VO
         vJCvaGEtxVPptmtVq5jMHrz5Vf6YXSUdPpJtFX+xCOPrGgmHiVaGDUNlqvtVFZ9c7LaE
         Y6CeHejSZvb4XMCthLIt19BWEx2zm2PfZBimUuH2EdnjAOZMMYu3VJsNcv/MFlKDXxsm
         Zf5g==
X-Gm-Message-State: APjAAAWQODwSRAuK17xa+a2FNqePBvIPKzUu/JaIBCp4KPOuo57sZsgK
	WmJFQfLTfdCtzXaxZnjSXeTbZwNuMRmQ1yhVm46arIj1NyH9zwkUP4U+d0X5plZAK/43n30WJXJ
	CNUR6eMUN0Qs/R5E2WZ57MjmtNTydC172i6djEYOgOnoRmpwpS5Bk2BoWG82YHLykLQ==
X-Received: by 2002:a2e:2f13:: with SMTP id v19mr25540815ljv.203.1560083351843;
        Sun, 09 Jun 2019 05:29:11 -0700 (PDT)
X-Received: by 2002:a2e:2f13:: with SMTP id v19mr25540796ljv.203.1560083351169;
        Sun, 09 Jun 2019 05:29:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560083351; cv=none;
        d=google.com; s=arc-20160816;
        b=hzgVbwCErVxCuWF6bvp0nxzK56ygEGApUQqvz05+NU4yaK/1N/tO5gJPDOGChAoZ1X
         XpXxM0g7e3eOf3ZhafORGOWIXfZPs3HXhe+L/E7z0AtVfzza3MfkDpTDk4vsHup/O4C2
         p1W0kJYvYqo9Sw25gH6RS+IMm5E+6YJJoGSeEUA8UMuB23ZwPF2U0grQ/WmWiYc9YxpG
         /hREELizh6FqmVb8CVGC6q3GdQmbMw1rWeehYJ/M/JdZ51MkJvVa7Bf/u+TznLN6KUQe
         idFiO+65iJSpNNVubkRYURTwPYdhYrIwv9a+JJaSMDmchzHgY7pnedQMuer2vmzGuVmw
         DdQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=MXL4qzS5tDYfPtk0bERwMQ8xPqTAnXucMreBi2SqrNs=;
        b=qmg/g4BPFd+kQeKkrbj2eP3uusTm3Zz6268HTAbR8D9LchjfeKw5nsbynSx/I6WmJG
         mnADZSC+gBAJECKRcWThhR+yRcyT8VlZVThibin1khxy+w8gOSSmSYhpgvG80PX5izwc
         mzcoPVt7ZQOzo1R6vgeT4K11sakag6ZsqG4D0rlEDamL/O/2KD78Or0fQljiSAu5nbod
         VckAIcSvRJR+xgGfUp3b1sWYjd/0lkMORykHLDUfA/aE8dQuO9807IHzaj7ij3pWhDQR
         ulGASD7HLgZRyVoYjWy05rpDZ+cU9apA6zo6WqS3v4dJTKhGnjcibUpPxO/hQ9jezKL8
         aIHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mCVFoo7u;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t12sor3507734ljh.37.2019.06.09.05.29.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 05:29:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mCVFoo7u;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=MXL4qzS5tDYfPtk0bERwMQ8xPqTAnXucMreBi2SqrNs=;
        b=mCVFoo7ulhKZFDXXA5kN2vuD7BliZW2iWtD8iSLmPJm8KpLV02zs2ncV98/tWXuqGm
         7M0CPaYeUnWZLMHghcjDl7bEeD0p1c1YUW84Vn99W5QD5MY/eWHY8Bnd6ga7oUgs3yWB
         31zs/BymNy8XV61jusfjmH4lZ6gat/66JzJzCZ3jfhRDIv+ASGIj/qwYNNVtuJf3nMcw
         h5NX7BoOxyjemzkNlZ6d7rWXtPJRWdbwJGecgDqOj0jsL4LRKwN8KpozzX0T/mwKHXAe
         8ooHbKQqo659Ur68uoPngVZi18rJw9C+/4r1LaP1I3a9e6xAlxP0+BgVCGfAwIeN60lC
         aHUg==
X-Google-Smtp-Source: APXvYqyoBPCE6WKWoKCNyKKaK4VA43l9wIL6YzGk9O3XcYlZCZ0XRvRoRPgTDbDDtZ2uyMI1ay9aJQ==
X-Received: by 2002:a2e:86d1:: with SMTP id n17mr10475622ljj.58.1560083350819;
        Sun, 09 Jun 2019 05:29:10 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id 137sm1337886ljj.46.2019.06.09.05.29.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 09 Jun 2019 05:29:09 -0700 (PDT)
Date: Sun, 9 Jun 2019 15:29:07 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 05/10] mm: introduce __memcg_kmem_uncharge_memcg()
Message-ID: <20190609122907.glceyxdaexmau74f@esperanza>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-6-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605024454.1393507-6-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 07:44:49PM -0700, Roman Gushchin wrote:
> Let's separate the page counter modification code out of
> __memcg_kmem_uncharge() in a way similar to what
> __memcg_kmem_charge() and __memcg_kmem_charge_memcg() work.
> 
> This will allow to reuse this code later using a new
> memcg_kmem_uncharge_memcg() wrapper, which calls
> __memcg_kmem_uncharge_memcg() if memcg_kmem_enabled()
> check is passed.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

