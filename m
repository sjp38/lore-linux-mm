Date: Thu, 20 Dec 2007 15:37:28 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] fix page_alloc for larger I/O segments (improved)
Message-ID: <20071220223728.GM29690@parisc-linux.org>
References: <20071213142935.47ff19d9.akpm@linux-foundation.org> <4761B32A.3070201@rtr.ca> <4761BCB4.1060601@rtr.ca> <4761C8E4.2010900@rtr.ca> <4761CE88.9070406@rtr.ca> <20071213163726.3bb601fa.akpm@linux-foundation.org> <4761D160.7060603@rtr.ca> <4761D279.6050500@rtr.ca> <20071214174236.GA28613@csn.ul.ie> <20071214181339.GW26334@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071214181339.GW26334@parisc-linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Mark Lord <liml@rtr.ca>, Andrew Morton <akpm@linux-foundation.org>, James.Bottomley@HansenPartnership.com, jens.axboe@oracle.com, lkml@rtr.ca, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 14, 2007 at 11:13:40AM -0700, Matthew Wilcox wrote:
> I'll send it to our DB team to see if this improves our numbers at all.

It does, by approximately 0.67%.  This is about double the margin of
error, and a significant improvement.  Thanks!

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
