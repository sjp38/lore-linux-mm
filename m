Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 239DB6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 05:41:59 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id rr4so485888pbb.25
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 02:41:58 -0800 (PST)
Received: from psmtp.com ([74.125.245.161])
        by mx.google.com with SMTP id hb3si10494291pac.36.2013.11.04.02.41.57
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 02:41:58 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1382449940-24357-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1382449940-24357-1-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH] x86, mm: get ASLR work for hugetlb mappings
Content-Transfer-Encoding: 7bit
Message-Id: <20131104104152.72F91E0090@blue.fi.intel.com>
Date: Mon,  4 Nov 2013 12:41:52 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>

Kirill A. Shutemov wrote:
> Matthew noticed that hugetlb doesn't participate in ASLR on x86-64.
> The reason is genereic hugetlb_get_unmapped_area() which is used on
> x86-64. It doesn't support randomization and use bottom-up unmapped area
> lookup, instead of usual top-down on x86-64.
> 
> x86 has arch-specific hugetlb_get_unmapped_area(), but it's used only on
> x86-32.
> 
> Let's use arch-specific hugetlb_get_unmapped_area() on x86-64 too.
> It fixes the issue and make hugetlb use top-down unmapped area lookup.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Matthew Wilcox <willy@linux.intel.com>

Andrew, any comments?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
