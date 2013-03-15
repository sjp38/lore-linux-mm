Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 3F7046B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 09:33:35 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id 16so3200429obc.19
        for <linux-mm@kvack.org>; Fri, 15 Mar 2013 06:33:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130315132656.BC518E0085@blue.fi.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1363283435-7666-17-git-send-email-kirill.shutemov@linux.intel.com>
	<CAJd=RBCxNgjUUSbbTnVymC7+O51LKDuKTyTkEGYwuWYB9_oUmw@mail.gmail.com>
	<20130315132656.BC518E0085@blue.fi.intel.com>
Date: Fri, 15 Mar 2013 21:33:34 +0800
Message-ID: <CAJd=RBBt5qfnucCT2KDpqy54BZ6SQiGxy3wmcKv0MS=kwN5+8Q@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 16/30] thp: handle file pages in split_huge_page()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 9:26 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Hillf Danton wrote:
>> On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>> > -int split_huge_page(struct page *page)
>> > +static int split_anon_huge_page(struct page *page)
>> >  {
>> >         struct anon_vma *anon_vma;
>> >         int ret = 1;
>> >
>> > -       BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
>> > -       BUG_ON(!PageAnon(page));
>> > -
>> deleted, why?
>
> split_anon_huge_page() should only be called from split_huge_page().
> Probably I could bring it back, but it's kinda redundant.
>
Ok, no more question.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
