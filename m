Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AF8676B0012
	for <linux-mm@kvack.org>; Fri, 13 May 2011 07:24:35 -0400 (EDT)
Date: Fri, 13 May 2011 12:24:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] Reduce impact to overall system of SLUB using
 high-order allocations
Message-ID: <20110513112429.GF3569@suse.de>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
 <1305149960.2606.53.camel@mulgrave.site>
 <alpine.DEB.2.00.1105111527490.24003@chino.kir.corp.google.com>
 <1305153267.2606.57.camel@mulgrave.site>
 <20110512180457.GO11579@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110512180457.GO11579@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, May 12, 2011 at 08:04:57PM +0200, Andrea Arcangeli wrote:
> Hi James!
> 
> On Wed, May 11, 2011 at 05:34:27PM -0500, James Bottomley wrote:
> > Yes, but only once in all the testing.  With patches 1 and 2 the hang is
> 
> Weird patch 2 makes the large order allocation without ~__GFP_WAIT, so
> even COMPACTION=y/n shouldn't matter anymore. Am I misreading
> something Mel?
> 
> Removing ~__GFP_WAIT from patch 2 (and adding ~__GFP_REPEAT as a
> correctness improvement) and setting COMPACTION=y also should work ok.
> 


should_continue_reclaim could till be looping unless __GFP_REPEAT is
cleared if CONFIG_COMPACTION is set.

> Removing ~__GFP_WAIT from patch 2 and setting COMPACTION=n is expected
> not to work well.
> 
> But compaction should only make the difference if you remove
> ~__GFP_WAIT from patch 2.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
