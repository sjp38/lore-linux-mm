Return-Path: <SRS0=MSKp=Q7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 806E7C4360F
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:34:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34D122084D
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:34:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cE+GB6xt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34D122084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C468F8E015D; Sun, 24 Feb 2019 07:34:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCF188E015B; Sun, 24 Feb 2019 07:34:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A70268E015D; Sun, 24 Feb 2019 07:34:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 625B58E015B
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 07:34:29 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x5so9536plv.17
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 04:34:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=IofwoUpnukhHD5Lom+sSlZv54BEm4R4tYJZvLTxZCAY=;
        b=efBFyp2CthGvK3C/I0WAQtvU/WB6DIfwlW8jVSqLoXGibpUn7yASSdtr9OGj89a2wd
         dk681ffvvsXLoABv60YOnYlXIMsbv+Zpmb6fCA6AsJvofPZNP6hHKZvgnZie20HrZPeu
         meCIOXUoIWEE/rfMOdeWil+afRUQpuSlp4b85v8//jmfRlNT41E+1tQdG+MziWH7zfrI
         72MstcUqWPQ1n+7jjxaqQm2CKkMyvNuKwBU8cgaFeG2y5CW/R8KenaZE8IaWNt4oC47N
         ETmQs4XjW5XqIrgHrev7PhwyXUKXRPTR2PwT01YSBjO6HHcnd8IBgIJ2mAs19Q3dNvg7
         Sq9g==
X-Gm-Message-State: AHQUAuaGjMiq2cqkytXtvu2LgbvJJYbTNPxOBrOTp4vS0/WtEBrDzziS
	eqLUhk5AbPCT28zoiGAp+SdR67nVanoQReUllPR6EFp/uKbpnTHS7Vy1ikE5Og4VvxAXwztbZXd
	+DoXBTsV2mTLPulX9frFlf0NGSj4p9lVW1m5nPdBdjuXGjNQq/dbzui6eeXoRB6gfcm4G+bAwh9
	NX53/Sc+0W/2Nck/tx61SG/wnQ21/bj+T9gDpkQGO/al2AC7mwpcLg+jzVoyI6UnJE3YcmnuI87
	Hc++WsDaLWo0PiHxBAP44QcKLwAH7jXCYMDTZn2a5AD68ez753j6PG5e9pRGZutgKAhlIs0KtnM
	FlXUtv3JqZ0dakrh9P20T1zSVLShtbaD9Qt75WaYojgMlz7EYOppNSsCk7iMn7iFd5kEWzaa6so
	y
X-Received: by 2002:a63:2ccb:: with SMTP id s194mr12748792pgs.214.1551011668954;
        Sun, 24 Feb 2019 04:34:28 -0800 (PST)
X-Received: by 2002:a63:2ccb:: with SMTP id s194mr12748673pgs.214.1551011667575;
        Sun, 24 Feb 2019 04:34:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551011667; cv=none;
        d=google.com; s=arc-20160816;
        b=gAQYun2y2wjdddN+nz/CyPVZSrp9TFLFzKE518GDIPUDV/oa4yPI1y6OSl7y5HKV5P
         NtTVUL7CLPYy8Ob6kgGP1RF6dO+dzTUWqk68LqzCMXXUMCFWxSNaP0bSDRzuuUOrRSZO
         xtY8CI7oCqCzjAiInhI9ztPSt/bU3CJMvUYKUnPoICs7BYE+IaYTK6fWica8OQINZgpy
         /mKK2AnGpK9T9p53umoi3+nG4gQGb3KZKQlVBTNqnOusYPAyVbuis0U7WBBb24vsdQ68
         z0pMfcrol4zyIr1fNzAMlPa4ydNF37f0B2slhG+d1IDUSy/1PwQj2qn4f1dZZm/2HDPu
         WgIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=IofwoUpnukhHD5Lom+sSlZv54BEm4R4tYJZvLTxZCAY=;
        b=NRw+en6Pbu61k+qbcrNfgQDVsIKpbTZaTC7LVtO8Y6OnVjNkOabLSG0+MB6CnAdNGy
         zSJpP+l5alWhOFWMFF1nUkRRxrQT0jTpjHyX+nGM71r8jTF3dUn9PmNGX9EE422yQq4J
         QEDOxRjwW1so0niqPqN5tJQEW1nBa27ZSUGffWbuARadoBFAv9hVRHCuvpJIXehiosYg
         WlbtS1PEvXJ0J4gMsEFqsPlL/41J2vL8TH/T6H9mDrETV9A21XltBHav9NnMrP1vwyTu
         hSMAsz69vD+FsA2RdrMkJPhgL4opxzgOKZ+RdNn5hO9TkAlufK+srfFpcawjoOnmMjIq
         zx5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cE+GB6xt;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9sor9935514pla.72.2019.02.24.04.34.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Feb 2019 04:34:27 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cE+GB6xt;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=IofwoUpnukhHD5Lom+sSlZv54BEm4R4tYJZvLTxZCAY=;
        b=cE+GB6xtHZOovXvIRtQuHIi4BXrBkV/809xXhQhyqY+Y8dpT40VE+KkpGF3CJTn8Pb
         B3ji3dgo5mmiU6ThZgIS/VVkvGLvgx/mrqrHncYlpzPZD4O/Pf8yM3XgBcP9Ab1ldvpD
         liq0uisXEblFwagMgK0FeNQiTIU65+NpCxXOAvEe5W3scuxMhTv0mBn4WPCSlB9slsp4
         kENdWSCWZx0DjL8rrnXlKGLPO/Kxfc3glrtT46N/kwBEWHhPeIEgoshTNTddWWGXBS3W
         v5uo1b8o5UXskMju4HkwXAqi5D9kdboBZp1iVtWgJ45Dt/cDiqqGyG7OcpBzDwgTRXO2
         XNhg==
