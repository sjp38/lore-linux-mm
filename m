Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id EF5A06B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 09:25:37 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAJd=RBA-CRVu2is9=9E1Y0=HFRHs1TXvFvm2wF7gT+=ujQ+8tg@mail.gmail.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-15-git-send-email-kirill.shutemov@linux.intel.com>
 <CAJd=RBA-CRVu2is9=9E1Y0=HFRHs1TXvFvm2wF7gT+=ujQ+8tg@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 14/30] thp, mm: naive support of thp in generic
 read/write routines
Content-Transfer-Encoding: 7bit
Message-Id: <20130315132716.AF225E0085@blue.fi.intel.com>
Date: Fri, 15 Mar 2013 15:27:16 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hillf Danton wrote:
> On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > +               if (PageTransTail(page)) {
> > +                       page_cache_release(page);
> > +                       page = find_get_page(mapping,
> > +                                       index & ~HPAGE_CACHE_INDEX_MASK);
> check page is valid, please.

Good catch. Fixed.

> > +                       if (!PageTransHuge(page)) {
> > +                               page_cache_release(page);
> > +                               goto find_page;
> > +                       }
> > +               }

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
