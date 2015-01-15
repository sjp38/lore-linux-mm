Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4166B006E
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 14:04:51 -0500 (EST)
Received: by mail-la0-f50.google.com with SMTP id pn19so15254624lab.9
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 11:04:50 -0800 (PST)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com. [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id ss9si867579lbb.89.2015.01.15.11.04.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 11:04:50 -0800 (PST)
Received: by mail-lb0-f181.google.com with SMTP id u14so5409454lbd.12
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 11:04:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150115185543.GA28195@htj.dyndns.org>
References: <20150115180242.10450.92.stgit@buzz>
	<20150115184914.10450.51964.stgit@buzz>
	<20150115185543.GA28195@htj.dyndns.org>
Date: Thu, 15 Jan 2015 23:04:49 +0400
Message-ID: <CALYGNiPY2K6F+OFoCV5XShrXaQOiyGXreR=4TC=Mp7axTiF0YQ@mail.gmail.com>
Subject: Re: [PATCH 3/6] memcg: track shared inodes with dirty pages
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Konstantin Khebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, Roman Gushchin <klamm@yandex-team.ru>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Jan 15, 2015 at 9:55 PM, Tejun Heo <tj@kernel.org> wrote:
> On Thu, Jan 15, 2015 at 09:49:14PM +0300, Konstantin Khebnikov wrote:
>> From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>
>> Inode is owned only by one memory cgroup, but if it's shared it might
>> contain pages from multiple cgroups. This patch detects this situation
>> in memory reclaiemer and marks dirty inode with flag I_DIRTY_SHARED
>> which is cleared only when data is completely written. Memcg writeback
>> always writes such inodes.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>
> This conflicts with the writeback cgroup support patchset which will
> solve the writeback and memcg problem a lot more comprehensively.
>
>  http://lkml.kernel.org/g/1420579582-8516-1-git-send-email-tj@kernel.org
>
> Thanks.

I know. Absolutely accurate per-page solution looks too complicated for me.
Is there any real demand for accurate handling dirty set in shared inodes?
Doing whole accounting in per-inode basis makes life so much easier.

>
> --
> tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
