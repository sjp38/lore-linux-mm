Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA49BC3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:35:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C1AE2166E
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:35:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="mCW/mV+2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C1AE2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C26D6B0005; Thu, 29 Aug 2019 12:35:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 273EC6B0008; Thu, 29 Aug 2019 12:35:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18A386B000C; Thu, 29 Aug 2019 12:35:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0072.hostedemail.com [216.40.44.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA7E86B0005
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:35:33 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9F4E4180AD7C1
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:35:33 +0000 (UTC)
X-FDA: 75876016146.08.sugar94_4d972d9eceb5d
X-HE-Tag: sugar94_4d972d9eceb5d
X-Filterd-Recvd-Size: 4483
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:35:33 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id j5so8132418ioj.8
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 09:35:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gWrfmUvmczY9Ye+Pr2g0BSFcyfcAgL193u3fjIy1N4Y=;
        b=mCW/mV+2Zet4DnsT0J9ry/QEDNvvfWVPRxF+fU90EoDLur8DOlh0dzN52gBa3d/dsY
         S5OybsNUGwjUhHRpdv/Rk1mN9zWng8ehkcHS2iZLITSjc24tUX906mFaR8L86AH+jncZ
         ia3ueIIt0kz4cMjOnYFL3DnEp7BnEwqR0yvGQjyQBGwTN1NOj0P4U+novHoEUURgEmXd
         1gWv3cvtZEnhok9SYTOVFkDHuX4z7g4w8J2Fel0eCd9RHhO6EMvjXWHOBBkD/myvSby/
         fHQ7b7YnU5skMwBByLvB8XavyuRWZGWFvQMx3yR3ZU9GOFiOz9tbbhWwTJo++cehM7S2
         OBMw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=gWrfmUvmczY9Ye+Pr2g0BSFcyfcAgL193u3fjIy1N4Y=;
        b=iPMTTpVlOiLKRUQTUaGFEODCI1rkuu4qw5aXgF5qO/IP0OGWtSe5W1wWS5/j3QUTv2
         K/uF43oniKZNPy/kjPUqdnrL4xprFJjYTaFVOFgcat5F5kWzG3fLsgKcOjAWduwGtEbd
         hKUrISbWbkGbjtcH4Wcno0iWBHfOVIlMQEmZQIvksPJzldP8lU6SfudVEm9O2pZZeNzq
         2CYGwa5w9ZEtSlGmOZcZ+18XLJeSYPpezxs3EpagjuddIqdaU+T5QdJdEgSPUkIhKedN
         DO0CHWOEdjTcAH+57QxzyLcmfdgPk6Pu9P9EW9ht0LYHFvIcFFgJW5/7+4fFDuVMZLjj
         WRgQ==
X-Gm-Message-State: APjAAAX/jKmAphMdPETNpvO4rvQA8rlPcMWEFNa6LGjwE6scBAsRhyt4
	PmFJ4MaQ5OL80021t2cvor2kZDa8Bx5vRtWV6QZJgg==
X-Google-Smtp-Source: APXvYqyUIN6VsTk2LP68rWn3MkN0M1tAJqRkiSTgbDqKxN8krqoELN2nCECCECeJ3LUjgUO7Tizggbnn64p8Wn6EONQ=
X-Received: by 2002:a5d:8591:: with SMTP id f17mr1731248ioj.5.1567096531180;
 Thu, 29 Aug 2019 09:35:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190826193638.6638-1-echron@arista.com> <20190827071523.GR7538@dhcp22.suse.cz>
 <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
 <20190828065955.GB7386@dhcp22.suse.cz> <CAM3twVR_OLffQ1U-SgQOdHxuByLNL5sicfnObimpGpPQ1tJ0FQ@mail.gmail.com>
 <20190829071105.GQ28313@dhcp22.suse.cz> <297cf049-d92e-f13a-1386-403553d86401@i-love.sakura.ne.jp>
 <20190829115608.GD28313@dhcp22.suse.cz> <CAM3twVSZm69U8Sg+VxQ67DeycHUMC5C3_f2EpND4_LC4UHx7BA@mail.gmail.com>
 <20190829161759.GK28313@dhcp22.suse.cz>
In-Reply-To: <20190829161759.GK28313@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Thu, 29 Aug 2019 09:35:19 -0700
Message-ID: <CAM3twVS+yAyBAzNHs7C8NLVXT6MmSamemXNMpmvmkzkFwu5b_A@mail.gmail.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional information
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 29, 2019 at 9:18 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 29-08-19 08:03:19, Edward Chron wrote:
> > On Thu, Aug 29, 2019 at 4:56 AM Michal Hocko <mhocko@kernel.org> wrote:
> [...]
> > > Or simply provide a hook with the oom_control to be called to report
> > > without replacing the whole oom killer behavior. That is not necessary.
> >
> > For very simple addition, to add a line of output this works.
>
> Why would a hook be limited to small stuff?

It could be larger but the few items we added were just a line or
two of output.

The vmalloc, slabs and processes can print many entries so we
added a control for those.

>
> > It would still be nice to address the fact the existing OOM Report prints
> > all of the user processes or none. It would be nice to add some control
> > for that. That's what we did.
>
> TBH, I am not really convinced partial taks list is desirable nor easy
> to configure. What is the criterion? oom_score (with potentially unstable
> metric)? Rss? Something else?

We used an estimate of the memory footprint of the process:
rss, swap pages and page table pages.

> --
> Michal Hocko
> SUSE Labs

