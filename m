Received: from 203-167-144-189.dialup.clear.net.nz
 (203-167-144-189.dialup.clear.net.nz [203.167.144.189])
 by smtp1.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0HAS00IWVFR2AD@smtp1.clear.net.nz> for linux-mm@kvack.org; Mon,
 24 Feb 2003 13:52:17 +1300 (NZDT)
Date: Mon, 24 Feb 2003 13:47:10 +1300
From: Nigel Cunningham <ncunningham@clear.net.nz>
Subject: RFC: How to write a page to swap with [near] zero impact on memory?
Message-id: <1046047118.9314.49.camel@laptop-linux.cunninghams>
MIME-version: 1.0
Content-type: text/plain
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi all.

I'm beginning to port the 2.4 beta 18 version, which allows the user to
suspend to disk what is pretty close to a complete image of RAM at the
time the suspend is initiated. Since this implies working in conditions
where there might be only a few hundred pages available, I carefully
accounted for pages in use and worked to free buffers and swapcache
pages that were added during the image-saving process. I'm wanting to
implement the same thing under 2.5, and would like advice on the best
way to do it. (Ideally, I'd like to write a page and have everything at
the end exactly as it was at the start, except that a copy of the page
is on disk as well as in memory).

I've spent some time looking at mm/*.c, but I won't pretend for a moment
to have a fraction of the knowledge that you guys have. I thus thought
I'd be wise to talk with you all before I submit any patches for
comments. What suggestions would you provide about minimising the impact
of writing a page to swap? 

Thanks in advance for any help and regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
