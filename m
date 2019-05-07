Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FA3EC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:53:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4664B20656
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:53:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4664B20656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D12036B0005; Tue,  7 May 2019 12:53:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC3C46B0008; Tue,  7 May 2019 12:53:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8BEC6B000A; Tue,  7 May 2019 12:53:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90B376B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 12:53:50 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id e5so6005215oih.23
        for <linux-mm@kvack.org>; Tue, 07 May 2019 09:53:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Les20PwGqp+bpDrgm0vkN1QrGvdMFh2R5hcLIBFlpD8=;
        b=reem/DKg9vK5rX+fGskkMAC3a6XwVUqHkvWJpHlq59fdhPumj25x3Q54QBIPruOO24
         30T9Te4b9hh01iau7vzGOUVwnkV+osCrrfbhM8yi2pQXIw2KU6SWRYYiDUXU7fLHVNEJ
         12Kd0s326Ingdr6SezXjktxHrXU2dIljtC8895+VYpQnhPyM4h5J3s7BpTAXK3BbUZ2S
         7/5BiXWoan9CZSrzurqKwBKOpDgEN1Gdq2a1JDNQbWv3Z00V6uj16HJRqzEn5UsQnAzc
         +fRKH+B8wtp1nd9EZ9d7Vshrl4DhLRar7myvL/Q7AuY8QDgLiVLCLzLcoK8FjpV32/a/
         n8Sg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAUIijUQwJI7gD5Vo7C35872hDNvHh8xjpPr16JNWQRq/oOL6WG/
	9VPkALhC2mD1booEG5kMulrHBftS6zR0UlLXYcbgOTERGA+ezWAfWVqniNOV8nCJgCCoqQPwNe6
	wH4y4OzQC4ES4jM6VRT9+za6yyl25CAi1GkqUtLfjdtuo+RWA4gblGoe8ZbytJ5g=
X-Received: by 2002:aca:ba0b:: with SMTP id k11mr818972oif.57.1557248030236;
        Tue, 07 May 2019 09:53:50 -0700 (PDT)
X-Received: by 2002:aca:ba0b:: with SMTP id k11mr818934oif.57.1557248029412;
        Tue, 07 May 2019 09:53:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557248029; cv=none;
        d=google.com; s=arc-20160816;
        b=NToDWCzQJVl3ZXTVt4E0UfI4xc4BdwbEyrWu4ghZ8SFC9JqGXh1Fasx0zZz781nI4R
         /62UqaxR4xdjboJyaUUC+lOe2NTIvMQGciTheL2jx5qMz62TTpdn2y6zzsefihd4toYn
         H6YoeTlloVbkiwWI7FqANsoETqkX+hiUfi5UpNeTL96jj5olodFNbG5ZsIXblfenCVxo
         CRf1lH8fByQwZmUZJuudHhh8XC3Gus52wf0h+iTziEM9h+QFFGh/zJqQyj/8f1AeL7NU
         4hoNBk4oIng4risNfHEMf+NUC8eE4A8p7QL3nBQTICGDCgeu5p5nnuQ3x/NXiP9wP3Vm
         5aAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Les20PwGqp+bpDrgm0vkN1QrGvdMFh2R5hcLIBFlpD8=;
        b=lmhS+vI0/DVtRr7GA5FH+ONbGDOe58lzm8LRnHQoRlTU0s30lmmNt3zzb+dvPT9RGQ
         uFzmE90AMCNqmYFvU9VYhUiuUlfwpsqIc9V2NJCjFnw7/YapPtB4vd9ysC3UZYeW7ijG
         k9xksH7XPN/VlJcniU/GTyesrQxqcUCxd5RYvjlVuat6UMOcdlXCbhp3nps6w3kFMI5K
         bTxQTP1MO65tkqgKz050ar88h26ULUgMGbSkN5bnoGO32S+r5qGW9mit1oRsiuFlOblK
         61l2XoOqvqumjy3XsggwEcqhTbaW7DVs/7d7wFsTd/Cd9xigHY568/pOtwx6t6oCuRJw
         a/Eg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l184sor5606861oia.51.2019.05.07.09.53.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 09:53:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqx8sIfbI/Yd4+hyeoP6avx/z10Ghv7vpqK+WFrxVb8S2qStm0EBvzmx8aLW1Yx8GgtwfEUHAw==
X-Received: by 2002:aca:bf07:: with SMTP id p7mr785143oif.140.1557248029127;
        Tue, 07 May 2019 09:53:49 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id e4sm4538586otr.50.2019.05.07.09.53.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 May 2019 09:53:48 -0700 (PDT)
Date: Tue, 7 May 2019 09:53:44 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Christian Brauner <christian@brauner.io>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	Daniel Colascione <dancol@google.com>,
	Todd Kjos <tkjos@android.com>, Kees Cook <keescook@chromium.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Martijn Coenen <maco@android.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Andy Lutomirski <luto@amacapital.net>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507165344.GA12201@sultan-box.localdomain>
References: <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507070430.GA24150@kroah.com>
 <20190507072721.GA4364@sultan-box.localdomain>
 <20190507074334.GB26478@kroah.com>
 <20190507081236.GA1531@sultan-box.localdomain>
 <20190507105826.oi6vah6x5brt257h@brauner.io>
 <CAJuCfpFeOVzDUq5O_cVgVGjonWDWjVVR192On6eB5gf==_uPKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpFeOVzDUq5O_cVgVGjonWDWjVVR192On6eB5gf==_uPKw@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 09:28:47AM -0700, Suren Baghdasaryan wrote:
> Hi Sultan,
> Looks like you are posting this patch for devices that do not use
> userspace LMKD solution due to them using older kernels or due to
> their vendors sticking to in-kernel solution. If so, I see couple
> logistical issues with this patch. I don't see it being adopted in
> upstream kernel 5.x since it re-implements a deprecated mechanism even
> though vendors still use it. Vendors on the other hand, will not adopt
> it until you show evidence that it works way better than what
> lowmemorykilled driver does now. You would have to provide measurable
> data and explain your tests before they would consider spending time
> on this.

Yes, this is mostly for the devices already produced that are forced to suffer
with poor memory management. I can't even convince vendors to fix kernel
memory leaks, so there's no way I'd be able to convince them of trying this
patch, especially since it seems like you're having trouble convincing vendors
to stop using lowmemorykiller in the first place. And thankfully, convincing
vendors isn't my job :)

> On the implementation side I'm not convinced at all that this would
> work better on all devices and in all circumstances. We had cases when
> a new mechanism would show very good results until one usecase
> completely broke it. Bulk killing of processes that you are doing in
> your patch was a very good example of such a decision which later on
> we had to rethink. That's why baking these policies into kernel is
> very problematic. Another problem I see with the implementation that
> it ties process killing with the reclaim scan depth. It's very similar
> to how vmpressure works and vmpressure in my experience is very
> unpredictable.

Could you elaborate a bit on why bulk killing isn't good?

> > > I linked in the previous message, Google made a rather large set of
> > > modifications to the supposedly-defunct lowmemorykiller.c not one month ago.
> > > What's going on?
> 
> If you look into that commit, it adds ability to report kill stats. If
> that was a change in how that driver works it would be rejected.

Fair, though it was quite strange seeing something that was supposedly totally
abandoned receiving a large chunk of code for reporting stats.

Thanks,
Sultan

