Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9825A8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 14:19:34 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id k96-v6so10264920wrc.3
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 11:19:34 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50065.outbound.protection.outlook.com. [40.107.5.65])
        by mx.google.com with ESMTPS id g14-v6si1395823wmh.93.2018.09.20.11.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Sep 2018 11:19:33 -0700 (PDT)
Date: Thu, 20 Sep 2018 12:19:23 -0600
From: Jason Gunthorpe <jgg@mellanox.com>
Subject: Linux RDMA mini-conf at Plumbers 2018
Message-ID: <20180920181923.GA6542@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-rdma@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Alex Rosenbaum <alexr@mellanox.com>, Alex Williamson <alex.williamson@redhat.com>, Bjorn Helgaas <bhelgaas@google.com>, Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>, Christoph Hellwig <hch@lst.de>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Don Dutile <ddutile@redhat.com>, Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@mellanox.com>, John Hubbard <jhubbard@nvidia.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Matthew Wilcox <willy@infradead.org>, Nicholas Piggin <npiggin@gmail.com>, Noa Osherovich <noaos@mellanox.com>, Parav Pandit <parav@mellanox.com>, Stephen Bates <sbates@raithlin.com>

This is just a friendly reminder that registration deadlines are
approaching for this conference. Please see

https://www.linuxplumbersconf.org/event/2/page/7-attend

For details.

This year we expect to have close to a day set aside for RDMA related
topics. Including up to half a day for the thorny general kernel issues
related to get_user_pages(), particularly as exasperated by RDMA.

We have been working on the following concepts for sessions, I've
roughly marked names based on past participation in related email
threads. As we get closer to the conference date we will be organizing
leaders for each section based on these lists, please let us know of
any changes, or desire to be a leader!

RDMA and get_user_pages
=======================
  Dan Williams <dan.j.williams@intel.com>
  Matthew Wilcox <willy@infradead.org>
  John Hubbard <jhubbard@nvidia.com>
  Nicholas Piggin <npiggin@gmail.com>
  Jan Kara <jack@suse.cz>

 RDMA, DAX and persistant memory co-existence.

 Explore the limits of what is possible without using On
 Demand Paging Memory Registration. Discuss 'shootdown'
 of userspace MRs

 Dirtying pages obtained with get_user_pages() can oops ext4
 discuss open solutions.

RDMA and PCI peer to peer
=========================
  Don Dutile <ddutile@redhat.com>
  Alex Williamson <alex.williamson@redhat.com>
  Christoph Hellwig <hch@lst.de>
  Stephen Bates <sbates@raithlin.com>
  Logan Gunthorpe <logang@deltatee.com>
  JA(C)rA'me Glisse <jglisse@redhat.com>
  Christian KA?nig <christian.koenig@amd.com>
  Bjorn Helgaas <bhelgaas@google.com>

 RDMA and PCI peer to peer transactions. IOMMU issues. Integration
 with HMM. How to expose PCI BAR memory to userspace and other
 drivers as a DMA target.

Improving testing of RDMA with syzkaller, RXE and Python
========================================================
 Noa Osherovich <noaos@mellanox.com>
 Don Dutile <ddutile@redhat.com>
 Jason Gunthorpe <jgg@mellanox.com>

 Problem solve RDMA's distinct lack of public tests.
 Provide a better framework for all drivers to test with,
 and a framework for basic testing in userspace.

 Worst remaining unfixed syzkaller bugs and how to try to fix them

 How to hook syzkaller more deeply into RDMA.

IOCTL conversion and new kABI topics
====================================
 Jason Gunthorpe <jgg@mellanox.com>
 Alex Rosenbaum <alexr@mellanox.com>

 Attempt to close on the remaining tasks to complete the project

 Restore fork() support to userspace

Container and namespaces for RDMA topics
========================================
 Parav Pandit <parav@mellanox.com>
 Doug Ledford <dledford@redhat.com>

 Remaining sticky situations with containers

 namespaces in sysfs and legacy all-namespace operation

 Remaining CM issues

 Security isolation problems

Very large Contiguous regions in userspace
==========================================
 Christopher Lameter <cl@linux.com>
 Parav Pandit <parav@mellanox.com>

 Poor performance of get_user_pages on very large virtual ranges

 No standardized API to allocate regions to user space

 Carry over from last year

As we get closer to the conference date the exact schedule will be
published on the conference web site. I belive we have the Thursday
set aside right now.

If there are any last minute topics people would like to see please
let us know.

See you all in Vancouver!

Thanks,
Jason & Leon
