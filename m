Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF1E6B0080
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 13:47:56 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id hz1so9312173pad.30
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 10:47:55 -0800 (PST)
Received: from psmtp.com ([74.125.245.109])
        by mx.google.com with SMTP id bc2si14699380pad.129.2013.11.05.10.47.53
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 10:47:53 -0800 (PST)
Message-ID: <52793D27.8050607@sr71.net>
Date: Tue, 05 Nov 2013 10:47:03 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: thp: give transparent hugepage code a separate
 copy_page
References: <20131028221618.4078637F@viggo.jf.intel.com> <20131028221620.042323B3@viggo.jf.intel.com> <20131028221126.GA29431@shutemov.name>
In-Reply-To: <20131028221126.GA29431@shutemov.name>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.jiang@intel.com, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, dhillf@gmail.com

On 10/28/2013 03:11 PM, Kirill A. Shutemov wrote:
> On Mon, Oct 28, 2013 at 03:16:20PM -0700, Dave Hansen wrote:
>> void copy_huge_page(struct page *dst, struct page *src)
>> {
>>         struct hstate *h = page_hstate(src);
>>         if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
>> ...
>>
>> This patch creates a copy_high_order_page() which can
>> be used on THP pages.
> 
> We already have copy_user_huge_page() and copy_user_gigantic_page() in
> generic code (mm/memory.c). I think copy_gigantic_page() and
> copy_huge_page() should be moved there too.

That would be fine I guesss... in another patch. :)

> BTW, I think pages_per_huge_page in copy_user_huge_page() is redunand:
> compound_order(page) should be enough, right?

The way it is now, the compiler can optimize for the !HUGETLBFS case.
Also, pages_per_huge_page() works for gigantic pages.  compound_order()
wouldn't work for those.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
