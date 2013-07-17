Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id EBC8A6B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 13:20:54 -0400 (EDT)
Date: Wed, 17 Jul 2013 19:20:47 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 10/10] mm: zone_reclaim: compaction: add compaction to
 zone_reclaim_mode
Message-ID: <20130717172047.GB6552@redhat.com>
References: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
 <1373982114-19774-11-git-send-email-aarcange@redhat.com>
 <51E653CB.6090808@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51E653CB.6090808@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hush Bensen <hush.bensen@gmail.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, Jul 17, 2013 at 04:20:27AM -0400, Hush Bensen wrote:
> These works should be done in slow path, does it mean fast path is not 
> faster any more?

The changes are in zone_reclaim(), I don't think zone_reclaim shall be
considered a fast path, that is intended to reclaim memory. The fast
path is when the free pages are above the low wmark and we don't need
to call zone_reclaim.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
