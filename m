Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D0AAC6B0092
	for <linux-mm@kvack.org>; Sun, 23 Jan 2011 22:56:49 -0500 (EST)
Subject: too big min_free_kbytes
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 24 Jan 2011 11:56:46 +0800
Message-ID: <1295841406.1949.953.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, aarcange@redhat.com
Cc: linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

Hi,
With transparent huge page, min_free_kbytes is set too big.
Before:
Node 0, zone    DMA32
  pages free     1812
        min      1424
        low      1780
        high     2136
        scanned  0
        spanned  519168
        present  511496

After:
Node 0, zone    DMA32
  pages free     482708
        min      11178
        low      13972
        high     16767
        scanned  0
        spanned  519168
        present  511496
This caused different performance problems in our test. I wonder why we
set the value so big.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
