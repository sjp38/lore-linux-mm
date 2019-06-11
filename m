Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8691FC31E46
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:09:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F0CB20866
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:09:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="EzYSNQ5V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F0CB20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EC676B000A; Tue, 11 Jun 2019 17:09:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99E6E6B000C; Tue, 11 Jun 2019 17:09:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8654E6B000D; Tue, 11 Jun 2019 17:09:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1346B000A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 17:09:10 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i33so8454743pld.15
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 14:09:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=v+lkaRP3G3DZM+ssfC8UAWzAhPFHDzRKVms/SD2Iq4U=;
        b=nTjQyIK1txogre61xyi7ACTtB4sp3VqOkaCp2WxEORQdUEaYI4MSa3LSs7uUgwj2NZ
         DIoRTB4QAjL7gaB1FQkkGB5+cN5W8oH91I2fBA3zoKq2rohIIRaK7NgeNB8o1cxVHOrm
         80GZtAsfZevgIEpwCaQRS0sS8PJ/qSSMkGoVh9g30he8iKzlUz/gRdjhmoWLa6xTxiW1
         mxwAq0BwIgxnl6a0pU5ZajD/HJo6cglgP47JtaUoFh/hQcty2YdO2r+odlR0PUR7WSkd
         ZzPz4HDPWg6q3/YHz57cITQzPTMCGKhJJQBapQBCnzliG4dDW+noMlHuxE6+6Ku01H+F
         yZ/w==
X-Gm-Message-State: APjAAAWlpKd0QmRpN8T41J10BKrzN/J5TC1Eaze6mjSU0ney2PiiTBgP
	xM4dDggFiJ8K7wfGoE8eKL5480Mlqu2oqq+PSAz2cHeQogoxDmi1QTste3p+GbBSJD0hVICJlsX
	smuTqaGhv2uOatJ1XKhJ3RqzAF13fgR1hXDzUfoZq+9QBBFO8+/hpdTYsHOmqpufJfQ==
X-Received: by 2002:a17:902:20e2:: with SMTP id v31mr77604220plg.138.1560287349873;
        Tue, 11 Jun 2019 14:09:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmSYhl6qSxchD2HENsaE9FUeSyOjI5w7bu+RqsjjTmr8qKJucF107kCAajR54K9dMZxhbF
X-Received: by 2002:a17:902:20e2:: with SMTP id v31mr77604177plg.138.1560287349267;
        Tue, 11 Jun 2019 14:09:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560287349; cv=none;
        d=google.com; s=arc-20160816;
        b=hXyFuVbWGLILxs+NybExtStjuW7GYVN4iT8sls+BVd0wwGmuz+ctaMSYAeTaFs86J2
         EPBFkMxqCL4Dp28ikbRqjCjX4T+5qI1KWkg5Y6GlAo6GTRf4ZRdf8/bgAWA3UWZ9/I0v
         tICtGuahSHASqt0BG5SUq1YrOIHognoGmx6KtTFNx2AurXEPVXGGN92/ZUxHFx80l4N/
         xj9MYKYW8pRsC0fLe/6IJsByramHhhufZDAiDEUiL+09UGoXYF3YOFlxt9RJIY/ny7Lb
         qI9pEmltKu2cjzWnjdbLAOMDqJbIR+O1giv4aooRH0/0oEoIN+Qj6n10Swm3XUCH6ZF+
         Ah4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=v+lkaRP3G3DZM+ssfC8UAWzAhPFHDzRKVms/SD2Iq4U=;
        b=GUuqXqjw2dGYpdI3EK+od119OZDTzE1oI6U9ugN67KEf3hjbpgq3D7P8SrSObBxJv+
         xifWzSn+rq4C6SHq4HYssf5RfSAgobCpPKfvvBYQSRTyoahNcCPXrQpjuEvLd/se3peg
         TMkfIVB9LwmDbBk1nbxvCLeu+1OA4nHpNHkI7DkBjGoce9kkr+p65OqibjDD3+MMXlQX
         1vZIslBEs/Xj0eAgEsVZ7SjVwzc0lGevaPReYtlIdvf2ZdQuDo9pRIVDq4YCHx1wkl5B
         2iJ9FTUezXDgsyn6V63kIlSAfzS7BFI+gY/EeBE/bpNr2TeoCCh54XV+mYw6CDqaydUY
         kZYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EzYSNQ5V;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e123si7703629pfa.252.2019.06.11.14.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 14:09:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EzYSNQ5V;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 542412080A;
	Tue, 11 Jun 2019 21:09:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560287348;
	bh=qmpEoNXO99XPF9xd/5iv2nDwyZYxG+9HqzTYNPT4KTw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=EzYSNQ5VopjCkhJxjwzVG+3NUfKcn1X9cU/Ns4PV5yZIsnow5MRHYB73/Tl3T81K/
	 SbRRApw7C7MWKpiNZqE5wCHVmQlPPOHtSxjsrM3RebqPsIl/mcOR/W6a0jpkC0UwOz
	 rSPkBbLzTQO7F5VSs5bcQHmoWK/bst5kRMcBgC7c=
