Date: Mon, 23 Jun 2003 10:10:16 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] Fix vmtruncate race and distributed filesystem race
Message-ID: <20030623081016.GI19940@dualathlon.random>
References: <20030612134946.450e0f77.akpm@digeo.com> <20030612140014.32b7244d.akpm@digeo.com> <150040000.1055452098@baldur.austin.ibm.com> <20030612144418.49f75066.akpm@digeo.com> <184910000.1055458610@baldur.austin.ibm.com> <20030620001743.GI18317@dualathlon.random> <20030623032842.GA1167@us.ibm.com> <20030622233235.0924364d.akpm@digeo.com> <20030623074353.GE19940@dualathlon.random> <20030623005623.5fe1ab30.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030623005623.5fe1ab30.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: paulmck@us.ibm.com, dmccr@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 23, 2003 at 12:56:23AM -0700, Andrew Morton wrote:
> Andrea Arcangeli <andrea@suse.de> wrote:
> >
> > that will finally close the race
> 
> Could someone please convince me that we really _need_ to close it?
> 
> The VM handles the whacky pages OK (on slowpaths), and when this first came
> up two years ago it was argued that the application was racy/buggy
> anyway.  So as long as we're secure and stable, we don't care.  Certainly
> not to the point of adding more atomic ops on the fastpath.
> 
> So...   what bug are we actually fixing here?

we're fixing userspace data corruption with an app trapping SIGBUS.

> 
> 
> (I'd also like to see a clearer description of the distributed fs problem,
> and how this fixes it).

I certainly would like discussions about it too.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
