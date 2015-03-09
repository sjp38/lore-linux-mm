Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id E94836B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 11:31:21 -0400 (EDT)
Received: by qgdz60 with SMTP id z60so29269236qgd.5
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 08:31:21 -0700 (PDT)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id e25si15392404qkh.43.2015.03.09.08.31.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 08:31:20 -0700 (PDT)
Received: by qcvp6 with SMTP id p6so5915178qcv.5
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 08:31:20 -0700 (PDT)
Date: Mon, 9 Mar 2015 11:31:16 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] memcg: add per cgroup dirty page accounting
Message-ID: <20150309153116.GV13283@htj.duckdns.org>
References: <1425876632-6681-1-git-send-email-gthelen@google.com>
 <20150309135234.GU13283@htj.duckdns.org>
 <CAHH2K0aFJ1Ti+gWkHM1VC=mdLZQE2Yn+8gpvthOnv89DjmVAAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHH2K0aFJ1Ti+gWkHM1VC=mdLZQE2Yn+8gpvthOnv89DjmVAAQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Konstantin Khebnikov <khlebnikov@yandex-team.ru>, Dave Chinner <david@fromorbit.com>, Sha Zhengju <handai.szj@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Mar 09, 2015 at 11:29:05AM -0400, Greg Thelen wrote:
> On Mon, Mar 9, 2015 at 9:52 AM, Tejun Heo <tj@kernel.org> wrote:
> > Hello, Greg.
> >
> > On Sun, Mar 08, 2015 at 09:50:32PM -0700, Greg Thelen wrote:
> >> When modifying PG_Dirty on cached file pages, update the new
> >> MEM_CGROUP_STAT_DIRTY counter.  This is done in the same places where
> >> global NR_FILE_DIRTY is managed.  The new memcg stat is visible in the
> >> per memcg memory.stat cgroupfs file.  The most recent past attempt at
> >> this was http://thread.gmane.org/gmane.linux.kernel.cgroups/8632
> >
> > Awesome.  I had a similar but inferior (haven't noticed the irqsave
> > problem) patch in my series.  Replaced that with this one.  I'm
> > getting ready to post the v2 of the cgroup writeback patchset.  Do you
> > mind routing this patch together in the patchset?
> 
> I don't object to routing this patch with the larger writeback series.
> But I do have small concern that merging the writeback series might
> take a while and this patch has independent value.  For now, I'd say:
> go for it.  If the series gets stalled we might want to split it off.

Yeah, sure, either is fine for me.  Hmm... I'm gonna move this patch
to the head of the series so that it can go either way.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
