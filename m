Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3D48482F64
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:55:08 -0400 (EDT)
Received: by wijp11 with SMTP id p11so99144026wij.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:55:07 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id lj8si12094446wjc.46.2015.10.21.07.55.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 07:55:07 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so78478813wic.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:55:06 -0700 (PDT)
Date: Wed, 21 Oct 2015 16:55:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151021145505.GE8805@dhcp22.suse.cz>
References: <201510212126.JIF90648.HOOFJVFQLMStOF@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org>
 <20151021143337.GD8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Wed 21-10-15 09:49:07, Christoph Lameter wrote:
> On Wed, 21 Oct 2015, Michal Hocko wrote:
> 
> > Because all the WQ workers are stuck somewhere, maybe in the memory
> > allocation which cannot make any progress and the vmstat update work is
> > queued behind them.
> >
> > At least this is my current understanding.
> 
> Eww. Maybe need a queue that does not do such evil things as memory
> allocation?

I am not sure how to achieve that. Requiring non-sleeping worker would
work out but do we have enough users to add such an API?

I would rather see vmstat using dedicated kernel thread(s) for this this
purpose. We have discussed that in the past but it hasn't led anywhere.

Anyway the workaround for this issue seems to be pretty trivial and
shouldn't affect users out of direct reclaim much so it sounds good
enough to me. Longterm we should really get rid of scan_reclaimable from
the direct reclaim altogether.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
