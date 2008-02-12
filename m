Message-Id: <20080212003643.536643832@sgi.com>
Date: Mon, 11 Feb 2008 16:36:43 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 0/3] Hotcold removal completion
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The patch that we had in mm for the removal of the cold page queue was merged.
However, there were 3 more pages that I think are necessary to complete
the work. Mel's testing indicated that the patch in mm is inferior to simply
removing the hot cold distinction in the VM altogether
(see http://marc.info/?t=119507025400001&r=1&w=2).

These 3 patches get rid of cold page handling in the VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
