Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35AE0C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:18:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8BFD2087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:18:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="ONOUseN5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8BFD2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F7A28E0003; Wed, 30 Jan 2019 12:18:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77EE38E0001; Wed, 30 Jan 2019 12:18:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66FA48E0003; Wed, 30 Jan 2019 12:18:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id E5D1F8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:18:41 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id u17so60088lfl.3
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:18:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=uLRQ1SBdctMYyjAwt+9Xhs7ky5rrWokjn3qsrqXAjVw=;
        b=qhrDl/2TAGxhz+63OgJ8BDWjMOCsF93w3f8sWOyUPI+tQ1Ayqx57K9FaZMVtTvmY/S
         RbUxX1VU/XDooKiZFpi4QL2r+OlKfThlpCuVVFepwU8MtkLalNWb9UzaUnFB3Parsifm
         il9YaiXveVnxMdmtGbZ0ODAualD59mu4CIapsjlg8vx4at9b1X1PxVXyk/4z8iGpGdfr
         3dRtmvUytHNYQ5FRuJjcuudjxaSssWSUZdH27/lSwnplpMRwECbP653sLCtADBnUl+io
         cmqULoHlSvSwTR0ur/GMMGRxAhESpcNVyOOlvVwHcxDXio1b78cd5hRwEl8wmYzfqbxc
         q8yQ==
X-Gm-Message-State: AJcUukc/1SMQDzgUlPInZruPCJmZ5DSbUEe/vePS7Z0Pq/vEDeOV3lte
	os9zEYaQ5qq30nH+OiXLkFqwqRjRnzPcfhS4uq1UwED2qd9ATQEkTnQc8bj4r862BT+3eK44umt
	h9L1aA7kzwwv9k1Nx2VJRadNqQ/47P72bnOV0cst2QdbhsSWE2nCVvU/D6d/pgCi5IMp7e8CPBJ
	iOktDV4tFAcDnyU3AeC6OBZEnGPLgMz5BBHNUxsIfc6fXbrJ4ZxtHJxz5EYAaMPVuVgOizguUgG
	fk+s3sVvyCwI14k3dKaGR+ICepNq79Pojp40qKKqDDcenR4FQH+rEQH0fqbExaGpE6yk4diG1Uy
	xGdr04w3W8O701F2AosHXsblP8S7y197XCWflpW7RJkOxl2SpLVjlSWxYYPeaoDxqStXBcM+BkX
	Q
X-Received: by 2002:a2e:9849:: with SMTP id e9-v6mr25020986ljj.9.1548868721072;
        Wed, 30 Jan 2019 09:18:41 -0800 (PST)
X-Received: by 2002:a2e:9849:: with SMTP id e9-v6mr25020947ljj.9.1548868719991;
        Wed, 30 Jan 2019 09:18:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548868719; cv=none;
        d=google.com; s=arc-20160816;
        b=H0+xMMK1uZ0VSwCDq4LIb3ikhx69KUQPXQ3iBlZsVA4jg95rhzibLff3Iu8YEnV5l5
         8vmVjqIcCN6+jzpc8k2fTgNLWN8bbf5a5ZK1MWpU9cBJsO1o5ZaX3yVWEPmS9t7d3Ncu
         fdwyHJp9AWNETmawGj88qPtnhBJB7MLUTER0su5oQzalGlAPwk8O+F4N+E3DN3N6+y+s
         682fUbGPwcbR3ZlnxEkN0dTiLB72t8cf7npYN4ZCbgOQiZsQs1Cr3JlnJpxPAAK1GYXi
         pw6P+0wnHBvdFOinGbr1ffzpZ0RPb7BFuZBJwNQf6X0oywLuN8ulBoNy4ft9FCiXUvYw
         UyvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=uLRQ1SBdctMYyjAwt+9Xhs7ky5rrWokjn3qsrqXAjVw=;
        b=N8GVqZE4SOLlxNyqXboM/WTyywv0PH+dhgm8zyTY/Y9zQNvQqgOlF+4s0rDMxN3rkE
         uCeDBIvTMgGGyqTKO3p3HagJGmPq0BDYQ5Z0ZzLRlFnA50WsTwCJreYai96xUiFmiy1z
         dzIpbapmRje9rXxwazCU2GdtGZJZrSmwOUsAdTPN2giGUTTAJ6EutXUx8UHAGRQVFl05
         NmVOaW9TME1CxE9BeC2f2GuoVz6XBlfBPLb43S23NSlac9JAXxUCdRdFd1jV8q/11jBJ
         orOiNzoOoCpL5VcFiePhz08npai8P5Ed9AV8oc8LrYEmV36E6+Ch17HU6xaXy9ZeOefG
         xvKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=ONOUseN5;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o80sor643028lff.12.2019.01.30.09.18.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 09:18:39 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=ONOUseN5;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uLRQ1SBdctMYyjAwt+9Xhs7ky5rrWokjn3qsrqXAjVw=;
        b=ONOUseN5WXIiQ53JP5ZfD4g7RUpTfBgvWnBMEoC0MhXxIw9m2w4uMmFRhNatFx3WdL
         c4E1T5QUqlEfV75Vbzbn9w8SC2ouFIV9akF9yT8denyk99Xmkf1dzsvNlk4i8kYDc1v4
         HcRUT5BnmoHoz0D7wLFpLosUZDTu4WIR8FB4c=
