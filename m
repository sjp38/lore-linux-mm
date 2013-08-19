Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id B37D06B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 00:33:04 -0400 (EDT)
Message-ID: <52119FC7.5070406@oracle.com>
Date: Mon, 19 Aug 2013 12:32:07 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] mm: merge zram into zswap
References: <1376815249-6611-1-git-send-email-bob.liu@oracle.com> <20130819041044.GB26832@bbox>
In-Reply-To: <20130819041044.GB26832@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, eternaleye@gmail.com, mgorman@suse.de, gregkh@linuxfoundation.org, akpm@linux-foundation.org, axboe@kernel.dk, sjenning@linux.vnet.ibm.com, ngupta@vflare.org, semenzato@google.com, penberg@iki.fi, sonnyrao@google.com, smbarber@google.com, konrad.wilk@oracle.com, riel@redhat.com, kmpark@infradead.org

Hi Minchan,

On 08/19/2013 12:10 PM, Minchan Kim wrote:
> On Sun, Aug 18, 2013 at 04:40:45PM +0800, Bob Liu wrote:
>> Both zswap and zram are used to compress anon pages in memory so as to reduce
>> swap io operation. The main different is that zswap uses zbud as its allocator
>> while zram uses zsmalloc. The other different is zram will create a block
>> device, the user need to mkswp and swapon it.
>>
>> Minchan has areadly try to promote zram/zsmalloc into drivers/block/, but it may
>> cause increase maintenance headaches. Since the purpose of zswap and zram are
>> the same, this patch series try to merge them together as Mel suggested.
>> Dropped zram from staging and extended zswap with the same feature as zram.
>>
>> zswap todo:
>> Improve the writeback of zswap pool pages!
>>
>> Bob Liu (4):
>>   drivers: staging: drop zram and zsmalloc
> 
> Bob, I feel you're very rude and I'm really upset.
> 
> You're just dropping the subsystem you didn't do anything without any consensus
> from who are contriubting lots of patches to make it works well for a long time.

I apologize for that, at least I should add [RFC] in the patch title!

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
