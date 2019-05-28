Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DB81C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:37:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D00BB21734
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:37:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="F1ETGdXe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D00BB21734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FAA36B0283; Tue, 28 May 2019 13:37:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B3286B0284; Tue, 28 May 2019 13:37:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49AC46B0285; Tue, 28 May 2019 13:37:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD6456B0283
	for <linux-mm@kvack.org>; Tue, 28 May 2019 13:37:35 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id 7so3890615ljr.23
        for <linux-mm@kvack.org>; Tue, 28 May 2019 10:37:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=F2jMeMvfMZ6+f8aMiqek9ZN+qjHWyjCaTe5iI/rDq+E=;
        b=CJOIdFvhPdkplMoKd/4vU1SyH0JhOXkWcQfFp7Ai7X3uNHUO8Fx8JM1/gYQdepgdiC
         EB2xvPMiupeTAkshzLTS7CWFiYjqlCo4cgSNjjil3jTa5mV6ZIwY6HDJthYTsYFsRAyw
         PBEimHW/8aG2x64KhZoF5HIlWA+wa2b8aAt/ONnGsP2flzdRMH53hg5EyUSLEEnYY4ZX
         eZ7d0nZZsD+Q5NqEjmjpdgBxVST4VTsJFhcl65w9a9aa+LiScppUg8wUFI4fF+Kn6KFL
         Ll+RuaU0gXuZM6d5Cj2voln1Hbut7fHu5OxzJrS3jayjA0AdBmlGeRge7rf5Wer9xAZ4
         Jv4g==
X-Gm-Message-State: APjAAAXLv1SEbUyTV7GHW9puFCqe+L6DReZdrvZBQaKrPcVt+r6P5sXd
	LJks/P8Vn5rbQaF7IjKdvCWE11RJMIyNgW6mLuOEg6LRP1fWWsSWppDvCz9q8z9s6HGaUOSxYQE
	oOTv2j6ymCKTNWjTmxp9yXbjyalLMt8z6aplZMSSrGV5D49zNRSgTfqkG9sdrHlL7pQ==
X-Received: by 2002:a2e:9a97:: with SMTP id p23mr23338203lji.160.1559065055378;
        Tue, 28 May 2019 10:37:35 -0700 (PDT)
X-Received: by 2002:a2e:9a97:: with SMTP id p23mr23338172lji.160.1559065054613;
        Tue, 28 May 2019 10:37:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559065054; cv=none;
        d=google.com; s=arc-20160816;
        b=r5lC2J2VLneqsoCNEs++PqkazOe+/Kzlsche+wb2M/7Cbt5YekyNkdUYYldLCfZcn/
         6HerkM98IMIU4LE3tV560SSo9eDJfGXpZiEEqUuvN2IEAowOcZQUsMFMpr15Hf/TV1GP
         rZ6YhlRzOUw9OF4CGUcXzKXHc96c7WrFTCHLXTNWhbC45drNO8DuH27o4/ueO+I9hAas
         S8Nduc87/hzU+zkB/V3VyfEnhpLJcN1dKWJ1KZEiFy49Dv9wML+YRqfENz9oHSDV0SDQ
         +kCBdJm3Hx/zKi66TmBoSYSydOYn8rf9gLQQzQhxYaQMdzWb7MB/1N11O1x6FDLEmqAk
         x/1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=F2jMeMvfMZ6+f8aMiqek9ZN+qjHWyjCaTe5iI/rDq+E=;
        b=OMUv1N9jOh/oW5C2VyPI1USa1JRXKJnMLFRUPGj3m8FXmIVKL/nWhZxuul/u1erTIc
         5MGmhf2dqA6bgxa+UTZuQo4GpOdlihRyma5BjRSGl5jp4fa0GObKoRr3PKnZW/L0E/75
         yknnsiIkdmoZiW412UDqxOfb3xBNGkFH6ERuN2Jnox+q7Kob2xxL2ByrjZk8jvZzWdnD
         6HJAGDOACLusmhW1SuSUDUWKDOrCrShZmqgL/hTw9e6pKAxwiW9wRE+WZk/0OKmCxsbw
         MgEnaVcykwDbA2PbVsGGL/G8Js8gti2JOVzWVSrxVF5ovSTraEMI0mQKMbuMExLsDt0v
         kPhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=F1ETGdXe;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u4sor3917044lfc.47.2019.05.28.10.37.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 10:37:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=F1ETGdXe;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=F2jMeMvfMZ6+f8aMiqek9ZN+qjHWyjCaTe5iI/rDq+E=;
        b=F1ETGdXeFfCBHmdWbLBHd8vZ7taVOvI6ORkmxBqkgmnSIzcWwbuL7Fhv0S2FLp97AT
         XCPInppgu1tkfwt4dcLiPmzEju6ML58hvTfKMWoxMW2Wuusd11zPUwBSNYNdyPwqwnst
         6LPs3DuCLXNIyE4Zp2se+L+KeAMs1gw7ROLd4=
