Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 98F476B00DF
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:32:23 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAJd=RBDChGT0i_fsnqW7RvQkJhQaTv7k+=HNTzjx7Rg+6uTNPA@mail.gmail.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-35-git-send-email-kirill.shutemov@linux.intel.com>
 <CAJd=RBDChGT0i_fsnqW7RvQkJhQaTv7k+=HNTzjx7Rg+6uTNPA@mail.gmail.com>
Subject: Re: [PATCHv4 34/39] thp, mm: handle huge pages in filemap_fault()
Content-Transfer-Encoding: 7bit
Message-Id: <20130522153448.04D7DE0090@blue.fi.intel.com>
Date: Wed, 22 May 2013 18:34:47 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hillf Danton wrote:
> On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >
> > If caller asks for huge page (flags & FAULT_FLAG_TRANSHUGE),
> > filemap_fault() return it if there's a huge page already by the offset.
> >
> > If the area of page cache required to create huge is empty, we create a
> > new huge page and return it.
> >
> > Otherwise we return VM_FAULT_FALLBACK to indicate that fallback to small
> > pages is required.
> >
> s/small/regular/g ?

% git log --oneline -p -i --grep 'small.\?page' | wc -l
5962
% git log --oneline -p -i --grep 'regular.\?page' | wc -l
3623

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
