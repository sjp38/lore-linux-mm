Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 545B46B0036
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 11:56:54 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so1385613wgh.14
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 08:56:53 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id lt4si12903350icc.60.2014.06.05.08.56.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 08:56:53 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so1086358iec.33
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 08:56:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53908D10.7080809@ubuntu.com>
References: <53908D10.7080809@ubuntu.com>
Date: Thu, 5 Jun 2014 19:56:52 +0400
Message-ID: <CALYGNiNupJLmMV4ehMb9r9hxefBmbLoW2aZ2E0eZ=C=Y1rDXZQ@mail.gmail.com>
Subject: Re: Dump struct page array?
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: linux-mm <linux-mm@kvack.org>

On Thu, Jun 5, 2014 at 7:30 PM, Phillip Susi <psusi@ubuntu.com> wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> Is there a way to dump the struct page array or perhaps even a tool to
> analyze it?  I would like to get a map of what pages are in use, or in
> particular, where all of the unmovable pages are.

Have you seen "page-types"? tools/vm/page-types.c in the kernel source tree.

> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v2.0.17 (MingW32)
> Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/
>
> iQEcBAEBAgAGBQJTkI0QAAoJEI5FoCIzSKrwcrcH/AiOUvh5osAFezgR2pGlp3Iy
> G+rvqzHdgFFef2RX057ehK+lj2nW8fNFyCy/zKR0aaueyH88yj4nFgoZw060cklo
> 0P5Fcvim1BKhPMUpD+0J8XaFEP9WD95/Q5XPqmfSUf64VrwPQSLcppwUJPO+ec7D
> PBEctU9EvnXKPtrQRui44t6U0VRRvsN2OaRI8tZR7ou7V0FrOe86GdyXFRu8dsTN
> 22hy9A0JqTldjM9ebbr8xCu5cRRQFkUZSFqBv2lnnox+V8/1M8N8ZwCbkayQiyMQ
> pW7DMTottjGsXrq/+l96UF2aWQv5PIof9NR4FJ3YSFdo1YvTfUozSLbX24KCQFI=
> =t4Q0
> -----END PGP SIGNATURE-----
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
