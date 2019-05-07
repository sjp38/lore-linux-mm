Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A99AC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:17:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAFDB20656
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:17:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAFDB20656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 697516B0005; Tue,  7 May 2019 13:17:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 647376B0007; Tue,  7 May 2019 13:17:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E8676B0008; Tue,  7 May 2019 13:17:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0AE6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:17:17 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id f92so3786771otb.3
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:17:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=E9wTNkAOK0Q4lAuFt/sfS/LjQKpDg59u0F4E5sd+CsI=;
        b=kbZwc116WyGch6GTckciWkLa9DUMOA9asbgYx0kRhkKIF0iFvX1XU9UwzPID7YC5M4
         ueq7MqoleVAZZ33gi9zZs/SzNE8I4nIF+SCWom8QW7lJULklkpa063uLJ+KkidS3YO0n
         OI3O78TNW1Q0HSOwixR9bW6CWnK9DDKGeuqr7dIiyxORkL7QocJksFRMrnXub8NHSlO1
         dHL0w2/HuSJnTjY00sfxorVrfd8gn6+rddOOWX0cj80JjAKtFsoTbmOPXq65nw4n8SHC
         cMlOGPfEV+jLEF8oj4DHQua5H6z8h92wt67au0ppgdfDYocC8UY/mfVLFa7c76yE7IOA
         LmXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAXAfAzYi4sU7yVwHicVCRE27LqpWvlZtEWYr++EK7LZsRSD44Lp
	dAsDR8v5Pln31CAHq8DfXJLXQaYsKIt7nlreSpIiz18aigGFx695sDYq0E2+ZFmEYiQZXEB68C0
	NJn45QpUP40n8d5w4b6W0m2O9OYWiN6iQt8vkVApWJ13WTGOJhLGybSCAnc6ma+E=
X-Received: by 2002:a9d:4906:: with SMTP id e6mr18283698otf.99.1557249436841;
        Tue, 07 May 2019 10:17:16 -0700 (PDT)
X-Received: by 2002:a9d:4906:: with SMTP id e6mr18283651otf.99.1557249436061;
        Tue, 07 May 2019 10:17:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557249436; cv=none;
        d=google.com; s=arc-20160816;
        b=q2c2LSbjMPNRm8rL33EJCM7l74dtxyZ/UlZ8uWXPsyCkXYeoxzG7hjVHhd3B0E5gzH
         QBZdRoZtPK05WI2jKmB9zzavGHYsbgNFU24SsjGAllyVm927dKXP4SEzs4gyEXIJ+T1e
         HFrTnt7jivUewtEtFcSDevwz+QqWNitvQJyP62Y9MotPqjQoiTrBjmVykg4h6/1l3p80
         oJAr6YVf6oMjpC4BpZMf9pO6aV6RgAc7VI0NDO6jXmCpNOp0mTAueVJ7BT2Gd6v0IP0L
         TfwoYzBf/nUbKD8QTQqDB3Zjl20uivVVriAe+AWhoitrT/mGIVxElcg4Qv2K9ra3x3Vy
         G71w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=E9wTNkAOK0Q4lAuFt/sfS/LjQKpDg59u0F4E5sd+CsI=;
        b=qrZeqtKrcnoPFKwWJVSAqjujFLLw5I0bL4E1Yqz9JZ1NcVlLi3IwtZgIIz5u3St1Qa
         8FGJsQAJLwBAmbmSZJQLOry45jfYQxMkDU8Tbe5Pt5K3CEQHhp77MaiyPzfceyvUsF57
         gcfAtDhfWY+cvT07QcE9ybSh5uPm9GtQQ/034RFdQdImuGWQKUsQid5pdqbuPdIEWD5P
         v4T2yufL0xMMmKG7OvEYMZYY6mvO73L4y6pPfoV3ZzoG+M4j9JkCGW/1CoHTWkjuXLrT
         2jERBOD9Jl3yk2qIBm+Am/A2OHcECuN7QgyPYqCmj1KpmK407/UpIZ/0ZMOejQzNDNUC
         ub4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y11sor6551126otk.27.2019.05.07.10.17.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 10:17:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqx4xD4T9EyjERPdqkpNFarhqKMZJ2bjl+TL0Qi4QVxwmB8ENcE4Li8DoRtFni5wwxEr70A6yA==
