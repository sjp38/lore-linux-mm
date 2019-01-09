Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C146FC43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 21:12:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 599FB206B6
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 21:12:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DdDaTqDf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 599FB206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB87F8E009F; Wed,  9 Jan 2019 16:12:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A681C8E0038; Wed,  9 Jan 2019 16:12:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 956F98E009F; Wed,  9 Jan 2019 16:12:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 697FB8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 16:12:31 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id c4so7690200ioh.16
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 13:12:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zq0NOiAht/Wu131V0q+UW8lFyXAWF05ECGwx61ADzNE=;
        b=VSZ8/K8uGNiHh4rrQZfVQNBLGQAXI2lJq96vqL0sazHcMfTyZdkrk/6iB9MgUaVl88
         4VEJDdI98PObnKpi3uRSAoE8usOWr9V3YSdigqKtknOZ2BuJVjnsODB6hXZg6qLw83ew
         jJUsUN4U5pCeAVtnnkLxujRuKZREkTmgByQHB9HzUX/H3qi1/eTmW/O/Z9qjPmNTfEgO
         0tpkAqVoyMpns5CSpbNYxC2RluQmRQkfb9wHFA/au7pX7J64eb7+sZzvr2PVqoCmOX8F
         S1Ee9nNqa9S+jxXoAsreWFHGUq3Aws+ca5jmGsa7LKmra0ni/+cdIUTM5OV3zTVeq44A
         wm0Q==
X-Gm-Message-State: AJcUuke1XIfehgBMcn5myBLVSMFBT8CUtdPwi9u01UTOK3OsQWbhISk/
	flbZ5++cls2/cgqqc23kAL7qlLVDmEHJNOLdmMrrDHaMGpr0q7eLi5LgMi1eXfWXHTuL1wLQJ5b
	aZllITex1uO+QE2er/Hbk4QkIMtuFshe/Eh+H6+52/cOHFVjkdm8jTFaNuwR+OqP/lRurkKwT5a
	5Xl3fDkltt2AgVr5tAJXkTpJc9PPZrUUE3k+/Ac9suKsW5FnmiVVG4o08CtPIFtXnoPt5rJsre8
	oMjLby+JAAwOzzkA3HT8i5sYjc+2quStnIkMEVgrCqZRn9504UNWdJd5qoj/J9bem9gg2bvJXnu
	qZIZ9u520vDPMclM1HCS6VhjJZmbRleSX8oQpcOGBEPUVxT8HriuMg2cbHWZeyXIlpe5fZFDZtu
	r
X-Received: by 2002:a24:5608:: with SMTP id o8mr5145230itb.35.1547068351078;
        Wed, 09 Jan 2019 13:12:31 -0800 (PST)
