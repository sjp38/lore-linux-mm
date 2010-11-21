Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 744B56B0087
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 11:35:04 -0500 (EST)
Received: by qwi2 with SMTP id 2so1646420qwi.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 08:35:02 -0800 (PST)
From: Ben Gamari <bgamari@gmail.com>
Subject: Re: [RFC 2/2] Prevent promotion of page in madvise_dontneed
In-Reply-To: <5d205f8a4df078b0da3681063bbf37382b02dd23.1290349672.git.minchan.kim@gmail.com>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com> <5d205f8a4df078b0da3681063bbf37382b02dd23.1290349672.git.minchan.kim@gmail.com>
Date: Sun, 21 Nov 2010 11:34:57 -0500
Message-ID: <87tyjavdn2.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Sun, 21 Nov 2010 23:30:24 +0900, Minchan Kim <minchan.kim@gmail.com> wrote:
> Now zap_pte_range alwayas promotes pages which are pte_young &&
> !VM_SequentialReadHint(vma). But in case of calling MADV_DONTNEED,
> it's unnecessary since the page wouldn't use any more.
> 
Is this not against master? If it is, I think you might have forgotten
to update the zap_page_range() reference on mm/memory.c:1226 (in
zap_vma_ptes()). Should promote be true or false in this case? Cheers,

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
