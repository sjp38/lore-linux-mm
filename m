Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0839A6B005C
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:17:40 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id z5so959860qti.4
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 03:17:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o21si3414161qtm.98.2018.03.28.03.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 03:17:38 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2SAFxND132809
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:17:37 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h07cfmb42-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:17:37 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 28 Mar 2018 11:17:34 +0100
Date: Wed, 28 Mar 2018 13:17:29 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH] userfaultfd: add UFFDIO_TRY_COW
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20180328101729.GB1743@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>

Hi,

This is an initial attempt to implement COW with userfaultfd.
It's not yet complete, but I'd like to get an early feedback to see I'm not
talking complete nonsense.

It was possible to extend UFFDIO_COPY with UFFDIO_COPY_MODE_COW,  but I've
preferred to add the COW'ing of the pages as a new ioctl because otherwise
I would need to extend uffdio_copy structure to hold an additional
parameter.

--
Sincerely yours,
Mike.
