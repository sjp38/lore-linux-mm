Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 3126E6B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 09:26:07 -0400 (EDT)
Message-ID: <50645322.7000407@parallels.com>
Date: Thu, 27 Sep 2012 17:22:42 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK1 [02/13] create common functions for boot slab creation
References: <20120926200005.911809821@linux.com> <0000013a042b9869-e49d65b2-0216-4010-8c8c-b12654aa219e-000000@email.amazonses.com>
In-Reply-To: <0000013a042b9869-e49d65b2-0216-4010-8c8c-b12654aa219e-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 09/27/2012 12:01 AM, Christoph Lameter wrote:
> Use a special function to create kmalloc caches and use that function in
> SLAB and SLUB.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Seems ok.
Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
