Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3E86B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 11:29:27 -0400 (EDT)
Received: by obbgq1 with SMTP id gq1so34344875obb.2
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 08:29:27 -0700 (PDT)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com. [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id i125si1175203oib.76.2015.03.09.08.29.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 08:29:26 -0700 (PDT)
Received: by obbgq1 with SMTP id gq1so34344666obb.2
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 08:29:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150309135234.GU13283@htj.duckdns.org>
References: <1425876632-6681-1-git-send-email-gthelen@google.com> <20150309135234.GU13283@htj.duckdns.org>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 9 Mar 2015 11:29:05 -0400
Message-ID: <CAHH2K0aFJ1Ti+gWkHM1VC=mdLZQE2Yn+8gpvthOnv89DjmVAAQ@mail.gmail.com>
Subject: Re: [PATCH] memcg: add per cgroup dirty page accounting
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Konstantin Khebnikov <khlebnikov@yandex-team.ru>, Dave Chinner <david@fromorbit.com>, Sha Zhengju <handai.szj@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Mar 9, 2015 at 9:52 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Greg.
>
> On Sun, Mar 08, 2015 at 09:50:32PM -0700, Greg Thelen wrote:
>> When modifying PG_Dirty on cached file pages, update the new
>> MEM_CGROUP_STAT_DIRTY counter.  This is done in the same places where
>> global NR_FILE_DIRTY is managed.  The new memcg stat is visible in the
>> per memcg memory.stat cgroupfs file.  The most recent past attempt at
>> this was http://thread.gmane.org/gmane.linux.kernel.cgroups/8632
>
> Awesome.  I had a similar but inferior (haven't noticed the irqsave
> problem) patch in my series.  Replaced that with this one.  I'm
> getting ready to post the v2 of the cgroup writeback patchset.  Do you
> mind routing this patch together in the patchset?

I don't object to routing this patch with the larger writeback series.
But I do have small concern that merging the writeback series might
take a while and this patch has independent value.  For now, I'd say:
go for it.  If the series gets stalled we might want to split it off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
