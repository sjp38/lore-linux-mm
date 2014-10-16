Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 09E506B006E
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 16:11:52 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so3422797lbi.23
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 13:11:52 -0700 (PDT)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500:20f:1fff:fe04:1bbb])
        by mx.google.com with ESMTP id r1si36404775lar.58.2014.10.16.13.11.50
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 13:11:51 -0700 (PDT)
Date: Thu, 16 Oct 2014 23:11:49 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: unaligned accesses in SLAB etc.
In-Reply-To: <alpine.LRH.2.11.1410161021130.5119@adalberg.ut.ee>
Message-ID: <alpine.LRH.2.11.1410162309560.19924@adalberg.ut.ee>
References: <alpine.LRH.2.11.1410151059520.8050@adalberg.ut.ee> <20141015.143624.941838991598108211.davem@davemloft.net> <alpine.LRH.2.11.1410152310080.11974@adalberg.ut.ee> <20141015.231154.1804074463934900124.davem@davemloft.net>
 <alpine.LRH.2.11.1410161021130.5119@adalberg.ut.ee>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: iamjoonsoo.kim@lge.com, Linux Kernel list <linux-kernel@vger.kernel.org>, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

> > Hopefully, this should be a simply matter of doing a complete build
> > with gcc-4.9, then removing the object file we want to selectively
> > build with the older compiler and then going:
> > 
> > 	make CC="gcc-4.6" arch/sparc/mm/init_64.o
> > 
> > then relinking with plain 'make'.
> > 
> > If the build system rebuilds the object file on you when you try
> > to relink the final kernel image, we'll have to do some of this
> > by hand to make the test.
> 
> Unfortunately it starts a full rebuild with plain make after compiling 
> some files with gcc-4.6 - detects CC change?

Figured out from make V=1 how to call gcc-4.6 directly, so far my 
bisection shows that it one or probably more of arch/sparc/kernel/*.c 
but probably more than 1 - 2 halfs of it both failed. Still bisecting.

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
