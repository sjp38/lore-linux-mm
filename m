Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 73D126B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:14:53 -0400 (EDT)
Date: Thu, 2 Aug 2012 09:14:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [13/16] slub: Introduce function for opening boot
 caches
In-Reply-To: <501A5593.5090704@parallels.com>
Message-ID: <alpine.DEB.2.00.1208020914230.23049@router.home>
References: <20120801211130.025389154@linux.com> <20120801211202.982983350@linux.com> <501A5593.5090704@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Glauber Costa wrote:

> On 08/02/2012 01:11 AM, Christoph Lameter wrote:
> > Basically the same thing happens for various boot caches.
> > Provide a function.
> >
> > Signed-off-by: Christoph Lameter <cl@linux.com>
> >
> > ---
>
> I can't spot any problems with the patch per-se, but I honestly also
> don't see the point for it.

Well yes the patch could stand along from this series. Just a way to avoid
having to repeat code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
