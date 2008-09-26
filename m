Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m8Q8f0E7003200
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 14:11:00 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8Q8f0dN1179702
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 14:11:00 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m8Q8f0j1025536
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 18:41:00 +1000
Message-ID: <48DCA01C.9020701@linux.vnet.ibm.com>
Date: Fri, 26 Sep 2008 14:11:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 3/12] memcg make root cgroup unlimited.
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com> <20080925151543.ba307898.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080925151543.ba307898.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Make root cgroup of memory resource controller to have no limit.
> 
> By this, users cannot set limit to root group. This is for making root cgroup
> as a kind of trash-can.
> 
> For accounting pages which has no owner, which are created by force_empty,
> we need some cgroup with no_limit. A patch for rewriting force_empty will
> will follow this one.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is an ABI change (although not too many people might be using it, I wonder
if we should add memory.features (a set of flags and let users enable them and
provide good defaults), like sched features.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
