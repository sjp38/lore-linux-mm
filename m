Date: Thu, 12 Dec 2002 00:59:02 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: strange bug rmap15a
In-Reply-To: <Pine.LNX.4.50L.0212120037060.21756-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.50L.0212120057010.21756-100000@imladris.surriel.com>
References: <Pine.LNX.4.50L.0212120037060.21756-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: linux-mm@kvack.org, Benjamin LaHaise <bcrl@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Dec 2002, Rik van Riel wrote:

> OK, something between rmap15 and rmap15a is triggering the

Forget that, it's Ben's pte-highmem patch ...

> mystery page c1028220, cnt 1 map 00000000, buf 00000000, ptec 00000000, dirty 0

... it conveniently adds a page->pte.{direct,chain} union, but
doesn't remove the old page->pte_chain field, which is still
referenced by tons of source code.

Of course the old field is always zero, so left and right code
gets confused...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://guru.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
