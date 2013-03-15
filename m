Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 92F5F6B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 09:30:34 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id wd20so3192199obb.37
        for <linux-mm@kvack.org>; Fri, 15 Mar 2013 06:30:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130315132440.C4DF8E0085@blue.fi.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1363283435-7666-14-git-send-email-kirill.shutemov@linux.intel.com>
	<CAJd=RBCHLigJBWiBt==wjjm7HA3CYSSyS6odKy0BgoudVxN80g@mail.gmail.com>
	<20130315132440.C4DF8E0085@blue.fi.intel.com>
Date: Fri, 15 Mar 2013 21:30:31 +0800
Message-ID: <CAJd=RBAMTOX=h5jodjNNbY=25rX8BxvEyVdWVYe-U=qDeow76A@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 13/30] thp, mm: implement grab_cache_huge_page_write_begin()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 9:24 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Hillf Danton wrote:
>> On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>> > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> > +struct page *grab_cache_huge_page_write_begin(struct address_space *mapping,
>> > +                       pgoff_t index, unsigned flags);
>> > +#else
>> > +static inline struct page *grab_cache_huge_page_write_begin(
>> > +               struct address_space *mapping, pgoff_t index, unsigned flags)
>> > +{
>> build bug?
>
> Hm?. No. Why?
>
Stop build if THP not configured?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
