Date: Wed, 7 Jun 2000 19:11:38 -0600
From: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Subject: Re: journaling & VM
Message-ID: <20000607191138.A6577@acs.ucalgary.ca>
References: <Pine.LNX.4.21.0006071818580.14304-100000@duckman.distro.conectiva> <393EC40A.376BB072@reiser.to>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <393EC40A.376BB072@reiser.to>; from hans@reiser.to on Wed, Jun 07, 2000 at 02:52:10PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[recipient list brutally slashed]

On Wed, Jun 07, 2000 at 02:52:10PM -0700, Hans Reiser wrote:
> Caches have a declining marginal utility. It is a good idea to
> keep at least a little bit of each cache around. The classic
> problem is when you switch usage patterns back and forth, and
> one of the caches has been completely flushed by, say, a large
> file read. If just 3% of the amount of cache remained from when
> it was being used that 3% might give you a lot of speedup when
> the usage pattern flipped back.

I'm not sure about this.  The problem is that things like file
reads break the LRU heuristic.  If the new pages read will be
accessed sooner than the cache pages (instead of being just
accessed once) then the cache pages should be paged out.  Am I
missing something?

    Neil

-- 
Real Life? I played that game. The plot sucks but the graphics are
awesome.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
