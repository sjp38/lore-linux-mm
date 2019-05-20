Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED914C072A4
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9540720449
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OT53xaXo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9540720449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 204106B0005; Sun, 19 May 2019 23:53:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18F966B0006; Sun, 19 May 2019 23:53:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0546E6B0007; Sun, 19 May 2019 23:53:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC3AB6B0005
	for <linux-mm@kvack.org>; Sun, 19 May 2019 23:53:06 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o8so8870667pgq.5
        for <linux-mm@kvack.org>; Sun, 19 May 2019 20:53:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=AOnrcLqkjHP19PScPNjQgwAfOGbBMDgtiALDPlzvFYQ=;
        b=TcKMefUL2GWO6kLFQXZ1G1rxpEhbdV32UqgJLwc+WW1dJE6h6xwMUTKEeEOOP9lv/e
         BEbQOvNtbBh8t9Do7nFmRWMuvrrxlji+OZ4J8F+dNXJQDxklx8adqkGDw/79qbJsDD7Z
         MrcQXDRqxrSo6VWfiu0Df8d8bW3mEUTNrqIihXD4nTeXDy0bN4oR0ElpnJi4UrUEB9/P
         ZCO5COMKl02LnHMbXfEfYjDDfvJwJmnzG3s8t4v15ePrWTVRcDWNeKpt8nleDKzVVzip
         qS+1L5I+IjT6+xtUVCBQokxql/gasSSJ2bLqBpsaWGgGPt/uEq+CgzmtCLTIbf66c4h6
         VOFA==
X-Gm-Message-State: APjAAAUvZvamjlVfj+5vS4/33ViGrZe2SCGQTTw+03d/jKIGpxmNfV7H
	oItP7tN4D9TIZaAUAn0aWxYtIA6qsXTnpOgKcusZ183u6VDWPgWvuIyuaof01E2oFPJazWMhZR3
	BXcn2IeGVDR/BD+sASAyxAU0UDQye/PFkN97zxEcB4N2d1GMeh/QSzAULS8M2yBo=
X-Received: by 2002:a63:6f0b:: with SMTP id k11mr72333494pgc.342.1558324386242;
        Sun, 19 May 2019 20:53:06 -0700 (PDT)
X-Received: by 2002:a63:6f0b:: with SMTP id k11mr72333419pgc.342.1558324385152;
        Sun, 19 May 2019 20:53:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558324385; cv=none;
        d=google.com; s=arc-20160816;
        b=QLiRI4Mk97OUkSKDyceL5muxmAdyXz4Hu16SyLeo1uJ2cv8TEQ/hv1VQcrYsDjQx0p
         18vTFragzZ6GbIih5C5N6isaBrTAJQWJXqLwhnGdbfqoegyVYwitg1okOxTcWsu4zWNe
         pnfrLTshgjOqxrFDJcjcrDT3ZRi1lvQZuu3W3u3vxSHZvG4Li5YMd3zUZLGn5u2IGn7E
         h/vCVt0McSQW2mHg9auCe9eDCgH2ci4+BYlV7jNWbDT2ALBr1OL/zbtPfoXfRsz/EK6Y
         l7rgISEyBJnnwFZmzpGS/4i3Mq3E1Ewoi4tVpn9T1EeAiJNMqqJsx7adyrbMnozCF2RE
         gVPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:dkim-signature;
        bh=AOnrcLqkjHP19PScPNjQgwAfOGbBMDgtiALDPlzvFYQ=;
        b=yCfDnMy+DhB3W2aKC/0YQ8I0qEsTUH/NwdLCNYqDJuExSNWnDyq3np5+gInDZAx3/+
         VzoXsxm7bWkN6J+9hASx7dKTm+BG2wg+dnw7HLVu+4Gn40Qx+1zAQOZd1+8bEAnoCAI8
         KjDvOegwVIL9mOrmvl0suJDmY9Mzp0299T50vLrbF74bxvFwGTwRp3sU0lW4otMIr5EJ
         31T1Khgxg6GOtFfFC7ugyKm8gRCQWm0uQJ8rpqcAbRnoquBecvm34XmGZ6QS+zApP+X+
         6+T4YMtb9aqp2kPQh2mUI9vqjL5iYT03Xeo0GPpJKR3vJokmkyJKet2+nRLmTCB9jzGe
         qpOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OT53xaXo;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b11sor18141572plz.51.2019.05.19.20.53.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 May 2019 20:53:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OT53xaXo;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=AOnrcLqkjHP19PScPNjQgwAfOGbBMDgtiALDPlzvFYQ=;
        b=OT53xaXom6Yfanw1bzJpi6sfGVTcl6JNG5vMptFQD1ESPwMhG7mJgmSLU3e9/eQOsS
         APAsZVbnbdWSbUEqmOdYqVC1F1eAzZJilo04vKFYQ4AWFo6n0UlW/sMylxJ/R3m1wRSa
         /zq6g3Q5rPRiL2j2F8qthGTCPZ77hjMv7VS0VcI1YWSwm9LRenYW+E6ranNNsw4TNxXZ
         kVHipVWbMC3QIY8oOgBZQMYUxEGicgu85g3DSfmpGvuqXdkeGiTwCqsoMke3onEFyJ43
         WrQGIaItg2cufJjHfmRi9f3Lburb7ypAqWQppRirrVyzTKr8Qg86++w+SwvvLteMxZeI
         wpqA==
