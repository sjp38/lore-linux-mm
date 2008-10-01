Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id m916Z3SC6148316
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 16:35:03 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m916QjHB219924
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 16:26:46 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m916Qjwv000588
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 16:26:45 +1000
Message-ID: <48E31821.6070004@linux.vnet.ibm.com>
Date: Wed, 01 Oct 2008 11:56:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 9/12] memcg allocate all page_cgroup at boot
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com> <20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com> <48E2F6A9.9010607@linux.vnet.ibm.com> <20081001140748.637b9831.kamezawa.hiroyu@jp.fujitsu.com> <48E30B02.3030506@linux.vnet.ibm.com> <20081001144150.3faa92ea.kamezawa.hiroyu@jp.fujitsu.com> <20081001151249.b6d697a5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081001151249.b6d697a5.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 1 Oct 2008 14:41:50 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>>> It will be easier to test/debug as well, we'll know if the problem is because of
>>> new page_cgroup being outside struct page rather then guessing if it was the
>>> atomic ops that caused the problem.
>>>
>> atomic_ops patch just rewrite exisiting behavior.
>>
> please forgive me to post v6 today, which passed 24h+ tests.
> v5 is a week old.
> Discussion about patch order is welcome. But please give me hint.

That sounds impressive. I'll test and review v6.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
