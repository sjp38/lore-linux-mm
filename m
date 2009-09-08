Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C05606B0082
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 18:23:36 -0400 (EDT)
Message-ID: <4AA6D968.6000009@redhat.com>
Date: Tue, 08 Sep 2009 18:23:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/8] mm: fix anonymous dirtying
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <Pine.LNX.4.64.0909072237190.15430@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909072237190.15430@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> do_anonymous_page() has been wrong to dirty the pte regardless.
> If it's not going to mark the pte writable, then it won't help
> to mark it dirty here, and clogs up memory with pages which will
> need swap instead of being thrown away.  Especially wrong if no
> overcommit is chosen, and this vma is not yet VM_ACCOUNTed -
> we could exceed the limit and OOM despite no overcommit.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: stable@kernel.org

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
