Message-ID: <416ACBCE.9090500@colorfullife.com>
Date: Mon, 11 Oct 2004 20:07:10 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] reduce fragmentation due to kmem_cache_alloc_node
References: <41684BF3.5070108@colorfullife.com> <1097514734.12861.366.camel@dyn318077bld.beaverton.ibm.com>
In-Reply-To: <1097514734.12861.366.camel@dyn318077bld.beaverton.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote:

>Manfred,
>
>This patch seems to work fine on my AMD machine.
>I tested your patch on 2.6.9-rc2-mm3. 
>
>It seemed to have fixed fragmentation problem I was
>observing, but I don't think it fixed the problem
>completely. I still see some fragmentation, with
>repeated tests of scsi-debug, but it could be due
>to the test. I will collect more numbers..
>
>  
>
Did you disable the !CONFIG_NUMA block from <linux/slab.h> or leave it 
enabled? If the CONFIG_NUMA test is in the header file, then my patch is 
identical to you proposal, except that I've changed the global 
declaration instead of just the call from alloc_percpu.

--
    Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
