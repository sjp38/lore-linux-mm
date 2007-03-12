From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/3] Lumpy Reclaim V5
Message-ID: <exportbomb.1173723760@pinky>
Date: Mon, 12 Mar 2007 18:22:45 +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Following this email are three patches which represent the
current state of the lumpy reclaim patches; collectively lumpy V5.
This patch kit is against 2.6.21-rc3-mm2.  This stack is split out
to show the incremental changes in this version.  This contains
one fixup following on from Christoph Lameters feedback and one change
affecting scan rates.  Andrew, please consider for -mm.

Comparitive testing between lumpy-V4 and lump-V5 generally shows
a small improvement, coming from the slight increase in scanning
coming from second of the patches.

I have taken the lumpy-V3 patches and the last batch of changes
and folded them back into a single patch (collectively lumpy-V4),
updating attribution.  On top of this are are two patches the first
the result of feedback from Christoph and the latter a change which
I believe is a correctness issue for scanning rates:

lumpy-reclaim-V4: folded back base, changes incorporated are listed
  in the changelog which is included in the patch.

lumpy-back-out-removal-of-active-check-in-isolate_lru_pages:
  reinstating a BUG where the active state missmatched the lru we are
  scanning.  As pointed out by Christoph Lameter, there should not
  be a missmatch and testing confirms with this base there are none.

lumpy-only-count-taken-pages-as-scanned: when scanning an area
  around a target page taken from the LRU we will only take pages
  which match the active state.  Previously we would count the
  missmatching pages passed over as 'scanned'.  Prior to lumpy a
  page was only counted as 'scanned' if we had removed it from the
  LRU and reclaimed or rotated it back to the list.  This leads
  to reduced reclaim scanning and affects reclaim performance.
  Move to counting pages as scanned only when actually touched.

Against: 2.6.21-rc3-mm2

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
