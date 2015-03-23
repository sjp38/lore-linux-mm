Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 432AA6B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:00:31 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so171582677pdb.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 19:00:31 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id ti6si19350610pab.223.2015.03.22.19.00.28
        for <linux-mm@kvack.org>;
        Sun, 22 Mar 2015 19:00:29 -0700 (PDT)
Date: Sun, 22 Mar 2015 22:00:24 -0400 (EDT)
Message-Id: <20150322.220024.1171832215344978787.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <550F5852.5020405@oracle.com>
References: <550F51D5.2010804@oracle.com>
	<20150322.195403.1653355516554747742.davem@davemloft.net>
	<550F5852.5020405@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david.ahern@oracle.com
Cc: torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

From: David Ahern <david.ahern@oracle.com>
Date: Sun, 22 Mar 2015 18:03:30 -0600

> On 3/22/15 5:54 PM, David Miller wrote:
>>> I just put it on 4.0.0-rc4 and ditto -- problem goes away, so it
>>> clearly suggests the memcpy or memmove are the root cause.
>>
>> Thanks, didn't notice that.
>>
>> So, something is amuck.
> 
> to continue to refine the problem ... I modified only the memmove
> lines (not the memcpy) and it works fine. So its the memmove.
> 
> I'm sure this will get whitespaced damaged on the copy and paste but
> to be clear this is the patch I am currently running and system is
> stable. On Friday it failed on every single; with this patch I have
> allyesconfig builds with -j 128 in a loop (clean in between) and
> nothing -- no panics.

Can you just try calling memcpy(), that should work because
I think we agree that if the memcpy() implementation copies
from low to high it should work.

I wonder if the triggering factor is configuring for a high
number of cpus.  I always have NR_CPUS=128 since that's the
largest machine I have.  I'll give NR_CPUS=1024 a spin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
