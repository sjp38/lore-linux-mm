Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57A77C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:51:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBD27218AF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:51:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tRWANaip"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBD27218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 544056B0005; Mon,  9 Sep 2019 13:51:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F4966B0006; Mon,  9 Sep 2019 13:51:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40A5B6B0007; Mon,  9 Sep 2019 13:51:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0105.hostedemail.com [216.40.44.105])
	by kanga.kvack.org (Postfix) with ESMTP id 20EB06B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:51:42 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 7D1BE45AB
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:51:41 +0000 (UTC)
X-FDA: 75916124802.10.net27_48e8e6a531530
X-HE-Tag: net27_48e8e6a531530
X-Filterd-Recvd-Size: 5536
Received: from mail-ua1-f68.google.com (mail-ua1-f68.google.com [209.85.222.68])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:51:40 +0000 (UTC)
Received: by mail-ua1-f68.google.com with SMTP id w12so4598052uam.8
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 10:51:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=me3z0sidVzD11gqWBb3sZqCabzQWgLFcPjYSdMTz1yE=;
        b=tRWANaipFkUOW8z5xd1xToYfoXwD9eAg+5+VNRC8Are76zv8tkNu8tL5Q/EGhRvOqN
         BN/L1QOOgmGH2A5GczhDn4Lr+w/y+K0rEQVzvL48hA04B7IaEB5PsS8l/upxWa2VAjwj
         jGkSNkFnJFQqfAVRcibxf8rK1+5tvgDcLWKru5z7M45EEKrui2FXIWMq1rKknnBYSSlp
         p22SKfFRyYM4jqx1AhgWbu0rCF6DX1ozwtb1U0RnhHDmAiADohLqfsf3JrIr6O3MfBuW
         nLNtDYDyzvvsq/G0xyuCLQ2iCKGozUVTDTNFnG5FZLipY6nk7JEDyqp7kqdn9N0HZArA
         cL2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=me3z0sidVzD11gqWBb3sZqCabzQWgLFcPjYSdMTz1yE=;
        b=IEyMKZd2yqLk7LTFJayer4pDxDLaIlJD8r1iaJCV9ChgjH2NcokMcs4T4/JKcD3Ik0
         XCuIAFeXNVLIWxia+DtY3z6PI3xa61DRL5P6JB/QHAYUbflXQleM/03khYo59GZY+eI6
         EwpR+r50OFXE2h1BBQjw9oFibFwRGZYJlCgokAM7mT9RmUaOAmkeGtkzWOt1Z94MLObQ
         WjYcd5bKaOTDRS1ebSUe3OfB/wsqg8Q6fFB1Fvp+G3Cr52aBI38pjN+K+yoziEy2WQKo
         JvOBM6jOjA6nH9nahwzYVo3a2zH91HlWk3F9YCpW/7pbqxI6LH9j+uA+tv8rihneTh+k
         Uycg==
X-Gm-Message-State: APjAAAUWj/X2wWrRirGiEq+X/2oFIlnbU3iiTH96z8fuJEA0qPVw7Dk8
	vzSgeBxmsLtuSOYojT6Mq+A2iVX9GpFf9yQj4DI=
X-Google-Smtp-Source: APXvYqxCCZRcEkDR2vDUeCckegMIQ3Z7XnBIjBVqh0z5ySfnb3/p8JV745nfaDIpM7TMIMW2yBR2/HzaAZPFblU57a8=
X-Received: by 2002:ab0:6585:: with SMTP id v5mr5673536uam.78.1568051500336;
 Mon, 09 Sep 2019 10:51:40 -0700 (PDT)
