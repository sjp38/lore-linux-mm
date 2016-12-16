Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9816B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 22:14:19 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id j49so49462793qta.1
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 19:14:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f62si2117364qkj.33.2016.12.15.19.14.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 19:14:19 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBG3DsM5093464
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 22:14:18 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 27c3chq5mw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 22:14:18 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 15 Dec 2016 20:14:17 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [LSF/MM ATTEND] Un-addressable device memory and block/fs implications
In-Reply-To: <20161213181511.GB2305@redhat.com>
References: <20161213181511.GB2305@redhat.com>
Date: Fri, 16 Dec 2016 08:44:11 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87lgvgwoos.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

Jerome Glisse <jglisse@redhat.com> writes:

> I would like to discuss un-addressable device memory in the context of
> filesystem and block device. Specificaly how to handle write-back, read,
> ... when a filesystem page is migrated to device memory that CPU can not
> access.
>
> I intend to post a patchset leveraging the same idea as the existing
> block bounce helper (block/bounce.c) to handle this. I believe this is
> worth discussing during summit see how people feels about such plan and
> if they have better ideas.
>
>
> I also like to join discussions on:
>   - Peer-to-Peer DMAs between PCIe devices
>   - CDM coherent device memory
>   - PMEM
>   - overall mm discussions

I would like to attend this discussion. I can talk about coherent device
memory and how having HMM handle that will make it easy to have one
interface for device driver. For Coherent device case we definitely need
page cache migration support.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
