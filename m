Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAA66B006E
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 18:42:00 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so30570013pdb.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 15:41:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ch6si14503113pdb.175.2015.04.23.15.41.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 15:41:59 -0700 (PDT)
Date: Thu, 23 Apr 2015 15:41:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: reduce arch dependent code about
 huge_pmd_unshare
Message-Id: <20150423154157.837a378188ef0a703813f206@linux-foundation.org>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32A6478B@ORSMSX114.amr.corp.intel.com>
References: <1428996566-86763-1-git-send-email-zhenzhang.zhang@huawei.com>
	<552CC328.9050402@huawei.com>
	<20150423151118.40c41fb1810f2aaa877163ae@linux-foundation.org>
	<3908561D78D1C84285E8C5FCA982C28F32A6478B@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Zhang Zhen <zhenzhang.zhang@huawei.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "james.hogan@imgtec.com" <james.hogan@imgtec.com>, "ralf@linux-mips.org" <ralf@linux-mips.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "cmetcalf@ezchip.com" <cmetcalf@ezchip.com>, David Rientjes <rientjes@google.com>, "James.Yang@freescale.com" <James.Yang@freescale.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>

On Thu, 23 Apr 2015 22:26:18 +0000 "Luck, Tony" <tony.luck@intel.com> wrote:

> > Memory fails me.  Why do some architectures (arm, arm64, x86_64) want
> > huge_pmd_[un]share() while other architectures (ia64, tile, mips,
> > powerpc, metag, sh, s390) do not?
> 
> Potentially laziness/ignorance-of-feature?  It looks like this feature started on x86_64 and then spread
> to arm*.

Yes.  In 3212b535f200c85b5a6 Steve Capper (ARM person) hoisted the code
out of x86 into generic, then made arm use it.

We're not (I'm not) very good about letting arch people know about such
things.  I wonder how to fix that; does linux-arch work?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
