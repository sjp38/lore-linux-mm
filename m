Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2714F6B0038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 06:00:58 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so49725188wms.7
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 03:00:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xs6si45665172wjc.244.2016.12.26.03.00.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Dec 2016 03:00:56 -0800 (PST)
Date: Mon, 26 Dec 2016 12:00:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Bug 4.9 and memorymanagement
Message-ID: <20161226110053.GA16042@dhcp22.suse.cz>
References: <20161225205251.nny6k5wol2s4ufq7@ikki.ethgen.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161225205251.nny6k5wol2s4ufq7@ikki.ethgen.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Klaus Ethgen <Klaus+lkml@ethgen.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

[CCing linux-mm]

On Sun 25-12-16 21:52:52, Klaus Ethgen wrote:
> Hello,
> 
> The last days I compiled version 4.9 for my i386 laptop. (Lenovo x61s)

Do you have memory cgroups enabled in runtime (aka does the same happen
with cgroup_disable=memory)?

> First, everything seems to be sane but after some sleep and awake
> (suspend to ram) cycles I seen some really weird behaviour ending in OOM
> or even complete freeze of the laptop.
> 
> What I was able to see is that it went to swap even if there is plenty
> of memory left. The OOMs was also with many memory left.

Could you paste those OOM reports from the kernel log?

> Once I also catched kswapd0 with running insane with 100% CPU
> utilization.
> 
> I first had in mind the CONFIG_SLAB_FREELIST_RANDOM setting and disabled
> it. This didn't made the problem to go away but it helped a little.
> Nevertheless, further OOM or other strange behaviour happened.
> 
> I went back to 4.8.15 now with the same config from 4.9 and everything
> gets back to normal.
> 
> So it seems for me that there are some really strange memory leaks in
> 4.9. The biggest problem is, that I do not know how to reproduce it
> reliable. The only what I know is that it happened after several
> suspends. (Not necessarily the first.)
> 
> Am I the only one seeing that behavior or do anybody have an idea what
> could went wrong?

no there were some reports recently and 32b with memory cgroups are
broken since 4.8 when the zone LRU's were moved to nodes.
>x 
> For the reference I put the .configs of the two compilings as attachment
> to this mail.
> 
> Please keep me in CC as I am not subscribed to LKML.
> 
> Regards
>    Klaus






-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
