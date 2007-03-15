Date: Thu, 15 Mar 2007 12:52:37 +0100
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [patch 1/2] splice: dont steal
Message-ID: <20070315115237.GM15400@kernel.dk>
References: <20070314121440.GA926@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070314121440.GA926@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 14 2007, Nick Piggin wrote:
> Here are a couple of splice patches I found when digging in the area.
> I could be wrong, so I'd appreciate confirmation.
> 
> Untested other than compile, because I don't have a good splice test
> setup.
> 
> Considering these are data corruption / information leak issues, then
> we could do worse than to merge them in 2.6.21 and earlier stable
> trees.
> 
> Does anyone really use splice stealing?

That's a damn shame, I'd greatly prefer if we can try and fix it
instead. Splice isn't really all that used yet to my knowledge, but
stealing is one of the niftier features I think. Otherwise you're just
copying data again.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
