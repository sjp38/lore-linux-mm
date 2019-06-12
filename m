Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F8AAC31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 06:43:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0141208CB
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 06:43:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmwopensource.org header.i=@vmwopensource.org header.b="m3g04XUO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0141208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 388596B0005; Wed, 12 Jun 2019 02:43:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 334006B0008; Wed, 12 Jun 2019 02:43:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D53B6B0007; Wed, 12 Jun 2019 02:43:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0D386B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 02:43:17 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id e13so2374432lfb.18
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 23:43:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=E7xDlM/OYx7CPvDhBFPYl3+gcA6UyTRJrb8kCjG3cu0=;
        b=arFwZg8YHAUD7QeENC3gAejJ8Ypo+2S8BcXqALhKALZT4YvvD7UZxdzRZcTXkmAEUm
         MNovJJWnK+ALv9fYCbI1BQmB9ZDDuIr7YCV9ZibnUPBtwZOAu3fzVLuG6XifZms4MKux
         7MmyxaJn10jNpqhcMgeTHYK4SaF4bMetQHvnVybl2Qz7ojqaSzUSkuI0fDwGpFi7JlaS
         GVIFzGrk6Jhp3N4hyXySPCp/v3qyNimS6qRkt3Xxb69SE3sTTjmlXvXwXRt1U/NHcdkZ
         OYdZ7j3qTD0ZN5SCbZFd9q5QzMRdTUd/qhwIw/iTj70RIcI7DzSPeGD0cEOS+NjMleZn
         HBOA==
X-Gm-Message-State: APjAAAVMwfduqpwk9c3jN19e4EXWvGPc2c+Pz90h+EdP0B/wlMToufxm
	qTOwcfYWZD8QoRLwQa+0AQQaFDF70pU4Pv6x3qM1vcdEOkCcQOYcFXQpgrg6hPrzzXLfwxt6Tqk
	zwV8NnKGmJv4A6OvUHXtE+qaL2b4FHNU/vrcAgarWn6jIG//vuiWHRITolw/2xfbB9w==
X-Received: by 2002:a05:6512:dc:: with SMTP id c28mr39490602lfp.105.1560321796734;
        Tue, 11 Jun 2019 23:43:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsWmbyM/RSZTc/pCMXotaHuO7Y9ws3nawcUKGGwlI81JeCeNBJIgQw74s2yx8h99qrz5S1
X-Received: by 2002:a05:6512:dc:: with SMTP id c28mr39490523lfp.105.1560321795181;
        Tue, 11 Jun 2019 23:43:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560321795; cv=none;
        d=google.com; s=arc-20160816;
        b=JMgThte1elE0+yNvv7CnvtSawNSwAt8FpPj59n6w+Ud+EiC/WFis2+NVZ/9XRBj2SZ
         f3EFIqRgsKuaabkEHSyXcRm7BdCZ7IKmFSziAtPmualM781HPDcf8o3HNZY97p1t7Xkh
         j1tJPUeb/feU7RyOYR5ag2qBZyUF6bAqPUgXwUu3MoOWJoUDEKSs6hNJ/sogfrNYItED
         VPKjuMcjdbBeLV1DGD/Oz1vA59Yd2eNYbaMvoAVv+a3q6W8AP4L0dCgjV6da+dJeSXYv
         ZMaI8oDWS2JM3JMJpSGIwslgkXfdtOqTX7zzDGhMzy8ExPPN2GKjbg9LfXtIrva2SUou
         4O4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=E7xDlM/OYx7CPvDhBFPYl3+gcA6UyTRJrb8kCjG3cu0=;
        b=t8VHVm/nOLgJqwZPAmVg5N4XEZ0wRfJjYJVvTPFiKkzF8AYuKa4TWV6AgKn6nMXzqG
         encwEaccKTVDIIMNqoJJCYUu/wYEdXHtgb5QmFm29atjNzZYFZzLsIka1461sRH9BbuH
         UymqpRlkmcUnaN1RPoRA6U/RjsDc9fb9VhqcLuMbf5hgmiD+6sl7KRdvHRyiIOxrgfsn
         eR0cn9uhtkQuPmqh6rvgz5QXBTDJVV+yKG4MaNCS2YJtvylxOHzfqcHKqeRxQ3oNMVhM
         PBFI9mWUMCyXtTqTKrlJu1P0MkuxYKiSp6zeOX54qQDSe38Uu8pOu1b+QvhAYhFMzocR
         sutQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=m3g04XUO;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from ste-pvt-msa1.bahnhof.se (ste-pvt-msa1.bahnhof.se. [213.80.101.70])
        by mx.google.com with ESMTPS id e19si5600358ljj.64.2019.06.11.23.43.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 23:43:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) client-ip=213.80.101.70;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=m3g04XUO;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTP id A81053F4D4;
	Wed, 12 Jun 2019 08:43:09 +0200 (CEST)
