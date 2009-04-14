Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2267F5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 11:21:15 -0400 (EDT)
Date: Tue, 14 Apr 2009 17:21:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
Message-ID: <20090414152122.GA2299@random.random>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <200904150026.36142.nickpiggin@yahoo.com.au> <20090414143252.GE28265@random.random> <200904150042.15653.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200904150042.15653.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 15, 2009 at 12:42:14AM +1000, Nick Piggin wrote:
> to waste their time [..]

Me neither.

> If we get that far, then I can ask them to run tests definitely.

Agreed!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
