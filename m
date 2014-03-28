Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 336F36B0035
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 12:28:14 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so3658460wgg.33
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 09:28:13 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id ge12si2560861wic.74.2014.03.28.09.28.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 09:28:11 -0700 (PDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 28 Mar 2014 16:28:10 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9C1921B0805F
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 16:28:02 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2SGRu3b2031882
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 16:27:56 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2SGS7S5010592
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 10:28:08 -0600
Date: Fri, 28 Mar 2014 17:28:05 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH V2] mm: hugetlb: Introduce huge_pte_{page,present,young}
Message-ID: <20140328172805.67f9ea0b@thinkpad>
In-Reply-To: <20140327151129.GA5117@linaro.org>
References: <1395321473-1257-1-git-send-email-steve.capper@linaro.org>
	<20140327151129.GA5117@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, akpm@linux-foundation.org, catalin.marinas@arm.com

On Thu, 27 Mar 2014 15:11:30 +0000
Steve Capper <steve.capper@linaro.org> wrote:

> On Thu, Mar 20, 2014 at 01:17:53PM +0000, Steve Capper wrote:
> > Introduce huge pte versions of pte_page, pte_present and pte_young.
> > 
> > This allows ARM (without LPAE) to use alternative pte processing logic
> > for huge ptes.
> > 
> > Generic implementations that call the standard pte versions are also
> > added to asm-generic/hugetlb.h.
> > 
> > Signed-off-by: Steve Capper <steve.capper@linaro.org>
> > ---
> > Changed in V2 - moved from #ifndef,#define macros to entries in
> > asm-generic/hugetlb.h as it makes more sense to have these with the
> > other huge_pte_. definitions.
> > 
> > The only other architecture I can see that does not use
> > asm-generic/hugetlb.h is s390. This patch includes trivial definitions
> > for huge_pte_{page,present,young} for s390.
> > 
> > I've compile-tested this for s390, but don't have one under my desk so
> > have not been able to test it.
> > ---
> >  arch/s390/include/asm/hugetlb.h | 15 +++++++++++++++
> >  include/asm-generic/hugetlb.h   | 15 +++++++++++++++
> >  mm/hugetlb.c                    | 22 +++++++++++-----------
> >  3 files changed, 41 insertions(+), 11 deletions(-)
> > 
> 
> Hello,
> I was just wondering if this patch looked reasonable to people?

Looks good, and I also tested it on s390, so for the s390 part:
Acked-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
