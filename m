Date: Mon, 7 Jan 2002 16:53:31 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] improving oom detection in rmap10c.
In-Reply-To: <20020106154950.5B067693F@oscar.casa.dyndns.org>
Message-ID: <Pine.LNX.4.33L.0201071635170.872-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jan 2002, Ed Tomlinson wrote:

> This patch should prevent oom situations where the vm does not see
> pages released from the slab caches.

> Comments?

I have a feeling the OOM detection in rmap10c isn't working
out because of another issue ... I think it has something to
do with the swap allocation failure path indirectly triggering
OOM, I think I'll go audit the code now ;)

(oh the wonders of maintaining code ... auditing everybody's
code and tracking down bugs instead of doing fun development ;))

cheers,

Rik
-- 
Shortwave goes a long way:  irc.starchat.net  #swl

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