Date: Tue, 11 Jun 2019 14:09:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Shyam Saini <shyam.saini@amarulasolutions.com>,
 kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org,
 keescook@chromium.org, linux-arm-kernel@lists.infradead.org,
 linux-mips@vger.kernel.org, intel-gvt-dev@lists.freedesktop.org,
 intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
 netdev@vger.kernel.org, linux-ext4 <linux-ext4@vger.kernel.org>,
 devel@lists.orangefs.org, linux-mm@kvack.org, linux-sctp@vger.kernel.org,
 bpf@vger.kernel.org, kvm@vger.kernel.org, mayhs11saini@gmail.com, Alexey
 Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH V2] include: linux: Regularise the use of FIELD_SIZEOF
 macro
Message-Id: <20190611140907.899bebb12a3d731da24a9ad1@linux-foundation.org>
In-Reply-To: <6DCAE4F8-3BEC-45F2-A733-F4D15850B7F3@dilger.ca>
References: <20190611193836.2772-1-shyam.saini@amarulasolutions.com>
	<20190611134831.a60c11f4b691d14d04a87e29@linux-foundation.org>
	<6DCAE4F8-3BEC-45F2-A733-F4D15850B7F3@dilger.ca>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jun 2019 15:00:10 -0600 Andreas Dilger <adilger@dilger.ca> wrote:

> >> to FIELD_SIZEOF
> > 
> > As Alexey has pointed out, C structs and unions don't have fields -
> > they have members.  So this is an opportunity to switch everything to
> > a new member_sizeof().
> > 
> > What do people think of that and how does this impact the patch footprint?
> 
> I did a check, and FIELD_SIZEOF() is used about 350x, while sizeof_field()
> is about 30x, and SIZEOF_FIELD() is only about 5x.

Erk.  Sorry, I should have grepped.

> That said, I'm much more in favour of "sizeof_field()" or "sizeof_member()"
> than FIELD_SIZEOF().  Not only does that better match "offsetof()", with
> which it is closely related, but is also closer to the original "sizeof()".
> 
> Since this is a rather trivial change, it can be split into a number of
> patches to get approval/landing via subsystem maintainers, and there is no
> huge urgency to remove the original macros until the users are gone.  It
> would make sense to remove SIZEOF_FIELD() and sizeof_field() quickly so
> they don't gain more users, and the remaining FIELD_SIZEOF() users can be
> whittled away as the patches come through the maintainer trees.

In that case I'd say let's live with FIELD_SIZEOF() and remove
sizeof_field() and SIZEOF_FIELD().

I'm a bit surprised that the FIELD_SIZEOF() definition ends up in
stddef.h rather than in kernel.h where such things are normally
defined.  Why is that?

