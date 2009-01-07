Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 718336B0047
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 13:56:51 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n07It934005706
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 05:55:09 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n07Ivgh02158720
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 05:57:42 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n07Iukxf026936
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 05:56:46 +1100
Date: Thu, 8 Jan 2009 00:26:27 +0530
From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/4] Memory controller soft limit patches
Message-ID: <20090107185627.GL4145@linux.vnet.ibm.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 08, 2009 at 12:11:10AM +0530, Balbir Singh wrote:
> 
> Here is v1 of the new soft limit implementation. Soft limits is a new feature
> for the memory resource controller, something similar has existed in the
> group scheduler in the form of shares. We'll compare shares and soft limits
> below. I've had soft limit implementations earlier, but I've discarded those
> approaches in favour of this one.
> 
> Soft limits are the most useful feature to have for environments where
> the administrator wants to overcommit the system, such that only on memory
> contention do the limits become active. The current soft limits implementation
> provides a soft_limit_in_bytes interface for the memory controller and not
> for memory+swap controller. The implementation maintains an RB-Tree of groups
> that exceed their soft limit and starts reclaiming from the group that
> exceeds this limit by the maximum amount.
> 
> This is an RFC implementation and is not meant for inclusion
> 
> TODOs
> 
> 1. The shares interface is not yet implemented, the current soft limit
>    implementation is not yet hierarchy aware. The end goal is to add
>    a shares interface on top of soft limits and to maintain shares in
>    a manner similar to the group scheduler

Just to clarify, when there is no contention, you want to share memory
proportionally?

thanks,
-- 
regards,
Dhaval

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
