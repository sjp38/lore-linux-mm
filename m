Date: Thu, 7 Nov 2002 00:16:48 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] Buffers pinning inodes in icache forever
In-Reply-To: <200211062159.gA6LxmK23126@sisko.scot.redhat.com>
Message-ID: <Pine.LNX.4.44L.0211070016180.3411-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.44L.0211070016182.3411@imladris.surriel.com>
Content-Disposition: INLINE
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Nov 2002, Stephen C. Tweedie wrote:

> With the patch below we've not seen this particular pathology recur.
> Comments?

I like it.  This seems like a correct and simple fix.

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://distro.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
