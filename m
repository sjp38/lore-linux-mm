Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D50FC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 19:56:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE2CB2073F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 19:56:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZfbLouN/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE2CB2073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CAA96B026A; Thu, 11 Apr 2019 15:56:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77AD86B026B; Thu, 11 Apr 2019 15:56:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68FFF6B026C; Thu, 11 Apr 2019 15:56:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DFB76B026A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 15:56:46 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id y7so4694653wrq.4
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:56:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Lg0hWMJ42KhS273dLVmtjiem1n57p0phYc3aCztZZmg=;
        b=XvSxrMLKIXnqEla5B40bGFGnYB1DIa3B1cXKuz1YDxcIEuzGX1d1Vn3MvRs9jGSl2D
         G9MY+yCASAQbjLBBpT0FXL6wLkb7zl44P6hH+/KUL5Na7J3yegqQl2TaOAT4Ttm/1v4J
         WoDA8rtVVBAWgMBu3yPIRsrIAbKvcSpbB/pqTBWxRV31SI10Y9tqIEDws5NMXzl/0aW6
         q02Wwgr7bRngqGivJ8u1zoQXOugf5xWIE/B/GHmbSb6pxu2XGjrfuam/n8CTufrsXDB2
         kvUR1lalnoggj59/QYPx1GKaV8wGH/s+l3vdS+k3x90+0m1RDZkv2ala3i8+1c6dxTrM
         6XAQ==
X-Gm-Message-State: APjAAAVafpLJ/nOLIbjV/5mb1qG+fwsYDKyw45oTZMlZlAjp4rZ9FcXq
	sT0cpw69cSdcm9JJvOoKUvy3rFVL3SYhZVy2en2yjRxidciW3qM4d7xPk13Pj2x0xFt7JNC7JRD
	NTmEvFxxuI+QOlx/w9oIxLfZJ4w8fc7K/cdKLpXkV5G/aiFUchoTNA7YDevNSLhRCJA==
X-Received: by 2002:a1c:f310:: with SMTP id q16mr7660796wmq.102.1555012605437;
        Thu, 11 Apr 2019 12:56:45 -0700 (PDT)
X-Received: by 2002:a1c:f310:: with SMTP id q16mr7660766wmq.102.1555012604693;
        Thu, 11 Apr 2019 12:56:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555012604; cv=none;
        d=google.com; s=arc-20160816;
        b=k1519Ojv2nexqIYV4+8bDr3SZus7l1McHjiowA+aeJRjRSSQ4sDFS4D9ga47kJYGjL
         qTP06vLm5KXCBj/xchRGvRSTPZDDze8cCol3xOphxPvPSATlBqK4CWNE1jevJTJmd9J3
         F57o04QWPuq6ztt7CMyduN3PNQvJigfwB3VtSwz7nCUYOBcGZtbVqI6joQPEJOff6TDj
         cJJW7hnfJmDWXLBmxrYmOuj9T3/ut6gIA8NVnt3toOB16RM7LljzpshdB4NW/bNunihV
         GQVzKHv2ec3rf1i/tcuNyn7hJRt707BD5ycx8O9nU5Yn1C8FBt2P0rV5MfV1arpYzxLk
         nXNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Lg0hWMJ42KhS273dLVmtjiem1n57p0phYc3aCztZZmg=;
        b=wxU2hlZRVsDMdoHvDzb4AFAT+djKjofXXzWsjWHS9ogJzWovsP01dWBG/dmDptMzwR
         Q0hS/2GORQQQDnw8kOTPOhMLlmkzTB0LvjzXAAt8MLSsNuXPQt38JV3PxCj38QzSrkSj
         itjTs9KiOS5OIieLT8v0xiUipRg9r2AvdtlSSEFGbXCAi3r4AlXVZvuRUxZPOfCUEFR2
         kzFYJ51GreiOh0m8e4RVdn6cdLO5NiSm8Weu7A7+430SmP6GjCr6yhFv+4xetT4iLoSc
         mrp8G640R8F3NPLa6dcnygl+SyzkdZDsph2421tVghupnVLf1m2X2JqrgWVWlQ41y+xl
         78UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="ZfbLouN/";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n129sor4274275wma.19.2019.04.11.12.56.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 12:56:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="ZfbLouN/";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Lg0hWMJ42KhS273dLVmtjiem1n57p0phYc3aCztZZmg=;
        b=ZfbLouN/yweSuJhHjVGX3qEBDhFipr1oU9Ux4JpVEY4ccPHDmRRjGkFvjsDvAmYf3g
         1pDg2ro6jZdw/T2aSxXiKjvAaq6/EiYvlfHQt6+BZ3+mn4MtVWEjsf3hM0glyTVXHxSl
         Xw5jcTP/LGwql0o47dSWBf1iwV1j5yxOfx8uEyOTuWtQI+WyC/LFiQqPWCcAwn2irhP3
         93Qm/bmSPNR1pWmSUuoPzG3Dc+wN7pBFww7r98LzOv6rfTpkOZSQB0iSFMfQ1ogyv28I
         e2zI9hVGG1Mt5N8Eoo6n9EOeQGbxaTtZqTQUiTf+vgF/fgKf0rvaX9SVOn2fm6HXASCa
         Z3sw==
