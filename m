Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2C4DC10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:19:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3925421874
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:19:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="QmPJbJMB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3925421874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A5686B0003; Wed, 20 Mar 2019 15:19:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 955406B0006; Wed, 20 Mar 2019 15:19:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F6D76B0007; Wed, 20 Mar 2019 15:19:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5056B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:19:38 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n10so3570300qtk.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 12:19:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5mMC0KQfG735C164EcTD+oEbBbnx3mNbSvIp42P1/ag=;
        b=V929tSH7d9OsB/aCq7DDoHrvY/mcI6N5H+L/XDHzVSHq5vmNCv/7Jhww0L4NFx69wK
         X8Tz3foBkhEdwsrBADh4O8RKxIhEP4/Gs6g/PWVbGcYubZgv151yQrAcrSx4vqeP5k69
         Kc7Q5cR4VlwbjFM6K0tTzHPvl906nzgbth5I8BQokd0NHV0UQ2+o8egs8YocDfiKTw1+
         7raGwpNj2WKxdcSF5mgqkCt/ag2U5X4GQCfFwd5Cs1SEugOF7QT9+FuHNgRLqJubv3Fx
         d6Pd3x+eQ/+3S94ixpmV92wVzpcuRubeQUZHkGzdH0qZsUT4yRPahDmREP52h5SBCaNZ
         FQdQ==
X-Gm-Message-State: APjAAAXCp283TxE0EGJ4l+AwayN67cawyjJ6/Tqywf4B3BxEFjqvZXiK
	QGof/cCOK1EOLJQpa3GmsWTpCUo+3KXOWy/7RJgeOIQE6swF+wsAP9Rt0NbEgkz0SMSo1x0+SHw
	31SlkkKfcNOSchiIDwLvij4gL6t3ldwdZy7lYMunFt2yd+ohJfvxpqgA5YDI9mI38lw==
X-Received: by 2002:ae9:f509:: with SMTP id o9mr8024603qkg.133.1553109578185;
        Wed, 20 Mar 2019 12:19:38 -0700 (PDT)
X-Received: by 2002:ae9:f509:: with SMTP id o9mr8024569qkg.133.1553109577626;
        Wed, 20 Mar 2019 12:19:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553109577; cv=none;
        d=google.com; s=arc-20160816;
        b=mytA2vi7YzoXclwtY8XQqvuKumwrc5CzHPGN+nxsGoVdjlfW7osfI9Odj7E1Kpxr6s
         kLvk0iIfzWaNlGvzLy5oJNqq9G/H6Ev/JGHArbsW5nuHmQqf318yxUOegPQJlhTh3mNo
         N4kd9rmIco81n7SA0pO1l/K6tqjPJZAYDyl2LsO1NCtAeM1+YM11VQU+KRcCyokIjv/s
         ocG9GtZ7cbVPo07LB/xtdMgZuJQ5OIXxKpxcJrV+qj0jwy6Jgve+hV3KNh9t5y36RhQQ
         o8edT//FjzkTXzyGFfecEe05dNDM2H9TMvXkTWIfIsTgYIPGGC83t9YhW+pLAPrL0vql
         uQPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5mMC0KQfG735C164EcTD+oEbBbnx3mNbSvIp42P1/ag=;
        b=gAxLJS7hRXF3b+4gpRZXdnsezGyYmNMpGKSE0Ot227+RTm0WTacdWkFdd+NxnyKUSO
         aZUpflIHlVpnKDPRYmJrKoPHfOPq62Zw8hvamE+wfOI6EE7FYjgq+ZgzgBbHlbfBKU1v
         rX8nghL4d8q4KKhMvZdMJGRr+gzk065wQqzBIh+ePTp8lkD9/6QphhCdY9+cLuuHKnaT
         v0QVUpTLgN01ANC9zbmQrGiQoBaPHLQCUzy0PtfEmrbFAmtrnryAI5YLjJ14QW9MV4qq
         8yl3b0IXgMOGKbVK0K3Akp77J4z8rjoBQMp3+644P8NqiPIKC7cuZu28YCT6BVVnw9XU
         iB3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=QmPJbJMB;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4sor5254923qtj.18.2019.03.20.12.19.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 12:19:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=QmPJbJMB;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=5mMC0KQfG735C164EcTD+oEbBbnx3mNbSvIp42P1/ag=;
        b=QmPJbJMB9wKLf1bmnt3tiF7HqCc3zU327h3UXi5c8JGotzjL+VOVDTOEXl3wAoaEIu
         9lAq+U7AMe3JsNkD/QoqLqLNVTcrH/nV+0YJxKHOpRootWoI8oATCWHjdDIFomwmlko/
         uW0bKGgZvqQgDsmQl8QAYmYpsrgerWnYApdp8=
X-Google-Smtp-Source: APXvYqyCvIcP3+DKbe38H1Wq95MgCtycxVep/aavFfInOZgeS5CjRORRXHM97tnnLgFhx5cd9IBy/A==
X-Received: by 2002:ac8:3a63:: with SMTP id w90mr7586860qte.233.1553109577350;
        Wed, 20 Mar 2019 12:19:37 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id 33sm1829081qtm.28.2019.03.20.12.19.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 12:19:36 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:19:35 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Christian Brauner <christian@brauner.io>
Cc: Daniel Colascione <dancol@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
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
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>
Subject: Re: pidfd design
Message-ID: <20190320191935.GB76715@google.com>
References: <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io>
 <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org>
 <20190320182649.spryp5uaeiaxijum@brauner.io>
 <CAKOZuevHbQtrq+Nb-jw1L7O72BmAzcXmbUnfnseeXZjX4PE4tg@mail.gmail.com>
 <20190320185156.7bq775vvtsxqlzfn@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320185156.7bq775vvtsxqlzfn@brauner.io>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 07:51:57PM +0100, Christian Brauner wrote:
[snip]
> > > translate_pid() should just return you a pidfd. Having it return a pidfd
> > > and a status fd feels like stuffing too much functionality in there. If
> > > you're fine with it I'll finish prototyping what I had in mind. As I
> > > said in previous mails I'm already working on this.
> > 
> > translate_pid also needs to *accept* pidfds, at least optionally.
> > Unless you have a function from pidfd to pidfd, you race.
> 
> You're misunderstanding. Again, I said in my previous mails it should
> accept pidfds optionally as arguments, yes. But I don't want it to
> return the status fds that you previously wanted pidfd_wait() to return.
> I really want to see Joel's pidfd_wait() patchset and have more people
> review the actual code.

No problem, pidfd_wait is also fine with me and we can change it later to
translate_pid or something else if needed.

Agreed that lets get to some code writing now that (I hope) we are all on the
same page and discuss on actual code.

 - Joel

