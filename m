Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id D5BAB6B0074
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 12:45:18 -0400 (EDT)
Date: Thu, 11 Jul 2013 16:45:17 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub.c: remove 'per_cpu' which is useless variable
In-Reply-To: <51DE55C9.1060908@asianux.com>
Message-ID: <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com>
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 11 Jul 2013, Chen Gang wrote:

> On 07/11/2013 02:45 PM, Pekka Enberg wrote:
> > Hi,
> >
> > On 07/08/2013 11:07 AM, Chen Gang wrote:
> >> Remove 'per_cpu', since it is useless now after the patch: "205ab99
> >> slub: Update statistics handling for variable order slabs".
> >
> > Whoa, that's a really old commit. Christoph?

Gosh we have some code duplication there. Patch mismerged?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
