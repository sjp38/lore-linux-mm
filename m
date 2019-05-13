Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C703C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 11:49:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A8302085A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 11:49:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M/ooK/+0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A8302085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82CE96B0289; Mon, 13 May 2019 07:49:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DE096B028A; Mon, 13 May 2019 07:49:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A4D06B028B; Mon, 13 May 2019 07:49:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4119D6B0289
	for <linux-mm@kvack.org>; Mon, 13 May 2019 07:49:07 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id q82so4556960oif.7
        for <linux-mm@kvack.org>; Mon, 13 May 2019 04:49:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=4vhQMjONRCKV8VXJkEEAJgFRn01xSw31XodLnAxmh8Q=;
        b=gDFnqDc70skNNaYO8fhLijKLTJUNSfwMzA7hzIUoYFCoiZwBYjh11VnCN5AjQ4ZEsX
         b4pjIGbTWCxOJr9pmFRzolOq9ePDRHFGyw+oXTvzR/qgrfb9I36wPL7CWIuI2+v6/ngo
         fIuk/5DcjCScl4hsf+dGbL+xxgZCDNHDSRCSVimgCkm5+ku/wjoXKXzjB4ZIMIdS0oxN
         x9GHH5kuGegjaDafASZkduAJeYA9fEkef1BZ8pLSMVyTvnRxPgEytED22oPif77Nty4m
         GwDdzl6+LFDBTVd+hhoDr3pC9IEqlYNmcChsduxod5otHZ/tNFnd0OZiBlk6QInKi7ZF
         EbfA==
X-Gm-Message-State: APjAAAWIezyDSmKPGpt1hAK/t69f0j6EGa08dIuX2rJHFQdbcVDwKIo/
	VPpMWdAjPg3JJK/XZUVPbeXA6wiF1WxlOSJCLPjoHFmf9SENg4GISEdop57vsHEWfE6n8sFdvVW
	FkcptKlXB+7QfTFcVZivV5ajsGWvABEiNwFjaRNDVaDW/M4jnb3FsOWpeWr05AB7zXA==
X-Received: by 2002:a05:6830:1112:: with SMTP id w18mr15389122otq.136.1557748146911;
        Mon, 13 May 2019 04:49:06 -0700 (PDT)
