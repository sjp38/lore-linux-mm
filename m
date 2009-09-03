Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A52616B005D
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 20:24:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n830OfVY014949
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Sep 2009 09:24:41 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 85FA345DE51
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 09:24:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3824745DE4F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 09:24:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EF237E08013
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 09:24:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B3FFE0800F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 09:24:40 +0900 (JST)
Message-ID: <61624a1a836fe4f48d76af9b431eba39.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <661de9470909021258j7fcc71fcv27d284738d1e37e3@mail.gmail.com>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
    <20090902134114.b6f1a04d.kamezawa.hiroyu@jp.fujitsu.com>
    <20090902182923.c6d98fd6.kamezawa.hiroyu@jp.fujitsu.com>
    <661de9470909021258j7fcc71fcv27d284738d1e37e3@mail.gmail.com>
Date: Thu, 3 Sep 2009 09:24:39 +0900 (JST)
Subject: Re: [mmotm][experimental][PATCH] coalescing charge
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh さんは書きました：
> On Wed, Sep 2, 2009 at 2:59 PM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> I'm sorry that I'll be absent tomorrow. This is dump of current code.
>> IMHO, this version is enough simple.
>>
>> My next target is css's refcnt per page. I think we never need it...
>
> Is this against 27th August 2009 mmotm?
>
Onto mmotm-27+ all patches I sent. Maybe arguments to res_counter will
HUNK, at least

Thanks,
-Kame

> Balbir Singh
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
