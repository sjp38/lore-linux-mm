Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 0BC986B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 09:53:17 -0400 (EDT)
Date: Fri, 12 Jul 2013 13:53:16 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub.c: use 'unsigned long' instead of 'int' for
 variable 'slub_debug'
In-Reply-To: <51DF5F43.3080408@asianux.com>
Message-ID: <0000013fd3283b9c-b5fe217c-fff3-47fd-be0b-31b00faba1f3-000000@email.amazonses.com>
References: <51DF5F43.3080408@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org

On Fri, 12 Jul 2013, Chen Gang wrote:

> Since all values which can be assigned to 'slub_debug' are 'unsigned
> long', recommend also to define 'slub_debug' as 'unsigned long' to
> match the type precisely

The bit definitions in slab.h as well as slub.c all assume that these are
32 bit entities. See f.e. the defition of the internal slub flags:

/* Internal SLUB flags */
#define __OBJECT_POISON         0x80000000UL /* Poison object */
#define __CMPXCHG_DOUBLE        0x40000000UL /* Use cmpxchg_double */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
