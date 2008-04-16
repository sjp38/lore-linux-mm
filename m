Date: Wed, 16 Apr 2008 11:04:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
In-Reply-To: <20080416121003.8440caf4.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0804161102570.12313@schroedinger.engr.sgi.com>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
 <20080415191350.0dc847b6.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0804151227050.1785@schroedinger.engr.sgi.com>
 <20080416092334.2dabce2c.kamezawa.hiroyu@jp.fujitsu.com>
 <20080416112341.ef1d5452.kamezawa.hiroyu@jp.fujitsu.com>
 <20080416121003.8440caf4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Apr 2008, KAMEZAWA Hiroyuki wrote:

> BTW, a bit off-topic.
> I found I can't do memory offline when I use SLAB not SLUB, 

Ah. SLAB depends on GFP_THISNODE to force the page allocator to allocate 
on a certain and since we broke that it does strange things.

SLUB lets the page allocator figure out which node to use. GFP_THISNODE is 
only used if the caller specifies it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
