Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id BAC8E6B0036
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 05:11:39 -0400 (EDT)
Received: by mail-yh0-f53.google.com with SMTP id v1so7246470yhn.40
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 02:11:39 -0700 (PDT)
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
        by mx.google.com with ESMTPS id 21si17287632yhq.214.2014.03.31.02.11.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 02:11:39 -0700 (PDT)
Received: by mail-yk0-f172.google.com with SMTP id 200so5859964ykr.17
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 02:11:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140328172805.67f9ea0b@thinkpad>
References: <1395321473-1257-1-git-send-email-steve.capper@linaro.org>
	<20140327151129.GA5117@linaro.org>
	<20140328172805.67f9ea0b@thinkpad>
Date: Mon, 31 Mar 2014 10:11:38 +0100
Message-ID: <CAPvkgC2MQerGMeY=Sunz-t2kTAnAe_cuJDr+d1kdOP9qr=UW6g@mail.gmail.com>
Subject: Re: [PATCH V2] mm: hugetlb: Introduce huge_pte_{page,present,young}
From: Steve Capper <steve.capper@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: linux-mm@kvack.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-s390@vger.kernel.org, akpm@linux-foundation.org, Catalin Marinas <catalin.marinas@arm.com>

On 28 March 2014 16:28, Gerald Schaefer <gerald.schaefer@de.ibm.com> wrote:
> On Thu, 27 Mar 2014 15:11:30 +0000
> Steve Capper <steve.capper@linaro.org> wrote:
>
>> On Thu, Mar 20, 2014 at 01:17:53PM +0000, Steve Capper wrote:
>> > Introduce huge pte versions of pte_page, pte_present and pte_young.
>> >
>> > This allows ARM (without LPAE) to use alternative pte processing logic
>> > for huge ptes.
>> >
>> > Generic implementations that call the standard pte versions are also
>> > added to asm-generic/hugetlb.h.
>> >
>> > Signed-off-by: Steve Capper <steve.capper@linaro.org>
>> > ---
>> > Changed in V2 - moved from #ifndef,#define macros to entries in
>> > asm-generic/hugetlb.h as it makes more sense to have these with the
>> > other huge_pte_. definitions.
>> >
>> > The only other architecture I can see that does not use
>> > asm-generic/hugetlb.h is s390. This patch includes trivial definitions
>> > for huge_pte_{page,present,young} for s390.
>> >
>> > I've compile-tested this for s390, but don't have one under my desk so
>> > have not been able to test it.
>> > ---
>> >  arch/s390/include/asm/hugetlb.h | 15 +++++++++++++++
>> >  include/asm-generic/hugetlb.h   | 15 +++++++++++++++
>> >  mm/hugetlb.c                    | 22 +++++++++++-----------
>> >  3 files changed, 41 insertions(+), 11 deletions(-)
>> >
>>
>> Hello,
>> I was just wondering if this patch looked reasonable to people?
>
> Looks good, and I also tested it on s390, so for the s390 part:
> Acked-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
