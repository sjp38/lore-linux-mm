Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6582FC43387
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 17:23:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25E65218E0
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 17:23:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="qupI2FB2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25E65218E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6C978E0005; Fri, 21 Dec 2018 12:23:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1C3C8E0001; Fri, 21 Dec 2018 12:23:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A324C8E0005; Fri, 21 Dec 2018 12:23:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63C5E8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:23:18 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v11so4504728ply.4
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:23:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xZ3RRXah8n3uIO6f7K5v1Jcx/du9NIReJlkSDVG3gJg=;
        b=A9RRGPaZoL9SIqNMcHl97jR1spefuX6wf7fNiz9fDHv1PvnBHdizCW8UxJtcck7kcf
         8w6T+8+SNwsp73UdyeKmsnjrXmJceoQUC73unIeLmbfU7RMuqcG5MaJ2RKg8q6c6ndCG
         LPKr3tYyhVO73J8iNKPmUdOCmOKUXwXwh9gdWrdbMuaUSA2cthwJfNKpVDwIlionogZX
         3Bnc0DQipOx83WHG0ozRnMsRJ1TbOaGeBSJVnZl3IryAiWEmNn+pO1I6lp746LwAR48s
         sKF+yBxJwQu2FmrUUpJKUx9voGyJo4v9TDEPwNxW4ZV9U7uPu2jkjtNvDX8zxiT0jRMn
         WpPw==
X-Gm-Message-State: AA+aEWby+E0lLiEj2KJxsXABSGE3uzZMol9LPxzVt34mPblaXn1UGLAL
	ds8xY96XMuFPC1GxqAiIlNAZ4dh0gdxcdbV4r0qg5cFyt+MheXRa6WQwMxG4VSTK64PcKGB2sdh
	R/6BYAn5pxwzUytg+Fxi65GodIZgfCdgrUOq4uRLXPMr3IUohGaqrcLMbkizY3XHmKQ==
X-Received: by 2002:a62:d0c1:: with SMTP id p184mr3341532pfg.245.1545412997937;
        Fri, 21 Dec 2018 09:23:17 -0800 (PST)
X-Google-Smtp-Source: AFSGD/UcUJQNyq/d2v9Gq8h5lKd5fRK4F+WdRQHYhysHyPSKqV861Rto+YutXzJTCyLnc6NHfEbT
X-Received: by 2002:a62:d0c1:: with SMTP id p184mr3341484pfg.245.1545412997140;
        Fri, 21 Dec 2018 09:23:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545412997; cv=none;
        d=google.com; s=arc-20160816;
        b=GBLmR8FGb4wnonaa+7hOAptnemyNkE3ES59kbgbouBhvsn/ONnJ5/SFbP4O9hR+igi
         KjrSAONDPp/ZTSg46mWtVc4mZMoC3arRvrlyDrZKsjhpNXi5LYq8cPoIvu+QfIpFHrgr
         Sx6ZkU0/fjXmh5JHhaT/DkxGR2oZM0GhxACjJNGeKRunrg85a7D8ooN+RSnA26tBseod
         7k/9ibPCfPHEHtcIk7y0Q2FBVTeqKzyPmQG0nhabDmciln2HnbP8B/rKgU4jssO5iBTJ
         XGE7XwEbbkI0YelfX9D80WbIBJAFe7faKMV5t10fLg9b5Z2F8w4jyt3sBDr2FJFuJcG5
         s5bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xZ3RRXah8n3uIO6f7K5v1Jcx/du9NIReJlkSDVG3gJg=;
        b=FyHT2bYZkCUvdKObfwYtZq9TeMsfixJSxEwqhYE6uH+cfwuZpIP8iW+j7OXUFcRn/7
         ZUdiLpINi/l8Vws0a90tF4C6xB5WJbiAe0p94i/mN7gqov6OC3wqld6fPvyMNjQ/93Ws
         aMt3heCnZOh0Dy07SJgUbena58ix34JVLBB+pnEscOWvBrMgual3YI16tf3pIvEbCSDL
         k/JZKxGdSsx5WhaSSdKhAQRcV9Vj460GubTcDsPbr0M6WfCpWsrSQ6HSbdUAsuY+sHd9
         qQIdb6nLak7BUssdEoyV0Rmt2DyOGBwPfRBoshq1fP+w3MMoh9FM4brWEvYOpB59fQv/
         hdjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qupI2FB2;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 62si1783925pgi.314.2018.12.21.09.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 09:23:17 -0800 (PST)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qupI2FB2;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 69BAF2195D
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 17:23:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1545412996;
	bh=jKlCDnEG+8eNj0q1jYLDJIR9NUvNXj14/UuskFSxAH8=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=qupI2FB2kuvsXIyc8X4o4XB7y15ipKkI5IEOVxtAj2G+936cBkM3nIgyyPB/lPBao
	 uxvjk6ic87RhrixSSe4ViSpCG9JVY9EacyG80dfHX7ek70UMrFNJ/i6sY4Kb3EZ2ho
	 TsFbfTZuE+5lZIuCU/usZXgLLwW+fA/mHZUb2VFk=
