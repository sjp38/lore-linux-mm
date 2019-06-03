Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A386C28CC7
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:27:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8E9627151
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:27:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="cGJAgqDK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8E9627151
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CE6E6B026B; Mon,  3 Jun 2019 00:27:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47D996B026C; Mon,  3 Jun 2019 00:27:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36BA76B026D; Mon,  3 Jun 2019 00:27:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 167286B026B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:27:38 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 49so6462321qtn.23
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:27:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=vJh10jP5FQHItH6L90Py3lEvHZ/YcRQDomptsbrqx1k=;
        b=gJHew/t9BLmvth+XjUSst3oIoIdRvyxS5BKVj0b9KFb6lRqRIsZdpAix/ov5aHuvMd
         3rRVXjhFLbW2VJyADUhw1AzmvQyrHmHsj4Ny6cEcdQE97fBlG4qMs7eeMWaDIw7Ivbgl
         fVE/r5rcvfU0J/j/UTZBBx/BpkNmcL8yaFyu3+VV5FBEhw37UOODcQs0Dca5x8rASqFM
         TuWgKJdXHucIWXvt6aU9IVOiEm2UeemyuNkaNuqASW6HN2PBy6O/YbMIYC1VnVpoy3HX
         rHXdjNi87+I5ej1bNAwG+vGKRGPHJbzvqLkXgdHRPoqUqVjElJzRq/R1IkOX+v0EUUPl
         /lJw==
X-Gm-Message-State: APjAAAWQOR7IOjkZbFLg58lxYQI0Br4xEnEPanBf/I3XwYn0Zbn5/Z6F
	cQt278ALQakcdkkT8CKNY5RtCG3zbhi0tUwa7FV0NMwAyTcRFx/veQhiRmC9AmRGxrP0vToO5wJ
	t5YB+GkYViNWqR39o6Rvdr/GWtPy+HXAWf7YF2NI76e0hTBQZfqELHiBHnegBhSw=
X-Received: by 2002:ac8:2763:: with SMTP id h32mr21507996qth.350.1559536057754;
        Sun, 02 Jun 2019 21:27:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwz9cJIgYrT1OpKubrrTy2Rc1bVGwegPI9z32TV7ky34d3vOsbSu3ZQxbg/innQPrNnActH
X-Received: by 2002:ac8:2763:: with SMTP id h32mr21507963qth.350.1559536056847;
        Sun, 02 Jun 2019 21:27:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559536056; cv=none;
        d=google.com; s=arc-20160816;
        b=si/j/lkL48Xsq6bBOhNka9jwo6uKjFWXe0I2ttVRQMw8y0T862CDFSL8nFeWXqw8bY
         4mMBp3zmnOfwA+p04n7B4Qfp+o08tB8KrbqiYusi9SAZZ0V5gWrzkeq5eKIteglRlSJv
         rkVjusMuTMQmnCrnaQzf7m4RIdV9rcVMZzghlLTECmDPsBgFP0B+RFLVdINbzzbxOQtj
         vDWpJ1GVvWECkDmb2aha8fpMh4S27Nua3fcyDhTp01X9Z4u+fYqD/Y6JQomqKddotpNb
         /QWXjFj8sIVV+JTbxu9gipd3jMyu7nwf9APJRq13QZXBEIWP0lilN7oBKeZwgDStzBKB
         2a8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=vJh10jP5FQHItH6L90Py3lEvHZ/YcRQDomptsbrqx1k=;
        b=mgr9Mbr1jNr1qwkx9hmwA4V3oEzzpfG5fQcx4j+PuhlAp7ENYivRUylG1FRfzt9EQw
         EY9zmCv9kVLb+JN0ZNr0xdllX8xZFXVmgrONe20fzanglBeb+4opISp1JwZ9haqURnEp
         qZSKO6jN0/RWNc6EUEw7MqPIo8bO0TsZp4VK61HF0qjDTvDsjVzwNdzeGVF0VttsTTzD
         sAOhFASciRZzy8M3gpwLa+nu5bOieRR2UZ1f0gIBeaD3lhQKofBs86R0E1311rXAwlTM
         b94rMhk41P7XIrYkrg4n0nZlJPxPXrFNuu2T2h7U8WQZchT4x0HwW3qjxKnZ6Tyq1+ud
         Mj3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=cGJAgqDK;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id e11si1104067qkb.156.2019.06.02.21.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 21:27:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=cGJAgqDK;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 8BCE61320;
	Mon,  3 Jun 2019 00:27:36 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 03 Jun 2019 00:27:36 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=vJh10jP5FQHItH6L9
	0Py3lEvHZ/YcRQDomptsbrqx1k=; b=cGJAgqDK4X3UwkO5q/nqsgdDIUL+3g+T7
	yOP7wvHPzMshGTs4EBqY/HLso9/s+2AsL4ErSs2lXX/HSyNWJg39aBKJ8gDsbCnZ
	JvZANmHV90OEkIjEFzGO8otjzE2HGE8B91WeUh4SW9YUuRkdfW5qF4XQcBEttPJ1
	tHTD6Li6d3KZY3ehdFSuwurjCy3rMIU725vlLbeede5CUhbSTy2RycM4MzpXRZx3
	HiSZ6GHSX6GzCixFMoVKdbXcrGx1jTHEf+Kzkc4gsOCWHhWc4he1j6lonBFXEfCB
	pnq5rdTIDtS6cwpZ0YPhUZV/ZJty0mdDzEjAm+hvsGtHU+eVs6Jmw==
