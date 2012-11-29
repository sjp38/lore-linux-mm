Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 7CE0D6B005A
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 04:38:59 -0500 (EST)
Message-ID: <50B72D2F.9020400@parallels.com>
Date: Thu, 29 Nov 2012 13:38:55 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK5 [5/6] slab: Use the new create_boot_cache function to simplify
 bootstrap
References: <20121128162238.111670741@linux.com> <0000013b47d436ad-e9d7b412-0551-49d6-992f-a9adb5de5dfa-000000@email.amazonses.com>
In-Reply-To: <0000013b47d436ad-e9d7b412-0551-49d6-992f-a9adb5de5dfa-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 11/28/2012 08:23 PM, Christoph Lameter wrote:
> Simplify setup and reduce code in kmem_cache_init(). This allows us to
> get rid of initarray_cache as well as the manual setup code for
> the kmem_cache and kmem_cache_node arrays during bootstrap.
> 
> We introduce a new bootstrap state "PARTIAL" for slab that signals the
> creation of a kmem_cache boot cache.
> 
> V1->V2: Get rid of initarray_cache as well.
> V2->V3: Drop the setting of slab_state to PARTIAL [glommer]
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

It looks good to me.

Reviewed-by: Glauber Costa <glommer@parallels.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
