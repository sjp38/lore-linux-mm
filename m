Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2B59D6B005C
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:33:06 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3BCD882C6F6
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:43:56 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id g0mlCFTulvIk for <linux-mm@kvack.org>;
	Tue, 21 Apr 2009 11:43:51 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 85B0982C6F4
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:43:51 -0400 (EDT)
Date: Tue, 21 Apr 2009 11:25:34 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 11/25] Calculate the cold parameter for allocation only
 once
In-Reply-To: <20090421151355.GA29083@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0904211122540.21796@qirst.com>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie> <1237543392-11797-12-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903201109250.3740@qirst.com> <20090421151355.GA29083@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009, Mel Gorman wrote:

> On Fri, Mar 20, 2009 at 11:09:40AM -0400, Christoph Lameter wrote:
> >
> > Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> I apologise, I've it added now. While the patch is currently dropped from the
> set, I'll bring it back later for further discussion when it can be
> established if it really helps or not.

Sooo much self-doubt..... Could you post the not included patches at the
end of your patchsets so that others can help improve those?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
