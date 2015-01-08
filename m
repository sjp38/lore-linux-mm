Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6FCDF6B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 10:08:54 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id x12so3108931wgg.11
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 07:08:54 -0800 (PST)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id k9si13883475wiw.32.2015.01.08.07.08.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 07:08:53 -0800 (PST)
Received: by mail-wi0-f173.google.com with SMTP id r20so3866866wiv.0
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 07:08:53 -0800 (PST)
Date: Thu, 8 Jan 2015 16:08:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Linux 3.19-rc3
Message-ID: <20150108150850.GD5658@dhcp22.suse.cz>
References: <CA+55aFwsxoyLb9OWMSCL3doe_cz_EQtKsEFCyPUYn_T87pbz0A@mail.gmail.com>
 <54AE7D53.2020305@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54AE7D53.2020305@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Langsdorf <mlangsdo@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>

[CCing linux-mm and CMA people]
[Full message here:
http://article.gmane.org/gmane.linux.ports.arm.kernel/383669]

On Thu 08-01-15 06:51:31, Mark Langsdorf wrote:
[...]
> [ 1053.968815] active_anon:207417 inactive_anon:25722 isolated_anon:0
> [ 1053.968815]  active_file:1300 inactive_file:21234 isolated_file:0
> [ 1053.968815]  unevictable:0 dirty:0 writeback:0 unstable:0
> [ 1053.968815]  free:1014 slab_reclaimable:1047 slab_unreclaimable:1758
> [ 1053.968815]  mapped:733 shmem:58 pagetables:267 bounce:0
> [ 1053.968815]  free_cma:1

Still a lot of pages (~80M) on the file LRU list which should be reclaimable
because they are not dirty apparently.
Anon pages can be reclaimed as well because the swap is basically
unused.

[...]
> [ 1054.095277] DMA: 109*64kB (UR) 53*128kB (R) 8*256kB (R) 0*512kB 0*1024kB
> 0*2048kB 1*4096kB (R) 0*8192kB 0*16384kB 1*32768kB (R) 0*65536kB = 52672kB
> [ 1054.108621] Normal: 191*64kB (MR) 0*128kB 0*256kB 0*512kB 0*1024kB
> 0*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB 0*65536kB = 12224kB
[...]
> [ 1054.142545] Free swap  = 6598400kB
> [ 1054.145928] Total swap = 8388544kB
> [ 1054.149317] 262112 pages RAM
> [ 1054.152180] 0 pages HighMem/MovableOnly
> [ 1054.155995] 18446744073709544361 pages reserved
> [ 1054.160505] 8192 pages cma reserved

Besides underflow in the reserved pages accounting mentioned in other
email the free lists look strange as well. All free blocks with some memory
are marked as reserved. I would suspect something CMA related.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
