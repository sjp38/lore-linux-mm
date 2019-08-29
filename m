Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B811EC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 22:42:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77E2E2189D
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 22:42:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="bay27Xp9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77E2E2189D
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 078896B0008; Thu, 29 Aug 2019 18:42:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 028F16B000C; Thu, 29 Aug 2019 18:42:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E817B6B000D; Thu, 29 Aug 2019 18:42:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0146.hostedemail.com [216.40.44.146])
	by kanga.kvack.org (Postfix) with ESMTP id C76396B0008
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 18:42:04 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6883482437C9
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 22:42:04 +0000 (UTC)
X-FDA: 75876939768.11.show12_4c3a7a67f8656
X-HE-Tag: show12_4c3a7a67f8656
X-Filterd-Recvd-Size: 8864
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com [209.85.166.67])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 22:42:03 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id u185so6411184iod.10
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:42:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RTNmKtMIyOKeRFWnzoE7Y4Kbo1rZA/2OLCV7CQcUZaA=;
        b=bay27Xp9dhwp305KeWzqWGBJOrj4JYWn62Pav9CMuasFotcVgHgTvR74QRX8ySXuvu
         nBO/oZf6XuALTkVOCJIkQHZ62D6opYjzsyUFgQ+MenLc0ruQ+KJoyXCcI0/otwTEKcsk
         QIe9tBfHOFauh8gUyAVpZycZFnCyMHlz5TkRkGMZ9ZbNIQPwNKvuZpTlk2MbfYnZIuxU
         jZHU4aLvN1KlQB4oFiVwaepvA3nd6LipqB8s42MhA7SPxpR5gh/TSRC31KYeef/+Gxns
         A7RnJV0CLKIp6SlrqekzUytbP8YtaFg3I5rFB84lTwrOhCxFPs9d8nq273hYpku0suh7
         1pSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=RTNmKtMIyOKeRFWnzoE7Y4Kbo1rZA/2OLCV7CQcUZaA=;
        b=BVOJozVwnEpAa6mmHifVMiY8PRRX70rMpAkq1ZjiRDFaHLu5JDTQ5nWU/yfKrJwWpM
         CoMSg5GbXV4YZ8P62qbg0E3XLC4pBAsomHwg5DJ/DAibS8XdPMFryo2MXmcLOolP0TaC
         wCW22AMMPUOEISg5BPlsBUCuZEgQkG00ooIzvTGcN74pNva2KdJu1YHIwvhdB0HlDq8y
         5ecvU6dHBL05ZEcsa6n7iY/GsP7LT95W+UZKAN2BBhUDWsz2mDDPM5rszDTDok0aELZ4
         0bfo5gHrSTkucZHX8mJX40Z+K//1H8L9PNF88LgNBlGVPn+t+o6vhjCsyqN3BQTNW5s6
         KE4w==
X-Gm-Message-State: APjAAAUamrr4ZAORrtsxl3rvhYDbATT3ZLN/AqT/9UE42hpLl4+6SRzQ
	/Wo8/1YmUr1oIYjB8Zy69DXxVCpAQay1KswNlw+eug==
X-Google-Smtp-Source: APXvYqyNrJWjy3x7Ur1kzMDcBvIhbe7fsLZ3D5JpqvF7N7XmX4yjLG0yJByx9Fibo1qWyc6xU0MlOCGXegbXTCQ8pXU=
X-Received: by 2002:a6b:8b0b:: with SMTP id n11mr8118399iod.101.1567118522911;
 Thu, 29 Aug 2019 15:42:02 -0700 (PDT)
MIME-Version: 1.0
References: <20190826193638.6638-1-echron@arista.com> <20190827071523.GR7538@dhcp22.suse.cz>
 <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
 <20190828065955.GB7386@dhcp22.suse.cz> <CAM3twVR_OLffQ1U-SgQOdHxuByLNL5sicfnObimpGpPQ1tJ0FQ@mail.gmail.com>
 <20190829071105.GQ28313@dhcp22.suse.cz> <297cf049-d92e-f13a-1386-403553d86401@i-love.sakura.ne.jp>
 <20190829115608.GD28313@dhcp22.suse.cz> <CAM3twVSZm69U8Sg+VxQ67DeycHUMC5C3_f2EpND4_LC4UHx7BA@mail.gmail.com>
 <1567093344.5576.23.camel@lca.pw> <CAM3twVSgJdFKbzkg1V+7voFMi-SYQTCz6jCBobLBQ72Cg8k5VQ@mail.gmail.com>
 <1567104241.5576.30.camel@lca.pw>
