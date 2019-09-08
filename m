Return-Path: <SRS0=7uET=XD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0E71C433EF
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 20:44:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70927206A1
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 20:44:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vd8B1p6v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70927206A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACEB06B0003; Sun,  8 Sep 2019 16:44:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7F646B0006; Sun,  8 Sep 2019 16:44:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9951A6B0007; Sun,  8 Sep 2019 16:44:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0024.hostedemail.com [216.40.44.24])
	by kanga.kvack.org (Postfix) with ESMTP id 78E1B6B0003
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 16:44:47 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3136581F6
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 20:44:47 +0000 (UTC)
X-FDA: 75912932214.15.loaf41_46d6b70a4a93f
X-HE-Tag: loaf41_46d6b70a4a93f
X-Filterd-Recvd-Size: 3764
Received: from mail-lj1-f195.google.com (mail-lj1-f195.google.com [209.85.208.195])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 20:44:46 +0000 (UTC)
Received: by mail-lj1-f195.google.com with SMTP id h2so4192228ljk.1
        for <linux-mm@kvack.org>; Sun, 08 Sep 2019 13:44:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1juM/iMQ96QooUUt3f77LO+IV8A/P1jdeBRL84BbUZU=;
        b=vd8B1p6vAgV+BtAIEf0xv0O+Y4Vm/xhVfRv4TU+EyRD9QBl/R8GaZu4HLoGkEtk5e6
         oHp0+VcNHewZ4JRNXZRhAZEwgrV2uESOmdeVVr3fytPmTmBj9rhHIhz3jtvUAgBH5jjt
         SOImtUAKCMn/kRf5v1wa2/0dld4ICc+ZUEV+fF0u5sX5a+D2yUPsDZZHFXtYwqGguiyr
         UAWhgas7L840y2sXbDf+W2jJwY9UeFTBpR4NA6fWqRODuARyElMF3+m2TfA8jgSnahjW
         dUbg9pmU3ftyKRD6vOcUGDoN+bvtJ2C+b0rujLRZ5YdyNQpbJu5ahSir2rFBEtLpGUqC
         wvtg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=1juM/iMQ96QooUUt3f77LO+IV8A/P1jdeBRL84BbUZU=;
        b=R6f0BjACHtavkLUif3w6MNkb4D8ckiXwbyYok444LH5GI2buWkZieyU58mxZaT7irM
         VS+RHJhiYJ3cJ7h9qIOUvOZWjHywJmnpaN19yI+3277BgN6j29kO8KaMbYZpt+a3TATL
         NwREk3PTd1KGKkzOimV5w/0S09G3spgtktQU3TmNiVTzaECPd6Ko8qo3SZIzYnVKUNmw
         AAxo34jtCC6mkO7+zM1TnlYl09JJrR1Kt2tRT3xjFR63LnqZnkMdGGGn+vOmmP+vCOBd
         JebciHVrqynnbjDdTCjlHPoV45o1rPFC+f/3T2mALdiWjYjzhxKpsfoeVYVXggo+c3+L
         6PNg==
X-Gm-Message-State: APjAAAVd9vGXCHdmqHfZDtnPwQa7ptZE27LWNt523cW4Z7o0r9hIu6iq
	Ne16FJfQL2VvgCXMjb58tOFvdbGRI18D89zHQJ4=
X-Google-Smtp-Source: APXvYqwlv/wBgFFrFzrC4IrBPrmdeLAs0UNxrB4MpaAENwAGnvMZb8JChTPKYfY8wUlnapiIlX1xsEqLNddVi3ZOIMY=
X-Received: by 2002:a2e:90c7:: with SMTP id o7mr13234884ljg.73.1567975485166;
 Sun, 08 Sep 2019 13:44:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190908162919.830388dc7404d1e2c80f4095@gmail.com> <1ed46a95-12bc-d8ee-0770-43057a09f0d9@maciej.szmigiero.name>
In-Reply-To: <1ed46a95-12bc-d8ee-0770-43057a09f0d9@maciej.szmigiero.name>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Sun, 8 Sep 2019 23:44:33 +0300
Message-ID: <CAMJBoFPVmZ=9G0hYz0YYeVH=cMZ=F1urMorvRtm8ZwV7fc4haA@mail.gmail.com>
Subject: Re: [PATCH] z3fold: fix retry mechanism in page reclaim
To: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	=?UTF-8?Q?Agust=C3=ADn_Dall=CA=BCAlba?= <agustin@dallalba.com.ar>, 
	Dan Streetman <ddstreet@ieee.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Markus Linnala <markus.linnala@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000007, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 8, 2019 at 4:56 PM Maciej S. Szmigiero
<mail@maciej.szmigiero.name> wrote:
>
> On 08.09.2019 15:29, Vitaly Wool wrote:
> > z3fold_page_reclaim()'s retry mechanism is broken: on a second
> > iteration it will have zhdr from the first one so that zhdr
> > is no longer in line with struct page. That leads to crashes when
> > the system is stressed.
> >
> > Fix that by moving zhdr assignment up.
> >
> > While at it, protect against using already freed handles by using
> > own local slots structure in z3fold_page_reclaim().
> >
> > Reported-by: Markus Linnala <markus.linnala@gmail.com>
> > Reported-by: Chris Murphy <bugzilla@colorremedies.com>
> > Reported-by: Agustin Dall'Alba <agustin@dallalba.com.ar>
> > Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> > ---
>
> Shouldn't this be CC'ed to stable@ ?

I guess :)

Thanks,
   Vitaly