X-Received: by 2002:a05:6830:1112:: with SMTP id w18mr15389084otq.136.1557748146073;
        Mon, 13 May 2019 04:49:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557748146; cv=none;
        d=google.com; s=arc-20160816;
        b=jXcNP+RJsiCXs+8nhzLzCFI8rruZAZAxHEmgrPHd/V6+SD/ajXM1W70Ik2q3cpQW2t
         zECg/tMaLl4LLVRvRVZPkBe87sbaUvh9e2weVNPckwYeZBeAgbxFKAoCjFA6YAlfaCoh
         kqv3iTDIN7wCt3UKiwUSFxYmTc4ebTSfCClJuZHyhzaG4Pn1SZJRIq57wCVuOwWjMdYT
         w/INgssbxEMMnQ+P7GTWX+WLkgIQgbpJbfLsRpoHzrOp0rGM2i2bcPm4Axxuqmj0W9ZD
         JKImNsO0iPUehuh+jZSSo3n7594xsiciWVJfrukGHW0tn0cOtnMhzUO5at0BomNvTEAQ
         s+6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=4vhQMjONRCKV8VXJkEEAJgFRn01xSw31XodLnAxmh8Q=;
        b=Md6HWeQC79AhZowHT3IOZifAlxgUPMO7HFR/b5Z/cUxhTNuesvoH6zFJTKD7H5h5nK
         7lxxkBf4l3CxPdHgWzNvDKoOq1UbrgZTl/bqUzfPjrCVPDS8PTJUEgrHCC636sOWmTdv
         84F0ws3o3f6JNtDjVyMD0mVmsK9cH7bj1GivbEcnhjsPLYC/82FJy1XA/UnwHAwrYbYs
         00CfKxRQGj0q3oHDd8OxeXF1XTqIwZbkZ+LQMSqsLBUFzHv/tJgdA9SjhPxHKbl4Y0Tj
         /ocx4DNQaNtWdqlZ26uQewdpEro/aPaA3T/NkjpHEdvrilHuRcYl9TFZ3/5zcw3oU68s
         OPzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="M/ooK/+0";
       spf=pass (google.com: domain of nefelim4ag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nefelim4ag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d23sor3409620oib.4.2019.05.13.04.49.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 04:49:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of nefelim4ag@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="M/ooK/+0";
       spf=pass (google.com: domain of nefelim4ag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nefelim4ag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=4vhQMjONRCKV8VXJkEEAJgFRn01xSw31XodLnAxmh8Q=;
        b=M/ooK/+0myGKsg80MKoPVHSY1U6mU84oLn3Dm2m+awcHyLaYMWbk6whjAvMGRdzauQ
         thj7kpxttDC1sOeZEEpN1+/ApcqIA8Z20uXEiGjY3j7dKzOdeZl/+jssBZxie3VF8MYF
         pouhx9Kjs7fm9WmArIUwn2+xPwN2yE7j5Bd/7UEAq3kubhkmVYjLXr3IX7pop5vk75n+
         H5wuL+KaUDDTc8ib814+0P3LMyVGEIbdIeSxV7WG1BEivtpr8Mu2Mui+RV1PZFiNUzlG
         L3JrYEpiCGo1uAEO0/Zdmkjdk7h9nYJItEbh55F4L2DgQp84IyEdlx8ptjqpK7XQdeAo
         WLVw==
X-Google-Smtp-Source: APXvYqyFcncD0mcOnz2gYfHCxsEgFwXbwF1p3GDLIw/UmxQFIOaK7mjff+Sy9Q/NTprljQ5gR2L67QJnJ5AfelFmEJw=
X-Received: by 2002:aca:f007:: with SMTP id o7mr4454518oih.59.1557748145537;
 Mon, 13 May 2019 04:49:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190510072125.18059-1-oleksandr@redhat.com> <36a71f93-5a32-b154-b01d-2a420bca2679@virtuozzo.com>
 <20190513113314.lddxv4kv5ajjldae@butterfly.localdomain>
In-Reply-To: <20190513113314.lddxv4kv5ajjldae@butterfly.localdomain>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Mon, 13 May 2019 14:48:29 +0300
Message-ID: <CAGqmi744Vef7iF0tuBO3uBtXbNCKYxBV_c-T_Eg3LKPY0rKcWA@mail.gmail.com>
Subject: Re: [PATCH RFC 0/4] mm/ksm: add option to automerge VMAs
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Aaron Tomlin <atomlin@redhat.com>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

=D0=BF=D0=BD, 13 =D0=BC=D0=B0=D1=8F 2019 =D0=B3. =D0=B2 14:33, Oleksandr Na=
talenko <oleksandr@redhat.com>:
>
> Hi.
>
> On Mon, May 13, 2019 at 01:38:43PM +0300, Kirill Tkhai wrote:
> > On 10.05.2019 10:21, Oleksandr Natalenko wrote:
> > > By default, KSM works only on memory that is marked by madvise(). And=
 the
> > > only way to get around that is to either:
> > >
> > >   * use LD_PRELOAD; or
> > >   * patch the kernel with something like UKSM or PKSM.
> > >
> > > Instead, lets implement a so-called "always" mode, which allows marki=
ng
> > > VMAs as mergeable on do_anonymous_page() call automatically.
> > >
> > > The submission introduces a new sysctl knob as well as kernel cmdline=
 option
> > > to control which mode to use. The default mode is to maintain old
> > > (madvise-based) behaviour.
> > >
> > > Due to security concerns, this submission also introduces VM_UNMERGEA=
BLE
> > > vmaflag for apps to explicitly opt out of automerging. Because of add=
ing
> > > a new vmaflag, the whole work is available for 64-bit architectures o=
nly.
> > >> This patchset is based on earlier Timofey's submission [1], but it d=
oesn't
> > > use dedicated kthread to walk through the list of tasks/VMAs.
> > >
> > > For my laptop it saves up to 300 MiB of RAM for usual workflow (brows=
er,
> > > terminal, player, chats etc). Timofey's submission also mentions
> > > containerised workload that benefits from automerging too.
> >
> > This all approach looks complicated for me, and I'm not sure the shown =
profit
> > for desktop is big enough to introduce contradictory vma flags, boot op=
tion
> > and advance page fault handler. Also, 32/64bit defines do not look good=
 for
> > me. I had tried something like this on my laptop some time ago, and
> > the result was bad even in absolute (not in memory percentage) meaning.
> > Isn't LD_PRELOAD trick enough to desktop? Your workload is same all the=
 time,
> > so you may statically insert correct preload to /etc/profile and replac=
e
> > your mmap forever.
> >
> > Speaking about containers, something like this may have a sense, I thin=
k.
> > The probability of that several containers have the same pages are high=
er,
> > than that desktop applications have the same pages; also LD_PRELOAD for
> > containers is not applicable.
>
> Yes, I get your point. But the intention is to avoid another hacky trick
> (LD_PRELOAD), thus *something* should *preferably* be done on the
> kernel level instead.
>
> > But 1)this could be made for trusted containers only (are there similar
> > issues with KSM like with hardware side-channel attacks?!);
>
> Regarding side-channel attacks, yes, I think so. Were those openssl guys
> who complained about it?..
>
> > 2) the most
> > shared data for containers in my experience is file cache, which is not
> > supported by KSM.
> >
> > There are good results by the link [1], but it's difficult to analyze
> > them without knowledge about what happens inside them there.
> >
> > Some of tests have "VM" prefix. What the reason the hypervisor don't ma=
rk
> > their VMAs as mergeable? Can't this be fixed in hypervisor? What is the
> > generic reason that VMAs are not marked in all the tests?
>
> Timofey, could you please address this?

That's just a describe of machine,
only to show difference in deduplication for application in small VM
and real big server
i.e. KSM enabled in VM for containers, not for hypervisor.

> Also, just for the sake of another piece of stats here:
>
> $ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
> 526

IIRC, for calculate saving you must use (pages_shared - pages_sharing)

> > In case of there is a fundamental problem of calling madvise, can't we
> > just implement an easier workaround like a new write-only file:
> >
> > #echo $task > /sys/kernel/mm/ksm/force_madvise
> >
> > which will mark all anon VMAs as mergeable for a passed task's mm?
> >
> > A small userspace daemon may write mergeable tasks there from time to t=
ime.
> >
> > Then we won't need to introduce additional vm flags and to change
> > anon pagefault handler, and the changes will be small and only
> > related to mm/ksm.c, and good enough for both 32 and 64 bit machines.
>
> Yup, looks appealing. Two concerns, though:
>
> 1) we are falling back to scanning through the list of tasks (I guess
> this is what we wanted to avoid, although this time it happens in the
> userspace);
>
> 2) what kinds of opt-out we should maintain? Like, what if force_madvise
> is called, but the task doesn't want some VMAs to be merged? This will
> required new flag anyway, it seems. And should there be another
> write-only file to unmerge everything forcibly for specific task?
>
> Thanks.
>
> P.S. Cc'ing Pavel properly this time.
>
> --
>   Best regards,
>     Oleksandr Natalenko (post-factum)
>     Senior Software Maintenance Engineer



--=20
Have a nice day,
Timofey.

