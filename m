Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADFD6B00A4
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 04:47:53 -0400 (EDT)
Date: Fri, 28 Aug 2009 09:47:58 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3] Reduce searching in the page allocator fast-path
Message-ID: <20090828084758.GA5054@csn.ul.ie>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1251449067-3109-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 28, 2009 at 09:44:25AM +0100, Mel Gorman wrote:
> The following two patches remove searching in the page allocator fast-path

Gack, and of course the subject should have been PATCH 0/2

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
