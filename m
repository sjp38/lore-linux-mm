Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 03CE26B009C
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 21:03:20 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so10729089pab.9
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 18:03:20 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id mv8si145413pab.461.2014.04.01.18.03.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 18:03:20 -0700 (PDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 90CB23EE0FE
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 10:03:18 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EE0445DE4D
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 10:03:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.nic.fujitsu.com [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 64A5C45DE52
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 10:03:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3725A1DB8038
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 10:03:18 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CEA311DB8048
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 10:03:17 +0900 (JST)
Message-ID: <533B61AC.7090808@jp.fujitsu.com>
Date: Wed, 02 Apr 2014 10:02:36 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>	<20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>	<1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>	<20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>	<1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>	<20140331170546.3b3e72f0.akpm@linux-foundation.org>	<533A5CB1.1@jp.fujitsu.com> <20140401121920.50d1dd96c2145acc81561b82@linux-foundation.org>
In-Reply-To: <20140401121920.50d1dd96c2145acc81561b82@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Gotou, Yasunori" <y-goto@jp.fujitsu.com>, chenhanxiao <chenhanxiao@cn.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>

(2014/04/02 4:19), Andrew Morton wrote:
> On Tue, 01 Apr 2014 15:29:05 +0900 Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>>>
>>> So their system will act as if they had set SHMMAX=enormous.  What
>>> problems could that cause?
>>>
>>>
>>> Look.  The 32M thing is causing problems.  Arbitrarily increasing the
>>> arbitrary 32M to an arbitrary 128M won't fix anything - we still have
>>> the problem.  Think bigger, please: how can we make this problem go
>>> away for ever?
>>>
>>
>> Our middleware engineers has been complaining about this sysctl limit.
>> System administrator need to calculate required sysctl value by making sum
>> of all planned middlewares, and middleware provider needs to write "please
>> calculate systcl param by....." in their installation manuals.
>
> Why aren't people just setting the sysctl to a petabyte?  What problems
> would that lead to?
>

They(and admin) don't know the fact, setting petabytes won't cause any pain.

In their thinking:
==
If there is a kernel's limit, it should have some (bad) side-effect and
the trade-off which must be handled by admin is represented by the limit.
In this case, they think setting this value large will consume tons of resource.
==
They don't care kernel's implemenation but takes care of what API says.

Of course, always I was asked, I answer set it to peta-bytes. But the fact
*default is small* makes them doubtful.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
