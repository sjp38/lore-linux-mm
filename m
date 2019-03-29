Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13205C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 18:09:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFF65218A5
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 18:09:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iHXxaJID"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFF65218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 597B46B000D; Fri, 29 Mar 2019 14:09:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56D1A6B000E; Fri, 29 Mar 2019 14:09:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4368F6B0010; Fri, 29 Mar 2019 14:09:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 071DC6B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 14:09:41 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d10so2190611plo.12
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:09:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=s4ZCUKfRLPJnIxAUuStXAE+wg+9f7Meg4+UY3x4a0tc=;
        b=FLL5Er8ZK5eEy0sg4GTwibKLeieYeshC92h9DU2mggzQj8Ija5XjBCX4XUy1zzVrSM
         dbkwRNo4Zz+4PeXgBgHARTRw06UMDF1XGznyqj/ljKPWDHrOU4JQHAVgk/+1Ifbwb3Kc
         ibyto8tJo8PGQTn+Ukp/ZRNbQpz85484mtfScAEpv9zqyQfLylvBG7QxUmclxQwv65FX
         NJbYsOZ8XtbmCJPnzUG9XQ94ZtNcQjY89obffT+tjZifBQz9D3HwGn1r0CqXQ94xn19E
         zQ983DqJx0yHCNmbNAJQpWoVEnneU7br0cIgcX1i+Byp3o0axF+RUGhKteBIpPWTl6Jo
         qpYg==
X-Gm-Message-State: APjAAAXZ0FWzVirCyNgu2bQXjslMpXAwu4ko5JeVqjpmcNmu3tB6HR5O
	fP+rU06Esrs8GTSiX3242ZL22s3ZmKniYK3AnOqc12lQnG83KJhB0y8jE9VSX6HxioTo9m3VTml
	zmdUmewi16DcPzGYieaf76k06lzL6+9TzxRESKYOvsV7S/m64fzGohZmja8zVG4G43g==
X-Received: by 2002:a17:902:4827:: with SMTP id s36mr16342330pld.296.1553882980648;
        Fri, 29 Mar 2019 11:09:40 -0700 (PDT)
X-Received: by 2002:a17:902:4827:: with SMTP id s36mr16342277pld.296.1553882980095;
        Fri, 29 Mar 2019 11:09:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553882980; cv=none;
        d=google.com; s=arc-20160816;
        b=psuM1go2V7i+qSwfg1kggMr5DkoKEvMEDe3BugqT2KlGizcxHoBTWKxL2RhKkqOn8G
         lnrsWLux7I6PzpPVlYHdAe5cn5250TjM/GW/I4IOTo+qFwiCVwASf1uqOhcVSjOW/fSI
         DuNLr1LBse9Ctge4MQqaUqAl40cx63gJxpUdAVTC6QeO8Cq0PBVgeNTuyaRkrGzXC3lO
         0egoZl9+AKmds6p9OCEPWgdUfPy+YISoYlcvg579oKKIdECOSVk8mIlcF6Kuqk1K659r
         HFLMV231fib+BPeD5y5FTTMgIQjXRyQ3SgS7mgA3PGe5wYpWz4ZwgLxuqoPkFNDnFa9+
         pybA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=s4ZCUKfRLPJnIxAUuStXAE+wg+9f7Meg4+UY3x4a0tc=;
        b=Dasw1yWIVVTdMZBUEBBXuryblVkuIVZFco+PSskoLU0JgjG8FGtYfgqSwAj3+KODmB
         x9AW0t0Q4lKDjTDPeOEFHcidDPIbuuBjQAeHMp/n0PFhCIlD4kkVRl58evCrqOM+JBkE
         2OgqeIPEG6AvVH8Vzwm25I5+iLYs4m7CryvFwG+CoY9xV6Ty5y4MBnkgg05+U1LgO/b9
         r/XYRhmp9V+XuUxdbFb9LFrRoZNeF5S2f74CgIX+nXhaB31se5MbzBr3RHPFuW8sftij
         VYNUS5qVlkdw6RHATrOzVAD4Rc6oMFg0B8e69VJ90ZPyhQTJxK3frkiiNlQkSMfc6kI2
         DW0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iHXxaJID;
       spf=pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ndesaulniers@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j7sor1349538pfa.29.2019.03.29.11.09.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 11:09:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iHXxaJID;
       spf=pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ndesaulniers@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=s4ZCUKfRLPJnIxAUuStXAE+wg+9f7Meg4+UY3x4a0tc=;
        b=iHXxaJID1cfcFFuS4BGDnRyg9Mxplx4UhQoViLW3/gt5s5HuCZPp0EWOtuBz1X7fKt
         WAuEATJBmWOLWZxbPAQSevDxuA3jUitzRs+m1m/Hr2gELSKiEmq7P+I1SbTROFV40kDM
         P28z3Q6P+VRj7IiWG1u1n7IxIXi9y63/9R8wqZNUOcoNQv3EYcDm00vASADxRdLOwR6p
         D5Xi/zzjhTfjkUmnVjEuExzjV6MyNdw7NlyqZqivoz8kRQ9mUbtuqFDHK8F+UtUTGqeM
         j16u9bxOtDrqjxnrxrPWdup2xEJqZfP4PHseCUHfolSHGPreR+NMcnuyZPVyEB5OitUQ
         U83Q==
