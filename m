Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96E5CC3A5A3
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 02:47:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41F6920679
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 02:47:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="ktVMjyQZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41F6920679
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B63746B000A; Tue, 27 Aug 2019 22:47:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B13EC6B000C; Tue, 27 Aug 2019 22:47:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A29C66B000D; Tue, 27 Aug 2019 22:47:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0115.hostedemail.com [216.40.44.115])
	by kanga.kvack.org (Postfix) with ESMTP id 830A26B000A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 22:47:38 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 32239181AC9AE
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 02:47:38 +0000 (UTC)
X-FDA: 75870300996.15.wing85_426eae1408134
X-HE-Tag: wing85_426eae1408134
X-Filterd-Recvd-Size: 10037
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 02:47:36 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id j5so2783481ioj.8
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 19:47:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=GPQRiYVfBOgJGL5IndO4b2Qj9z4y+4Gng0xlroZ7WXU=;
        b=ktVMjyQZSdfg/cVCwKMjKMBjLsOxQQXi65EQ2acPZxravyv+ij+1u/xcAZlJ0RaZyy
         JeojFSnh/VIMFGRAzLeJOmcmqaOiGxcYiHK7CHxtllRYsKitZfxCvlDvA1lE2MLKkSCj
         yY9JZwkUNVswXqaHUOJqF5YcaGKguoRvh/qe98GO8xZjQGY1JOePTPegw//nh7hHKCe7
         yWaHB7W04LuLFfNisJREde7UnT2rlb37/J+Ryy8j14FGJV+3PHQGtkQsHNq+EwxqqESg
         jw7X+QE0LYUZ2BE49cKVQurKoQdsVuA65Gus0FN2X/FH56O2BoM4xSy/n68kZgYFXZjS
         4X3Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=GPQRiYVfBOgJGL5IndO4b2Qj9z4y+4Gng0xlroZ7WXU=;
        b=eaAhZ6o668D4ARxaRRb7tFd/x9D8qBHy/yUn7LAWMrO98ZEBZINMwduNVFvvhoP52f
         Cwi87HuakfQ/SJzUeHJ9hghx54EwMKZSkBz6Y+npubK/wcLiuSsc08VrOffutFdO/2bt
         CpSs+DJZ20EQkeyym6i5lih6CK+e+b+SMYQO2LMkK6ZuN5wBEJe0WXyGP8h2C6s876Zm
         Oh3OdqBZbEIi7+SYr6CCEEU5H0W74b6oKt6pdiAWGNfRAqORat2AOhRnV0VCydcvB4ng
         f9pk28J8RaT8ylD4XPqavZtQ1Qu0UShUrNb0ju3dfY6OaJvWiIHB9A2EHXUM4Nm8x+rc
         7K/w==
X-Gm-Message-State: APjAAAXK8Ubi0FpJuepSR2eaGuAsoBEEvcjedj4zgGOqo2VaOIdVKNlK
	XC0MOSjI2HMyBc6ARc+KqAV6YdVzc0/95SO6GugwKw==
X-Google-Smtp-Source: APXvYqzsTQhkHbzX4LLTUmZifzcHvjYiv+weYlEc6VUaVUp1LlSlif9Nb69UB6AZII9xglbhfqmr4EuFF2Egbwq8vPY=
X-Received: by 2002:a5e:8e0d:: with SMTP id a13mr1880940ion.28.1566960454459;
 Tue, 27 Aug 2019 19:47:34 -0700 (PDT)
MIME-Version: 1.0
References: <20190826193638.6638-1-echron@arista.com> <1566909632.5576.14.camel@lca.pw>
 <CAM3twVQEMGWMQEC0dduri0JWt3gH6F2YsSqOmk55VQz+CZDVKg@mail.gmail.com>
 <79FC3DA1-47F0-4FFC-A92B-9A7EBCE3F15F@lca.pw> <CAM3twVSdxJaEpmWXu2m_F1MxFMB58C6=LWWCDYNn5yT3Ns+0sQ@mail.gmail.com>
 <2A1D8FFC-9E9E-4D86-9A0E-28F8263CC508@lca.pw>
