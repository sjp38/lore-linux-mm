Date: Sat, 9 Jun 2001 00:30:01 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM tuning patch, take 2
In-Reply-To: <01060721593800.06690@oscar>
Message-ID: <Pine.LNX.4.21.0106090028570.10415-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Jonathan Morton <chromi@cyberspace.org>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jeff Garzik <jgarzik@mandrakesoft.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2001, Ed Tomlinson wrote:

> Think you are right Jonathan.  This adding this back is _not_ going to
> make a difference.  With the changes Rik made for 2.4.5, these caches
> are agressivily shrunk when there is free shortage...

Suppose you have 80MB of free memory, 120MB in inode/dentry
cache and no swap.  A 100MB allocation will _fail_ with this
code removed from vm_enough_memory(), even though it's easy
to free the inode and dentry caches...

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
