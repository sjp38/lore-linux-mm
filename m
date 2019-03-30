Return-Path: <SRS0=krm6=SB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDD7FC10F00
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 23:57:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71D5C2184C
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 23:57:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="ozHEe23W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71D5C2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AB716B0003; Sat, 30 Mar 2019 19:57:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90B9E6B0006; Sat, 30 Mar 2019 19:57:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F8F76B0007; Sat, 30 Mar 2019 19:57:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2EF6B0003
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 19:57:43 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id j202so2092721oih.23
        for <linux-mm@kvack.org>; Sat, 30 Mar 2019 16:57:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/mTXQwEHp25jsXXs0xOppcW45YpPe1sGxWOzazKsAao=;
        b=IMZXKtAJ5VQQAukPh/uAtasgOm1r1YafbizGBLesO3P0XvAaba9McXaHvtiZxlidzq
         BMMVU+MCKlqYNLB4numALfSO2HG6ONnr0rkk4r94AHjPAycls9k/saLHRp4l9Ty5aUlZ
         2MDKCntdrMTjO94eXbPThnqqYtvSt1jcsnFw7KuOWCXQohE3NbOSnumsl+b7N1f7Stcx
         MVVm2KE9emJA+rmdWojMhAxTLkRwt8aQyNEIStSUWF/Ec74UowbnNlKjzzHooYAmTd7g
         M6I0htWN11h8ywDaCuhmMqvrfKU7z0m6HxpdXFKNLzRlvxfzI1nCq2RmwwvtdJssOIVe
         B2og==
X-Gm-Message-State: APjAAAUKy2whuctldqFhboC0MkE3YPSfSwTTuTO6C+sI7282yhh+RJM7
	lWbZaR2aAXdlzAXEcZMW9q5hjtAluc3QUATxIJ2GWB1mDUqJdZhdWt+Ps5CxjWJQwHe4seXYrov
	D9Nz4Iw9oKTLp55MP8fd94ET3z4fOsyU7Hd1+5enVLsmshf21Jw2a2fPC0Yf2W/VYJg==
X-Received: by 2002:a9d:7a4b:: with SMTP id z11mr40208558otm.355.1553990262845;
        Sat, 30 Mar 2019 16:57:42 -0700 (PDT)
X-Received: by 2002:a9d:7a4b:: with SMTP id z11mr40208543otm.355.1553990262079;
        Sat, 30 Mar 2019 16:57:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553990262; cv=none;
        d=google.com; s=arc-20160816;
        b=Aiz5PCgxbvf21t3j5orDZRrwt/Bl+FLwC4T2NUPVM+u4V1RoKE08FNImcV5wcw0y7Q
         dRouu5XbWPx/W/3LmZAir21amKf+cQht4L5VO90EgiptdDFAQOQsd761ZkmOsSRWj5vX
         wtvjM26r0vwOS3Moo4eSydUnLDmzDROmrA815ee3DRofLiDG+zsanfR84Q5Tkbi8Q1yE
         15NqzAa+dOKI4aphPA50k6ncOFiZ7kXJb1jip+wKeG3gAlytmFeoe74jDjN4SukjiP4g
         ygE+vOithZYQOZivIzwQV63aIljcn6uF/p1cQ9l283NYYfsnkg6xuqF8sHrfQzwqTnN9
         RHhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/mTXQwEHp25jsXXs0xOppcW45YpPe1sGxWOzazKsAao=;
        b=wwe9uNNmSZxupRKdiCje/DLOn8z/UpT4v83M/5/QkVcMhM/Qm2kd76/HzcL/K2G98r
         qn1TYdZT1kle5BnOf7L33MuMiH4EJMP1An7Vjh6Gnh27wqbUVGr6p4n/+b7/UFTliHtm
         qYEsEtqM7nUTgUkbt442c8UT+GQK5T57zUN56ms0KwER7Yc79VBuQVfD9A3UQvi5Q17U
         tve8xjYRUqNiXwv12InD381k3GphcTLNeOQOmm9Z8OpS7kKcaYkUCF5qcaCUElQOq7Tj
         FOYdCCkyfrfycrsR54bagoLKuP1D7o2vwbxw/4UhaoEJ0d9RECxWSbc+qrh/emrRse6G
         YQOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=ozHEe23W;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o10sor2712278otl.80.2019.03.30.16.57.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 30 Mar 2019 16:57:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=ozHEe23W;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/mTXQwEHp25jsXXs0xOppcW45YpPe1sGxWOzazKsAao=;
        b=ozHEe23WHi2UdztToyVId1Kmaiop+mLWTewhTDgRtxN41uC3SZ+Jbdhy7Cp+IWvbQR
         zFzOQex+qr+RrVTlm1knBbHOjWMcA1YsbxtMW1VuqFurEgBnOCmy10L9vPNaHP3VRML8
         kUsXQIQHEPgmDaxjgax3Cn+vjBGL2oAoSg6qnZCpsIMVXxVVXHeoKUIAxmUf+reY9ggj
         XfucD1OxCplzwT/Z4+VEndIs7+cGtpLxSI1f+G0TwuBZ6H03v/C5zUHlNgnOas4iWMfl
         +J5W/v0JS1VRmMtu89cD2R8Jngi+gyjyElfBo4GSqfYu4/c4S8sjVF95aclfsOKQvnnz
         MDQQ==