In-Reply-To: <2A1D8FFC-9E9E-4D86-9A0E-28F8263CC508@lca.pw>
From: Edward Chron <echron@arista.com>
Date: Tue, 27 Aug 2019 19:47:22 -0700
Message-ID: <CAM3twVR5TVuuZSLM2qRJYnkCEKVZmA3XDNREaB+wdKH2Ne9vVA@mail.gmail.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional information
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 6:32 PM Qian Cai <cai@lca.pw> wrote:
>
>
>
> > On Aug 27, 2019, at 9:13 PM, Edward Chron <echron@arista.com> wrote:
> >
> > On Tue, Aug 27, 2019 at 5:50 PM Qian Cai <cai@lca.pw> wrote:
> >>
> >>
> >>
> >>> On Aug 27, 2019, at 8:23 PM, Edward Chron <echron@arista.com> wrote:
> >>>
> >>>
> >>>
> >>> On Tue, Aug 27, 2019 at 5:40 AM Qian Cai <cai@lca.pw> wrote:
> >>> On Mon, 2019-08-26 at 12:36 -0700, Edward Chron wrote:
> >>>> This patch series provides code that works as a debug option through
> >>>> debugfs to provide additional controls to limit how much information
> >>>> gets printed when an OOM event occurs and or optionally print additi=
onal
> >>>> information about slab usage, vmalloc allocations, user process memo=
ry
> >>>> usage, the number of processes / tasks and some summary information
> >>>> about these tasks (number runable, i/o wait), system information
> >>>> (#CPUs, Kernel Version and other useful state of the system),
> >>>> ARP and ND Cache entry information.
> >>>>
> >>>> Linux OOM can optionally provide a lot of information, what's missin=
g?
> >>>> --------------------------------------------------------------------=
--
> >>>> Linux provides a variety of detailed information when an OOM event o=
ccurs
> >>>> but has limited options to control how much output is produced. The
> >>>> system related information is produced unconditionally and limited p=
er
> >>>> user process information is produced as a default enabled option. Th=
e
> >>>> per user process information may be disabled.
> >>>>
> >>>> Slab usage information was recently added and is output only if slab
> >>>> usage exceeds user memory usage.
> >>>>
> >>>> Many OOM events are due to user application memory usage sometimes i=
n
> >>>> combination with the use of kernel resource usage that exceeds what =
is
> >>>> expected memory usage. Detailed information about how memory was bei=
ng
> >>>> used when the event occurred may be required to identify the root ca=
use
> >>>> of the OOM event.
> >>>>
> >>>> However, some environments are very large and printing all of the
> >>>> information about processes, slabs and or vmalloc allocations may
> >>>> not be feasible. For other environments printing as much information
> >>>> about these as possible may be needed to root cause OOM events.
> >>>>
> >>>
> >>> For more in-depth analysis of OOM events, people could use kdump to s=
ave a
> >>> vmcore by setting "panic_on_oom", and then use the crash utility to a=
nalysis the
> >>> vmcore which contains pretty much all the information you need.
> >>>
> >>> Certainly, this is the ideal. A full system dump would give you the m=
aximum amount of
> >>> information.
> >>>
> >>> Unfortunately some environments may lack space to store the dump,
> >>
> >> Kdump usually also support dumping to a remote target via NFS, SSH etc
> >>
> >>> let alone the time to dump the storage contents and restart the syste=
m. Some
> >>
> >> There is also =E2=80=9Cmakedumpfile=E2=80=9D that could compress and f=
ilter unwanted memory to reduce
> >> the vmcore size and speed up the dumping process by utilizing multi-th=
reads.
> >>
> >>> systems can take many minutes to fully boot up, to reset and reinitia=
lize all the
> >>> devices. So unfortunately this is not always an option, and we need a=
n OOM Report.
> >>
> >> I am not sure how the system needs some minutes to reboot would be rel=
evant  for the
> >> discussion here. The idea is to save a vmcore and it can be analyzed o=
ffline even on
> >> another system as long as it having a matching =E2=80=9Cvmlinux.".
> >>
> >>
> >
> > If selecting a dump on an OOM event doesn't reboot the system and if
> > it runs fast enough such
> > that it doesn't slow processing enough to appreciably effect the
> > system's responsiveness then
> > then it would be ideal solution. For some it would be over kill but
> > since it is an option it is a
> > choice to consider or not.
>
> It sounds like you are looking for more of this,

If you want to supplement the OOM Report and keep the information together =
than
you could use EBPF to do that. If that really is the preference it
might make sense
to put the entire report as an EBPF script than you can modify the
script however
you choose. That would be very flexible. You can change your
configuration on the
fly. As long as it has access to everything you need it should work.

Michal would know what direction OOM is headed and if he thinks that fits w=
ith
where things are headed.

I'm flexible in he sense that I could change our submission to make
specific updates
to the existing OOM code. We kept it as separate as possible as for
ease of porting.
But if we can build an acceptable case for making updates to the existing O=
OM
Report code that works.

Our current implementation has some knobs to allow some limited scaling tha=
t
has advantages over print rate limiting and it may allow environments
that didn't
want to allow process printing or slab or vmalloc entry allocations
printing to do
so without generating a lot of output.

But the existing code could be modified to do the same thing. Possibly with=
out
having a configuration interface if that is not desirable. It could look at
the number entries to potentially print for example and if the number
is small it
could print them all or scale selection based on a default memory usage. Do=
 you
really care about slab or vmalloc entries using 1 MB or less of memory on a
256 GB system for example? Probably not. Our approach let's you size this
and has a default that may be reasonable for many environments. But it allo=
ws
you to configure things which adds some complexity.

Now you could in theory produce the entire OOM Report plus anything we've
purposed with an EBPF script. Haven't done it but assume it works with 5.3.
Problem with any type of plugin and or configurable option is testing as
Michal mentions and the fact it may or not be present.

For production systems installing and updating EBPF scripts may someday
be very common, but I wonder how data center managers feel about it now?
Developers are very excited about it and it is a very powerful tool but can=
 I
get permission to add or replace an existing EBPF on production systems?
If there is reluctance for security or reliability or any issue than I
would rather
have the code in the kernel so I know it is there and is tested. Just as I =
would
prefer not to have the config options for reasons Michal cites, but
I'll take that
if that is the best I can get.

Will be interested to hear what Michal advises.

>
> https://github.com/iovisor/bcc/blob/master/tools/oomkill.py
>

