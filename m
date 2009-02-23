Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 47E0F6B00CC
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 11:41:42 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B769382C32D
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 11:46:13 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FC1jrfTYSYrL for <linux-mm@kvack.org>;
	Mon, 23 Feb 2009 11:46:13 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 05B0A82C2A0
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 11:46:09 -0500 (EST)
Date: Mon, 23 Feb 2009 11:33:00 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 04/20] Convert gfp_zone() to use a table of precalculated
 value
In-Reply-To: <20090223163322.GN6740@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0902231130280.3333@qirst.com>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0902231003090.7298@qirst.com> <20090223163322.GN6740@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Feb 2009, Mel Gorman wrote:

> I was concerned with mispredictions here rather than the actual assembly
> and gfp_zone is inlined so it's lot of branches introduced in a lot of paths.

The amount of speculation that can be done by the processor pretty
limited to a few instructions. So the impact of a misprediction also
should be minimal. The decoder is likely to have sucked in the following
code anyways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
