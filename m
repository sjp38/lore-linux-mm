Date: Fri, 11 Jul 2003 09:56:30 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: 2.5.74-mm3 - apm_save_cpus() Macro still bombs out
Message-ID: <20030711145630.GL27280@waste.org>
References: <20030708223548.791247f5.akpm@osdl.org> <200307101142.37137.schlicht@uni-mannheim.de> <20030710094841.GU15452@holomorphy.com> <200307101159.51175.schlicht@uni-mannheim.de> <20030710103022.GV15452@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030710103022.GV15452@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Thomas Schlichter <schlicht@uni-mannheim.de>, Piet Delaney <piet@www.piet.net>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 10, 2003 at 03:30:22AM -0700, William Lee Irwin III wrote:
> On Thursday 10 July 2003 11:48, William Lee Irwin III wrote:
> > It's not the 64B...
> > I care about the unneeded but executed code!
> > But I'm a hopeless perfectionist caring about such nits...
> 
> On Thu, Jul 10, 2003 at 11:59:49AM +0200, Thomas Schlichter wrote:
> > And I don't know why everybody hates my patches... ;-(
> 
> It's not that anyone hates them, it's that
> pass 1: the semantics (0 == empty cpu set) needed preserving
> pass 2: remove code instead of changing redundant stuff
> 
> NFI YTF gcc doesn't optimize out the whole shebang.

Probably would if inline were added to the function spec?
 
If we're going to worry about space, we'd start by worrying about the
existence of current->cpus_allowed in the UP case. 

> At any rate, if we're pounding APM BIOS calls or apm_power_off()
> like wild monkeys there's something far more disturbing going wrong
> than 64B of code gcc couldn't optimize (it's probably due to some
> jump target being aligned to death or some such nonsense).

I much prefer the removal of #ifdef approach - would have prevented
the bug getting out in the first place.

-- 
Matt Mackall : http://www.selenic.com : of or relating to the moon
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
