Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02125C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:23:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF07F21874
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:23:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF07F21874
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28AD96B000A; Wed, 20 Mar 2019 11:23:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 215A86B0281; Wed, 20 Mar 2019 11:23:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DF226B0283; Wed, 20 Mar 2019 11:23:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE1586B000A
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:23:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 14so2837417pfh.10
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:23:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=ob4YiEH7MMKuxcQISd8NHG0eyGf7waqczXDu7i8A3ZM=;
        b=eBeUjOMEgUSN+KucaD6WXXDNIVF/JmAINfUhg0fE9Vj1OA68L94p/n6mZKsOa8Z5Dt
         j3rQXb8LZp3Wi89uGwn1lNFrJMQe2bEEo3oPAzeS3JJfjTqQfmJkeUyc+U0gN9pa+iJ4
         ZA5uosQJjhPRSjULY8GEHVPgfQllhdQz8mWcL2yy5oETNXBkQIvqEiz0BFTKPuzllBq/
         ueUGeCed6Dna7eUXc+yOSwXKSlfSHK3BmgZvcPPA9GOHuPpwf10tTP7x0fzvLRwgKVsr
         /lduBIcIQsqrCFnYk/R7xqUIvtYMq8JXui52iOSSM6z5poUfEdlxFqazSxfr5HgAFAmv
         PArw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAWDZpMfdv5vu82LhVUvuVufWYUtkwUsZAnu9hIoVVhOwU0Yyk5D
	aU19MoslWaSMDKdlhaxW5+roUQNNX/c+Xbrmdj7eeyZOsyUeihaT9ovL03faJ7mADrwLinZenzp
	gzc2mGCYWd+d83FwfU5SVvtzL8R/AITs3k17t+Vr2o2Bx/Yq5aXpfDASV3L7w692Pnw==
X-Received: by 2002:a63:2158:: with SMTP id s24mr7741962pgm.156.1553095423224;
        Wed, 20 Mar 2019 08:23:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvv7c4XqzByxQ21Lmdvxn/dP1I6mol7q/k+DRYDcLztWkMHiA/FYJkY/oBgA0ZD4Ifn++I
X-Received: by 2002:a63:2158:: with SMTP id s24mr7741875pgm.156.1553095422114;
        Wed, 20 Mar 2019 08:23:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553095422; cv=none;
        d=google.com; s=arc-20160816;
        b=FJvjSqLgh5YQWkXXQDrtLz9hvHVRXk1Aw+UQ+wwuN6g37forstFQF2ejUgSqa6OXUc
         dlIRP9HlSXPNvahDvSMv8WSjV8bVqItkvuOIr1k/AWxdkkZqbdjXiv+6hoB58Kebgmhi
         XS/ZBewAba6px7CjTkTrzsJDA+h4qTV/uQdtCa/TpdNDE91C0j8sqxxyMhFT6OyEryd+
         +tcz+bFT+RhLR4fr5m61lnF5QwX+F89SH09iZooLb/l2V8gMQ7p9MmPtO8wwzGl+Gvr/
         XmCJ+OHaStu5Q1b9SJdQ1m/EW2ve/NKqXGiWjJLeCHkH6LDXIGt6hvshMMYbBlsfAFoO
         hyIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=ob4YiEH7MMKuxcQISd8NHG0eyGf7waqczXDu7i8A3ZM=;
        b=rzezeoGzhoE0AssJ9zOykuXPKET6nTm71aV7jSh+sShaO45k5xyp3VXSiAsWqjUdmd
         9ha6CF4ZW4i676NPEpdQpao5cB0Nfkw+H5C/7RMGSdUSeXXhPscXCly7360fWgaAYYfH
         kgjzQ3/TDstiZi5aUarorKqfJBmzOeYBz6Mxdh8Z0hlQ7MBsQs2U364kYhsB1q+9u91Y
         YqzssjZIhiYBV8nHDk2bNnC9veoshX9oLe8vuSSu06YkfTX1NbyU6uGOu8uUIDvuhylr
         LtzOaru4jEnhH2tStyLmKT7lieaCQ3B3fzPCTAQysIL638ewUIev0Hi0Xt0I9pWuIR2Z
         f9mA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id l17si1807308pff.202.2019.03.20.08.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Mar 2019 08:23:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 20 Mar 2019 08:23:37 -0700
Received: from fedoratest.localdomain (unknown [10.30.24.114])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 1115B4199D;
	Wed, 20 Mar 2019 08:23:37 -0700 (PDT)
From: Thomas Hellstrom <thellstrom@vmware.com>
To: <dri-devel@lists.freedesktop.org>
CC: <linux-graphics-maintainer@vmware.com>, Thomas Hellstrom
	<thellstrom@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew
 Wilcox <willy@infradead.org>, Will Deacon <will.deacon@arm.com>, Peter
 Zijlstra <peterz@infradead.org>, Rik van Riel <riel@surriel.com>, Minchan Kim
	<minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Huang Ying
	<ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Subject: [RFC PATCH 0/3] mm modifications / helpers for emulated GPU coherent memory
Date: Wed, 20 Mar 2019 16:23:12 +0100
Message-ID: <20190320152315.82758-1-thellstrom@vmware.com>
X-Mailer: git-send-email 2.19.0.rc1
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Received-SPF: None (EX13-EDG-OU-001.vmware.com: thellstrom@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Hi,
This is an early RFC to make sure I don't go too far in the wrong direction.

Non-coherent GPUs that can't directly see contents in CPU-visible memory,
like VMWare's SVGA device, run into trouble when trying to implement
coherent memory requirements of modern graphics APIs. Examples are
Vulkan and OpenGL 4.4's ARB_buffer_storage.

To remedy, we need to emulate coherent memory. Typically when it's detected
that a buffer object is about to be accessed by the GPU, we need to
gather the ranges that have been dirtied by the CPU since the last operation,
apply an operation to make the content visible to the GPU and clear the
the dirty tracking.

Depending on the size of the buffer object and the access pattern there are
two major possibilities:

1) Use page_mkwrite() and pfn_mkwrite(). (GPU buffer objects are backed
either by PCI device memory or by driver-alloced pages).
The dirty-tracking needs to be reset by write-protecting the affected ptes
and flush tlb. This has a complexity of O(num_dirty_pages), but the
write page-fault is of course costly.

2) Use hardware dirty-flags in the ptes. The dirty-tracking needs to be reset
by clearing the dirty bits and flush tlb. This has a complexity of
O(num_buffer_object_pages) and dirty bits need to be scanned in full before
each gpu-access.

So in practice the two methods need to be interleaved for best performance.

So to facilitate this, I propose two new helpers, apply_as_wrprotect() and
apply_as_clean() ("as" stands for address-space) both inspired by
unmap_mapping_range(). Users of these helpers are in the making, but needs
some cleaning-up.

There's also a change to x_mkwrite() to allow dropping the mmap_sem while
waiting.

Any comments or suggestions appreciated.

Thanks,
Thomas



