Date: Sun, 5 May 2002 19:23:46 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <E174Qu0-00048i-00@starship>
Message-ID: <Pine.LNX.4.44L.0205051922541.22779-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 5 May 2002, Daniel Phillips wrote:

> Another aspect of the (Free)BSD mm we probably want to hijack is the
> process management, i.e., throttling processes selectively (and in some
> kind of fair rotation) to reduce mm thrashing, which is known to improve
> throughput in high load situations.

We absolutely need something like this, but I'm not sure we'll want
the policy FreeBSD has or one of the many others.

As for the mechanism ... I've had that up and running for about a
year now.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
