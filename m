Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 71D406B0044
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 14:13:31 -0400 (EDT)
Date: Thu, 2 Aug 2012 13:13:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [00/16] Sl[auo]b: Common code rework V8
In-Reply-To: <501AC247.8020306@parallels.com>
Message-ID: <alpine.DEB.2.00.1208021313040.27953@router.home>
References: <20120801211130.025389154@linux.com> <501A3F1E.4060307@parallels.com> <alpine.DEB.2.00.1208020912340.23049@router.home> <501A8BE4.4060206@parallels.com> <alpine.DEB.2.00.1208020941150.23049@router.home> <501A92FB.8020906@parallels.com>
 <alpine.DEB.2.00.1208021305200.27953@router.home> <501AC247.8020306@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Glauber Costa wrote:

> On 08/02/2012 10:07 PM, Christoph Lameter wrote:
> > I got my tree working cleanly now by removing the one kfree for s->name
> > that I missed in kmem_cache_release and by removing the refcount
> > modifications from the last patch. I put them in a separate patch.
> > Applying that patch causes the problem.
> >
> > Can you skip the last patch for now or do you want another set posted?
> >
>
> What is "the last patch" Patc 16/16 doesn't seem to have anything to do
> with it.

The patch that reduces the parameters to __kmem_cache_create.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
