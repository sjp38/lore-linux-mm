Date: Fri, 23 Jun 2000 10:45:46 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] RSS guarantees and limits
In-Reply-To: <00062220521900.11608@oscar>
Message-ID: <Pine.LNX.4.21.0006231045220.4551-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2000, Ed Tomlinson wrote:

> Just wondering what will happen with java applications?  These
> beasts typically have working sets of 16M or more and use 10-20
> threads.  When using native threads linux sees each one as a
> process.  They all share the same memory though.

Ahh, but these limits are of course applied per _MM_, not
per thread ;)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
