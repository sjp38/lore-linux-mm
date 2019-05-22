Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7604BC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:17:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F57B20645
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:17:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iBWci38m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F57B20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D2DB6B0006; Wed, 22 May 2019 11:17:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6830F6B0008; Wed, 22 May 2019 11:17:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 572F56B000A; Wed, 22 May 2019 11:17:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32C9C6B0006
	for <linux-mm@kvack.org>; Wed, 22 May 2019 11:17:37 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id 76so540222uat.12
        for <linux-mm@kvack.org>; Wed, 22 May 2019 08:17:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=85/xp1LLQ/Gq2RJYWYYuF9b0tPNRLe+Qag7yBp7mWAc=;
        b=Yz8jwsKMu4bu6UBewF4twTapElBr//MPUR1EAQkK//wJObFBMjR01BKrMC5Tt3lok9
         N1EZo2bxi2Q+THIEKPuMKsIsx4cGkXPzwldYzlKNykCjPOlMnboV/PGbvKd83xSy9PE+
         YdQ9rbJBdTu+FFR4OHZOeCGd5818J2R5aSAjXCFKN2n8O01w8tZuUcjkALVw518nVp4c
         3MnXWZIOA69eGjFgUHH8Qi1wGsgT6mEfrseo5sXhCp5NaRkUGnYpmHD8rinwtPSeA4x8
         YoIVdKar08VaGpAqtEhsiP011Inx/iXHuUnRAhsejGHswtzes/4uit2umEzmXnnjKxhm
         4Usg==
X-Gm-Message-State: APjAAAXF0sL8bSJyaC/jC6Vv17+vpfOEoyl39C1bz2QT9vkQWgc9RXGE
	paDL5MXoyb+4EbD3wQzq2fUfkRKmiepalTRC0RVtgQ0xnKayZJsj/hH2osKc0sUsBDBhCqdhcVk
	AHPKdJDvzOLwT5SPoQodYgVST0Yd0QiF+TLtL6sH7aogjBlHzpuEXILgylaqKj+r+yw==
X-Received: by 2002:a1f:2fd2:: with SMTP id v201mr15649277vkv.83.1558538256881;
        Wed, 22 May 2019 08:17:36 -0700 (PDT)
X-Received: by 2002:a1f:2fd2:: with SMTP id v201mr15649239vkv.83.1558538256334;
        Wed, 22 May 2019 08:17:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558538256; cv=none;
        d=google.com; s=arc-20160816;
        b=gTUwZvABupCnsnJ6vbzb2t7efHXjOEuNBUn2IDc9yD0oq7F6ozpKZeoZnD05Dq6YtI
         jhBT6mTL/+b4AVVfCf1RGZtKkvr/UjxiMUWSzuIzu8wK0uPr1YxpBDra82kZm6oP32jg
         ejlM77PLKm/n/fqKs5rjTSOkr2vpgkDLm3wtbTq2FNWIEEDysBeaildTjgZTcqiBQkT+
         2jzKhWPl8ZCp8IzoCZCFwPH01BahY0d91w7aEJHH+R/Lpk0xiPdHtopFSTk3IHEj9AMf
         GVAi4Ixl7ltXBfWtefluWqBFiZhf5SnVbAr0cjFXapXzzMyiHWPt8xbSIdmvoW5X5y07
         bFNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=85/xp1LLQ/Gq2RJYWYYuF9b0tPNRLe+Qag7yBp7mWAc=;
        b=0k1NRcH9nszL0x1qVK2EXwtFTV+2tnGlBIKu/7Zm7pMIhdMhGU4BQIk1ozLOSaCyn6
         K4Zp6057+hLHXdBzH8MCXu/B570J4C4RBeU41sgEy0sBfAAQMGsirjKNdGBBzw4SCLpv
         n/hiyAHG6uRFYuq5uBWhV1UI1c9f90/OFtFdUl4YdCxBhAb5L4zNhIFuM5nqgOuh/mWl
         r8U841hGJVBENpGwUauB88sA4sszvU+3/Pn751jSzY630sUjoEBRJGR2GY6EWxurcflc
         xC3SStfWDMe4sYMWHYpC/iBQTAOeDbc2JguXABIwpmoDZvEadScoOzCG3GZz0cU5Gi/q
         nhDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iBWci38m;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 186sor10883727vsy.62.2019.05.22.08.17.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 08:17:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iBWci38m;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=85/xp1LLQ/Gq2RJYWYYuF9b0tPNRLe+Qag7yBp7mWAc=;
        b=iBWci38mGhcli5wl56IPjiVCAofYwzUm4VCJt87rQIGMSzAXm/QAy94eFgEFu8rUce
         2NBGu1/wkdaHaRcgpPfNmplL8dhDXjTVblDzenDcR0W+w6pUL9obwUeRHAVKQLcZoXYF
         GuCdoBXre8W4MP86eIDrkksZYa1fEFrxAcO9jXA7sAl9bJllqYSc5wJa1iAdguUqvdlf
         OuBrz86GYBbuxVW87BTcDE3HQS59eTVvXENFhOHWENHDbM0HUJ39W2JzfNV16r7l/wgO
         oj0farWsUo773EVjgFU5QmbjsDTQlf1c11zA1tw7d8iG5F7UYd4mxj4QI+EKJufJaBpc
         YTuQ==
X-Google-Smtp-Source: APXvYqwY3fllxdUsIb9pMNHzQvevbLB7gTfbyxHIV/lLfYAFC6DFS71u+U2Zbq2qGndivpbq5Z7rOI0NonYCw87UG3I=
X-Received: by 2002:a67:e1d3:: with SMTP id p19mr31572261vsl.183.1558538255715;
 Wed, 22 May 2019 08:17:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190520035254.57579-1-minchan@kernel.org> <20190521084158.s5wwjgewexjzrsm6@brauner.io>
 <20190521110552.GG219653@google.com> <20190521113029.76iopljdicymghvq@brauner.io>
 <20190521113911.2rypoh7uniuri2bj@brauner.io> <CAKOZuesjDcD3EM4PS7aO7yTa3KZ=FEzMP63MR0aEph4iW1NCYQ@mail.gmail.com>
 <CAHrFyr6iuoZ-r6e57zp1rz7b=Ee0Vko+syuUKW2an+TkAEz_iA@mail.gmail.com>
 <CAKOZueupb10vmm-bmL0j_b__qsC9ZrzhzHgpGhwPVUrfX0X-Og@mail.gmail.com> <20190522145216.jkimuudoxi6pder2@brauner.io>
In-Reply-To: <20190522145216.jkimuudoxi6pder2@brauner.io>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 22 May 2019 08:17:23 -0700
Message-ID: <CAKOZueu837QGDAGat-tdA9J1qtKaeuQ5rg0tDyEjyvd_hjVc6g@mail.gmail.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Christian Brauner <christian@brauner.io>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 7:52 AM Christian Brauner <christian@brauner.io> wrote:
> I'm not going to go into yet another long argument. I prefer pidfd_*.

Ok. We're each allowed our opinion.

> It's tied to the api, transparent for userspace, and disambiguates it
> from process_vm_{read,write}v that both take a pid_t.

Speaking of process_vm_readv and process_vm_writev: both have a
currently-unused flags argument. Both should grow a flag that tells
them to interpret the pid argument as a pidfd. Or do you support
adding pidfd_vm_readv and pidfd_vm_writev system calls? If not, why
should process_madvise be called pidfd_madvise while process_vm_readv
isn't called pidfd_vm_readv?