X-Received: by 2002:a9d:5882:: with SMTP id x2mr471197otg.49.1557249435730;
        Tue, 07 May 2019 10:17:15 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id y18sm2818116otq.36.2019.05.07.10.17.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 May 2019 10:17:14 -0700 (PDT)
Date: Tue, 7 May 2019 10:17:11 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Christian Brauner <christian@brauner.io>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
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
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507171711.GB12201@sultan-box.localdomain>
References: <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507070430.GA24150@kroah.com>
 <20190507072721.GA4364@sultan-box.localdomain>
 <20190507074334.GB26478@kroah.com>
 <20190507081236.GA1531@sultan-box.localdomain>
 <20190507105826.oi6vah6x5brt257h@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507105826.oi6vah6x5brt257h@brauner.io>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 12:58:27PM +0200, Christian Brauner wrote:
> This is work that is ongoing and requires kernel changes to make it
> feasible. One of the things that I have been working on for quite a
> while is the whole file descriptor for processes thing that is important
> for LMKD (Even though I never thought about this use-case when I started
> pitching this.). Joel and Daniel have joined in and are working on
> making LMKD possible.
> What I find odd is that every couple of weeks different solutions to the
> low memory problem are pitched. There is simple_lkml, there is LMKD, and
> there was a patchset that wanted to speed up memory reclaim at process
> kill-time by adding a new flag to the new pidfd_send_signal() syscall.
> That all seems - though related - rather uncoordinated. Now granted,
> coordinated is usually not how kernel development necessarily works but
> it would probably be good to have some sort of direction and from what I
> have seen LMKD seems to be the most coordinated effort. But that might
> just be my impression.

LMKD is just Android's userspace low-memory-killer daemon. It's been around for
a while.

This patch (simple_lmk) is meant to serve as an immediate solution for the
devices that'll never see a single line of PSI code running on them, which
amounts to... well, most Android devices currently in existence. I'm more of a
cowboy who made this patch after waiting a few years for memory management
improvements on Android that never happened. Though it looks like it's going to
happen soon(ish?) for super new devices that'll have the privilege of shipping
with PSI in use.

On Tue, May 07, 2019 at 01:09:21PM +0200, Greg Kroah-Hartman wrote:
> > It's even more odd that although a userspace solution is touted as the proper
> > way to go on LKML, almost no Android OEMs are using it, and even in that commit
> > I linked in the previous message, Google made a rather large set of
> > modifications to the supposedly-defunct lowmemorykiller.c not one month ago.
> > What's going on?
> 
> "almost no"?  Again, Android Go is doing that, right?

I'd check for myself, but I can't seem to find kernel source for an Android Go
device...

This seems more confusing though. Why would the ultra-low-end devices use LMKD
while other devices use the broken lowmemorykiller driver?

> > Qualcomm still uses lowmemorykiller.c [1] on the Snapdragon 845.
> 
> Qualcomm should never be used as an example of a company that has any
> idea of what to do in their kernel :)

Agreed, but nearly all OEMs that use Qualcomm chipsets roll with Qualcomm's
kernel decisions, so Qualcomm has a bit of influence here.

> > If PSI were backported to 4.4, or even 3.18, would it really be used?
> 
> Why wouldn't it, if it worked properly?

For the same mysterious reason that Qualcomm and others cling to
lowmemorykiller, I presume. This is part of what's been confusing me for quite
some time...

> Please see the work that went into PSI and the patches around it.
> There's also a lwn.net article last week about the further work ongoing
> in this area.  With all of that, you should see how in-kernel memory
> killers are NOT the way to go.
> 
> > Regardless, even if PSI were backported, a full-fledged LMKD using it has yet to
> > be made, so it wouldn't be of much use now.
> 
> "LMKD"?  Again, PSI is in the 4.9.y android-common tree, so the
> userspace side should be in AOSP, right?

LMKD as in Android's low-memory-killer daemon. It is in AOSP, but it looks like
it's still a work in progress.

Thanks,
Sultan

