Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m49DZ2qJ031743
	for <linux-mm@kvack.org>; Fri, 9 May 2008 19:05:02 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m49DYrVC938012
	for <linux-mm@kvack.org>; Fri, 9 May 2008 19:04:53 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m49DXW47024484
	for <linux-mm@kvack.org>; Fri, 9 May 2008 19:03:33 +0530
Message-ID: <48245308.9010401@linux.vnet.ibm.com>
Date: Fri, 09 May 2008 19:05:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 3/4] Add rlimit controller accounting and control
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain> <20080503213814.3140.66080.sendpatchset@localhost.localdomain> <6599ad830805062029m37b507dcue737e1affddeb120@mail.gmail.com> <48230FBB.20105@linux.vnet.ibm.com> <6599ad830805081445w5991b47cld2861aab26ac6323@mail.gmail.com>
In-Reply-To: <6599ad830805081445w5991b47cld2861aab26ac6323@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Thu, May 8, 2008 at 7:35 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  I currently intend to use this controller for controlling memory related
>>  rlimits, like address space and mlock'ed memory. How about we use something like
>>  "memrlimit"?
> 
> Sounds reasonable.
> 
>>  Good suggestion, but it will be hard if not impossible to account the data
>>  correctly as it changes, if we do the accounting/summation at bind time. We'll
>>  need a really big lock to do it, something I want to avoid. Did you have
>>  something else in mind?
> 
> Yes, it'll be tricky but I think worthwhile. I believe it can be done
> without the charge/uncharge code needing to take a global lock, except
> for when we're actually binding/unbinding, with careful use of RCU.
> 

[snip]

This is an optimization that I am willing to consider later in the project. At
first I want to focus on functionality. I would like to optimize once I know
that the functionality has been well tested by a good base of users and make
sure that the optimization is real.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
