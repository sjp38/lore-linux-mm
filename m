Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DCB186B0092
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 02:46:29 -0400 (EDT)
Subject: Re: [rfc][patch 1/3] fs: new truncate sequence
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090706174700.GT2714@wotan.suse.de>
References: <20090706165438.GQ2714@wotan.suse.de>
	 <20090706172241.GA26042@infradead.org>
	 <20090706174700.GT2714@wotan.suse.de>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Tue, 07 Jul 2009 09:29:11 +0200
Message-Id: <1246951751.8143.104.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-07-06 at 19:47 +0200, Nick Piggin wrote:
> All good points. I don't know what name to use though -- your idea
> of renaming ->truncate then reusing it is nice but people will cry
> about breaking external modules. I'll call it ->setsize and defer
> having to think about it for now.

Changing the function signature should get them a compiler warning,
aside from that I don't think we should really consider their feelings
anyway ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
