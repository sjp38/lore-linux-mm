Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6F86B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 11:46:28 -0400 (EDT)
Received: by iecrt8 with SMTP id rt8so86444981iec.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:46:28 -0700 (PDT)
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com. [209.85.213.177])
        by mx.google.com with ESMTPS id l74si9750568iol.61.2015.04.24.08.46.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 08:46:27 -0700 (PDT)
Received: by igbhj9 with SMTP id hj9so18120951igb.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:46:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150423154157.837a378188ef0a703813f206@linux-foundation.org>
References: <1428996566-86763-1-git-send-email-zhenzhang.zhang@huawei.com>
	<552CC328.9050402@huawei.com>
	<20150423151118.40c41fb1810f2aaa877163ae@linux-foundation.org>
	<3908561D78D1C84285E8C5FCA982C28F32A6478B@ORSMSX114.amr.corp.intel.com>
	<20150423154157.837a378188ef0a703813f206@linux-foundation.org>
Date: Fri, 24 Apr 2015 16:46:27 +0100
Message-ID: <CAPvkgC2dMzp26-XcYMNVufMiuoAmuKw-hr4kYH27_nARz3gbQg@mail.gmail.com>
Subject: Re: [PATCH] mm/hugetlb: reduce arch dependent code about huge_pmd_unshare
From: Steve Capper <steve.capper@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "james.hogan@imgtec.com" <james.hogan@imgtec.com>, "ralf@linux-mips.org" <ralf@linux-mips.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "cmetcalf@ezchip.com" <cmetcalf@ezchip.com>, David Rientjes <rientjes@google.com>, "James.Yang@freescale.com" <James.Yang@freescale.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>

Hi,

On 23 April 2015 at 23:41, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 23 Apr 2015 22:26:18 +0000 "Luck, Tony" <tony.luck@intel.com> wrote:
>
>> > Memory fails me.  Why do some architectures (arm, arm64, x86_64) want
>> > huge_pmd_[un]share() while other architectures (ia64, tile, mips,
>> > powerpc, metag, sh, s390) do not?
>>
>> Potentially laziness/ignorance-of-feature?  It looks like this feature started on x86_64 and then spread
>> to arm*.
>
> Yes.  In 3212b535f200c85b5a6 Steve Capper (ARM person) hoisted the code
> out of x86 into generic, then made arm use it.

I tested the pmd sharing code that x86 had and it worked well on ARM
too so I bundled it in when I generalised some of the huge page code.
I didn't know enough about the other architectures to enable it for
them, so played things safe by leaving it disabled for them.
Looking at this patch, I could have done that more cleanly though.

>
> We're not (I'm not) very good about letting arch people know about such
> things.  I wonder how to fix that; does linux-arch work?
>

linux-arch is working for me, maybe a good idea to CC in some arch
maintainers too.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
