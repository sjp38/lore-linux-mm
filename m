Date: Fri, 15 Sep 2000 21:37:26 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [PATCH *] VM patch for 2.4.0-test8
Message-ID: <20000915213726.A9965@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0009141351510.10822-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0009151915040.7748-100000@tux.rsn.hk-r.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009151915040.7748-100000@tux.rsn.hk-r.se>; from gandalf@wlug.westbo.se on Fri, Sep 15, 2000 at 07:28:43PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Cc: Rik van Riel <riel@conectiva.com.br>, "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Martin Josefsson wrote:
> I've been trying to get my machine to swap but that seems hard with this
> new patch :) I have 0kB of swap used after 8h uptime, and I have been
> compiling, moving files between partitions and running md5sum on files
> (that was a big problem before, everything ended up on the active list and
> the swapping started and brought my machine down to a crawl)

No preemptive page-outs?

0kB swap means if you suddenly need a lot of memory, inactive
application pages have to be written to disk first.  There are always
inactive application pages.

Maybe the stats are inaccurate.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
