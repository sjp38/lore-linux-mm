Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8AEDF6B006E
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 16:18:30 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id i17so3458267qcy.2
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 13:18:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s103si20183208qgs.94.2014.10.16.13.18.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 13:18:30 -0700 (PDT)
Date: Thu, 16 Oct 2014 16:18:23 -0400 (EDT)
Message-Id: <20141016.161823.2256065922400180323.davem@redhat.com>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@redhat.com>
In-Reply-To: <alpine.LRH.2.11.1410162309560.19924@adalberg.ut.ee>
References: <20141015.231154.1804074463934900124.davem@davemloft.net>
	<alpine.LRH.2.11.1410161021130.5119@adalberg.ut.ee>
	<alpine.LRH.2.11.1410162309560.19924@adalberg.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mroos@linux.ee
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

From: Meelis Roos <mroos@linux.ee>
Date: Thu, 16 Oct 2014 23:11:49 +0300 (EEST)

>> > Hopefully, this should be a simply matter of doing a complete build
>> > with gcc-4.9, then removing the object file we want to selectively
>> > build with the older compiler and then going:
>> > 
>> > 	make CC="gcc-4.6" arch/sparc/mm/init_64.o
>> > 
>> > then relinking with plain 'make'.
>> > 
>> > If the build system rebuilds the object file on you when you try
>> > to relink the final kernel image, we'll have to do some of this
>> > by hand to make the test.
>> 
>> Unfortunately it starts a full rebuild with plain make after compiling 
>> some files with gcc-4.6 - detects CC change?
> 
> Figured out from make V=1 how to call gcc-4.6 directly, so far my 
> bisection shows that it one or probably more of arch/sparc/kernel/*.c 
> but probably more than 1 - 2 halfs of it both failed. Still bisecting.

Thanks a lot for working this out.

I'm going to also try to setup a test environment so I can try this
gcc-4.9 stuff on my T4-2 as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
