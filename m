Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8EBBC6B013F
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 19:48:21 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so916388pab.24
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 16:48:21 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id jh5si2095467pbb.426.2014.04.02.16.48.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 16:48:20 -0700 (PDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2BF623EE1D8
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 08:48:19 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D4AA45DE54
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 08:48:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 04D4745DE53
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 08:48:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EAA551DB804A
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 08:48:18 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9771D1DB803F
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 08:48:18 +0900 (JST)
Message-ID: <533CA179.3050005@jp.fujitsu.com>
Date: Thu, 03 Apr 2014 08:47:05 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>	<20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>	<1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>	<20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>	<1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>	<20140331170546.3b3e72f0.akpm@linux-foundation.org>	<533A5CB1.1@jp.fujitsu.com>	<20140401121920.50d1dd96c2145acc81561b82@linux-foundation.org> <20140402155507.1d976144@alan.etchedpixels.co.uk>
In-Reply-To: <20140402155507.1d976144@alan.etchedpixels.co.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Gotou, Yasunori" <y-goto@jp.fujitsu.com>, chenhanxiao <chenhanxiao@cn.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>

(2014/04/02 23:55), One Thousand Gnomes wrote:
>> Why aren't people just setting the sysctl to a petabyte?  What problems
>> would that lead to?
>
> Historically - hanging on real world desktop systems when someone
> accidentally creates a giant SHM segment and maps it.
>
> If you are running with vm overcmmit set to actually do checks then it
> *shouldn't* blow up nowdays.
>
> More to the point wtf are people still using prehistoric sys5 IPC APIs
> not shmemfs/posix shmem ?
>

AFAIK, there are many sys5 ipc users.
And admins are using ipcs etc...for checking status. I guess they will not
change the attitude until they see trouble with sysv IPC.
*) I think some RedHat's document(MRG?) says sysv IPC is obsolete clearly but...

I tend to recommend posix shared memory when people newly starts development but
there is an another trap.
IIUC, for posix shmem, an implicit size limit is applied by tmpfs's fs size.
tmpfs mounted on /dev/shm tends to be limited to half size of system memory.
It's hard to know that limit for users before hitting trouble.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
