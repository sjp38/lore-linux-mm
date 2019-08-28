Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4F3EC41514
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 00:50:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89C82214DA
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 00:50:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="oJhyVsx3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89C82214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A9A26B0006; Tue, 27 Aug 2019 20:50:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15A386B0008; Tue, 27 Aug 2019 20:50:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0487B6B000A; Tue, 27 Aug 2019 20:50:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0059.hostedemail.com [216.40.44.59])
	by kanga.kvack.org (Postfix) with ESMTP id D3D196B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 20:50:03 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8224D87DE
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 00:50:03 +0000 (UTC)
X-FDA: 75870004686.18.mask32_3aa6ceb3ecb20
X-HE-Tag: mask32_3aa6ceb3ecb20
X-Filterd-Recvd-Size: 6745
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 00:50:02 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id r21so949838qke.2
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 17:50:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=Y/1pz5SQ7hg1f+EhmBwif7l68UJ4QOsWMuYQ+9sbJjA=;
        b=oJhyVsx3g1+lIuHDcEbcQe6uPD0tAP9Iojp6qyE+eyrT2sCuXPGqPbQQ1DJNMoU8TL
         hMoy5Hqc5fumIeVfGZdSZhiI19uu9EubQmo7+3Wgvp+4cQViDpR8npuLzId968sjDtgm
         D1xZTVoMTBBfCRT1bgA7kb3Kj0ADMsZA4Nf+Jx1IVzmlWf8Qce8AU9bloYe1o6HAuFCa
         d+xCgZTniXfh25QL//GAv9TpMvYyCgRLkW3Wl0SLpjGPuLlUK3yKZQjavfSgctHovnPy
         +PSetFpFAqALZNCM3tvyP0iL/J6wuhR8Xh7nOyL2gOBPHfPy2NSjKoKym4BSKjWyGQNP
         MPjA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=Y/1pz5SQ7hg1f+EhmBwif7l68UJ4QOsWMuYQ+9sbJjA=;
        b=KbQ4mMAMjmPy+I/FmIT+B6UoR+rXyIktssQuEAhkL/UBpgkcja0ty/U8gLFKmBKQcy
         U0OyyG6n8FtSEPncyspaz5D4Hl3jt3KsymIMNxhHTKZHCXRM6jHOcFhTTDMW2IIMgYKB
         Ug8VS3B5qHrND8feHzWQ3cPLwMJgT1wvEiwt1Wf/clvyYckwbF8t2w9+N14mi8Y3jj/y
         sT5kXyCUke6X+mHwhVgInLSn0ULVZaDnu6M/NJ2HMhBars/O5Q6DJ+v2eMu4ZW0GZHff
         QDVN24T3tEKhwF40NctVMn6cPmZmV/JpmZek8v1GSt5twuHTTy3PrxAEghQA/GqokFoR
         /+ow==
X-Gm-Message-State: APjAAAVoLuxBVrUI0TsqC1I4dcJnVYEPvY7l5IiK3+2LSXDypLnZTLQW
	3KajEI+6wmbRFJMY5tN+Ur82TQ==
X-Google-Smtp-Source: APXvYqyRfkZpX/5JpJzVIVIpQq9tGkKxIffeo4vymy2aUmomnGx2gtzE3vAA3cbhf5eke+EGWDjQMg==
X-Received: by 2002:a37:aa04:: with SMTP id t4mr1443643qke.359.1566953402231;
        Tue, 27 Aug 2019 17:50:02 -0700 (PDT)
Received: from qians-mbp.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id q123sm124429qkf.52.2019.08.27.17.50.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Aug 2019 17:50:01 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
From: Qian Cai <cai@lca.pw>
In-Reply-To: <CAM3twVQEMGWMQEC0dduri0JWt3gH6F2YsSqOmk55VQz+CZDVKg@mail.gmail.com>
Date: Tue, 27 Aug 2019 20:50:00 -0400
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@suse.com>,
 Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>,
 David Rientjes <rientjes@google.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Shakeel Butt <shakeelb@google.com>,
 linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,
 Ivan Delalande <colona@arista.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <79FC3DA1-47F0-4FFC-A92B-9A7EBCE3F15F@lca.pw>
References: <20190826193638.6638-1-echron@arista.com>
 <1566909632.5576.14.camel@lca.pw>
 <CAM3twVQEMGWMQEC0dduri0JWt3gH6F2YsSqOmk55VQz+CZDVKg@mail.gmail.com>
To: Edward Chron <echron@arista.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 27, 2019, at 8:23 PM, Edward Chron <echron@arista.com> wrote:
>=20
>=20
>=20
> On Tue, Aug 27, 2019 at 5:40 AM Qian Cai <cai@lca.pw> wrote:
> On Mon, 2019-08-26 at 12:36 -0700, Edward Chron wrote:
> > This patch series provides code that works as a debug option through
> > debugfs to provide additional controls to limit how much information
> > gets printed when an OOM event occurs and or optionally print =
additional
> > information about slab usage, vmalloc allocations, user process =
memory
> > usage, the number of processes / tasks and some summary information
> > about these tasks (number runable, i/o wait), system information
> > (#CPUs, Kernel Version and other useful state of the system),
> > ARP and ND Cache entry information.
> >=20
> > Linux OOM can optionally provide a lot of information, what's =
missing?
> > =
----------------------------------------------------------------------
> > Linux provides a variety of detailed information when an OOM event =
occurs
> > but has limited options to control how much output is produced. The
> > system related information is produced unconditionally and limited =
per
> > user process information is produced as a default enabled option. =
The
> > per user process information may be disabled.
> >=20
> > Slab usage information was recently added and is output only if slab
> > usage exceeds user memory usage.
> >=20
> > Many OOM events are due to user application memory usage sometimes =
in
> > combination with the use of kernel resource usage that exceeds what =
is
> > expected memory usage. Detailed information about how memory was =
being
> > used when the event occurred may be required to identify the root =
cause
> > of the OOM event.
> >=20
> > However, some environments are very large and printing all of the
> > information about processes, slabs and or vmalloc allocations may
> > not be feasible. For other environments printing as much information
> > about these as possible may be needed to root cause OOM events.
> >=20
>=20
> For more in-depth analysis of OOM events, people could use kdump to =
save a
> vmcore by setting "panic_on_oom", and then use the crash utility to =
analysis the
>  vmcore which contains pretty much all the information you need.
>=20
> Certainly, this is the ideal. A full system dump would give you the =
maximum amount of
> information.=20
>=20
> Unfortunately some environments may lack space to store the dump,

Kdump usually also support dumping to a remote target via NFS, SSH etc=20=


> let alone the time to dump the storage contents and restart the =
system. Some

There is also =E2=80=9Cmakedumpfile=E2=80=9D that could compress and =
filter unwanted memory to reduce
the vmcore size and speed up the dumping process by utilizing =
multi-threads.

> systems can take many minutes to fully boot up, to reset and =
reinitialize all the
> devices. So unfortunately this is not always an option, and we need an =
OOM Report.

I am not sure how the system needs some minutes to reboot would be =
relevant  for the
discussion here. The idea is to save a vmcore and it can be analyzed =
offline even on=20
another system as long as it having a matching =E2=80=9Cvmlinux.".=20



