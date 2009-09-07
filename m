Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 69E696B00C4
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 19:51:25 -0400 (EDT)
Date: Mon, 7 Sep 2009 16:51:26 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/8] mm: around get_user_pages flags
In-Reply-To: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
Message-ID: <alpine.LFD.2.01.0909071648560.7458@localhost.localdomain>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Mon, 7 Sep 2009, Hugh Dickins wrote:
>
> Here's a series of mm mods against current mmotm: mostly cleanup
> of get_user_pages flags, but fixing munlock's OOM, sorting out the
> "FOLL_ANON optimization", and reinstating ZERO_PAGE along the way.

Ack on the whole series as far as I'm concerned. All looks very 
straightforward and sane.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
