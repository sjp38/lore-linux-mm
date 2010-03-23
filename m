Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E4C0D6B01B6
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 20:01:20 -0400 (EDT)
Date: Tue, 23 Mar 2010 16:55:42 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge regression
 in performance
In-Reply-To: <20100323233640.GA16798@elte.hu>
Message-ID: <alpine.LFD.2.00.1003231653260.18017@i5.linux-foundation.org>
References: <bug-15618-10286@https.bugzilla.kernel.org/> <20100323102208.512c16cc.akpm@linux-foundation.org> <20100323173409.GA24845@elte.hu> <alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org> <9D040E9A-80F2-468F-A6CD-A4912615CD3F@gmail.com>
 <alpine.LFD.2.00.1003231253570.18017@i5.linux-foundation.org> <9FC34DA1-D6DD-41E5-8B76-0712A813C549@gmail.com> <alpine.LFD.2.00.1003231602130.18017@i5.linux-foundation.org> <20100323233640.GA16798@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Anton Starikov <ant.starikov@gmail.com>, Greg KH <greg@kroah.com>, stable@kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>



On Wed, 24 Mar 2010, Ingo Molnar wrote:
> 
> We havent had any stability problems with them, except one trivial build bug, 
> so -stable would be nice.

Oh, you're right. There was that UML build bug. But I think that was 
included in the list of commits Anton had - commit 4126faf0ab ("x86: Fix 
breakage of UML from the changes in the rwsem system").

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
