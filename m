Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4428A6B7A2C
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 07:28:10 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id q18so94839wrx.0
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 04:28:10 -0800 (PST)
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70089.outbound.protection.outlook.com. [40.107.7.89])
        by mx.google.com with ESMTPS id k14si162636wrx.338.2018.12.06.04.28.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Dec 2018 04:28:09 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V4 6/6] arm64: mm: Allow forcing all userspace addresses
 to 52-bit
Date: Thu, 6 Dec 2018 12:28:07 +0000
Message-ID: <20181206122758.GB17572@capper-debian.cambridge.arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
 <20181205164145.24568-7-steve.capper@arm.com>
 <20181206115132.GD54495@arrakis.emea.arm.com>
In-Reply-To: <20181206115132.GD54495@arrakis.emea.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A69D1A85E3666F408922354C98372FF0@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <Catalin.Marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>

On Thu, Dec 06, 2018 at 11:51:33AM +0000, Catalin Marinas wrote:
> On Wed, Dec 05, 2018 at 04:41:45PM +0000, Steve Capper wrote:
> > On arm64 52-bit VAs are provided to userspace when a hint is supplied t=
o
> > mmap. This helps maintain compatibility with software that expects at
> > most 48-bit VAs to be returned.
> >=20
> > In order to help identify software that has 48-bit VA assumptions, this
> > patch allows one to compile a kernel where 52-bit VAs are returned by
> > default on HW that supports it.
> >=20
> > This feature is intended to be for development systems only.
> >=20
> > Signed-off-by: Steve Capper <steve.capper@arm.com>
>=20
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks Catalin.
