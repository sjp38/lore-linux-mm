Date: Tue, 25 Apr 2000 12:06:58 -0700
From: Simon Kirby <sim@stormix.com>
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
Message-ID: <20000425120657.B7176@stormix.com>
References: <Pine.LNX.4.21.0004251757360.9768-100000@alpha.random> <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva> <20000425113616.A7176@stormix.com> <3905EB26.8DBFD111@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3905EB26.8DBFD111@mandrakesoft.com>; from jgarzik@mandrakesoft.com on Tue, Apr 25, 2000 at 02:59:50PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: riel@nl.linux.org, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, Apr 25, 2000 at 02:59:50PM -0400, Jeff Garzik wrote:

> Simon Kirby wrote:
> > Hrmm.. I guess the ideal solution would be that swappable pages would age
> > just like cache pages and everything else?  Then, if a particular
> > program's page hasn't been accessed for 60 seconds and there is nothing
> > older in the page cahce, it would swap out...
> 
> Again a policy decision...  I think such a feature should be present and
> enabled by default, but there are some people who would prefer that
> their configuration not do this, or would prefer that the timeout for
> old pages be far longer than 60 seconds.

Sorry, I made a mistake there while writing..I was going to give an
example and wrote 60 seconds, but I didn't actually mean to limit
anything to 60 seconds.  I just meant to make a really big global lru
that contains everything including page cache and swap. :)

Simon-

[  Stormix Technologies Inc.  ][  NetNation Communications Inc. ]
[       sim@stormix.com       ][       sim@netnation.com        ]
[ Opinions expressed are not necessarily those of my employers. ]
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