X-Google-Smtp-Source: APXvYqwNakSvNRcfHvnrWJo4v2tkWC3B66dQWKw3JrDSQubWhIvoZfDe+dgc2mpkMqWQATqa3u4kmA==
X-Received: by 2002:a19:8116:: with SMTP id c22mr6939420lfd.111.1559065052994;
        Tue, 28 May 2019 10:37:32 -0700 (PDT)
Received: from mail-lj1-f173.google.com (mail-lj1-f173.google.com. [209.85.208.173])
        by smtp.gmail.com with ESMTPSA id 20sm3029669ljw.7.2019.05.28.10.37.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 10:37:31 -0700 (PDT)
Received: by mail-lj1-f173.google.com with SMTP id q16so1422140ljj.8
        for <linux-mm@kvack.org>; Tue, 28 May 2019 10:37:31 -0700 (PDT)
X-Received: by 2002:a2e:85d1:: with SMTP id h17mr49489655ljj.1.1559065051361;
 Tue, 28 May 2019 10:37:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190520063534.GB19312@shao2-debian> <20190520215328.GA1186@cmpxchg.org>
 <20190521134646.GE19312@shao2-debian> <20190521151647.GB2870@cmpxchg.org> <CALvZod5KFJvfBfTZKWiDo_ux_OkLKK-b6sWtnYeFCY2ARiiKwQ@mail.gmail.com>
In-Reply-To: <CALvZod5KFJvfBfTZKWiDo_ux_OkLKK-b6sWtnYeFCY2ARiiKwQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 28 May 2019 10:37:15 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgaLQjZ8AZj76_cwvk_wLPJjr+Dc=Qvac_vHY2RruuBww@mail.gmail.com>
Message-ID: <CAHk-=wgaLQjZ8AZj76_cwvk_wLPJjr+Dc=Qvac_vHY2RruuBww@mail.gmail.com>
Subject: Re: [PATCH] mm: memcontrol: don't batch updates of local VM stats and events
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, 
	kernel test robot <rong.a.chen@intel.com>, LKP <lkp@01.org>, LKML <linux-kernel@vger.kernel.org>, 
	Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>, 
	Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 9:00 AM Shakeel Butt <shakeelb@google.com> wrote:
>
> I was suspecting the following for-loop+atomic-add for the regression.

If I read the kernel test robot reports correctly, Johannes' fix patch
does fix the regression (well - mostly. The original reported
regression was 26%, and with Johannes' fix patch it was 3% - so still
a slight performance regression, but not nearly as bad).

> Why the above atomic-add is the culprit?

I think the problem with that one is that it's cross-cpu statistics,
so you end up with lots of cacheline bounces on the local counts when
you have lots of load.

But yes, the recursive updates still do show a small regression,
probably because there's still some overhead from the looping up in
the hierarchy. You still get *those* cacheline bounces, but now they
are limited to the upper hierarchies that only get updated at batch
time.

Johannes? Am I reading this right?

                   Linus

