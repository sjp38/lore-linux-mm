Message-ID: <3ACE281E.2F00519F@mandrakesoft.com>
Date: Fri, 06 Apr 2001 16:33:34 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: [PATCH] swap_state.c thinko
References: <OFF70E8B5F.A2073252-ON85256A26.006E7BF4@pok.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Bulent Abali wrote:
> By the way, disk space is cheap why not give more than 1 percent slop?
> This is really accounted in the swap space and not the memory.
> It will also help system out of oom_killer's radar.

Dumb question...  is the OOM killer accounting for icache and dcache
memory usage?

-- 
Jeff Garzik       | Sam: "Mind if I drive?"
Building 1024     | Max: "Not if you don't mind me clawing at the dash
MandrakeSoft      |       and shrieking like a cheerleader."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
