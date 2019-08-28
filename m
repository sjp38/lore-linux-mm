Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F2EFC3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:13:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B782422DA7
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:13:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="cyI0K9bk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B782422DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 394176B0006; Tue, 27 Aug 2019 21:13:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31D936B0008; Tue, 27 Aug 2019 21:13:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E5616B000A; Tue, 27 Aug 2019 21:13:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0235.hostedemail.com [216.40.44.235])
	by kanga.kvack.org (Postfix) with ESMTP id EA7DC6B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 21:13:34 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 909D681D5
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:13:34 +0000 (UTC)
X-FDA: 75870063948.30.lift01_767ac66e24c21
X-HE-Tag: lift01_767ac66e24c21
X-Filterd-Recvd-Size: 6846
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:13:34 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id o9so2502565iom.3
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 18:13:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=aXhUQnfZQDKleQOklf5FuJsDb1E8hBR8PFQqMhT/jws=;
        b=cyI0K9bkR6g+jAhPEbl6uuV0FKncWBWE6TLnWHYS450ubtH0Xi4xGv/ijkZwhZlcTD
         7TRhHA24RgNvGvbBH3phisksEKudVMv8Y2R/1rLD4+8eXRgPLNV/chNAtgO9wVMeNY67
         HCuZPKR67XKQD3DpZnHBYgFaVwUPOOxB55F2Q3Mzn1mbKGyBBBl4yY57KgPe+MxfdWCL
         xdk9eVK826eiC3SMt16fPjPoYtSiRf1BG1Vg+pE3zvQIpa4NnfHncYWXPVgLHI69j2ML
         KdZOF/sMQ+3IgFKwo5Rf6WoY+0UTqDoCepxBCKJNDYSW1Fe9mVeC8nPMg7QTW3do3sUi
         VgSg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=aXhUQnfZQDKleQOklf5FuJsDb1E8hBR8PFQqMhT/jws=;
        b=KWO+TZr5xTYVrsMQJQglBI7gA4HSpWg2xOdXNBkRsl9FGymcUaEFB7RjYY7HEhqC6x
         +S561NBZii8bt3i4lrH7zn2OAi7rqVmYOX3B/G2JlCpttqPTHemvPvWyv+Ljm6D7YFXv
         MF/YqwQElFvQC4rm1Egu/cIMLnCpBhMKJ4g6WJtQflrc8aO7Lfr99qZO+gvLDnVel841
         uCZs0fLySanu3TCh+jv30umbfWJxDsqo5Ue5vOWx2IT7eVyC+u/O2ToJja7k5BhOb4my
         18jxo+QfpIo1f2evPePWqCOyU5bm/v4rXO8mpZyT8VwZE9htqCC9keiw8dcF5o2Rmp/j
         g69Q==
X-Gm-Message-State: APjAAAV0Y76AWNVodr4sAzu1jLIK6K286lKK5v6AF0CHwV5j+WuWtqF5
	ORMIhFHn6xdhG5TzmpGpZasd4BtIuMFb6v5QYoBVZyfD
X-Google-Smtp-Source: APXvYqy42usK0sA9aVlheDFbqQtf6evzfcN8wANnTZqjyjI9/iPBjceViSHvUS7KuPtSr+9aZicp5tUEp3g73ooJGCE=
X-Received: by 2002:a6b:f803:: with SMTP id o3mr1409378ioh.187.1566954812678;
 Tue, 27 Aug 2019 18:13:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190826193638.6638-1-echron@arista.com> <1566909632.5576.14.camel@lca.pw>
 <CAM3twVQEMGWMQEC0dduri0JWt3gH6F2YsSqOmk55VQz+CZDVKg@mail.gmail.com> <79FC3DA1-47F0-4FFC-A92B-9A7EBCE3F15F@lca.pw>
In-Reply-To: <79FC3DA1-47F0-4FFC-A92B-9A7EBCE3F15F@lca.pw>
From: Edward Chron <echron@arista.com>
Date: Tue, 27 Aug 2019 18:13:20 -0700
Message-ID: <CAM3twVSdxJaEpmWXu2m_F1MxFMB58C6=LWWCDYNn5yT3Ns+0sQ@mail.gmail.com>
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

On Tue, Aug 27, 2019 at 5:50 PM Qian Cai <cai@lca.pw> wrote:
>
>
>
> > On Aug 27, 2019, at 8:23 PM, Edward Chron <echron@arista.com> wrote:
> >
> >
> >
> > On Tue, Aug 27, 2019 at 5:40 AM Qian Cai <cai@lca.pw> wrote:
> > On Mon, 2019-08-26 at 12:36 -0700, Edward Chron wrote:
> > > This patch series provides code that works as a debug option through
> > > debugfs to provide additional controls to limit how much information
> > > gets printed when an OOM event occurs and or optionally print additio=
nal
> > > information about slab usage, vmalloc allocations, user process memor=
y
> > > usage, the number of processes / tasks and some summary information
> > > about these tasks (number runable, i/o wait), system information
> > > (#CPUs, Kernel Version and other useful state of the system),
> > > ARP and ND Cache entry information.
> > >
> > > Linux OOM can optionally provide a lot of information, what's missing=
?
> > > ---------------------------------------------------------------------=
-
> > > Linux provides a variety of detailed information when an OOM event oc=
curs
> > > but has limited options to control how much output is produced. The
> > > system related information is produced unconditionally and limited pe=
r
> > > user process information is produced as a default enabled option. The
> > > per user process information may be disabled.
> > >
> > > Slab usage information was recently added and is output only if slab
> > > usage exceeds user memory usage.
> > >
> > > Many OOM events are due to user application memory usage sometimes in
> > > combination with the use of kernel resource usage that exceeds what i=
s
> > > expected memory usage. Detailed information about how memory was bein=
g
> > > used when the event occurred may be required to identify the root cau=
se
> > > of the OOM event.
> > >
> > > However, some environments are very large and printing all of the
> > > information about processes, slabs and or vmalloc allocations may
> > > not be feasible. For other environments printing as much information
> > > about these as possible may be needed to root cause OOM events.
> > >
> >
> > For more in-depth analysis of OOM events, people could use kdump to sav=
e a
> > vmcore by setting "panic_on_oom", and then use the crash utility to ana=
lysis the
> >  vmcore which contains pretty much all the information you need.
> >
> > Certainly, this is the ideal. A full system dump would give you the max=
imum amount of
> > information.
> >
> > Unfortunately some environments may lack space to store the dump,
>
> Kdump usually also support dumping to a remote target via NFS, SSH etc
>
> > let alone the time to dump the storage contents and restart the system.=
 Some
>
> There is also =E2=80=9Cmakedumpfile=E2=80=9D that could compress and filt=
er unwanted memory to reduce
> the vmcore size and speed up the dumping process by utilizing multi-threa=
ds.
>
> > systems can take many minutes to fully boot up, to reset and reinitiali=
ze all the
> > devices. So unfortunately this is not always an option, and we need an =
OOM Report.
>
> I am not sure how the system needs some minutes to reboot would be releva=
nt  for the
> discussion here. The idea is to save a vmcore and it can be analyzed offl=
ine even on
> another system as long as it having a matching =E2=80=9Cvmlinux.".
>
>

If selecting a dump on an OOM event doesn't reboot the system and if
it runs fast enough such
that it doesn't slow processing enough to appreciably effect the
system's responsiveness then
then it would be ideal solution. For some it would be over kill but
since it is an option it is a
choice to consider or not.

