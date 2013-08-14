Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id C29EE6B0037
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 12:40:25 -0400 (EDT)
Date: Wed, 14 Aug 2013 16:40:24 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [3.12 1/3] Move kmallocXXX functions to common code
In-Reply-To: <520BA215.6010207@iki.fi>
Message-ID: <000001407db319e3-26cded64-dc7f-40ee-8ca4-2a27c7cb7a34-000000@email.amazonses.com>
References: <20130813154940.741769876@linux.com> <00000140785e1062-89326db9-3999-43c1-b081-284dd49b3d9b-000000@email.amazonses.com> <520B9A0E.4020009@fastmail.fm> <520BA215.6010207@iki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Pekka Enberg <penberg@fastmail.fm>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Wed, 14 Aug 2013, Pekka Enberg wrote:

> On 08/14/2013 05:54 PM, Pekka Enberg wrote:
> > I already applied an earlier version that's now breaking linux-next.
> > Can you please send incremental fixes on top of slab/next?
> > I'd prefer not to rebase...
>
> Ok, I rebased anyway and dropped the broken commits. I'm not
> happy that this bundles kmalloc_large(), though, so it needs to
> be taken out for me to merge this.

kmalloc_large is already available for slub. I just made it generally
available. slob large allocations now also fallback to kmalloc_large. We
could just disable it for SLAB?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
