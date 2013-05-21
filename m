Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B472D6B00A2
	for <linux-mm@kvack.org>; Tue, 21 May 2013 19:57:25 -0400 (EDT)
Message-ID: <519C09E3.30203@sr71.net>
Date: Tue, 21 May 2013 16:57:23 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 32/39] mm: cleanup __do_fault() implementation
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-33-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-33-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> Let's cleanup __do_fault() to prepare it for transparent huge pages
> support injection.
> 
> Cleanups:
>  - int -> bool where appropriate;
>  - unindent some code by reverting 'if' condition;
>  - extract !pte_same() path to get it clear;
>  - separate pte update from mm stats update;
>  - some comments reformated;

I've scanned through the rest of these patches.  They look OK, and I
don't have _too_ much to say.  They definitely need some closer review,
but I think you should concentrate your attention on the stuff _before_
this point in the series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
