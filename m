Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 69E4D6B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 23:37:06 -0400 (EDT)
Date: Wed, 1 Sep 2010 13:32:37 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 00/10] zram: various improvements and cleanups
Message-ID: <20100901033237.GA18958@kryten>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1281374816-904-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Hi Nitin,

I gave zram a try on a ppc64 box with a 64kB PAGE_SIZE. It looks like the
xvmalloc allocator fails when we add in a large enough block (in this case
65532 bytes).

flindex ends up as 127 which is larger than BITS_PER_LONG. We continually call
grow_block inside find_block and fail:

zram: Error allocating memory for compressed page: 0, size=467

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
