Date: Wed, 19 Jun 2002 19:11:36 +0200
From: Dave Jones <davej@suse.de>
Subject: Re: [PATCH] (1/2) reverse mapping VM for 2.5.23 (rmap-13b)
Message-ID: <20020619191136.H29373@suse.de>
References: <Pine.LNX.4.44.0206181340380.3031-100000@loke.as.arizona.edu> <E17KipF-0000up-00@starship>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E17KipF-0000up-00@starship>; from phillips@bonn-fries.net on Wed, Jun 19, 2002 at 07:00:57PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Craig Kulesa <ckulesa@as.arizona.edu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, rwhron@earthlink.net
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2002 at 07:00:57PM +0200, Daniel Phillips wrote:
 > > ...Hope this is of use to someone!  It's certainly been a fun and 
 > > instructive exercise for me so far.  ;)
 > It's intensely useful.  It changes the whole character of the VM discussion 
 > at the upcoming kernel summit from 'should we port rmap to mainline?' to 'how 
 > well does it work' and 'what problems need fixing'.  Much more useful.

Absolutely.  Maybe Randy Hron (added to Cc) can find some spare time
to benchmark these sometime before the summit too[1]. It'll be very
interesting to see where it fits in with the other benchmark results
he's collected on varying workloads.

        Dave

[1] I am master of subtle hints.

-- 
| Dave Jones.        http://www.codemonkey.org.uk
| SuSE Labs
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
