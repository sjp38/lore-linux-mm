Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 65EBF6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 20:32:43 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so3836201pbc.36
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 17:32:43 -0700 (PDT)
Message-ID: <5240DD83.1070509@huawei.com>
Date: Tue, 24 Sep 2013 08:32:03 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 0/5] memcg, cgroup: kill css id
References: <524001F8.6070205@huawei.com> <20130923130816.GH30946@htj.dyndns.org> <20130923131215.GI30946@htj.dyndns.org>
In-Reply-To: <20130923131215.GI30946@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2013/9/23 21:12, Tejun Heo wrote:
> On Mon, Sep 23, 2013 at 09:08:16AM -0400, Tejun Heo wrote:
>> Hello,
>>
>> On Mon, Sep 23, 2013 at 04:55:20PM +0800, Li Zefan wrote:
>>> The whole patchset has been acked and reviewed by Michal and Tejun.
>>> Could you merge it into mm tree?
>>
>> Ah... I really hoped that this had been merged during -rc1 window.
>> Andrew, would it be okay to carry this series through cgroup tree?  It
>> doesn't really have much to do with mm proper and it's a PITA to have
>> to keep updating css_id code from cgroup side when it's scheduled to
>> go away.  If carried in -mm, it's likely to cause conflicts with
>> ongoing cgroup changes too.

I would love to see this patchset go through cgroup tree. The changes to
memcg is quite small, and as -mm tree is based on -next it won't cause
future conflicts.

> 
> Also, wasn't this already in -mm during the last devel cycle?  ISTR
> conflicts with it in -mm with other cgroup core changes.  Is there any
> specific reason why this wasn't merged during the merge windw?
> 

No, it never went into -mm tree... I guess it's because Andrew was too
busy and overlooked this patchset?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
