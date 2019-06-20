Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB4D9C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 18:32:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90B9420665
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 18:32:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90B9420665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 142B86B0005; Thu, 20 Jun 2019 14:32:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CB658E0002; Thu, 20 Jun 2019 14:32:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFA688E0001; Thu, 20 Jun 2019 14:32:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CEC5C6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:32:15 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x10so4809808qti.11
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:32:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=1YQvFEDlJQCPGHuOuXSTVzjvx2e1LdFJSEyUmL77e/Y=;
        b=dEWdRfjDiAUmT+FRBggQ42jlqgNEYYaXLQQD4VrkvTrO3Tk1N8/R9hAIdE8tcRE3FY
         8IcKxhaxTCtSwo251AwkrBKVdIrWXZChH2Djd2xCCRyDTLTN8RxbhO4ncpCfvj5xTEcp
         iPRnkw57jm9xcpaGxb2SJbZYhsee3kt4EJMPR2OuwjJYk0WGbBpr6eVyXRvdghNPmeMD
         zFpVVO/H/HhRKCBLTjFhO2+JpJJCaFZeFSIBFKnk254UpTQG7emeSoHm5R3JE7I+Phdh
         wu6hlS8OSf95EJQtlr0GA2ct97Qq0x6kJvDlnP8NEBUzJsjWNb3G3QBvNjZO4pWl8LiU
         unTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUDwJWTejyWiPTKj4C8jLOBDWrhxsWeJr5s1pT7aGK+80F8XaAq
	8CpmdTZzJgj7ebR2EaJo8mYcg2X6W2e4LWNX60daWfafe5sirrEkbth4im9tm9G1edv3mSPcaJi
	YJVDPYYbJCCXqBnLPZFYrOctDzzShIIJ6btwHCQvAcQMPjH7kioGkssWZQHQmGBb+8w==
X-Received: by 2002:ac8:32ec:: with SMTP id a41mr99796374qtb.375.1561055535435;
        Thu, 20 Jun 2019 11:32:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztnVSdkn/F1vydW3Z+fmfUEY0QfuM/H5Q74spE8SxKcNdsTRJ0DtL5yiUuI+/DtwaFPADA
X-Received: by 2002:ac8:32ec:: with SMTP id a41mr99796287qtb.375.1561055534475;
        Thu, 20 Jun 2019 11:32:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561055534; cv=none;
        d=google.com; s=arc-20160816;
        b=t6Vx9A86CLNzVh0fd2icsjvu+XcjNbsQ28ODIws4r5rGE3v2ES772Ic4LC09pSCqjS
         jM+UxbnhFXIx8kReM8nc60dD6OK/sZ3qOiYFX2Gy2V5z+Jjf3taYddN3B+zfOYFEtVh9
         M6kAdl8szz+YEMjamaEOCe0vFVKJ3m5iftiCni6aHo4H7qIsfaVjVhGvcHT169Wh9TR4
         nk/yadjrT85f7745HxZydLnIxg4JxDxPS7YUyccYSGwuCzz2TA+W0PGX3lUUZvX4dsQV
         OjOTf3iDsRkalQZWoUwzDKlUj9Q92qPPmbCHNpZ4ii8KWS6z/72E0wuVQU1pvFdMx6de
         76qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=1YQvFEDlJQCPGHuOuXSTVzjvx2e1LdFJSEyUmL77e/Y=;
        b=kKIBny7xcBE6NfqMmX9YofD/Mq1eH/kb749NwE9PN/FDSCXfp5orWydafyAHuz/ckR
         kyeCkuSELfzFA2UKSZDu54MY4fY9TYhBefcVq05lgtALWyH192FZiBAAiAOa1ani+UVl
         mWwNlxVVzn4B36rc0rbSAsVsm5x4LlyGle3Xr25/xyFzb2N0tKiEs9O/yOOHD/MX/cqG
         NPFVZ2781gJgBfUnRvzuLcZ5bebYxYUzQS4T0mb7lo65liGQg4y83zPrhbNDtmP4zk76
         f4yQqOmLJ3WCNFbp7xQA3RWEfDUJyC8fG2d4xIHx8Pmsx2qaE5/XIZbxoBCIotG3uog4
         oULw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j8si120496qkg.105.2019.06.20.11.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 11:32:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 06634356EA;
	Thu, 20 Jun 2019 18:31:58 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-71.ams2.redhat.com [10.36.116.71])
	by smtp.corp.redhat.com (Postfix) with ESMTP id ACE2819722;
	Thu, 20 Jun 2019 18:31:40 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Arun KS <arunks@codeaurora.org>,
	Baoquan He <bhe@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Juergen Gross <jgross@suse.com>,
	Keith Busch <keith.busch@intel.com>,
	Len Brown <lenb@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Michael Neuling <mikey@neuling.org>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Oscar Salvador <osalvador@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Qian Cai <cai@lca.pw>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Rashmica Gupta <rashmica.g@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v3 0/6] mm: Further memory block device cleanups
Date: Thu, 20 Jun 2019 20:31:33 +0200
Message-Id: <20190620183139.4352-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 20 Jun 2019 18:32:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

@Andrew: Only patch 1, 4 and 6 changed compared to v1.

Some further cleanups around memory block devices. Especially, clean up
and simplify walk_memory_range(). Including some other minor cleanups.

Compiled + tested on x86 with DIMMs under QEMU. Compile-tested on ppc64.

v2 -> v3:
- "mm/memory_hotplug: Rename walk_memory_range() and pass start+size .."
-- Avoid warning on ppc.
- "drivers/base/memory.c: Get rid of find_memory_block_hinted()"
-- Fixup a comment regarding hinted devices.

v1 -> v2:
- "mm: Section numbers use the type "unsigned long""
-- "unsigned long i" -> "unsigned long nr", in one case -> "int i"
- "drivers/base/memory.c: Get rid of find_memory_block_hinted("
-- Fix compilation error
-- Get rid of the "hint" parameter completely

David Hildenbrand (6):
  mm: Section numbers use the type "unsigned long"
  drivers/base/memory: Use "unsigned long" for block ids
  mm: Make register_mem_sect_under_node() static
  mm/memory_hotplug: Rename walk_memory_range() and pass start+size
    instead of pfns
  mm/memory_hotplug: Move and simplify walk_memory_blocks()
  drivers/base/memory.c: Get rid of find_memory_block_hinted()

 arch/powerpc/platforms/powernv/memtrace.c |  23 ++---
 drivers/acpi/acpi_memhotplug.c            |  19 +---
 drivers/base/memory.c                     | 120 +++++++++++++---------
 drivers/base/node.c                       |   8 +-
 include/linux/memory.h                    |   5 +-
 include/linux/memory_hotplug.h            |   2 -
 include/linux/mmzone.h                    |   4 +-
 include/linux/node.h                      |   7 --
 mm/memory_hotplug.c                       |  57 +---------
 mm/sparse.c                               |  12 +--
 10 files changed, 106 insertions(+), 151 deletions(-)

-- 
2.21.0

