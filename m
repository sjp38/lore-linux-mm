Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC717C04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 07:27:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A24C620C01
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 07:27:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A24C620C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 322BF6B0007; Tue,  7 May 2019 03:27:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D2CD6B0008; Tue,  7 May 2019 03:27:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19B3F6B000A; Tue,  7 May 2019 03:27:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id E5CE26B0007
	for <linux-mm@kvack.org>; Tue,  7 May 2019 03:27:27 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id i21so8814614otf.4
        for <linux-mm@kvack.org>; Tue, 07 May 2019 00:27:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XByBP7XjRmOOGyhrd0e8L2R6PtcwPlhf6jPxirpwBCU=;
        b=Ww+luZNYqhhY4BNWxEktjgjcGC6mrAZvbJi56b8NjB5DemedlKJQEDBEJ2L/BzKOL8
         kIbgScdPakusnEnRDPUjRcx/DENInW5CM4nILXouBMHADVXCgMPfTPoDMJi+JwLD3eyM
         ipzzslJ2wNH9RfOdk4ixpSz/8mT4+MitBg7KGU2PjnZ1sadvZnwLr+egiEMM7EgOOahd
         KUyx+UwyA/EZPW46iXh5Jz4qilfui8JL+FkdGb0hxP9vvhufkVwnIih/Flkt5zCsfGqR
         1VW1EOy4X/SYYMs+A7CEALjaWbjzaMhPtmF067zzUtcys9LbC8Ft3Mt2oJpq5CqkQjqC
         3Oqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAWnFqrJVYCev2bP/Cnfauxe9/xh9ok1SEBDHXLwsard+DeOv6dS
	TJHpjWefAsOQSSOTYo3KXjMUzC7LpOVRUqFmnrlTUZym5KQqHsyAflidnkEH+MBdRnpsVsdjvGX
	rwY9cHgzIdNZqKqcb4NQWtD+nsdnKnxIWcJvdzNSdAd+21iUNBiDimagW+Ee2xXs=
X-Received: by 2002:a54:4698:: with SMTP id k24mr1535883oic.104.1557214047467;
        Tue, 07 May 2019 00:27:27 -0700 (PDT)
X-Received: by 2002:a54:4698:: with SMTP id k24mr1535846oic.104.1557214046598;
        Tue, 07 May 2019 00:27:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557214046; cv=none;
        d=google.com; s=arc-20160816;
        b=T9jA7912hiwCONzulhQl8PtXB3xmpOYOyIv4kA265RNR4HcA0ogcyJhu6Q/aVz8Sh5
         kCrEk22qarW4qWymMGMrMaUe/uIdjaM3dud5/NrgLNHb4AzDNLd7o8cq3hSQKIOv1V4L
         g0VgpmwLXGvaBJUEgmfg4Spo1837o6hrEDkW8NF35ZVyUycQezBow0njbELg+dH3Bvn8
         MDJp9M6xN6cOKuBO3sMoCgdGYrIqFoBLv59UpG8S+C9IWD19AAqd2qmAtXp+TmTLpkLZ
         LlUQhY4RqqPs4FCRYh4mJ8fYTAcwQCCHDGeTu0Wd/Iv4MNxjJODALwKXlnFKh4kPpEWm
         AdsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XByBP7XjRmOOGyhrd0e8L2R6PtcwPlhf6jPxirpwBCU=;
        b=wmipzP9C1lH7bPCINAG71zH9BfSSIPND89SvjqEjmclphm0Z7/yTYhLWsN7/ZM+m5R
         BTAMCkehrlTWrZPAv4j3AIaZJv+ZU7n+JungyjsX7HAbRcrlc9UelLlyBS5M2W/Vf6BF
         q/h1/4EMqDyq/DeRiJkt1SSh4+rug5pHhsAZgva4H0FKuocXHX3CxYvU2Exw8a9GKBZF
         8nxPIug/XYfxihWMAbqaswT0mk2Ac37n+kzjBvgxtgXbYKuTxZHiM/nMkRToMwlTCEtp
         lwp2V458AW/m9alVqgiRniv1E5gL0gvbuiC7Tk+H6yW1Fi6C+aCNtsuEESc/QPRg8jFA
         KLRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d19sor5820269oti.103.2019.05.07.00.27.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 00:27:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqyG6hXWXWpi7XEBI/DlyfoNWcZlsC+PlPheQwnNUwyImO+kZSLDKaxa2x4xmrLvZ3a+smTnDA==
X-Received: by 2002:a9d:6c5a:: with SMTP id g26mr10914341otq.187.1557214046204;
        Tue, 07 May 2019 00:27:26 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id s26sm4968147otk.24.2019.05.07.00.27.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 May 2019 00:27:25 -0700 (PDT)
Date: Tue, 7 May 2019 00:27:21 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	Daniel Colascione <dancol@google.com>,
	kernel-team <kernel-team@android.com>,
	Todd Kjos <tkjos@android.com>, Kees Cook <keescook@chromium.org>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Ingo Molnar <mingo@redhat.com>, Martijn Coenen <maco@android.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Suren Baghdasaryan <surenb@google.com>,
	Christian Brauner <christian@brauner.io>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507072721.GA4364@sultan-box.localdomain>
References: <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507070430.GA24150@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507070430.GA24150@kroah.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 09:04:30AM +0200, Greg Kroah-Hartman wrote:
> Um, why can't "all" Android devices take the same patches that the Pixel
> phones are using today?  They should all be in the public android-common
> kernel repositories that all Android devices should be syncing with on a
> weekly/monthly basis anyway, right?
> 
> thanks,
> 
> greg k-h

Hi Greg,

I only see PSI present in the android-common kernels for 4.9 and above. The vast
majority of Android devices do not run a 4.9+ kernel. It seems unreasonable to
expect OEMs to toil with backporting PSI themselves to get decent memory
management.

But even if they did backport PSI, it wouldn't help too much because a
PSI-enabled LMKD solution is not ready yet. It looks like a PSI-based LMKD is
still under heavy development and won't be ready for all Android devices for
quite some time.

Additionally, it looks like the supposedly-dead lowmemorykiller.c is still being
actively tweaked by Google [1], which does not instill confidence that a
definitive LMK solution a la PSI is coming any time soon.

Thanks,
Sultan

[1] https://android.googlesource.com/kernel/common/+/152bacdd85c46f0c76b00c4acc253e414513634c

