Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 91BAA6B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 10:47:17 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <51631CC0.5010908@sr71.net>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1365163198-29726-10-git-send-email-kirill.shutemov@linux.intel.com>
 <51631CC0.5010908@sr71.net>
Subject: Re: [PATCHv3, RFC 09/34] thp: represent file thp pages in meminfo and
 friends
Content-Transfer-Encoding: 7bit
Message-Id: <20130416144917.8FEAEE0085@blue.fi.intel.com>
Date: Tue, 16 Apr 2013 17:49:17 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 04/05/2013 04:59 AM, Kirill A. Shutemov wrote:
> > The patch adds new zone stat to count file transparent huge pages and
> > adjust related places.
> > 
> > For now we don't count mapped or dirty file thp pages separately.
> 
> I can understand tracking NR_FILE_TRANSPARENT_HUGEPAGES itself.  But,
> why not also account for them in NR_FILE_PAGES?  That way, you don't
> have to special-case each of the cases below:

Good point.
To be consistent I'll also convert NR_ANON_TRANSPARENT_HUGEPAGES to be
accounted in NR_ANON_PAGES.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
