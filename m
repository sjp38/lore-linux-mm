Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5DD596B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 09:36:24 -0400 (EDT)
Message-ID: <508E8651.1080809@parallels.com>
Date: Mon, 29 Oct 2012 17:36:17 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK4 [00/15] Sl[auo]b: Common kmalloc caches V4
References: <0000013a934eed6d-a9c1b247-dbbc-485d-b7cf-89aa36dcca57-000000@email.amazonses.com>
In-Reply-To: <0000013a934eed6d-a9c1b247-dbbc-485d-b7cf-89aa36dcca57-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 10/24/2012 07:05 PM, Christoph Lameter wrote:
> V3->V4:
>  - Further fixes of issues pointed out by Joonsoo and Glauber.
> 
> V2-V3:
> - Further cleanup and reordering as suggested by Glauber
> 
> V1-V2:
> - Clean up numerous things as suggested by Glauber.
> - Add two more patches that extract more kmalloc stuff
>   into common files.
> 
> This patchset cleans up the bootstrap of the allocators
> and creates a common functions to handle the kmalloc
> array. The results are more common data structures and
> functions that will simplify further work
> on having common functions for all allocators.
> 
> This patchset is against Pekka's slab/next tree as of today.

It looks good to me.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