X-Google-Smtp-Source: APXvYqxHD39w1ZNGQhKRDXhJxSes4mrfXcPcv4gwie55Uu1wRRS/LRNC7hDRdRwMbzqNi05PsdH8148aAAI3q6j3C9Y=
X-Received: by 2002:a9d:3e11:: with SMTP id a17mr38746422otd.185.1553990261575;
 Sat, 30 Mar 2019 16:57:41 -0700 (PDT)
MIME-Version: 1.0
References: <eea3ce6a-732b-5c1d-9975-eddaeee21cf5@infradead.org>
 <20190329181839.139301-1-ndesaulniers@google.com> <83226cfb-afa7-0174-896c-d9f7a6193cf4@infradead.org>
In-Reply-To: <83226cfb-afa7-0174-896c-d9f7a6193cf4@infradead.org>
From: Tri Vo <trong@android.com>
Date: Sat, 30 Mar 2019 16:57:30 -0700
Message-ID: <CANA+-vAcW0VfAZmZWi84s1pQQ+tFx8VyzYsWi5_gj7vHT3Ao6Q@mail.gmail.com>
Subject: Re: [PATCH v2] gcov: fix when CONFIG_MODULES is not set
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Nick Desaulniers <ndesaulniers@google.com>, Peter Oberparleiter <oberpar@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Hackmann <ghackmann@android.com>, linux-mm@kvack.org, 
	kbuild-all@01.org, kbuild test robot <lkp@intel.com>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 1:53 PM Randy Dunlap <rdunlap@infradead.org> wrote:
>
> On 3/29/19 11:18 AM, Nick Desaulniers wrote:
> > Fixes commit 8c3d220cb6b5 ("gcov: clang support")
>
> There is a certain format for Fixes: and that's not quite it. :(
>
> > Cc: Greg Hackmann <ghackmann@android.com>
> > Cc: Tri Vo <trong@android.com>
> > Cc: Peter Oberparleiter <oberpar@linux.ibm.com>
> > Cc: linux-mm@kvack.org
> > Cc: kbuild-all@01.org
> > Reported-by: Randy Dunlap <rdunlap@infradead.org>
> > Reported-by: kbuild test robot <lkp@intel.com>
> > Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
> > Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
>
> Acked-by: Randy Dunlap <rdunlap@infradead.org> # build-tested
>
> Thanks.
>
> > ---
> >  kernel/gcov/gcc_3_4.c | 4 ++++
> >  kernel/gcov/gcc_4_7.c | 4 ++++
> >  2 files changed, 8 insertions(+)

Thanks for taking a look at this Nick! I believe same fix should be
applied to kernel/gcov/clang.c. I'll send out an updated version later
today.

