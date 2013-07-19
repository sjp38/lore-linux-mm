Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 1FE3C6B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 09:57:30 -0400 (EDT)
Date: Fri, 19 Jul 2013 13:57:28 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub.c: add parameter length checking for
 alloc_loc_track()
In-Reply-To: <51E882E1.4000504@gmail.com>
Message-ID: <0000013ff73897b8-9d8f4486-1632-470c-8f1f-caf44932cef1-000000@email.amazonses.com>
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com> <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com> <51DEF935.4040804@kernel.org>
 <0000013fcf608df8-457e2029-51f9-4e49-9992-bf399a97d953-000000@email.amazonses.com> <51DF4540.8060700@asianux.com> <51DF4C94.3060103@asianux.com> <51DF5404.4060004@asianux.com> <0000013fd3250e40-1832fd38-ede3-41af-8fe3-5a0c10f5e5ce-000000@email.amazonses.com>
 <51E33F98.8060201@asianux.com> <0000013fe2e73e30-817f1bdb-8dc7-4f7b-9b60-b42d5d244fda-000000@email.amazonses.com> <51E49BDF.30008@asianux.com> <0000013fed280250-85b17e35-d4d4-468d-abed-5b2e29cedb94-000000@email.amazonses.com> <51E73A16.8070406@asianux.com>
 <0000013ff2076fb0-b52e0245-8fb5-4842-b0dd-d812ce2c9f62-000000@email.amazonses.com> <51E882E1.4000504@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang F T <chen.gang.flying.transformer@gmail.com>
Cc: Chen Gang <gang.chen@asianux.com>, Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, 19 Jul 2013, Chen Gang F T wrote:

> Yes, "'max' can roughly mean the same thing", but they are still a
> little different.
>
> 'max' also means: "the caller tells callee: I have told you the
> maximize buffer length, so I need not check the buffer length to be
> sure of no memory overflow, you need be sure of it".
>
> 'size' means: "the caller tells callee: you should use the size which I
> give you, I am sure it is OK, do not care about whether it can cause
> memory overflow or not".

Ok that makes sense.

> The diff may like this:

I am fine with such a patch.

Ultimately I would like the tracking and debugging technology to be
abstracted from the slub allocator and made generally useful by putting it
into mm/slab_common.c. SLAB has similar things but does not have all the
features.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
