Date: Tue, 25 Apr 2006 09:29:28 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page host virtual assist patches.
Message-Id: <20060425092928.292f3662.akpm@osdl.org>
In-Reply-To: <1145961867.5282.46.camel@localhost>
References: <20060424123412.GA15817@skybase>
	<20060424180138.52e54e5c.akpm@osdl.org>
	<444DCD87.2030307@yahoo.com.au>
	<1145953914.5282.21.camel@localhost>
	<20060425013712.365892c2.akpm@osdl.org>
	<1145961867.5282.46.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
>
> On Tue, 2006-04-25 at 01:37 -0700, Andrew Morton wrote:
> > >  The point here is WHO does the reclaim. Sure we can do the reclaim in
> > >  the guest but it is the host that has the memory pressure. To call into
> > >  the guest is not a good idea, if you have an idle guest you generally
> > >  increase the memory pressure because some of the guests pages might have
> > >  been swapped which are needed if the guest has to do the reclaim. 
> > 
> > Cannot the guests employ text sharing?
> 
> Yes we can. We even had some patches for sharing the kernel text between
> virtual machines. But the kernel text is only a small part of the memory
> that gets accessed for a vmscan operation.
> 

And the bulk of the rest will be accesses to mem_map[].  I guess the hva
patches still require that each guests's mem_map[] be in host memory, but
not necessarily in guest memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
