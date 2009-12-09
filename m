Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E240760021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 20:11:32 -0500 (EST)
Message-ID: <4B1EF8AB.6010806@ah.jp.nec.com>
Date: Wed, 09 Dec 2009 10:08:59 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reply-To: n-horiguchi@ah.jp.nec.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] mm hugetlb x86: add hugepage support to pagemap
References: <4B1CB5D6.9080007@ah.jp.nec.com> <20091208143928.f3aa0ad2.akpm@linux-foundation.org>
In-Reply-To: <20091208143928.f3aa0ad2.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, hugh.dickins@tiscali.co.uk, ak@linux.intel.com, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> I kind of dislike the practice of putting all the changelog in patch
> [0/n] and then leaving the patches themselves practically
> unchangelogged.  Because

Sorry, I agree.

> 
> a) Someone (ie: me) needs to go and shuffle all the text around so
>    that the information gets itself into the git record.  We don't add
>    changelog-only commits to git!
> 
> b) Someone (ie: me) might decide to backport a subset of the patches
>    into -stable.  Now someone (ie: me) needs to carve up the changelogs
>    so that the pieces which go into -stable still make standalone sense.
> 
> I'm not sure that I did this particularly well in this case.  Oh well.
> 
> 
> Please confirm that
> mm-hugetlb-fix-hugepage-memory-leak-in-walk_page_range.patch is
> suitable for a -stable backport without inclusion of
> mm-hugetlb-add-hugepage-support-to-pagemap.patch.  I think it is.
> 

I think that's OK.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
