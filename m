Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 195386B0055
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 11:47:51 -0400 (EDT)
Date: Sat, 1 Aug 2009 11:52:27 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] Dirty page tracking & on-the-fly memory mirroring
Message-ID: <20090801155227.GB10888@infradead.org>
References: <4A7393D9.50807@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A7393D9.50807@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Jim Paradis <jparadis@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 31, 2009 at 09:01:13PM -0400, Jim Paradis wrote:
>
> This patch is a reference implementation of a memory-mirroring module
> ("pagesync").  It is the same code that Stratus uses minus some
> hardware-specific bits.  This module scans through physical memory,
> clearing the hardware dirty bit of any dirty page and setting the
> software dirty bit.  If a dirty page has the *hardware* dirty bit
> set on a subsequent scan, we know that the page has been re-dirtied
> and it is a candidate for being copied again.

As mentioned in the prevois mail example code is uttely useless.  Please
post the real code for the stratus hardware, and also make in built-in
instead of opening big holes for external propritary modules.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
