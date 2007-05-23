Date: Wed, 23 May 2007 11:09:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch] memory unplug v3 [2/4] migration by kernel
Message-Id: <20070523110917.ea09e857.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705221855320.20738@schroedinger.engr.sgi.com>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
	<20070522160437.6607f445.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0705221143450.29456@schroedinger.engr.sgi.com>
	<20070523104558.a877d869.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0705221855320.20738@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007 18:56:56 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 23 May 2007, KAMEZAWA Hiroyuki wrote:
> 
> > > > +#ifdef CONFIG_MIGRATION_BY_KERNEL
> > > > +struct anon_vma *anon_vma_hold(struct page *page) {
> > > > +	struct anon_vma *anon_vma;
> > > > +	anon_vma = page_lock_anon_vma(page);
> > > > +	if (!anon_vma)
> > > > +		return NULL;
> > > > +	atomic_set(&anon_vma->ref, 1);
> > > 
> > > Why use an atomic value if it is set and cleared within a spinlock?
> > 
> > anon_vma_free(), which see this value, doesn't take any lock and use atomic ops.
> > I used atomic ops to handle atomic_t.
> 
> anon_vma_free() only reads the value. Thus no race. You do not need an 
> atomic_t. atomic_t is only necessary if a variable needs to be changed 
> atomically. Reading a word from memory is atomic regardless.
> 
thank you for pointing out. I understand.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
