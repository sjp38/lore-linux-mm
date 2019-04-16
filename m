Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89113C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:30:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45D8320821
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:30:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="flPVawiL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45D8320821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C77646B027C; Tue, 16 Apr 2019 12:30:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C26B06B029E; Tue, 16 Apr 2019 12:30:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B14216B02A8; Tue, 16 Apr 2019 12:30:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 913886B027C
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:30:42 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 54so19862822qtn.15
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:30:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=ro9SZF+a6pVbv+REtQYU1Dw+OJ2X/ZaeB8xzs9UAj64=;
        b=OcLE3vIeVGiJ6bp+AWsvS1yy/y6g7WnmGU0ff/RjxRztTdSzcMtfOEX+jAiyvF5j3C
         zmhW5FyjX15Bn/cgJdxuADgP3mcxWO8LNfs81nPNDwuuKyeZNgz6S2d/2goqH3dNNZQ0
         d5eAc7zNbP+gHoKk6bGVNqwRBLw7RKoj7bodpfxyJMJbH/7ncq28WjiAtTEwBRqK8ZQe
         gQPiieMd9khY5G1IXK12Cf8jIM3+vnVpqafKQT7Vfzipg2GGzOBpK3XGz0Er1GbBUofx
         6H7RFCH809qSqTHsDS53pvDS/nTd9daJ/mdSdrJamFblllnpnicvn60EVlg7OsEAeudL
         Vh+A==
X-Gm-Message-State: APjAAAUlBXnKwZQPWyME1ntLrO1zofawxC/zS2ZHluVH7ceq/WBpylB9
	y5sBuQFNbpntS+QYZxKykrG/dG9BD2YfZEXvMHDgIM3smyg+UMl/qQinY6AVWRC6DtIxtfkPLiC
	eCAcN/XScNCP8MqSrsttMqVhAqlOJ3P3xoTM90aFW0Sne8Lyl4nBwYsr/DEmhJpI=
X-Received: by 2002:a37:4ed5:: with SMTP id c204mr65349264qkb.68.1555432242238;
        Tue, 16 Apr 2019 09:30:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcKuU/TG9oSoeJteJtsSkJLmCcCfITxCJrWvF/nXy8x/vLD4pvnWkbGFiZqJCDXnB87Po4
X-Received: by 2002:a37:4ed5:: with SMTP id c204mr65349187qkb.68.1555432241373;
        Tue, 16 Apr 2019 09:30:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555432241; cv=none;
        d=google.com; s=arc-20160816;
        b=QC9zReoM+jJmVLGuwgOCLrzGbDtOtx4H14fH9aYTieX1WtXGD8M2BYICW5DA5neb28
         LTeGSZ9yw9U+SOgHk4QGwisUkXx3bg3Q2zEpq9bM20FrhS/X3XZpiURzp8XEYmC/y9X6
         7KmkHIrYqY3a7vjgAcshWwgMFEO46arMUTJc89peLASobZ2iW4jWfYx0Tm8c5+O5zDiX
         GX6Gcv5mESfToWeHoKZAHzOXOhy03rUjjIK1gq/fiv63ZI3KIAPN36xEnxfrw5Vn45iW
         Lm/SO9uY42THD8Xe8N8anrEBoiVYELk6RVcaynqhUsopu32PwV2XmAMNwciGXJz4hbpD
         VlLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=ro9SZF+a6pVbv+REtQYU1Dw+OJ2X/ZaeB8xzs9UAj64=;
        b=fV397We+A0kwmZS0+wzq5pH3mNKi4C4sTTOi7iyTsYIVzv5teK3tJrduVZPvbjUukS
         l3LPjU1elEmbUWeXWaHt+5PQA/Rxj9a+JfS267TZkYsPbhNaGkL7kSKBFcOliEzq/yBr
         ks5mpwyqbD8Y/4IP0t+1tVK7u5ZGLIYhe0yLmKZEaczutg9yJ+SRHKFCWfZvq0ACip2/
         ct7nnla0M1DumO/OG2rTKxAZr/g0OasFDedqzTihgAssnsMh7js4TboInnSQ3xHsV0Qc
         tJDNk4zEMInT/1JSalst1fxfKvbRRkGcagAUaTruWkaBcImJfK9ACLzOSDq+lyNDPVrj
         hHhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=flPVawiL;
       spf=pass (google.com: domain of 0100016a26fc7605-a9c76ac4-387c-47a3-8c53-a8d208eb0925-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=0100016a26fc7605-a9c76ac4-387c-47a3-8c53-a8d208eb0925-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id t24si5809718qtp.323.2019.04.16.09.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 09:30:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a26fc7605-a9c76ac4-387c-47a3-8c53-a8d208eb0925-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=flPVawiL;
       spf=pass (google.com: domain of 0100016a26fc7605-a9c76ac4-387c-47a3-8c53-a8d208eb0925-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=0100016a26fc7605-a9c76ac4-387c-47a3-8c53-a8d208eb0925-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1555432240;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=ro9SZF+a6pVbv+REtQYU1Dw+OJ2X/ZaeB8xzs9UAj64=;
	b=flPVawiLQNK05a/4cceOBilHYXdQqEBX4lkYs/L+Trm6tUeLz3hG3uL1k7gItumk
	85bdKD8lzLx6FrPviD0x1ZufxFEnjUSQS51R1ofFgffB+7KNw9Me/DVskbXWI+m4cLb
	gImLBrHRRV52b+OpaoPDdlLqEOUMv8psuio/ESXo=
Date: Tue, 16 Apr 2019 16:30:40 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Alexander Potapenko <glider@google.com>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    linux-security-module <linux-security-module@vger.kernel.org>, 
    Linux Memory Management List <linux-mm@kvack.org>, 
    Nick Desaulniers <ndesaulniers@google.com>, 
    Kostya Serebryany <kcc@google.com>, Dmitriy Vyukov <dvyukov@google.com>, 
    Kees Cook <keescook@chromium.org>, Sandeep Patil <sspatil@android.com>, 
    Laura Abbott <labbott@redhat.com>, 
    Kernel Hardening <kernel-hardening@lists.openwall.com>
Subject: Re: [PATCH] mm: security: introduce CONFIG_INIT_HEAP_ALL
In-Reply-To: <CAG_fn=U6aWfBXdkcWs0_1pqggAC16Yg8Q6rxLiVeiO83q1hOCw@mail.gmail.com>
Message-ID: <0100016a26fc7605-a9c76ac4-387c-47a3-8c53-a8d208eb0925-000000@email.amazonses.com>
References: <20190412124501.132678-1-glider@google.com> <0100016a26c711be-b99971ca-49f5-482c-9028-962ee471f733-000000@email.amazonses.com> <CAG_fn=U6aWfBXdkcWs0_1pqggAC16Yg8Q6rxLiVeiO83q1hOCw@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.16-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Apr 2019, Alexander Potapenko wrote:

> > Hmmm... But we already have debugging options that poison objects and
> > pages?
> Laura Abbott mentioned in one of the previous threads
> (https://marc.info/?l=kernel-hardening&m=155474181528491&w=2) that:
>
> """
> I've looked at doing something similar in the past (failing to find
> the thread this morning...) and while this will work, it has pretty
> serious performance issues. It's not actually the poisoning which
> is expensive but that turning on debugging removes the cpu slab
> which has significant performance penalties.

Ok you could rework that logic to be able to keep the per cpu slabs?

Also if you do the zeroing then you need to do it in the hotpath. And this
patch introduces new instructions to that hotpath for checking and
executing the zeroing.

