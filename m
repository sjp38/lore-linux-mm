Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5270DC606CF
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 20:20:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6CC3216F4
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 20:20:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="WRtxMatR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6CC3216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 480168E0035; Mon,  8 Jul 2019 16:20:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 430988E0032; Mon,  8 Jul 2019 16:20:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31E0D8E0035; Mon,  8 Jul 2019 16:20:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8978E0032
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 16:20:58 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id x83so7002916vkx.12
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 13:20:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=uPawzHgSXshI+XHGB6J1ayR3ywnOsHKWmwACBnodim8=;
        b=GkwrilWY05jA3qXmEWzCgmjgNWqwXI3VHK78GGlNCp72pCyifq9/RtHIxVMTvlc7W7
         ilOGqWK3q2of+DF5qhv537jLdyJYbsYDmBzRjdl3twi64CkS42ARexsqKwA2sgFGmTOV
         q8Qjuolkn8RiNqUBAgpQwNyZ1IauemhmJQ3FZV/+oeEJsw3TXijfgKQWn8hXr/bTP41J
         eAUctaFxjNSqy4cIsHzqsVwbfoFaqM05X1cWL2MYl/mvx+7vz2zLr1SGPhcVerrkn71g
         HjOehVCo79IzY4asTi/vs/Gqg5gkbMNF+Sfc2Gk4gQLYuAjfI8VwaiTrquS6jHKlJQZy
         jfyg==
X-Gm-Message-State: APjAAAU+Q+ops1hgzLC0tdLkUKe639nQ2Xd0MfZkTYNsRg11pvUjI/Zx
	9h+LiGGgDedIG2a9Lxp0eDJ5OlJ+G9zWIApykWEg4S69MYy1LbNt7t7vwU3jHa5qafvpoYcTLh7
	WMqV93mlz+M4Gi/bwyOQ2+Hi9yv13kXKDcTqy9Ri3zRSg/6i96uF98BoesoStNFU=
X-Received: by 2002:a9f:3605:: with SMTP id r5mr12182866uad.131.1562617257793;
        Mon, 08 Jul 2019 13:20:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmAa/28d+sEkZbXF6UxB+dwOo7Y/gpXiu2+VwxtjxTDRZFAJNOFTlIYCQU7De1247YgByU
X-Received: by 2002:a9f:3605:: with SMTP id r5mr12182803uad.131.1562617257178;
        Mon, 08 Jul 2019 13:20:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562617257; cv=none;
        d=google.com; s=arc-20160816;
        b=ZjXBIUgD6r/J8arDQdMJNxoDIKlANOKPpES22Fbo/gm12D6rOp3SdD/YSvIp1tE50K
         pWGezEPDXnjoiT/yJROVYXJ4LZErvMB2+56OyODBMw4xc1mlwvQvSOP//jcTzOPrTUuC
         dN+OG73FgAqN/DnBA4ISoJb+pmkNNyKVHNlga4FLu9L6JGIc7Eeb6aNMzvUIoQTodx5j
         WkdsBC59yOQepVnpJZrHD5kilvVRt+0uv8/3/oNzmUixLZsCDl6vT7B2KVogA0jsJVKW
         VMHUCZJ7Y9gbPCjAJ67K3n3ODEeiD33IWeddT3LCpfQkCzFb2elIbD6tqewVBjMK35Nb
         bXCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=uPawzHgSXshI+XHGB6J1ayR3ywnOsHKWmwACBnodim8=;
        b=kzSZBavFczZRAVlV3NiQilQqlqMFIi1XYhIOGBoOEywpfHX+F4zcx4Hj+i9hhCfnby
         OD2XK/Rf2XeNNuUhxZCxKjefALEPPW15bfe6IshJvVLEWM0tlf0rdcsKJHab+5xjVepn
         /J1InZk1V9keKlbuybDab+eGpTd1EEKBJ+pXalgRGQQISvECX1Vd6GCXNDXmE2SXCm3Q
         ixqNZ85icnIW4t/zR5YfcQSIKLeqswZsEPbIXHxzurJ/24bzeYjy2Mrv0578U4T8OCtP
         /B9GIYLPwo/vwXJLu/8Zdwr0bQoaWh8HpNoiDrXGvjmKTHHvrUhB1W02gOInqnGg7GtL
         Y+Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=WRtxMatR;
       spf=pass (google.com: domain of 0100016bd33f19f3-46ea67c2-d930-4e22-9934-41d6b25d5bd5-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=0100016bd33f19f3-46ea67c2-d930-4e22-9934-41d6b25d5bd5-000000@amazonses.com
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id r17si3106372vsp.327.2019.07.08.13.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Jul 2019 13:20:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016bd33f19f3-46ea67c2-d930-4e22-9934-41d6b25d5bd5-000000@amazonses.com designates 54.240.9.92 as permitted sender) client-ip=54.240.9.92;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=WRtxMatR;
       spf=pass (google.com: domain of 0100016bd33f19f3-46ea67c2-d930-4e22-9934-41d6b25d5bd5-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=0100016bd33f19f3-46ea67c2-d930-4e22-9934-41d6b25d5bd5-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1562617256;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=uPawzHgSXshI+XHGB6J1ayR3ywnOsHKWmwACBnodim8=;
	b=WRtxMatR0hA6JDxkxO6CtPf3jkw04T7iVP47f2NnMk6BacWo9MWaSSgNkpSTzctv
	xL1SF+FcGnVBjsVlk2UU338vlietdiGTqB80aJ5ZHWvAtnh+Jn1yy4qxA5QRgOF2pwR
	lSfY4BemfcRxdfFqfDodWcXNAfNoyreGxEYGK8Bw=
Date: Mon, 8 Jul 2019 20:20:56 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Marco Elver <elver@google.com>
cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
    Dmitry Vyukov <dvyukov@google.com>, 
    Alexander Potapenko <glider@google.com>, 
    Andrey Konovalov <andreyknvl@google.com>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Mark Rutland <mark.rutland@arm.com>, kasan-dev@googlegroups.com, 
    linux-mm@kvack.org
Subject: Re: [PATCH v5 4/5] mm/slab: Refactor common ksize KASAN logic into
 slab_common.c
In-Reply-To: <20190708170706.174189-5-elver@google.com>
Message-ID: <0100016bd33f19f3-46ea67c2-d930-4e22-9934-41d6b25d5bd5-000000@email.amazonses.com>
References: <20190708170706.174189-1-elver@google.com> <20190708170706.174189-5-elver@google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.07.08-54.240.9.92
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jul 2019, Marco Elver wrote:

> This refactors common code of ksize() between the various allocators
> into slab_common.c: __ksize() is the allocator-specific implementation
> without instrumentation, whereas ksize() includes the required KASAN
> logic.

Acked-by: Christoph Lameter <cl@linux.com>

