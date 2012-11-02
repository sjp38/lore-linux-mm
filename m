Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 96E606B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 16:11:59 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2958850pad.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 13:11:58 -0700 (PDT)
Date: Fri, 2 Nov 2012 13:11:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: CK5 [01/18] Use correct cpu_slab on dead cpu
In-Reply-To: <0000013abdf0bd68-4a493a6a-3009-4ee4-8a66-1029eee65507-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1211021311260.5902@chino.kir.corp.google.com>
References: <20121101214538.971500204@linux.com> <0000013abdf0bd68-4a493a6a-3009-4ee4-8a66-1029eee65507-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, elezegarcia@gmail.com

On Thu, 1 Nov 2012, Christoph Lameter wrote:

> Pass a kmem_cache_cpu pointer into unfreeze partials so that a different
> kmem_cache_cpu structure than the local one can be specified.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2012-11-01 10:10:05.073716747 -0500
> +++ linux/mm/slub.c	2012-11-01 10:10:06.173734998 -0500
> @@ -1871,10 +1871,10 @@ redo:
>   *
>   * This function must be called with interrupt disabled.

Should probably say interrupts disabled for c's cpu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
