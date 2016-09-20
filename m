Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 307956B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 04:31:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so10405506wmc.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 01:31:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si25511533wmh.60.2016.09.20.01.31.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 01:31:33 -0700 (PDT)
Subject: Re: [PATCH] mem-hotplug: Don't clear the only node in new_node_page()
References: <1473044391.4250.19.camel@TP420>
 <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
 <20160912091811.GE14524@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c144f768-7591-8bb8-4238-b3f1ecaf8b4b@suse.cz>
Date: Tue, 20 Sep 2016 10:31:31 +0200
MIME-Version: 1.0
In-Reply-To: <20160912091811.GE14524@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zhong <zhong@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, jallen@linux.vnet.ibm.com, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 09/12/2016 11:18 AM, Michal Hocko wrote:
> On Mon 05-09-16 16:18:29, Vlastimil Babka wrote:
>
>> Also OOM is skipped for __GFP_THISNODE
>> allocations, so we might also consider the same for nodemask-constrained
>> allocations?
>>
>> > The patch checks whether it is the last node on the system, and if it is, then
>> > don't clear the nid in the nodemask.
>>
>> I'd rather see the allocation not OOM, and rely on the fallback in
>> new_node_page() that doesn't have nodemask. But I suspect it might also make
>> sense to treat empty nodemask as something unexpected and put some WARN_ON
>> (instead of OOM) in the allocator.
>
> To be honest I am really not all that happy about 394e31d2ceb4
> ("mem-hotplug: alloc new page from a nearest neighbor node when
> mem-offline") and find it a bit fishy. I would rather re-iterate that
> patch rather than build new hacks on top.

OK, IIRC I suggested the main idea of clearing the current node from nodemask 
and relying on nodelist to get us the other nodes sorted by their distance. 
Which I thought was an easy way to get to the theoretically optimal result. How 
would you rewrite it then? (but note that the fix is already mainline).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
