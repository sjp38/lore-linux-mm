Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57ABD6B03A2
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:47:47 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w37so30375689wrc.2
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:47:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t25si11089389wra.239.2017.03.02.07.47.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:47:46 -0800 (PST)
Date: Thu, 2 Mar 2017 16:47:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
Message-ID: <20170302154744.GN1404@dhcp22.suse.cz>
References: <20170302124909.GE1404@dhcp22.suse.cz>
 <20170302130009.GC3213@bfoster.bfoster>
 <20170302132755.GG1404@dhcp22.suse.cz>
 <20170302134157.GD3213@bfoster.bfoster>
 <20170302135001.GI1404@dhcp22.suse.cz>
 <20170302142315.GE3213@bfoster.bfoster>
 <20170302143441.GL1404@dhcp22.suse.cz>
 <20170302145131.GF3213@bfoster.bfoster>
 <20170302151411.GM1404@dhcp22.suse.cz>
 <20170302153002.GG3213@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302153002.GG3213@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu 02-03-17 10:30:02, Brian Foster wrote:
> On Thu, Mar 02, 2017 at 04:14:11PM +0100, Michal Hocko wrote:
[...]
> > I am not objecting to adding fatal_signal_pending as well I just thought
> > that from the logic POV breaking after reaching the minimum size is just
> > the right thing to do. We can optimize further by checking
> > fatal_signal_pending and reducing retries when we know it doesn't make
> > much sense but that should be done on top as an optimization IMHO.
> > 
> 
> I don't think of it as an optimization to not invoke calls (a
> non-deterministic number of times) that we know are going to fail, but

the point is that vmalloc failure modes are an implementation detail
which might change in the future. The fix should be really independent
on the current implementation that is why I think the
fatal_signal_pending is just an optimization.

> ultimately I don't care too much how it's framed or if it's done in
> separate patches or whatnot. As long as they are posted at the same
> time. ;)

Done

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
