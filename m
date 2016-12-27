Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 01C206B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 07:05:31 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id iq1so23909417wjb.1
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 04:05:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e138si45983053wmd.25.2016.12.27.04.05.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Dec 2016 04:05:29 -0800 (PST)
Date: Tue, 27 Dec 2016 13:05:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Bug 4.9 and memorymanagement
Message-ID: <20161227120525.GH1308@dhcp22.suse.cz>
References: <20161226110053.GA16042@dhcp22.suse.cz>
 <66baf7dd-c5e3-e11c-092f-3a642c306e63@I-love.SAKURA.ne.jp>
 <20161227114821.j3dl3r7segov6tb3@ikki.ethgen.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161227114821.j3dl3r7segov6tb3@ikki.ethgen.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Klaus Ethgen <Klaus+lkml@ethgen.de>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 27-12-16 12:48:24, Klaus Ethgen wrote:
[...]
> By the way, I find the following two messages often. Maybe they are
> unrelated, maybe not.
>    [31633.189121] Purging GPU memory, 144 pages freed, 5692 pages still pinned.
>    [31638.530025] Unable to lock GPU to purge memory.

I do not think this makes much of a difference for the oom reports. See
more below:

[...]
>    [28756.498366] Xorg invoked oom-killer: gfp_mask=0x24200d4(GFP_USER|GFP_DMA32|__GFP_RECLAIMABLE), nodemask=0, order=0, oom_score_adj=0
[...]
>    [28756.498761] Node 0 active_anon:409988kB inactive_anon:233592kB active_file:1272348kB inactive_file:720884kB unevictable:27744kB isolated(anon):0kB isolated(file):0kB mapped:190792kB dirty:4656kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 35332kB writeback_tmp:0kB unstable:0kB pages_scanned:4062806 all_unreclaimable? yes
>    [28756.498769] DMA free:4116kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:1568kB inactive_file:0kB unevictable:0kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclaimable:9848kB slab_unreclaimable:376kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
>    lowmem_reserve[]: 0 833 3008 3008
>    [28756.498782] Normal free:42404kB min:42416kB low:53020kB high:63624kB active_anon:1316kB inactive_anon:20540kB active_file:548376kB inactive_file:60kB unevictable:0kB writepending:260kB present:892920kB managed:854328kB mlocked:0kB slab_reclaimable:184192kB slab_unreclaimable:47020kB kernel_stack:2728kB pagetables:0kB bounce:0kB free_pcp:936kB local_pcp:216kB free_cma:0kB
[...]
> 
>    [28757.732436] updatedb.mlocat invoked oom-killer: gfp_mask=0x2400840(GFP_NOFS|__GFP_NOFAIL), nodemask=0, order=0, oom_score_adj=0
>    [28757.732649] Node 0 active_anon:124120kB inactive_anon:61840kB active_file:1280688kB inactive_file:713860kB unevictable:27744kB isolated(anon):0kB isolated(file):0kB mapped:103164kB dirty:0kB writeback:4kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 27352kB writeback_tmp:0kB unstable:0kB pages_scanned:3674354 all_unreclaimable? yes
>    [28757.732656] DMA free:4116kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:1568kB inactive_file:0kB unevictable:0kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclaimable:9848kB slab_unreclaimable:376kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
>    lowmem_reserve[]: 0 833 3008 3008
>    [28757.732669] Normal free:42324kB min:42416kB low:53020kB high:63624kB active_anon:1312kB inactive_anon:20408kB active_file:549628kB inactive_file:40kB unevictable:0kB writepending:0kB present:892920kB managed:854328kB mlocked:0kB slab_reclaimable:184036kB slab_unreclaimable:46960kB kernel_stack:2384kB pagetables:0kB bounce:0kB free_pcp:408kB local_pcp:124kB free_cma:0kB
>    lowmem_reserve[]: 0 0 17397 17397
[...]
>    [31617.991795] gkrellm invoked oom-killer: gfp_mask=0x25000c0(GFP_KERNEL_ACCOUNT), nodemask=0, order=0, oom_score_adj=0
>    [31617.991950] Node 0 active_anon:410912kB inactive_anon:188952kB active_file:1274928kB inactive_file:579668kB unevictable:28468kB isolated(anon):0kB isolated(file):0kB mapped:184664kB dirty:68kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 34744kB writeback_tmp:0kB unstable:0kB pages_scanned:5362697 all_unreclaimable? yes
>    [31617.991957] DMA free:4116kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:1568kB inactive_file:0kB unevictable:0kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclaimable:9848kB slab_unreclaimable:376kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
>    lowmem_reserve[]: 0 833 3008 3008
>    [31617.991970] Normal free:42300kB min:42416kB low:53020kB high:63624kB active_anon:1380kB inactive_anon:20244kB active_file:558700kB inactive_file:16kB unevictable:0kB writepending:16kB present:892920kB managed:854328kB mlocked:0kB slab_reclaimable:173456kB slab_unreclaimable:45024kB kernel_stack:3144kB pagetables:0kB bounce:0kB free_pcp:1392kB local_pcp:612kB free_cma:0kB

All of those are lowmem requests triggering the oom killer while there
is a lot of page cache sitting on the active Normal list. So it smells
like the same issue I was referring to and the mentioned patch should
fix the issue.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
