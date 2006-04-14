Date: Thu, 13 Apr 2006 17:42:32 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/5] Swapless V2: Add migration swap entries
Message-Id: <20060413174232.57d02343.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0604131728150.15802@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
	<20060413235416.15398.49978.sendpatchset@schroedinger.engr.sgi.com>
	<20060413171331.1752e21f.akpm@osdl.org>
	<Pine.LNX.4.64.0604131728150.15802@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Thu, 13 Apr 2006, Andrew Morton wrote:
> 
> > Christoph Lameter <clameter@sgi.com> wrote:
> > >
> > > +
> > >  +	if (unlikely(is_migration_entry(entry))) {
> > 
> > Perhaps put the unlikely() in is_migration_entry()?
> > 
> > >  +		yield();
> > 
> > Please, no yielding.
> > 
> > _especially_ no unchangelogged, uncommented yielding.
> 
> Page migration is ongoing so its best to do something else first.

That doesn't help a lot.  What is "something else"?  What are the dynamics
in there, and why do you feel that some sort of delay is needed?

> Add a comment?

I don't think we're up to that stage yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
