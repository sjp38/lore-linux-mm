Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 05E1C6B0031
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 11:16:14 -0400 (EDT)
Date: Mon, 15 Jul 2013 15:16:13 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub.c: add parameter length checking for
 alloc_loc_track()
In-Reply-To: <51E33F98.8060201@asianux.com>
Message-ID: <0000013fe2e73e30-817f1bdb-8dc7-4f7b-9b60-b42d5d244fda-000000@email.amazonses.com>
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com> <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com> <51DEF935.4040804@kernel.org>
 <0000013fcf608df8-457e2029-51f9-4e49-9992-bf399a97d953-000000@email.amazonses.com> <51DF4540.8060700@asianux.com> <51DF4C94.3060103@asianux.com> <51DF5404.4060004@asianux.com> <0000013fd3250e40-1832fd38-ede3-41af-8fe3-5a0c10f5e5ce-000000@email.amazonses.com>
 <51E33F98.8060201@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, 15 Jul 2013, Chen Gang wrote:

> On 07/12/2013 09:49 PM, Christoph Lameter wrote:
> > On Fri, 12 Jul 2013, Chen Gang wrote:
> >
> >> Since alloc_loc_track() will alloc additional space, and already knows
> >> about 'max', so need be sure of 'max' must be larger than 't->count'.
> >
> > alloc_loc_track is only called if t->count > max from add_location:
> >
>
> For add_location(), if "t->count > t->max", it calls alloc_loc_track()
> with "max == 2 * t->max".
>
> In this case we need be sure that "t->count < 2 * t->max".

We are sure about that since t->count is always incremented by one and
then checked against t->max. The location database is build up from a
single hardware thread without any concurrency.

So we do not really need this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
