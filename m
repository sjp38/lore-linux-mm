Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id mA6DkdJS005497
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 19:16:39 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA6Dkcgv3903740
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 19:16:39 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id mA6DkbxD022723
	for <linux-mm@kvack.org>; Fri, 7 Nov 2008 00:46:37 +1100
Message-ID: <4912F53A.2070407@linux.vnet.ibm.com>
Date: Thu, 06 Nov 2008 19:16:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 7/6] memcg: add atribute (for change bahavior of
 rmdir)
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com> <49129493.9070103@linux.vnet.ibm.com> <20081106194153.220157ec.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081106194153.220157ec.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 06 Nov 2008 12:24:11 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> Weekly (RFC) update for memcg.
>>>
>>> This set includes
>>>
>>> 1. change force_empty to do move account rather than forget all
>> I would like this to be selectable, please. We don't want to break behaviour and
>> not everyone would like to pay the cost of movement.
> 
> How about a patch like this ? I'd like to move this as [2/7], if possible.
> It obviously needs painful rework. If I found it difficult, schedule this as [7/7].
> 
> BTW, cost of movement itself is not far from cost for force_empty.
> 
> If you can't find why "forget" is bad, please consider one more day.

The attributes seem quite reasonable, I've taken a quick look, not done a full
review or test.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
