Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 744BCC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:20:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C2732192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:20:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernelci-org.20150623.gappssmtp.com header.i=@kernelci-org.20150623.gappssmtp.com header.b="MwPNlyGd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C2732192C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernelci.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA1218E0002; Fri, 15 Feb 2019 13:20:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4F578E0001; Fri, 15 Feb 2019 13:20:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9175C8E0002; Fri, 15 Feb 2019 13:20:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1848E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:20:13 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id t7so2400179wrw.8
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:20:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:date:mime-version
         :content-transfer-encoding:subject:to:from:cc;
        bh=VIqqoHDjFGd1btfGJg8kDnzStzfnLDSQIK8Q9CoC5E0=;
        b=fZ+sDdHM4OX2mf3PDUfuJSJ+x6uBUActOLjTfqL1SHASW6UgKguEby9Wf0QrtnV2Qn
         5nJ02uhPfJicDRPZlXQ1Mi3R6d3Fvfpa1nn1ZGhW11TFszw+wDvm6EYCoiARgfac7iNk
         JiBOM/gE0y2izeDxEgP7zORp0mASJy0MIjU1ex4ZrU2zaPj/D/fC8VUDNfoGzYFEk/PI
         5nV8j3kH5XgRVxMPWxPo/UhnvPIpxHZGdqEqmwhKVXym+apyls5et4XNZuZU1JCvQIvJ
         c7dsQPXMvq3MzXFOIeqQy6PzPzE60ADyQ5jT/Pfzz08v+LWP3xP3N2f3weFf/A548XqG
         bDgg==
X-Gm-Message-State: AHQUAubE++4P5Ta13sMG+g/4Iaj9gvPQXZouzv9K/fNKSfEx5ktPGVpr
	fpasQDLbUfTJurs6iCDW88lIGQpR1kSP2NS1piF8+pXVTqZ4PNzy8iwQq3z5418MgmmqunCr2u7
	erfIOUTDsK7oEHa7YCLOLmPaiX9bMau9c9n/7RH1y+kc14H716TD28rCZboQWS5j7WEJB9fOU8I
	pZePJX5bJBjmsy93M42O7cN7IU1RQcVy8CGqzdCMRNgJWeGV478ddR4yLmELL/AYGVKQh6MJbBc
	PXMn1lpqAdZNKNhA1bqJh91izIYtE5WRSypKkyuU8rOa69DsA/WNkgIlVYdmxxDNqQsD7qo3Ax6
	Nuo6fl+NuznJ9pS/UhNsbNogXiJHkxv4QInHlAqLPcsA6IbU54LncUjxINlDYoLvon+YSUkmXVU
	z
X-Received: by 2002:adf:e647:: with SMTP id b7mr7738235wrn.260.1550254812719;
        Fri, 15 Feb 2019 10:20:12 -0800 (PST)
