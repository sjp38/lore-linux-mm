Date: Wed, 7 Jun 2000 22:29:33 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: journaling & VM
In-Reply-To: <20000607191138.A6577@acs.ucalgary.ca>
Message-ID: <Pine.LNX.4.21.0006072228400.18679-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jun 2000, Neil Schemenauer wrote:

> I'm not sure about this.  The problem is that things like file
> reads break the LRU heuristic.  If the new pages read will be
> accessed sooner than the cache pages (instead of being just
> accessed once) then the cache pages should be paged out.  Am I
> missing something?

No. You just described why LRU is not the algorithm we want
to use for page aging ;)

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
