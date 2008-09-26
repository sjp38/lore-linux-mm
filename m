Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8Q9bGKE021822
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 19:37:16 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8Q9U33e299726
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 19:30:23 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8Q9U2aG006549
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 19:30:02 +1000
Message-ID: <48DCAB8C.5030405@linux.vnet.ibm.com>
Date: Fri, 26 Sep 2008 14:59:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 3/12] memcg make root cgroup unlimited.
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com> <20080925151543.ba307898.kamezawa.hiroyu@jp.fujitsu.com> <48DCA01C.9020701@linux.vnet.ibm.com> <20080926182122.c7c88a65.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080926182122.c7c88a65.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 26 Sep 2008 14:11:00 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> Make root cgroup of memory resource controller to have no limit.
>>>
>>> By this, users cannot set limit to root group. This is for making root cgroup
>>> as a kind of trash-can.
>>>
>>> For accounting pages which has no owner, which are created by force_empty,
>>> we need some cgroup with no_limit. A patch for rewriting force_empty will
>>> will follow this one.
>>>
>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> This is an ABI change (although not too many people might be using it, I wonder
>> if we should add memory.features (a set of flags and let users enable them and
>> provide good defaults), like sched features.
>>
> I think "feature" flag is complicated, at this stage.
> We'll add more features and not settled yet.
> 

I know.. but breaking ABI is a bad bad thing. We'll have to keep the feature
flags extensible (add new things). If we all feel we don't have enough users
affected by this change, I might agree with you and make that change.

> Hmm, if you don't like this,
> calling try_to_free_page() at force_empty() instead of move_account() ?
> 

Not sure I understand this.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