MIME-Version: 1.0
References: <4a56ed8a08a3226500739f0e6961bf8cdcc6d875.camel@dallalba.com.ar>
 <3c906446-d2fd-706b-312f-c08dfaf8f67a@suse.cz> <CAMJBoFNvs2QNAAE=pjdV_RR2mz5Dw2PgP5mXfrwdQX8PmjKxPg@mail.gmail.com>
 <501f9d274cbe1bcf1056bfd06389bd9d4e00de2a.camel@dallalba.com.ar>
 <CAMJBoFNiu6OMrKvMU1mF-sAX1QmGk9fq4UMsZT7bqM+QOd6cAA@mail.gmail.com> <CAMJBoFNa3w5zHwM8QOUgr-UUctKnXn3b6SzeZ5MB5CXDdS3wwg@mail.gmail.com>
In-Reply-To: <CAMJBoFNa3w5zHwM8QOUgr-UUctKnXn3b6SzeZ5MB5CXDdS3wwg@mail.gmail.com>
From: Henry Burns <henrywolfeburns@gmail.com>
Date: Mon, 9 Sep 2019 13:51:29 -0400
Message-ID: <CADJK47PWCjHHrcrjPcDc3D3Y2HAz5LPoZY+ftK3_T381q6uANQ@mail.gmail.com>
Subject: Re: CRASH: General protection fault in z3fold
To: Vitaly Wool <vitalywool@gmail.com>
Cc: =?UTF-8?Q?Agust=C3=ADn_Dall=CA=BCAlba?= <agustin@dallalba.com.ar>, 
	Vlastimil Babka <vbabka@suse.cz>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002836, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 9, 2019 at 8:44 AM Vitaly Wool <vitalywool@gmail.com> wrote:
>
> On Mon, Sep 9, 2019 at 9:17 AM Vitaly Wool <vitalywool@gmail.com> wrote:
> >
> > On Mon, Sep 9, 2019 at 2:14 AM Agust=C3=ADn Dall=CA=BCAlba
> > <agustin@dallalba.com.ar> wrote:
> > >
> > > Hello,
> > >
> > > > Would you care to test with
> > > > https://bugzilla.kernel.org/attachment.cgi?id=3D284883 ? That one
> > > > should
> > > > fix the problem you're facing.
> > >
> > > Thank you, my machine doesn't crash when stressed anymore. :)
> >
> > That's good to hear :) I hope the fix gets into 5.3.
> >
> > > However trace 2 (__zswap_pool_release blocked for more than xxxx
> > > seconds) still happens.
> >
> > That one is pretty new and seems to have been caused by
> > d776aaa9895eb6eb770908e899cb7f5bd5025b3c ("mm/z3fold.c: fix race
> > between migration and destruction").
> > I'm looking into this now and CC'ing Henry just in case.

Ack. I'll look into the commit to see if I can find anything, but I've
lost access to the testing that I had previously.

>
> Agustin, could you please try reverting that commit? I don't think
> it's working as it should.
>
> >
> > ~Vitaly
> >
> > > > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > > > > TRACE 2: z3fold_zpool_destroy blocked
> > > > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > > > >
> > > > > > INFO: task kworker/2:3:335 blocked for more than 122 seconds.
> > > > > >       Not tainted 5.3.0-rc7-1-ARCH #1
> > > > > > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables thi=
s message.
> > > > > > kworker/2:3     D    0   335      2 0x80004080
> > > > > > Workqueue: events __zswap_pool_release
> > > > > > Call Trace:
> > > > > >  ? __schedule+0x27f/0x6d0
> > > > > >  schedule+0x43/0xd0
> > > > > >  z3fold_zpool_destroy+0xe9/0x130
> > > > > >  ? wait_woken+0x70/0x70
> > > > > >  zpool_destroy_pool+0x5c/0x90
> > > > > >  __zswap_pool_release+0x6a/0xb0
> > > > > >  process_one_work+0x1d1/0x3a0
> > > > > >  worker_thread+0x4a/0x3d0
> > > > > >  kthread+0xfb/0x130
> > > > > >  ? process_one_work+0x3a0/0x3a0
> > > > > >  ? kthread_park+0x80/0x80
> > > > > >  ret_from_fork+0x35/0x40
> > >
> > > Kind regards.
> > >

