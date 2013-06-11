Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 623956B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 12:04:11 -0400 (EDT)
Message-ID: <51B74A7A.1040707@sr71.net>
Date: Tue, 11 Jun 2013 09:04:10 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] thp, mm: avoid PageUnevictable on active/inactive
 lru lists
References: <1370964919-16187-1-git-send-email-kirill.shutemov@linux.intel.com> <1370964919-16187-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1370964919-16187-3-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 06/11/2013 08:35 AM, Kirill A. Shutemov wrote:
> active/inactive lru lists can contain unevicable pages (i.e. ramfs pages
> that have been placed on the LRU lists when first allocated), but these
> pages must not have PageUnevictable set - otherwise shrink_[in]active_list
> goes crazy:

I think it's also important here to note if this is a bug that can be
hit _currently_, or if this really is just a preparatory patch for
transparent huge page cache.

>From what I can see, this is _needed_ preparatory work, but it can also
stand on its own because it simplifies things.  It should go in sooner
rather than later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
