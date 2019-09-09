Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9807C00307
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 07:17:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB80721920
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 07:17:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p2Q/UjD0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB80721920
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E3276B0007; Mon,  9 Sep 2019 03:17:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 793506B0008; Mon,  9 Sep 2019 03:17:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65AB86B000A; Mon,  9 Sep 2019 03:17:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id 3F85E6B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 03:17:47 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D0374180AD7C3
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:17:46 +0000 (UTC)
X-FDA: 75914527332.03.touch91_43e015a9f343d
X-HE-Tag: touch91_43e015a9f343d
X-Filterd-Recvd-Size: 4816
Received: from mail-lj1-f181.google.com (mail-lj1-f181.google.com [209.85.208.181])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:17:46 +0000 (UTC)
Received: by mail-lj1-f181.google.com with SMTP id a4so11635484ljk.8
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 00:17:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=6WWi6PnkCvJIgohYd6MjFYKiE1xulC2u3LHy1axU0uA=;
        b=p2Q/UjD0V81KtdynBIW9ji2HvZN1FvdFw7M5Eco6yvyiK82LeAnjTGePpEzYOvEco/
         fitPaONnri/GUCGzVD7tp/7hBYc1wOFvCYpuA7Om8X3oC9/xxnYiwQZg+LqD6YSpjJaK
         7Q8n7KVxZwG1sgHqg90zLPw+tqjwLPkLQI/nGOIyyeSpZlSyyzmU3+Wkbfu0omwkqmZW
         M2HxiNCXDRnlO5Ymk8sm9IjZ5HxTIkhnqNTmnzptanTHERdutpX5yNAMXKQ00xv1Htqf
         XLPCWyS0/VXl1JbhX2w9+iHfiYqUmaivoTFNMV92Nm0LDZELFst6ZUm7O9mXwhAc3pJP
         YSgQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=6WWi6PnkCvJIgohYd6MjFYKiE1xulC2u3LHy1axU0uA=;
        b=hn7KMIRVyNdauasdK9UCSnNVoo+5oKz5YOJOtUjeurndokzgaHRu2DZvEFUgKIoYWQ
         UcxOwLYF1h+AAlmsJyxh+vBtsceECiiI/xmY282812che9KiSlsUEgDZdxGb3/o6jmuW
         mlrYuNrmSw0miRrOph/QD726GkNjikIT8ERsgw3T+55Ryyri5hCqPh8YHd//838lFCM+
         PTLmngbxMFcMf6cA+axvTQGdoJkYl3cLmeaXckZ343gq8TFRDVtOwf2GlIUtcwL9/Xgp
         HNjWu3WM50Uo/aTKaAoAlcFCn8TOQHUNrASNKtFG00wsJQM4iHQ5qbrOyLu8VCu/gvVw
         a/9A==
X-Gm-Message-State: APjAAAWCwsMWVEKENP3duKWJEKFL10Vo5FMHeoZwDl7Dn+l/NxV+CghX
	Ab5IFMrfZ46sRLHkcqipOHu8Oh5e5lxoiLQqNbQ=
X-Google-Smtp-Source: APXvYqys8d1JGVfzClrmA4k74GNFOt74+uC21NguH0zWmSd4mmJxYMeNVSZuWEovbUUAevhoKUorz+C1tXbTzE3GaSc=
X-Received: by 2002:a2e:9792:: with SMTP id y18mr1656166lji.168.1568013464829;
 Mon, 09 Sep 2019 00:17:44 -0700 (PDT)
MIME-Version: 1.0
References: <4a56ed8a08a3226500739f0e6961bf8cdcc6d875.camel@dallalba.com.ar>
 <3c906446-d2fd-706b-312f-c08dfaf8f67a@suse.cz> <CAMJBoFNvs2QNAAE=pjdV_RR2mz5Dw2PgP5mXfrwdQX8PmjKxPg@mail.gmail.com>
 <501f9d274cbe1bcf1056bfd06389bd9d4e00de2a.camel@dallalba.com.ar>
In-Reply-To: <501f9d274cbe1bcf1056bfd06389bd9d4e00de2a.camel@dallalba.com.ar>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Mon, 9 Sep 2019 09:17:33 +0200
Message-ID: <CAMJBoFNiu6OMrKvMU1mF-sAX1QmGk9fq4UMsZT7bqM+QOd6cAA@mail.gmail.com>
Subject: Re: CRASH: General protection fault in z3fold
To: =?UTF-8?Q?Agust=C3=ADn_Dall=CA=BCAlba?= <agustin@dallalba.com.ar>
Cc: Vlastimil Babka <vbabka@suse.cz>, Seth Jennings <sjenning@redhat.com>, 
	Dan Streetman <ddstreet@ieee.org>, Linux-MM <linux-mm@kvack.org>, 
	Henry Burns <henrywolfeburns@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 9, 2019 at 2:14 AM Agust=C3=ADn Dall=CA=BCAlba
<agustin@dallalba.com.ar> wrote:
>
> Hello,
>
> > Would you care to test with
> > https://bugzilla.kernel.org/attachment.cgi?id=3D284883 ? That one
> > should
> > fix the problem you're facing.
>
> Thank you, my machine doesn't crash when stressed anymore. :)

That's good to hear :) I hope the fix gets into 5.3.

> However trace 2 (__zswap_pool_release blocked for more than xxxx
> seconds) still happens.

That one is pretty new and seems to have been caused by
d776aaa9895eb6eb770908e899cb7f5bd5025b3c ("mm/z3fold.c: fix race
between migration and destruction").
I'm looking into this now and CC'ing Henry just in case.

~Vitaly

> > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > > TRACE 2: z3fold_zpool_destroy blocked
> > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > >
> > > > INFO: task kworker/2:3:335 blocked for more than 122 seconds.
> > > >       Not tainted 5.3.0-rc7-1-ARCH #1
> > > > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this me=
ssage.
> > > > kworker/2:3     D    0   335      2 0x80004080
> > > > Workqueue: events __zswap_pool_release
> > > > Call Trace:
> > > >  ? __schedule+0x27f/0x6d0
> > > >  schedule+0x43/0xd0
> > > >  z3fold_zpool_destroy+0xe9/0x130
> > > >  ? wait_woken+0x70/0x70
> > > >  zpool_destroy_pool+0x5c/0x90
> > > >  __zswap_pool_release+0x6a/0xb0
> > > >  process_one_work+0x1d1/0x3a0
> > > >  worker_thread+0x4a/0x3d0
> > > >  kthread+0xfb/0x130
> > > >  ? process_one_work+0x3a0/0x3a0
> > > >  ? kthread_park+0x80/0x80
> > > >  ret_from_fork+0x35/0x40
>
> Kind regards.
>

