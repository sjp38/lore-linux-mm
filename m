Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BE6C06B0087
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 09:38:21 -0500 (EST)
Received: by pzk30 with SMTP id 30so1274196pzk.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 06:38:20 -0800 (PST)
Date: Sun, 21 Nov 2010 23:38:12 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC 2/2] Prevent promotion of page in madvise_dontneed
Message-ID: <20101121143812.GA13857@barrios-desktop>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
 <5d205f8a4df078b0da3681063bbf37382b02dd23.1290349672.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5d205f8a4df078b0da3681063bbf37382b02dd23.1290349672.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 21, 2010 at 11:30:24PM +0900, Minchan Kim wrote:
> If the page is sharred by other processes and it's real working set

Please ignore this last sentense. It's my mistake. I will fix it v2 after
some review. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
