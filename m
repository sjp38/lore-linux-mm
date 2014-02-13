Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 64DB96B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 19:39:19 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so9742818pdj.32
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 16:39:19 -0800 (PST)
Received: from mail-pb0-x233.google.com (mail-pb0-x233.google.com [2607:f8b0:400e:c01::233])
        by mx.google.com with ESMTPS id x3si41330pbf.271.2014.02.12.16.39.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 16:39:18 -0800 (PST)
Received: by mail-pb0-f51.google.com with SMTP id un15so9973970pbc.24
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 16:39:18 -0800 (PST)
Date: Wed, 12 Feb 2014 16:38:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] cgroup: bring back kill_cnt to order css
 destruction
In-Reply-To: <20140213002853.GC2916@htj.dyndns.org>
Message-ID: <alpine.LSU.2.11.1402121636290.5728@eggly.anvils>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils> <20140207164321.GE6963@cmpxchg.org> <alpine.LSU.2.11.1402121417230.5029@eggly.anvils> <alpine.LSU.2.11.1402121504150.5029@eggly.anvils> <20140213002853.GC2916@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 12 Feb 2014, Tejun Heo wrote:
> 
> Not that your implementation is bad or anything but the patch itself
> somehow makes me cringe a bit.  It's probably just because it has to
> add to the already overly complicated offline path.  Guaranteeing
> strict offline ordering might be a good idea but at least for the
> immediate bug fix, I agree that the memcg specific fix seems better
> suited.  Let's apply that one and reconsider this one if it turns out
> we do need strict offline reordering.

Yes, I agree completely - thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