X-Received: by 2002:adf:e647:: with SMTP id b7mr7738188wrn.260.1550254811530;
        Fri, 15 Feb 2019 10:20:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550254811; cv=none;
        d=google.com; s=arc-20160816;
        b=SdfDj1PVOPmNWLeH317oRom+tthIIKdWi39Al6oPXW5DyaYREzpztR+UoYmrVRZBA8
         rbh9H8BbuTW81ZZBO6dowA8MsNxMan0b/jfjUM97v0PjK0cJGVnq6Onn3kldRw01KdcY
         t/lzdZgpF4wKKeuIBVUrfznLjAwXxXHueODgESCsidAZDy3ziYEUkcwCjfbhKG0Tj69t
         9apZx3f1wfnBMD+5T5bsX4Zt6+gfA8Zf/G/6JJsOQP+JQyaZxUYeF1EZy1HF5O8caQAK
         c51ZoRGDhPZeAUpXv1mrf/tGsy3tPM0+TXUTV8+YbrcbuoeDESTZLbvqO6e5ETZHojll
         ChGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:from:to:subject:content-transfer-encoding:mime-version:date
         :message-id:dkim-signature;
        bh=VIqqoHDjFGd1btfGJg8kDnzStzfnLDSQIK8Q9CoC5E0=;
        b=lTs/RIH371IOBMGxZak0fW18IACpQ6MyS/Z6w9a6Aehpqy5s5v+1GE55yucFmDxkna
         cyRNKZIuyU1LWG2Pycu+cexd98I3F3zHjxITLwA3vpRXJQCV8lKG3ht8VR8W6G/DvgSU
         KiyF5uS/ePPU6Obbg0ugxoW9lpG2c0u/vlvVHJMfuFPNb8iqbsi4iNCERmfzz547uAmI
         9tLZZx1CAsBU3FT3KNzcneKQlZ6lwXciFZZo5ivnATlu/TrvWoGmuY0bJbiJDLXnbsDZ
         Q7eu1VXNfprMMinEFyG5wGXRnpMjwQ94OiIIYE8KFXkUu6weS/gSIAaxcTrX48lYNR/l
         MUcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernelci-org.20150623.gappssmtp.com header.s=20150623 header.b=MwPNlyGd;
       spf=pass (google.com: domain of bot@kernelci.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=bot@kernelci.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4sor4096740wml.7.2019.02.15.10.20.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 10:20:11 -0800 (PST)
Received-SPF: pass (google.com: domain of bot@kernelci.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernelci-org.20150623.gappssmtp.com header.s=20150623 header.b=MwPNlyGd;
       spf=pass (google.com: domain of bot@kernelci.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=bot@kernelci.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernelci-org.20150623.gappssmtp.com; s=20150623;
        h=message-id:date:mime-version:content-transfer-encoding:subject:to
         :from:cc;
        bh=VIqqoHDjFGd1btfGJg8kDnzStzfnLDSQIK8Q9CoC5E0=;
        b=MwPNlyGd7E6HfStuAfztk+RjqGGa/8NwvfNYFVx9pFyopoN2SprivYg3ohg5B1b+bG
         5B4tCTNl8VnhrNgaWmlmnc1C8Z+qwfb1kQYijHWpwTNkh1wiBUVkV+qhCTzs43O90vKu
         JQlOm/faNLgOxKICdm3o0BK/r0DPADq22NYfoDpxBq90CcVaP4YNBbF8OSBaisljA75l
         Pp1M9ldEXgGrjDdlnWoQBvotKI2/FziPfWVCvXnLb5h2VDN8TtPltOrMhPfhTHH6P+DD
         Ffpi5aOaBXbMnquKSE/PMkJPyHKBSd+WzSx2XUdnK4CroK8mhefup81zmcjLDoGz9WCP
         Zn5A==
X-Google-Smtp-Source: AHgI3IZ2Q1U7HteRaxteMtMZ/jU28DZha+Vweykj/Bp34ci+sDgxNDhHlNpyi/KD1AtBJHquFRA0mw==
X-Received: by 2002:a1c:2d4b:: with SMTP id t72mr6837058wmt.99.1550254811025;
        Fri, 15 Feb 2019 10:20:11 -0800 (PST)
Received: from [148.251.42.114] ([2a01:4f8:201:9271::2])
        by smtp.gmail.com with ESMTPSA id o7sm4289323wmc.13.2019.02.15.10.20.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 10:20:10 -0800 (PST)
Message-ID: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
Date: Fri, 15 Feb 2019 10:20:10 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Kernelci-Kernel: next-20190215
X-Kernelci-Report-Type: bisect
X-Kernelci-Tree: next
X-Kernelci-Lab-Name: lab-collabora
X-Kernelci-Branch: master
Subject: next/master boot bisection: next-20190215 on beaglebone-black
To: tomeu.vizoso@collabora.com, guillaume.tucker@collabora.com,
 Dan Williams <dan.j.williams@intel.com>, broonie@kernel.org,
 matthew.hart@linaro.org, Stephen Rothwell <sfr@canb.auug.org.au>,
 khilman@baylibre.com, enric.balletbo@collabora.com,
 Andrew Morton <akpm@linux-foundation.org>
From: "kernelci.org bot" <bot@kernelci.org>
Cc: Nicholas Piggin <npiggin@gmail.com>,
 Dominik Brodowski <linux@dominikbrodowski.net>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kees Cook <keescook@chromium.org>, "kernelci.org bot" <bot@kernelci.org>,
 Adrian Reber <adrian@lisas.de>, linux-kernel@vger.kernel.org,
 Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Michal Hocko <mhocko@suse.com>, Richard Guy Briggs <rgb@redhat.com>,
 "Peter Zijlstra (Intel)" <peterz@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* This automated bisection report was sent to you on the basis  *
* that you may be involved with the breaking commit it has      *
* found.  No manual investigation has been done to verify it,   *
* and the root cause of the problem may be somewhere else.      *
* Hope this helps!                                              *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

next/master boot bisection: next-20190215 on beaglebone-black

Summary:
  Start:      7a92eb7cc1dc Add linux-next specific files for 20190215
  Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
  Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/m=
ulti_v7_defconfig+CONFIG_SMP=3Dn/gcc-7/lab-collabora/boot-am335x-boneblack.=
txt
  HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/m=
ulti_v7_defconfig+CONFIG_SMP=3Dn/gcc-7/lab-collabora/boot-am335x-boneblack.=
html
  Result:     8dd037cc97d9 mm/shuffle: default enable all shuffling

Checks:
  revert:     PASS
  verify:     PASS

Parameters:
  Tree:       next
  URL:        git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next=
.git
  Branch:     master
  Target:     beaglebone-black
  CPU arch:   arm
  Lab:        lab-collabora
  Compiler:   gcc-7
  Config:     multi_v7_defconfig+CONFIG_SMP=3Dn
  Test suite: boot

Breaking commit found:

---------------------------------------------------------------------------=
----
commit 8dd037cc97d9226c97c2ee1abb4e97eff71e0c8d
Author: Dan Williams <dan.j.williams@intel.com>
Date:   Fri Feb 15 11:28:30 2019 +1100

    mm/shuffle: default enable all shuffling
    =

    Per Andrew's request arrange for all memory allocation shuffling code to
    be enabled by default.
    =

    The page_alloc.shuffle command line parameter can still be used to disa=
ble
    shuffling at boot, but the kernel will default enable the shuffling if =
the
    command line option is not specified.
    =

    Link: http://lkml.kernel.org/r/154943713572.3858443.1120630798838288937=
7.stgit@dwillia2-desk3.amr.corp.intel.com
    Signed-off-by: Dan Williams <dan.j.williams@intel.com>
    Cc: Kees Cook <keescook@chromium.org>
    Cc: Michal Hocko <mhocko@suse.com>
    Cc: Dave Hansen <dave.hansen@linux.intel.com>
    Cc: Keith Busch <keith.busch@intel.com>
    =

    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

diff --git a/init/Kconfig b/init/Kconfig
index 4531a97092c7..9d4b05e79a2d 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1709,7 +1709,7 @@ config SLAB_MERGE_DEFAULT
 	  command line.
 =

 config SLAB_FREELIST_RANDOM
-	default n
+	default y
 	depends on SLAB || SLUB
 	bool "SLAB freelist randomization"
 	help
@@ -1728,7 +1728,7 @@ config SLAB_FREELIST_HARDENED
 =

 config SHUFFLE_PAGE_ALLOCATOR
 	bool "Page allocator randomization"
-	default SLAB_FREELIST_RANDOM && ACPI_NUMA
+	default y
 	help
 	  Randomization of the page allocator improves the average
 	  utilization of a direct-mapped memory-side-cache. See section
diff --git a/mm/shuffle.c b/mm/shuffle.c
index 3ce12481b1dc..a979b48be469 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -9,8 +9,8 @@
 #include "internal.h"
 #include "shuffle.h"
 =

-DEFINE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
-static unsigned long shuffle_state __ro_after_init;
+DEFINE_STATIC_KEY_TRUE(page_alloc_shuffle_key);
+static unsigned long shuffle_state __ro_after_init =3D 1 << SHUFFLE_ENABLE;
 =

 /*
  * Depending on the architecture, module parameter parsing may run
diff --git a/mm/shuffle.h b/mm/shuffle.h
index 777a257a0d2f..c1e91ec118be 100644
--- a/mm/shuffle.h
+++ b/mm/shuffle.h
@@ -19,7 +19,7 @@ enum mm_shuffle_ctl {
 #define SHUFFLE_ORDER (MAX_ORDER-1)
 =

 #ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
-DECLARE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
+DECLARE_STATIC_KEY_TRUE(page_alloc_shuffle_key);
 extern void page_alloc_shuffle(enum mm_shuffle_ctl ctl);
 extern void __shuffle_free_memory(pg_data_t *pgdat);
 static inline void shuffle_free_memory(pg_data_t *pgdat)
---------------------------------------------------------------------------=
----


Git bisection log:

---------------------------------------------------------------------------=
----
git bisect start
# good: [23e93c9b2cde73f9912d0d8534adbddd3dcc48f4] Revert "gfs2: read journ=
al in large chunks to locate the head"
git bisect good 23e93c9b2cde73f9912d0d8534adbddd3dcc48f4
# bad: [7a92eb7cc1dc4c63e3a2fa9ab8e3c1049f199249] Add linux-next specific f=
iles for 20190215
git bisect bad 7a92eb7cc1dc4c63e3a2fa9ab8e3c1049f199249
# good: [3811b833d598702c05fd25e36a60f134dd5413b3] Merge remote-tracking br=
anch 'crypto/master'
git bisect good 3811b833d598702c05fd25e36a60f134dd5413b3
# good: [c6cd1b643783f81eaa8e0d777ab0f887df905a45] Merge remote-tracking br=
anch 'spi/for-next'
git bisect good c6cd1b643783f81eaa8e0d777ab0f887df905a45
# good: [36514d08b01218e91810d4007820e0f7d69851fa] Merge remote-tracking br=
anch 'staging/staging-next'
git bisect good 36514d08b01218e91810d4007820e0f7d69851fa
# good: [f84af8a897075fa5f07cd3f1dba6a5be015028a1] Merge remote-tracking br=
anch 'livepatching/for-next'
git bisect good f84af8a897075fa5f07cd3f1dba6a5be015028a1
# bad: [d9a4d0fe1030c19848a28f43f0ec1abc23303d94] dynamic_debug: move pr_er=
r from module.c to ddebug_add_module
git bisect bad d9a4d0fe1030c19848a28f43f0ec1abc23303d94
# good: [803117e440dde7fe8b77f80a9e592281f39e3789] mm/vmalloc.c: fix kernel=
 BUG at mm/vmalloc.c:512!
git bisect good 803117e440dde7fe8b77f80a9e592281f39e3789
# good: [131c16480ab397f4396dcba0e22edfe2fcb08702] mm, memcg: make memory.e=
min the baseline for utilisation determination
git bisect good 131c16480ab397f4396dcba0e22edfe2fcb08702
# good: [a5f4f868c87d60e55abf7bcf2175da5996aa8807] filemap-drop-the-mmap_se=
m-for-all-blocking-operations-v6
git bisect good a5f4f868c87d60e55abf7bcf2175da5996aa8807
# bad: [d658bb3b0f49638946d385055f6fcf5ed905128f] kernel/panic.c: taint: fi=
x debugfs_simple_attr.cocci warnings
git bisect bad d658bb3b0f49638946d385055f6fcf5ed905128f
# bad: [66eeeef52ba15aff9b7c5276e805f2970b9bfd0e] fs/proc/self.c: code clea=
nup for proc_setup_self()
git bisect bad 66eeeef52ba15aff9b7c5276e805f2970b9bfd0e
# bad: [8dd037cc97d9226c97c2ee1abb4e97eff71e0c8d] mm/shuffle: default enabl=
e all shuffling
git bisect bad 8dd037cc97d9226c97c2ee1abb4e97eff71e0c8d
# good: [0828998415b687cfcac66446e8c1fac8fe6190ba] filemap-drop-the-mmap_se=
m-for-all-blocking-operations-checkpatch-fixes
git bisect good 0828998415b687cfcac66446e8c1fac8fe6190ba
# good: [8061021c7c102891803bda7eed4d21873f49a857] mm: don't expose page to=
 fast gup before it's ready
git bisect good 8061021c7c102891803bda7eed4d21873f49a857
# first bad commit: [8dd037cc97d9226c97c2ee1abb4e97eff71e0c8d] mm/shuffle: =
default enable all shuffling
---------------------------------------------------------------------------=
----

