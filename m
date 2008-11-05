Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mA5Dsu64019303
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 00:54:56 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA5DtiHf1913002
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 00:55:44 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA5Dte4s027468
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 00:55:41 +1100
Message-ID: <4911A5D7.8090505@linux.vnet.ibm.com>
Date: Wed, 05 Nov 2008 19:25:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 1/4] Memory cgroup hierarchy documentation
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop> <20081101184824.2575.5935.sendpatchset@balbir-laptop> <6599ad830811032225w229d3a29k17b9a38cb76a521f@mail.gmail.com> <6599ad830811032226h4c4a81d4hb030953a4e0906db@mail.gmail.com>
In-Reply-To: <6599ad830811032226h4c4a81d4hb030953a4e0906db@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Nov 3, 2008 at 10:25 PM, Paul Menage <menage@google.com> wrote:
>> That's not a very intuitive interface. Why not memory.use_hierarchy?
> 
> Or for consistency with the existing cpuset.memory_pressure_enabled,
> just memory.hierarchy_enabled ?

Yes, I can change it to that.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
