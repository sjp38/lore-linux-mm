Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id DBABA6B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 09:45:29 -0400 (EDT)
Date: Fri, 12 Jul 2013 13:45:28 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm/slub.c: remove 'per_cpu' which is useless
 variable
In-Reply-To: <51DF4C94.3060103@asianux.com>
Message-ID: <0000013fd32114a7-6d601dfe-1d70-46cc-aa10-7d2898f5ceec-000000@email.amazonses.com>
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com> <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com> <51DEF935.4040804@kernel.org>
 <0000013fcf608df8-457e2029-51f9-4e49-9992-bf399a97d953-000000@email.amazonses.com> <51DF4540.8060700@asianux.com> <51DF4C94.3060103@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, 12 Jul 2013, Chen Gang wrote:

> Remove 'per_cpu', since it is useless now after the patch: "205ab99
> slub: Update statistics handling for variable order slabs". And the
> partial list is handled in the same way as the per cpu slab.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
