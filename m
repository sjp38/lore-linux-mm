Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A479CC4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 01:08:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 666FC21670
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 01:08:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b4Zd3zJN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 666FC21670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18C596B0007; Mon,  9 Sep 2019 21:08:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13C6F6B0008; Mon,  9 Sep 2019 21:08:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02C136B000A; Mon,  9 Sep 2019 21:08:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0154.hostedemail.com [216.40.44.154])
	by kanga.kvack.org (Postfix) with ESMTP id D7DC46B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 21:08:26 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8A9768243762
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:08:26 +0000 (UTC)
X-FDA: 75917225412.10.bat27_66bfd51967019
X-HE-Tag: bat27_66bfd51967019
X-Filterd-Recvd-Size: 4471
Received: from mail-vk1-f193.google.com (mail-vk1-f193.google.com [209.85.221.193])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:08:25 +0000 (UTC)
Received: by mail-vk1-f193.google.com with SMTP id s28so1388414vkm.13
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 18:08:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=rxJUTc7qY/ffI91oHTmmGRkLpr7IlNSIAyIGncMhLtY=;
        b=b4Zd3zJNRgJqxlLV0ghWXBlEVhBkhbWRR0JlgRNjzpJ7BEbH4uu2DqI4iCWlyhj7jJ
         kOu47LP3GjrCj+95foAbGiT6oOkPHpR8SguXh6fATVDypPzotczUv1xyb2sBn8Lls5St
         fGiXiUwVRQhOh290qUCUnMWcF4Jo4ateSgRlX1bEPm53tgx5zo5r4hLGpCuISRk51vhh
         QbJkwqyZ09ue1kjT+z92lmqL/veqlcqPaDgfFKJf5eYruVX3Lo+zjuq6YSeFQyRgiIqh
         iTMy+G/lX9vRm46s4T1Tw2Bf+GOTGdviCcgbXJ+gisFxvTrgtsd/UFfhwVnB3wwh39fj
         T5PQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=rxJUTc7qY/ffI91oHTmmGRkLpr7IlNSIAyIGncMhLtY=;
        b=lGRDS3g4nVVTy0hvDEdFizhQ9MlF+GHZvv1M0YKhQmMxcIQ25URc4yL9jD8a7SJqFo
         NnNfPTs1UtP/Q79pJ+lvpuRCjC/adilWodirLZLkU9ag82FWeTrKuItTku3UB9x/Tt3v
         6+3273jaK+uslb7d94qP8yIRyl1zg0T38i5auRxQRZIvmcLh2fx1LFvDumr4fu/Qjy47
         KowaMnkIo4MFa0ZlGV2jivXWGqXI8WW2mbMXRfY0auA24sMgUc/thw9K9AXePlfjUO/e
         ftImtmwW57dvpgqGn3VLecHNCnSwSFPPBpQG3wv4AfoB3h2WaBFjJ69m/GoQ8Ceco5cH
         VQLg==
X-Gm-Message-State: APjAAAUYaKzTs+iQEABovI7Mi5cAIQIgEKL+DhNhGITggYUucx2an50U
	F921r0382lMgnOJQqcUWU77e+8R4dyp5Spm+o2c=
X-Google-Smtp-Source: APXvYqzUTsxXbmdOCSlfLnj3ggqScpxkp9OvJ4SySq1B5JcCZE/xPn4bmj5rq6NbialpyeK50tug4ndHTgTYyivgq3k=
X-Received: by 2002:a1f:294a:: with SMTP id p71mr12904334vkp.74.1568077705433;
 Mon, 09 Sep 2019 18:08:25 -0700 (PDT)
MIME-Version: 1.0
References: <4a56ed8a08a3226500739f0e6961bf8cdcc6d875.camel@dallalba.com.ar>
 <3c906446-d2fd-706b-312f-c08dfaf8f67a@suse.cz> <CAMJBoFNvs2QNAAE=pjdV_RR2mz5Dw2PgP5mXfrwdQX8PmjKxPg@mail.gmail.com>
 <501f9d274cbe1bcf1056bfd06389bd9d4e00de2a.camel@dallalba.com.ar>
 <CAMJBoFNiu6OMrKvMU1mF-sAX1QmGk9fq4UMsZT7bqM+QOd6cAA@mail.gmail.com>
 <CAMJBoFNa3w5zHwM8QOUgr-UUctKnXn3b6SzeZ5MB5CXDdS3wwg@mail.gmail.com> <28453b3deba00d9343fdcbde5bcda00e7615d321.camel@dallalba.com.ar>
In-Reply-To: <28453b3deba00d9343fdcbde5bcda00e7615d321.camel@dallalba.com.ar>
From: Henry Burns <henrywolfeburns@gmail.com>
Date: Mon, 9 Sep 2019 21:08:14 -0400
Message-ID: <CADJK47MDwK4zxRiO0W-K4ZCbcJ=pkUpyn3A9VvYD2GhgFybwtA@mail.gmail.com>
Subject: Re: CRASH: General protection fault in z3fold
To: =?UTF-8?Q?Agust=C3=ADn_Dall=CA=BCAlba?= <agustin@dallalba.com.ar>
Cc: Vitaly Wool <vitalywool@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000750, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 9, 2019 at 6:59 PM Agust=C3=ADn Dall=CA=BCAlba
<agustin@dallalba.com.ar> wrote:
>
> On Mon, 2019-09-09 at 14:44 +0200, Vitaly Wool wrote:
> > On Mon, Sep 9, 2019 at 9:17 AM Vitaly Wool <vitalywool@gmail.com> wrote=
:
> > > On Mon, Sep 9, 2019 at 2:14 AM Agust=C3=ADn Dall=CA=BCAlba <agustin@d=
allalba.com.ar> wrote:
> > > > However trace 2 (__zswap_pool_release blocked for more than xxxx
> > > > seconds) still happens.
> > >
> > > That one is pretty new and seems to have been caused by
> > > d776aaa9895eb6eb770908e899cb7f5bd5025b3c ("mm/z3fold.c: fix race
> > > between migration and destruction").
> > > I'm looking into this now and CC'ing Henry just in case.
> >
> > Agustin, could you please try reverting that commit? I don't think
> > it's working as it should.
> >
> > > ~Vitaly
>
> I reverted the commit and I haven't seen the deadlock happen again.
> Should I be experiencing some side effect of having reverted that?
>
> Thanks,
> Agust=C3=ADn
>
Hi Agustin,

Having reverted the commit you should only experience problems if you
are changing the zswap backend at runtime. There was a race condition
where a migrating page could avoid destruction and eventually crash
the kernel.

Best,
Henry

