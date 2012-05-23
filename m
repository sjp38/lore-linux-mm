Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id B415C6B0092
	for <linux-mm@kvack.org>; Wed, 23 May 2012 12:17:11 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so7048115qcs.14
        for <linux-mm@kvack.org>; Wed, 23 May 2012 09:17:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FBA0C5E.4010102@parallels.com>
References: <20120518161906.207356777@linux.com>
	<20120518161932.708441342@linux.com>
	<4FBA0C5E.4010102@parallels.com>
Date: Thu, 24 May 2012 01:17:10 +0900
Message-ID: <CAAmzW4OvB+jG+RcOcV+6Cxoq4pZzRGxU=kCrpkmjEYdFTbqP6Q@mail.gmail.com>
Subject: Re: [RFC] Common code 10/12] sl[aub]: Use the name "kmem_cache" for
 the slab cache with the kmem_cache structure.
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Alex Shi <alex.shi@intel.com>

2012/5/21 Glauber Costa <glommer@parallels.com>:
> On 05/18/2012 08:19 PM, Christoph Lameter wrote:
>>
>> Make all allocators use the "kmem_cache" slabname for the "kmem_cache"
>> structure.
>>
>> Signed-off-by: Christoph Lameter<cl@linux.com>
>
> This is a good change.
>
> Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