X-Google-Smtp-Source: AHgI3IZtgIHa4u4QsONmKsC8s7teLj7KUuAEy8OSe7nq6FfrFdBZ9etnX7dc6bSBaVB11shNbDMJ7g==
X-Received: by 2002:a17:902:2a66:: with SMTP id i93mr13853538plb.128.1551011667204;
        Sun, 24 Feb 2019 04:34:27 -0800 (PST)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id v6sm9524634pgb.2.2019.02.24.04.34.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 04:34:26 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
To: x86@kernel.org,
	linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andy Lutomirski <luto@kernel.org>,
	Andi Kleen <ak@linux.intel.com>,
	Petr Tesarik <ptesarik@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Jonathan Corbet <corbet@lwn.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Daniel Vacek <neelx@redhat.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH 0/6] make memblock allocator utilize the node's fallback info
Date: Sun, 24 Feb 2019 20:34:03 +0800
Message-Id: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are NUMA machines with memory-less node. At present page allocator builds the
full fallback info by build_zonelists(). But memblock allocator does not utilize
this info. And for memory-less node, memblock allocator just falls back "node 0",
without utilizing the nearest node. Unfortunately, the percpu section is allocated 
by memblock, which is accessed frequently after bootup.

This series aims to improve the performance of per cpu section on memory-less node
by feeding node's fallback info to memblock allocator on x86, like we do for page
allocator. On other archs, it requires independent effort to setup node to cpumask
map ahead.


CC: Thomas Gleixner <tglx@linutronix.de>
CC: Ingo Molnar <mingo@redhat.com>
CC: Borislav Petkov <bp@alien8.de>
CC: "H. Peter Anvin" <hpa@zytor.com>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Vlastimil Babka <vbabka@suse.cz>
CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Joonsoo Kim <iamjoonsoo.kim@lge.com>
CC: Andy Lutomirski <luto@kernel.org>
CC: Andi Kleen <ak@linux.intel.com>
CC: Petr Tesarik <ptesarik@suse.cz>
CC: Michal Hocko <mhocko@suse.com>
CC: Stephen Rothwell <sfr@canb.auug.org.au>
CC: Jonathan Corbet <corbet@lwn.net>
CC: Nicholas Piggin <npiggin@gmail.com>
CC: Daniel Vacek <neelx@redhat.com>
CC: linux-kernel@vger.kernel.org

Pingfan Liu (6):
  mm/numa: extract the code of building node fall back list
  mm/memblock: make full utilization of numa info
  x86/numa: define numa_init_array() conditional on CONFIG_NUMA
  x86/numa: concentrate the code of setting cpu to node map
  x86/numa: push forward the setup of node to cpumask map
  x86/numa: build node fallback info after setting up node to cpumask
    map

 arch/x86/include/asm/topology.h |  4 ---
 arch/x86/kernel/setup.c         |  2 ++
 arch/x86/kernel/setup_percpu.c  |  3 --
 arch/x86/mm/numa.c              | 40 +++++++++++-------------
 include/linux/memblock.h        |  3 ++
 mm/memblock.c                   | 68 ++++++++++++++++++++++++++++++++++++++---
 mm/page_alloc.c                 | 48 +++++++++++++++++------------
 7 files changed, 114 insertions(+), 54 deletions(-)

-- 
2.7.4

