Date: Tue, 2 May 2000 22:14:05 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
Message-ID: <20000502221405.O1389@redhat.com>
References: <Pine.LNX.4.21.0005021818070.1919-100000@alpha.random> <Pine.LNX.4.21.0005021405030.10610-100000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0005021405030.10610-100000@duckman.conectiva>; from riel@conectiva.com.br on Tue, May 02, 2000 at 02:06:20PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Andrea Arcangeli <andrea@suse.de>, Roger Larsson <roger.larsson@norran.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, May 02, 2000 at 02:06:20PM -0300, Rik van Riel wrote:
> > do the smart things I was mentining some day ago in linux-mm
> > with NUMA.
> 
> How do you want to take care of global page balancing with
> this "optimisation"?

You don't.  With NUMA, the memory is inherently unbalanced, and you
don't want the allocator to smooth over the different nodes.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
