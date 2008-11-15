Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAF9G2CH025696
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 15 Nov 2008 18:16:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C8912AEA81
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 18:16:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CAFF1EF081
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 18:16:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 385B11DB803F
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 18:16:02 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B2BC9E08007
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 18:16:01 +0900 (JST)
Message-ID: <2754.10.75.179.61.1226740560.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <491E795D.5070507@linux.vnet.ibm.com>
References: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>
    <20081115120015.22fa5720.kamezawa.hiroyu@jp.fujitsu.com>
    <491E795D.5070507@linux.vnet.ibm.com>
Date: Sat, 15 Nov 2008 18:16:00 +0900 (JST)
Subject: Re: [PATCH 0/9] memcg updates (14/Nov/2008)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh said:
> KAMEZAWA Hiroyuki wrote:
> Time to resynchronize the patches! I've taken a cursory look, not done a
> detailed review of those patches. Help with hierarchy would be nice, I've
> got
> most of the patches nailed down, except for resynchronization with mmotm.
>
I have no other patches now and I'd like to use time for testing and
reviewing. So, it's nice time to resynchronize patches, yes.

Okay, let's start hierarchy support first. I'll stop "new feature" work
for a while.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
