Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8E0566B004D
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 00:02:07 -0400 (EDT)
From: Al Boldi <a1426z@gawab.com>
Subject: Re: compcache as a pre-swap area (was: [PATCH] swap: send callback  when swap slot is freed)
Date: Fri, 14 Aug 2009 07:02:23 +0300
References: <200908122007.43522.ngupta@vflare.org> <200908130805.36787.a1426z@gawab.com> <d760cf2d0908131031i2305f2deqe20d6a96c8d568af@mail.gmail.com>
In-Reply-To: <d760cf2d0908131031i2305f2deqe20d6a96c8d568af@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200908140702.23947.a1426z@gawab.com>
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matthew Wilcox <willy@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nitin Gupta wrote:
> compcache is really not really a swap replacement. Its just another
> swap device that
> compresses data and stores it in memory itself. You can have disk
> based swaps along
> with ramzswap (name of block device).

So once compcache fills up, it will start to age its contents into normal 
swap?


Thanks!

--
Al

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
