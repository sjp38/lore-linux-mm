Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id B5D5E6B0031
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 10:15:43 -0400 (EDT)
Date: Tue, 2 Jul 2013 14:15:42 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm/slub: Fix slub calculate active slabs
 uncorrectly
In-Reply-To: <51d218df.a77d440a.3cfe.ffffe64aSMTPIN_ADDED_BROKEN@mx.google.com>
Message-ID: <0000013f9fbd247d-8de715f1-e0dc-47fb-8f06-af6c061044be-000000@email.amazonses.com>
References: <1372291059-9880-1-git-send-email-liwanp@linux.vnet.ibm.com> <0000013f9b8d6897-d2399224-d203-4dc5-a700-90dea9be7536-000000@email.amazonses.com> <51d218df.a77d440a.3cfe.ffffe64aSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2 Jul 2013, Wanpeng Li wrote:

> Before patch:
> Active / Total Slabs (% used) : 59018 / 59018 (100.0%)
>
> After patch:
> Active / Total Slabs (% used) : 11086 / 11153 (99.4%)

Yes I saw that.

> These numbers are dump from slabtop for monitor slub, before patch Active / Total
> Slabs are always 100%, this is not truth since empty slabs present. However, the
> slab allocator can caculate its Active / Total Slabs correctly and its value is
> less than 100.0%. By comparison, slub is more efficient than slab through slabtop
> observation, however, it is not truth since slub uncorrectly calculate its
> Active / Total Slabs.

I always thought about the "empty" slabs to be active since they are used
for allocation and frees like the other partial slabs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
