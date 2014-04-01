Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 059036B003D
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 16:15:34 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id uz6so11698963obc.13
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 13:15:34 -0700 (PDT)
Received: from mail-oa0-x22c.google.com (mail-oa0-x22c.google.com [2607:f8b0:4003:c02::22c])
        by mx.google.com with ESMTPS id i2si15894777oeu.174.2014.04.01.13.15.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 13:15:34 -0700 (PDT)
Received: by mail-oa0-f44.google.com with SMTP id n16so11829213oag.3
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 13:15:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140401121920.50d1dd96c2145acc81561b82@linux-foundation.org>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
 <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
 <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net> <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
 <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org>
 <533A5CB1.1@jp.fujitsu.com> <20140401121920.50d1dd96c2145acc81561b82@linux-foundation.org>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 1 Apr 2014 16:15:14 -0400
Message-ID: <CAHGf_=r03QWxw3Jg7BE3z37k4omgo_HRE9qCGw80ngtUD_iEeA@mail.gmail.com>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Davidlohr Bueso <davidlohr@hp.com>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Gotou, Yasunori" <y-goto@jp.fujitsu.com>, chenhanxiao <chenhanxiao@cn.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>

>> Our middleware engineers has been complaining about this sysctl limit.
>> System administrator need to calculate required sysctl value by making sum
>> of all planned middlewares, and middleware provider needs to write "please
>> calculate systcl param by....." in their installation manuals.
>
> Why aren't people just setting the sysctl to a petabyte?  What problems
> would that lead to?

I don't have much Fujitsu middleware knowledges. But I'd like to explain
very funny bug I saw.

1. middleware-A suggest to set SHMMAX to very large value (maybe
LONG_MAX, but my memory was flushed)
2. middleware-B suggest to set SHMMAX to increase some dozen mega byte.

Finally, it was overflow and didn't work at all.

Let's demonstrate.

# echo 18446744073709551615 > /proc/sys/kernel/shmmax
# cat /proc/sys/kernel/shmmax
18446744073709551615
# echo 18446744073709551616 > /proc/sys/kernel/shmmax
# cat /proc/sys/kernel/shmmax
0

That's why many open source software continue the silly game. But
again, I don't have knowledge about Fujitsu middleware. I'm waiting
kamezawa-san's answer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
