Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 02EDA6B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 13:47:56 -0400 (EDT)
Date: Tue, 24 Mar 2009 10:56:24 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <200903250043.18069.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0903241056100.3032@localhost.localdomain>
References: <200903170323.45917.nickpiggin@yahoo.com.au> <20090318105735.BD17.A69D9226@jp.fujitsu.com> <20090322205249.6801.A69D9226@jp.fujitsu.com> <200903250043.18069.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Wed, 25 Mar 2009, Nick Piggin wrote:
> 
> I still don't understand why this way is so much better than
> my last proposal.

Take a look at the diffstat.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
