Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id E828B6B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 19:42:22 -0500 (EST)
Date: Wed, 30 Jan 2013 16:42:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: use long type for page counts in mm_populate()
 and get_user_pages()
Message-Id: <20130130164220.eaebcb6a.akpm@linux-foundation.org>
In-Reply-To: <1359591980-29542-2-git-send-email-walken@google.com>
References: <1359591980-29542-1-git-send-email-walken@google.com>
	<1359591980-29542-2-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 30 Jan 2013 16:26:18 -0800
Michel Lespinasse <walken@google.com> wrote:

> Use long type for page counts in mm_populate() so as to avoid integer
> overflow

Would prefer to use unsigned long if we're churning this code.  A "page
count" can never be negative and we avoid the various possible
overflow/signedness issues.

However get_user_pages() and follow_hugetlb_page() return "page count
or -ve errno", so we're somewhat screwed there.  And that's the bulk of
the patch :(

btw, what twit merged a follow_hugetlb_page() which takes an
undocumented argument called "i".  Sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
