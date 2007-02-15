Date: Thu, 15 Feb 2007 08:51:38 -0600
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 2/7] Add PageMlocked() page state bit and lru infrastructure
Message-ID: <20070215145138.GT10108@waste.org>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com> <20070215012459.5343.72021.sendpatchset@schroedinger.engr.sgi.com> <20070215020916.GS10108@waste.org> <Pine.LNX.4.64.0702141829410.5747@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702141829410.5747@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 14, 2007 at 06:30:06PM -0800, Christoph Lameter wrote:
> On Wed, 14 Feb 2007, Matt Mackall wrote:
> 
> > I think we should be much more precise in documenting the semantics of
> > these bits. This particular comment is imprecise enough to be
> > incorrect. This bit being set indicates that we saw that it was
> > mlocked at some point in the past, not any guarantee that it's mlocked
> > now. And the same for the converse.
> 
> See further down in the patch. The semantics are described when the 
> PageMlockedXXX ops are defined.

Fine. But -this- comment is still incorrect. If someone were to ask
"what does this bit mean?" they would go the list of bit definitions
and leave with the -wrong- answer. The page is not necessarily
mlocked, it's just on the lazy mlock list.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
