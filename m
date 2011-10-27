Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3BDFF6B002D
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 10:29:14 -0400 (EDT)
Date: Thu, 27 Oct 2011 16:29:08 +0200
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] cache align vm_stat
Message-ID: <20111027142858.GB6563@csn.ul.ie>
References: <20111027085008.GA6563@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111027085008.GA6563@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@gentwo.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>

On Thu, Oct 27, 2011 at 10:50:25AM +0200, Mel Gorman wrote:
> On Mon, Oct 24, 2011 at 11:10:35AM -0500, Dimitri Sivanich wrote:
> > Avoid false sharing of the vm_stat array.
> > 
> > This was found to adversely affect tmpfs I/O performance.
> > 
> 
> I think this fix is overly simplistic.

In a lesson on why I should not even try reviewing while attending
conferences, I totally misread what the patch is doing. It's aligning
the array to avoid false sharing with other global data, not aligning
each element. This is reasonable.

Acked-by: Mel Gorman <mel@csn.ul.ie>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
