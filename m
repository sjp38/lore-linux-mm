Date: Fri, 6 Sep 2002 23:10:20 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: inactive_dirty list
In-Reply-To: <3D7960FC.3E2C890A@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209062309580.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Sep 2002, Andrew Morton wrote:

> I have a silly feeling that setting DEF_PRIORITY to "12" will
> simply fix this.
>
> Duh.

Ideally we'd get rid of DEF_PRIORITY alltogether and would
just scan each zone once.

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
