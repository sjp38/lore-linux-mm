Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CBE196B004F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:13:55 -0400 (EDT)
Date: Tue, 21 Apr 2009 16:13:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/25] Calculate the cold parameter for allocation only
	once
Message-ID: <20090421151355.GA29083@csn.ul.ie>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie> <1237543392-11797-12-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903201109250.3740@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903201109250.3740@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 20, 2009 at 11:09:40AM -0400, Christoph Lameter wrote:
> 
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> 

I apologise, I've it added now. While the patch is currently dropped from the
set, I'll bring it back later for further discussion when it can be
established if it really helps or not.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
