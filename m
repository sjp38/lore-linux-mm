Subject: Re: [RFC/PATCH] prepare_unmapped_area
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1170795164.26117.35.camel@localhost.localdomain>
References: <200702060405.l1645R7G009668@shell0.pdx.osdl.net>
	 <1170736938.2620.213.camel@localhost.localdomain>
	 <20070206044516.GA16647@wotan.suse.de>
	 <1170738296.2620.220.camel@localhost.localdomain>
	 <1170777380.26117.28.camel@localhost.localdomain>
	 <1170792754.2620.244.camel@localhost.localdomain>
	 <1170795164.26117.35.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 07 Feb 2007 08:02:53 +1100
Message-Id: <1170795774.2620.255.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, hugh@veritas.com, Linux Memory Management <linux-mm@kvack.org>, hch@infradead.org, "David C. Hansen [imap]" <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> Yeah, you're right... Former revisions of the patch created a function
> called is_special_range() which for the moment only called
> is_hugepage_only_range().  The thought was that other types of "special
> ranges" could be checked for in this function.  I guess that's basically
> the same idea as validate_area() below.  That would work for me.
> 
> > I was talking to hch and arjan yesterday on irc and we though about
> > having an mm hook validate_area() that could replace the
> > is_hugepage_only_range() hack and deal with my issue as well. As for
> > having prepare in the fops, do we need it at all if we call fops->g_u_a
> > in the MAP_FIXED case ?
> 
> Nah, if we cleaned up g_u_a() so that it is always called, away goes the
> need for f_ops->prepare_unmapped_area().

Ok, I'll cook up a patch around those lines, possibly next week.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
