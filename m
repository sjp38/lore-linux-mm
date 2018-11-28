Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 804676B4DE1
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 11:31:59 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id q18so21913916wrx.0
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 08:31:59 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40073.outbound.protection.outlook.com. [40.107.4.73])
        by mx.google.com with ESMTPS id o8si6151183wrv.48.2018.11.28.08.31.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Nov 2018 08:31:58 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V3 3/5] arm64: mm: Define arch_get_mmap_end,
 arch_get_mmap_base
Date: Wed, 28 Nov 2018 16:31:56 +0000
Message-ID: <20181128163147.GB20432@capper-debian.cambridge.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-4-steve.capper@arm.com>
 <20181127171017.GD3563@arrakis.emea.arm.com>
In-Reply-To: <20181127171017.GD3563@arrakis.emea.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <602326BECCD55B469AA8A5A5E3979526@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <Catalin.Marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>

On Tue, Nov 27, 2018 at 05:10:18PM +0000, Catalin Marinas wrote:
> On Wed, Nov 14, 2018 at 01:39:18PM +0000, Steve Capper wrote:
> > Now that we have DEFAULT_MAP_WINDOW defined, we can arch_get_mmap_end
> > and arch_get_mmap_base helpers to allow for high addresses in mmap.
> >=20
> > Signed-off-by: Steve Capper <steve.capper@arm.com>
>=20
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks!
