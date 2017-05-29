Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48BB56B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 06:56:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 139so12732135wmf.5
        for <linux-mm@kvack.org>; Mon, 29 May 2017 03:56:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f124si22977972wmg.140.2017.05.29.03.56.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 03:56:48 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4TAt2qx011434
	for <linux-mm@kvack.org>; Mon, 29 May 2017 06:56:46 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2arha4apnc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 May 2017 06:56:46 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <michaele@au1.ibm.com>;
	Mon, 29 May 2017 20:56:43 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4TAuXZw59310194
	for <linux-mm@kvack.org>; Mon, 29 May 2017 20:56:41 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4TAu8Dd029194
	for <linux-mm@kvack.org>; Mon, 29 May 2017 20:56:08 +1000
From: Michael Ellerman <michaele@au1.ibm.com>
Subject: Re: [PATCH] mm: Define KB, MB, GB, TB in core VM
In-Reply-To: <7f85724c-6fc1-bb51-11e4-15fc2f89372b@linux.vnet.ibm.com>
References: <20170522111742.29433-1-khandual@linux.vnet.ibm.com> <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org> <20170523070227.GA27864@infradead.org> <09a6bafa-5743-425e-8def-bd9219cd756c@suse.cz> <161638da-3b2b-7912-2ae2-3b2936ca1537@linux.vnet.ibm.com> <7f85724c-6fc1-bb51-11e4-15fc2f89372b@linux.vnet.ibm.com>
Date: Mon, 29 May 2017 20:55:43 +1000
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87d1as6ifk.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:
>
> So the question is are we willing to do all these changes across
> the tree to achieve common definitions of KB, MB, GB, TB in the
> kernel ? Is it worth ?

No I don't think it's worth the churn.

But have you looked at using the "proper" names, ie. KiB, MiB, GiB?

AFAICS the only clash is:

drivers/mtd/ssfdc.c:#define KiB(x)	( (x) * 1024L )
drivers/mtd/ssfdc.c:#define MiB(x)	( KiB(x) * 1024L )

Which would be easy to convert.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