X-Google-Smtp-Source: APXvYqyAiLFvFmAzP17NJ+HtjCZy23KROjG8Dcmjfu2QSFVMdm7SITNkMr0Jg5U4JI3OnJm1c4zZxj/jiGjXg1dLHR8=
X-Received: by 2002:a62:7603:: with SMTP id r3mr48744017pfc.32.1553882979336;
 Fri, 29 Mar 2019 11:09:39 -0700 (PDT)
MIME-Version: 1.0
References: <201903291603.7podsjD7%lkp@intel.com> <20190329174541.79972-1-ndesaulniers@google.com>
 <9f1ad3e1-fad7-2fb4-31c0-d31832468143@infradead.org>
In-Reply-To: <9f1ad3e1-fad7-2fb4-31c0-d31832468143@infradead.org>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Fri, 29 Mar 2019 11:09:28 -0700
Message-ID: <CAKwvOdmv4_8pN5r8EO8c59WN+EE7ZPST8qHKMg7SzPH1rzaqag@mail.gmail.com>
Subject: Re: [PATCH] gcov: include linux/module.h for within_module
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Peter Oberparleiter <oberpar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Hackmann <ghackmann@android.com>, Tri Vo <trong@android.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org, kbuild test robot <lkp@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 11:01 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>
> On 3/29/19 10:45 AM, Nick Desaulniers wrote:
> > Fixes commit 8c3d220cb6b5 ("gcov: clang support")
> >
> > Cc: Greg Hackmann <ghackmann@android.com>
> > Cc: Tri Vo <trong@android.com>
> > Cc: Peter Oberparleiter <oberpar@linux.ibm.com>
> > Cc: linux-mm@kvack.org
> > Cc: kbuild-all@01.org
> > Reported-by: kbuild test robot <lkp@intel.com>
> > Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
> > Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
>
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> see https://lore.kernel.org/linux-mm/20190328225107.ULwYw%25akpm@linux-foundation.org/T/#mee26c00158574326e807480fc39dfcbd7bebd5fd
>
> Did you test this?

Yes, built with gcc 7.3 and
defconfig
+
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_GCOV_FORMAT_4_7=y

> kernel/gcov/gcc_4_7.c includes local "gcov.h",
> which includes <linux/module.h>, so why didn't that work or why
> does this patch work?

Good point. May be something in the configs from 0-day bot.  Boarding
a plane for Bangkok, but can dig further once landed.

Maybe module support was disabled?

--
Thanks,
~Nick Desaulniers

