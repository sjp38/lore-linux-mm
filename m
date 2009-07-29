Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 60EC76B004F
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 07:21:17 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n6TBLLBZ001673
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 11:21:21 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6TBLJrh2338910
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 13:21:21 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6TBLIs7008568
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 13:21:19 +0200
Message-ID: <4A70309A.3030304@de.ibm.com>
Date: Wed, 29 Jul 2009 13:20:58 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] hibernate / memory hotplug: always use for_each_populated_zone()
References: <1248103551.23961.0.camel@localhost.localdomain> <20090721071508.GB12734@osiris.boeblingen.de.ibm.com> <20090721163846.2a8001c1.kamezawa.hiroyu@jp.fujitsu.com> <200907211611.09525.rjw@sisk.pl>
In-Reply-To: <200907211611.09525.rjw@sisk.pl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Nigel Cunningham <ncunningham@crca.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rafael J. Wysocki wrote:
>>> So it looks like checking for pfn_valid() and afterwards checking
>>> for PG_Reserved (?) might give what one would expect.
>> I think so, too. If memory is offline, PG_reserved is always set.
>>
>> In general, it's expected that "page is contiguous in MAX_ORDER range"
>> and no memory holes in MAX_ORDER. In most case, PG_reserved is checked
>> for skipping not-existing memory.
> 
> PG_reserved is also set for kernel text, at least on some architectures, and
> for some other areas that we want to save.

How about checking for PG_reserved && ZONE_MOVABLE? I think we don't
have any special cases for PG_reserved inside ZONE_MOVABLE, but I'm not
sure if this is true for all architectures and NUMA systems.

If this would work, it could be a simple way to determine which hotplug
memory should be saved.

--
Regards,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
