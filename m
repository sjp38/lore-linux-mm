Date: Thu, 14 Jun 2007 00:22:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] memory unplug v5 [1/6] migration by kernel
In-Reply-To: <20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706140019490.11852@schroedinger.engr.sgi.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
 <20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
 <20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, KAMEZAWA Hiroyuki wrote:

> On Thu, 14 Jun 2007 00:01:51 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Thu, 14 Jun 2007, KAMEZAWA Hiroyuki wrote:
> > 
> > > 1. A page which is not mapped can be target of migration. Then, we have
> > >    to check page_mapped() before calling try_to_unmap().
> > 
> > How can we get an anonymous page that is not mapped?
> > 
> 
> In my case, any pages linked to LRU can be target of migration.
> "A page which is not mapped" may not be an anon. can be unmapped file caches.

But the code is checking for an anonymous page and then checks if it is 
mapped.

If you have a valid anonymous page then it is mapped. How can an unmapped 
anonymous page exist? It will be freed immediately (or am I missing a 
special case. No need to check that it is mapped. Thus also no need to 
call page_lock_anon_vma.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
