Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9824B6B007B
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 04:11:09 -0500 (EST)
Message-ID: <4B0E461C.50606@parallels.com>
Date: Thu, 26 Nov 2009 12:10:52 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: memcg: slab control
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>	<20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>	<20091126085031.GG2970@balbir.in.ibm.com> <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, David Rientjes <rientjes@google.com>
Cc: Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Anyway, I agree that we need another
>> slabcg, Pavel did some work in that area and posted patches, but they
>> were mostly based and limited to SLUB (IIRC).

I'm ready to resurrect the patches and port them for slab.
But before doing it we should answer one question.

Consider we have two kmalloc-s in a kernel code - one is
user-space triggerable and the other one is not. From my
POV we should account for the former one, but should not
for the latter.

If so - how should we patch the kernel to achieve that goal?

> My point is that most of the kernel codes cannot work well when kmalloc(small area)
> returns NULL.

:) That's not so actually. As our experience shows kernel lives fine
when kmalloc returns NULL (this doesn't include drivers though).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
