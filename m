Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E5FCA8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 00:29:40 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t3-v6so7399177oif.20
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 21:29:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w65-v6si8873640otb.455.2018.09.19.21.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 21:29:39 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8K4Sld0056503
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 00:29:38 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mm3yw95sh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 00:29:38 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 20 Sep 2018 05:29:37 +0100
Date: Thu, 20 Sep 2018 07:29:30 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 0/3] docs/core-api: add memory allocation guide
References: <1536917278-31191-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536917278-31191-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <20180920042930.GA19495@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Ping?

On Fri, Sep 14, 2018 at 12:27:55PM +0300, Mike Rapoport wrote:
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
> v3 -> v4:
>   * make GFP_*USER* description less confusing
> 
> v2 -> v3:
>   * s/HW/hardware
> 
> [1] https://www.spinics.net/lists/netfilter-devel/msg55542.html
> 
> Mike Rapoport (3):
>   docs: core-api/gfp_mask-from-fs-io: add a label for cross-referencing
>   docs: core-api/mm-api: add a lable for GFP flags section
>   docs: core-api: add memory allocation guide
> 
>  Documentation/core-api/gfp_mask-from-fs-io.rst |   2 +
>  Documentation/core-api/index.rst               |   1 +
>  Documentation/core-api/memory-allocation.rst   | 122 +++++++++++++++++++++++++
>  Documentation/core-api/mm-api.rst              |   2 +
>  4 files changed, 127 insertions(+)
>  create mode 100644 Documentation/core-api/memory-allocation.rst
> 
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.
