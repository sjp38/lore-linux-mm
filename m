Date: Thu, 3 Aug 2000 11:34:00 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: RFC: design for new VM
In-Reply-To: <Pine.LNX.4.21.0008031124170.7156-100000@enki.corp.icopyright.com>
Message-ID: <Pine.LNX.4.10.10008031132400.6384-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lamont@icopyright.com
Cc: Chris Wedgwood <cw@f00f.org>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Thu, 3 Aug 2000 lamont@icopyright.com wrote:
> 
> CONFIG_VM_FREEBSD_ME_HARDER would be a nice kernel option to have, if
> possible.  Then drop it iff the tweaks are proven over time to work
> better.

On eproblem is/may be the basic setup. Does FreeBSD have the notion of
things like high memory etc? Different memory pools for NUMA? Things like
that..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
