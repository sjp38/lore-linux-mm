Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0590BC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:53:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCD6120818
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:53:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCD6120818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 424796B0005; Wed, 15 May 2019 14:53:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D6256B0006; Wed, 15 May 2019 14:53:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 250AE6B0007; Wed, 15 May 2019 14:53:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E8E3F6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 14:53:02 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id r84so360112oia.9
        for <linux-mm@kvack.org>; Wed, 15 May 2019 11:53:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=F+uKuYKH8D9C30taRndDf2f3BiyObetVuhxljsMhA+w=;
        b=JW6rGHKw+iaN8KLUiFjTNl3tjRFCbY+iB256DcZlrnzRgxWaxRdpOrFmludyTDH8BN
         xsEuA6hpqIZEEkS3875Fev7LavvPaEHv4IP1cEaNNFxiO5mGQhYyEJQFmtBie9pIdndh
         eivvn4fQSlSfaJHnM2U6p6hJgUwJGBZqYecemeklVJbuU4yVmR/r3yKKXixaJah+e5XY
         zgSlDjK2DKhGKOLtuQwLeD2ILTzFenNsxT6CqNA9nLNXa1KMiiojR0PdG/yU0TAY4ae1
         NcLBQ8kpm+L/09YMVBbBEI7keeXmQ1Avlin9PzbBdmfcj3G0tms6leuR0x468ke6D1xG
         6Ssg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAU0gKs2fGLHMY/iT7U+k7SunDRcmu2etV3ou1gxkSEmM3w8RpIO
	A8M/lh6mtqbwqpeQGSM+V86oIfS03kTpeuV+NCNkswtzjPlqZItjEMpfSv1BTUeEhLsYgTrQXza
	AFH7w5IwroDMAgE5TnqN3cb52ZVlkgzMulGWS7eV1uYTQFzoSBb4t2nUy4EnlAkw=
X-Received: by 2002:aca:845:: with SMTP id 66mr7713745oii.163.1557946382570;
        Wed, 15 May 2019 11:53:02 -0700 (PDT)
X-Received: by 2002:aca:845:: with SMTP id 66mr7713720oii.163.1557946381862;
        Wed, 15 May 2019 11:53:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557946381; cv=none;
        d=google.com; s=arc-20160816;
        b=ge5WTZYx8eUH4jF0unwRgpC+zE+ALEnyGtaXIW3Uvmg4n1UFhf4g0sx8InCvAXUwOL
         1deBbz+oZ1pIGZL89RLceexcfqZPE8NISd6wz3fMWIKn2/yp+HO38lPzhroqo7BqagWJ
         Gmib9GRCKAUfoxpuepXm6jRat7an/2QZuUs+JcHCNiOKoCETdIeLC1x/yAlNoqZTPzox
         8zWp59r8kqIUmfofZIXc5SA4hm3xnN04nu9sgXg3XHX/4fIBRr9hJotnpC6KgkK/GY1c
         eq/jEO2BU7WSBQ0+XNdiPAPejEWNsCzx3fEcQVuHuKv+WkUbq7j9QODQH8kT9QaVTeZj
         0CoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=F+uKuYKH8D9C30taRndDf2f3BiyObetVuhxljsMhA+w=;
        b=fBbWmOWVVdR325OMJrpiZ+X2LlG7m/hb/nxLsL1YELJ3LBL2ely8IcEShdtm5nZgKt
         16VBMIvAOEfhVndDnsZe81WondLJ/+A6aCjQ7GQmLD3U2QZW1C/11dr3SqMYz2erB5uW
         W0mnzqB6SRalz8VyDBEGHZ1J9tYsH07SgJjiyQkLoE7t4rzqfOTVUOny5kLTjhg/9HPl
         PS/55c2Czh+HZmaZkcR/+nD7oP6Zoigc1yhvZxSGAju/BbyaJ0nH/3sE5IKMUomrj4LW
         iDUX31VPajt/63r/q9+f7hNIWWR6QNVyQU6E4G1T1LumBAhGqqeTdm0VCC+/ytJBb2K9
         kkoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c17sor1453853otn.100.2019.05.15.11.53.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 11:53:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqyB1lZtLwM2VdgPfATea+juZlcCsSuhi3KGqNsEZFCafam8pMbRKx9qHz3/tcPn80X+Dfi0tA==
X-Received: by 2002:a9d:7643:: with SMTP id o3mr17247096otl.129.1557946381574;
        Wed, 15 May 2019 11:53:01 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id h23sm1062735oic.10.2019.05.15.11.52.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 11:53:01 -0700 (PDT)
Date: Wed, 15 May 2019 11:52:57 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Oleg Nesterov <oleg@redhat.com>,
	Christian Brauner <christian@brauner.io>,
	Daniel Colascione <dancol@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>,
	Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190515185257.GC2888@sultan-box.localdomain>
References: <20190507021622.GA27300@sultan-box.localdomain>
 <20190507153154.GA5750@redhat.com>
 <20190507163520.GA1131@sultan-box.localdomain>
 <20190509155646.GB24526@redhat.com>
 <20190509183353.GA13018@sultan-box.localdomain>
 <20190510151024.GA21421@redhat.com>
 <20190513164555.GA30128@sultan-box.localdomain>
 <20190515145831.GD18892@redhat.com>
 <20190515172728.GA14047@sultan-box.localdomain>
 <20190515143248.17b827d0@oasis.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515143248.17b827d0@oasis.local.home>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 02:32:48PM -0400, Steven Rostedt wrote:
> I'm confused why you did this?

Oleg said that debug_locks_off() could've been called and thus prevented
lockdep complaints about simple_lmk from appearing. To eliminate any possibility
of that, I disabled debug_locks_off().

Oleg also said that __lock_acquire() could return early if lock debugging were
somehow turned off after lockdep reported one bug. To mitigate any possibility
of that as well, I threw in the BUG_ON() for good measure.

I think at this point it's pretty clear that lockdep truly isn't complaining
about simple_lmk's locking pattern, and that lockdep's lack of complaints isn't
due to it being mysteriously turned off...

Sultan

