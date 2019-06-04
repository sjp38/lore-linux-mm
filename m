Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74A3DC46470
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:45:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F6F9245BB
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:45:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YbXtk1gZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F6F9245BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1D6E6B0270; Tue,  4 Jun 2019 07:45:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCE006B0271; Tue,  4 Jun 2019 07:45:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE46D6B0272; Tue,  4 Jun 2019 07:45:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7956B6B0270
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 07:45:37 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j26so12238988pgj.6
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 04:45:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ROpXrP+r2OC9uJKtrd7VeU5I2GEkuLFi73TKRyEYr3w=;
        b=NYQYyuSJhKoz2MgiAOb9802w4MKZKUA+o5lhHqPCZNVaYqT0gjhY8tqYNaiQuaPSB3
         qDbcH7/S9r3HuBxCRxENFhex8eXZ8WbbBngu0jqdrulen95pKqBmom7dUM9araOfar3F
         1Wv4HYqv33XHa5VNXct130jZAyE0IC4QWiRJeib98Ghd5Zuh96Sfqc9cfmYK55ZaZuyy
         KljFiKrLePF7ihXW9LML9aVidwgW1SDA633RNEiXPN5UsX+hDxX9hWe6y343IwZefqKo
         T8FU5dLE/QP4jFokPtTgC3w1qRlnAqup7bSAK7mt/+u62NoL/IzikmWzNmTQ3NuDo0nW
         e1RA==
X-Gm-Message-State: APjAAAXdCtWnjdaiAqA4hX0cML3PNKZMdSeSO8gk+efs8jd8+1sgeA65
	qm979qIvqul14DM12BTDFOL+wlAVZPfjLv+0cOI0zDOpKaV8Z3RAint6sT3qt4r2g5WeSM0zJEE
	IxHbqINY2cwFn2HocWZTh2VGm4so59O32e6AToG/lKKG313V8AtC4RytzRDzZEFNRMQ==
X-Received: by 2002:a17:902:848c:: with SMTP id c12mr35492971plo.17.1559648737010;
        Tue, 04 Jun 2019 04:45:37 -0700 (PDT)
X-Received: by 2002:a17:902:848c:: with SMTP id c12mr35492881plo.17.1559648736207;
        Tue, 04 Jun 2019 04:45:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559648736; cv=none;
        d=google.com; s=arc-20160816;
        b=W22DCEWi+OJ9fGXnAiftK6y0yOknKhqI0VeCln3ANYKRZdlYsM/GhvK2D/mSw007xH
         6+qwjIxdIyVzeV/ZZ5F2Eq5QZRtWCsLUDEBI1TmL/9W38dHfPaz8DJhLy+uJ6MJrF5Ik
         UNLsUTugW1ZCMJkRiFYSMpsDa2obe+SrP/Oyo31AV/ca1STiim2DjwbvnzMJnWRBCMbz
         aaKsuEqV2FINYZ41vvRx9+c4XDhybApN5ndnj9xujVyc2g8rrzGwmHSJvi9a0pHeUzca
         q/Vfc1o4lit/Edteagq4MlxduGa30V6MAfjzxRSdG85sKyLpqD3fajPuuMnPUc3T4/x8
         EvBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ROpXrP+r2OC9uJKtrd7VeU5I2GEkuLFi73TKRyEYr3w=;
        b=DuHPq2iJASKYbYi9qmVFlPkDpVIOeidkZY1UNrvObNRO3aOt7S0B2wYFpA8iu0r9gw
         3naTIkB2ftr8X+ibb3KNgd7f6nZLBzSe2YHhkhZJvudmp4J92OiTDLwyM7OXNcxlGJ96
         JiTP1dDAQmLIS9olYK5RH8f2Rlg+VqvifZRXs/lvZvzlum9uFhMVS0H9la7Wp3J1lYEv
         fbCiYRp358QG4de2seuHJImkZFhpzAatLsX5P4g2Npn5SZvsoV4QEW11bMHHnLZ/xjYZ
         dlaT3OGm2S2hLCw+eDo6/aQECEaWpxzFHixZmwIWgAYXOI8yXKj0A5cCpncBGvozmoiu
         ToDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YbXtk1gZ;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ce5sor20185547plb.17.2019.06.04.04.45.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 04:45:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YbXtk1gZ;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ROpXrP+r2OC9uJKtrd7VeU5I2GEkuLFi73TKRyEYr3w=;
        b=YbXtk1gZpPouwSYE2Vhs1oY1Y4f37CPgCl4rhCDKDXOACPNCfLr9np6wKfbnqxvNqK
         net1HG8o5wBQb4vNApxrOerpg8MX7Frcm0nkoJCRedOp4gIlsU8B+szPQLnyAp7uDFz6
         18a5z5D1t2cCXPLwVyjN57+1xoFuuaOeWrZS3QYEL6m6NSRbpHdyTtJVRsjz8hDvO7ay
         x4MfN3T0GXyhVOPDl8Cb4swrSICIbrgdMT9k5w6B73MKVGcGVf0T8Ojj0gm6GQdck4bi
         ehe9TCYVm49T6ewlmRPV9pTGt0imE7M4Hg2EyyudgsziWrwS3zmaj416nN50DFpNVxSV
         8gRg==
