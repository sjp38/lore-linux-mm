Date: Thu, 13 Apr 2006 17:29:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/5] Swapless V2: Add migration swap entries
In-Reply-To: <20060413171331.1752e21f.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0604131728150.15802@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
 <20060413235416.15398.49978.sendpatchset@schroedinger.engr.sgi.com>
 <20060413171331.1752e21f.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Apr 2006, Andrew Morton wrote:

> Christoph Lameter <clameter@sgi.com> wrote:
> >
> > +
> >  +	if (unlikely(is_migration_entry(entry))) {
> 
> Perhaps put the unlikely() in is_migration_entry()?
> 
> >  +		yield();
> 
> Please, no yielding.
> 
> _especially_ no unchangelogged, uncommented yielding.

Page migration is ongoing so its best to do something else first.

Add a comment?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
