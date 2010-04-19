Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 117536B01F1
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 14:32:00 -0400 (EDT)
Date: Mon, 19 Apr 2010 11:19:49 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge
 regression in performance
Message-ID: <20100419181949.GC32347@kroah.com>
References: <20100323173409.GA24845@elte.hu>
 <alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org>
 <9D040E9A-80F2-468F-A6CD-A4912615CD3F@gmail.com>
 <alpine.LFD.2.00.1003231253570.18017@i5.linux-foundation.org>
 <9FC34DA1-D6DD-41E5-8B76-0712A813C549@gmail.com>
 <alpine.LFD.2.00.1003231602130.18017@i5.linux-foundation.org>
 <20100323233640.GA16798@elte.hu>
 <alpine.LFD.2.00.1003231653260.18017@i5.linux-foundation.org>
 <871vfah3db.fsf@basil.nowhere.org>
 <alpine.LFD.2.00.1003231957420.18017@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1003231957420.18017@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Anton Starikov <ant.starikov@gmail.com>, stable@kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 23, 2010 at 08:00:54PM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 24 Mar 2010, Andi Kleen wrote:
> > 
> > It would be also nice to get that change into 2.6.32 stable. That is
> > widely used on larger systems.
> 
> Looking at the changes to the files in question, it looks like it should 
> all apply cleanly to 2.6.32, so I don't see any reason not to backport 
> further back.
> 
> Somebody should double-check, though.

I have queued them all up for .33 and .32-stable kernel releases now.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
