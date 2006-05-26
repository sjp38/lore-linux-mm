Date: Thu, 25 May 2006 17:31:39 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Add /proc/sys/vm/drop_node_caches
Message-Id: <20060525173139.036356bf.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605251706350.27460@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605251653090.27354@schroedinger.engr.sgi.com>
	<20060525170509.331aaf2d.akpm@osdl.org>
	<Pine.LNX.4.64.0605251706350.27460@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Thu, 25 May 2006, Andrew Morton wrote:
> 
> > If we're talking about some formal, supported access to the kernel's NUMA
> > facilities then poking away at /proc doesn't seem a particularly good way
> > of doing it.  The application _should_ be able to set its memory policy to
> > point at that node and get all the old caches evicted automatically.  If
> > that doesn't work, what's wrong?
> 
> zone_reclaim does exactly that for an application. So that case is 
> covered.
> 
> However, there are situations in which someone wants to insure that there 
> is no pagecache on some nodes (testing and some special apps).

What situations?  Why doesn't zone_reclaim suit in those cases?

We'd need considerably more detail to be able to justify a hacky thing like
this please.  Bear in mind that if we do this and people start using it then

a) that'll cause us to avoid doing it properly (however that is)

b) if people are using this /proc hack to work around inadequacies in
   the NUMA support then it'll decrease the pressure on us to fix up that
   numa support.

c) it's something we'll need to support for ever and ever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