X-Google-Smtp-Source: APXvYqxKbsGHGzREndrVBtZi8nQnp1OBpv+F4c+HfxZ4pcZ1gIGEK5nPt9CuMgkOqHy0k9dA1NJE2w==
X-Received: by 2002:a17:902:b695:: with SMTP id c21mr73965937pls.160.1558324384465;
        Sun, 19 May 2019 20:53:04 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x66sm3312779pfx.139.2019.05.19.20.52.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 20:53:02 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [RFC 0/7] introduce memory hinting API for external process
Date: Mon, 20 May 2019 12:52:47 +0900
Message-Id: <20190520035254.57579-1-minchan@kernel.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

- Background

The Android terminology used for forking a new process and starting an app
from scratch is a cold start, while resuming an existing app is a hot start.
While we continually try to improve the performance of cold starts, hot
starts will always be significantly less power hungry as well as faster so
we are trying to make hot start more likely than cold start.

To increase hot start, Android userspace manages the order that apps should
be killed in a process called ActivityManagerService. ActivityManagerService
tracks every Android app or service that the user could be interacting with
at any time and translates that into a ranked list for lmkd(low memory
killer daemon). They are likely to be killed by lmkd if the system has to
reclaim memory. In that sense they are similar to entries in any other cache.
Those apps are kept alive for opportunistic performance improvements but
those performance improvements will vary based on the memory requirements of
individual workloads.

- Problem

Naturally, cached apps were dominant consumers of memory on the system.
However, they were not significant consumers of swap even though they are
good candidate for swap. Under investigation, swapping out only begins
once the low zone watermark is hit and kswapd wakes up, but the overall
allocation rate in the system might trip lmkd thresholds and cause a cached
process to be killed(we measured performance swapping out vs. zapping the
memory by killing a process. Unsurprisingly, zapping is 10x times faster
even though we use zram which is much faster than real storage) so kill
from lmkd will often satisfy the high zone watermark, resulting in very
few pages actually being moved to swap.

- Approach

The approach we chose was to use a new interface to allow userspace to
proactively reclaim entire processes by leveraging platform information.
This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
that are known to be cold from userspace and to avoid races with lmkd
by reclaiming apps as soon as they entered the cached state. Additionally,
it could provide many chances for platform to use much information to
optimize memory efficiency.

IMHO we should spell it out that this patchset complements MADV_WONTNEED
and MADV_FREE by adding non-destructive ways to gain some free memory
space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
kernel that memory region is not currently needed and should be reclaimed
immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
kernel that memory region is not currently needed and should be reclaimed
when memory pressure rises.

To achieve the goal, the patchset introduce two new options for madvise.
One is MADV_COOL which will deactive activated pages and the other is
MADV_COLD which will reclaim private pages instantly. These new options
complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
gain some free memory space. MADV_COLD is similar to MADV_DONTNEED in a way
that it hints the kernel that memory region is not currently needed and
should be reclaimed immediately; MADV_COOL is similar to MADV_FREE in a way
that it hints the kernel that memory region is not currently needed and
should be reclaimed when memory pressure rises.

This approach is similar in spirit to madvise(MADV_WONTNEED), but the
information required to make the reclaim decision is not known to the app.
Instead, it is known to a centralized userspace daemon, and that daemon
must be able to initiate reclaim on its own without any app involvement.
To solve the concern, this patch introduces new syscall -

	struct pr_madvise_param {
		int size;
		const struct iovec *vec;
	}

	int process_madvise(int pidfd, ssize_t nr_elem, int *behavior,
				struct pr_madvise_param *restuls,
				struct pr_madvise_param *ranges,
				unsigned long flags);

The syscall get pidfd to give hints to external process and provides
pair of result/ranges vector arguments so that it could give several
hints to each address range all at once.

I guess others have different ideas about the naming of syscall and options
so feel free to suggest better naming.

- Experiment

We did bunch of testing with several hundreds of real users, not artificial
benchmark on android. We saw about 17% cold start decreasement without any
significant battery/app startup latency issues. And with artificial benchmark
which launches and switching apps, we saw average 7% app launching improvement,
18% less lmkd kill and good stat from vmstat.

