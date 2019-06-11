Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 385F7C4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:25:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2E2120673
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:25:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmwopensource.org header.i=@vmwopensource.org header.b="gMRzw4i4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2E2120673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F1BF6B0008; Tue, 11 Jun 2019 08:25:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 050686B000D; Tue, 11 Jun 2019 08:25:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4C366B000D; Tue, 11 Jun 2019 08:25:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A13B6B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:25:31 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id c25so2062581ljb.3
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:25:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=O9rKDfABdYSDsplVt+kvAPnZK2PAjuJ3ebXsyu1dKbs=;
        b=UvTqZo7MFwr9iyng4qWvTRkrre/7C2Qll++TxK8M2qpvnBRoQA5id4JSQ0VnmKhIET
         qOLENXuhOVMBxrORXV1OLpBJL4wIhUvNro0uEMPL9epJxhmsO/rUtJVcO1fsY312FqQ8
         OQS1k8UAAg7aJ2JvwbAPiT9Jh0MmeqPEg4nDWOzo20RfrzycbFvy8Zg0mADsNPjBfVOZ
         k4yWkfDKGiSRcooaaUw477XTcbGuibH7+naZb4NXva1xjSC0p4+Es+lcTW2Mi+HboTdL
         CtAhT2avTnL07l4MB6O/QO7cNFYwNMycgvGs498Q9fFLmO+zcSB7/ZwuKpqH4bBBQw10
         Iw6w==
X-Gm-Message-State: APjAAAW+AWOmt2qzb/aRKsRbjq6OAJqVuv8GQCSH0vh3yoQvYDxxvUZc
	0Fmb4/+0S+ngPj3Bgv4+4H2yOCKJHgPkynJDRtVnFZo0day+aIL4zbvyDKsy4BtoVpdIybY/ZQ/
	VvTaz+8NAGIp/4C53L/dt8aAgmkA1ZPg6lWLGas61CL5ADveEwHxtx5eLBTIRAerqhw==
X-Received: by 2002:a2e:9112:: with SMTP id m18mr41217317ljg.181.1560255930350;
        Tue, 11 Jun 2019 05:25:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznHdC6piJX98YgoYVeS5tdP06ZqHrUsTnzVJxh/bsxgDt3rFjkpZJFdPf8Yz7xQCLfMoFt
X-Received: by 2002:a2e:9112:: with SMTP id m18mr41217248ljg.181.1560255928928;
        Tue, 11 Jun 2019 05:25:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560255928; cv=none;
        d=google.com; s=arc-20160816;
        b=yfBkRMOf5Jft1Y6jCWLh0KYZfNkf8cwHTVnYR/ulUql9In5P8VCWn3tsWX8r9bFz/5
         gdyA9gGJMlhU3KEB2bjIl/Nv1Zv/EB8wNBEDTCSCTudJdp5ibMRcM+cD1w/bhgi4nrgY
         6IOGtFrZ73g8qDyBBTGM54WqIuQYtIXsP9L/VDShjVCQ4x/OdpzRFCDLNeLeV3VcJAr2
         KhGyzc+Nwd/n6VMig+RGZVBENp3UIgwqHVECIcXKzhhR2euoCW5CBYc+kt1FFhnGXpIn
         KdWtsrczaqL69gGK82ver/snQ1Ab7qTBejboWY2MOU+SnkLHOlyxE/n9gFnRgYvYfjP+
         EhBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=O9rKDfABdYSDsplVt+kvAPnZK2PAjuJ3ebXsyu1dKbs=;
        b=L7SCMKRBRUwj4Qxe2pfp/JDr7l9k0W/TP6ob+am/0CFEwwe3k3JPbTBAkQPoqvNHzJ
         bq0p09gszKddG7vhlHcfe1bnysmxemWX1JrW+6RSXd3xz3kQlHBZrhG1s0xsYWGikYoL
         f4tOgVKxuP5fVvs2tKxTIE5w6gP5dQ0d1T16YSalq20Y6TNUnIIuPN2U7IdOBD31uKN3
         la2KUwSy1L70puFnb5rUyJ7gtFHausW00Lcpr6AJ0nsJlCS6+JkUUAAsDXIjRmXdA6eO
         oxXaVpyU4vKsivcE7rQ7ysPhJ3sBpC/zW1ykzeLUZA+2ZrZzSFu/a1PmgRnqLwHhHsCg
         1Wcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=gMRzw4i4;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se (ste-pvt-msa2.bahnhof.se. [213.80.101.71])
        by mx.google.com with ESMTPS id q27si1806399lfd.23.2019.06.11.05.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 05:25:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) client-ip=213.80.101.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=gMRzw4i4;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTP id 497503F4C0;
	Tue, 11 Jun 2019 14:25:23 +0200 (CEST)
Authentication-Results: ste-pvt-msa2.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=gMRzw4i4;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Authentication-Results: ste-ftg-msa2.bahnhof.se (amavisd-new);
	dkim=pass (1024-bit key) header.d=vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se ([127.0.0.1])
	by localhost (ste-ftg-msa2.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Yb0vNCNrCl76; Tue, 11 Jun 2019 14:25:09 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTPA id 9CE893F5EC;
	Tue, 11 Jun 2019 14:25:08 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id EB08D3619AA;
	Tue, 11 Jun 2019 14:25:07 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560255908;
	bh=8SSMjg5S87UIXKzzTPf2fASPtyT5YDoyHJlCuHXj464=;
	h=From:To:Cc:Subject:Date:From;
	b=gMRzw4i46y1oAfDZUJ2LywkUYfekmuoX6aqewJklfhU9nCUbA6MDcbNuaRtcft1Qc
	 tHI4tnrN0IyvR0CuFY7JKYiUdP13sYQdzDiSFEOcU3r2unZGMNjUCMuLEF44Gsr51R
	 CXXDFm6S1cPfQjHgAkRWT+8OCA+uRA2m0QJNJaGo=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thellstrom@vmwopensource.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org,
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
Subject: [PATCH v4 0/9] Emulated coherent graphics memory
Date: Tue, 11 Jun 2019 14:24:45 +0200
Message-Id: <20190611122454.3075-1-thellstrom@vmwopensource.org>
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

