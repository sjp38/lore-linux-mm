Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCA27C46470
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:43:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F16B217D9
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:43:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="BQ+JycJd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F16B217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C5C36B000A; Tue, 21 May 2019 10:43:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0760C6B000C; Tue, 21 May 2019 10:43:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECDA16B000D; Tue, 21 May 2019 10:43:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB7FC6B000A
	for <linux-mm@kvack.org>; Tue, 21 May 2019 10:43:39 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id p4so15746330qkj.17
        for <linux-mm@kvack.org>; Tue, 21 May 2019 07:43:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=ugj1TnF91z5+PBr8jQIJ7x5EpDifHr/zSRpWbpp1ovs=;
        b=VUnJZ+JoGNFwKljjqcOytKNsFtJBT3qtOG1JSmT1sm0smfu+LBI/s3gqImpOdPKXwX
         vdJwg4zMwzovav8aiVHDCODLZGljSrvy7jeflc+0HNEFcpB5i5he2icAp22JFkXqRjEN
         cYi8s9sR8+7i5RGAm+NSL+lNU/7IgBhxyBzXZO85TJsh3GyTXGkaQUvW0AsUucZy7GMg
         ioabZ6czHwL81FwlvYm+54rh5RVggUd/TK/rpXukj8+MD4PEgU/Sk/56rHg0OrPlCA1Q
         u5wF6PNPgpMobmxrRlWwy0Qq9GPtSFifm7BE6zVnALWEL4XeQLDNAkuedZfG42FRUOZT
         fbaQ==
X-Gm-Message-State: APjAAAVk0ajvVcjRD5M/Kl7k+y95+d9Zs/vKDutFfcZwz6ZO5vDmQAfY
	jVqW8/z5TwDIbaKyhyVJ6FbAvhNAiLkMuCsz1dI8xc/bDoa9gpYX+G3US4Q3U1VQ/++FjvrQmiN
	G2dZF0f0SwaDIsdp5f8kkzGCIqipm96ISdjqYAFxjYRTzykcKYV9D+EfGpklfu3A=
X-Received: by 2002:a05:620a:136f:: with SMTP id d15mr60718405qkl.192.1558449819617;
        Tue, 21 May 2019 07:43:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6IHp7QDG+Pc13P84ILxHnQACPvZIUs02sO9JUyOvxV02YdbzGNJSoPdLapBejzeqs72js
X-Received: by 2002:a05:620a:136f:: with SMTP id d15mr60718356qkl.192.1558449818979;
        Tue, 21 May 2019 07:43:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558449818; cv=none;
        d=google.com; s=arc-20160816;
        b=IavT39tLyiz+LmsFQB22csYIkuevfKge/Wth2Il7qnrjvezjZxFrKiaX7GwF2clvFf
         a0kYPEb3JgVSgXa3rJWwKxYWfCNeb6vJmzzbBGUhzIUl1ExwtDBxB6Eim/UI8Nxts26/
         55rkAeiTUUlWo7PHvEaszwo+3EaVH6jfE6hWUkSbKroI6iI8lLImndkAuzohxNrG3p6B
         vmxM1Az+feYHh/r2xDJ6cO5wh1PX3luegWnnzlafSsmKQ09Ri61S2cvAtCVBrshwOteu
         xUodjFi81Y997xyAJHx/fqIDsOXJujA19Crz2ONCmEAy0wDJEwikQbHM88wagjA08PLJ
         Dc4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=ugj1TnF91z5+PBr8jQIJ7x5EpDifHr/zSRpWbpp1ovs=;
        b=VJ4kA33H/u5zBIYlPNZ3DgNkNGLM21mAbWnYT9pBBsJTWiOCt6OhLWY3siEXNCyJqU
         Z082t3w8Zb5zXp994jLGKoP83jelQaITrt143+ereppBY6lHh0uP1W+z9WPIQEVKk3PY
         hVtHcRRbGvxu/dMlF6HSVaFPbC6+mT7FehQi8vncGGFbUE7SLqzex3JW/S69aGXOWqmx
         CHueaqe2BFtLmnSEK7+lm/hO9DRruEn2omPR0lLANycWszYWn5e4eBjDVbkLc23JoY46
         qmcyRGA6IzCr3O+r6CDaZ6tPPlgvaGNkswwYcf2fSg8/yfsGqM4LZneDtGyyXerupYat
         hARw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=BQ+JycJd;
       spf=pass (google.com: domain of 0100016adad909d8-e6c9c310-36e0-4bdd-80fd-5df1a1660041-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=0100016adad909d8-e6c9c310-36e0-4bdd-80fd-5df1a1660041-000000@amazonses.com
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id 130si1898061qkg.38.2019.05.21.07.43.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 May 2019 07:43:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016adad909d8-e6c9c310-36e0-4bdd-80fd-5df1a1660041-000000@amazonses.com designates 54.240.9.34 as permitted sender) client-ip=54.240.9.34;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=BQ+JycJd;
       spf=pass (google.com: domain of 0100016adad909d8-e6c9c310-36e0-4bdd-80fd-5df1a1660041-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=0100016adad909d8-e6c9c310-36e0-4bdd-80fd-5df1a1660041-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1558449818;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=ugj1TnF91z5+PBr8jQIJ7x5EpDifHr/zSRpWbpp1ovs=;
	b=BQ+JycJdcpCjIkVBFXG/uI/HVL5jFnPpTJt1wuepkBL/uNGFdX/hN68BkswpWFGW
	mg/FuCt9SExcgAO0Eslvkkk3XzdUBUdiRTWU+zp5YFpHW7RGAhGngcQtn5shOZF0VN/
	nOqFCUJNNa5hHtr4UGwVSyLKP9qAjIfWUg7eWWug=
Date: Tue, 21 May 2019 14:43:38 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Daniel Vetter <daniel.vetter@ffwll.ch>
cc: DRI Development <dri-devel@lists.freedesktop.org>, 
    Intel Graphics Development <intel-gfx@lists.freedesktop.org>, 
    LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
    Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, 
    Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
    David Rientjes <rientjes@google.com>, 
    =?ISO-8859-15?Q?Christian_K=F6nig?= <christian.koenig@amd.com>, 
    =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, 
    Masahiro Yamada <yamada.masahiro@socionext.com>, Wei Wang <wvw@google.com>, 
    Andy Shevchenko <andriy.shevchenko@linux.intel.com>, 
    Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>, 
    Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>, 
    Randy Dunlap <rdunlap@infradead.org>, 
    Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH] kernel.h: Add non_block_start/end()
In-Reply-To: <20190521100611.10089-1-daniel.vetter@ffwll.ch>
Message-ID: <0100016adad909d8-e6c9c310-36e0-4bdd-80fd-5df1a1660041-000000@email.amazonses.com>
References: <20190521100611.10089-1-daniel.vetter@ffwll.ch>
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

On Tue, 21 May 2019, Daniel Vetter wrote:

> In some special cases we must not block, but there's not a
> spinlock, preempt-off, irqs-off or similar critical section already
> that arms the might_sleep() debug checks. Add a non_block_start/end()
> pair to annotate these.

Just putting preempt on/off around these is not sufficient?

If not and you need to add another type of critical section then would
this not need to be added to the preempt counters? See
include/linux/preempt.h? Looks like there are sufficient bits left to put
the counter in there.


