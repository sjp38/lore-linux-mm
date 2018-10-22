Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2A56B0008
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 21:35:18 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w42-v6so23757638edd.0
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 18:35:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u1-v6sor9181144ejx.50.2018.10.21.18.35.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Oct 2018 18:35:17 -0700 (PDT)
Date: Mon, 22 Oct 2018 01:35:15 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] memblock: remove stale #else and the code it protects
Message-ID: <20181022013515.frvzqvccrrp3qiw4@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1538067825-24835-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20181019081729.klvckcytnhheaian@master>
 <6EEAA7EC-75B7-4899-A562-35A58FC037E6@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6EEAA7EC-75B7-4899-A562-35A58FC037E6@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Oct 21, 2018 at 10:30:16AM +0300, Mike Rapoport wrote:
>
>
>On October 19, 2018 11:17:30 AM GMT+03:00, Wei Yang <richard.weiyang@gmail.com> wrote:
>>Which tree it applies?
>
>To mmotm of the end of September.
>

I may lost some background of this change.

The file I am looking at is
https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git/tree/include/linux/memblock.h
which has CONFIG_HAVE_MEMBLOCK in line 5.

>>On Thu, Sep 27, 2018 at 08:03:45PM +0300, Mike Rapoport wrote:
>>>During removal of HAVE_MEMBLOCK definition, the #else clause of the
>>>
>>>	#ifdef CONFIG_HAVE_MEMBLOCK
>>>		...
>>>	#else
>>>		...
>>>	#endif
>>>
>>>conditional was not removed.
>>>
>>>Remove it now.
>>>
>>>Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
>>>Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
>>>Cc: Michal Hocko <mhocko@suse.com>
>>>---
>>> include/linux/memblock.h | 5 -----
>>> 1 file changed, 5 deletions(-)
>>>
>>>diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>>>index d3bc270..d4d0e01 100644
>>>--- a/include/linux/memblock.h
>>>+++ b/include/linux/memblock.h
>>>@@ -597,11 +597,6 @@ static inline void early_memtest(phys_addr_t
>>start, phys_addr_t end)
>>> {
>>> }
>>> #endif
>>>-#else
>>>-static inline phys_addr_t memblock_alloc(phys_addr_t size,
>>phys_addr_t align)
>>>-{
>>>-	return 0;
>>>-}
>>> 

And in that file, here is memblock_reserved_memory_within.

I guess this is not the version you are trying to fix.

BTW, if you could put the commit SHA which removes the
CONFIG_HAVE_MEMBLOCK, it would be easier for others to catch up.

>>> #endif /* __KERNEL__ */
>>> 
>>>-- 
>>>2.7.4
>
>-- 
>Sent from my Android device with K-9 Mail. Please excuse my brevity.

-- 
Wei Yang
Help you, Help me
