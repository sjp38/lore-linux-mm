Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 65449620001
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 15:14:02 -0500 (EST)
Subject: Re: [PATCH 09/10] mm/slab.c: Fix continuation line formats
From: Joe Perches <joe@perches.com>
In-Reply-To: <1264968523.3536.1801.camel@calx>
References: <cover.1264967493.git.joe@perches.com>
	 <9d64ab1e1d69c750d53a398e09fe5da2437668c5.1264967500.git.joe@perches.com>
	 <1264968523.3536.1801.camel@calx>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 31 Jan 2010 12:13:59 -0800
Message-ID: <1264968839.25140.169.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2010-01-31 at 14:08 -0600, Matt Mackall wrote:
> On Sun, 2010-01-31 at 12:02 -0800, Joe Perches wrote:
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 7451bda..9964619 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -4228,8 +4228,8 @@ static int s_show(struct seq_file *m, void *p)
> >  		unsigned long node_frees = cachep->node_frees;
> >  		unsigned long overflows = cachep->node_overflow;
> >  
> > -		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu \
> > -				%4lu %4lu %4lu %4lu %4lu", allocs, high, grown,
> > +		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu 				%4lu %4lu %4lu %4lu %4lu",
> > +				allocs, high, grown,
> 
> Yuck. The right way to do this is by mergeable adjacent strings, eg:
> 
> printk("part 1..."
>        " part 2...", ...);

Yuck indeed.

I think format strings shouldn't be split across multiple lines and
the right thing to do is to use a single space instead of the tabs.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
