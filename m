Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id EAB8A6B000D
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 22:02:18 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id j47so23631837ota.16
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 19:02:18 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id u23si10379098otf.19.2018.10.18.19.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 19:02:17 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH V2 0/5] arm64/mm: Enable HugeTLB migration
Date: Fri, 19 Oct 2018 02:01:01 +0000
Message-ID: <20181019020101.GB18973@hori1.linux.bs1.fc.nec.co.jp>
References: <1539316799-6064-1-git-send-email-anshuman.khandual@arm.com>
 <e1703454-e500-3a1b-35cb-6368dff91f10@arm.com>
In-Reply-To: <e1703454-e500-3a1b-35cb-6368dff91f10@arm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <7EDDC048D50B7E4FA3D4ECCE61480856@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "suzuki.poulose@arm.com" <suzuki.poulose@arm.com>, "punit.agrawal@arm.com" <punit.agrawal@arm.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Steven.Price@arm.com" <Steven.Price@arm.com>, "steve.capper@arm.com" <steve.capper@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>

On Wed, Oct 17, 2018 at 01:49:17PM +0530, Anshuman Khandual wrote:
>=20
>=20
> On 10/12/2018 09:29 AM, Anshuman Khandual wrote:
> > This patch series enables HugeTLB migration support for all supported
> > huge page sizes at all levels including contiguous bit implementation.
> > Following HugeTLB migration support matrix has been enabled with this
> > patch series. All permutations have been tested except for the 16GB.
> >=20
> >          CONT PTE    PMD    CONT PMD    PUD
> >          --------    ---    --------    ---
> > 4K:         64K     2M         32M     1G
> > 16K:         2M    32M          1G
> > 64K:         2M   512M         16G
> >=20
> > First the series adds migration support for PUD based huge pages. It
> > then adds a platform specific hook to query an architecture if a
> > given huge page size is supported for migration while also providing
> > a default fallback option preserving the existing semantics which just
> > checks for (PMD|PUD|PGDIR)_SHIFT macros. The last two patches enables
> > HugeTLB migration on arm64 and subscribe to this new platform specific
> > hook by defining an override.
> >=20
> > The second patch differentiates between movability and migratability
> > aspects of huge pages and implements hugepage_movable_supported() which
> > can then be used during allocation to decide whether to place the huge
> > page in movable zone or not.
> >=20
> > Changes in V2:
> >=20
> > - Added a new patch which differentiates migratability and movability
> >   of huge pages and implements hugepage_movable_supported() function
> >   as suggested by Michal Hocko.
>=20
> Hello Andrew/Michal/Mike/Naoya/Catalin,
>=20
> Just checking for an update. Does this series looks okay ?

Looks good to me. So for the series

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=
