Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 5AB776B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 06:25:29 -0400 (EDT)
Message-ID: <501A54E9.8020002@parallels.com>
Date: Thu, 2 Aug 2012 14:22:33 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [12/16] create common create_kmalloc_cache()
References: <20120801211130.025389154@linux.com> <20120801211202.431857668@linux.com>
In-Reply-To: <20120801211202.431857668@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 01:11 AM, Christoph Lameter wrote:
> Use a special function to create kmalloc caches and use that function in
> SLAB and SLUB.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---

Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
