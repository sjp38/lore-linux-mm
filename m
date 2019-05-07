Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,T_DKIMWL_WL_HIGH,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3087C46460
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:29:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C4132087F
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:29:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="X69pWunF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C4132087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A7A76B0005; Tue,  7 May 2019 13:29:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 358266B0006; Tue,  7 May 2019 13:29:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 246906B0007; Tue,  7 May 2019 13:29:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E05086B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:29:44 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s8so10754193pgk.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:29:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QgG44jb4fJDoD6Rh0WX/xkP1elw2in9+IHLQrR9ghTA=;
        b=UpFVKilG5L7tdchjWcWRBIQ2d4/iYmLl+mpJ1Bvs2YHQi1qTLut7vX3y1JdG1JZ1Wu
         WvL02ygprgOQHeQ25I1+D6DrNjunPHlQhcvPTwA8yERtEn2+ft4517WTd6xwvE4UobgU
         9C2CWWcwl75LLRScd2cIzd2rgMSgHJl9KaeqfgoK+yQKm1aupWEBaNMd97dlmD2/OxMZ
         NhS5o3xTcmHSLE7zQfX+0LieYy3lC2T3NXd04t+miwG5FBT0Xfn/L8KbAkiWSkUG5BVh
         4B/7AGojnFEjH+h7O9JpD34vH1xdXG1IMMWIWvCrHccM/m4CV0bGOBSrIVUT3FjdB4ay
         3Ecg==
X-Gm-Message-State: APjAAAWDpJk2fXdIov1DtyCDepPhO2s8JVL5u+WCpXYM/8o/mWIDUk9u
	eect+8SSs6O0SxmZVSAgxrhs1X56/3rw5/bD/4Y/dllsxY+AeN+7om3PT4rS+uIdO17lYmeeceK
	1zqygy0o7aE0oyL7uSc0oTrR4CqyLWkN2akU4B7/BK16ZKNzDzqN3P6ajwEZmgT1UGg==
X-Received: by 2002:a63:5c4c:: with SMTP id n12mr41098845pgm.111.1557250184452;
        Tue, 07 May 2019 10:29:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzNn3M9n3DHky2e9Yff3Nl3ISwL/vlwC3Bk/to/VZRd8f/qPMrJPK34wQGX7D5Is9+h+zz
X-Received: by 2002:a63:5c4c:: with SMTP id n12mr41098747pgm.111.1557250183668;
        Tue, 07 May 2019 10:29:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557250183; cv=none;
        d=google.com; s=arc-20160816;
        b=lInupMFob0Dei72Wmw9cVaePHCaBsWO02mr/AX4uLVzEO+PUzRf7zMZqvpMm62oiHY
         8OkyWZh6pyUMonfGayycSi+s5gIU0faMUN13JltuE/QbLYaiGUkLFN+LMRswxRyqsLrr
         MEHj1kWduu6qs0igCgKUQ/pDt79i+FR+vbamd6rEeNENg/vXCATlt98RYb0SW5M8QLRL
         cRKI+HONwihpekUsAY+4O3tfX9zHMZjYcJOJ+yvN0HNTftpCtXt/kMHUu61CnFl8PKvl
         6oWY3hshn1EUP++1ZGuFQZxDOX+7yFcDhT90DsjhE6DCnqfjd1e83ad3HgbPutx7j7pp
         v+8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QgG44jb4fJDoD6Rh0WX/xkP1elw2in9+IHLQrR9ghTA=;
        b=uwUuqAaH2uIAPfJzHRkITl/J34C1kVpGmvSQjGLimOXYJARlyL7M7lwzhQaHbI1eBn
         IFRePME0Ba+MOWo097zLrXcbosoNNkvAaA6/JrADbU7TgOKRau7L7Z/zsB/rGAC//2Dj
         MamcOkB2UFx3SlH4w9RK0PmkqpWP+ltTs7Dh41r6gCBWhHGXO5IXKqskOfCkBdogco9a
         h+uhzrCyYO6f0kaYMXmSTH+76pg2tRRhaSBmXuMLzxLs4vU6SRtAJDSjH9gJwKJJiAes
         K4Q9XCaI8leMPis6/7A4IrPwyw/g0qVdct7SysbJfb162yLYZ0PlUSSucCAEh8znME63
         dkeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=X69pWunF;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 141si18390772pgb.178.2019.05.07.10.29.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:29:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=X69pWunF;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CDFC9205ED;
	Tue,  7 May 2019 17:29:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557250183;
	bh=0aJ6ctT9vRN+sTWk16Y0kR/0wZNkZvMg4FJNEQtB+p4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=X69pWunFdt3abRor30eAi6ii8e0h5YWRT265TXQ35VyTi3237oX/jgxrmWxHMDzrn
	 jWcC3oUU67MGkRXnhy+uK/D0yND+RsTKHyAZqgjvh1anuZd8OMCMwHp6Ew+oHmwYRj
	 q6lrXTdH17oLXqhF6mYfNJwdkR7vBAeIWptDiI0o=
