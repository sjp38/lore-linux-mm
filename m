Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 89DDB9003C7
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 21:38:19 -0400 (EDT)
Received: by qgeg89 with SMTP id g89so27077623qge.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 18:38:19 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id k87si4615686qkh.23.2015.07.01.18.38.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 18:38:18 -0700 (PDT)
Received: by qkei195 with SMTP id i195so42646205qke.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 18:38:18 -0700 (PDT)
Date: Wed, 1 Jul 2015 21:38:15 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 28/51] writeback, blkcg: restructure
 blk_{set|clear}_queue_congested()
Message-ID: <20150702013815.GE26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-29-git-send-email-tj@kernel.org>
 <20150630150254.GN7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150630150254.GN7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello, Jan.

On Tue, Jun 30, 2015 at 05:02:54PM +0200, Jan Kara wrote:
> BTW, I'd prefer if this was merged with the following patch. I was
> wondering for a while about the condition at the beginning of
> blk_clear_congested() only to learn it gets modified to the one I'd expect
> in the following patch :)

The patches are already merged, it's a bit too late to discuss but I
usually try to keep each step quite granular.  e.g. I try hard to
avoid combining code relocation / restructuring with actual functional
changes so that the code change A -> B -> C where B is functionally
identical to A and C is different from B only where the actual
functional changes occur.

I think your argument is that as C is the final form, introducing B is
actually harder for reviewing.  I have to disagree with that pretty
strongly.  When you only think about the functional transformations A
-> C might seem easier but given that we also want to verify the
changes - both during development and review - it's far more
beneficial to go through the intermediate stage as that isolates
functional changes from mere code transformation.

Another thing to consider is that there's a difference when one is
reviewing a patch series as a whole tracking the development of big
picture and later when somebody tries to debug or bisect a bug the
patchset introduces.  At that point, the general larger flow isn't
really in the picture and combining structural and functional changes
may make understanding what's going on significantly harder in
addition to making such errors more likely and less detectable in the
first place.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
