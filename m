Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,T_DKIMWL_WL_HIGH,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E056DC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 07:43:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A22C321019
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 07:43:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2MVgXQNq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A22C321019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38AED6B0005; Tue,  7 May 2019 03:43:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33B576B0006; Tue,  7 May 2019 03:43:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 203546B000A; Tue,  7 May 2019 03:43:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB4586B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 03:43:38 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d7so4313625pgc.8
        for <linux-mm@kvack.org>; Tue, 07 May 2019 00:43:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7lQZZQUvbrpCglPdrHtpC2hCfoI82JB8YsYbcjRty0c=;
        b=D0hU9EXR/v+COTU1gSajE5cEttKuzSJYTy8U450JgJJHa5pRjCmu9B77X4PLyFtPY+
         f8tYmHc67sg5J5qO/Mgj+BABzygY6c/Hk2uB7xFM3FMMi0xNi1XtQJQ9goBSURU6T6Ct
         HnVKxPiBNAWYmShCmD7632xDM4Uw41VrKHnFIYxkXUUEg2GOzObBZ3xVNvzzIO9wiTnN
         rCiFQqEcFF8wnARgjkn8m0v+zv+BmSzTpMsn79CNz0Gr5to4IQJBx1ARNu2dIq22Ep52
         HsSTyKJOE89sDZAHIMosKlZPkUJlRzlXppgktj3kFgCSWEDbVLmFsQ0MW5xzg0+gp7Sc
         520w==
X-Gm-Message-State: APjAAAXGwYFeS8gtKHNjGD342kjZn0aZr/DFBh1RBOBp3gg8Y+I7kqHk
	ChS/7hNml5WoLMUOq/nPFcw2xaG/SaesNR6bq10GjuJofgErw9yof0PKSHocbXx11SIKwLGJhPI
	GEyG/jaeaASy4erCTeJHDBY5zOuURyPxbv7Y2jSsXdg4CouDFacP6TeQs29Aecc7OqA==
X-Received: by 2002:a17:902:50ec:: with SMTP id c41mr38605963plj.244.1557215018409;
        Tue, 07 May 2019 00:43:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhDkiaV+nd6LV8pml++vBXMaR5PWBbGQzKst6MyY1jp8hJCoFaTGsG8dC361g1ShR16fcm
X-Received: by 2002:a17:902:50ec:: with SMTP id c41mr38605901plj.244.1557215017557;
        Tue, 07 May 2019 00:43:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557215017; cv=none;
        d=google.com; s=arc-20160816;
        b=0o5GcAwlab5kEF723PaMDjO2xdW9m1KCZPUvMpW4X+zFw0BGEdIggHsMMKYrzFGnpf
         9C0V0ZT1l3qZ5G8hLagtVZB6EYe3zUq987My2HIBLR+pOaZD7oQsH7s2ffEGeqtI3gNG
         s5ctt6uW/Vc43a12UcYbvjSqsOB1Mha6BXAGQ4pLHx7GO6MOg/8P7Jus/mcqOHste6xV
         nu0Z4SBdt9BZs2pZWa4b2ukNQ4Gko5iXgtMU0eumCVphr1Ic2dAC51lafBNq17d68L3o
         C3+w5qksiEPxjJbSCAeL3zpoy7sPj6kh9UD6cRyIy3gybuf87JC/NnPqGdzovXZSMrio
         rpJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7lQZZQUvbrpCglPdrHtpC2hCfoI82JB8YsYbcjRty0c=;
        b=U/XecPG/oiGNsofcUNHp0wOvMFak6rPkDqAcV4M4cNIdDNsNrhkEc2Vr1JaxLGUPbm
         bpFegxPSxcu6KFIJqyE0mLw9tbfl8ZPLrhhIv8gwxlnm7tsWJfkXXyNMkaGVDEI5Gnm2
         CdXgZtW2916mcBRh/3fSyIQdRfaSy28M0B2tD0jG2DfLBGsB2eqOSPqJnFHLKr/C0amh
         ra/ord2+1uszp2oGRdIKdD7gVm7eQ4L2PWbwB3JX95AqI0CxEw0EzL30L0latamfD/gT
         5M6OEVZiAUCBM5bzqbkAqg504Xq0DGg9eEy3S8SteKwq52mbg5jHnwtyvJA+W9NdBHUZ
         hPcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2MVgXQNq;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l34si18523391pgb.574.2019.05.07.00.43.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 00:43:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2MVgXQNq;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B243120989;
	Tue,  7 May 2019 07:43:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557215017;
	bh=MFdZ/EgpyfY0kwMJXZf/qyVBEWcoQTA3dkpraEXQxMo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=2MVgXQNq38tiYvMcy6xa99VJq5jg23ZnqHpAEu4onk5dmCkIOFH9x1lLwuj6OOiJ2
	 sewqDcBYKlyNG65ez+rwXLx6PYzSMdFiHCNVzxgbw++r7k2T6KOScNLiActm7KzU+m
	 xAvWpbDF7QlCx3RNDlId5RsJEh+Nfm1FJlhwRxwU=
Date: Tue, 7 May 2019 09:43:34 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
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
Message-ID: <20190507074334.GB26478@kroah.com>
References: <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507070430.GA24150@kroah.com>
 <20190507072721.GA4364@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507072721.GA4364@sultan-box.localdomain>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 12:27:21AM -0700, Sultan Alsawaf wrote:
> On Tue, May 07, 2019 at 09:04:30AM +0200, Greg Kroah-Hartman wrote:
> > Um, why can't "all" Android devices take the same patches that the Pixel
> > phones are using today?  They should all be in the public android-common
> > kernel repositories that all Android devices should be syncing with on a
> > weekly/monthly basis anyway, right?
> > 
> > thanks,
> > 
> > greg k-h
> 
> Hi Greg,
> 
> I only see PSI present in the android-common kernels for 4.9 and above. The vast
> majority of Android devices do not run a 4.9+ kernel. It seems unreasonable to
> expect OEMs to toil with backporting PSI themselves to get decent memory
> management.

Given that any "new" android device that gets shipped "soon" should be
using 4.9.y or newer, is this a real issue?

And if it is, I'm sure that asking for those patches to be backported to
4.4.y would be just fine, have you asked?

Note that I know of Android Go devices, running 3.18.y kernels, do NOT
use the in-kernel memory killer, but instead use the userspace solution
today.  So trying to get another in-kernel memory killer solution added
anywhere seems quite odd.

thanks,

greg k-h

