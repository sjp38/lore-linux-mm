Date: Mon, 9 Oct 2000 12:12:02 +0200 (CEST)
From: Marco Colombo <marco@esi.it>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010061721520.13585-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0010091159430.20087-100000@Megathlon.ESI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Oct 2000, Rik van Riel wrote:

[...]
> They are niced because the user thinks them a bit less
> important. 

Please don't, this assumption is quite wrong. I use nice just to be
'nice' to other users. I can run my *important* CPU hog simulation
nice +10 in order to let other people get more CPU when the need it.
But if you put the logic "niced == not important" somewhere into the
kernel, nobody will use nice anymore. I'd rather give a bonus to niced
processes.

I agree this is a small issue, the OOM killer job isn't "nice" at all
anyway. B-) (at OOM time, I'd not even look at the nice of a process at
all. But my point here is that you do, and you take it as an hint for
process importance as percieved by the user that run it, and I believe
it's just wrong guessing).

.TM.
-- 
      ____/  ____/   /
     /      /       /			Marco Colombo
    ___/  ___  /   /		      Technical Manager
   /          /   /			 ESI s.r.l.
 _____/ _____/  _/		       Colombo@ESI.it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
