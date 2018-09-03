Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB6C16B6623
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 01:12:49 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id r131-v6so18082718oie.14
        for <linux-mm@kvack.org>; Sun, 02 Sep 2018 22:12:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 24-v6si12773912oik.220.2018.09.02.22.12.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Sep 2018 22:12:48 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8358nnO098531
	for <linux-mm@kvack.org>; Mon, 3 Sep 2018 01:12:48 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2m8qf8bhdj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 03 Sep 2018 01:12:47 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 3 Sep 2018 06:12:46 +0100
Date: Mon, 3 Sep 2018 08:12:40 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 0/3] docs/core-api: add memory allocation guide
References: <1534517236-16762-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1534517236-16762-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <20180903051239.GB5826@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Michal Hocko <mhocko@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Any updates on this?

On Fri, Aug 17, 2018 at 05:47:13PM +0300, Mike Rapoport wrote:
> Hi,
> 
> As Vlastimil mentioned at [1], it would be nice to have some guide about
> memory allocation. This set adds such guide that summarizes the "best
> practices". 
> 
> The changes from the RFC include additions and corrections from Michal and
> Randy. I've also added markup to cross-reference the kernel-doc
> documentation.
> 
> I've split the patch into three to separate labels addition to the exiting
> files from the new contents.
> 
> Note that the second patch depends on the mm docs update [2] that Andrew
> took to the -mm tree.
> 
> v2 -> v3:
>   * s/HW/hardware
> 
> [1] https://www.spinics.net/lists/netfilter-devel/msg55542.html
> [2] https://lkml.org/lkml/2018/7/26/684
> 
> Mike Rapoport (3):
>   docs: core-api/gfp_mask-from-fs-io: add a label for cross-referencing
>   docs: core-api/mm-api: add a lable for GFP flags section
>   docs: core-api: add memory allocation guide
> 
>  Documentation/core-api/gfp_mask-from-fs-io.rst |   2 +
>  Documentation/core-api/index.rst               |   1 +
>  Documentation/core-api/memory-allocation.rst   | 124 +++++++++++++++++++++++++
>  Documentation/core-api/mm-api.rst              |   2 +
>  4 files changed, 129 insertions(+)
>  create mode 100644 Documentation/core-api/memory-allocation.rst
> 
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.
