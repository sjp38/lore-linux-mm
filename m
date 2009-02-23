Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BAB426B00D4
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 13:01:37 -0500 (EST)
Date: Mon, 23 Feb 2009 18:01:35 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: clean up __GFP_* flags a bit
Message-ID: <20090223180134.GR6740@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-5-git-send-email-mel@csn.ul.ie> <1235390101.4645.79.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1235390101.4645.79.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 12:55:01PM +0100, Peter Zijlstra wrote:
> Subject: mm: clean up __GFP_* flags a bit
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Mon Feb 23 12:28:33 CET 2009
> 
> re-sort them and poke at some whitespace alignment for easier reading.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

It didn't apply because we are working off different trees. I was on
git-latest from last Wednesday and this looks to be -mm based on the presense
of CONFIG_KMEMCHECK. I rebased and ended up with the patch below. Thanks

====
