Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id DE67A6B0032
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 17:18:18 -0400 (EDT)
Message-ID: <1366751135.6660.3.camel@misato.fc.hp.com>
Subject: Re: [Bug fix PATCH v5] Reusing a resource structure allocated by
 bootmem
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 23 Apr 2013 15:05:35 -0600
In-Reply-To: <5175E5E8.3010003@jp.fujitsu.com>
References: <5175E5E8.3010003@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linuxram@us.ibm.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2013-04-23 at 10:37 +0900, Yasuaki Ishimatsu wrote:
 :
> The reason why the messages are shown is to release a resource structure,
> allocated by bootmem, by kfree(). So when we release a resource structure,
> we should check whether it is allocated by bootmem or not.
> 
> But even if we know a resource structure is allocated by bootmem, we cannot
> release it since SLxB cannot treat it. So for reusing a resource structure,
> this patch remembers it by using bootmem_resource as follows:
> 
> When releasing a resource structure by free_resource(), free_resource() checks
> whether the resource structure is allocated by bootmem or not. If it is
> allocated by bootmem, free_resource() adds it to bootmem_resource. If it is
> not allocated by bootmem, free_resource() release it by kfree().
> 
> And when getting a new resource structure by get_resource(), get_resource()
> checks whether bootmem_resource has released resource structures or not. If
> there is a released resource structure, get_resource() returns it. If there is
> not a releaed resource structure, get_resource() returns new resource structure
> allocated by kzalloc().
> ---
> v5:
> Define bootmem_resource_free as static and poiner for saving memory
> Fix slab check in free_resource()
> Move memset outside of spin lock in get_resource()

Please add your "Signed-off-by".  Otherwise the changes look good.

Reviewed-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
