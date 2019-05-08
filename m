Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87F45C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DB60214C6
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DB60214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5872F6B0003; Wed,  8 May 2019 02:17:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55D9F6B0005; Wed,  8 May 2019 02:17:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44F656B0007; Wed,  8 May 2019 02:17:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 23B9B6B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:17:33 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id q188so17643888ywc.15
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:17:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=/S+LATtjTDIrUoa7FeJVerxJZMGHhJk4O4pVHqrAYNo=;
        b=GK5iUMJ214RBqUKFiaxwYfD0Vf4IUznG0hurA3+veXBkbc/jihzxBI2IqfkO9cGdgD
         C2gM6ybh6N0yXrDyAK4VvzITVPXOLcxPXpD58eetvaCSewJ9bULC5gImGGzSWVDn9gOo
         lqMSYZq5EhSdoxlOmD/dwu9Meq/4UYYhadD7gYiiL98Y+aAjbhIZhfdJTqrM95njUQDV
         3LlwyqYR/8mXV27S/azdRzjloZ4mkJaMWSh0Z9lIdbLEo/o0FRoEvceRjGx879F/I97F
         zAgkH0bgB+1A3gNMkPx5u/fi+VyzW4/pQWdOItOVrrcpk163koEZp4bdUrGOIqqNaznH
         9R+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWGXBTG4d9HnkQtu17u9s98hiv6ZmkhaCIeY4tnbNlZ+rfpANU6
	CBVkTkP3mifbzwD20Vz1eczOH+gCn9ujo7OvVmc2GVJ6nEvn64gs+nNIzK70FLEJKYn+vr1fdKH
	MJktj4EFu32Qfum+l0E/QQYqHS4+Y/UYRg0hwUGHYJEtiMbP1VVhl1FfalwS0ccdBIA==
X-Received: by 2002:a5b:4:: with SMTP id a4mr1471991ybp.406.1557296252835;
        Tue, 07 May 2019 23:17:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMYEO92/bc6u+Wv1dug1TYgvKWIYLb3ePropFh65ixuIqJFXJYc7kcTt7koddEsivXbpXq
X-Received: by 2002:a5b:4:: with SMTP id a4mr1471948ybp.406.1557296251744;
        Tue, 07 May 2019 23:17:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296251; cv=none;
        d=google.com; s=arc-20160816;
        b=XsKMUg7fGIritD1wn98lAi2SqqUx44C7imC60mB0pEiUNLDg72RLTTkn4gicWXq7a0
         oQGZY+rGMks7rXffqJ6ohBioUtgJq/GVtBxm17ThlpwJCprC++F1JKamI0H722C//kCB
         w0+W+I00kWp+czyTmkgGTCIdQgYG7ExbYwB9HCiZQoJyBF5kuvOEn9VG7lpLE6DAu5Zh
         g5ADZwOQeISTXssdyQkPefNlBMdKCQjczDDSpkHCTkGs8PhqAZCVuZdVchR1weLjBOL4
         n35QoVhDRc3WC1VrDWBYqsuEb+OTNNuGpAVu+uaKhiHygnYyDyiGJdd8WCFr5wUUoFxh
         Yd3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=/S+LATtjTDIrUoa7FeJVerxJZMGHhJk4O4pVHqrAYNo=;
        b=sO8p198+SLVcIKBFhMiDj4CzN3c6X0pTJxPR1q6FjoeSrLIE4ffMpoLnJaHNR+OeAJ
         U8Ilh42NCfcFzwkr6vCDfCxJXiYfeG+LERKUw4GMHxfWS9W1EKPYp0uXBSeVsOBwhdnP
         6C7/acQzRTSliYu+YqOks/NAYHllHL5m9s5hxAcexLwsRYRP2r4MRwYTAT037uZoE95n
         gx6kzRgofXeldqnsuXhrbNxH/NzhuBSEG6i8jbYRNI4qj1RBmLnq0mAXpKBvDzTPX+Yt
         B/slKbW4yQjCy5ya7U92bbzBCjYWiVHMiLxXqg7JGLauw6y9z6/GghAvCVfFUvDFVB2O
         fJiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d76si5865884ybh.114.2019.05.07.23.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:17:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486GcVl073203
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:17:31 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sbq0rpw11-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:17:31 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:17:27 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:17:17 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486HGdZ56426730
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:17:16 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C1500A405F;
	Wed,  8 May 2019 06:17:16 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7C43EA406B;
	Wed,  8 May 2019 06:17:13 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  8 May 2019 06:17:13 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:17:12 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Anshuman Khandual <anshuman.khandual@arm.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greentime Hu <green.hu@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>,
        Guo Ren <guoren@kernel.org>, Helge Deller <deller@gmx.de>,
        Ley Foon Tan <lftan@altera.com>, Matthew Wilcox <willy@infradead.org>,
        Matt Turner <mattst88@gmail.com>,
        Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>,
        Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>,
        Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>,
        Russell King <linux@armlinux.org.uk>, Sam Creasey <sammy@sammy.net>,
        x86@kernel.org, linux-alpha@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
        linux-mm@kvack.org, linux-parisc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org,
        linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 00/14] introduce generic pte_{alloc,free}_one[_kernel]
