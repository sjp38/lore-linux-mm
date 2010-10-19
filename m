Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1618E6B0099
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 12:58:09 -0400 (EDT)
Date: Tue, 19 Oct 2010 18:24:07 +0200
From: Helmut Grohne <helmut@subdivi.de>
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
Message-ID: <20101019162407.GB10148@alf.mars>
References: <20101013144044.GS30667@csn.ul.ie>
 <20101013175205.21187.qmail@kosh.dhis.org>
 <20101018113331.GB30667@csn.ul.ie>
 <20101018123750.ef7d6d48.akpm@linux-foundation.org>
 <alpine.LFD.2.00.1010182342490.6815@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1010182342490.6815@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, pacman@kosh.dhis.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 18, 2010 at 11:55:44PM +0200, Thomas Gleixner wrote:
> I might be completely one off as usual, but this thing reminds me of a
> bug I stared at yesterday night:

This problem is completely unrelated. My problem was caused by using
binutils-gold.

Helmut

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
