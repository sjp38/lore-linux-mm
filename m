Date: Fri, 8 Mar 2002 18:38:35 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: O(1) page launder, first version
Message-ID: <Pine.LNX.4.44L.0203081836380.2181-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: William Lee Irwin III <wli@holomorphy.com>, arjan@fenrus.demon.nl
List-ID: <linux-mm.kvack.org>

Hi,

I've made available the first (still crashing) version of
the O(1) page launder code Arjan designed.

You can grab it from bk://linuxvm.bkbits.net/vm-o1pglaunder-2.4

I suspect submit_writeouts_zone is unlocking a page under
IO since end_buffer_io_async is trying to unlock an already
unlocked page, which blows up...

have fun,

Rik
-- 
<insert bitkeeper endorsement here>

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