X-ME-Sender: <xms:taH0XJm-3njHVnq-PvAmoiysRTAjt8ODP8RYwNqgVzZTA6eRCwLnNw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudefiedgkedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufffkffoggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghinhcu
    vedrucfjrghrughinhhgfdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukfhppe
    duvdegrddugeelrdduudefrdefieenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:taH0XIGlni124F3v1b5nTtOWPr8guPIJ41zHOlM2u01qUjsE812YUQ>
    <xmx:taH0XJHh9E5LC8S6czHkgzSc-T7PdnclIIL4PKuisAG-Yxb00aK80g>
    <xmx:taH0XFPM-bp9AdMfoRIIXbTcoJjYOB9u8vSdsWu80e3WIYJYv4xwmg>
    <xmx:uKH0XPpEMWMUGal3kXzZB_SQjNF623F2joUdwbczXIb9rWxTu-q8HA>
Received: from eros.localdomain (124-149-113-36.dyn.iinet.net.au [124.149.113.36])
	by mail.messagingengine.com (Postfix) with ESMTPA id F3FE88005B;
	Mon,  3 Jun 2019 00:27:26 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 00/15] Slab Movable Objects (SMO)
Date: Mon,  3 Jun 2019 14:26:22 +1000
Message-Id: <20190603042637.2018-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

TL;DR - Add object migration (SMO) to the SLUB allocator and implement
object migration for the XArray and the dcache. 

Thanks for you patience with all the RFC's of this patch set.  Here it
is, ready for prime time.

Internal fragmentation can occur within pages used by the slub
allocator.  Under some workloads large numbers of pages can be used by
partial slab pages.  This under-utilisation is bad simply because it
wastes memory but also because if the system is under memory pressure
higher order allocations may become difficult to satisfy.  If we can
defrag slab caches we can alleviate these problems.

In order to be able to defrag slab chaches we need to be able to migrate
objects to a new slab.  Slab object migration is the core functionality
added by this patch series.

Internal slab fragmentation is a long known problem.  This series does
not claim to completely _fix_ the issue.  Instead we are adding core
code to the SLUB allocator to enable users of the allocator to help
mitigate internal fragmentation.  Object migration is on a per cache
basis, with each cache being able to take advantage of object migration
to varying degrees depending on the nature of the objects stored in the
cache.

