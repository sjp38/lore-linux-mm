Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 837BD6B0075
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 11:10:43 -0400 (EDT)
Date: Fri, 6 Jul 2012 10:10:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] slub: release a lock if freeing object with a lock
 is failed in __slab_free()
In-Reply-To: <CAAmzW4P941qeKy6UH079r73zR5VjUeNZNB53Mi4wiHE28f==gg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207061008560.28648@router.home>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com> <1340389359-2407-3-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207050924330.4138@router.home> <CAAmzW4NJyX9e_dMyJBA5zDiVYVmL1vbUkaRHNoSbbhDZWW7iMg@mail.gmail.com>
 <alpine.DEB.2.00.1207060928580.26790@router.home> <CAAmzW4P941qeKy6UH079r73zR5VjUeNZNB53Mi4wiHE28f==gg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 6 Jul 2012, JoonSoo Kim wrote:

> >> At CPU2, we don't need lock anymore, because this slab already in partial list.
> >
> > For that scenario we could also simply do a trylock there and redo
> > the loop if we fail. But still what guarantees that another process will
> > not modify the page struct between fetching the data and a successful
> > trylock?
>
>
> I'm not familiar with English, so take my ability to understand into
> consideration.

I have a hard time understanding what you want to accomplish here.

> we don't need guarantees that another process will not modify
> the page struct between fetching the data and a successful trylock.

No we do not need that since the cmpxchg will then fail.

Maybe it would be useful to split this patch into two?

One where you introduce the dropping of the lock and the other where you
get rid of certain code paths?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
