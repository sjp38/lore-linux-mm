Date: Thu, 14 Jun 2007 16:11:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory unplug v5 [1/6] migration by kernel
Message-Id: <20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007 00:01:51 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 14 Jun 2007, KAMEZAWA Hiroyuki wrote:
> 
> > 1. A page which is not mapped can be target of migration. Then, we have
> >    to check page_mapped() before calling try_to_unmap().
> 
> How can we get an anonymous page that is not mapped?
> 

In my case, any pages linked to LRU can be target of migration.
"A page which is not mapped" may not be an anon. can be unmapped file caches.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
