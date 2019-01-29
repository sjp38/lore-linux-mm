Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18369C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:26:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C06A620869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:26:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BXh7n98B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C06A620869
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 740B68E0002; Tue, 29 Jan 2019 13:26:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EFB68E0001; Tue, 29 Jan 2019 13:26:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DE688E0002; Tue, 29 Jan 2019 13:26:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0A26F8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:26:13 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id 144so6127662wme.5
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:26:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ADwM0lszvaqhduF5I3DNeFvWPeUQTXjMtjOQKUDAPJ8=;
        b=mS3iI/eyoYXPPt5qrmafdJsj9tsjGeXf31yQr8vZQKUTggScVjjHjZ7/Esp43URSi/
         vlrGKnL20lCKY2quCMkZAcjV4Lv6GECaD1dU+ZgI9jf+BeI69c9qXYCcUtudDbL1H0kr
         kD+ZioYa02RNdsdEU5ptitubuDn7hAQzhIV4rQn0hyIu/rO5NDKEMk18tXcp7biLAZd0
         XyzH1z2+bjPrxnpstnqOQav7sDgINLY1K4t8StZH5wcu0EQVq2JKR2XzqP9xuhaeB7sD
         UhTPGUgO98096LysPqIRIGXXVhruHwXMSi58p9wBthERUl4KxjrSu60pkNkkt55/vEBW
         /+oQ==
X-Gm-Message-State: AJcUukfChlLyod9X/pWq/N2kx+d0BE6xCjx4RYpLqLDdksAtEpbeXhDJ
	0tGn2D+Z3FT2TD+0uoJxCqGYXjca1aA8IwC0Mil533CehaseWlwDn172XfQ7wxW9blNL83JP4Yk
	SQfMJzQsmr7rD2TlSy1gpOTsAHwG4pTBgAN3wxyI4COw4wk6O7tJXmfT73REJzQmZE+3OwyVsRw
	ZbzV5ZFIRfXGmK+cZ2Ea2GfpjThlof0BwAz5NXCvEafcM/jgj1xJRd8rdJ2f/yFreWitBbBP1qW
	a3TFoZrIlXiYQ8baH4AIOn8gHbEozefqJZD1ZxRLhD5W3DQ5oaikR6Pglj7XcBSflRG6XEpX9Fx
	AAbGxZFHYSmItvYiEVSrGEaShpu8ZwvISmgRtsJ3pwYOQiHABpnkUL64kilTgmnuvqInIwhByv/
	V
X-Received: by 2002:a1c:8d12:: with SMTP id p18mr23864207wmd.31.1548786372550;
        Tue, 29 Jan 2019 10:26:12 -0800 (PST)
