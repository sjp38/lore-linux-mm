Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 0EE816B00EB
	for <linux-mm@kvack.org>; Tue, 22 May 2012 11:25:14 -0400 (EDT)
Message-ID: <4FBBAF5E.2020308@parallels.com>
Date: Tue, 22 May 2012 19:23:10 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] Common code 04/12] slabs: Extract common code for kmem_cache_create
References: <20120518161906.207356777@linux.com> <20120518161929.264565121@linux.com> <CAAmzW4PuHiNf2FhyOhNUXvJRF+y2JBdO_92Mqo6LHWKVu8W47g@mail.gmail.com>
In-Reply-To: <CAAmzW4PuHiNf2FhyOhNUXvJRF+y2JBdO_92Mqo6LHWKVu8W47g@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Alex Shi <alex.shi@intel.com>

On 05/22/2012 07:08 PM, JoonSoo Kim wrote:
>> +#ifdef CONFIG_DEBUG_VM
>> >  +       if (!name || in_interrupt() || size<  sizeof(void *) ||
>> >  +               size>  KMALLOC_MAX_SIZE) {
>> >  +               printk(KERN_ERR "kmem_cache_create(%s) integrity check"
>> >  +                       " failed\n", name);
>> >  +               goto out;
>> >  +       }
>> >  +#endif
> Currently, when !CONFIG_DEBUG_VM, name check is handled differently in
> sl[aou]bs.
> slob worked with !name, but slab, slub return NULL.
> So I think some change is needed for name handling

Just because slob works without a name, it doesn't mean that calling 
kmem_cache_create() without a name is even a bit close to being sane.

Any user of this interface, has no way to know which allocator will be 
used in the end. So the guarantees given by the interface should be 
sanity checked, whether or not the particular cache uses it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
