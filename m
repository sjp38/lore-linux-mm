Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FCE0C3A5A3
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:32:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C0F5217F5
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:32:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="mgFobc5f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C0F5217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFC356B0006; Tue, 27 Aug 2019 21:32:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CACD06B0008; Tue, 27 Aug 2019 21:32:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B74C26B000A; Tue, 27 Aug 2019 21:32:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0076.hostedemail.com [216.40.44.76])
	by kanga.kvack.org (Postfix) with ESMTP id 97FA96B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 21:32:44 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 55AF88771
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:32:44 +0000 (UTC)
X-FDA: 75870112248.17.grass71_8c43bd7792207
X-HE-Tag: grass71_8c43bd7792207
X-Filterd-Recvd-Size: 7606
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:32:43 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id m10so1028544qkk.1
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 18:32:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=bbXKSUkqr29WGeRW9M1BSxucOrrsWqD2ZBb0I9Kry9U=;
        b=mgFobc5ffaUN03Nf/39fKhsoLWWI9H6Xt4t0McOW/dAzuB+ixS6d3dGSjg94jiX8Bw
         tcW5djNkMtyYUVhOW9pc7lLxSiq3GTDkdU5OSezG5T89Tyd1/mndh1MM10QcGMEChxqC
         MPeDgCShAePZt6bRCtexajuvCrIdTNZFGoBUrHJYLx5uyh0DqgCB4pBDqh6z+1vnBoaI
         EsnPW2Rm9E30I0KBdbrNrNK0A6eCYyQ1bG62ghwZy2Cm690fzGIRxPgSWSXShb/0C1ar
         VZlJxoanAm3Lv1KkMVTjTJ0AofCPVCYAKRJgr4oLpKWYjhJ33iQMrj8Gr7yE6RBLv2/J
         4kUw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=bbXKSUkqr29WGeRW9M1BSxucOrrsWqD2ZBb0I9Kry9U=;
        b=NgXeaLE47dny53pDd/O197cJSK/bMseV8TGPgdK/wr/VTMWSGBnqJLNWbKVougHctf
         uwSMuajv1Nm3/9xRzja4ESnxqxs0a7yCQoYLbOP57Ns4tJNbPl4n4sEKK/jtys/VQ9LM
         GSfUL43nv+keYFvwBtAipLmANrjAyShXm8HtfVXoMOhW4emLwqv1zTgOZZzhxzJXuHqt
         kdirHWfcZVQbco7ouQ3yt+aKd6ZTpqo9DQ/hVmjGoc9wouCAH8iUoUeww+FHW4w2J+AJ
         kaakLGz2hOmrI0hy5GYDMdowWq42yJLEONe7k/t2N5eij6JG74aaQQwo0NpvQ+IotPMs
         4nlQ==
X-Gm-Message-State: APjAAAVtCNLSt4ZAFsJaqG+SjXIznofbjeUAvZG7rcbBBjgZDqBSQ51F
	Es3zTc7Xsrdk2KBqiTEp3LzIEg==
X-Google-Smtp-Source: APXvYqxlwQThl2tTPDVmPDHUV1q27S9aiAnORCm17X/zwySX6KTslctYRNy3KcRZIaw4x8ilv0gdJw==
X-Received: by 2002:a05:620a:745:: with SMTP id i5mr1585427qki.39.1566955963157;
        Tue, 27 Aug 2019 18:32:43 -0700 (PDT)
Received: from qians-mbp.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id w24sm456801qtb.35.2019.08.27.18.32.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Aug 2019 18:32:42 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
From: Qian Cai <cai@lca.pw>
In-Reply-To: <CAM3twVSdxJaEpmWXu2m_F1MxFMB58C6=LWWCDYNn5yT3Ns+0sQ@mail.gmail.com>
Date: Tue, 27 Aug 2019 21:32:41 -0400
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
Message-Id: <2A1D8FFC-9E9E-4D86-9A0E-28F8263CC508@lca.pw>
References: <20190826193638.6638-1-echron@arista.com>
 <1566909632.5576.14.camel@lca.pw>
 <CAM3twVQEMGWMQEC0dduri0JWt3gH6F2YsSqOmk55VQz+CZDVKg@mail.gmail.com>
 <79FC3DA1-47F0-4FFC-A92B-9A7EBCE3F15F@lca.pw>
 <CAM3twVSdxJaEpmWXu2m_F1MxFMB58C6=LWWCDYNn5yT3Ns+0sQ@mail.gmail.com>
