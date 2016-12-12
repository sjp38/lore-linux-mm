Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC8F6B025E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 12:56:57 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id w63so194093933oiw.4
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 09:56:57 -0800 (PST)
Received: from gateway20.websitewelcome.com (gateway20.websitewelcome.com. [192.185.51.6])
        by mx.google.com with ESMTPS id l46si21825502otb.34.2016.12.12.09.56.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 09:56:56 -0800 (PST)
Received: from cm3.websitewelcome.com (unknown [108.167.139.23])
	by gateway20.websitewelcome.com (Postfix) with ESMTP id 047F5400FE3C6
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:56:56 -0600 (CST)
Message-ID: <055180bb41167c3a6b9f1f20ae4d4f3f.squirrel@webmail.raithlin.com>
Date: Mon, 12 Dec 2016 11:51:54 -0600
Subject: [LSF/MM TOPIC][LSF/MM ATTEND] Enabling Peer-to-Peer DMAs between
 PCIe devices
From: "Stephen Bates" <sbates@raithlin.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org

Hi

I'd like to discuss the topic of how best to enable DMAs between PCIe
devices in the Linux kernel.

There have been many attempts to add to the kernel the ability to DMA
between two PCIe devices. However, to date, none of these have been
accepted. However as PCIe devices like NICs, NVMe SSDs and GPGPUs continue
to get faster the desire to move data directly between these devices (as
opposed to having to using a temporary buffer in system memory) is
increasing. Out of tree solutions like GPU-Direct are one illustration of
the popularity of this functionality. A recent discussion on this topic
provides a good summary of where things stand [1].

I would like to propose a session at LFS/MM to discuss some of the
different use cases for these P2P DMAs and also to discuss the pros and
cons of these approaches. The desire would be to try and form a consensus
on how best to move forward to an upstreamable solution to this problem.

In addition I would also be interested in participating in the following
topics:

 * Anything related to PMEM and DAX.

 * Integrating the block-layer polling capability into file-systems.

 * New feature integration into the NVMe driver (e.g. fabrics, CMBs, IO
tags etc.)

Cheers

Stephen

[1] http://marc.info/?l=linux-pci&m=147976059431355&w=2 (and subsequent
thread).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
