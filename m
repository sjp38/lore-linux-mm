Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E147A6B7A25
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 07:26:15 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id l45so308792edb.1
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 04:26:15 -0800 (PST)
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70077.outbound.protection.outlook.com. [40.107.7.77])
        by mx.google.com with ESMTPS id gx11-v6si178526ejb.297.2018.12.06.04.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Dec 2018 04:26:14 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V4 5/6] arm64: mm: introduce 52-bit userspace support
Date: Thu, 6 Dec 2018 12:26:12 +0000
Message-ID: <20181206122603.GB17473@capper-debian.cambridge.arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
 <20181205164145.24568-6-steve.capper@arm.com>
 <e1a9b147-d635-9f32-2f33-ccd689dba858@arm.com>
In-Reply-To: <e1a9b147-d635-9f32-2f33-ccd689dba858@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1F5D34DCB0DB9E419B0ABB0B65633BE6@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suzuki Poulose <Suzuki.Poulose@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>

On Wed, Dec 05, 2018 at 06:22:27PM +0000, Suzuki K Poulose wrote:
> Hi Steve,
>=20
[...]=20
> I think we may need a check for the secondary CPUs to make sure that they=
 have
> the 52bit support once the boot CPU has decided to use the feature and fa=
il the
> CPU bring up (just like we do for the granule support).
>=20
> Suzuki

Hi Suzuki,
I have just written a patch to detect a mismatch between 52-bit VA that
is being tested now.

As 52-bit kernel VA support is coming in future, the patch checks for a
mismatch during the secondary boot path and, if one is found, prevents
the secondary from booting (and displays an error message to the user).

Cheers,
--=20
Steve
