Date: Fri, 8 Jun 2007 00:21:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: memory unplug v4 intro [1/6] migration without mm->sem
In-Reply-To: <20070608160148.616dae54.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706080019400.29461@schroedinger.engr.sgi.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
 <20070608143844.569c2804.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706072242500.28618@schroedinger.engr.sgi.com>
 <20070608145435.4fa7c9b6.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706072254160.28618@schroedinger.engr.sgi.com>
 <20070608150602.78f07b34.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706072344040.29301@schroedinger.engr.sgi.com>
 <20070608160148.616dae54.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007, KAMEZAWA Hiroyuki wrote:

> On Thu, 7 Jun 2007 23:44:38 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > I think what Hugh meant is someething like this:
> > 
> Hmm, I see. 
> 
> 
> >  	/*
> > +	 * Add dummy vma so that the vma cannot vanish under us
> > +	 */
> > +	if (PageAnon(page))
> > +		anon_vma_link(&dummy_vma);
> > +
> Before calling anon_vma_link(), I have to set "dummy_vma->anon_vma = anon_vma".
> anon_vma_hold() does what it has to do.

Yup. Forgot that one.

> But it's not necessary to add anon_vma_hold() in rmap.c, as you pointed out.
> I'll rewrite them as static func in migrate.c

I do not think you need anon_vma_hold at all. Neither do you need to add 
any other function. The presence of the dummy vma while the page is 
removed and added guarantees that it does not vanish.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
