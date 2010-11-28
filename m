Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 520146B0085
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 10:13:27 -0500 (EST)
Received: by iwn38 with SMTP id 38so3386513iwn.14
        for <linux-mm@kvack.org>; Sun, 28 Nov 2010 07:13:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
Date: Mon, 29 Nov 2010 00:13:24 +0900
Message-ID: <AANLkTikW+WG09KetDPG9DgT5CRBkm1tqQ+tUTHjLu4N6@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] deactivate invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch is add-on patch of mmotm-11-23.
Please, read original patch and thread.

http://marc.info/?l=linux-kernel&m=129034986927826&w=3

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