X-Received: by 2002:a24:5608:: with SMTP id o8mr5145186itb.35.1547068350017;
        Wed, 09 Jan 2019 13:12:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547068349; cv=none;
        d=google.com; s=arc-20160816;
        b=n3bvYHHB2tqOOnZnrRRdCFh1gD9Tqi24STHiysmVilXRk31shq3RXm37Bep5fgqVD9
         ezpOeddG8ZyeVde5ii1TQqgEJr4u57agEIxipL9qT7n7P5caKlGTEQC5lECmXVcoK+92
         iO3gTbFFHVV/uvUZgne9x5ZjKiU2ExHLud5vpafwMGAuZ/bNjIZr+n8JJJ8sg6rIicgF
         Z3Ob8CF5oRtpeTTcYQKBAYw9kFJzOYYnaBTLDqILwr2WN6sVvr+JHd7H4C4CQAqdErVE
         CAGynosIaRhZZx4Wuvpu7D6kVRyKamPMSumblEIUaS+Pg5KvoOJ53MKvFd2HYSE+H4YC
         cvXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zq0NOiAht/Wu131V0q+UW8lFyXAWF05ECGwx61ADzNE=;
        b=wsuejRpKY60zCseUU/y4j5sPmMzBsEEkaL0WKlSJAFxOfOnocEogBBt4mCmvGo/yQq
         3XVzRP2J0/2M02PXifb8nb83G58TO4iiGtyIsrVHcjgF8tpYzelclghrC2QA32PTXJo9
         +4qBKOn8uWncSbcbd0W7l8438yYGUMZFyvvbkkmsRP5VjDkVhCTaBKImS5FiMe12stLM
         EmZf0ssFBGJI/kzde8cvKdQIxrfOMLFh8N6n6H0R2CO07aLsgUnciJZSptq9Cq0N1DMJ
         HPF+vJ6giqJYb6o7AuP7jgDhXvuHxZDACkVEQs5MCGnUptwWsFq6qhOtzUL0ZmvPM9U7
         2izA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DdDaTqDf;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 130sor23734729ita.7.2019.01.09.13.12.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 13:12:29 -0800 (PST)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DdDaTqDf;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zq0NOiAht/Wu131V0q+UW8lFyXAWF05ECGwx61ADzNE=;
        b=DdDaTqDfIou7vT+/3o/IJqlVHivgy534lIpxrubc27DapqWdG2FiwEPV0sVMLpV53Z
         38B4lqHryT23UQR9hj/ppnXPZ+caP0iyZkvt4BO5G83/i3ln1SJIYFEFX363JGd80xr8
         lwSmJUAmpLLDo7NgbEJV6WxvRgO8AMHdXKcj7s1L4uuJx7JU0UXTCG3r54gQFpvZQuuv
         A9jJULYtDlikP8RXbsOboh5Zt4ZyU6xXNt2on6lSM2e1QKiJYvV/ssO73CHd8xzlzDdN
         Q2GNqJ5XG5yJmABulBEPJy6mvWA9ZmU9bx30ipdgYSTjHic8U6ItWzA4wbr+1v/j0R6b
         QkfQ==
X-Google-Smtp-Source: ALg8bN4bnLnUkf8DVHudzDZZde3KNpZLda6wkJnXS4Bo+fsSowmgjSkJU66CsBrRojcBYvwmxWwu0RE23g0bI1eS4b8=
X-Received: by 2002:a24:65c8:: with SMTP id u191mr5490406itb.7.1547068349549;
 Wed, 09 Jan 2019 13:12:29 -0800 (PST)
MIME-Version: 1.0
References: <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com> <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com> <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPCACOhOo4DTCiOam65SiOiudrKpn5vKAL72bV6iGo9vA@mail.gmail.com>
 <CABXGCsMMSMJuURyhBQC3GuZc7m6Wq7FH=8_rpSWHrZT-0dJeGA@mail.gmail.com>
 <e1ced25f-4f35-320b-5208-7e1ca3565a3a@amd.com> <CABXGCsPPjz57=Et-V-_iGyY0GrEwfcK2QcRJcqiujUp90zaz-g@mail.gmail.com>
 <5a53e55f-91cf-759e-b52b-f4681083d639@amd.com>
In-Reply-To: <5a53e55f-91cf-759e-b52b-f4681083d639@amd.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Thu, 10 Jan 2019 02:12:18 +0500
Message-ID:
 <CABXGCsMKMgzQBr4_QchVyc9JaN64cqDEY5dv29oRE5qhkaHH3g@mail.gmail.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
To: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>
Cc: "Wentland, Harry" <Harry.Wentland@amd.com>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109211218.P24Lh7wdhYOpSOqhU7ETh7fdQhYUG1KLKi9cGkBDZLI@z>

On Thu, 10 Jan 2019 at 01:35, Grodzovsky, Andrey
<Andrey.Grodzovsky@amd.com> wrote:
>
> I think the 'verbose' flag causes it do dump so much output, maybe try without it in ALL the commands above.
> Are you are aware of any particular application during which run this happens ?
>

Last logs related to situation when I launch the game "Shadow of the
Tomb Raider" via proton 3.16-16.
Occurs every time when the game menu should appear after game launching.

--
Best Regards,
Mike Gavrilov.

