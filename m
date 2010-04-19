Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBE36B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 23:09:57 -0400 (EDT)
Date: Sun, 18 Apr 2010 23:08:51 -0400
From: tytso@mit.edu
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100419030851.GA6344@thunk.org>
References: <20100414155233.D153.A69D9226@jp.fujitsu.com>
 <20100414072830.GK2493@dastard>
 <20100414085132.GJ25756@csn.ul.ie>
 <20100415013436.GO2493@dastard>
 <20100415102837.GB10966@csn.ul.ie>
 <20100416041412.GY2493@dastard>
 <20100416151403.GM19264@csn.ul.ie>
 <20100417203239.dda79e88.akpm@linux-foundation.org>
 <op.vbdgq3hhrwwil4@sfaibish1.corp.emc.com>
 <1271626236.27350.70.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1271626236.27350.70.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@suse.de>
Cc: Sorin Faibish <sfaibish@emc.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 18, 2010 at 04:30:36PM -0500, James Bottomley wrote:
> > I for one am looking very seriously at this problem together with Bruce.
> > We plan to have a discussion on this topic at the next LSF meeting
> > in Boston.
> 
> As luck would have it, the Memory Management summit is co-located with
> the Storage and Filesystem workshop ... how about just planning to lock
> all the protagonists in a room if it's not solved by August.  The less
> extreme might even like to propose topics for the plenary sessions ...

I'd personally hope that this is solved long before the LSF/VM
workshops.... but if not, yes, we should definitely tackle it then.

      	     	       	  	 	    	   - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
