Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 77FB86B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 07:12:58 -0400 (EDT)
Date: Fri, 7 Aug 2009 12:13:01 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/6] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090807111300.GE18134@csn.ul.ie>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie> <1249574827-18745-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.00.0908061358250.13451@mail.selltech.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0908061358250.13451@mail.selltech.ca>
Sender: owner-linux-mm@kvack.org
To: "Li, Ming Chun" <macli@brc.ubc.ca>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 06, 2009 at 02:07:33PM -0700, Li, Ming Chun wrote:
> On Thu, 6 Aug 2009, Mel Gorman wrote:
> 
> Code style nitpick, There are four trailing whitespace errors while 
> applying this script patch, use ./scripts/checkpatch.pl would tell which 
> lines have trailing whitespace.
> 

Fixed now. I had been ignoring the checkpatch output to some extent as
it were so many warnings about the formatting. It was one of those
cases where it looked better without checkpatch but that's no excuse for
the whitespace :)

Thanks

> <SNIP>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
