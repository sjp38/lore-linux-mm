Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4C15C742A1
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 00:06:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C25721019
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 00:06:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="x6iGf4L5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C25721019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0564B8E0109; Thu, 11 Jul 2019 20:06:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 006D58E00DB; Thu, 11 Jul 2019 20:06:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5E568E0109; Thu, 11 Jul 2019 20:06:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2E1D8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 20:06:01 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id h3so8566947iob.20
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 17:06:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=62nH5oWkGzOQ06SAu95rykYn8etGFCzWFiF4NkIvxBQ=;
        b=joGNzKTuK1vD/dBIbsK9ume18952xFE0eZW/uTdXQ4dRJIlJJqvBSsjBJmT5JimgsL
         Ae7cdYUUKEof/vNsix7aB8qG3oHcrqY6mXSCdEgbDdgsTAbRtDwUlUddYn2TTONWGywz
         sEnLbc28vQeaMlzfxz5vWklCzF5ZmnsUM9sQH3vaOjhlhJziWwx/ADELzIre6WxfOOz+
         /sMTG9gPvEjhkIp5IRyS0gTUXgorx736PQ/wo/KdwosQda4Y1TaIsESUeR9q2yQ3TyuC
         g1OobmU4Tta/8Z3gjLObO1zFFxDxDm7rwxyA48JVI8D4jJ3C2CKzP8XD1+BGylbggnNv
         aFZg==
X-Gm-Message-State: APjAAAUiJScJGQuzzzX/JUaoZ90X8MtmswY94BhXQeCPvORLc0rY9o/F
	6/VOf7GYgObABW4ev056PMsjxn4jJm9jD/ZidxEoLAP/QxV0Lsvf/BeTxD7PzjpKFogR72RsH6W
	JgBPhzyM+TpUYz4wofSze1/k0hhQDLKUxAFhbn7DgBnKw2upbMn5sGE1tsRDG4I8T8Q==
X-Received: by 2002:a5d:8195:: with SMTP id u21mr5243699ion.260.1562889961506;
        Thu, 11 Jul 2019 17:06:01 -0700 (PDT)
X-Received: by 2002:a5d:8195:: with SMTP id u21mr5243657ion.260.1562889960945;
        Thu, 11 Jul 2019 17:06:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562889960; cv=none;
        d=google.com; s=arc-20160816;
        b=pF3Z08Ya9+0G82uIYcz1htpooO0BGaP6q05n7kC3lcdMnzilS8iMRGbYXf3aWBRGR1
         B6NpB0ZuV3SNi0IYRfAZN+yS65PnZN8s2uKCWSwXaOf2EjPIPXW7dl6cVPYWZaPwaKC0
         izqgsRDyXiMaEQ5td9FB/BPN8Omh4mx8Tg4GfZbraZbLGBbxP3Ky4qPYFpRoQgIPOZY+
         u+wLHFfL6S54UVZFkwBaeQfZzwScElAgf96oN+bB4SWEH9I8/bMNRG9pYosxaDS4E9NB
         nacfy6xDx+ca6fCVHElyVFJx2D/5JnZIascL8ch9pMRg0rDg/SQMzBtGYbPueBVxlgnU
         z8gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=62nH5oWkGzOQ06SAu95rykYn8etGFCzWFiF4NkIvxBQ=;
        b=U+l/InEY+uFJMbv8m3HtCCKdRMPx3EhJalPHwo8voaMyO8EGe7UIHLxydyc0Ep4B7A
         GYVK0n5jm2LjnGCpdzSL/gkKKwy1o3HUIQu+rHnVGL/VGJ+M1CurqXYICsqW4x+de8Mh
         PcGRMY/+x1KXArCicVrFDMHSYtYdkSh3OCiD6HsPG1zC52JsiFg05OIw6/5TBpKzYDCN
         6tJWJHwzH4BzAWKLVoWb3iRIVJJEuNCj+4Fxgm0gzFD677dTQ8oQqTepdpmIDCsKnhBR
         KK9c9FvkfNxBRCuHQyv7g9WNDeX+BqfiVXrhDF1pst3hItrOrKT3Cg6qinxD2/3J6rBy
         XQtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=x6iGf4L5;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor15879795jaa.6.2019.07.11.17.06.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 17:06:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=x6iGf4L5;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=62nH5oWkGzOQ06SAu95rykYn8etGFCzWFiF4NkIvxBQ=;
        b=x6iGf4L5yWS+TipgGMZaTstAJSFZHmt4jOCyVxJXA05tn4AvQqO7XQ9jA/D7ymwATG
         PWuN9SzO9zG1m+PEuyKII10uOSL9gg/O57hI2huctP6Og913oIrwhV2UID0IFwMymSEZ
         pSxo0Php2i+/JqZ9P5rh6HvaKN6HtjCSw/3qwxiVDhGnI3DArpoc4m0F9IctT6DD1Di1
         wu4AMH5pCym6cMoCHPWOZAcSY3xU4Avs8wRgU0TwfTmIVmwdhlW+aos08799MA2ewuTT
         YwY5vBW2TokBxQCwis69AwDoXaOek1HHnLZ9u/AICEFSungrKFs4ck9yFBleKW797VV8
         NCMQ==
X-Google-Smtp-Source: APXvYqyEv1kc809mAGLveMhoHxeqWbWWXmWJlBsCCsN3LPsii0kASeeYoYXmRIGy/00rllieyCi4zA==
X-Received: by 2002:a02:5a89:: with SMTP id v131mr8057345jaa.130.1562889960481;
        Thu, 11 Jul 2019 17:06:00 -0700 (PDT)
Received: from ?IPv6:2601:281:200:3b79:24dc:faf7:acdc:387a? ([2601:281:200:3b79:24dc:faf7:acdc:387a])
        by smtp.gmail.com with ESMTPSA id l5sm12084721ioq.83.2019.07.11.17.05.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 17:05:59 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC v2 02/26] mm/asi: Abort isolation on interrupt, exception and context switch
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <1562855138-19507-3-git-send-email-alexandre.chartre@oracle.com>
Date: Thu, 11 Jul 2019 18:05:58 -0600
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com,
 luto@kernel.org, peterz@infradead.org, kvm@vger.kernel.org, x86@kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, konrad.wilk@oracle.com,
 jan.setjeeilers@oracle.com, liran.alon@oracle.com, jwadams@google.com,
 graf@amazon.de, rppt@linux.vnet.ibm.com
Content-Transfer-Encoding: quoted-printable
Message-Id: <B8AF6DF6-8D39-40F6-8624-6F67EDA4E390@amacapital.net>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com> <1562855138-19507-3-git-send-email-alexandre.chartre@oracle.com>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> On Jul 11, 2019, at 8:25 AM, Alexandre Chartre <alexandre.chartre@oracle.c=
om> wrote:
>=20
> Address space isolation should be aborted if there is an interrupt,
> an exception or a context switch. Interrupt/exception handlers and
> context switch code need to run with the full kernel address space.
> Address space isolation is aborted by restoring the original CR3
> value used before entering address space isolation.
>=20

NAK to the entry changes. That code you=E2=80=99re changing is already known=
 to be a bit buggy, and it=E2=80=99s spaghetti. PeterZ and I are gradually w=
orking on fixing some bugs and C-ifying it. ASI can go on top.