X-Google-Smtp-Source: ALg8bN52gHTt9dzo0lFGAY/fnWfGJmTKxZDq12mRcYh1CFmPQCw6/VMTabRwHOrb3Umpm6J+TJPuqA==
X-Received: by 2002:a19:f115:: with SMTP id p21mr23741955lfh.20.1548868718839;
        Wed, 30 Jan 2019 09:18:38 -0800 (PST)
Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com. [209.85.167.47])
        by smtp.gmail.com with ESMTPSA id q20sm383205lfj.20.2019.01.30.09.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 09:18:37 -0800 (PST)
Received: by mail-lf1-f47.google.com with SMTP id c16so207756lfj.8
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:18:37 -0800 (PST)
X-Received: by 2002:a19:ef15:: with SMTP id n21mr24603026lfh.21.1548868717271;
 Wed, 30 Jan 2019 09:18:37 -0800 (PST)
MIME-Version: 1.0
References: <CAHk-=widebSUzbugcLS2txfucxDNOGWFbWBWVseAmxrdypDBrg@mail.gmail.com>
 <CAHk-=wg=gquY8DT6s1Qb46HkJn=hV2uHeX-dafdb8T4iZAmhdw@mail.gmail.com> <201901300254.x0U2sKdE090905@www262.sakura.ne.jp>
In-Reply-To: <201901300254.x0U2sKdE090905@www262.sakura.ne.jp>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 30 Jan 2019 09:18:20 -0800
X-Gmail-Original-Message-ID: <CAHk-=wjEHQZyen7WEG5K5gC_5gEb9gM_r+WtpkfsLkYFstN5XA@mail.gmail.com>
Message-ID: <CAHk-=wjEHQZyen7WEG5K5gC_5gEb9gM_r+WtpkfsLkYFstN5XA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yang Shi <shy828301@gmail.com>, 
	Jiufei Xue <jiufei.xue@linux.alibaba.com>, Linux MM <linux-mm@kvack.org>, 
	joseph.qi@linux.alibaba.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 6:54 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> Then, do we automatically defer vfree() to mm_percpu_wq context?

We might do that, and say "if you call vfree with interrupts disabled,
it gets deferred".

That said, the deferred case should generally not be a common case
either. It has real issues, one of which is simply that particularly
on 32-bit architectures we can run out of vmalloc space even normally,
and if there are loads that do a lot of allocation and then deferred
frees, that problem could become really bad.

So I'd almost be happier having a warning if we end up doing the TLB
flush and defer. At least to find *what* people do.

And I do wonder if we should just always warn, and have that
"might_sleep()", and simply say "if you do vfree from interrupts or
with interrupts disabled, you really should be aware of these kinds of
issues, and you really should *show* that you are aware by using
vfree_atomic()".

                     Linus

