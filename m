Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B752FC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 17:37:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7139921019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 17:37:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="FgSTNGfr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7139921019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06B066B0003; Tue, 21 May 2019 13:37:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01BAD6B0006; Tue, 21 May 2019 13:37:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4DD66B0007; Tue, 21 May 2019 13:37:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC52B6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:37:06 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id u128so11628875qka.2
        for <linux-mm@kvack.org>; Tue, 21 May 2019 10:37:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=hc0/BUKgUjDfp5UyEzfAVwM6axcjh6mZxMvpraGYMr8=;
        b=TUps9EVP3S9FtDdvuen2dpEBLIuZ+raEP68ogwcalotCVYyVoytH+wcYrYI1ybs/JF
         m9W6+C78b5HUedroUwMDTfcatQkCc7bQVq7Qz0dSy6EerkRrhyoMPX7tC8AKaiyjOShs
         M/ilED2q6SjmzammNTqMd79jtvwzCbm+Zh0wbYnY2ewXZlrN7h8lpCY39TFhjPAVcGH9
         2dCAxPFOgz+Atd/lCNOm3BrFvZaVR7bTg+QyWYFkouTkIk1OX2AxJgtkTEoLm0SISSlf
         g+tvLPgI4oI/FDfTLbLf551jVWdz6Injtv3VNmAeD1MfGCJpbt+nG2VTl7DO3DRYDwXP
         9mRw==
X-Gm-Message-State: APjAAAXsrsAl5GSJZDZqgnNlO8OUgkwJkU4+CEc+kbwQ33LFBy/B39Bz
	pDYEkC0fTJYwnyLOOi/kL4EH4dZm4bOoRkukNItR648OzBH3AtokO/GvaJiD6oLHhPvAcecFuxM
	zUU/MAyZAf9AL4d6WzGkVvh7cSvSb1e7jp0VR79c8aSrMssoSHYpiwL/1o/o3sgw=
X-Received: by 2002:a0c:b17a:: with SMTP id r55mr49910929qvc.206.1558460226642;
        Tue, 21 May 2019 10:37:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8Wv8kkQa5ncvH/y6TVxKN9QN5fRt+D1+FF5UeMqGG3a4BEbO/IfDJ1VqS6BGwWhrvXBKM
X-Received: by 2002:a0c:b17a:: with SMTP id r55mr49910890qvc.206.1558460226142;
        Tue, 21 May 2019 10:37:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558460226; cv=none;
        d=google.com; s=arc-20160816;
        b=vRW0r4hos5nFNgJGqK/bazzVDyCkUXpmDh/+BRj7HPZEXFAW9f32OpsCYPNU4LT5yH
         j7aQJIUMbwFQU5p/Jm1zGQkkVnf5XBTG3/S64T2UqmI9tgWXafiiSg7mvJUwKipxhfit
         TdPbbxFL9Lwt4n7ysVOUXWKR/yKSQ9jXFxbVZ4OXyqbwc+e7q6J1fvgX2ycGgyxK8dTk
         bWeDXdvzzRVwtFT9dsqHx69AdI/CLFgzdekSsfDqC2BrGZcoMBTOJFv7xdCbEry88yb6
         HFwn9PAAKOnNaS7j7ZOjwKmcDrX7nOk3mTrOa039nONGroKba94EyUq+Gda0rghCe5l/
         OWYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=hc0/BUKgUjDfp5UyEzfAVwM6axcjh6mZxMvpraGYMr8=;
        b=y983BdaWtK8FM3+hroUqyQlxw1ZXW9XzwDqFkTNve9wzH5m0PG27tUAs3Fd35jj+Fs
         d2z0zEsZMsMrYB16vh45i1qHt02weL5wmkjbQvy856WX7ZQqedgeFKYRU+N3VwLwOFfc
         bGdPTid8T+7T9yGW4VrTShJoOa+Ae+LxTSs03UFaRbm1uFFLsYtLgNRuMgRefs6+KrwW
         AfRd1x8FNgzGkF6z8y+Oa38buctwD+2yPefRE1YhUrBKe9tbRHfi9cokeN7xdNBwb/vZ
         Fxki0pI6lqKPqhphfy07zpHZku38eUxyBXVlr+vnhAZMzhFceeYh0UK+I4VwDL5wtg3/
         GltQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=FgSTNGfr;
       spf=pass (google.com: domain of 0100016adb77d817-18d39284-976c-4cac-ad92-b46316534dbe-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=0100016adb77d817-18d39284-976c-4cac-ad92-b46316534dbe-000000@amazonses.com
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id g54si1737814qtb.184.2019.05.21.10.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 May 2019 10:37:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016adb77d817-18d39284-976c-4cac-ad92-b46316534dbe-000000@amazonses.com designates 54.240.9.34 as permitted sender) client-ip=54.240.9.34;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=FgSTNGfr;
       spf=pass (google.com: domain of 0100016adb77d817-18d39284-976c-4cac-ad92-b46316534dbe-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=0100016adb77d817-18d39284-976c-4cac-ad92-b46316534dbe-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1558460225;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=hc0/BUKgUjDfp5UyEzfAVwM6axcjh6mZxMvpraGYMr8=;
	b=FgSTNGfrqsrblnIl/lCTiPv3wlbz+X9x9z5hJXCDH1UaOVOWqa/dMcb4vkX0BxhK
	YeaQMGsZAZj1BeHhkHC79v+BSEfUb4EUB4DKL2alF9QDP1fFZ52gCHnuezf6LkqkjY7
	9sk+ILbNN+wpagdH+/bXQS7gYYj3wbqMpKGdz+Wk=
Date: Tue, 21 May 2019 17:37:05 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Qian Cai <cai@lca.pw>
cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, me@tobin.cc, 
    vbabka@suse.cz, penberg@kernel.org, rientjes@google.com, 
    iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH] slab: remove /proc/slab_allocators
In-Reply-To: <1558036661-17577-1-git-send-email-cai@lca.pw>
Message-ID: <0100016adb77d817-18d39284-976c-4cac-ad92-b46316534dbe-000000@email.amazonses.com>
References: <1558036661-17577-1-git-send-email-cai@lca.pw>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.05.21-54.240.9.34
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 May 2019, Qian Cai wrote:

> It turned out that DEBUG_SLAB_LEAK is still broken even after recent
> recue efforts that when there is a large number of objects like
> kmemleak_object which is normal on a debug kernel,

Acked-by: Christoph Lameter <cl@linux.com>

