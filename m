Date: Sat, 20 Jul 2002 10:07:48 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH 6/6] Updated VM statistics patch
In-Reply-To: <Pine.LNX.4.44.0207192328330.5880-100000@loke.as.arizona.edu>
Message-ID: <Pine.LNX.4.44L.0207201006100.12241-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Jul 2002, Craig Kulesa wrote:

> This latest version takes advantage of the list management macros in
> mm_inline.h to handle all of the 'pgactivate' and 'pgdeactivate'
> counter incrementing.  This simplifies the patch, and makes it easier to
> keep accounting accurate.

Except for the fact that you'll count every new page allocation
as an activation, which isn't quite the intended behaviour ;)

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
