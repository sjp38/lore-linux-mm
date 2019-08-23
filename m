Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 464B2C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 08:34:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF28421848
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 08:34:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="aeC3TxV0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF28421848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A9F36B0385; Fri, 23 Aug 2019 04:34:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 759B96B0387; Fri, 23 Aug 2019 04:34:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6493E6B0389; Fri, 23 Aug 2019 04:34:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id 42DFA6B0385
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 04:34:15 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E0F2B82437CF
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 08:34:14 +0000 (UTC)
X-FDA: 75853030428.04.stem82_2506e961adc62
X-HE-Tag: stem82_2506e961adc62
X-Filterd-Recvd-Size: 4351
Received: from mail-ot1-f66.google.com (mail-ot1-f66.google.com [209.85.210.66])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 08:34:14 +0000 (UTC)
Received: by mail-ot1-f66.google.com with SMTP id e12so8053284otp.10
        for <linux-mm@kvack.org>; Fri, 23 Aug 2019 01:34:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2wI4jnej8AspWUXE13reusEb4wx5ZdHi/mO0D9XYtEg=;
        b=aeC3TxV0j2A92x3gKbNcF7bCggKdYhKlcyjxAhb5hfIRm+pYMjP86E3zP6iPTYa0CW
         V4FP5NjHd9HiRZopamKaKgTN9DoDP1olhMwISRwQM8srvpF0JbA28Xs/5rV6oXCqpMTX
         iTLRFwvLICz57Ol4za0Kp8tRS9HWt94Uo/ni8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=2wI4jnej8AspWUXE13reusEb4wx5ZdHi/mO0D9XYtEg=;
        b=WJQm8Y3+FD6KCsyaaBqBFnV/pZ8qIIiXjkSNP7dmcG6573J01OKeDVo6Y88DZ1W2vq
         8mC9HQYB1gBEWdPYiPPqawtIRkKoGVoKSZfe29Y9ADNXHsUI1XT6fv839nbL22v51etg
         rZv/xxVRQVcVdGIH2zVqf/tNUbmmAT107Dg/jzzgjESEVsOY8v+qvJh/rkHY4wxKeNNF
         /tu65vBfGF7rJtPViU6ENv+6pi3fqU9I2r0CZBu5RVdObrZsHqBxOaYIkLVkj9atR01W
         vJjo9OTCs89MhFm0gF4pBLLSFk+R7r60PozDKTZULwYj6g5MuKdBC7liUYt2/+LUmqOp
         TFfA==
X-Gm-Message-State: APjAAAXNgJswlRGMDhDlk2Vbv6EF4ujpGhNzPdnTkHpGE6i+4q3WdEuu
	Nzi8FKi7vo/o8h1mNurXmwwgTOJrKEGndrW0X4xbtg==
X-Google-Smtp-Source: APXvYqySGMSx76GQciFyarc45Uaxat2fi1EkKKRAKJHDAgSYk4ycOdQtf+zAg8LRPPEFSKLE0nTWT6z30G/6Y2FEpF0=
X-Received: by 2002:a9d:7006:: with SMTP id k6mr3113253otj.303.1566549253448;
 Fri, 23 Aug 2019 01:34:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-4-daniel.vetter@ffwll.ch> <20190820202440.GH11147@phenom.ffwll.local>
 <20190822161428.c9e4479207386d34745ea111@linux-foundation.org>
In-Reply-To: <20190822161428.c9e4479207386d34745ea111@linux-foundation.org>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Fri, 23 Aug 2019 10:34:01 +0200
Message-ID: <CAKMK7uGw_7uD=wH3bcR9xXSxAcAuYTLOZt3ue4TEvst1D0KzLQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] kernel.h: Add non_block_start/end()
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>, 
	David Rientjes <rientjes@google.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Wei Wang <wvw@google.com>, 
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Jann Horn <jannh@google.com>, Feng Tang <feng.tang@intel.com>, 
	Kees Cook <keescook@chromium.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Daniel Vetter <daniel.vetter@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 1:14 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 20 Aug 2019 22:24:40 +0200 Daniel Vetter <daniel@ffwll.ch> wrote:
>
> > Hi Peter,
> >
> > Iirc you've been involved at least somewhat in discussing this. -mm folks
> > are a bit undecided whether these new non_block semantics are a good idea.
> > Michal Hocko still is in support, but Andrew Morton and Jason Gunthorpe
> > are less enthusiastic. Jason said he's ok with merging the hmm side of
> > this if scheduler folks ack. If not, then I'll respin with the
> > preempt_disable/enable instead like in v1.
>
> I became mollified once Michel explained the rationale.  I think it's
> OK.  It's very specific to the oom reaper and hopefully won't be used
> more widely(?).

Yeah, no plans for that from me. And I hope the comment above them now
explains why they exist, so people think twice before using it in
random places.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

