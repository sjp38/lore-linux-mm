Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m915UiUu023884
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 11:00:44 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m915Ui1l1806342
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 11:00:44 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m915Uinx005433
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 11:00:44 +0530
Message-ID: <48E30B02.3030506@linux.vnet.ibm.com>
Date: Wed, 01 Oct 2008 11:00:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 9/12] memcg allocate all page_cgroup at boot
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com> <20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com> <48E2F6A9.9010607@linux.vnet.ibm.com> <20081001140748.637b9831.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081001140748.637b9831.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 01 Oct 2008 09:33:53 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Can we make this patch indepedent of the flags changes and push it in ASAP.
>>
> Need much work....Hmm..rewrite all again ? 
> 

I don't think you'll need to do a major rewrite? Will you? My concern is that
this patch does too much to be a single patch. Consider someone trying to do a
git-bisect to identify a problem? It is hard to review as well and I think the
patch that just removes struct page member can go in faster.

It will be easier to test/debug as well, we'll know if the problem is because of
new page_cgroup being outside struct page rather then guessing if it was the
atomic ops that caused the problem.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
