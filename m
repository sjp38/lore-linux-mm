Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1023D6B005D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:23:08 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F3E5B82C538
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:37:29 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8DRsEzmo8zpF for <linux-mm@kvack.org>;
	Wed, 27 May 2009 10:37:29 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 48F5182C53C
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:37:25 -0400 (EDT)
Date: Wed, 27 May 2009 10:23:16 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Use integer fields lookup for gfp_zone and check for
 errors in flags passed to the page allocator
In-Reply-To: <20090527094857.GA633@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0905271022020.27671@gentwo.org>
References: <alpine.DEB.1.10.0905221438120.5515@qirst.com> <20090525113004.GD12160@csn.ul.ie> <alpine.DEB.1.10.0905261401100.5632@gentwo.org> <20090526232620.GA6189@csn.ul.ie> <20090527094857.GA633@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, npiggin@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 27 May 2009, Mel Gorman wrote:

> I'm happier with this now. After the tests and another read through the
> patch, nothing else jumps out at me.
>
> Reviewed-by: Mel Gorman <mel@csn.ul.ie>
>
> Good work.

It would not have been possible without your help and the testing you did.
Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
