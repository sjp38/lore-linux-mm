Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7846F6B0334
	for <linux-mm@kvack.org>; Sat, 27 Oct 2018 05:20:41 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id k24so1371245otl.13
        for <linux-mm@kvack.org>; Sat, 27 Oct 2018 02:20:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j187-v6si6277oih.22.2018.10.27.02.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Oct 2018 02:20:40 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9R9IiwS078954
	for <linux-mm@kvack.org>; Sat, 27 Oct 2018 05:20:39 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ncn39rath-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 27 Oct 2018 05:20:39 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sat, 27 Oct 2018 10:20:36 +0100
Date: Sat, 27 Oct 2018 10:20:29 +0100
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH RESEND] c6x: switch to NO_BOOTMEM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20181027092028.GC6770@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Salter <msalter@redhat.com>, linux-c6x-dev@linux-c6x.org, linux-mm@kvack.org

Hi,

The patch below that switches c6x to NO_BOOTMEM is already merged into c6x
tree, but as there were no pull request from c6x during v4.19 merge window
it is still not present in Linus' tree.

Probably it would be better to direct it via mm tree to avoid possible
conflicts and breakage because of bootmem removal.

-- 
Sincerely yours,
Mike.
