Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53C416B025E
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:37:56 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id n63so338120896ywf.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 03:37:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t124si2279288ybf.190.2016.06.20.03.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 03:37:55 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5KAYAOb048891
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:37:54 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23n2ta3vfc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:37:54 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 20 Jun 2016 11:37:52 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id AE4F717D805F
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 11:39:05 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5KAbnAf14352668
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 10:37:49 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5K9bpgB011076
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 03:37:51 -0600
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH 0/1] introduce page_ref_inc_return
Date: Mon, 20 Jun 2016 12:38:12 +0200
Message-Id: <1466419093-114348-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, KVM <kvm@vger.kernel.org>, Cornelia Huck <cornelia.huck@de.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, Christian Borntraeger <borntraeger@de.ibm.com>, David Hildenbrand <dahi@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

commit 0139aa7b7fa1 ("mm: rename _count, field of the struct page,
to _refcount") changed all accesses to page->_count to use wrappers.
There is already a page_ref_dec_return and we need for kvm/s390
code the function "page_ref_inc_return" as well.

FWIW, the code is under
https://git.kernel.org/cgit/linux/kernel/git/kvms390/linux.git/log/?h=next


Can I get an ack to carry this patch via the KVM/s390 tree (will
be merged into Paolos kvm tree soon)?

David Hildenbrand (1):
  mm/page_ref: introduce page_ref_inc_return

 include/linux/page_ref.h | 9 +++++++++
 1 file changed, 9 insertions(+)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
