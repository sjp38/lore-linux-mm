Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 6B0CC6B0027
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 15:07:09 -0400 (EDT)
Message-ID: <5163155D.7030401@sr71.net>
Date: Mon, 08 Apr 2013 12:07:09 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv3, RFC 32/34] thp: handle write-protect exception to file-backed
 huge pages
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com> <1365163198-29726-33-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-33-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

For all the do_huge_pmd_wp_page(), I think we need a better description
of where the code came from.  There are some more obviously
copy-n-pasted comments in there.

For the entire series, in the patch description, we need to know:
1. What was originally written and what was copied from elsewhere
2. For the stuff that was copied, was an attempt made to consolidate
   instead of copy?  Why was consolidation impossible or infeasible?

> +			if (!PageAnon(page)) {
> +				add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
> +				add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
> +			}

This seems like a bit of a hack.  Shouldn't we have just been accounting
to MM_FILEPAGES in the first place?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
