Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B5CFC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 21:50:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6B40218B0
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 21:50:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pDRQWSwd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6B40218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F8216B0003; Wed, 20 Mar 2019 17:50:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A6EE6B0006; Wed, 20 Mar 2019 17:50:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 695846B0007; Wed, 20 Mar 2019 17:50:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 12D416B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 17:50:39 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id n9so1591954wra.19
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:50:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QuzZpU3JLNjrV9G28aYFCK9t3tn4MzRm3nE3ai0SkRE=;
        b=tS4ivhVjduIAqn5WxdBlxCF9dpqRjJkuGH4bvkpitx0Q3d3oQQb6YlRDtVkV9Rhehy
         /SFpFeM9dUY7Er1OksU9gpw5mPaBmh0h5FYBkbF+gZIb1FK3Zt623X/cRLPGFzVaJLAj
         3yZglMpTfgz/sOZorJ/aJdQqq6yzFhloesYAWvlGWNVQSx1X0ibUib1rIWj5oAuNrEfR
         4p9RxYV/FddKXECohlsNGcHErqJFhfyksOvc1FZ4HVLFcBDaPmo86Xhw7LLr2efgEaMw
         tf+nPyuWz6ow2sXPfvLOtjRkyWrzYMmHNlK4HmoytMmcPaQiem4Z+ZYQGDv9atBRP2SZ
         FxPA==
X-Gm-Message-State: APjAAAWRGqRJiqLPPVc1PCEfLjYdc3Eui/XuxM2RAXBlesyeVbFDoPd7
	j/5HZB9gXEn/mDPwb5A/2BmflFs5/3/tOZJzx9sVb9XM9sp6rAm7maOEvWoQKvWQuSS5Ty4MmEJ
	xlRIGLvCith/c9f/zDv4sC4ZOndND+tjA0MIHC4tw1Au0Y3blOIN5+1RZf4HT2Ar1Uw==
X-Received: by 2002:a1c:4b03:: with SMTP id y3mr288541wma.75.1553118638547;
        Wed, 20 Mar 2019 14:50:38 -0700 (PDT)
X-Received: by 2002:a1c:4b03:: with SMTP id y3mr288503wma.75.1553118637466;
        Wed, 20 Mar 2019 14:50:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553118637; cv=none;
        d=google.com; s=arc-20160816;
        b=vaokp6TvqN8KDsYCfEwsB+7t5JqNuncb5FbMrCGTJ828rdvaDnXUVR4ofna+LFuCx8
         evFxxiFTp17CGGeYjN2F87BRbjr7flcGCty+GMonL07EQz12YEFZxu6oGyeqNEr9hE+K
         WO9FWpDBc0FhaM1dN9LhUrByA5UJUvRsn4iCbqPhwKcepivrVK6xm/IcfFoZ02KBHExR
         eJX4cks+gDr1dOhYZO5OzaxWICm4tMVVh/kQk1HrwMeru2o8lWe1Cns2HKKkdBI9aBCe
         xJujYQzelxRhrh/zK5Bb7KNZbW+5c0/tSdzOVPvS2Jy9yVRc8t0Gw9jP3dvjBEbwj8Pq
         YsaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QuzZpU3JLNjrV9G28aYFCK9t3tn4MzRm3nE3ai0SkRE=;
        b=i5P/LHw7dqxKp52YUDWvfA9tdQ7mB077M+sMte9/H16xVPj/XYx9mishX58fWj0Lvm
         Li7gdxmd18nJvsR6N5x5UUGk8mL1ze+M5PhOXW5k697X3FNvKf2ngaZve3+Cgm2kKnMN
         UM+KftaVLAqJHpW/K1RxYiZ/gWK2ocUHy35XnRDT6ePrRmq5VumAdN8EsZcMFuyonTQv
         ZMDVdpFH0tWa0+1sF/67m0IVmvfQGiWaiTzugz447A5gj3UfKgNlDj5+8/LpnEGbGyEK
         xfrDxwdhpj0izsWBDsWsdZes7uggdDCJgYRyB1uzt/yismo2bYdsDAfWbK6M5yFTOqqv
         YvIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pDRQWSwd;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a2sor2590843wrm.50.2019.03.20.14.50.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 14:50:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pDRQWSwd;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QuzZpU3JLNjrV9G28aYFCK9t3tn4MzRm3nE3ai0SkRE=;
        b=pDRQWSwdYu7PLk1ciUtfmWOKhFKJ31iOGsFfaMXiR/wG0h/ZV9ODplbEfrdZ3NGCxz
         eNN8+kkRv0Y6TvZjNH2h5sDGeObfnctxhX0q0ohJt+TSQbHWANMQhH73wNLYVdtKtekF
         h7hUvY4jZX73nNvF3rnjMsBHg6Z/u7HzYUEuY79svajtAonTaCK6CP6+NhWau/4YyQd2
         v5JLuiQ0gsX85TDMbctW3cCqfN1yUqbElCdJ5V2ocpnO3WdNBXt3AMf9zsWkjqNS1ELl
         tw3GYJ4CTetDUGE3DqBr6y4cv52wW6mXbJmnu2E8sEOvuwUpoidMkjTqLHCxBOSEjwzZ
         tZuA==
