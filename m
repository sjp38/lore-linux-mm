Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA6EUUg3000736
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 23:30:30 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B3D545DD7A
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 23:30:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DCA5745DD78
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 23:30:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C887E1DB803E
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 23:30:29 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D69BE08001
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 23:30:29 +0900 (JST)
Message-ID: <6941.10.75.179.62.1225981828.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <4912F53A.2070407@linux.vnet.ibm.com>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
    <49129493.9070103@linux.vnet.ibm.com>
    <20081106194153.220157ec.kamezawa.hiroyu@jp.fujitsu.com>
    <4912F53A.2070407@linux.vnet.ibm.com>
Date: Thu, 6 Nov 2008 23:30:28 +0900 (JST)
Subject: Re: [RFC][PATCH 7/6] memcg: add atribute (for change bahavior
     ofrmdir)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Balbir Singh said:
> KAMEZAWA Hiroyuki wrote:
>> BTW, cost of movement itself is not far from cost for force_empty.
>>
>> If you can't find why "forget" is bad, please consider one more day.
>
> The attributes seem quite reasonable, I've taken a quick look, not done a
> full
> review or test.
>
Thanks, I'll go ahead in this direction.

By the way, should we keep "one value per one file" for attributes ?
If so, I'll add a new file just for this.
Current my patch allows prural attributes set on a file.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
