Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6156B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 21:34:47 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id c37so2335250wra.5
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 18:34:47 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 53sor8909936wrv.61.2018.03.07.18.34.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Mar 2018 18:34:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <d6ec23eb-a886-9fef-99c7-51c7ba4f5d18@infradead.org>
References: <20180308002016.L3JwBaNZ9%akpm@linux-foundation.org>
 <41ec9eeb-f0bf-e26d-e3ae-4a684c314360@infradead.org> <d6ec23eb-a886-9fef-99c7-51c7ba4f5d18@infradead.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 7 Mar 2018 18:34:44 -0800
Message-ID: <CALvZod53CV+R0CeVPDJ=3JAtFjyOfSSSrr3x0tqAWHec0AshTA@mail.gmail.com>
Subject: Re: mmotm 2018-03-07-16-19 uploaded (UML & memcg)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, broonie@kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-next@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, mm-commits@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Mar 7, 2018 at 6:23 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 03/07/2018 06:20 PM, Randy Dunlap wrote:
>> On 03/07/2018 04:20 PM, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2018-03-07-16-19 has been uploaded to
>>>
>>>    http://www.ozlabs.org/~akpm/mmotm/
>>>
>>> mmotm-readme.txt says
>>>
>>> README for mm-of-the-moment:
>>>
>>> http://www.ozlabs.org/~akpm/mmotm/
>>>
>>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>>> more than once a week.
>>
>> UML on i386 and/or x86_64:
>>
>> defconfig, CONFIG_MEMCG is not set:
>>
>> ../fs/notify/group.c: In function 'fsnotify_final_destroy_group':
>> ../fs/notify/group.c:41:24: error: dereferencing pointer to incomplete type
>>    css_put(&group->memcg->css);
>>                         ^
>>
>> From: Shakeel Butt <shakeelb@google.com>
>> Subject: fs: fsnotify: account fsnotify metadata to kmemcg
>
>
>
> or x86 any time that CONFIG_MEMCG is not enabled.
>
>

Sorry about that. Replacing this with mem_cgroup_put(group->memcg)
should solve the issue on the mm tree.
