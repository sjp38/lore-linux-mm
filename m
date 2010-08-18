Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B2E4D6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:19:05 -0400 (EDT)
Received: by pzk33 with SMTP id 33so307875pzk.14
        for <linux-mm@kvack.org>; Wed, 18 Aug 2010 08:19:04 -0700 (PDT)
Date: Thu, 19 Aug 2010 00:18:57 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: android-kernel memory reclaim x20 boost?
Message-ID: <20100818151857.GA6188@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, swetland@google.com
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Android forks,

I could have a question in android kernel mailing list.
But I think many mm guys in linux-mm also might have a interest in it. 
So I send a question in linux-mm mailing list.

I saw the advertisement phrase in this[1]. 

"Kernel Memory Management Boost: Improved memory reclaim by up to 20x, 
which results in faster app switching and smoother performance 
on memory-constrained devices."

But I can't find any code for it in android kernel git tree.
If it's your private patch, could you explan what kinds of feature can enhance 
it by up to 20x?

If it is really good, we can merge it to mainline. 

[1] http://developer.android.com/sdk/android-2.2-highlights.html

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
