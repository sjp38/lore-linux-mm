Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <441863AC.6050101@argo.co.il>
References: <1142019195.5204.12.camel@localhost.localdomain>
	 <20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com>
	 <1142270857.5210.50.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0603131541330.13713@schroedinger.engr.sgi.com>
	 <44183B64.3050701@argo.co.il>	<20060315095426.b70026b8.pj@sgi.com>
	 <Pine.LNX.4.64.0603151008570.27212@schroedinger.engr.sgi.com>
	 <20060315101402.3b19330c.pj@sgi.com>  <441863AC.6050101@argo.co.il>
Content-Type: text/plain
Date: Wed, 15 Mar 2006 14:27:06 -0500
Message-Id: <1142450826.5198.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@argo.co.il>
Cc: Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Steve Ofsthun <sofsthun@virtualiron.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-03-15 at 20:57 +0200, Avi Kivity wrote:
> Paul Jackson wrote:
> 
> >>a page if a certain mapcount is reached.
> >>    
> >>
> >
> >He said "accessed", not "referenced".
> >
> >The point was to copy pages that receive many
> >load and store instructions from far away nodes.
> >
> >  
> >
> Only loads, please. Writable pages should not be duplicated.
> 
> >This has only minimal to do with the number of
> >memory address spaces mapping the region
> >holding that page.
> >
> >  
> >
> 
> For starters, you could indicate which files need duplication manually. 
> You would duplicate your main binaries and associated shared objects. 
> Presumably large numas have plenty of memory so over-duplication would 
> not be a huge problem.
> 
> Is the kernel text duplicated?

No.  Might have been patches to do this for ia64 at one time.  I'm not
sure, tho'.

However, the folks at Virtual Iron do have patches to replicate shared,
executable segments.  They mentioned this at OLS last year.  I believe
that Ray Bryant got 'hold of a copy of the patch and had it working at
one time.  Didn't address one of the issues he was interested in, which
was to also duplicate the page tables for shared segments [?].  I hope
to experiment with them sometime down the line to see if they provide
measurable benefit.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