Date: Tue, 7 May 2019 19:29:41 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Christian Brauner <christian@brauner.io>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	Daniel Colascione <dancol@google.com>,
	kernel-team <kernel-team@android.com>,
	Todd Kjos <tkjos@android.com>, Kees Cook <keescook@chromium.org>,
	Peter Zijlstra <peterz@infradead.org>,
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
	Martijn Coenen <maco@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507172940.GA6835@kroah.com>
References: <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507070430.GA24150@kroah.com>
 <20190507072721.GA4364@sultan-box.localdomain>
 <20190507074334.GB26478@kroah.com>
 <20190507081236.GA1531@sultan-box.localdomain>
 <20190507105826.oi6vah6x5brt257h@brauner.io>
 <20190507171711.GB12201@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507171711.GB12201@sultan-box.localdomain>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 10:17:11AM -0700, Sultan Alsawaf wrote:
> On Tue, May 07, 2019 at 01:09:21PM +0200, Greg Kroah-Hartman wrote:
> > > It's even more odd that although a userspace solution is touted as the proper
> > > way to go on LKML, almost no Android OEMs are using it, and even in that commit
> > > I linked in the previous message, Google made a rather large set of
> > > modifications to the supposedly-defunct lowmemorykiller.c not one month ago.
> > > What's going on?
> > 
> > "almost no"?  Again, Android Go is doing that, right?
> 
> I'd check for myself, but I can't seem to find kernel source for an Android Go
> device...
> 
> This seems more confusing though. Why would the ultra-low-end devices use LMKD
> while other devices use the broken lowmemorykiller driver?

It's probably because the Android Go devices got a lot more "help" from
people at Google than did the other devices you are looking at.  Also,
despite the older kernel version, they are probably running a newer
version of Android userspace, specially tuned just for lower memory
devices.

So those 3.18.y based Android Go devices are newer than the 4.4.y based
"full Android" devices on the market, and even some 4.9.y based devices.

Yes, it is strange :)

> > > Qualcomm still uses lowmemorykiller.c [1] on the Snapdragon 845.
> > 
> > Qualcomm should never be used as an example of a company that has any
> > idea of what to do in their kernel :)
> 
> Agreed, but nearly all OEMs that use Qualcomm chipsets roll with Qualcomm's
> kernel decisions, so Qualcomm has a bit of influence here.

Yes, because almost no OEM wants to mess with their kernel, they just
take QCOM's kernel and run with it.  But don't take that for some sort
of "best design practice" summary at all.

> > > If PSI were backported to 4.4, or even 3.18, would it really be used?
> > 
> > Why wouldn't it, if it worked properly?
> 
> For the same mysterious reason that Qualcomm and others cling to
> lowmemorykiller, I presume. This is part of what's been confusing me for quite
> some time...

QCOM's 4.4.y based kernel work was done 3-4 years ago, if not older.
They didn't know that this was not the "right way" to do things.  The
Google developers have been working for the past few years to do it
correct, but they can not go back in time to change old repos, sorry.

Now that I understand you just want to work on your local device, that
makes more sense.  But I think you will have a better result trying to
do a 4.4 backport of PSI combined with the userspace stuff, than to try
to worry about your driver in 5.2 or newer.

Or you can forward-port your kernel to 4.9, or better yet, 4.14.  That
would probably be a much better thing to do overall as 4.4 is really old
now.

Good luck!

greg k-h

