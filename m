Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 3F7146B00E7
	for <linux-mm@kvack.org>; Tue, 22 May 2012 12:22:29 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so5965135qcs.14
        for <linux-mm@kvack.org>; Tue, 22 May 2012 09:22:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FBA0A94.8000803@parallels.com>
References: <20120518161906.207356777@linux.com>
	<20120518161931.570041085@linux.com>
	<4FBA0A94.8000803@parallels.com>
Date: Wed, 23 May 2012 01:22:28 +0900
Message-ID: <CAAmzW4OmgKhtggK8m=uBuGZ=mXbg0EdP2WyMTU-RqeqhJS-pXw@mail.gmail.com>
Subject: Re: [RFC] Common code 08/12] slabs: list addition move to slab_common
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Alex Shi <alex.shi@intel.com>

> On 05/18/2012 08:19 PM, Christoph Lameter wrote:
>>
>> Move the code to append the new kmem_cache to the list of slab caches to
>> the kmem_cache_create code in the shared code.
>>
>> This is possible now since the acquisition of the mutex was moved into
>> kmem_cache_create().
>>
>> Signed-off-by: Christoph Lameter<cl@linux.com>
>
> Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
