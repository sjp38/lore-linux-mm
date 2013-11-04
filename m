Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 118B36B0036
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 16:09:54 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so7412717pad.39
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 13:09:54 -0800 (PST)
Received: from psmtp.com ([74.125.245.180])
        by mx.google.com with SMTP id z1si732621pbn.241.2013.11.04.13.09.53
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 13:09:54 -0800 (PST)
Date: Mon, 4 Nov 2013 13:09:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] x86, mm: get ASLR work for hugetlb mappings
Message-Id: <20131104130951.44c20ed3d29395a3da57ad46@linux-foundation.org>
In-Reply-To: <20131104104152.72F91E0090@blue.fi.intel.com>
References: <1382449940-24357-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20131104104152.72F91E0090@blue.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

On Mon,  4 Nov 2013 12:41:52 +0200 (EET) "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Kirill A. Shutemov wrote:
> > Matthew noticed that hugetlb doesn't participate in ASLR on x86-64.
> > The reason is genereic hugetlb_get_unmapped_area() which is used on
> > x86-64. It doesn't support randomization and use bottom-up unmapped area
> > lookup, instead of usual top-down on x86-64.
> > 
> > x86 has arch-specific hugetlb_get_unmapped_area(), but it's used only on
> > x86-32.
> > 
> > Let's use arch-specific hugetlb_get_unmapped_area() on x86-64 too.
> > It fixes the issue and make hugetlb use top-down unmapped area lookup.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Matthew Wilcox <willy@linux.intel.com>
> 
> Andrew, any comments?

whome?  I'm convinced, but it's an x86 patch.  I tossed it in there so
it gets a bit of linux-next exposure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
