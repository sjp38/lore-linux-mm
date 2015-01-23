Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 527DF6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 12:00:24 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id vb8so8168343obc.10
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 09:00:24 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id i203si1112104oif.10.2015.01.23.09.00.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 09:00:22 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YEhac-001hbD-Li
	for linux-mm@kvack.org; Fri, 23 Jan 2015 17:00:11 +0000
Message-ID: <54C27E07.6000908@roeck-us.net>
Date: Fri, 23 Jan 2015 08:59:51 -0800
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org> <20150123050802.GB22751@roeck-us.net> <20150123141817.GA22926@phnom.home.cmpxchg.org> <alpine.DEB.2.11.1501230908560.15325@gentwo.org> <20150123160204.GA32592@phnom.home.cmpxchg.org>
In-Reply-To: <20150123160204.GA32592@phnom.home.cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, mhocko@suse.cz

On 01/23/2015 08:02 AM, Johannes Weiner wrote:
> On Fri, Jan 23, 2015 at 09:17:44AM -0600, Christoph Lameter wrote:
>> On Fri, 23 Jan 2015, Johannes Weiner wrote:
>>
>>> Is the assumption of this patch wrong?  Does the specified node have
>>> to be online for the fallback to work?
>>
>> Nodes that are offline have no control structures allocated and thus
>> allocations will likely segfault when the address of the controls
>> structure for the node is accessed.
>>
>> If we wanted to prevent that then every allocation would have to add a
>> check to see if the nodes are online which would impact performance.
>
> Okay, that makes sense, thank you.
>
> Andrew, can you please drop this patch?
>
Problem is that there are three patches.

2537ffb mm: memcontrol: consolidate swap controller code
2f9b346 mm: memcontrol: consolidate memory controller initialization
a40d0d2 mm: memcontrol: remove unnecessary soft limit tree node test

Reverting (or dropping) a40d0d2 alone is not possible since it modifies
mem_cgroup_soft_limit_tree_init which is removed by 2f9b346.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
