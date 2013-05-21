Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 4A4C96B008A
	for <linux-mm@kvack.org>; Tue, 21 May 2013 19:20:16 -0400 (EDT)
Message-ID: <519C012D.7070006@sr71.net>
Date: Tue, 21 May 2013 16:20:13 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 27/39] x86-64, mm: proper alignment mappings with hugepages
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-28-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-28-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> Make arch_get_unmapped_area() return unmapped area aligned to HPAGE_MASK
> if the file mapping can have huge pages.

OK, so there are at least four phases of this patch set which are
distinct to me.

1. Prep work that can go upstream now
2. Making the page cache able to hold compound pages
3. Making thp-cache work with ramfs
4. Making mmap() work with thp-cache

(1) needs to go upstream now.

(2) and (3) are related and should go upstream together.  There should
be enough performance benefits from this alone to let them get merged.

(4) has lot of the code complexity, and is certainly required...
eventually.  I think you should stop for the _moment_ posting things in
this category and wait until you get the other stuff merged.  Go ahead
and keep it in your git tree for toying around with, but don't try to
get it merged until parts 1-3 are in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