To: Edward Chron <echron@arista.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 27, 2019, at 9:13 PM, Edward Chron <echron@arista.com> wrote:
>=20
> On Tue, Aug 27, 2019 at 5:50 PM Qian Cai <cai@lca.pw> wrote:
>>=20
>>=20
>>=20
>>> On Aug 27, 2019, at 8:23 PM, Edward Chron <echron@arista.com> wrote:
>>>=20
>>>=20
>>>=20
>>> On Tue, Aug 27, 2019 at 5:40 AM Qian Cai <cai@lca.pw> wrote:
>>> On Mon, 2019-08-26 at 12:36 -0700, Edward Chron wrote:
>>>> This patch series provides code that works as a debug option =
through
>>>> debugfs to provide additional controls to limit how much =
information
>>>> gets printed when an OOM event occurs and or optionally print =
additional
>>>> information about slab usage, vmalloc allocations, user process =
memory
>>>> usage, the number of processes / tasks and some summary information
>>>> about these tasks (number runable, i/o wait), system information
>>>> (#CPUs, Kernel Version and other useful state of the system),
>>>> ARP and ND Cache entry information.
>>>>=20
>>>> Linux OOM can optionally provide a lot of information, what's =
missing?
>>>> =
----------------------------------------------------------------------
>>>> Linux provides a variety of detailed information when an OOM event =
occurs
>>>> but has limited options to control how much output is produced. The
>>>> system related information is produced unconditionally and limited =
per
>>>> user process information is produced as a default enabled option. =
The
>>>> per user process information may be disabled.
>>>>=20
>>>> Slab usage information was recently added and is output only if =
slab
>>>> usage exceeds user memory usage.
>>>>=20
>>>> Many OOM events are due to user application memory usage sometimes =
in
>>>> combination with the use of kernel resource usage that exceeds what =
is
>>>> expected memory usage. Detailed information about how memory was =
being
>>>> used when the event occurred may be required to identify the root =
cause
>>>> of the OOM event.
>>>>=20
>>>> However, some environments are very large and printing all of the
>>>> information about processes, slabs and or vmalloc allocations may
>>>> not be feasible. For other environments printing as much =
information
>>>> about these as possible may be needed to root cause OOM events.
>>>>=20
>>>=20
>>> For more in-depth analysis of OOM events, people could use kdump to =
save a
>>> vmcore by setting "panic_on_oom", and then use the crash utility to =
analysis the
>>> vmcore which contains pretty much all the information you need.
>>>=20
>>> Certainly, this is the ideal. A full system dump would give you the =
maximum amount of
>>> information.
>>>=20
>>> Unfortunately some environments may lack space to store the dump,
>>=20
>> Kdump usually also support dumping to a remote target via NFS, SSH =
etc
>>=20
>>> let alone the time to dump the storage contents and restart the =
system. Some
>>=20
>> There is also =E2=80=9Cmakedumpfile=E2=80=9D that could compress and =
filter unwanted memory to reduce
>> the vmcore size and speed up the dumping process by utilizing =
multi-threads.
>>=20
>>> systems can take many minutes to fully boot up, to reset and =
reinitialize all the
>>> devices. So unfortunately this is not always an option, and we need =
an OOM Report.
>>=20
>> I am not sure how the system needs some minutes to reboot would be =
relevant  for the
>> discussion here. The idea is to save a vmcore and it can be analyzed =
offline even on
>> another system as long as it having a matching =E2=80=9Cvmlinux.".
>>=20
>>=20
>=20
> If selecting a dump on an OOM event doesn't reboot the system and if
> it runs fast enough such
> that it doesn't slow processing enough to appreciably effect the
> system's responsiveness then
> then it would be ideal solution. For some it would be over kill but
> since it is an option it is a
> choice to consider or not.

It sounds like you are looking for more of this,

https://github.com/iovisor/bcc/blob/master/tools/oomkill.py


