Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 676646B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 03:22:59 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id pn19so2365324lab.14
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 00:22:58 -0700 (PDT)
Received: from smtp1.it.da.ut.ee (mailhost6-1.ut.ee. [2001:bb8:2002:500::46])
        by mx.google.com with ESMTP id j10si33418130laf.95.2014.10.16.00.22.57
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 00:22:57 -0700 (PDT)
Date: Thu, 16 Oct 2014 10:22:56 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: unaligned accesses in SLAB etc.
In-Reply-To: <20141015.231154.1804074463934900124.davem@davemloft.net>
Message-ID: <alpine.LRH.2.11.1410161021130.5119@adalberg.ut.ee>
References: <alpine.LRH.2.11.1410151059520.8050@adalberg.ut.ee> <20141015.143624.941838991598108211.davem@davemloft.net> <alpine.LRH.2.11.1410152310080.11974@adalberg.ut.ee> <20141015.231154.1804074463934900124.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

> Do you happen to have both gcc-4.9 and a previously working compiler
> on these systems?  If you do, we can build a kernel with gcc-4.9 and
> then selectively compile certain failes with the older working
> compiler to narrow down what compiles into something non-working with
> gcc-4.9

Yes, I kept gcc-4.6 to help resolving it.

[...]

> Hopefully, this should be a simply matter of doing a complete build
> with gcc-4.9, then removing the object file we want to selectively
> build with the older compiler and then going:
> 
> 	make CC="gcc-4.6" arch/sparc/mm/init_64.o
> 
> then relinking with plain 'make'.
> 
> If the build system rebuilds the object file on you when you try
> to relink the final kernel image, we'll have to do some of this
> by hand to make the test.

Unfortunately it starts a full rebuild with plain make after compiling 
some files with gcc-4.6 - detects CC change?

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