Series includes test modules and test code that can be used to verify the
claimed behaviour.

Patch #1 - Adds the callbacks used to enable SMO for a particular cache.

Patch #2 - Updates the slabinfo tool to show operations related to SMO.

Patch #3 - Sorts the cache list putting migratable slabs at front.

Patch #4 - Adds the SMO infrastructure.  This is the core patch of the
           series.

Patch #5, #6 - Further update slabinfo tool for information just added.

Patch #7 - Add a module for testing SMO.

Patch #8 - Add unit test suite in Python utilising test module from #7.

Patch #9 - Add a new slab cache for the XArray (separate from radix tree).

Patch #10 - Implement SMO for the XArray.

Patch #11 - Add module for testing XArray SMO implementation.

Patch #12 - Add a dentry constructor.

Patch #13 - Use SMO to attempt to reduce fragmentation of the dcache by
	    selectively freeing dentry objects.

Patch #14 - Add functionality to move slab objects to a specific NUMA node.

Patch #15 - Add functionality to balance slab objects across all NUMA nodes.

The last RFC (RFCv5 and discussion on it) included code to conditionally
exclude SMO for the dcache.  This has been removed.  IMO it is now not
needed.  Al sufficiently bollock'ed me during development that I believe
the dentry code is good and does not negatively effect the dcache.  If
someone would like to prove me wrong simply remove the call to

    kmem_cache_setup_mobility(dentry_cache, d_isolate, d_partial_shrink);

Testing:

The series has been tested to verify that objects are moved using bare
metal (core i5) and also Qemu.  This has not been tested on big metal or
on NUMA hardware.

I have no measurements on performance gains achievable with this set, I
have just verified that the migration works and does not appear to break
anything.

Patch #14 and #15 depend on

	CONFIG_SLBU_DEBUG_ON or boot with 'slub_debug'

Thanks for taking the time to look at this.

	Tobin


Tobin C. Harding (15):
  slub: Add isolate() and migrate() methods
  tools/vm/slabinfo: Add support for -C and -M options
  slub: Sort slab cache list
  slub: Slab defrag core
  tools/vm/slabinfo: Add remote node defrag ratio output
  tools/vm/slabinfo: Add defrag_used_ratio output
  tools/testing/slab: Add object migration test module
  tools/testing/slab: Add object migration test suite
  lib: Separate radix_tree_node and xa_node slab cache
  xarray: Implement migration function for xa_node objects
  tools/testing/slab: Add XArray movable objects tests
  dcache: Provide a dentry constructor
  dcache: Implement partial shrink via Slab Movable Objects
  slub: Enable moving objects to/from specific nodes
  slub: Enable balancing slabs across nodes

 Documentation/ABI/testing/sysfs-kernel-slab |  14 +
 fs/dcache.c                                 | 105 ++-
 include/linux/slab.h                        |  71 ++
 include/linux/slub_def.h                    |  10 +
 include/linux/xarray.h                      |   3 +
 init/main.c                                 |   2 +
 lib/radix-tree.c                            |   2 +-
 lib/xarray.c                                | 109 ++-
 mm/Kconfig                                  |   7 +
 mm/slab_common.c                            |   2 +-
 mm/slub.c                                   | 827 ++++++++++++++++++--
 tools/testing/slab/Makefile                 |  10 +
 tools/testing/slab/slub_defrag.c            | 567 ++++++++++++++
 tools/testing/slab/slub_defrag.py           | 451 +++++++++++
 tools/testing/slab/slub_defrag_xarray.c     | 211 +++++
 tools/vm/slabinfo.c                         |  51 +-
 16 files changed, 2339 insertions(+), 103 deletions(-)
 create mode 100644 tools/testing/slab/Makefile
 create mode 100644 tools/testing/slab/slub_defrag.c
 create mode 100755 tools/testing/slab/slub_defrag.py
 create mode 100644 tools/testing/slab/slub_defrag_xarray.c

-- 
2.21.0

