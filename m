Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5469DC282D7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:09:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05D5720844
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:09:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="CGu974ho"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05D5720844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FDB68E019D; Mon, 11 Feb 2019 19:09:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AD478E019C; Mon, 11 Feb 2019 19:09:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C4EA8E019D; Mon, 11 Feb 2019 19:09:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 588F28E019C
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:09:27 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id b189so328440vke.21
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:09:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=H/Z6SBwrxte/a4eWZAeqhxzhggVunUiGqztKV9/JXHs=;
        b=phl2Q++VlxFTh2Ua3aQ+0IzVVR9yQq92EYryFQOQtTzqtEd4vpg/wQ0RJGqh+5YjmG
         /YUz7XQHX+ZfFDUiddeRb8F/AmxrtUVLfrVHQwNZLHx0ZNlCsgh1wVkFWzRnQXuZ7+Do
         C61BRii4V4/LUqLmKkuqezlngT9Dke7nNw6lWXyAa1n+FIE8X3A/zZ0vTs7UD3NDL8Ah
         WuVvCDHLWmS4yEkk5QhXA5L0RfV/0DpktoBP5yxYnHldkcaDzgQOZygYKDR8RFQQY+T3
         zJlrbL/8LGP/E2MzTrnCsPLlDTnjbHGny7MdTXt0pNGRkQMbnBljhqwwRDhYPPxH+MjQ
         kdaA==
X-Gm-Message-State: AHQUAuY0yiiCWacXIS6ocqy1TvdC9mTubvbFRoSbUxEILBVTINvYNJHh
	rmQQRBgY4ck09dN0fuKPBzAveVUZUqDtWh9Sfz5n5Pw/ow8CpOJPbVdSX6Md832S7pgRTf/1plx
	7lKr9PuHDCZbK+Hm2+mOuAt8jRaK2iB8M6IPRRMjtltD1inhAoftjSPg3JZ9G4nIdaenkfkMwE8
	iFb5yKM0qKnGyMeNEjOqH4Iqm1xG5LDhFe0qWwUW2kkXrAE2jbbjAorA0wYpko+5QGXHSyXXGDz
	L5zxTcnS4/E2LA0xkAqZ4Fb9oVzz/0NWL28mUb94nNxztxvsazi3/DFPR3PN+KCWLLi6++h1cjB
	DCyMuMnnTH7IiSTiJCCjfeU3q+3A29Z8MWcvAc1X+Kmu8psp2oCWHislHw0lW7u6dEVKoJ8fWvh
	S
X-Received: by 2002:ab0:48c9:: with SMTP id y9mr212009uac.77.1549930166941;
        Mon, 11 Feb 2019 16:09:26 -0800 (PST)
X-Received: by 2002:ab0:48c9:: with SMTP id y9mr211995uac.77.1549930166312;
        Mon, 11 Feb 2019 16:09:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549930166; cv=none;
        d=google.com; s=arc-20160816;
        b=v8RfYj/DyZV9uItaZxvpOhTgJV+K08JCETm78dazFy4nK0BAX8UCT3Y9u/3YJqZXq9
         vLmOmVwe/H3nAjAF6XEekoy9tP3k7IwYWnviY4dDa/XvsaOt/7MRIwW3Sr8DKDH1rW99
         jpYm9fsx8R8M8knk2JJz9MSECXhvo+bvJvT2QN8HrGawzlR2PEH3/FnIHUmpjbMqimaE
         lHAp3wOQaRTx1gy2XjoX0iULetUdSU4LPkvcNozCUbFj2Ioze6qcs4HsplDcf5qnIhsx
         +6CKiZorURsxAT6yD7qRNANUfqpGdowyegy0+2eAyP5bf3UYWJhH45+UnUO2ZJjB+OR9
         ytQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=H/Z6SBwrxte/a4eWZAeqhxzhggVunUiGqztKV9/JXHs=;
        b=V7kiZ0zn/U3QaH0k4WgiIg/T1zujQ4oR+QFkqEztPOSfng1HzkBoyO2vGKtX0/TJLR
         DAe8iLg661WNbMMpw2CkLA1idyECO9RfxBuSP3Oflh1VxvAXPTJ5rmJ8k1n/IWqBgaPs
         CEq+1GCYixBVK5cl2Unh7laMuSA+ncVBfavDVOS0qqDzJ/J6LxuySUpbVLXa1htunGCm
         Sm2nPyjkwhq/04H3H/oQC5WAAPltQxXUSDTC/D6Iofp0Ec/0VYN6LlTFMxKIXF/6d7qf
         NAoD1Wjuj40Z/GyOEtFUSMSICTF8GEJdwMD1FLQo0F6i5EAS8gWsWFPsBCZ5mVJmHDAz
         aURg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=CGu974ho;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b18sor6215528uap.35.2019.02.11.16.09.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 16:09:26 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=CGu974ho;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=H/Z6SBwrxte/a4eWZAeqhxzhggVunUiGqztKV9/JXHs=;
        b=CGu974hoK3qP86sgob0OClO6eAsop4HseTV9JTbKVeiqaBLUM5o0AJ7lJeGzgm6smk
         tAlVEoo+FwIFniOTpEqDcX1lgNW9qkWl7yjBm56ZbPytAgs1hbBMF8BdYK+TZ70Tpz6Q
         nj5tq0wHe+RI5HlX2EVJoumKbZw8Ryk1ApACQ=
