Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 390CC6B00AA
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:31:05 -0400 (EDT)
Date: Fri, 24 Aug 2012 16:31:03 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] slub: correct the calculation of the number of cpu
 objects in get_partial_node
In-Reply-To: <CAAmzW4ORnSLMdhVPmYPpeEJ=P1rrpz1LOibOYWQJgOYQxmDhuA@mail.gmail.com>
Message-ID: <000001395978f794-7569c405-1955-4e20-ad74-6e60ee4efcdc-000000@email.amazonses.com>
References: <1345824303-30292-1-git-send-email-js1304@gmail.com> <1345824303-30292-2-git-send-email-js1304@gmail.com> <00000139596a800b-875d7863-23ac-44a5-8710-ea357f3df8a8-000000@email.amazonses.com>
 <CAAmzW4ORnSLMdhVPmYPpeEJ=P1rrpz1LOibOYWQJgOYQxmDhuA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 25 Aug 2012, JoonSoo Kim wrote:

> But, when using "cpu_partial_objects", I have a coding style problem.
>
>                 if (kmem_cache_debug(s)
>                         || cpu_slab_objects + cpu_partial_objects
>                                                 > s->max_cpu_object / 2)
>
> Do you have any good idea?

Not sure what the problem is? The line wrap?

Reduce the tabs for the third line?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
