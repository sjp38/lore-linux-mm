Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA6526B026A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 15:19:05 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id l95-v6so12398607otl.17
        for <linux-mm@kvack.org>; Mon, 07 May 2018 12:19:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t37-v6si7674289oti.103.2018.05.07.12.19.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 May 2018 12:19:04 -0700 (PDT)
Date: Mon, 7 May 2018 12:18:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH v1 0/6] use mm to manage NVDIMM (pmem) zone
Message-ID: <20180507191857.GA15604@bombadil.infradead.org>
References: <1525704627-30114-1-git-send-email-yehs1@lenovo.com>
 <20180507184622.GB12361@bombadil.infradead.org>
 <CAPcyv4hBJN3npXwg3Ur32JSWtKvBUZh7F8W+Exx3BB-uKWwPag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hBJN3npXwg3Ur32JSWtKvBUZh7F8W+Exx3BB-uKWwPag@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Huaisheng Ye <yehs1@lenovo.com>, Michal Hocko <mhocko@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, chengnt@lenovo.com, pasha.tatashin@oracle.com, Sasha Levin <alexander.levin@verizon.com>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, colyli@suse.de, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@intel.com>

On Mon, May 07, 2018 at 11:57:10AM -0700, Dan Williams wrote:
> I think adding yet one more mm-zone is the wrong direction. Instead,
> what we have been considering is a mechanism to allow a device-dax
> instance to be given back to the kernel as a distinct numa node
> managed by the VM. It seems it times to dust off those patches.

I was wondering how "safe" we think that ability is.  NV-DIMM pages
(obviously) differ from normal pages by their non-volatility.  Do we
want their contents from the previous boot to be observable?  If not,
then we need the BIOS to clear them at boot-up, which means we would
want no kernel changes at all; rather the BIOS should just describe
those pages as if they were DRAM (after zeroing them).
