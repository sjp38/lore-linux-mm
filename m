Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B693C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 20:09:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C7562087E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 20:09:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C7562087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 748B76B0005; Wed, 15 May 2019 16:09:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D2B76B0006; Wed, 15 May 2019 16:09:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54B9D6B0007; Wed, 15 May 2019 16:09:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7B56B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 16:09:11 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i123so514615pfb.19
        for <linux-mm@kvack.org>; Wed, 15 May 2019 13:09:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=P8Zgf8tm3TK7RkikLtaUsg+oxKsitA1msx4oaFQQtNo=;
        b=tS5Hqz6ZxSjf/rvTFU2a+49qja0giASYVqS/t0J4S8P8Fdx5q9z8r2nfZ8Gu6GEDnb
         7zg/Nzn1sFp4up4jNOLfeGaV/AyEdNdb1K5QxsnujhkmXDzGP+VPLhioFFwiJqu6KH4h
         78N6zcJuQEYJQpZszE50E5WUaVsip2N6BRJ23ZM+3HNYXQjvIDNLUt1Nx7X+/n0Bobal
         NtZqFnhxUkGMtk/hVwlyCgOJFKrDo4CBsqburvspu3yr4E6uKQzqrnPIbcRpr0AANHWY
         B2vwLBXoEDYPxTXfBGPRXAqMqN2hf4gQSgm5ERuOB+N0MKmo+8Agd3eOisFi/gEgBx/I
         +ULQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=ytuu=tp=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=yTUU=TP=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAUENvP4q7LTW69UQ873IuO53WFD+8bssJQ7h7kKqxOhv8D6E5Ol
	aq65BS+6UEI8DCThV27fOYQaOX/psr9kiLOlxm90UVBewrmn7PThCNp8IlBaHm8TPKvuIM+dlIJ
	UborVCx4FdQx6h1DHgqpQrTo4icwjsYgaifIHS1jK4EltTUVoJGzoE5rutHi7njM=
X-Received: by 2002:a17:902:5a47:: with SMTP id f7mr20697018plm.321.1557950950642;
        Wed, 15 May 2019 13:09:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxceQg7YItKxH9lFiK2F32aW2eUHBKnt7GhkOslLU1UaTQZvOb1FbrZ949PXtiWwipFXfqe
X-Received: by 2002:a17:902:5a47:: with SMTP id f7mr20696953plm.321.1557950949692;
        Wed, 15 May 2019 13:09:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557950949; cv=none;
        d=google.com; s=arc-20160816;
        b=rrRhaI6ssYZ7887wKaCTmeLcZz23Hc0hcsrheq7vs0F3YQMSxwdkxNXLf1N++Q9PEh
         M7FDm5IdbSPAamoYHRCzszylRbISQj3bqcNwqjPJbTJaOeB+mSryTq26xrMK9MF9+i3p
         nqbO6P7B/J+V3uEmt0aFocu4FjF7QgbzYaA5Ig32wEmFq550bnI4BmgrqM3LcpbU8ln/
         +l242vySTn22mJu4/kaPeXN4PT8Z2HciuXV6fWQokU58Z696s6gV0DTk7vlb2urLOMWs
         4D/X/vTkldt4ITxkMTDhHjJSIygUfsHr2vz7oSrC7ZBEpmjfNOkhGdnXnMCFx4AibleJ
         YW0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=P8Zgf8tm3TK7RkikLtaUsg+oxKsitA1msx4oaFQQtNo=;
        b=jZ1VPgOiLeK9K/muDb5I2SotM1nmEi4jAOVUt93d4O5lAhe4/MPLWzjnattQGpeoW1
         SGt8LtU9PBcBZd+Rh+F4p8LKnQ0sutZKgbqMmILNxS37DEmDOww6y8lWSo7r9ymf7X/K
         oabT8GwPBXDjXNbgMZCZZz56Af3kGMQgqAGuAUIU2berS5lhQGwbcmCzGW16XQ4P1h3h
         F9Fs8fPcOME88EwzAekBYgo/X6tO4lgaz3oMs/ovheS6kyGjTxn0/87Rcuh6zf36ZTDu
         spbb8x8Kd5uaUWDJVZCvlUm4736FsTRwfz63rfh4rUD33qJVTBSSOyI25QSL39Db7wXI
         loSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=ytuu=tp=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=yTUU=TP=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s36si2723330pga.19.2019.05.15.13.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 13:09:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=ytuu=tp=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=ytuu=tp=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=yTUU=TP=goodmis.org=rostedt@kernel.org"
Received: from oasis.local.home (50-204-120-225-static.hfc.comcastbusiness.net [50.204.120.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5D5382084F;
	Wed, 15 May 2019 20:09:08 +0000 (UTC)
Date: Wed, 15 May 2019 16:09:06 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Christian Brauner
 <christian@brauner.io>, Daniel Colascione <dancol@google.com>, Suren
 Baghdasaryan <surenb@google.com>, Tim Murray <timmurray@google.com>, Michal
 Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Arve =?UTF-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>, Todd Kjos
 <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar
 <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, LKML
 <linux-kernel@vger.kernel.org>, "open list:ANDROID DRIVERS"
 <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, kernel-team
 <kernel-team@android.com>, Andy Lutomirski <luto@amacapital.net>, "Serge E.
 Hallyn" <serge@hallyn.com>, Kees Cook <keescook@chromium.org>, Joel
 Fernandes <joel@joelfernandes.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for
 Android
Message-ID: <20190515160906.4ce25c8e@oasis.local.home>
In-Reply-To: <20190515185257.GC2888@sultan-box.localdomain>
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
	<20190515185257.GC2888@sultan-box.localdomain>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 May 2019 11:52:57 -0700
Sultan Alsawaf <sultan@kerneltoast.com> wrote:

> On Wed, May 15, 2019 at 02:32:48PM -0400, Steven Rostedt wrote:
> > I'm confused why you did this?  
> 
> Oleg said that debug_locks_off() could've been called and thus prevented
> lockdep complaints about simple_lmk from appearing. To eliminate any possibility
> of that, I disabled debug_locks_off().

But I believe that when lockdep discovers an issue, the data from then
on is not reliable. Which is why we turn it off. But just commenting
out the disabling makes lockdep unreliable, and is not a proper way to
test your code.

Yes, it can then miss locking issues after one was discovered. Thus,
you are not properly testing the locking in your code.

-- Steve

