Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 386DC6B00CE
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 04:38:27 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <514B4A9F.5090004@sr71.net>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-13-git-send-email-kirill.shutemov@linux.intel.com>
 <514B4A9F.5090004@sr71.net>
Subject: Re: [PATCHv2, RFC 12/30] thp, mm: add event counters for huge page
 alloc on write to a file
Content-Transfer-Encoding: 7bit
Message-Id: <20130326084012.CEF0AE0085@blue.fi.intel.com>
Date: Tue, 26 Mar 2013 10:40:12 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> > --- a/include/linux/vm_event_item.h
> > +++ b/include/linux/vm_event_item.h
> > @@ -71,6 +71,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> >  		THP_FAULT_FALLBACK,
> >  		THP_COLLAPSE_ALLOC,
> >  		THP_COLLAPSE_ALLOC_FAILED,
> > +		THP_WRITE_ALLOC,
> > +		THP_WRITE_FAILED,
> >  		THP_SPLIT,
> >  		THP_ZERO_PAGE_ALLOC,
> >  		THP_ZERO_PAGE_ALLOC_FAILED,
> 
> I think these names are a bit terse.  It's certainly not _writes_ that
> are failing and "THP_WRITE_FAILED" makes it sound that way.

Right. s/THP_WRITE_FAILED/THP_WRITE_ALLOC_FAILED/

> Also, why do we need to differentiate these from the existing anon-hugepage
> vm stats?  The alloc_pages() call seems to be doing the exact same thing in
> the end.  Is one more likely to succeed than the other?

Existing stats specify source of thp page: fault or collapse. When we
allocate a new huge page with write(2) it's nither fault nor collapse. I
think it's reasonable to introduce new type of event for that.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
