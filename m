Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8EDCA6B004D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 11:19:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3OFJYif001158
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 25 Apr 2009 00:19:34 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B04845DE62
	for <linux-mm@kvack.org>; Sat, 25 Apr 2009 00:19:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0843C45DE51
	for <linux-mm@kvack.org>; Sat, 25 Apr 2009 00:19:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D91F41DB803C
	for <linux-mm@kvack.org>; Sat, 25 Apr 2009 00:19:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 84E971DB803E
	for <linux-mm@kvack.org>; Sat, 25 Apr 2009 00:19:33 +0900 (JST)
Message-ID: <6e429f293fa1e3d02900a41039861119.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090424122441.GD3944@balbir.in.ibm.com>
References: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
    <20090424122441.GD3944@balbir.in.ibm.com>
Date: Sat, 25 Apr 2009 00:19:33 +0900 (JST)
Subject: Re: [RFC][PATCH 0/9] memcg soft limit v2 (new design)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-03
> 17:08:35]:
>> In this v2.
>>  - problems under use_hierarchy=1 case are fixed.
>>  - more hooks are added.
>>  - codes are cleaned up.
>>
>
> The results seem good so far with some basic tests I've been doing.
> I'll come back with more feedback, I would like to see this feature in
> -mm soon.
>
Thank you. I'll update this. But now I have bugfix patch for
stale swap caches (coop with Nishimura). Then, I'll go ahead one by one.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
