Date: Wed, 31 Jul 2002 17:26:27 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: throttling dirtiers
In-Reply-To: <20020731162357.Q10270@redhat.com>
Message-ID: <Pine.LNX.4.44L.0207311725530.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@zip.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jul 2002, Benjamin LaHaise wrote:

> Why?  Filling the entire ram with dirty pages is okay, and in fact you
> want to support that behaviour for apps that "just fit" (think big
> scientific apps).  The only interesting point is that when you hit the
> limit of available memory, the system needs to block on *any* io
> completing and resulting in clean memory (which is reasonably low
> latency), not a specific io which may have very high latency.

Also, the system shouldn't try writing out the complete inactive
list at once and blocking in __get_request_wait instead of grabbing
pages as they become cleaned.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
