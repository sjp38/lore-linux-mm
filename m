Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0F696B05D1
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 05:33:56 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id t22-v6so412221wmt.9
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 02:33:56 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30079.outbound.protection.outlook.com. [40.107.3.79])
        by mx.google.com with ESMTPS id q193-v6si3177312wmg.125.2018.11.08.02.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Nov 2018 02:33:54 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V3 1/5] mm/hugetlb: Distinguish between migratability and
 movability
Date: Thu, 8 Nov 2018 10:33:52 +0000
Message-ID: <20181108103340.ajeg566spidprzzk@capper-debian.cambridge.arm.com>
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
 <1540299721-26484-2-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1540299721-26484-2-git-send-email-anshuman.khandual@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3C4C4AF369624046874B8669A50CA08E@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <Anshuman.Khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Suzuki Poulose <Suzuki.Poulose@arm.com>, Punit Agrawal <Punit.Agrawal@arm.com>, Will Deacon <Will.Deacon@arm.com>, Steven Price <Steven.Price@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, nd <nd@arm.com>

Hi Anshuman,

On Tue, Oct 23, 2018 at 06:31:57PM +0530, Anshuman Khandual wrote:
> During huge page allocation it's migratability is checked to determine if
> it should be placed under movable zones with GFP_HIGHUSER_MOVABLE. But th=
e
> movability aspect of the huge page could depend on other factors than jus=
t
> migratability. Movability in itself is a distinct property which should n=
ot
> be tied with migratability alone.
>=20
> This differentiates these two and implements an enhanced movability check
> which also considers huge page size to determine if it is feasible to be
> placed under a movable zone. At present it just checks for gigantic pages
> but going forward it can incorporate other enhanced checks.
>=20
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

FWIW:
Reviewed-by: Steve Capper <steve.capper@arm.com>
