Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1C26B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 12:33:35 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id i11so33145oag.37
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:33:35 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id k2si23496243oel.155.2014.04.18.09.33.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 09:33:34 -0700 (PDT)
Message-ID: <1397838812.19331.3.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v3] ipc,shm: disable shmmax and shmall by default
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 18 Apr 2014 09:33:32 -0700
In-Reply-To: <5350EFAA.2030607@colorfullife.com>
References: <1397784345.2556.26.camel@buesod1.americas.hpqcorp.net>
	 <5350EFAA.2030607@colorfullife.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-api@vger.kernel.org

On Fri, 2014-04-18 at 11:26 +0200, Manfred Spraul wrote:
> Hi Davidlohr,
> 
> On 04/18/2014 03:25 AM, Davidlohr Bueso wrote:
> > So a value of 0 bytes or pages, for shmmax and shmall, respectively,
> > implies unlimited memory, as opposed to disabling sysv shared memory.
> That might be a second risk:
> Right now, a sysadmin can prevent sysv memory allocations with
> 
>      # sysctl kernel.shmall=0

Yeah, I had pointed this out previously, and it is addressed in the
changelog. shmall = 0 directly contradicts size < shmmin = 1, so I don't
know who's wrong there...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
