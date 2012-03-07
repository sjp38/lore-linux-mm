Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 1FA3C6B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 09:48:30 -0500 (EST)
Date: Wed, 7 Mar 2012 11:46:44 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH -v2] mm: SLAB Out-of-memory diagnostics
Message-ID: <20120307144643.GB2009@x61.redhat.com>
References: <20120305181041.GA9829@x61.redhat.com>
 <4F56ECE6.4010100@gmail.com>
 <alpine.DEB.2.00.1203062142290.6424@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1203062142290.6424@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>

On Tue, Mar 06, 2012 at 09:42:57PM -0800, David Rientjes wrote:
> On Wed, 7 Mar 2012, Cong Wang wrote:
> 
> > > Following the example at mm/slub.c, add out-of-memory diagnostics to the
> > > SLAB allocator to help on debugging certain OOM conditions.
> > > 
> > > An example print out looks like this:
> > > 
> > >    <snip page allocator out-of-memory message>
> > >    SLAB: Unable to allocate memory on node 0 (gfp=0x11200)
> > >       cache: bio-0, object size: 192, order: 0
> > >       node0: slabs: 3/3, objs: 60/60, free: 0
> > > 
> > 
> > Nitpick:
> > 
> > What about "node: 0" instead of "node0: " ?
> > 
> 
> Good catch, that format would match the output of the slub out-of-memory 
> messages.
>

To be honest, I really don't see a big advantage on the nitpick, however, if we
want to accurately copycat the slub output here, I can insert a blank space
between the word and the digit, like the following:
   "node #: ..."

  Rafael 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
