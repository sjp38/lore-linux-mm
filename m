Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id D31AC6B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 09:52:38 -0400 (EDT)
Received: by qcxm20 with SMTP id m20so2124744qcx.3
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 06:52:38 -0700 (PDT)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com. [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id l1si5954995qkh.110.2015.03.09.06.52.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 06:52:38 -0700 (PDT)
Received: by qgfi50 with SMTP id i50so28350871qgf.9
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 06:52:37 -0700 (PDT)
Date: Mon, 9 Mar 2015 09:52:34 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] memcg: add per cgroup dirty page accounting
Message-ID: <20150309135234.GU13283@htj.duckdns.org>
References: <1425876632-6681-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425876632-6681-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Konstantin Khebnikov <khlebnikov@yandex-team.ru>, Dave Chinner <david@fromorbit.com>, Sha Zhengju <handai.szj@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hello, Greg.

On Sun, Mar 08, 2015 at 09:50:32PM -0700, Greg Thelen wrote:
> When modifying PG_Dirty on cached file pages, update the new
> MEM_CGROUP_STAT_DIRTY counter.  This is done in the same places where
> global NR_FILE_DIRTY is managed.  The new memcg stat is visible in the
> per memcg memory.stat cgroupfs file.  The most recent past attempt at
> this was http://thread.gmane.org/gmane.linux.kernel.cgroups/8632

Awesome.  I had a similar but inferior (haven't noticed the irqsave
problem) patch in my series.  Replaced that with this one.  I'm
getting ready to post the v2 of the cgroup writeback patchset.  Do you
mind routing this patch together in the patchset?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