A is vanilla and B is process_madvise.


                                       A          B      delta   ratio(%)
               allocstall_dma          0          0          0       0.00
           allocstall_movable       1464        457      -1007     -69.00
            allocstall_normal     263210     190763     -72447     -28.00
             allocstall_total     264674     191220     -73454     -28.00
          compact_daemon_wake      26912      25294      -1618      -7.00
                 compact_fail      17885      14151      -3734     -21.00
         compact_free_scanned 4204766409 3835994922 -368771487      -9.00
             compact_isolated    3446484    2967618    -478866     -14.00
      compact_migrate_scanned 1621336411 1324695710 -296640701     -19.00
                compact_stall      19387      15343      -4044     -21.00
              compact_success       1502       1192       -310     -21.00
kswapd_high_wmark_hit_quickly        234        184        -50     -22.00
            kswapd_inodesteal     221635     233093      11458       5.00
 kswapd_low_wmark_hit_quickly      66065      54009     -12056     -19.00
                   nr_dirtied     259934     296476      36542      14.00
  nr_vmscan_immediate_reclaim       2587       2356       -231      -9.00
              nr_vmscan_write    1274232    2661733    1387501     108.00
                   nr_written    1514060    2937560    1423500      94.00
                   pageoutrun      67561      55133     -12428     -19.00
                   pgactivate    2335060    1984882    -350178     -15.00
                  pgalloc_dma   13743011   14096463     353452       2.00
              pgalloc_movable          0          0          0       0.00
               pgalloc_normal   18742440   16802065   -1940375     -11.00
                pgalloc_total   32485451   30898528   -1586923      -5.00
                 pgdeactivate    4262210    2930670   -1331540     -32.00
                      pgfault   30812334   31085065     272731       0.00
                       pgfree   33553970   31765164   -1788806      -6.00
                 pginodesteal      33411      15084     -18327     -55.00
                  pglazyfreed          0          0          0       0.00
                   pgmajfault     551312    1508299     956987     173.00
               pgmigrate_fail      43927      29330     -14597     -34.00
            pgmigrate_success    1399851    1203922    -195929     -14.00
                       pgpgin   24141776   19032156   -5109620     -22.00
                      pgpgout     959344    1103316     143972      15.00
                 pgpgoutclean    4639732    3765868    -873864     -19.00
                     pgrefill    4884560    3006938   -1877622     -39.00
                    pgrotated      37828      25897     -11931     -32.00
                pgscan_direct    1456037     957567    -498470     -35.00
       pgscan_direct_throttle          0          0          0       0.00
                pgscan_kswapd    6667767    5047360   -1620407     -25.00
                 pgscan_total    8123804    6004927   -2118877     -27.00
                   pgskip_dma          0          0          0       0.00
               pgskip_movable          0          0          0       0.00
                pgskip_normal      14907      25382      10475      70.00
                 pgskip_total      14907      25382      10475      70.00
               pgsteal_direct    1118986     690215    -428771     -39.00
               pgsteal_kswapd    4750223    3657107   -1093116     -24.00
                pgsteal_total    5869209    4347322   -1521887     -26.00
                       pswpin     417613    1392647     975034     233.00
                      pswpout    1274224    2661731    1387507     108.00
                slabs_scanned   13686905   10807200   -2879705     -22.00
          workingset_activate     668966     569444     -99522     -15.00
       workingset_nodereclaim      38957      32621      -6336     -17.00
           workingset_refault    2816795    2179782    -637013     -23.00
           workingset_restore     294320     168601    -125719     -43.00

pgmajfault is increased by 173% because swapin is increased by 200% by
process_madvise hint. However, swap read based on zram is much cheaper
than file IO in performance point of view and app hot start by swapin is
also cheaper than cold start from the beginning of app which needs many IO
from storage and initialization steps.

This patchset is against on next-20190517.

Minchan Kim (7):
  mm: introduce MADV_COOL
  mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
  mm: introduce MADV_COLD
  mm: factor out madvise's core functionality
  mm: introduce external memory hinting API
  mm: extend process_madvise syscall to support vector arrary
  mm: madvise support MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER

 arch/x86/entry/syscalls/syscall_32.tbl |   1 +
 arch/x86/entry/syscalls/syscall_64.tbl |   1 +
 include/linux/page-flags.h             |   1 +
 include/linux/page_idle.h              |  15 +
 include/linux/proc_fs.h                |   1 +
 include/linux/swap.h                   |   2 +
 include/linux/syscalls.h               |   2 +
 include/uapi/asm-generic/mman-common.h |  12 +
 include/uapi/asm-generic/unistd.h      |   2 +
 kernel/signal.c                        |   2 +-
 kernel/sys_ni.c                        |   1 +
 mm/madvise.c                           | 600 +++++++++++++++++++++----
 mm/swap.c                              |  43 ++
 mm/vmscan.c                            |  80 +++-
 14 files changed, 680 insertions(+), 83 deletions(-)

-- 
2.21.0.1020.gf2820cf01a-goog

