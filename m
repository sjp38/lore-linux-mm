Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 75CBC280257
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 08:16:19 -0400 (EDT)
Received: by wicgi11 with SMTP id gi11so98784260wic.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 05:16:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ju8si14862164wid.83.2015.07.03.05.16.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Jul 2015 05:16:17 -0700 (PDT)
Date: Fri, 3 Jul 2015 14:16:11 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 28/51] writeback, blkcg: restructure
 blk_{set|clear}_queue_congested()
Message-ID: <20150703121611.GI23329@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-29-git-send-email-tj@kernel.org>
 <20150630150254.GN7252@quack.suse.cz>
 <20150702013815.GE26440@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150702013815.GE26440@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Wed 01-07-15 21:38:15, Tejun Heo wrote:
> Hello, Jan.
> 
> On Tue, Jun 30, 2015 at 05:02:54PM +0200, Jan Kara wrote:
> > BTW, I'd prefer if this was merged with the following patch. I was
> > wondering for a while about the condition at the beginning of
> > blk_clear_congested() only to learn it gets modified to the one I'd expect
> > in the following patch :)
> 
> The patches are already merged, it's a bit too late to discuss but I
> usually try to keep each step quite granular.  e.g. I try hard to
> avoid combining code relocation / restructuring with actual functional
> changes so that the code change A -> B -> C where B is functionally
> identical to A and C is different from B only where the actual
> functional changes occur.

Yeah, I didn't mean this comment as something you should change even if the
series wasn't applied yet (it isn't that bad). I meant it more as a
feedback for future.
 
> I think your argument is that as C is the final form, introducing B is
> actually harder for reviewing.  I have to disagree with that pretty
> strongly.  When you only think about the functional transformations A
> -> C might seem easier but given that we also want to verify the
> changes - both during development and review - it's far more
> beneficial to go through the intermediate stage as that isolates
> functional changes from mere code transformation.
>
> Another thing to consider is that there's a difference when one is
> reviewing a patch series as a whole tracking the development of big
> picture and later when somebody tries to debug or bisect a bug the
> patchset introduces.  At that point, the general larger flow isn't
> really in the picture and combining structural and functional changes
> may make understanding what's going on significantly harder in
> addition to making such errors more likely and less detectable in the
> first place.

In general I agree with you - separating refactoring from functional
changes is useful. I just think you took it a bit to the extreme in this
series :) When I'm reviewing patches, I'm also checking whether the
function does what it's "supposed" to do. So in case of splitting patches
like this I have to go through the series and verify that in the end we end
up with what one would expect. And sometimes the correctness is so much
easier to verify when changes are split that the extra patch chasing is
worth it.  But in simple cases like this one, merged patch would have been
easier for me. I guess it's a matter of taste...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
