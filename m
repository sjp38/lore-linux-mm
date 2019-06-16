Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A477BC31E50
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 16:27:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69A6820679
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 16:27:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ritRXhRU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69A6820679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07DA08E0002; Sun, 16 Jun 2019 12:27:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02EBD8E0001; Sun, 16 Jun 2019 12:27:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E86C88E0002; Sun, 16 Jun 2019 12:27:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83C3D8E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 12:27:19 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id e16so1534683lja.23
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 09:27:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=cVuvolx0crP2RdRYi3l8AqoSD+eqXL2UwZAQBs6f87k=;
        b=ex6gBds2pqOHRfPAH4z1y+r7c99905v2WlRaVWyx2zujML1Jhta52mjP6rwqidNedL
         Ea+KIyrTdXNTdRECMEnI7GzPg3Ju6JXtpohyO15403G+CzHK9UHz/+omH4uVvaszKsjZ
         61aK7Kuk43aC9lWT5921xAxdsSVGpBxoy9u2uECN3a7k8ZlqLxHHmhiZWDbvVRHz7eGO
         XcfoHDyYB/v03G0XbNfTehBhGfjjPr+QVNLPYoooF3szrU7E8jQD7oOuVSSddJcms4+A
         weATfBxs2A8sSHWUEN3lSQDjLVUWRnRxKC0BXIEcPnerWE7aYWGC8MaLLCEj6Tqr2Mzm
         QYUw==
X-Gm-Message-State: APjAAAUB8hLKbwON+r2QWnpihiUbCqYI1DF62OukVLZBluySnpEihrHQ
	aePaaUaLOfQ/0yiM44OdvB2Orm27/R2hU21Ze7cbt495GV5Mnc+5rmADcLXnPW/tmXuqrwsEHpK
	JxNkoL1iBcxhe/AYhU7eTpCZKLGtg5blgUe54eB+DSrMVK73Pn3wP2ETaOk0kOW0Cag==
X-Received: by 2002:ac2:5ec6:: with SMTP id d6mr7972404lfq.131.1560702438839;
        Sun, 16 Jun 2019 09:27:18 -0700 (PDT)
X-Received: by 2002:ac2:5ec6:: with SMTP id d6mr7972380lfq.131.1560702438150;
        Sun, 16 Jun 2019 09:27:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560702438; cv=none;
        d=google.com; s=arc-20160816;
        b=o0M7I6iT+jUAvYVSIdi9h6noW91ASU8/2y0uRkTRvYhNrIjPWXsP0VmI5Z7cOuu7If
         izYwpkBpBrsvykowC35kdJZGzvU0iO5zbuoD5ZGXE8stUXKL+HpGJAGCFUr4TE7uAi4r
         Rv+uMSspOyw3tEj+by42XM1x93eVGIfFuXoAtZVBjwZNDnqq8Yxllg9upvm07m8U5XnN
         jNWoRlqZUv0SfxA4wNSdh08cpzkslL9OsSe50GSJrgUu+V//s+8DB08nkkbh5Pxih90h
         RO27Z4EwHjA9rpyGk+SJBwtoz9yWQklc2ekMiP6lkqu0NXgXO3baj7M9FvvccvB1cipl
         izpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=cVuvolx0crP2RdRYi3l8AqoSD+eqXL2UwZAQBs6f87k=;
        b=U5BmykQbYdUZ1SOzj6xTFpZa/+NccRMRugofqPB5gRNgoAv3B4xm7utw25kKBiACqG
         1bfYWbcl9NiVEXiFsKiAf3R14FO/ijlb+AVtizUu3vumyyLCABWMy00c7nylfiCWiF+m
         yiTMeFPyqy3Z2ikkRRH+dYkcM+/u2PRaGf2HhcF1IyWoIN7CAfNBCWiLYkMUCnP3OCnv
         ZUS+qHZK0BEzy9LKy+Fg7a5V+5gbizGZyzWRIaOERkikFu4JRqufmVEnC09tgom35nmJ
         ixFBca/mskkIhu0KLda76f1zGTmi1TpEaDj57qJt14+HEg5hl3FGCzUL4SVv7KRZDfBR
         YpDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ritRXhRU;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d26sor2009267lfj.65.2019.06.16.09.27.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 09:27:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ritRXhRU;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=cVuvolx0crP2RdRYi3l8AqoSD+eqXL2UwZAQBs6f87k=;
        b=ritRXhRUWri2ajUBEJqAb8sN7dg1so0SakcFYpITeSodyL6ROwOWOP1wruSQb7gM0E
         7v6zL7TWZjx4HEyzGcit1ShuLzToPmJWmc/hJw4+7X4KIKNjf/3eK0QhqY9G7X78+6wb
         WeCCIKjMV9ERdSda39uHxZxuuViTUcjDR+nV24QFyTAcEGCqwf/MhFotRPdDxhkjO03g
         2xJvt6erCxUEWOuNvuvY5gK21c7TMNkQXwrI4on+F8rb/hL0v12NyL01o04WyE41x1lq
         foRlj2rPRgZ8U+Bggen1bNvqHkRLmKP7qNpb97M9YOVxRGp3JN/CZP9OEG7AReKQC/Q7
         Rorw==
X-Google-Smtp-Source: APXvYqzy25joefgU8Dw0kC+dz7ltpG9ilwsoYNoU+2LxGFnAeuLIcpR8rTBaAdSrO6lhpOx8cDgMDA==
X-Received: by 2002:ac2:47fa:: with SMTP id b26mr18365774lfp.82.1560702437898;
        Sun, 16 Jun 2019 09:27:17 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id q4sm1844099lje.99.2019.06.16.09.27.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 16 Jun 2019 09:27:17 -0700 (PDT)
Date: Sun, 16 Jun 2019 19:27:16 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v7 07/10] mm: synchronize access to kmem_cache dying flag
 using a spinlock
Message-ID: <20190616162716.broxurphhmvdzy5s@esperanza>
References: <20190611231813.3148843-1-guro@fb.com>
 <20190611231813.3148843-8-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611231813.3148843-8-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:18:10PM -0700, Roman Gushchin wrote:
> Currently the memcg_params.dying flag and the corresponding
> workqueue used for the asynchronous deactivation of kmem_caches
> is synchronized using the slab_mutex.
> 
> It makes impossible to check this flag from the irq context,
> which will be required in order to implement asynchronous release
> of kmem_caches.
> 
> So let's switch over to the irq-save flavor of the spinlock-based
> synchronization.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

