Date: Sat, 7 Oct 2000 01:21:35 +0200
From: David Weinehall <tao@acc.umu.se>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001007012135.A25855@khan.acc.umu.se>
References: <Pine.LNX.4.21.0010061555150.13585-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0010061611540.2191-100000@winds.org> <20001006232718.E22187@khan.acc.umu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001006232718.E22187@khan.acc.umu.se>; from tao@acc.umu.se on Fri, Oct 06, 2000 at 11:27:18PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Byron Stanoszek <gandalf@winds.org>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 06, 2000 at 11:27:18PM +0200, David Weinehall wrote:
> On Fri, Oct 06, 2000 at 04:19:55PM -0400, Byron Stanoszek wrote:
> > On Fri, 6 Oct 2000, Rik van Riel wrote:
> > 
> > > 3. add the out of memory killer, which has been tuned with
> > >    -test9 to be ran at exactly the right moment; process
> > >    selection: "principle of least surprise"  <== OOM handling
> 
> I've tested v2.4.0test9+RielVMpatch now, together with the
> memory_static program. It works terrific. No innocent process got
> killed, just the offending one. And not until the memory was completely
> depleted.

More tests conducted:

16MB memory, 32MB swapfile + 64MB swappartition (in that order)
16MB memory, 64MB swappartition + 32MB swapfile
16MB memory, 64MB swappartition
16MB memory, 32MB swapfile
16MB memory, NO swap

64MB memory, 256MB swappartition
64MB memory, NO swap

All survives just fine.

I can't do anything else while running the memory-eater program
(this is via ssh; haven't tried locally), but when it finally gets
killed, everything works ok again.


/David
  _                                                                 _
 // David Weinehall <tao@acc.umu.se> /> Northern lights wander      \\
//  Project MCA Linux hacker        //  Dance across the winter sky //
\>  http://www.acc.umu.se/~tao/    </   Full colour fire           </
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
