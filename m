Date: Wed, 28 May 2008 11:59:51 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 07/23] hugetlb: multi hstate sysctls
Message-ID: <20080528095951.GE2630@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.841211000@nick.local0.net> <1211922031.12036.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1211922031.12036.22.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi-suse@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Tue, May 27, 2008 at 04:00:31PM -0500, Adam Litke wrote:
> On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> > @@ -614,8 +614,16 @@ void __init hugetlb_add_hstate(unsigned 
> > 
> >  static int __init hugetlb_setup(char *s)
> >  {
> > -	if (sscanf(s, "%lu", &default_hstate_max_huge_pages) <= 0)
> > -		default_hstate_max_huge_pages = 0;
> > +	unsigned long *mhp;
> > +
> 
> Perhaps a one-liner comment here to remind us that !max_hstate means we
> currently have only one huge page size defined, and that it is
> considered the default (or compat) size, and that it gets special
> treatment by using ???default_hstate_max_huge_pages.

Sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
