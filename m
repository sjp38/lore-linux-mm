Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 1FE4D6B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 10:39:36 -0400 (EDT)
Received: by ggm4 with SMTP id 4so7822993ggm.14
        for <linux-mm@kvack.org>; Tue, 22 May 2012 07:39:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FBA090B.4070200@parallels.com>
References: <20120518161906.207356777@linux.com>
	<20120518161928.691250633@linux.com>
	<4FBA090B.4070200@parallels.com>
Date: Tue, 22 May 2012 23:39:35 +0900
Message-ID: <CAAmzW4MJKRvS86Rhqq7SL7YsnvBYvPpFAks7=o3=PSkJPQW1sw@mail.gmail.com>
Subject: Re: [RFC] Common code 03/12] Extract common fields from struct kmem_cache
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Alex Shi <alex.shi@intel.com>

> On 05/18/2012 08:19 PM, Christoph Lameter wrote:
>>
>> Define "COMMON" to include definitions for fields used in all
>> slab allocators. After that it will be possible to share code that
>> only operates on those fields of kmem_cache.
>>
>> The patch basically takes the slob definition of kmem cache and
>> uses the field namees for the other allocators.
>>
>> The slob definition of kmem_cache is moved from slob.c to slob_def.h
>> so that the location of the kmem_cache definition is the same for
>> all allocators.
>>
>> Signed-off-by: Christoph Lameter<cl@linux.com>
>
>
> Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
