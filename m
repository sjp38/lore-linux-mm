Received: from flecktone.americas.sgi.com (flecktone.americas.sgi.com [198.149.16.15])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j1GBVuxT017101
	for <linux-mm@kvack.org>; Wed, 16 Feb 2005 05:32:16 -0600
Date: Wed, 16 Feb 2005 05:30:47 -0600
From: Robin Holt <holt@SGI.com>
Subject: Re: manual page migration -- issue list
Message-ID: <20050216113047.GA8388@lnx-holt.americas.sgi.com>
References: <42128B25.9030206@sgi.com> <20050215165106.61fd4954.pj@sgi.com> <20050216015622.GB28354@lnx-holt.americas.sgi.com> <20050215202214.4b833bf3.pj@sgi.com> <20050216092011.GA6616@lnx-holt.americas.sgi.com> <20050216022009.7afb2e6d.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050216022009.7afb2e6d.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@SGI.com>
Cc: Robin Holt <holt@SGI.com>, raybry@SGI.com, linux-mm@kvack.org, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

On Wed, Feb 16, 2005 at 02:20:09AM -0800, Paul Jackson wrote:
> The next concern that rises to the top for me was best expressed by Andi:
> >
> > The main reasons for that is that I don't think external
> > processes should mess with virtual addresses of another process.
> > It just feels unclean and has many drawbacks (parsing /proc/*/maps
> > needs complicated user code, racy, locking difficult).  
> > 
> > In kernel space handling full VMs is much easier and safer due to better 
> > locking facilities.
> 
> I share Andi's concerns, but I don't see what to do about this.  Andi's
> recommendations seem to be about memory policies (which guide future
> allocations), and not about migration of already allocated physical
> pages.  So for now at least, his recommendations don't seem like answers
> to me.

If we had the ability to change the vendor provided software to meet
our needs, that would be wonderful.

Unfortunately, most of this type code runs on _MANY_ different OSs and
architectures.  If you could get the NUMA api into everything from AIX
to Windows XP, I think you would have a very good chance of convincing
ISVs to start converting.  Until then, there is no clear win over first
touch for their type of application.

With that in mind, we are left with doing things from the outside in.
Heck, if we could get them to change their code, cpusets would be
irrelavent as well ;)

Thanks,
Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
