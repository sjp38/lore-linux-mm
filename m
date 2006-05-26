Date: Thu, 25 May 2006 18:23:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Add /proc/sys/vm/drop_node_caches
In-Reply-To: <20060525173139.036356bf.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0605251753270.27701@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605251653090.27354@schroedinger.engr.sgi.com>
 <20060525170509.331aaf2d.akpm@osdl.org> <Pine.LNX.4.64.0605251706350.27460@schroedinger.engr.sgi.com>
 <20060525173139.036356bf.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 May 2006, Andrew Morton wrote:

> Christoph Lameter <clameter@sgi.com> wrote:
> >
> > On Thu, 25 May 2006, Andrew Morton wrote:
> > 
> > > If we're talking about some formal, supported access to the kernel's NUMA
> > > facilities then poking away at /proc doesn't seem a particularly good way
> > > of doing it.  The application _should_ be able to set its memory policy to
> > > point at that node and get all the old caches evicted automatically.  If
> > > that doesn't work, what's wrong?
> > 
> > zone_reclaim does exactly that for an application. So that case is 
> > covered.
> > 
> > However, there are situations in which someone wants to insure that there 
> > is no pagecache on some nodes (testing and some special apps).
> 
> What situations?  Why doesn't zone_reclaim suit in those cases?

We already have your hack for all nodes. Most of our systems are segmented 
into subsets of nodes so there is a desire to have that same hack for some 
nodes. The same arguments that justified the introduction of drop_cache 
also justify drop_node_caches. Tests will produce more consistent 
results and applications can be sure to start with all of memory free. Its 
only active for CONFIG_NUMA.

I can check and see if I find more supporting arguments tomorrow when 
I have a chance to talk with those who want this feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