In-Reply-To: <1567104241.5576.30.camel@lca.pw>
From: Edward Chron <echron@arista.com>
Date: Thu, 29 Aug 2019 15:41:50 -0700
Message-ID: <CAM3twVTojKErZLBj4CmPfQLFNxQjPhQJJnHjkd5i5PTtAyLP4w@mail.gmail.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional information
To: Qian Cai <cai@lca.pw>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
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

On Thu, Aug 29, 2019 at 11:44 AM Qian Cai <cai@lca.pw> wrote:
>
> On Thu, 2019-08-29 at 09:09 -0700, Edward Chron wrote:
>
> > > Feel like you are going in circles to "sell" without any new information. If
> > > you
> > > need to deal with OOM that often, it might also worth working with FB on
> > > oomd.
> > >
> > > https://github.com/facebookincubator/oomd
> > >
> > > It is well-known that kernel OOM could be slow and painful to deal with, so
> > > I
> > > don't buy-in the argument that kernel OOM recover is better/faster than a
> > > kdump
> > > reboot.
> > >
> > > It is not unusual that when the system is triggering a kernel OOM, it is
> > > almost
> > > trashed/dead. Although developers are working hard to improve the recovery
> > > after
> > > OOM, there are still many error-paths that are not going to survive which
> > > would
> > > leak memories, introduce undefined behaviors, corrupt memory etc.
> >
> > But as you have pointed out many people are happy with current OOM processing
> > which is the report and recovery so for those people a kdump reboot is
> > overkill.
> > Making the OOM report at least optionally a bit more informative has value.
> > Also
> > making sure it doesn't produce excessive output is desirable.
> >
> > I do agree for developers having to have all the system state a kdump
> > provides that
> > and as long as you can reproduce the OOM event that works well. But
> > that is not the
> > common case as has already been discussed.
> >
> > Also, OOM events that are due to kernel bugs could leak memory and over time
> > and cause a crash, true. But that is not what we typically see. In
> > fact we've had
> > customers come back and report issues on systems that have been in continuous
> > operation for years. No point in crashing their system. Linux if
> > properly maintained
> > is thankfully quite stable. But OOMs do happen and root causing them to
> > prevent
> > future occurrences is desired.
>
> This is not what I meant. After an OOM event happens, many kernel memory
> allocations could fail. Since very few people are testing those error-paths due
> to allocation failures, it is considered one of those most buggy areas in the
> kernel. Developers have mostly been focus on making sure the kernel OOM should
> not happen in the first place.
>
> I still think the time is better spending on improving things like eBPF, oomd
> and kdump etc to solve your problem, but leave the kernel OOM report code alone.
>

Sure would rather spend my time doing other things.
No argument about that. No one likes OOMs.
If I never see another OOM I'd be quite happy.

But OOM events still happen and an OOM report gets generated.
When it happens it is useful to get information that can help
find the cause of the OOM so it can be fixed and won't happen again.
We get tasked to root cause OOMs even though we'd rather do
other things.

We've added a bit of output to the OOM Report and it has been helpful.
We also reduce our total output by only printing larger entries
with helpful summaries.
We've been using and supporting this code for quite a few releases.
We haven't had problems and we have a lot of systems in use.

Contributing to an open source project like Linux is good.
If the code is not accepted its not the end of the world.
I was told to offer our code upstream and to try to be helpful.

I understand that processing an OOM event can be flakey.
We add a few lines of OOM output but in fact we reduce our total
output because we skip printing smaller entries and print
summaries instead.

So if the volume of the output increases the likelihood of system
failure during an OOM event, then we've actually increased our
reliability. Maybe that is why we haven't had any problems.

As far as switching from generating an OOM report to taking
a dump and restarting the system, the choice is not mine to
decide. Way above my pay grade. When asked, I am
happy to look at a dump but dumps plus restarts for
the systems we work on take too long so I typically don't get
a dump to look at. Have to make due with OOM output and
logs.

Also, and depending on what you work on, you may take
satisfaction that OOM events are far less traumatic with
newer versions of Linux, with our systems. The folks upstream
do really good work, give credit where credit is due.
Maybe tools like KASAN really help, which we also use.

Sure people fix bugs all the time, Linux is huge and super
complicated, but many of the bugs are not very common
and we spend an amazing (to me anyway) amount of time
testing and so when we take OOM events, even multiple
OOM events back to back, the system almost always
recovers and we don't seem to bleed memory. That is
why we systems up for months and even years.

Occasionally we see a watchdog timeout failure and that
can be due to a low memory situation but just FYI a fair
number of those do not involve OOM events so its not
because of issues with OOM code, reporting or otherwise.

Regardless, thank-you for your time and for your comments.
Constructive feedback is useful and certainly appreciated.

By the way we use oomd on some systems. It is helpful and
in my experience it helps to reduce OOM events but sadly
they still occur. For systems where it is not used, again that
is not my choice to make.

Edward Chron
Arista Networks

