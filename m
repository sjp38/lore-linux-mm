Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D485A6B0088
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 06:21:14 -0400 (EDT)
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090922100540.GD12254@csn.ul.ie>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
	 <20090921174656.GS12726@csn.ul.ie>
	 <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1>
	 <20090921180739.GT12726@csn.ul.ie>
	 <alpine.DEB.1.10.0909211412050.3106@V090114053VZO-1>
	 <20090922100540.GD12254@csn.ul.ie>
Date: Tue, 22 Sep 2009 13:21:15 +0300
Message-Id: <1253614875.30406.12.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Tue, 2009-09-22 at 11:05 +0100, Mel Gorman wrote:
> I'm going to punt the decision on this one to Pekka or Nick. My feeling
> is leave it enabled for NUMA so it can be identified if it gets fixed
> for some other reason - e.g. the stalls are due to a per-cpu problem as
> stated by Sachin and SLQB happens to exasperate the problem.

Can I have a tested patch that uses MAX_NUMNODES to allocate the
structs, please? We can convert SLQB over to per-cpu allocator if the
memoryless node issue is resolved.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
