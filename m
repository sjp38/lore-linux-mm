Subject: Re: [PATCH] VM bugfix + rebalanced + code beauty
References: <Pine.LNX.4.21.0005301941030.16985-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 31 May 2000 20:05:51 +0200
In-Reply-To: Rik van Riel's message of "Tue, 30 May 2000 19:49:01 -0300 (BRST)"
Message-ID: <qww4s7e61ds.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: evil7@bellsouth.net, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:
> here is a patch (versus 2.4.0-test1-ac5 and 6) that fixes a number
> of things in the VM subsystem.
> 
> - since the pagecache can now contain dirty pages, we no
>   longer take them out of the pagecache when they get dirtied

Does this mean, that we can do anonymous shared maps in the page
cache?

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
