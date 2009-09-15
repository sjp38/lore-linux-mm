Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D014B6B0055
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:17:27 -0400 (EDT)
Date: Tue, 15 Sep 2009 21:16:47 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 0/8] mm: around get_user_pages flags
In-Reply-To: <20090910093207.9CC6.A69D9226@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0909152115300.22199@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
 <20090908090009.0CC0.A69D9226@jp.fujitsu.com> <20090910093207.9CC6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 Sep 2009, KOSAKI Motohiro wrote:
> > 
> > Great!
> > I'll start to test this patch series. Thanks Hugh!!
> 
> At least, My 24H stress workload test didn't find any problem.
> I'll continue testing.

Thanks a lot for that: four more patches coming shortly,
but they shouldn't affect what you've found so far.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
