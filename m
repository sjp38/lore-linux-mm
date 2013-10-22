Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 07D636B00D2
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 11:22:11 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so7994962pad.30
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 08:22:11 -0700 (PDT)
Received: from psmtp.com ([74.125.245.143])
        by mx.google.com with SMTP id ph6si11991471pbb.7.2013.10.22.08.22.10
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 08:22:11 -0700 (PDT)
Message-ID: <526697F5.7040800@intel.com>
Date: Tue, 22 Oct 2013 08:21:25 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86, mm: get ASLR work for hugetlb mappings
References: <1382449940-24357-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1382449940-24357-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

On 10/22/2013 06:52 AM, Kirill A. Shutemov wrote:
> Matthew noticed that hugetlb doesn't participate in ASLR on x86-64.
> The reason is genereic hugetlb_get_unmapped_area() which is used on
> x86-64. It doesn't support randomization and use bottom-up unmapped area
> lookup, instead of usual top-down on x86-64.

I have to wonder if this was on purpose in order to keep the large and
small mappings separate.  We don't *have* to keep them separate this, of
course, but it makes me wonder.

> x86 has arch-specific hugetlb_get_unmapped_area(), but it's used only on
> x86-32.
> 
> Let's use arch-specific hugetlb_get_unmapped_area() on x86-64 too.
> It fixes the issue and make hugetlb use top-down unmapped area lookup.

Shouldn't we fix the generic code instead of further specializing the
x86 stuff?

In any case, you probably also want to run this through: the
libhugetlbfs tests:

http://sourceforge.net/p/libhugetlbfs/code/ci/master/tree/tests/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
