Date: Tue, 24 Oct 2000 00:28:51 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Another wish item for your TODO list...
Message-ID: <20001024002851.G727@nightmaster.csn.tu-chemnitz.de>
References: <20001023175402.B2772@redhat.com> <Pine.LNX.4.21.0010231501210.13115-100000@duckman.distro.conectiva> <20001023183649.H2772@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001023183649.H2772@redhat.com>; from sct@redhat.com on Mon, Oct 23, 2000 at 06:36:49PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 23, 2000 at 06:36:49PM +0100, Stephen C. Tweedie wrote:
> On Mon, Oct 23, 2000 at 03:02:06PM -0200, Rik van Riel wrote:
> > I take it you mean "move all the pages from before the
> > currently read page to the inactive list", so we preserve
> > the pages we just read in with readahead ?
> No, I mean that once we actually remove a page, we should also remove
> all the other pages IF the file has never been accessed in a
> non-sequential manner.  The inactive management is separate.

*.h files, which are read in by the GCC are always accessed
sequentielly (at least from the kernel POV) and while unmapping
them is ok, they should at least remain in cache to speed up
compiling. That's just one example for a workload which will
suffer from this idea.

If you are going to include stuff like this, please make it at
least a sysctl. It would be nice, if I could tell the kernel the
workload I have, that these weird access patterns are quite
normal for me and how to handle them.

Thanks & Regards

Ingo Oeser
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