Received: by mail-wr1-f46.google.com with SMTP id c14so6057102wrr.0
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:23:16 -0800 (PST)
X-Received: by 2002:adf:8323:: with SMTP id 32mr3357864wrd.176.1545412994785;
 Fri, 21 Dec 2018 09:23:14 -0800 (PST)
MIME-Version: 1.0
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
 <20181219213338.26619-5-igor.stoppa@huawei.com> <20181220184917.GY10600@bombadil.infradead.org>
 <d5e8523a-3afd-d992-1af3-b329985c5ed5@gmail.com>
In-Reply-To: <d5e8523a-3afd-d992-1af3-b329985c5ed5@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 21 Dec 2018 09:23:03 -0800
X-Gmail-Original-Message-ID: <CALCETrU8GZbF2oWYeKUVKBURuh1zeMqcHM5RMTchiDsdrSSVPA@mail.gmail.com>
Message-ID:
 <CALCETrU8GZbF2oWYeKUVKBURuh1zeMqcHM5RMTchiDsdrSSVPA@mail.gmail.com>
Subject: Re: [PATCH 04/12] __wr_after_init: x86_64: __wr_op
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, 
	Igor Stoppa <igor.stoppa@huawei.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Kees Cook <keescook@chromium.org>, linux-integrity <linux-integrity@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181221172303.mF6RBeqNtGLgXSJg7d00WBHyp2yHOi8utquik1MUZRw@z>

On Thu, Dec 20, 2018 at 11:19 AM Igor Stoppa <igor.stoppa@gmail.com> wrote:
>
>
>
> On 20/12/2018 20:49, Matthew Wilcox wrote:
>
> > I think you're causing yourself more headaches by implementing this "op"
> > function.
>
> I probably misinterpreted the initial criticism on my first patchset,
> about duplication. Somehow, I'm still thinking to the endgame of having
> higher-level functions, like list management.
>
> > Here's some generic code:
>
> thank you, I have one question, below
>
> > void *wr_memcpy(void *dst, void *src, unsigned int len)
> > {
> >       wr_state_t wr_state;
> >       void *wr_poking_addr = __wr_addr(dst);
> >
> >       local_irq_disable();
> >       wr_enable(&wr_state);
> >       __wr_memcpy(wr_poking_addr, src, len);
>
> Is __wraddr() invoked inside wm_memcpy() instead of being invoked
> privately within __wr_memcpy() because the code is generic, or is there
> some other reason?
>
> >       wr_disable(&wr_state);
> >       local_irq_enable();
> >
> >       return dst;
> > }
> >
> > Now, x86 can define appropriate macros and functions to use the temporary_mm
> > functionality, and other architectures can do what makes sense to them.
> >

I suspect that most architectures will want to do this exactly like
x86, though, but sure, it could be restructured like this.

On x86, I *think* that __wr_memcpy() will want to special-case len ==
1, 2, 4, and (on 64-bit) 8 byte writes to keep them atomic. i'm
guessing this is the same on most or all architectures.

>
> --
> igor

