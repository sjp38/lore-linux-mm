Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0B22F6B00FE
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:01:38 -0400 (EDT)
Date: Wed, 13 May 2009 15:01:28 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: do we really want to export more pdflush details in sysctls
Message-ID: <20090513130128.GA10382@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Peter W Morreale <pmorreale@novell.com>, torvalds@osdl.org, jens.axboe@oracle.com, akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi all,

commit fafd688e4c0c34da0f3de909881117d374e4c7af titled
"mm: add /proc controls for pdflush threads" adds two more sysctl
variables exposing details about pdflush threads.  At the same time
Jens Axboe is working on the per-bdi writeback patchset which will
hopefull soon get rid of the pdflush threads in their current form.

Is it really a good idea to expose more details now or should we revert
this patch before 2.6.30 is out?

Cheers,
	Christoph

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
