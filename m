Date: Tue, 1 Jul 2003 05:25:08 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030701032508.GN3040@dualathlon.random>
References: <Pine.LNX.4.53.0307010238210.22576@skynet> <20030701022516.GL3040@dualathlon.random> <20030630200237.473d5f82.akpm@digeo.com> <20030701032248.GM3040@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030701032248.GM3040@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 01, 2003 at 05:22:48AM +0200, Andrea Arcangeli wrote:
> On Mon, Jun 30, 2003 at 08:02:37PM -0700, Andrew Morton wrote:
> > callers are fixed up to not require NOFAIL then we don't need it any more.
> 
> Agreed indeed.

I also found one argument in favour of NOFAIL: now it'll be easier to
find all the deadlocking places ;)

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
