Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 000076B00C3
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:51:58 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 21B3182C333
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:56:25 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wkYQ0qEf01RD for <linux-mm@kvack.org>;
	Mon, 23 Feb 2009 10:56:25 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8523B82C31A
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:56:24 -0500 (EST)
Date: Mon, 23 Feb 2009 10:43:20 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 04/20] Convert gfp_zone() to use a table of precalculated
 value
In-Reply-To: <200902240241.48575.nickpiggin@yahoo.com.au>
Message-ID: <alpine.DEB.1.10.0902231042440.7790@qirst.com>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0902231003090.7298@qirst.com> <200902240241.48575.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Feb 2009, Nick Piggin wrote:

> > Are you sure that this is a benefit? Jumps are forward and pretty short
> > and the compiler is optimizing a branch away in the current code.
>
> Pretty easy to mispredict there, though, especially as you can tend
> to get allocations interleaved between kernel and movable (or simply
> if the branch predictor is cold there are a lot of branches on x86-64).
>
> I would be interested to know if there is a measured improvement. It
> adds an extra dcache line to the footprint, but OTOH the instructions
> you quote is more than one icache line, and presumably Mel's code will
> be a lot shorter.

Maybe we can come up with a version of gfp_zone that has no branches and
no lookup?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