X-Google-Smtp-Source: APXvYqxcQbob+za9RtxHt5VEPHNzn+qHcbGuUw8nqxG71DyZhYNjRHFFhJRI11WDs1FeGghLePlsv4QZ23K7Ern9EPE=
X-Received: by 2002:a1c:cfcb:: with SMTP id f194mr7621486wmg.51.1555012603911;
 Thu, 11 Apr 2019 12:56:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411105111.GR10383@dhcp22.suse.cz>
 <CAJuCfpEqCKSHwAmR_TR3FaQzb=jkPH1nvzvkhAG57=Pb09GVrA@mail.gmail.com> <20190411181946.GC10383@dhcp22.suse.cz>
In-Reply-To: <20190411181946.GC10383@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 11 Apr 2019 12:56:32 -0700
Message-ID: <CAJuCfpERmBzCpRTj5W1929OOiVEjcdBoSAsYXiYKoq0gsgRyhg@mail.gmail.com>
Subject: Re: [RFC 0/2] opportunistic memory reclaim of a killed process
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, 
	Matthew Wilcox <willy@infradead.org>, yuzhoujian@didichuxing.com, 
	Souptick Joarder <jrdr.linux@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, Shakeel Butt <shakeelb@google.com>, 
	Christian Brauner <christian@brauner.io>, Minchan Kim <minchan@kernel.org>, 
	Tim Murray <timmurray@google.com>, Daniel Colascione <dancol@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>, 
	lsf-pc@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 11:19 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 11-04-19 09:47:31, Suren Baghdasaryan wrote:
> [...]
> > > I would question whether we really need this at all? Relying on the exit
> > > speed sounds like a fundamental design problem of anything that relies
> > > on it.
> >
> > Relying on it is wrong, I agree. There are protections like allocation
> > throttling that we can fall back to stop memory depletion. However
> > having a way to free up resources that are not needed by a dying
> > process quickly would help to avoid throttling which hurts user
> > experience.
>
> I am not opposing speeding up the exit time in general. That is a good
> thing. Especially for a very large processes (e.g. a DB). But I do not
> really think we want to expose an API to control this specific aspect.

Great! Thanks for confirming that the intent is not worthless.
There were a number of ideas floating both internally and in the 2/2
of this patchset. I would like to get some input on which
implementation would be preferable. From your answer sounds like you
think it should be a generic feature, should not require any new APIs
or hints from the userspace and should be conducted for all kills
unconditionally (irrespective of memory pressure, who is waiting for
victim's death, etc.). Do I understand correctly that this would be
the preferred solution?

> --
> Michal Hocko
> SUSE Labs
>
> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