X-Google-Smtp-Source: APXvYqw/MEeiL2bhH+9bBygV1lo6Im71uAjcUSVWx84fFkrTwjlzF36BIb4PZCfj0/vMKrfmiVx/F/2QMSAp/3q5QEs=
X-Received: by 2002:a17:902:8609:: with SMTP id f9mr33680584plo.252.1559648735444;
 Tue, 04 Jun 2019 04:45:35 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <097bc300a5c6554ca6fd1886421bb2e0adb03420.1559580831.git.andreyknvl@google.com>
 <8ff5b0ff-849a-1e0b-18da-ccb5be85dd2b@oracle.com> <CAAeHK+xX2538e674Pz25unkdFPCO_SH0pFwFu=8+DS7RzfYnLQ@mail.gmail.com>
 <f6711d31-e52c-473a-d7ad-b2d63131d7a5@oracle.com> <20190603172916.GA5390@infradead.org>
 <7a687a26-fc3e-2caa-1d6a-464f1f7e684c@oracle.com>
In-Reply-To: <7a687a26-fc3e-2caa-1d6a-464f1f7e684c@oracle.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 4 Jun 2019 13:45:24 +0200
Message-ID: <CAAeHK+wccK1upfOWxNbZBR0BUWT23VFUFEqRTEp3H+8hXN8yzw@mail.gmail.com>
Subject: Re: [PATCH v16 01/16] uaccess: add untagged_addr definition for other arches
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 3, 2019 at 8:17 PM Khalid Aziz <khalid.aziz@oracle.com> wrote:
>
> On 6/3/19 11:29 AM, Christoph Hellwig wrote:
> > On Mon, Jun 03, 2019 at 11:24:35AM -0600, Khalid Aziz wrote:
> >> On 6/3/19 11:06 AM, Andrey Konovalov wrote:
> >>> On Mon, Jun 3, 2019 at 7:04 PM Khalid Aziz <khalid.aziz@oracle.com> wrote:
> >>>> Andrey,
> >>>>
> >>>> This patch has now become part of the other patch series Chris Hellwig
> >>>> has sent out -
> >>>> <https://lore.kernel.org/lkml/20190601074959.14036-1-hch@lst.de/>. Can
> >>>> you coordinate with that patch series?
> >>>
> >>> Hi!
> >>>
> >>> Yes, I've seen it. How should I coordinate? Rebase this series on top
> >>> of that one?
> >>
> >> That would be one way to do it. Better yet, separate this patch from
> >> both patch series, make it standalone and then rebase the two patch
> >> series on top of it.
> >
> > I think easiest would be to just ask Linus if he could make an exception
> > and include this trivial prep patch in 5.2-rc.
> >
>
> Andrey,
>
> Would you mind updating the commit log to make it not arm64 specific and
> sending this patch out by itself. We can then ask Linus if he can
> include just this patch in the next rc.

Sure! Just sent it out.

>
> Thanks,
> Khalid
>