X-Received: by 2002:a1c:8d12:: with SMTP id p18mr23864174wmd.31.1548786371809;
        Tue, 29 Jan 2019 10:26:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548786371; cv=none;
        d=google.com; s=arc-20160816;
        b=mJhIDC/E5zmX1Bk40kTPRjUvCZelmVRBJ5FmCgMN7SKxEP4v2LbOl1//V79Qx1b0LS
         YsNWB9bAHJKWZDoKcgPYIXIfSGT957gF/JM6e5gbUFn6KGHL3T6fqGJomLi5/RMjI6nj
         PtkDyBeG+89F+QBc7/TTMCnLl4jWsxQJjYB7bArwBxe5fztn0i/OLYrTEaXNCSbS4LIj
         XL8TXVGIGYPxqqvMI2Y0SFSrDUgeULBirX00IgteTP9PRF6xGFYz3h8gpwb/mF2oMg7g
         4NYc9oabaatxvn1JIA14NirRlqUdOiyaLlLlypf1XAy5A29ilhbX2dh3+wzTtSIeEeGP
         Zr5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ADwM0lszvaqhduF5I3DNeFvWPeUQTXjMtjOQKUDAPJ8=;
        b=0yS8CVOniJq77vuK1/CyUgZsDj8je/R0qyimY62NILg82ypNi7mDTLa6GJvP9ezktb
         fyEP0+PQvokSYodkYXt2hsjb2/Yoqc+Qs5Sd/zG2FkuOAymUvVzG6JLaBU3sIXJHqUPT
         krOVfENNc1AzQ1szKle8nu1Ea29By99UjrScvjFWFnhuup09b7V95Xh6CmKQpsBGgJT/
         YX0XFn3eYdpSxxeccCp9vX578oeVVTW80kdvCve0oJrQWkAUA+P+9ztUXuduPCEK2N2W
         CLJPD0lf8/KzTh3vfeOv9TrTANOE/i0mTUx2nnFjuLPs4nxakzhVCGPQWbgx9EA78XEt
         +gkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BXh7n98B;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j30sor81023691wrd.23.2019.01.29.10.26.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 10:26:11 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BXh7n98B;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ADwM0lszvaqhduF5I3DNeFvWPeUQTXjMtjOQKUDAPJ8=;
        b=BXh7n98B5xjbeB+aql7MNs/6BjRNZglzr66LB5d1zE4A4IXStoeq7g7volggkOR0jm
         Zw4Ew6E/Mn8x9yOekTa6e3ZeVuRcso8aX3m5+bpoW/SbRmwVAh7PW5CHhPa3QjTpqSWI
         uLYmSvffhC1lccnslt+fRVgCkeoPzinyOXdqCHzx03/tGID0YwW0bRIT+fsW57P472hY
         dIksMeGK073m5vEA30nAIeiNKStj7FtgFsaObHsW4CFEy8wMXyPrYI4K27+VKVl2sh9y
         MmAVuYcOhROvZCyChKdV3QsAE741Ix5ZmCqCkX3aa2Jdi2RMb+Cwe5vou1Ftliov/taq
         +Hdg==
X-Google-Smtp-Source: AHgI3IbJXcwKzyDgm1JDGoKVL5g4uCwu2Dk74NNLxZkW+r/uERASibjooWGTvyTUxd2OI6Moz27ryN1VdshIkuPqAI8=
X-Received: by 2002:adf:dc4e:: with SMTP id m14mr7274623wrj.107.1548786371209;
 Tue, 29 Jan 2019 10:26:11 -0800 (PST)
MIME-Version: 1.0
References: <20190124211518.244221-1-surenb@google.com> <20190124211518.244221-6-surenb@google.com>
 <20190129123843.GK28467@hirez.programming.kicks-ass.net> <20190129151649.GA2997@hirez.programming.kicks-ass.net>
In-Reply-To: <20190129151649.GA2997@hirez.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 29 Jan 2019 10:25:58 -0800
Message-ID: <CAJuCfpHyuY89Aw3YpQpaor2hKvdqJOH5sMoXNZ-yNAnAb+tY6A@mail.gmail.com>
Subject: Re: [PATCH v3 5/5] psi: introduce psi monitor
To: Peter Zijlstra <peterz@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, 
	Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, 
	Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, 
	linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 7:16 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Tue, Jan 29, 2019 at 01:38:43PM +0100, Peter Zijlstra wrote:
> > On Thu, Jan 24, 2019 at 01:15:18PM -0800, Suren Baghdasaryan wrote:
> > > +                   atomic_set(&group->polling, polling);
> > > +                   /*
> > > +                    * Memory barrier is needed to order group->polling
> > > +                    * write before times[] read in collect_percpu_times()
> > > +                    */
> > > +                   smp_mb__after_atomic();
> >
> > That's broken, smp_mb__{before,after}_atomic() can only be used on
> > atomic RmW operations, something atomic_set() is _not_.
>
> Also; the comment should explain _why_ not only what.

Got it. Will change the comment to something like:

Order group->polling=0 before reading times[] in
collect_percpu_times() to detect possible race with hotpath that
modifies times[] before it sets group->polling=1 (see Race #1 in the
comments at the top).

> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

