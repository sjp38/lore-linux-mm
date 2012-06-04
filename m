Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 84BAC6B005C
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 13:13:39 -0400 (EDT)
Date: Mon, 4 Jun 2012 13:13:28 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH v9] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
Message-ID: <20120604171328.GA23788@redhat.com>
References: <201206041543.56917.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201206041543.56917.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>

On Mon, Jun 04, 2012 at 03:43:56PM +0200, Bartlomiej Zolnierkiewicz wrote:
 > 
 > Dave, could you please test this version?
 > 
 > From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
 > Subject: [PATCH v9] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type pageblocks

Initial testing looks good.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
