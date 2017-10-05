Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 886CC6B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 22:55:38 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u78so12145920wmd.4
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 19:55:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a12si26886edm.386.2017.10.04.19.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 19:55:37 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v952rx3P020097
	for <linux-mm@kvack.org>; Wed, 4 Oct 2017 22:55:35 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dda6snn5g-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Oct 2017 22:55:34 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 5 Oct 2017 12:55:32 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v952tUu844892298
	for <linux-mm@kvack.org>; Thu, 5 Oct 2017 13:55:30 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v952tXFF011945
	for <linux-mm@kvack.org>; Thu, 5 Oct 2017 13:55:34 +1100
Subject: Re: [PATCH] cma: Take __GFP_NOWARN into account in cma_alloc()
References: <20171004125447.15195-1-boris.brezillon@free-electrons.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 5 Oct 2017 08:25:25 +0530
MIME-Version: 1.0
In-Reply-To: <20171004125447.15195-1-boris.brezillon@free-electrons.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <7bf6c3b7-48a8-940a-1614-c2b0fdcddcb7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Brezillon <boris.brezillon@free-electrons.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, dri-devel@lists.freedesktop.org, Eric Anholt <eric@anholt.net>

On 10/04/2017 06:24 PM, Boris Brezillon wrote:
> cma_alloc() unconditionally prints an INFO message when the CMA
> allocation fails. Make this message conditional on the non-presence of
> __GFP_NOWARN in gfp_mask.
> 
> Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
> ---
> Hello,
> 
> This patch aims at removing INFO messages that are displayed when the
> VC4 driver tries to allocate buffer objects. From the driver perspective
> an allocation failure is acceptable, and the driver can possibly do
> something to make following allocation succeed (like flushing the VC4
> internal cache).
> 
> Also, I don't understand why this message is only an INFO message, and
> not a WARN (pr_warn()). Please let me know if you have good reasons to
> keep it as an unconditional pr_info()

Making it conditional (__GFP_NOWARN based what you already have) with
pr_warn() message makes more sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
