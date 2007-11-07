Date: Wed, 7 Nov 2007 10:18:48 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC PATCH 3/10] define page_file_cache
In-Reply-To: <20071107131736.437a21e0@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0711071018001.9110@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
 <20071103185516.24832ab0@bree.surriel.com> <Pine.LNX.4.64.0711061821010.5249@schroedinger.engr.sgi.com>
 <20071106215552.4ab7df81@bree.surriel.com> <Pine.LNX.4.64.0711061856400.5565@schroedinger.engr.sgi.com>
 <20071106221710.3f9b8dd6@bree.surriel.com> <Pine.LNX.4.64.0711061920510.5746@schroedinger.engr.sgi.com>
 <20071107093527.0d312903@bree.surriel.com> <Pine.LNX.4.64.0711071005400.9000@schroedinger.engr.sgi.com>
 <20071107131736.437a21e0@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Nov 2007, Rik van Riel wrote:

> On Wed, 7 Nov 2007 10:06:10 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Wed, 7 Nov 2007, Rik van Riel wrote:
> > 
> > > How exactly can an anonymous page ever become file backed?
> > 
> > When they get assigned a swap entry.
> 
> That does not change their status.  They're still swap backed.

If they are swap backed then they have a backing store on disk. They are 
file backed in some sense.

> > > > Do ramfs pages count as memory backed?
> > > 
> > > Since ramfs pages cannot be evicted from memory at all, they
> > > should go into the "noreclaim" page set.
> > 
> > Which LRU do they go on.
> 
> With the patch set from last weekend, the file LRU.

Argh.

> With the patch set later this week, they'll be in the 
> "noreclaim" page set, which is never scanned by the VM.

That sounds better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
