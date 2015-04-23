Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 254D16B007B
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 18:11:21 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so29995829pdb.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 15:11:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qc10si4800265pbc.75.2015.04.23.15.11.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 15:11:20 -0700 (PDT)
Date: Thu, 23 Apr 2015 15:11:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: reduce arch dependent code about
 huge_pmd_unshare
Message-Id: <20150423151118.40c41fb1810f2aaa877163ae@linux-foundation.org>
In-Reply-To: <552CC328.9050402@huawei.com>
References: <1428996566-86763-1-git-send-email-zhenzhang.zhang@huawei.com>
	<552CC328.9050402@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux@arm.linux.org.uk, catalin.marinas@arm.com, tony.luck@intel.com, james.hogan@imgtec.com, ralf@linux-mips.org, benh@kernel.crashing.org, schwidefsky@de.ibm.com, cmetcalf@ezchip.com, David Rientjes <rientjes@google.com>, James.Yang@freescale.com, aneesh.kumar@linux.vnet.ibm.com

On Tue, 14 Apr 2015 15:35:04 +0800 Zhang Zhen <zhenzhang.zhang@huawei.com> wrote:

> Currently we have many duplicates in definitions of huge_pmd_unshare.
> In all architectures this function just returns 0 when
> CONFIG_ARCH_WANT_HUGE_PMD_SHARE is N.
> 
> This patch put the default implementation in mm/hugetlb.c and lets
> these architecture use the common code.

Memory fails me.  Why do some architectures (arm, arm64, x86_64) want
huge_pmd_[un]share() while other architectures (ia64, tile, mips,
powerpc, metag, sh, s390) do not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
