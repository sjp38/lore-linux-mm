Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 52A116B0068
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 04:42:26 -0500 (EST)
Message-ID: <50B72DFE.2040209@parallels.com>
Date: Thu, 29 Nov 2012 13:42:22 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK5 [6/6] Common alignment code
References: <20121128162238.111670741@linux.com> <0000013b47d45710-368fdf96-d763-43ad-b670-3cade26ebd9e-000000@email.amazonses.com>
In-Reply-To: <0000013b47d45710-368fdf96-d763-43ad-b670-3cade26ebd9e-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 11/28/2012 08:23 PM, Christoph Lameter wrote:
> Extract the code to do object alignment from the allocators.
> Do the alignment calculations in slab_common so that the
> __kmem_cache_create functions of the allocators do not have
> to deal with alignment.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Looks decent and straightforward enough.

Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
