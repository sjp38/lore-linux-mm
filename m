Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EE34C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:53:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1728320815
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:53:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="ibB5Z1OY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1728320815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B92616B0005; Thu, 16 May 2019 12:53:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B43466B0006; Thu, 16 May 2019 12:53:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E3FA6B0007; Thu, 16 May 2019 12:53:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6569F6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 12:53:05 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 5so2553944pff.11
        for <linux-mm@kvack.org>; Thu, 16 May 2019 09:53:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=6LcSRBYGYblE8KnG9YkzHNeJWSKv1kS+36NXuNsO3Vk=;
        b=TLbel8CWTp+ESzTPZh136vjNLe4BmEcTX/U2h9KLT9gg7kuraS7F0Wstkee/4OcpMp
         5Fuv3UgxJCMA3XL+sNFxJ1Jh0pgymWOQ4mbaBeJ5CsynDGb7cvCyEcgDV2ky3TmfvdWo
         4Ex36cfBYQ56zBTyMXa2+dLOQxRpOj8LlUTYn919GHyd139I+8iPwO9TH7KIqf/FqOWN
         Nj+LlfQdLqP2NSlAf7j4HJYsoGIVwk7u1/lTtmPrUVL0f2vcq9xu5ZoQnNZ7BG+08GXw
         BOXgySOh1Zn6t7gQT64T5q5ZeX31ZOsT0IQQ9RzCBmbbeYWN32SppsRYwSuY6X2N1gHf
         B9uQ==
X-Gm-Message-State: APjAAAVPy/GkwDq7YYrQLjU06keMLZQ570NErR8ubdj8/w8R9wCtVddA
	oYpE4AK6Xgca6hUeKTV9bIotPbQ0aZq2FgbB4f72uUJETPTAyNZCa5xeipdYNVI0+s18E9Cw52c
	ku2srqDc0d2/ajbjlqfSZ1XrUZPnZrpOyi6jJa6jenEMxuDXn+01xkuz3WiWGZWwWfg==
X-Received: by 2002:aa7:92da:: with SMTP id k26mr10218053pfa.70.1558025584922;
        Thu, 16 May 2019 09:53:04 -0700 (PDT)
X-Received: by 2002:aa7:92da:: with SMTP id k26mr10217986pfa.70.1558025584100;
        Thu, 16 May 2019 09:53:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558025584; cv=none;
        d=google.com; s=arc-20160816;
        b=aL2uhN8gv04gxShp3xrcCfjfnTNRTNjoGrbspDy5yKMs2yVAPcSDJbsD1yMFHZTruL
         8xKeKC00lurPy0F1KNwEQyBckjTDsDSEjC9soxVfkmDb7Rl+JxPBh0WTrkP5dH7q9FnU
         Uwi6aMvvg3dMleA+6HcDJlI0qpgoVWHftdscPkDVbutz0OcYw6OzTIxFnmBN0SwTX3be
         M23LHLgO4FKb/FyPTNJlMUa/ZYje8LPy9o8nQ4SuetjARhllTgORklxjZ3djDIvdT1wa
         NiggjbSiT6wNEWPc1JusZieSnuIRExElt3cOB8M77u6ez0Gb83Uvmu7bYbYhh0E6JlvG
         GERA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=6LcSRBYGYblE8KnG9YkzHNeJWSKv1kS+36NXuNsO3Vk=;
        b=KgC5SYEhH1D8DXli2IChKfTo18Hh3nRReqDlhQcVSYbxWebYR/TSQ0h1ZhEdT/8gAw
         WOvGKSczjKkd9aPqhBtdTrmYIWOB2E6rAMmqWQwnTus16Y0Qt1NiOK77Oz3rl+4kn0xm
         GMsakKjXepH/TvMFmNVBDFH/2JAK5AtyE3OoIK3wxT4QPwwPdnalJKoBbAZha4WHcY3I
         rtE7k7t86PuSUGdnlmRfJDPNPOhvEJva3B0XfCvIWHVs/Iw09F9cmWYTJtx0roOSpnlQ
         aeHp1k+4eMiZIZ42KNabbVf+qjsLiAVbSJItoRzmpS+1qYEPREwP1l2GKAW/lLvqtERE
         kpdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ibB5Z1OY;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b91sor6645734plb.0.2019.05.16.09.53.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 09:53:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ibB5Z1OY;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=6LcSRBYGYblE8KnG9YkzHNeJWSKv1kS+36NXuNsO3Vk=;
        b=ibB5Z1OYQwc98aDEYCmgshR4HnNV1ewVWdMdm/6CKYXPVekT2bhzH4PkYIc0CBN6g0
         3RVcq3LMmZ5Q5lyRNGhCySSZnXDeQlR3o+rYJ7XjtWaWqiP4S8z4OyyjXHTScR2eI/lD
         BGuI6KsW5NIL4fQ067WG0tUG+O+QUq3y5B3pg=
