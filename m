Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63EF96B0011
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 06:06:35 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id a6so4215597oti.15
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 03:06:35 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 64si697195ota.415.2018.02.09.03.06.34
        for <linux-mm@kvack.org>;
        Fri, 09 Feb 2018 03:06:34 -0800 (PST)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB hugepage
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
	<1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<87inbbjx2w.fsf@e105922-lin.cambridge.arm.com>
	<20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp>
	<87fu6bfytm.fsf@e105922-lin.cambridge.arm.com>
	<20180208121749.0ac09af2b5a143106f339f55@linux-foundation.org>
Date: Fri, 09 Feb 2018 11:06:31 +0000
In-Reply-To: <20180208121749.0ac09af2b5a143106f339f55@linux-foundation.org>
	(Andrew Morton's message of "Thu, 8 Feb 2018 12:17:49 -0800")
Message-ID: <877ermfmmg.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 08 Feb 2018 12:30:45 +0000 Punit Agrawal <punit.agrawal@arm.com> wrote:
>
>> >
>> > So I don't think that the above test result means that errors are properly
>> > handled, and the proposed patch should help for arm64.
>> 
>> Although, the deviation of pud_huge() avoids a kernel crash the code
>> would be easier to maintain and reason about if arm64 helpers are
>> consistent with expectations by core code.
>> 
>> I'll look to update the arm64 helpers once this patch gets merged. But
>> it would be helpful if there was a clear expression of semantics for
>> pud_huge() for various cases. Is there any version that can be used as
>> reference?
>
> Is that an ack or tested-by?

It's an ack - I should've been more explicit.

Acked-by: Punit Agrawal <punit.agrawal@arm.com>

Thanks,
Punit

[...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
