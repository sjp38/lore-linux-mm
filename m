Date: Wed, 7 Jun 2000 16:09:31 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
Message-ID: <20000607160931.C22749@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0006050716160.31069-100000@duckman.distro.conectiva> <qww1z29ssbb.fsf@sap.com> <20000607143242.D30951@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000607143242.D30951@redhat.com>; from sct@redhat.com on Wed, Jun 07, 2000 at 02:32:42PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Christoph Rohland <cr@sap.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> The main reason SHM needs its own swap code is that normal anonymous
> pages are referred to only from ptes --- the ptes either point to
> the physical page containing the page, or to the swap entry.  We
> cannot use that for SHM, because SysV SHM segments must be persistent
> even if there are no attachers, and hence no ptes to maintain the 
> location of the pages.  

It might be possible to create MMs without tasks specifically to map the
SHM segments.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
