Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 515476B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 10:03:04 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r18so25958012wmd.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 07:03:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 62si5350581wrd.82.2017.02.07.07.03.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 07:03:02 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v17Es2ea045578
	for <linux-mm@kvack.org>; Tue, 7 Feb 2017 10:03:00 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28euqx29mg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 Feb 2017 10:03:00 -0500
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 7 Feb 2017 15:02:57 -0000
Date: Tue, 7 Feb 2017 17:02:50 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] userfaultfd: mcopy_atomic: update cases returning -ENOENT
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20170207150249.GA6709@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hello Andrew,

The patch below is an incremental fixup for concerns Andrea raised at [1].
Please let me know if you prefer me to update the original patch and
resend.

[1] http://www.spinics.net/lists/linux-mm/msg121267.html

--
Sincerely yours,
Mike.