Date: Wed,  8 May 2019 09:16:57 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19050806-0008-0000-0000-000002E466E7
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0009-0000-0000-00002250E6BE
Message-Id: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=405 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Many architectures have similar, if not identical implementation of
pte_alloc_one_kernel(), pte_alloc_one(), pte_free_kernel() and pte_free().

A while ago Anshuman suggested to introduce a common definition of
GFP_PGTABLE and during the discussion it was suggested to rather
consolidate the allocators.

These patches introduce generic version of PTE allocation and free and
enable their use on several architectures.

The conversion introduces some changes for some of the architectures.
Here's the executive summary and the details are described at each patch.

* Most architectures do not set __GFP_ACCOUNT for the user page tables.
Switch to the generic functions is "spreading that goodness to all other
architectures"
* arm, arm64 and unicore32 used to check if the pte is not NULL before
freeing its memory in pte_free_kernel(). It's dropped during the
conversion as it seems superfluous.
* x86 used to BUG_ON() is pte was not page aligned duirng
pte_free_kernel(), the generic version simply frees the memory without any
checks.

This set only performs the straightforward conversion, the architectures
with different logic in pte_alloc_one() and pte_alloc_one_kernel() are not
touched, as well as architectures that have custom page table allocators.

v2 changes:
* rebase on the current upstream
* fix copy-paste error in the description of pte_free()
* fix changelog for MIPS to match actual changes
* drop powerpc changes
* add Acked/Reviewed tags

[1] https://lore.kernel.org/lkml/1547619692-7946-1-git-send-email-anshuman.khandual@arm.com

Mike Rapoport (14):
  asm-generic, x86: introduce generic pte_{alloc,free}_one[_kernel]
  alpha: switch to generic version of pte allocation
  arm: switch to generic version of pte allocation
  arm64: switch to generic version of pte allocation
  csky: switch to generic version of pte allocation
  hexagon: switch to generic version of pte allocation
  m68k: sun3: switch to generic version of pte allocation
  mips: switch to generic version of pte allocation
  nds32: switch to generic version of pte allocation
  nios2: switch to generic version of pte allocation
  parisc: switch to generic version of pte allocation
  riscv: switch to generic version of pte allocation
  um: switch to generic version of pte allocation
  unicore32: switch to generic version of pte allocation

 arch/alpha/include/asm/pgalloc.h     |  40 +------------
 arch/arm/include/asm/pgalloc.h       |  41 +++++---------
 arch/arm/mm/mmu.c                    |   2 +-
 arch/arm64/include/asm/pgalloc.h     |  47 +++------------
 arch/arm64/mm/mmu.c                  |   2 +-
 arch/arm64/mm/pgd.c                  |   9 ++-
 arch/csky/include/asm/pgalloc.h      |  30 +---------
 arch/hexagon/include/asm/pgalloc.h   |  34 +----------
 arch/m68k/include/asm/sun3_pgalloc.h |  41 +-------------
 arch/mips/include/asm/pgalloc.h      |  33 +----------
 arch/nds32/include/asm/pgalloc.h     |  31 ++--------
 arch/nios2/include/asm/pgalloc.h     |  37 +-----------
 arch/parisc/include/asm/pgalloc.h    |  33 +----------
 arch/riscv/include/asm/pgalloc.h     |  29 +---------
 arch/um/include/asm/pgalloc.h        |  16 +-----
 arch/um/kernel/mem.c                 |  22 -------
 arch/unicore32/include/asm/pgalloc.h |  36 +++---------
 arch/x86/include/asm/pgalloc.h       |  19 +------
 arch/x86/mm/pgtable.c                |  33 +++--------
 include/asm-generic/pgalloc.h        | 107 +++++++++++++++++++++++++++++++++--
 virt/kvm/arm/mmu.c                   |   2 +-
 21 files changed, 178 insertions(+), 466 deletions(-)

-- 
2.7.4

