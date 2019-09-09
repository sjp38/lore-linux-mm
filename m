Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3243C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90AF2218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:44:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NpwmgZD2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90AF2218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 391F86B0005; Mon,  9 Sep 2019 08:44:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 343016B0006; Mon,  9 Sep 2019 08:44:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2587E6B0007; Mon,  9 Sep 2019 08:44:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0068.hostedemail.com [216.40.44.68])
	by kanga.kvack.org (Postfix) with ESMTP id 03C0A6B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:44:26 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A7074824376B
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:44:26 +0000 (UTC)
X-FDA: 75915350532.21.pigs71_9a054d38155a
X-HE-Tag: pigs71_9a054d38155a
X-Filterd-Recvd-Size: 5155
Received: from mail-lf1-f45.google.com (mail-lf1-f45.google.com [209.85.167.45])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:44:26 +0000 (UTC)
Received: by mail-lf1-f45.google.com with SMTP id j4so10354961lfh.8
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 05:44:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=R6a6MHAAq92PoJ0en/aktkNhLe6tJTuSuyqshtT5WhI=;
        b=NpwmgZD2M3c/pxKxEqH1QmXBfWOTdjE9lexTj5V52T9NIoD+x/zoDewxE1czCXCJqh
         lVpVDJPo1aZC5Lcb4HHDk7noMjy1aj3f5aLhHevPq7R+jeB+KJJAxGnI3ccseFdh+D+t
         5Op6pEWRs++2sfymeg4aeglGKUJYClyWknuS2WktjgrYTf0d8pYtA03dfEaGWDrSQl+8
         z+z7sgV8oiRUCle2dFZgMSxX2RtlAVRAJs3vLCKiAqgyH4k4+pgyXwccOmOLuDspQ+EN
         YS5AcJlbp7/2RFqz2GVDd3Q1nuY5Z65Mdx2qTi6ZIII1cXlZbEFAkTw5n1yOjsoDEhkv
         EpaQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=R6a6MHAAq92PoJ0en/aktkNhLe6tJTuSuyqshtT5WhI=;
        b=SF8DPHwHc9Y7oYGaGJ2agkvfEj/RrZCK4Ev4imzcusByWvkc8OqB/rc0HaztJJBGOt
         KIJJihmuqN0qAUINu4O9GJm2/iDwpyLYZsRQpVwoyGdMTI88KzcQEhVNPFFj1Df1Lw1A
         K3Fg0QoGdulDC95DwWm8xd4uW72eSuGu853n6vIB48K2eI+XOJx2dRpaeWGQJ5Ye0dUH
         AGuJDQKHVPyAXPcpxev/Fr5APQtZU9fH+NpS8uUM3FK6jYI273Rf36ocscYEVNMRENWv
         VhQWfjyfs7CfJqnZc/UYCvqmWT4TZmyv9pIRigVZirXeLE2nbZg1nGFKsTBkVdbFxsdA
         ncLw==
X-Gm-Message-State: APjAAAVB/p0k7HBxJOUtj/k9J3ha476OCbtBkgVSCd83/8919a9zfhKN
	lAE4fhYUgiDFubHrY0ErqSEeDEUPW3u3gvGJFdA=
X-Google-Smtp-Source: APXvYqzPX6Y/upcHRONQHMlfD5VgVnO/5LGZWe7X/3jl/QAm05A66ox+S9wriOncaMF7TFxXd+tAw17JJvuoMe5PhUw=
X-Received: by 2002:a19:f617:: with SMTP id x23mr15986754lfe.97.1568033064458;
 Mon, 09 Sep 2019 05:44:24 -0700 (PDT)
MIME-Version: 1.0
References: <4a56ed8a08a3226500739f0e6961bf8cdcc6d875.camel@dallalba.com.ar>
 <3c906446-d2fd-706b-312f-c08dfaf8f67a@suse.cz> <CAMJBoFNvs2QNAAE=pjdV_RR2mz5Dw2PgP5mXfrwdQX8PmjKxPg@mail.gmail.com>
 <501f9d274cbe1bcf1056bfd06389bd9d4e00de2a.camel@dallalba.com.ar> <CAMJBoFNiu6OMrKvMU1mF-sAX1QmGk9fq4UMsZT7bqM+QOd6cAA@mail.gmail.com>
In-Reply-To: <CAMJBoFNiu6OMrKvMU1mF-sAX1QmGk9fq4UMsZT7bqM+QOd6cAA@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Mon, 9 Sep 2019 14:44:11 +0200
Message-ID: <CAMJBoFNa3w5zHwM8QOUgr-UUctKnXn3b6SzeZ5MB5CXDdS3wwg@mail.gmail.com>
Subject: Re: CRASH: General protection fault in z3fold
To: =?UTF-8?Q?Agust=C3=ADn_Dall=CA=BCAlba?= <agustin@dallalba.com.ar>
Cc: Vlastimil Babka <vbabka@suse.cz>, Seth Jennings <sjenning@redhat.com>, 
	Dan Streetman <ddstreet@ieee.org>, Linux-MM <linux-mm@kvack.org>, 
	Henry Burns <henrywolfeburns@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 9, 2019 at 9:17 AM Vitaly Wool <vitalywool@gmail.com> wrote:
>
> On Mon, Sep 9, 2019 at 2:14 AM Agust=C3=ADn Dall=CA=BCAlba
> <agustin@dallalba.com.ar> wrote:
> >
> > Hello,
> >
> > > Would you care to test with
> > > https://bugzilla.kernel.org/attachment.cgi?id=3D284883 ? That one
> > > should
> > > fix the problem you're facing.
> >
> > Thank you, my machine doesn't crash when stressed anymore. :)
>
> That's good to hear :) I hope the fix gets into 5.3.
>
> > However trace 2 (__zswap_pool_release blocked for more than xxxx
> > seconds) still happens.
>
> That one is pretty new and seems to have been caused by
> d776aaa9895eb6eb770908e899cb7f5bd5025b3c ("mm/z3fold.c: fix race
> between migration and destruction").
> I'm looking into this now and CC'ing Henry just in case.

Agustin, could you please try reverting that commit? I don't think
it's working as it should.

>
> ~Vitaly
>
> > > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > > > TRACE 2: z3fold_zpool_destroy blocked
> > > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > > >
> > > > > INFO: task kworker/2:3:335 blocked for more than 122 seconds.
> > > > >       Not tainted 5.3.0-rc7-1-ARCH #1
> > > > > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this =
message.
> > > > > kworker/2:3     D    0   335      2 0x80004080
> > > > > Workqueue: events __zswap_pool_release
> > > > > Call Trace:
> > > > >  ? __schedule+0x27f/0x6d0
> > > > >  schedule+0x43/0xd0
> > > > >  z3fold_zpool_destroy+0xe9/0x130
> > > > >  ? wait_woken+0x70/0x70
> > > > >  zpool_destroy_pool+0x5c/0x90
> > > > >  __zswap_pool_release+0x6a/0xb0
> > > > >  process_one_work+0x1d1/0x3a0
> > > > >  worker_thread+0x4a/0x3d0
> > > > >  kthread+0xfb/0x130
> > > > >  ? process_one_work+0x3a0/0x3a0
> > > > >  ? kthread_park+0x80/0x80
> > > > >  ret_from_fork+0x35/0x40
> >
> > Kind regards.
> >