X-Google-Smtp-Source: AHgI3IZfqqnhTY3aIinKWOz/ZwvP1fj/xN4dY42PNCCieQwACV2B0GrbtXYXVnwUBopnLJJeivvn4A==
X-Received: by 2002:a9f:2c87:: with SMTP id w7mr401377uaj.116.1549930165641;
        Mon, 11 Feb 2019 16:09:25 -0800 (PST)
Received: from mail-vs1-f43.google.com (mail-vs1-f43.google.com. [209.85.217.43])
        by smtp.gmail.com with ESMTPSA id l10sm12452292vkl.54.2019.02.11.16.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 16:09:24 -0800 (PST)
Received: by mail-vs1-f43.google.com with SMTP id x1so490855vsc.10
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:09:24 -0800 (PST)
X-Received: by 2002:a67:c00a:: with SMTP id v10mr427593vsi.66.1549930163604;
 Mon, 11 Feb 2019 16:09:23 -0800 (PST)
MIME-Version: 1.0
References: <cover.1549927666.git.igor.stoppa@huawei.com>
In-Reply-To: <cover.1549927666.git.igor.stoppa@huawei.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 11 Feb 2019 16:09:10 -0800
X-Gmail-Original-Message-ID: <CAGXu5j+n3ky2dOe4F+VyneQsM4VJbGPUw+DO55NkxxPhKzKHag@mail.gmail.com>
Message-ID: <CAGXu5j+n3ky2dOe4F+VyneQsM4VJbGPUw+DO55NkxxPhKzKHag@mail.gmail.com>
Subject: Re: [RFC PATCH v4 00/12] hardening: statically allocated protected memory
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, 
	linux-integrity <linux-integrity@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 3:28 PM Igor Stoppa <igor.stoppa@gmail.com> wrote:
> at last I'm able to resume work on the memory protection patchset I've
> proposed some time ago. This version should address comments received so
> far and introduce support for arm64. Details below.

Cool!

> Patch-set implementing write-rare memory protection for statically
> allocated data.

It seems like this could be expanded in the future to cover dynamic
memory too (i.e. just a separate base range in the mm).

> Its purpose is to keep write protected the kernel data which is seldom
> modified, especially if altering it can be exploited during an attack.
>
> There is no read overhead, however writing requires special operations that
> are probably unsuitable for often-changing data.
> The use is opt-in, by applying the modifier __wr_after_init to a variable
> declaration.
>
> As the name implies, the write protection kicks in only after init() is
> completed; before that moment, the data is modifiable in the usual way.
>
> Current Limitations:
> * supports only data which is allocated statically, at build time.
> * supports only x86_64 and arm64;other architectures need to provide own
>   backend

It looked like only the memset() needed architecture support. Is there
a reason for not being able to implement memset() in terms of an
inefficient put_user() loop instead? That would eliminate the need for
per-arch support, yes?

> - I've added a simple example: the protection of ima_policy_flags

You'd also looked at SELinux too, yes? What other things could be
targeted for protection? (It seems we can't yet protect page tables
themselves with this...)

> - the x86_64 user space address range is double the size of the kernel
>   address space, so it's possible to randomize the beginning of the
>   mapping of the kernel address space, but on arm64 they have the same
>   size, so it's not possible to do the same

Only the wr_rare section needs mapping, though, yes?

> - I'm not sure if it's correct, since it doesn't seem to be that common in
>   kernel sources, but instead of using #defines for overriding default
>   function calls, I'm using "weak" for the default functions.

The tradition is to use #defines for easier readability, but "weak"
continues to be a thing. *shrug*

This will be a nice addition to protect more of the kernel's static
data from write-what-where attacks. :)

-- 
Kees Cook

