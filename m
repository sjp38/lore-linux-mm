Date: Mon, 8 Oct 2001 18:28:20 -0700
Subject: Re: [CFT][PATCH *] faster cache reclaim
Message-ID: <20011008182820.A6361@gnuppy>
References: <Pine.LNX.4.33L.0110082032070.26495-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0110082032070.26495-100000@duckman.distro.conectiva>
From: Bill Huey <billh@gnuppy.monkey.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, kernelnewbies@nl.linux.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 08, 2001 at 08:38:27PM -0300, Rik van Riel wrote:
> It also reduces the distance between inactive_shortage and
> inactive_plenty, so kswapd should spend much less time rolling
> over pages from zones we're not interested in.
> 
> This patch is meant to fix the problems where heavy cache
> activity flushes out pages from the working set, while still
> allowing the cache to put some pressure on the working set.

Rik,

It work well when I pressure it under some intensive IO operations under
dpkg and made progress when previous VMs basically froze. I did have two
running programs that have large working sets which created a lot of
contention and some CPU choppiness, but possibly some per process thrash
control should allow for both to make progress. ;-)

Good work.

bill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
