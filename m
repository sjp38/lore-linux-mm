Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 967776B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 15:32:48 -0400 (EDT)
Message-ID: <519BCBDE.2050504@intel.com>
Date: Tue, 21 May 2013 12:32:46 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCHv4 10/39] thp: account anon transparent huge pages into
 NR_ANON_PAGES
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-11-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> We use NR_ANON_PAGES as base for reporting AnonPages to user.
> There's not much sense in not accounting transparent huge pages there, but
> add them on printing to user.
> 
> Let's account transparent huge pages in NR_ANON_PAGES in the first place.

This is another one that needs to be pretty carefully considered
_independently_ of the rest of this set.  It also has potential
user-visible changes, so it would be nice to have a blurb in the patch
description if you've thought about this, any why you think it's OK.

But, it still makes solid sense to me, and simplifies the code.

Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
