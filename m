Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AF8F96B005A
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:39:50 -0400 (EDT)
Message-id: <isapiwc.34aac0fd.3bb4.4ac3f042.11536.9@mail.jp.nec.com>
In-Reply-To: <20091001083133.429f373b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090930190417.8823fa44.kamezawa.hiroyu@jp.fujitsu.com>
 <20090930190943.8f19c48b.kamezawa.hiroyu@jp.fujitsu.com>
 <20091001083133.429f373b.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 1 Oct 2009 08:56:50 +0900
From: nishimura@mxp.nes.nec.co.jp
Subject: Re: [RFC][PATCH 1/2] percpu array counter like vmstat
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 30 Sep 2009 19:09:43 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> +int array_counter_init(struct array_counter *ac, int size)
>> +{
>> +	ac->v.elements = size;
>> +	ac->v.counters = alloc_percpu(s8);
> This is a bug, of course...
Yes, I was confused at that point and about to pointing it out :)

> should be
> ac->v.counters = __alloc_percpu(size, __alignof__(char));
> 
__alloc_pecpu(size * sizeof(s8), __alignof__(s8)) would be better ?
There is no actual difference, though.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
