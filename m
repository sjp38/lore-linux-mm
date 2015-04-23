Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id CF2E06B0038
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 18:26:22 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so30275108pdb.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 15:26:22 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id er5si14452435pbd.38.2015.04.23.15.26.20
        for <linux-mm@kvack.org>;
        Thu, 23 Apr 2015 15:26:22 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] mm/hugetlb: reduce arch dependent code about
 huge_pmd_unshare
Date: Thu, 23 Apr 2015 22:26:18 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32A6478B@ORSMSX114.amr.corp.intel.com>
References: <1428996566-86763-1-git-send-email-zhenzhang.zhang@huawei.com>
	<552CC328.9050402@huawei.com>
 <20150423151118.40c41fb1810f2aaa877163ae@linux-foundation.org>
In-Reply-To: <20150423151118.40c41fb1810f2aaa877163ae@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "james.hogan@imgtec.com" <james.hogan@imgtec.com>, "ralf@linux-mips.org" <ralf@linux-mips.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "cmetcalf@ezchip.com" <cmetcalf@ezchip.com>, David Rientjes <rientjes@google.com>, "James.Yang@freescale.com" <James.Yang@freescale.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>

> Memory fails me.  Why do some architectures (arm, arm64, x86_64) want
> huge_pmd_[un]share() while other architectures (ia64, tile, mips,
> powerpc, metag, sh, s390) do not?

Potentially laziness/ignorance-of-feature?  It looks like this feature star=
ted on x86_64 and then spread
to arm*.

Huge pages are weird on ia64 in that they have to be in a specific range of=
 virtual addresses (region 4).
But I don't see why that would prevent sharing pmd's.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
