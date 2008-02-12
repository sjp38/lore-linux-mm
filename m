From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 0/3] Hotcold removal completion
Date: Tue, 12 Feb 2008 17:32:29 +1100
References: <20080212003643.536643832@sgi.com>
In-Reply-To: <20080212003643.536643832@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802121732.29593.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tuesday 12 February 2008 11:36, Christoph Lameter wrote:
> The patch that we had in mm for the removal of the cold page queue was
> merged.

That patch to merge the hot and cold lists has obvious problems.
It pulls cold pages off the list in the opposite order that hot
pages come off the list (which is obviously bad); and also it
allows cold allocations to deplete hot pages (which may not be a
good idea).

Obviously the half baked code that's there now should be fixed...
But whether it is to fix hot/cold properly, or to remove it
completely, I don't really know.


> However, there were 3 more pages that I think are necessary to 
> complete the work. Mel's testing indicated that the patch in mm is inferior
> to simply removing the hot cold distinction in the VM altogether
> (see http://marc.info/?t=119507025400001&r=1&w=2).
>
> These 3 patches get rid of cold page handling in the VM.

I'm all in favour of removing these. But honestly, I don't think
kernbench, [td]bench, and aim9 are really great tests when it
comes to subtle cache behaviour... OTOH, that didn't stop the
last patch being merged. May as well do it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
