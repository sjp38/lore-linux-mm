Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 614DE6B006E
	for <linux-mm@kvack.org>; Sun, 19 Oct 2014 13:19:01 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so3696855pab.30
        for <linux-mm@kvack.org>; Sun, 19 Oct 2014 10:19:01 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id fr3si5727392pdb.233.2014.10.19.10.18.59
        for <linux-mm@kvack.org>;
        Sun, 19 Oct 2014 10:19:00 -0700 (PDT)
Date: Sun, 19 Oct 2014 13:18:55 -0400 (EDT)
Message-Id: <20141019.131855.1429160564158795766.davem@davemloft.net>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.LRH.2.11.1410192011410.32417@adalberg.ut.ee>
References: <20141018.142335.1935310766779155342.davem@davemloft.net>
	<alpine.LRH.2.11.1410191459210.32417@adalberg.ut.ee>
	<alpine.LRH.2.11.1410192011410.32417@adalberg.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mroos@linux.ee
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

From: Meelis Roos <mroos@linux.ee>
Date: Sun, 19 Oct 2014 20:12:43 +0300 (EEST)

>> > > I don't want to define the array size of the fpregs save area
>> > > explicitly and thereby placing an artificial limit there.
>> > 
>> > Nevermind, it seems we have a hard limit of 7 FPU save areas anyways.
>> > 
>> > Meelis, please try this patch:
>> 
>> Works fine with 3.17.0-09670-g0429fbc + fault patch.
>> 
>> Will try current git next to find any new problems :)
> 
> Works on all 3 machines, with latest git (only had to apply the no-ipv6 
> patch on one of them). Thank you for the good work!

Thanks for testing.

Hopefully we can kill the gcc-4.9 bug next, and then see if that
exit_mmap() crash is still happening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