X-Google-Smtp-Source: APXvYqyFC7QsNmy8nMn6o1RgJ1n6+91m1OKGY9zvoohXvUDmb0nE4MPkSUishqRl3c4CeorOr+OBu6EBwVYZ+Sk50Ak=
X-Received: by 2002:a5d:4a43:: with SMTP id v3mr284719wrs.126.1553118636839;
 Wed, 20 Mar 2019 14:50:36 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
In-Reply-To: <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Thu, 21 Mar 2019 02:50:25 +0500
Message-ID: <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, mgorman@techsingularity.net, cai@lca.pw, 
	vbabka@suse.cz
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Mar 2019 at 01:59, Daniel Jordan <daniel.m.jordan@oracle.com> wrote:
>
> This is new code, from e332f741a8dd1 ("mm, compaction: be selective about what
> pageblocks to clear skip hints"), so I added some folks.
>
> Can you show
> $LINUX/scripts/faddr2line path/to/vmlinux __reset_isolation_pfn+0x244
> ?

$ /usr/src/kernels/`uname -r`/scripts/faddr2line
/lib/debug/lib/modules/`uname -r`/vmlinux __reset_isolation_pfn+0x244
__reset_isolation_pfn+0x244/0x2b0:
page_to_nid at include/linux/mm.h:1021
(inlined by) page_zone at include/linux/mm.h:1163
(inlined by) __reset_isolation_pfn at mm/compaction.c:250

It was not easy, but I completed just now kernel bisecting and see
that you right.
First bad commit is e332f741a8dd1

$ git bisect log
git bisect start
# good: [cd2a3bf02625ffad02a6b9f7df758ee36cf12769] Merge tag
'leds-for-5.1-rc1' of
git://git.kernel.org/pub/scm/linux/kernel/git/j.anaszewski/linux-leds
git bisect good cd2a3bf02625ffad02a6b9f7df758ee36cf12769
# bad: [610cd4eadec4f97acd25d3108b0e50d1362b3319] Merge branch
'x86-uv-for-linus' of
git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect bad 610cd4eadec4f97acd25d3108b0e50d1362b3319
# good: [203b6609e0ede49eb0b97008b1150c69e9d2ffd3] Merge branch
'perf-core-for-linus' of
git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 203b6609e0ede49eb0b97008b1150c69e9d2ffd3
# bad: [da2577fe63f865cd9dc785a42c29c0071f567a35] Merge tag
'sound-5.1-rc1' of
git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect bad da2577fe63f865cd9dc785a42c29c0071f567a35
# good: [fb686ad25be0343a9dab23acff674d0cb84bb516] Merge tag
'armsoc-defconfig' of
git://git.kernel.org/pub/scm/linux/kernel/git/soc/soc
git bisect good fb686ad25be0343a9dab23acff674d0cb84bb516
# good: [70395a96bd882d8dba669f99b5cec0008690accd] Merge tag
'asoc-v5.1-2' of
https://git.kernel.org/pub/scm/linux/kernel/git/broonie/sound into
for-next
git bisect good 70395a96bd882d8dba669f99b5cec0008690accd
# bad: [8dcd175bc3d50b78413c56d5b17d4bddd77412ef] Merge branch 'akpm'
(patches from Andrew)
git bisect bad 8dcd175bc3d50b78413c56d5b17d4bddd77412ef
# bad: [7f18825174203526a47c127c12a50f897ee0b511] powerpc/mm/iommu:
allow large IOMMU page size only for hugetlb backing
git bisect bad 7f18825174203526a47c127c12a50f897ee0b511
# good: [566e54e113eb2b669f9300db2c2df400cbb06646] mm, compaction:
remove last_migrated_pfn from compact_control
git bisect good 566e54e113eb2b669f9300db2c2df400cbb06646
# bad: [d9f7979c92f7b34469c1ca5d1f3add6681fd567c] mm: no need to check
return value of debugfs_create functions
git bisect bad d9f7979c92f7b34469c1ca5d1f3add6681fd567c
# good: [cb810ad294d3c3a454e51b12fbb483bbb7096b98] mm, compaction:
rework compact_should_abort as compact_check_resched
git bisect good cb810ad294d3c3a454e51b12fbb483bbb7096b98
# bad: [147e1a97c4a0bdd43f55a582a9416bb9092563a9] fs: kernfs: add poll
file operation
git bisect bad 147e1a97c4a0bdd43f55a582a9416bb9092563a9
# good: [dbe2d4e4f12e07c6a2215e3603a5f77056323081] mm, compaction:
round-robin the order while searching the free lists for a target
git bisect good dbe2d4e4f12e07c6a2215e3603a5f77056323081
# bad: [e332f741a8dd1ec9a6dc8aa997296ecbfe64323e] mm, compaction: be
selective about what pageblocks to clear skip hints
git bisect bad e332f741a8dd1ec9a6dc8aa997296ecbfe64323e
# good: [4fca9730c51d51f643f2a3f8f10ebd718349c80f] mm, compaction:
sample pageblocks for free pages
git bisect good 4fca9730c51d51f643f2a3f8f10ebd718349c80f
# first bad commit: [e332f741a8dd1ec9a6dc8aa997296ecbfe64323e] mm,
compaction: be selective about what pageblocks to clear skip hints

Also I see that two patches already proposed for fixing this issue.
[1] https://patchwork.kernel.org/patch/10862267/
[2] https://patchwork.kernel.org/patch/10862519/

If I understand correctly, it is enough to apply only the second patch [2].



--
Best Regards,
Mike Gavrilov.

