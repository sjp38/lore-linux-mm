Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 572CA6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 09:53:31 -0500 (EST)
Date: Fri, 25 Jan 2013 14:53:29 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: FIX [1/2] slub: Do not dereference NULL pointer in node_match
In-Reply-To: <1359101516.16101.6.camel@kernel>
Message-ID: <0000013c7232fa91-a8f59c62-a7c6-4937-89b9-8c53d86df7b1-000000@email.amazonses.com>
References: <20130123214514.370647954@linux.com> <0000013c695fbd30-9023bc55-f780-4d44-965f-ab4507e483d5-000000@email.amazonses.com> <1358988824.3351.5.camel@kernel> <0000013c6d200e1d-03ae09c1-6fb8-42eb-ab6c-8fcae05fdb6e-000000@email.amazonses.com>
 <1359101516.16101.6.camel@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Fri, 25 Jan 2013, Simon Jeons wrote:

> >
> > node_match(NULL, xx) = 0
> >
> >  	->
> >
> > call into __slab_alloc.
> >
> > __slab_alloc() will check for !c->page which requires the assignment of a
> > new per cpu slab page.
> >
>
> But there are dereference in page_to_nid path, function page_to_section:
> return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;

node_match() checks for NULL and will not invoke page_to_nid for a NULL
pointer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
