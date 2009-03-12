Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2B12B6B0055
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 08:07:52 -0400 (EDT)
Date: Thu, 12 Mar 2009 20:06:49 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Memory usage per memory zone
Message-ID: <20090312120649.GA20854@localhost>
References: <e2dc2c680903110516v2c66d4a4h6a422cffceb12e2@mail.gmail.com> <20090311122611.GA8804@localhost> <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com> <20090312075952.GA19331@localhost> <e2dc2c680903120104h4d19a3f6j57ad045bc06f9a90@mail.gmail.com> <20090312081113.GA19506@localhost> <e2dc2c680903120117j7be962b2xd63f3296f8f65a46@mail.gmail.com> <20090312103847.GA20210@localhost> <e2dc2c680903120438i27e209c2h28c61704299b8b4f@mail.gmail.com> <e2dc2c680903120448q386f84a4t5667e22751002ae9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e2dc2c680903120448q386f84a4t5667e22751002ae9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: jack marrow <jackmarrow2@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 01:48:50PM +0200, jack marrow wrote:
> >> Sure, but something is unreclaimable... Maybe some process is taking a
> >> lot of shared memory(shm)? What's the output of `lsof`?
> >
> > I can't paste that, but I expect oracle is using it.
> 
> Maybe this is helpful:
> 
> #  ipcs |grep oracle
> 0x00000000 2293770    oracle    640        4194304    22
> 0x00000000 2326539    oracle    640        536870912  22
> 0x880f3334 2359308    oracle    640        266338304  22
> 0x0f9b5efc 1933312    oracle    640        44

Up to 800M shm...

http://lwn.net/Articles/286485/
http://feedblog.org/2009/01/25/splitlru-patch-in-kernel-2628-must-have-for-mysql-and-innodb/

which reads: 

        If youa??re running MySQL with InnoDB and an in-memory buffer pool, and
        having paging issues, you probably should upgrade to 2.6.28 ASAP.


Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
