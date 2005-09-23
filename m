Date: Thu, 22 Sep 2005 18:58:04 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] Increase maximum kmalloc size to 256K
Message-ID: <20050923005804.GI26389@parisc-linux.org>
References: <Pine.LNX.4.62.0509221306380.18133@schroedinger.engr.sgi.com> <20050922131521.77da1684.akpm@osdl.org> <Pine.LNX.4.62.0509221329270.18240@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0509221329270.18240@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, manfred@colorfulllife.com
List-ID: <linux-mm.kvack.org>

On Thu, Sep 22, 2005 at 01:55:43PM -0700, Christoph Lameter wrote:
> On Thu, 22 Sep 2005, Andrew Morton wrote:
> 
> > Christoph Lameter <clameter@engr.sgi.com> wrote:
> > >
> > >  The workqueue structure can grow larger than 128k under 2.6.14-rc2 (with 
> > >  all debugging features enabled on 64 bit platforms)
> > 
> > Would it be better to use alloc_percpu() in there?  Bearing in mind that
> > one day we'll probably have an alloc_percpu() which incurs one less
> > indirection and which allocates things node-affinely.
> 
> Yes I am working on a patch like that right now. But there is still the 
> danger that other structures also may get big in the future. It would 
> be best to raise the limit.

It would be better to leave the limit alone so other structures which
get ridiculously big are also caught and fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
