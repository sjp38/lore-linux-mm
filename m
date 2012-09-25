Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 606B26B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 03:34:43 -0400 (EDT)
Date: Tue, 25 Sep 2012 16:37:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 7/9] Revert "mm: have order > 0 compaction start off
 where it left"
Message-ID: <20120925073747.GO13234@bbox>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
 <1348224383-1499-8-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348224383-1499-8-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 21, 2012 at 11:46:21AM +0100, Mel Gorman wrote:
> This reverts commit 7db8889a (mm: have order > 0 compaction start off
> where it left) and commit de74f1cc (mm: have order > 0 compaction start
> near a pageblock with free pages). These patches were a good idea and
> tests confirmed that they massively reduced the amount of scanning but
> the implementation is complex and tricky to understand. A later patch
> will cache what pageblocks should be skipped and reimplements the
> concept of compact_cached_free_pfn on top for both migration and
> free scanners.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
