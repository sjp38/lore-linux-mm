Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A191D6B0071
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 07:15:07 -0500 (EST)
Date: Tue, 19 Jan 2010 07:15:05 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 2/2] xfs: use scalable vmap API
Message-ID: <20100119121505.GA9428@infradead.org>
References: <20081021082542.GA6974@wotan.suse.de> <20081021082735.GB6974@wotan.suse.de> <20081021120932.GB13348@infradead.org> <20081022093018.GD4359@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081022093018.GD4359@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

I've looked into retesting and re-enabling the swithc to your
scalabale vmap API (original commit 95f8e302c04c0b0c6de35ab399a5551605eeb006).

The good thing is that I can't reproduce the original regressions in
xfstests I've seen.  The bad news is that starting from the second
consequitive xfstests run we're not able to vmalloc the log buffers
anymore.  It seems the use of this API introduces some leak of vmalloc
space.  Any idea how to debug this further?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
