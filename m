Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id EA2626B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 17:14:22 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2496254pbb.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 14:14:22 -0700 (PDT)
Date: Thu, 31 May 2012 14:14:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Common 01/22] [slob] Define page struct fields used in
 mm_types.h
In-Reply-To: <20120523203505.599591201@linux.com>
Message-ID: <alpine.DEB.2.00.1205311414090.2764@chino.kir.corp.google.com>
References: <20120523203433.340661918@linux.com> <20120523203505.599591201@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

On Wed, 23 May 2012, Christoph Lameter wrote:

> Define the fields used by slob in mm_types.h and use struct page instead
> of struct slob_page in slob. This cleans up numerous of typecasts in slob.c and
> makes readers aware of slob's use of page struct fields.
> 
> [Also cleans up some bitrot in slob.c. The page struct field layout
> in slob.c is an old layout and does not match the one in mm_types.h]
> 
> Reviewed-by: Glauber Costa <gommer@parallels.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
