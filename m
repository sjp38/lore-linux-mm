Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CF7216B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 17:37:35 -0400 (EDT)
Message-ID: <4A414B3E.9020000@redhat.com>
Date: Tue, 23 Jun 2009 17:38:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't rely on flags coincidence
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain> <Pine.LNX.4.64.0906231349250.19552@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0906231349250.19552@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Indeed FOLL_WRITE matches FAULT_FLAG_WRITE, matches GUP_FLAGS_WRITE,
> and it's tempting to devise a set of Grand Unified Paging flags;
> but not today.  So until then, let's rely upon the compiler to spot
> the coincidence, "rather than have that subtle dependency and a
> comment for it" - as you remarked in another context yesterday.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Good catch.

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
