Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8599C6B004D
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 23:41:33 -0400 (EDT)
Message-ID: <4AADBB77.5050803@redhat.com>
Date: Mon, 14 Sep 2009 11:41:43 +0800
From: Danny Feng <dfeng@redhat.com>
MIME-Version: 1.0
Subject: Re: [GIT BISECT] BUG kmalloc-8192: Object already free from kmem_cache_destroy
References: <1252866835.13780.37.camel@dhcp231-106.rdu.redhat.com> <1252883493.16335.8.camel@dhcp231-106.rdu.redhat.com>
In-Reply-To: <1252883493.16335.8.camel@dhcp231-106.rdu.redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/14/2009 07:11 AM, Eric Paris wrote:
> On Sun, 2009-09-13 at 14:33 -0400, Eric Paris wrote:
>    
>> 2a38a002fbee06556489091c30b04746222167e4 is first bad commit
>> commit 2a38a002fbee06556489091c30b04746222167e4
>> Author: Xiaotian Feng<dfeng@redhat.com>
>> Date:   Wed Jul 22 17:03:57 2009 +0800
>>
>>      slub: sysfs_slab_remove should free kmem_cache when debug is enabled
>>
>>      kmem_cache_destroy use sysfs_slab_remove to release the kmem_cache,
>>      but when CONFIG_SLUB_DEBUG is enabled, sysfs_slab_remove just release
>>      related kobject, the whole kmem_cache is missed to release and cause
>>      a memory leak.
>>
>>      Acked-by: Christoph Lameer<cl@linux-foundation.org>
>>      Signed-off-by: Xiaotian Feng<dfeng@redhat.com>
>>      Signed-off-by: Pekka Enberg<penberg@cs.helsinki.fi>
>>
>> CONFIG_SLUB_DEBUG=y
>> CONFIG_SLUB=y
>> CONFIG_SLUB_DEBUG_ON=y
>> # CONFIG_SLUB_STATS is not set
>>      
> I also had problems destroying a kmem_cache in a security_initcall()
> function which had a different backtrace (it's what made me create the
> module and bisect.)   So be sure to let me know what you find so I can
> be sure that we fix that place as well   (I believe that was a kref
> problem rather than a double free)
>
> -Eric
>
>
>    
That's my fault... Please drop this patch, I didn't notice the free 
action in kobject release phase.. Thanks for point it out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
