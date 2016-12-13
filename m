Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7917A6B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 13:15:15 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id q13so62836417vkd.3
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 10:15:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 40si13578604uah.38.2016.12.13.10.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 10:15:14 -0800 (PST)
Date: Tue, 13 Dec 2016 13:15:11 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: [LSF/MM TOPIC] Un-addressable device memory and block/fs implications
Message-ID: <20161213181511.GB2305@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

I would like to discuss un-addressable device memory in the context of
filesystem and block device. Specificaly how to handle write-back, read,
... when a filesystem page is migrated to device memory that CPU can not
access.

I intend to post a patchset leveraging the same idea as the existing
block bounce helper (block/bounce.c) to handle this. I believe this is
worth discussing during summit see how people feels about such plan and
if they have better ideas.


I also like to join discussions on:
  - Peer-to-Peer DMAs between PCIe devices
  - CDM coherent device memory
  - PMEM
  - overall mm discussions

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
