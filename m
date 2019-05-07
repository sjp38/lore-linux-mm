Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A916AC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 08:12:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C294204FD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 08:12:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C294204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA0856B0005; Tue,  7 May 2019 04:12:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A52036B0006; Tue,  7 May 2019 04:12:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9676A6B0007; Tue,  7 May 2019 04:12:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DCEE6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 04:12:42 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id d11so8838685otp.22
        for <linux-mm@kvack.org>; Tue, 07 May 2019 01:12:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NQ6dv2i93HZ0YYfKZpbV9MkWY21B58FCrXMAN8Dpx2E=;
        b=Ce8UaOTmzm3eGRx2qXrLNMJjbo+MB5CsnqRt5AX8SWAArtzkckBipvqaGCcnHFSsX/
         9KGwErn+jJZGP5CRHtz6PBz/C+k5aOBgrfHWOlrKf2N4V2CTNp7pTKf5CX7wCGAUCU3i
         lD2ybBYctA7TWcN2H9rh7vIU1+cMuSHJiCFoEMWjpL0FLLhabZtNqD4+A29NpRvcP7Jp
         1h1OSTzSkGFKRE77sITPK1QjY7b/oCtcgwjM3W4EUDkkt+YcRKBK1M1B+a+THxJBTFyp
         B6AISUmbXlC5F8ZrV+W4Qgnjk9ahWE4cfVmfbKnIb6zFgw2WEa07cjP5PqP2qCWW+7UE
         huEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAV4zXWZHdZw/93f80CcMUP7lTVDjEXA1jRR7FKr5UI/XSUT0MuH
	/3btfb5kZiH/DAKCbMXDhjq/HSZJkZkwnaTu5zewg1Y8JY0h+/Xu/uSQXOSLoVAMLyvV93G+cOa
	evfxsdsu9D2vuc+liP1Mgk41T4jYB/BWZIK8xnsze9CfzSfnItJXF6yVNYYBqxSs=
X-Received: by 2002:a9d:3445:: with SMTP id v63mr7851916otb.41.1557216762131;
        Tue, 07 May 2019 01:12:42 -0700 (PDT)
X-Received: by 2002:a9d:3445:: with SMTP id v63mr7851868otb.41.1557216761187;
        Tue, 07 May 2019 01:12:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557216761; cv=none;
        d=google.com; s=arc-20160816;
        b=w8pGF1ZethcgWVuGdfMnU5BPAWfTmrB1r9BG+EyRIO51XtKXF7BbMycTvEY1e1U/xI
         7O/XXscX/pl48o2iomJmCM2z+fWPc4t86U43p6QlgCBJ1aq/M5+PAyLYwgAPjN38SlGF
         RCRgDHzc/vOer8WEhUzWRD9SBgrlTeUzQvPlX+4w3HGp4On8TpfrwEcq0zBB0yWo+6nD
         AWKIGUuy6iyKneyhRZFZUIqfsvrlMHTuO5F7AZF+S80kp61zHv9WCha906noidE3I5Tv
         ePJ5M/qf9TXm+eF7El6c3WQ4zUsdH4QGBZX9Btfag3T8diW6lbJzVN51oVniJS6Xck8N
         qJUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NQ6dv2i93HZ0YYfKZpbV9MkWY21B58FCrXMAN8Dpx2E=;
        b=AAh7Cb7IKN1g9iU7IZ6MScR1NRpmtF6Nhct3npXMW3YXD7tHG4kqXKLRs+SRMPVJYC
         +0Dm2sFTpmBL3kFWeIc/5y1hmDgKAbmed3/WhPpH+ZgrDd0FHVfJSsxikgCYk9N2WBm4
         0UpRHrI1/QrJEiuUjc6NAkWq5byNYe31/lmJV8Bjgt1sBoZMqNiptiI3+AcrByYvKBo7
         YH1QNOy/10ZpxmHkTOZavsR0CrYnFXHrVvN33U4lr6q8X7M8MEHYobKmGuZwJ9WEI/21
         vbgOxi14t/XDgf+AkC/Xw1DKvD9nqCCEer0P2mN5fXtUjV14s//kZOkiSTe1X73f23DH
         bOqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r17sor1850922otg.84.2019.05.07.01.12.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 01:12:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqxazZcvVgW8B8Abx61RE3d6GpWO8pSjTz4Bl2xHSbS/zPSIG/vaJXjunEVO9ubN+ITWd3WpFw==
X-Received: by 2002:a9d:6d19:: with SMTP id o25mr3196049otp.151.1557216760884;
        Tue, 07 May 2019 01:12:40 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id k60sm5643992otc.42.2019.05.07.01.12.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 May 2019 01:12:40 -0700 (PDT)
Date: Tue, 7 May 2019 01:12:36 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	Daniel Colascione <dancol@google.com>,
	Todd Kjos <tkjos@android.com>, Kees Cook <keescook@chromium.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Martijn Coenen <maco@android.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	linux-mm <linux-mm@kvack.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Andy Lutomirski <luto@amacapital.net>,
	kernel-team <kernel-team@android.com>,
	Christian Brauner <christian@brauner.io>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507081236.GA1531@sultan-box.localdomain>
References: <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507070430.GA24150@kroah.com>
 <20190507072721.GA4364@sultan-box.localdomain>
 <20190507074334.GB26478@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507074334.GB26478@kroah.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 09:43:34AM +0200, Greg Kroah-Hartman wrote:
> Given that any "new" android device that gets shipped "soon" should be
> using 4.9.y or newer, is this a real issue?

It's certainly a real issue for those who can't buy brand new Android devices
without software bugs every six months :)

> And if it is, I'm sure that asking for those patches to be backported to
> 4.4.y would be just fine, have you asked?
>
> Note that I know of Android Go devices, running 3.18.y kernels, do NOT
> use the in-kernel memory killer, but instead use the userspace solution
> today.  So trying to get another in-kernel memory killer solution added
> anywhere seems quite odd.

It's even more odd that although a userspace solution is touted as the proper
way to go on LKML, almost no Android OEMs are using it, and even in that commit
I linked in the previous message, Google made a rather large set of
modifications to the supposedly-defunct lowmemorykiller.c not one month ago.
What's going on?

Qualcomm still uses lowmemorykiller.c [1] on the Snapdragon 845. If PSI were
backported to 4.4, or even 3.18, would it really be used? I don't really
understand the aversion to an in-kernel memory killer on LKML despite the rest
of the industry's attraction to it. Perhaps there's some inherently great cost
in using the userspace solution that I'm unaware of?

Regardless, even if PSI were backported, a full-fledged LMKD using it has yet to
be made, so it wouldn't be of much use now.

Thanks,
Sultan

[1] https://source.codeaurora.org/quic/la/kernel/msm-4.9/tree/arch/arm64/configs/sdm845_defconfig?h=LA.UM.7.3.r1-07400-sdm845.0#n492

