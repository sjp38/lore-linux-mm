Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 109A2C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:56:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC18D21743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:56:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ryyO3SCT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC18D21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59A3E6B0005; Mon, 20 May 2019 22:56:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5494C6B0006; Mon, 20 May 2019 22:56:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 439966B0007; Mon, 20 May 2019 22:56:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 076306B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 22:56:53 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s8so11145786pgk.0
        for <linux-mm@kvack.org>; Mon, 20 May 2019 19:56:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=6Afh3+z0qmcfkeuctfv1v2GNWM1yrCE10w4LdsfArpU=;
        b=gPR+G2wAQWtxUHb/6oqlnQrgxcozz9D/GnRplxNpr2mkEm9OeOXgW6zQ5QE/V45U1F
         ARbffKd95NMasI+mRuShA2vdAoXKNdzA0fCixnYc7cfBO+CQ/S1hAGStqWhea1eURlq0
         KCJL2l6TTaPxC/IotWBF0ocy08UAbhCpDlAWC8LPPEgUxl1SAfvYKvZhMc9mU7tzZvkM
         gusd69eMwfZQqYZ2v9oFQEtp5SY2AHBOnUUkKYcOGlsL/s7sZ6Qy1RRr5UpEpWyI4/4/
         1Qr3bklzBDeiLxbOZTQD951J9uKtEFKvFC3kx114iDPSnbEBQbDPAF9/sN/1g4O97juh
         GY9g==
X-Gm-Message-State: APjAAAU0a2iLNkVz22tLW59TCKBGZzm5BWdQ7opF54AKHHpXQ3g4Idle
	n2UlPsDyvdpW6OGydy9G4A0fpBvJrY7qWxo1tM91w7dWtRoQ+99jXFU+LQ76tec147kp8qsl9MU
	81cek9R0tfnGgsjd6fk0XvWYzapgdFol2iul544FKQ8BycJ0rcJwGt49hXuxXiq8=
X-Received: by 2002:a63:2118:: with SMTP id h24mr80147287pgh.320.1558407412642;
        Mon, 20 May 2019 19:56:52 -0700 (PDT)
X-Received: by 2002:a63:2118:: with SMTP id h24mr80147208pgh.320.1558407411471;
        Mon, 20 May 2019 19:56:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558407411; cv=none;
        d=google.com; s=arc-20160816;
        b=q9RqoNzmH08BD8/ks2z0QoV5IZXoG0xoyV2qmfrpqxclSwB77zLb0hWuCA/bKeuAgU
         5j5fAswdz8h8tkO4VWJx0fr8jSmb+zjjL5EEdDutj7BGn93jf318ktoOzJqNJLShtHNz
         jCIAWxr5EN0XzuIeG6VhKnmUwbUPbQs/KF0wVTq2ECd/kogsQI2/PT8drEe+VLLd1Ivq
         rEZMvlCAfmL0ZUfdnKK7H+nboNy8ztX7GTFxThSYjORdSQF5aN0AlpuE8VcrZEAaFGXt
         VDCtr84XGxaV07P/rrVMaMHDYXPlNDuTwiZ0ZnaEyKPiHP1BEzR/fMwux90tMEusv4O8
         epeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=6Afh3+z0qmcfkeuctfv1v2GNWM1yrCE10w4LdsfArpU=;
        b=cqMlJEPYVHK4hCc0/jy9YcdRiMyeTVGa/zuYPhKruVtyLW3u66VMjyLSxoOWdnBQFO
         f9uML1wuv6WNNtn8EUXq7rO+sZc3PEdspF3lk4TVnAljq3/ma/Sn8WFy0+E1xxIC+l7E
         TcSuPhWy9RRTpRzcVBdYIfhhAUIHq4+qyAvKjTgpwfrpyrPh2dFM78pX6eISc/LHRakx
         W3JEqKreLQaAmeKnnukwRJckpWb7RlJJThGqaYxLuadzmbO68Tf8Q6Gb28D/huyWsSlO
         V5NvbdaSpGpJQe1ilFHTxn//+EnfKMpafFRZP/tZSinEFAWf09hI/2y4SRkd9aREW71l
         8nqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ryyO3SCT;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m11sor5570624plt.30.2019.05.20.19.56.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 19:56:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ryyO3SCT;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=6Afh3+z0qmcfkeuctfv1v2GNWM1yrCE10w4LdsfArpU=;
        b=ryyO3SCTjZ1P51XagZ2b4X1f0ekMu6xS7/hBacBJ7oBTZ97AyhVLG4SmL5puT6PS+A
         CrYxMzYM2SNECAV2y+fmHEl1TZuFsoB22zvcVzRnBFI4ABiutcfbZBoI7kAWg4kuY/zk
         Z8pEcn5wMNtgVDznjp5X6ZvaxBkGS2CKJqHIg47LkrGSGjD7Ca9P0UaC4vTrSaG9vRvU
         qkAOOOYgPVtYuarpWeJ60CMcjz6HslEpXu4CHYhs2+kyja5khRcujRdWgKDhu3IRC5gR
         nTv0kH849FahWfDsHOJ2PUBKVN1qYrztf48t6DLkr5Mv0Tzxxu6h6wX9sF4LBIzENsL7
         fU7Q==
