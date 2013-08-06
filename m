Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id D68C56B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 16:56:38 -0400 (EDT)
Date: Tue, 6 Aug 2013 23:57:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 19/23] truncate: support huge pages
Message-ID: <20130806205716.GA4031@shutemov.name>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-20-git-send-email-kirill.shutemov@linux.intel.com>
 <52015B54.5010605@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52015B54.5010605@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 06, 2013 at 01:23:48PM -0700, Dave Hansen wrote:
> On 08/03/2013 07:17 PM, Kirill A. Shutemov wrote:
> > +			if (PageTransTailCache(page)) {
> > +				/* part of already handled huge page */
> > +				if (!page->mapping)
> > +					continue;
> > +				/* the range starts in middle of huge page */
> > +				partial_thp_start = true;
> > +				start = index & ~HPAGE_CACHE_INDEX_MASK;
> > +				continue;
> > +			}
> > +			/* the range ends on huge page */
> > +			if (PageTransHugeCache(page) &&
> > +				index == (end & ~HPAGE_CACHE_INDEX_MASK)) {
> > +				partial_thp_end = true;
> > +				end = index;
> > +				break;
> > +			}
> 
> Still reading through the code, but that "index ==" line's indentation
> is screwed up.  It makes it look like "index == " is a line of code
> instead of part of the if() condition.

I screwed it up myself. Otherwise, the line is too long. :-/

Probably, I should move partial page logic into separate function.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
