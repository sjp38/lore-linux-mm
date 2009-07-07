Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9B36B005D
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 04:05:32 -0400 (EDT)
Date: Tue, 7 Jul 2009 10:48:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] fs: new truncate sequence
Message-ID: <20090707084841.GY2714@wotan.suse.de>
References: <20090706165438.GQ2714@wotan.suse.de> <20090706172241.GA26042@infradead.org> <20090706174700.GT2714@wotan.suse.de> <1246951751.8143.104.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1246951751.8143.104.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 09:29:11AM +0200, Peter Zijlstra wrote:
> On Mon, 2009-07-06 at 19:47 +0200, Nick Piggin wrote:
> > All good points. I don't know what name to use though -- your idea
> > of renaming ->truncate then reusing it is nice but people will cry
> > about breaking external modules. I'll call it ->setsize and defer
> > having to think about it for now.
> 
> Changing the function signature should get them a compiler warning,
> aside from that I don't think we should really consider their feelings
> anyway ;-)

Well I don't much, but some people do. Anyway I think ->setsize is
actually quite a good name on 2nd thoughts ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