X-Google-Smtp-Source: APXvYqxOqqKzfHjrBuGGsb9HgKt4DNkrhaD+HUgE2b3fqnEQJgptqdR6bTofWAs99kevyfVePs7KCA==
X-Received: by 2002:a17:902:7082:: with SMTP id z2mr56570051plk.176.1558407410941;
        Mon, 20 May 2019 19:56:50 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id q5sm23222349pfb.51.2019.05.20.19.56.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 20 May 2019 19:56:49 -0700 (PDT)
Date: Tue, 21 May 2019 11:56:44 +0900
From: Minchan Kim <minchan@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521025644.GI10039@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520144200.cpiqhxxbxyovmk7h@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190520144200.cpiqhxxbxyovmk7h@butterfly.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 04:42:00PM +0200, Oleksandr Natalenko wrote:
> Hi.
> 
> On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> > - Background
> > 
> > The Android terminology used for forking a new process and starting an app
> > from scratch is a cold start, while resuming an existing app is a hot start.
> > While we continually try to improve the performance of cold starts, hot
> > starts will always be significantly less power hungry as well as faster so
> > we are trying to make hot start more likely than cold start.
> > 
> > To increase hot start, Android userspace manages the order that apps should
> > be killed in a process called ActivityManagerService. ActivityManagerService
> > tracks every Android app or service that the user could be interacting with
> > at any time and translates that into a ranked list for lmkd(low memory
> > killer daemon). They are likely to be killed by lmkd if the system has to
> > reclaim memory. In that sense they are similar to entries in any other cache.
> > Those apps are kept alive for opportunistic performance improvements but
> > those performance improvements will vary based on the memory requirements of
> > individual workloads.
> > 
> > - Problem
> > 
> > Naturally, cached apps were dominant consumers of memory on the system.
> > However, they were not significant consumers of swap even though they are
> > good candidate for swap. Under investigation, swapping out only begins
> > once the low zone watermark is hit and kswapd wakes up, but the overall
> > allocation rate in the system might trip lmkd thresholds and cause a cached
> > process to be killed(we measured performance swapping out vs. zapping the
> > memory by killing a process. Unsurprisingly, zapping is 10x times faster
> > even though we use zram which is much faster than real storage) so kill
> > from lmkd will often satisfy the high zone watermark, resulting in very
> > few pages actually being moved to swap.
> > 
> > - Approach
> > 
> > The approach we chose was to use a new interface to allow userspace to
> > proactively reclaim entire processes by leveraging platform information.
> > This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> > that are known to be cold from userspace and to avoid races with lmkd
> > by reclaiming apps as soon as they entered the cached state. Additionally,
> > it could provide many chances for platform to use much information to
> > optimize memory efficiency.
> > 
> > IMHO we should spell it out that this patchset complements MADV_WONTNEED
> > and MADV_FREE by adding non-destructive ways to gain some free memory
> > space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> > kernel that memory region is not currently needed and should be reclaimed
> > immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> > kernel that memory region is not currently needed and should be reclaimed
> > when memory pressure rises.
> > 
> > To achieve the goal, the patchset introduce two new options for madvise.
> > One is MADV_COOL which will deactive activated pages and the other is
> > MADV_COLD which will reclaim private pages instantly. These new options
> > complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
> > gain some free memory space. MADV_COLD is similar to MADV_DONTNEED in a way
> > that it hints the kernel that memory region is not currently needed and
> > should be reclaimed immediately; MADV_COOL is similar to MADV_FREE in a way
> > that it hints the kernel that memory region is not currently needed and
> > should be reclaimed when memory pressure rises.
> > 
> > This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> > information required to make the reclaim decision is not known to the app.
> > Instead, it is known to a centralized userspace daemon, and that daemon
> > must be able to initiate reclaim on its own without any app involvement.
> > To solve the concern, this patch introduces new syscall -
> > 
> > 	struct pr_madvise_param {
> > 		int size;
> > 		const struct iovec *vec;
> > 	}
> > 
> > 	int process_madvise(int pidfd, ssize_t nr_elem, int *behavior,
> > 				struct pr_madvise_param *restuls,
> > 				struct pr_madvise_param *ranges,
> > 				unsigned long flags);
> > 
> > The syscall get pidfd to give hints to external process and provides
> > pair of result/ranges vector arguments so that it could give several
> > hints to each address range all at once.
> > 
> > I guess others have different ideas about the naming of syscall and options
> > so feel free to suggest better naming.
> > 
> > - Experiment
> > 
> > We did bunch of testing with several hundreds of real users, not artificial
> > benchmark on android. We saw about 17% cold start decreasement without any
> > significant battery/app startup latency issues. And with artificial benchmark
> > which launches and switching apps, we saw average 7% app launching improvement,
> > 18% less lmkd kill and good stat from vmstat.
> > 
> > A is vanilla and B is process_madvise.
> > 
> > 
> >                                        A          B      delta   ratio(%)
> >                allocstall_dma          0          0          0       0.00
> >            allocstall_movable       1464        457      -1007     -69.00
> >             allocstall_normal     263210     190763     -72447     -28.00
> >              allocstall_total     264674     191220     -73454     -28.00
> >           compact_daemon_wake      26912      25294      -1618      -7.00
> >                  compact_fail      17885      14151      -3734     -21.00
> >          compact_free_scanned 4204766409 3835994922 -368771487      -9.00
> >              compact_isolated    3446484    2967618    -478866     -14.00
> >       compact_migrate_scanned 1621336411 1324695710 -296640701     -19.00
> >                 compact_stall      19387      15343      -4044     -21.00
> >               compact_success       1502       1192       -310     -21.00
> > kswapd_high_wmark_hit_quickly        234        184        -50     -22.00
> >             kswapd_inodesteal     221635     233093      11458       5.00
> >  kswapd_low_wmark_hit_quickly      66065      54009     -12056     -19.00
> >                    nr_dirtied     259934     296476      36542      14.00
> >   nr_vmscan_immediate_reclaim       2587       2356       -231      -9.00
> >               nr_vmscan_write    1274232    2661733    1387501     108.00
> >                    nr_written    1514060    2937560    1423500      94.00
> >                    pageoutrun      67561      55133     -12428     -19.00
> >                    pgactivate    2335060    1984882    -350178     -15.00
> >                   pgalloc_dma   13743011   14096463     353452       2.00
> >               pgalloc_movable          0          0          0       0.00
> >                pgalloc_normal   18742440   16802065   -1940375     -11.00
> >                 pgalloc_total   32485451   30898528   -1586923      -5.00
> >                  pgdeactivate    4262210    2930670   -1331540     -32.00
> >                       pgfault   30812334   31085065     272731       0.00
> >                        pgfree   33553970   31765164   -1788806      -6.00
> >                  pginodesteal      33411      15084     -18327     -55.00
> >                   pglazyfreed          0          0          0       0.00
> >                    pgmajfault     551312    1508299     956987     173.00
> >                pgmigrate_fail      43927      29330     -14597     -34.00
> >             pgmigrate_success    1399851    1203922    -195929     -14.00
> >                        pgpgin   24141776   19032156   -5109620     -22.00
> >                       pgpgout     959344    1103316     143972      15.00
> >                  pgpgoutclean    4639732    3765868    -873864     -19.00
> >                      pgrefill    4884560    3006938   -1877622     -39.00
> >                     pgrotated      37828      25897     -11931     -32.00
> >                 pgscan_direct    1456037     957567    -498470     -35.00
> >        pgscan_direct_throttle          0          0          0       0.00
> >                 pgscan_kswapd    6667767    5047360   -1620407     -25.00
> >                  pgscan_total    8123804    6004927   -2118877     -27.00
> >                    pgskip_dma          0          0          0       0.00
> >                pgskip_movable          0          0          0       0.00
> >                 pgskip_normal      14907      25382      10475      70.00
> >                  pgskip_total      14907      25382      10475      70.00
> >                pgsteal_direct    1118986     690215    -428771     -39.00
> >                pgsteal_kswapd    4750223    3657107   -1093116     -24.00
> >                 pgsteal_total    5869209    4347322   -1521887     -26.00
> >                        pswpin     417613    1392647     975034     233.00
> >                       pswpout    1274224    2661731    1387507     108.00
> >                 slabs_scanned   13686905   10807200   -2879705     -22.00
> >           workingset_activate     668966     569444     -99522     -15.00
> >        workingset_nodereclaim      38957      32621      -6336     -17.00
> >            workingset_refault    2816795    2179782    -637013     -23.00
> >            workingset_restore     294320     168601    -125719     -43.00
> > 
> > pgmajfault is increased by 173% because swapin is increased by 200% by
> > process_madvise hint. However, swap read based on zram is much cheaper
> > than file IO in performance point of view and app hot start by swapin is
> > also cheaper than cold start from the beginning of app which needs many IO
> > from storage and initialization steps.
> > 
> > This patchset is against on next-20190517.
> > 
> > Minchan Kim (7):
> >   mm: introduce MADV_COOL
> >   mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
> >   mm: introduce MADV_COLD
> >   mm: factor out madvise's core functionality
> >   mm: introduce external memory hinting API
> >   mm: extend process_madvise syscall to support vector arrary
> >   mm: madvise support MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER
> > 
> >  arch/x86/entry/syscalls/syscall_32.tbl |   1 +
> >  arch/x86/entry/syscalls/syscall_64.tbl |   1 +
> >  include/linux/page-flags.h             |   1 +
> >  include/linux/page_idle.h              |  15 +
> >  include/linux/proc_fs.h                |   1 +
> >  include/linux/swap.h                   |   2 +
> >  include/linux/syscalls.h               |   2 +
> >  include/uapi/asm-generic/mman-common.h |  12 +
> >  include/uapi/asm-generic/unistd.h      |   2 +
> >  kernel/signal.c                        |   2 +-
> >  kernel/sys_ni.c                        |   1 +
> >  mm/madvise.c                           | 600 +++++++++++++++++++++----
> >  mm/swap.c                              |  43 ++
> >  mm/vmscan.c                            |  80 +++-
> >  14 files changed, 680 insertions(+), 83 deletions(-)
> > 
> > -- 
> > 2.21.0.1020.gf2820cf01a-goog
> > 
> 
> Please Cc me for the next iteration since I was working on the very same
> thing recently [1].
> 
> Thank you.
> 
> [1] https://gitlab.com/post-factum/pf-kernel/commits/remote-madvise-v3

Sure, I'm happy to see others have similar requirement.

