Date: Thu, 10 Jul 2003 18:08:12 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm1
Message-ID: <20030711010812.GA15452@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org> <200307100059.57398.phillips@arcor.de> <16140.51447.73888.717087@wombat.chubb.wattle.id.au> <200307110304.11216.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200307110304.11216.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Peter Chubb <peter@chubb.wattle.id.au>, Jamie Lokier <jamie@shareable.org>, Davide Libenzi <davidel@xmailserver.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 11, 2003 at 03:04:11AM +0200, Daniel Phillips wrote:
> Thinking strictly about the needs of sound processing, what's needed is a 
> guarantee of so much cpu time each time the timer fires, and a user limit to 
> prevent cpu hogging.  It's worth pondering the difference between that and 
> rate-of-forward-progress.  I suspect some simple improvements to the current 
> scheduler can be made to do the job, and at the same time, avoid the 
> priorty-based starvation issue that seems to have been practically mandated 
> by POSIX.

Such scheduling policies are called "isochronous".


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
