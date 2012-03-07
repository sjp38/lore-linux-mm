Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id C80A36B004D
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 00:43:00 -0500 (EST)
Received: by iajr24 with SMTP id r24so10578895iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 21:43:00 -0800 (PST)
Date: Tue, 6 Mar 2012 21:42:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -v2] mm: SLAB Out-of-memory diagnostics
In-Reply-To: <4F56ECE6.4010100@gmail.com>
Message-ID: <alpine.DEB.2.00.1203062142290.6424@chino.kir.corp.google.com>
References: <20120305181041.GA9829@x61.redhat.com> <4F56ECE6.4010100@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>

On Wed, 7 Mar 2012, Cong Wang wrote:

> > Following the example at mm/slub.c, add out-of-memory diagnostics to the
> > SLAB allocator to help on debugging certain OOM conditions.
> > 
> > An example print out looks like this:
> > 
> >    <snip page allocator out-of-memory message>
> >    SLAB: Unable to allocate memory on node 0 (gfp=0x11200)
> >       cache: bio-0, object size: 192, order: 0
> >       node0: slabs: 3/3, objs: 60/60, free: 0
> > 
> 
> Nitpick:
> 
> What about "node: 0" instead of "node0: " ?
> 

Good catch, that format would match the output of the slub out-of-memory 
messages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
