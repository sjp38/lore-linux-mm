Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id CC9516B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:16:48 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:16:47 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK1 [06/13] Common kmalloc slab index determination
In-Reply-To: <50655F8D.5010706@parallels.com>
Message-ID: <0000013a0d3c9dcb-648d3df7-f86c-4255-acc7-43ccc8a311ba-000000@email.amazonses.com>
References: <20120926200005.911809821@linux.com> <0000013a043cdd82-a153095d-219a-467a-b0f2-c799f5ddbb05-000000@email.amazonses.com> <50655F8D.5010706@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Fri, 28 Sep 2012, Glauber Costa wrote:

> > +	if (size <=  8 * 1024 * 1024) return 23;
> > +	if (size <=  16 * 1024 * 1024) return 24;
> > +	if (size <=  32 * 1024 * 1024) return 26;
> > +	if (size <=  64 * 1024 * 1024) return 27;
> > +	BUG();
> > +
> > +	/* Will never be reached. Needed because the compiler may complain */
> > +	return -1;
> > +}
> > +
>
> That is a bunch of branches... can't we use ilog2 for that somehow ?

Believe me we have tried but the c compiler had issue with constant
folding. ilog2 is used for the non inlined version.

> In any case, you skipped "return 25".

Thanks. Fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
