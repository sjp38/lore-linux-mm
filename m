Subject: Re: [RFC] initialize all arches mem_map in one place
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200408060857.18641.jbarnes@engr.sgi.com>
References: <1091779673.6496.1021.camel@nighthawk>
	 <200408060857.18641.jbarnes@engr.sgi.com>
Content-Type: text/plain
Message-Id: <1091811353.6496.2608.camel@nighthawk>
Mime-Version: 1.0
Date: Fri, 06 Aug 2004 09:55:53 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, Anton Blanchard <anton@samba.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2004-08-06 at 08:57, Jesse Barnes wrote:
> On Friday, August 6, 2004 1:07 am, Dave Hansen wrote:
> > The following patch does what my first one did (don't pass mem_map into
> > the init functions), incorporates Jesse Barnes' ia64 fixes on top of
> > that, and gets rid of all but one of the global mem_map initializations
> > (parisc is weird).  It also magically removes more code than it adds.
> > It could be smaller, but I shamelessly added some comments.
> 
> Doesn't apply cleanly to the latest BK tree, which patch am I missing?

It should only be against the latest mm: 2.6.8-rc3-mm1

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
