Date: Wed, 26 Apr 2000 12:01:30 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
Message-ID: <20000426120130.E3792@redhat.com>
References: <Pine.LNX.4.21.0004251757360.9768-100000@alpha.random> <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva> <20000425113616.A7176@stormix.com> <3905EB26.8DBFD111@mandrakesoft.com> <20000425120657.B7176@stormix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000425120657.B7176@stormix.com>; from sim@stormix.com on Tue, Apr 25, 2000 at 12:06:58PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Kirby <sim@stormix.com>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, riel@nl.linux.org, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 25, 2000 at 12:06:58PM -0700, Simon Kirby wrote:
> 
> Sorry, I made a mistake there while writing..I was going to give an
> example and wrote 60 seconds, but I didn't actually mean to limit
> anything to 60 seconds.  I just meant to make a really big global lru
> that contains everything including page cache and swap. :)

Doesn't work.  If you do that, a "find / | grep ..." swaps out 
everything in your entire system.

Getting the VM to respond properly in a way which doesn't freak out
in the mass-filescan case is non-trivial.  Simple LRU over all pages
simply doesn't cut it.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
