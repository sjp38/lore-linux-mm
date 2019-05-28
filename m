Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18F70C04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:15:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D004621530
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:15:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tL4iRhDx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D004621530
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 692906B0276; Tue, 28 May 2019 10:15:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 643C36B0279; Tue, 28 May 2019 10:15:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55AFC6B027A; Tue, 28 May 2019 10:15:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20D6A6B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 10:15:00 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 11so15831351pfb.4
        for <linux-mm@kvack.org>; Tue, 28 May 2019 07:15:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=uILrnXKlYf2xjYbSzuRjxVZ/GKBRZG6iBlNh5FVzNqg=;
        b=Tb9cskqf0N0RpY7k/fSp3A/VSdaYGtMYClwKIenTe4guzDumEq5XHXlH4hf3aGWsqg
         jYq6RxkPnvjVL14xC4FosHtPZ3ZqpiJBj1Pf++pCMPkBgReyeqLZ1UV118vPGYsp6lQa
         pBya9bMROWGtHZWO1bKYDthEFbizUnJP5z1auvm6T+amOCTXnrVPFKAzq9JK0cOQcTTy
         x9fVEx23OPxhIHsXKShmGbZy7WyXEvBXaLfZErwJOOx1t3fOVNM5eKdiHyvrqPN6j9dJ
         wObF6g5+MpfkNcuQS1/67b4jZ7jd9tJ0wshomaGjGKbfOI2JTzKpSzjKZzmQbWiyFxi3
         s/NA==
X-Gm-Message-State: APjAAAWAgn9yJzyMZvXVqMpfhGqZe7mxD/2fmOrbnUziQUCTcuoNnBgf
	3jNy2/A3SQB3pAMBVnVHssZc6WiDVHoHvAOobAtfJ5nQXsGaiMZeOCULPsWInql0dPHLeO2xth0
	Dm2RCnWuF5CvH4chh0JBG8RuQRyY25b85xARfwB7Qo2E7kYJdPDOsH0LHRX093474wA==
X-Received: by 2002:a62:2706:: with SMTP id n6mr63376238pfn.150.1559052899746;
        Tue, 28 May 2019 07:14:59 -0700 (PDT)
X-Received: by 2002:a62:2706:: with SMTP id n6mr63376158pfn.150.1559052898725;
        Tue, 28 May 2019 07:14:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559052898; cv=none;
        d=google.com; s=arc-20160816;
        b=sP00WCeXqPlfgyKBgPjie+IQUQ09bapZ7nU1cxyGV3yb6m2Hudq7171LpTLQ9Fp7At
         5LI+Sfu2yEpNuOgeTOJEksQFnZsf5BWRTM68gCeleMtQOotBQHazhwZOBoqjPQucqgIO
         SH3W6jjuhjN98dd1peLri/P0z2q+mnyvsvkpLUCHotdzSB6hChnnTPHGzqIKrsxcaRYZ
         mlHbrMGUUHI7N8qQaQc623Ahxll99WWajIdAPFGC3MZ7axPwOQdDK/g3wadF2h79ZYtb
         f0Lg00D7vRoQ5/8oFnmEMyklgX8Si8+h48FCJ7Ry+qOIXxN9JPSHihuSYsXes+NMN8c4
         TsHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=uILrnXKlYf2xjYbSzuRjxVZ/GKBRZG6iBlNh5FVzNqg=;
        b=qFlEXBQsmB8ob7NCdW3MOZiQw+AEejYrCQHAGKO3nirXPC1VZWEyHl83lFniFxXcAv
         79+ubpDuB6FD6vna5qLqhcviGdATX4oZcKkAYkAXzGtACgZMt+8MFRsko4V3uLmnDhkj
         X8z13+IZXJ2GxQxevAWvdhCPIHdUmmM/eUavGy3DUZDrQZ6zRjqYUPYn2wkU4+Y63Cge
         Od00mQhYzi7xa+oyVOccy+Qq7rvD9IThwf9RwgV19q0xWZqaMBYUN/Ii0GqTeTrMDw7p
         qCcUhBuKzZwDf0CIFzz5XZlqWQwe0OC7arlX/1YGUmqNILXAeuMXrINuhWdrVbyimFi0
         XmSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tL4iRhDx;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j16sor9688413pgl.59.2019.05.28.07.14.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 07:14:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tL4iRhDx;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uILrnXKlYf2xjYbSzuRjxVZ/GKBRZG6iBlNh5FVzNqg=;
        b=tL4iRhDxBHlVQ+tyr45nAjSTrWm4FGkpU9/gqgAOrFY5B7cJ7oOHLY740uFY6v9Apt
         FqrRnmxExj3iQTQYzs/PenqdbelZVqX7ImfSm34SI3kUWnaFv2Pd1vXHqDLGJYPgxvw8
         7KLV8hWWHlsDJ/UwTZYLqE3rqDzmSrpBL95BUyqXducEuzu32sr8cYoLi6lrm/VHbu19
         kGodX0/6n5OKGvwKCkqnvqlMkPVgQ7D246As7ltK/sqPD0kwVjhXWCNgzf39x95m1k16
         0eXP9QfKOUXReSvTh9f0l8fCYrSWQokxzY+jcITzAkXcdghBa76eI6mVVXYUH34oj3Ib
         qnwQ==
X-Google-Smtp-Source: APXvYqyOX9PeZsCaqURSrIEWPGIBd1WFVQ7exVP3S114miK0Cy+gUD/uDqW5wGxUjPG0aHqJLJFWW3mMb6YG8JIQdRk=
X-Received: by 2002:a65:64d9:: with SMTP id t25mr132418776pgv.130.1559052897854;
 Tue, 28 May 2019 07:14:57 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com> <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp> <201905211633.6C0BF0C2@keescook>
 <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com> <20190523201105.oifkksus4rzcwqt4@mbp>
 <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com> <20190524101139.36yre4af22bkvatx@mbp>
 <c6dd53d8-142b-3d8d-6a40-d21c5ee9d272@oracle.com>
In-Reply-To: <c6dd53d8-142b-3d8d-6a40-d21c5ee9d272@oracle.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 28 May 2019 16:14:45 +0200
Message-ID: <CAAeHK+yAUsZWhp6xPAbWewX5Nbw+-G3svUyPmhXu5MVeEDKYvA@mail.gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
To: Catalin Marinas <catalin.marinas@arm.com>, Kees Cook <keescook@chromium.org>
Cc: Evgenii Stepanov <eugenis@google.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, 
	Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Elliott Hughes <enh@google.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for a lot of valuable input! I've read through all the replies
and got somewhat lost. What are the changes I need to do to this
series?

1. Should I move untagging for memory syscalls back to the generic
code so other arches would make use of it as well, or should I keep
the arm64 specific memory syscalls wrappers and address the comments
on that patch?

2. Should I make untagging opt-in and controlled by a command line argument?

3. Should I "add Documentation/core-api/user-addresses.rst to describe
proper care and handling of user space pointers with untagged_addr(),
with examples based on all the cases seen so far in this series"?
Which examples specifically should it cover?

Is there something else?