Authentication-Results: ste-pvt-msa1.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=m3g04XUO;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from ste-pvt-msa1.bahnhof.se ([127.0.0.1])
	by localhost (ste-pvt-msa1.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id GIepRt2s3xa6; Wed, 12 Jun 2019 08:42:56 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTPA id 5499A3F38D;
	Wed, 12 Jun 2019 08:42:55 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id BA7783619AF;
	Wed, 12 Jun 2019 08:42:54 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560321774;
	bh=WByRYt5aLCsI5/JRo0mK5a2KNL8fi1jYGttv4dC9TWM=;
	h=From:To:Cc:Subject:Date:From;
	b=m3g04XUOi3+wmlV5q5yPo/679JErYTahFbyb9/TgMh9mwskbT6O4oJ6p58+JNehNT
	 DCe+GRbQmmugO+pW/5d/5FgblMp3QWO8T4AmXg+D7na6lEtBx29/MmWP2kMlkRZM2O
	 1Z/0ncxWla/yhVHlhUA7Tf3GHqh0IGZx2PLpxBOQ=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thellstrom@vmwopensource.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org,
	nadav.amit@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	linux-mm@kvack.org
Subject: [PATCH v5 0/9] Emulated coherent graphics memory
Date: Wed, 12 Jun 2019 08:42:34 +0200
Message-Id: <20190612064243.55340-1-thellstrom@vmwopensource.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Planning to merge this through the drm/vmwgfx tree soon, so if there
are any objections, please speak up.

Graphics APIs like OpenGL 4.4 and Vulkan require the graphics driver
to provide coherent graphics memory, meaning that the GPU sees any
content written to the coherent memory on the next GPU operation that
touches that memory, and the CPU sees any content written by the GPU
to that memory immediately after any fence object trailing the GPU
operation has signaled.

Paravirtual drivers that otherwise require explicit synchronization
needs to do this by hooking up dirty tracking to pagefault handlers
and buffer object validation. This is a first attempt to do that for
the vmwgfx driver.

The mm patches has been out for RFC. I think I have addressed all the
feedback I got, except a possible softdirty breakage. But although the
dirty-tracking and softdirty may write-protect PTEs both care about,
that shouldn't really cause any operation interference. In particular
since we use the hardware dirty PTE bits and softdirty uses other PTE bits.

For the TTM changes they are hopefully in line with the long-term
strategy of making helpers out of what's left of TTM.

The code has been tested and excercised by a tailored version of mesa
where we disable all explicit synchronization and assume graphics memory
is coherent. The performance loss varies of course; a typical number is
around 5%.

Changes v1-v2:
- Addressed a number of typos and formatting issues.
- Added a usage warning for apply_to_pfn_range() and apply_to_page_range()
- Re-evaluated the decision to use apply_to_pfn_range() rather than
  modifying the pagewalk.c. It still looks like generically handling the
  transparent huge page cases requires the mmap_sem to be held at least
  in read mode, so sticking with apply_to_pfn_range() for now.
- The TTM page-fault helper vma copy argument was scratched in favour of
  a pageprot_t argument.
Changes v3:
- Adapted to upstream API changes.
Changes v4:
- Adapted to upstream mmu_notifier changes. (Jerome?)
- Fixed a couple of warnings on 32-bit x86
- Fixed image offset computation on multisample images.
Changes v5:
- Updated usage warning in patch 3/9 after review comments from Nadav Amit.
  
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: "Christian König" <christian.koenig@amd.com>
Cc: linux-mm@kvack.org

