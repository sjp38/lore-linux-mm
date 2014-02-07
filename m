Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 35E1C6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 16:06:49 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so3660427pab.26
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 13:06:48 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id wm3si6394456pab.49.2014.02.07.13.06.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 13:06:48 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so3699546pab.3
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 13:06:47 -0800 (PST)
Date: Fri, 7 Feb 2014 13:06:00 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] cgroup: use an ordered workqueue for cgroup
 destruction
In-Reply-To: <20140207203508.GC8833@htj.dyndns.org>
Message-ID: <alpine.LSU.2.11.1402071300300.926@eggly.anvils>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils> <20140207140402.GA3304@htj.dyndns.org> <alpine.LSU.2.11.1402071130250.333@eggly.anvils> <20140207203508.GC8833@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 7 Feb 2014, Tejun Heo wrote:
> On Fri, Feb 07, 2014 at 12:20:44PM -0800, Hugh Dickins wrote:
> 
> > You don't return to this concern in the following mails of the thread:
> > did you later decide that it actually won't be a problem?  I'll assume
> > so for the moment, since you took the patch, but please reassure me.
> 
> I was just worrying about a different solution where we take
> css_offline invocation outside of cgroup_mutex and bumping up
> max_active.  There's nothing to worry about your patch.  Sorry about
> not being clear.  :)

Thanks a lot for your detailed and admirably responsive explanations.
You were looking ahead, I see that now, and I'm gratefully reassured :)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
