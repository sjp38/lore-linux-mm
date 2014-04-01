Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 008666B004D
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 16:26:36 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so10414715pab.13
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 13:26:36 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id a8si11891438pbs.199.2014.04.01.13.26.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 13:26:36 -0700 (PDT)
Message-ID: <1396383989.25314.19.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 01 Apr 2014 13:26:29 -0700
In-Reply-To: <CAHGf_=r03QWxw3Jg7BE3z37k4omgo_HRE9qCGw80ngtUD_iEeA@mail.gmail.com>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	 <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
	 <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>
	 <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
	 <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>
	 <20140331170546.3b3e72f0.akpm@linux-foundation.org>
	 <533A5CB1.1@jp.fujitsu.com>
	 <20140401121920.50d1dd96c2145acc81561b82@linux-foundation.org>
	 <CAHGf_=r03QWxw3Jg7BE3z37k4omgo_HRE9qCGw80ngtUD_iEeA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Gotou, Yasunori" <y-goto@jp.fujitsu.com>, chenhanxiao <chenhanxiao@cn.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>

On Tue, 2014-04-01 at 16:15 -0400, KOSAKI Motohiro wrote:
> >> Our middleware engineers has been complaining about this sysctl limit.
> >> System administrator need to calculate required sysctl value by making sum
> >> of all planned middlewares, and middleware provider needs to write "please
> >> calculate systcl param by....." in their installation manuals.
> >
> > Why aren't people just setting the sysctl to a petabyte?  What problems
> > would that lead to?
> 
> I don't have much Fujitsu middleware knowledges. But I'd like to explain
> very funny bug I saw.
> 
> 1. middleware-A suggest to set SHMMAX to very large value (maybe
> LONG_MAX, but my memory was flushed)
> 2. middleware-B suggest to set SHMMAX to increase some dozen mega byte.
> 
> Finally, it was overflow and didn't work at all.
> 
> Let's demonstrate.
> 
> # echo 18446744073709551615 > /proc/sys/kernel/shmmax
> # cat /proc/sys/kernel/shmmax
> 18446744073709551615
> # echo 18446744073709551616 > /proc/sys/kernel/shmmax
> # cat /proc/sys/kernel/shmmax
> 0

hehe, what a nasty little tunable this is. Reminds me of this:
https://access.redhat.com/site/solutions/16333

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