X-Google-Smtp-Source: APXvYqzxktrdR74/jozDFmScyT7V6rFj+OxDZS8IbmNkChFWgpOSZeP4blgwp9KkSVtUQXVkKb0mfw==
X-Received: by 2002:a17:902:7797:: with SMTP id o23mr50309891pll.147.1558025583725;
        Thu, 16 May 2019 09:53:03 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id f29sm16984632pfq.11.2019.05.16.09.53.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 09:53:02 -0700 (PDT)
Date: Thu, 16 May 2019 09:53:01 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: akpm@linux-foundation.org, cl@linux.com,
	kernel-hardening@lists.openwall.com,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 4/4] net: apply __GFP_NO_AUTOINIT to AF_UNIX sk_buff
 allocations
Message-ID: <201905160923.BD3E530EFC@keescook>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-5-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514143537.10435-5-glider@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 04:35:37PM +0200, Alexander Potapenko wrote:
> Add sock_alloc_send_pskb_noinit(), which is similar to
> sock_alloc_send_pskb(), but allocates with __GFP_NO_AUTOINIT.
> This helps reduce the slowdown on hackbench in the init_on_alloc mode
> from 6.84% to 3.45%.

Out of curiosity, why the creation of the new function over adding a
gfp flag argument to sock_alloc_send_pskb() and updating callers? (There
are only 6 callers, and this change already updates 2 of those.)

> Slowdown for the initialization features compared to init_on_free=0,
> init_on_alloc=0:
> 
> hackbench, init_on_free=1:  +7.71% sys time (st.err 0.45%)
> hackbench, init_on_alloc=1: +3.45% sys time (st.err 0.86%)

In the commit log it might be worth mentioning that this is only
changing the init_on_alloc case (in case it's not already obvious to
folks). Perhaps there needs to be a split of __GFP_NO_AUTOINIT into
__GFP_NO_AUTO_ALLOC_INIT and __GFP_NO_AUTO_FREE_INIT? Right now __GFP_NO_AUTOINIT is only checked for init_on_alloc:

static inline bool want_init_on_alloc(gfp_t flags)
{
        if (static_branch_unlikely(&init_on_alloc))
                return !(flags & __GFP_NO_AUTOINIT);
        return flags & __GFP_ZERO;
}
...
static inline bool want_init_on_free(void)
{
        return static_branch_unlikely(&init_on_free);
}

On a related note, it might be nice to add an exclusion list to
the kmem_cache_create() cases, since it seems likely that further
tuning will be needed there. For example, with the init_on_free-similar
PAX_MEMORY_SANITIZE changes in the last public release of PaX/grsecurity,
the following were excluded from wipe-on-free:

	buffer_head
	names_cache
	mm_struct
	vm_area_struct
	anon_vma
	anon_vma_chain
	skbuff_head_cache
	skbuff_fclone_cache

Adding these and others (with details on why they were selected),
might improve init_on_free performance further without trading too
much coverage.

Having a kernel param with a comma-separated list of cache names and
the logic to add __GFP_NO_AUTOINIT at creation time would be a nice
(and cheap!) debug feature to let folks tune things for their specific
workloads, if they choose to. (And it could maybe also know what "none"
meant, to actually remove the built-in exclusions, similar to what
PaX's "pax_sanitize_slab=full" does.)

-- 
Kees Cook

