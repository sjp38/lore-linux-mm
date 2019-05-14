Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24890C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 16:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8C3720850
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 16:44:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8C3720850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 205E16B0007; Tue, 14 May 2019 12:44:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B5B36B0008; Tue, 14 May 2019 12:44:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A57C6B000A; Tue, 14 May 2019 12:44:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C64A96B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 12:44:57 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e20so12262043pfn.8
        for <linux-mm@kvack.org>; Tue, 14 May 2019 09:44:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KLpbl2WvS+msNhS3NmBmekLDDmmP+NNcoapAUKZkpt8=;
        b=Aokdru4QX1jiHzzH803GqxXtre2t9qBz40Cqab3HTFvMGx9lQyPuaP5hr0Y4QmnG3k
         HisvqjsH0GFw9A0ISElOokbRpf2ld3SviS+SY+T3o+ru9MBW3bOPbUlklxMcbztJaKm0
         lpTSVGAg3V2in0migrBDlWNmWkSK6VullC37jjsH3e55HB4SS+Yo68z8vMXQyByYb2j3
         tYl2omLH4aHV3yJHu+R4mTo/lryay3TsU4S33Sz04ncXQOO4e8H0chY36pRA4qcQixqk
         mrhK62LHOrq2M15vWktyqnYqXqkdTyfutauLJhc/oFJv8azq2/92yR9ObSrZTHGVbeCH
         XvGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=/xha=to=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=/XhA=TO=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAW+ZiKCJ+Ol2lJPELwWtz9VYrFElmDdqwR2JgE7QD6nj4yXwJQo
	ai++vkVfwc00kyR/Sbq6DQuVqlgWvmnlAIbx8NIMriPKWxvQqncneSs5XpdQCmN1HgfeO4z90F4
	BemdqrC4r2j/F5mPD+ECvY+Y7yVepJArKTcVlKWS9U3T2Lsv/y1NVCBw9VauFTFY=
X-Received: by 2002:a63:d150:: with SMTP id c16mr38650335pgj.439.1557852297310;
        Tue, 14 May 2019 09:44:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw68aYmIje+UKbD2ZVMJF/fgfHLu4YZ6rsIOspPVDU7rGYCNt+fhlNWWtaU9zqBKCKNX+yI
X-Received: by 2002:a63:d150:: with SMTP id c16mr38650241pgj.439.1557852296136;
        Tue, 14 May 2019 09:44:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557852296; cv=none;
        d=google.com; s=arc-20160816;
        b=f/BVR0E8fP25+iWnWItHK3UeRhQBnV725xq77Toy/9BDvPKauAbSuDO0LRcjHc43j0
         9xzuec9TQOJkj+QLhTgJiBgQhN+91lxG4L5Jf5bx5GvuIGc7UMoaf8A0JhD9/jlUvHzx
         /tCN5DgBY4yfMM6sKne/pIgA26OwMSu3TmT/LUDBflDH7iY6xsDnUkDolAAa3ZZXzUVN
         DDG7UrhkxZz70OCVSm/zPCas30UwYOmdE76sn1qNaaPg2ar5TqWnii43st2DkuiBYM+7
         m2ogU6rjwfUXxHXJQmihuyaOR7acPK5tTTKl2VX8nrfRjyEzC7491Fyz7no/9c4kFhBk
         seEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=KLpbl2WvS+msNhS3NmBmekLDDmmP+NNcoapAUKZkpt8=;
        b=YfaTJJ0ku8/d3V1nOKfg8Dcl/6lcsvONySl2XctmYQGiT0IR8ETQ7sK7uRk/a6gBTw
         jga1uLrn8iezBzeiGvqOtxLR+uAyjeoqUiMpyvCVJNMFyam3uCzULr9cA6nt0ucrSyVH
         roMHAJ6iefP7LeUrLPFzxYSlk+Y5PbQzaWb5xhR9azBaLpqOIceIRMmymtSuGp5Q1mC/
         ZCddJfm1st6MJhR1qLBC5/LwxiOgAyZJP+/PaZ40Y1XaCn+I33sPC9L8JYxzrwsB/ntS
         FMh6QBbaukrDXoycJj3xil8Eh5gdl6Q/EK0GKAL5XWEsuzj3WzMmzc8j7PxOAdgtrXhE
         Yf+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=/xha=to=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=/XhA=TO=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v1si20267860plo.191.2019.05.14.09.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 09:44:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=/xha=to=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=/xha=to=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=/XhA=TO=goodmis.org=rostedt@kernel.org"
Received: from oasis.local.home (50-204-120-225-static.hfc.comcastbusiness.net [50.204.120.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D709B2084F;
	Tue, 14 May 2019 16:44:54 +0000 (UTC)
Date: Tue, 14 May 2019 12:44:53 -0400
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
Message-ID: <20190514124453.6fb1095d@oasis.local.home>
In-Reply-To: <20190513164555.GA30128@sultan-box.localdomain>
References: <20190319221415.baov7x6zoz7hvsno@brauner.io>
	<CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
	<20190319231020.tdcttojlbmx57gke@brauner.io>
	<20190320015249.GC129907@google.com>
	<20190507021622.GA27300@sultan-box.localdomain>
	<20190507153154.GA5750@redhat.com>
	<20190507163520.GA1131@sultan-box.localdomain>
	<20190509155646.GB24526@redhat.com>
	<20190509183353.GA13018@sultan-box.localdomain>
	<20190510151024.GA21421@redhat.com>
	<20190513164555.GA30128@sultan-box.localdomain>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 May 2019 09:45:55 -0700
Sultan Alsawaf <sultan@kerneltoast.com> wrote:

> On Fri, May 10, 2019 at 05:10:25PM +0200, Oleg Nesterov wrote:
> > I am starting to think I am ;)
> > 
> > If you have task1 != task2 this code
> > 
> > 	task_lock(task1);
> > 	task_lock(task2);
> > 
> > should trigger print_deadlock_bug(), task1->alloc_lock and task2->alloc_lock are
> > the "same" lock from lockdep pov, held_lock's will have the same hlock_class().  

OK, this has gotten my attention.

This thread is quite long, do you have a git repo I can look at, and
also where is the first task_lock() taken before the
find_lock_task_mm()?

-- Steve

