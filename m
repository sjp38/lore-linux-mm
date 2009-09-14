Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7F13E6B004D
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 23:28:57 -0400 (EDT)
Message-ID: <4AADB887.103@redhat.com>
Date: Mon, 14 Sep 2009 11:29:11 +0800
From: Danny Feng <dfeng@redhat.com>
MIME-Version: 1.0
Subject: Re: [GIT BISECT] BUG kmalloc-8192: Object already free from kmem_cache_destroy
References: <1252866835.13780.37.camel@dhcp231-106.rdu.redhat.com>	 <4AADB5EE.9090902@redhat.com> <1252898739.5793.4.camel@dhcp231-106.rdu.redhat.com>
In-Reply-To: <1252898739.5793.4.camel@dhcp231-106.rdu.redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/14/2009 11:25 AM, Eric Paris wrote:
> On Mon, 2009-09-14 at 11:18 +0800, Danny Feng wrote:
>> diff --git a/mm/slub.c b/mm/slub.c
>> index b627675..40e12d5 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -3337,8 +3337,8 @@ struct kmem_cache *kmem_cache_create(const char
>> *name, size_t size,
>>                                  goto err;
>>                          }
>>                          return s;
>> -               }
>> -               kfree(s);
>> +               } else
>> +                       kfree(s);
>>          }
>>          up_write(&slub_lock);
>>
>
> Doesn't the return inside the conditional take care of this?  I'll give
> it a try in the morning, but I don't see how this can solve the
> problem....
>
> -Eric
>
>
err, you're right... let me try to find why. It's strange, if SLUB_DEBUG 
is not set, sysfs_slab_remove is just to free kmem_cache s. So I think 
if SLUB_DEBUG is not set, we also have the same issue....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
