Date: Wed, 31 May 2000 15:49:26 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM bugfix + rebalanced + code beauty
In-Reply-To: <qww4s7e61ds.fsf@sap.com>
Message-ID: <Pine.LNX.4.21.0005311548550.30221-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: evil7@bellsouth.net, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On 31 May 2000, Christoph Rohland wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> > here is a patch (versus 2.4.0-test1-ac5 and 6) that fixes a number
> > of things in the VM subsystem.
> > 
> > - since the pagecache can now contain dirty pages, we no
> >   longer take them out of the pagecache when they get dirtied
> 
> Does this mean, that we can do anonymous shared maps in the page
> cache?

Ermmm, %s/pagecache/swapcache/g in my email. My mistake...

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
