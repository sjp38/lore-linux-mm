Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 6035E6B0033
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 11:03:12 -0400 (EDT)
Date: Wed, 17 Jul 2013 15:03:10 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub.c: add parameter length checking for
 alloc_loc_track()
In-Reply-To: <51E49BDF.30008@asianux.com>
Message-ID: <0000013fed280250-85b17e35-d4d4-468d-abed-5b2e29cedb94-000000@email.amazonses.com>
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com> <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com> <51DEF935.4040804@kernel.org>
 <0000013fcf608df8-457e2029-51f9-4e49-9992-bf399a97d953-000000@email.amazonses.com> <51DF4540.8060700@asianux.com> <51DF4C94.3060103@asianux.com> <51DF5404.4060004@asianux.com> <0000013fd3250e40-1832fd38-ede3-41af-8fe3-5a0c10f5e5ce-000000@email.amazonses.com>
 <51E33F98.8060201@asianux.com> <0000013fe2e73e30-817f1bdb-8dc7-4f7b-9b60-b42d5d244fda-000000@email.amazonses.com> <51E49BDF.30008@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, 16 Jul 2013, Chen Gang wrote:

> Hmm... what you says above is reasonable.
>
> In this case, since alloc_loc_track() is a static function, it will
> depend on the related maintainers' willing and opinions to decide
> whether add the related check or not (just like add 'BUG_ON' or not).
>
> I need respect the original related maintainers' willing and opinions.

You are talking to the author of the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
