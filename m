Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A946C10F11
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:35:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 993D820674
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:35:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="L289Jprq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 993D820674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 006116B0005; Wed, 10 Apr 2019 21:35:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF7A46B0006; Wed, 10 Apr 2019 21:35:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBFC16B0007; Wed, 10 Apr 2019 21:35:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA9696B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:35:42 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w124so3690927qkb.12
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:35:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=rQf4zwsfnCSSf3OBXv6d9238qkoNFZ1PhFX05pcE+KE=;
        b=Vvv5X5VBHKx8zVFD7kD7JzB01to9h8slJhLlfVIK20t+SIhPkBxZonww6oFdll4tFO
         ShBndR3NuRhh5poxJQEJoqIzHyzGdYheP4xGIH6LSyPTZrrqn0/6xYLCcQPm1aeHNpEV
         7WGNf1fH+cHa/AxiQ4REz44t7UiJzTScrpvP8tYOnMIH3ZHnrcL1edreqNJlEiwh8KQ5
         WlTnbiqJ6dwMqZWdEZV0ohu78Ri1R/3hp8HH6FvNI993VALG1O07Kzfnp1v5XYc5OK5h
         wOk53EID0tajQF69E3AHrLpP/aVCeiJoHRGE3gMbwId/EwIQnFQOm1UpHS1ASC6hJW1O
         WemQ==
X-Gm-Message-State: APjAAAUfFt+eFv+i9cccpQ7KxX62ZOzT/0/g/QBIAsGsxz06LKRpCPMP
	4zPLkVUWD1pFpxZ+0YNeiAZNLaJZjRwnWPnZKVAIcwW8zlzybA7/RMKvqe3oD0Xl5NUDnoT1yvd
	GPgFsBmmKLSuX6iEtUKjNUgvBJqAwYN7TOv5zN/KAP7c7yPA6jd2WP10HPvImd8c=
X-Received: by 2002:ac8:2f98:: with SMTP id l24mr39062981qta.261.1554946542429;
        Wed, 10 Apr 2019 18:35:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysKxz/P4n02nW7wVZjl1z0R2BpXchPgxmsf1912KnZrqn8C4C78FlVCg3y3BubZQRzindL
X-Received: by 2002:ac8:2f98:: with SMTP id l24mr39062920qta.261.1554946540923;
        Wed, 10 Apr 2019 18:35:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946540; cv=none;
        d=google.com; s=arc-20160816;
        b=dKsqKq/FWsihkm0Nl2C+2vBmLkM4AjGi+eKXs693roMteDDkQwwhnT+rCmSBsMormc
         TojgNlRH4VsutXEGf0RTh2wH6tRllNUAOeb+EEOJzRdj57EsCyg3EPDZ1SNnqAp5TBov
         qqWKHxFISNVVpc4OTm5g0kS3OUHIYB1aoDft5R6TLaYB//ULorz0YMyQNsC1ZiuUu3KI
         MqEZnsJaA5M8s3CTI2q2ryDPy9cmgE/jID0S1W/xxhrZe4DlGrmTbP6ff5BQKks04dfp
         4iCNqQX0ZHOm1iHxbjo2RSm9Y4kD+csDbFgjfhlxhTzLuxQ26GtZd67JH4Oj7SGUQg03
         Vs9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=rQf4zwsfnCSSf3OBXv6d9238qkoNFZ1PhFX05pcE+KE=;
        b=PNMqzJdAjNdV9ueG9izMNLFsl2t6LYL39DT/MSl6AX3zINvAbhd74deaaw8ZjQqT0y
         k4cmHJhB1f9+vtks7zDWAjijvf4N09qYQeLeKd8uetRL2fSXi0Rk6X6O6JX1YLWsNVnw
         eTwsDDclK/MkbZfBpBoyeN2wGjNKa6DXw1Wg+4dcvcNXeKps5IqcwhsOdht9Tey56Aai
         FtmmrA+W+GI/RELQSklK2diyV3zMLDsN6aNuuDJdgtSNbSupCGA4zMPSdqxZnui54T3L
         423CR9PvHwJaAuUZnsRFdtVqSXr71ls9fDDthXoh4apz6VIsP6ZWsGPHpLERCho571XR
         T6dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=L289Jprq;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id d43si1767119qve.150.2019.04.10.18.35.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:35:40 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=L289Jprq;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 9285413D7F;
	Wed, 10 Apr 2019 21:35:40 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:35:40 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=rQf4zwsfnCSSf3OBX
	v6d9238qkoNFZ1PhFX05pcE+KE=; b=L289Jprqg9xt7pBLCD/lry8TD+HTFgERS
	T/2dxrgPnD9PE0kpTD7CWgWyRB57ozSNbx01SepmvLvNhVSUAaApOdqAulFd5LeR
	HxM62e1eVNPOogozsO80LyZCxUa+c+QgtlCck9JR/ZVogIFG48WW8nOCeI5wpZGW
	z2GtlEutZpX/vej7K2oWNbnuYxs9lB8Jm5/KdvsQ2VsyaClh/7B1n1/BJlYu9EoU
	ABMRDIv6wlgzpwN+NZUWtjxjXv/0GCJSz7mfDvAnkxf0nfF3MY/0RZJfalOC4iWf
	MDmwov4cEs3yV6v2AI3JDXpmedBNUt4WizPprTlfp54eSCmanz7qA==
X-ME-Sender: <xms:6pmuXH8DZOQmgswxL9Ptbyur3HsK2YzRXYHaG7GZpSAl5wm41Mk-Rw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhnucev
    rdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucffohhmrg
    hinhepkhgvrhhnvghlrdhorhhgnecukfhppeduvdegrddujedurdduledrudelgeenucfr
    rghrrghmpehmrghilhhfrhhomhepthhosghinheskhgvrhhnvghlrdhorhhgnecuvehluh
    hsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:6pmuXLcamF3_OA_bpi8ISNaHLeDG46dpQ8_mF3mCGPDzx8DQXEZNBA>
    <xmx:6pmuXIFF2T60Akxn9lXaRmvhQNmt5iH4ps9qdvDrKrYyXaFmbvIjOg>
    <xmx:6pmuXBf_cfJ30SlWLYDYB4KAWi_bRHiX5nHctcD92zldzzOEvJ4Rzw>
    <xmx:7JmuXIC8B8hcYM7LbU53A9H_JtyhJeVKlgZtan7DCrZnOMJ3jmctYw>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id E3B01E41C3;
	Wed, 10 Apr 2019 21:35:29 -0400 (EDT)
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
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v3 00/15] Slab Movable Objects (SMO)
Date: Thu, 11 Apr 2019 11:34:26 +1000
Message-Id: <20190411013441.5415-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Another iteration of the SMO patch set implementing suggestions from Al
and Willy on the last version as well as some feedback from comments on
the recent LWN article.

Applies on top of Linus' tree (tag: v5.1-rc4).

This is a patch set implementing movable objects within the SLUB
allocator.  This is work based on Christopher Lameter's patch set:

 https://lore.kernel.org/patchwork/project/lkml/list/?series=377335

The original code logic is from that set and implemented by Christopher.
Clean up, refactoring, documentation, and additional features by myself.
Responsibility for any bugs remaining falls solely with myself.

Patch #9 has changes to the XArray migration function as suggested by
Matthew, thank you.

The only other changes to this version are to the dcache code.

dcache
------

It was noted on LWN that calling the dcache migration function
'd_migrate' is a misnomer because we are _not_ trying to migrate the
dentry objects but rather only free them.  As noted by Al dentry (and
inode) objects are inherently not relocatable.  What we are trying to
achieve here is, rather, to attempt to free a select group of dentry
objects.  The dcache patches are not intended to be a silver bullet
fixing all fragmentation within the dentry slab cache.  Instead we are
trying to make a non-invasive attempt at freeing up pages sparsely used
by the dentry slab cache.  This may be useful for a number of reasons
e.g. we _may_ be able to free a page that is stopping high order page
allocations.  This would be a useful capability.

Since this is only something that _may_ help the aim is to be
non-intrusive.  This version of the set adds a config option to
selectively build in the SMO stuff for the dcache.  Without this option
the only change this set makes to the dcache is adding a constructor.
With the constructor doing a spinlock_init() it is hoped this will at
best be a performance gain and at worst NOT be a performance reduction.
Benchmarking has found this to be the case, results are included below.

Patch #14 and #15 can be rolled into a single patch if #15 is found
favourable.

Changes since v2:

 - Improve the XArray migration function (thanks Matthew)
 - Fix the dcache constructor (thanks Alexander)
 - Rename the d_migrate function to d_partial_shrink (open to
   suggested improvement)
 - Totally re-write the dcache migration function based on schooling by Al


Thanks for looking at this,
Tobin.


=============================
dcache SMO patch benchmarking
=============================

Process
=======

We use 5.1-rc4 as the baseline.  We benchmark the SMO patchset with
and without CONFIG_DCACHE_SMO.  SMO patch set without CONFIG_DCACHE_SMO
just adds a constructor to the dcache, no other code added to the build.
Building with CONFIG_DCACHE_SMO adds code to enable object migration for
the dcache.

cmd = `time find / -name fname-no-exist`
drop_caches = `cat 2 > /proc/sys/vm/drop_caches`

1. Boot system
2. Run $cmd
3. Run $drop_caches
4. Run $cmd


Bare metal results
------------------

Machine: x86_64
Kernel configured with::

	make defconfig


- rc4 kernel (baseline)::

	time find / -name fname-no-exist dentry 

	real	0m29.799s
	user	0m1.519s
	sys	0m10.825s

	echo 2 > /proc/sys/vm/drop_caches 

	time find / -name fname-no-exist dentry 

	real	0m6.828s
	user	0m0.952s
	sys	0m5.824s


- rc4 kernel with SMO patch set and !CONFIG_DCACHE_SMO::

	time find / -name fname-no-exist

	real	0m30.075s
	user	0m1.480s
	sys	0m10.754s

	echo 2 > /proc/sys/vm/drop_caches 
	time find / -name fname-no-existproc/sys/vm/drop_caches 

	real	0m6.626s
	user	0m0.917s
	sys	0m5.661s


- rc4 kernel with SMO patch set and CONFIG_DCACHE_SMO::

	time find / -name fname-no-exist dentry 

	real	0m30.637s
	user	0m1.516s
	sys	0m11.603s

	echo 2 > /proc/sys/vm/drop_caches 

	time find / -name fname-no-exist dentry 

	real	0m6.886s
	user	0m0.932s
	sys	0m5.907s


Qemu results
------------

Host machine: x86_64

Qemu kernel configured with::

	make defconfig
	make kvmconfig

Qemu invoked with::

    qemu-system-x86_64 \
      -enable-kvm \
      -m 4G \
      -hda arch.qcow \
      -kernel $kernel \
      -serial stdio \
      -display none" \
      -append 'root=/dev/sda1 console=ttyS0 rw'

- rc4 kernel (baseline)::

	time find / -name fname-no-exist

	real	0m0.929s
	user	0m0.096s
	sys	0m0.168s

	echo 2 > /proc/sys/vm/drop_caches 
	time find / -name fname-no-exist

	real	0m0.249s
	user	0m0.112s
	sys	0m0.133s

- rc4 kernel with SMO patch set and !CONFIG_DCACHE_SMO::

	time find / -name fname-no-exist

	real	0m1.018s
	user	0m0.095s
	sys	0m0.151s

	echo 2 > /proc/sys/vm/drop_caches 
	time find / -name fname-no-exist

	real	0m0.191s
	user	0m0.083s
	sys	0m0.105s


- rc4 kernel with SMO patch set and CONFIG_DCACHE_SMO::

	time find / -name fname-no-exist

	real	0m0.763s
	user	0m0.091s
	sys	0m0.165s

	echo 2 > /proc/sys/vm/drop_caches 
	time find / -name fname-no-exist

	real	0m0.192s
	user	0m0.062s
	sys	0m0.126s


I am not very experienced with benchmarking, if this is grossly
incorrect please do not hesitate to yell at me.  Any suggestions on
more/better benchmarking most appreciated.

Thanks,
Tobin.


Tobin C. Harding (15):
  slub: Add isolate() and migrate() methods
  tools/vm/slabinfo: Add support for -C and -M options
  slub: Sort slab cache list
  slub: Slab defrag core
  tools/vm/slabinfo: Add remote node defrag ratio output
  tools/vm/slabinfo: Add defrag_used_ratio output
  tools/testing/slab: Add object migration test module
  tools/testing/slab: Add object migration test suite
  xarray: Implement migration function for objects
  tools/testing/slab: Add XArray movable objects tests
  slub: Enable moving objects to/from specific nodes
  slub: Enable balancing slabs across nodes
  dcache: Provide a dentry constructor
  dcache: Implement partial shrink via Slab Movable Objects
  dcache: Add CONFIG_DCACHE_SMO

 Documentation/ABI/testing/sysfs-kernel-slab |  14 +
 fs/dcache.c                                 | 106 ++-
 include/linux/slab.h                        |  71 ++
 include/linux/slub_def.h                    |  10 +
 lib/radix-tree.c                            |  13 +
 lib/xarray.c                                |  49 ++
 mm/Kconfig                                  |  14 +
 mm/slab_common.c                            |   2 +-
 mm/slub.c                                   | 819 ++++++++++++++++++--
 tools/testing/slab/Makefile                 |  10 +
 tools/testing/slab/slub_defrag.c            | 567 ++++++++++++++
 tools/testing/slab/slub_defrag.py           | 451 +++++++++++
 tools/testing/slab/slub_defrag_xarray.c     | 211 +++++
 tools/vm/slabinfo.c                         |  51 +-
 14 files changed, 2295 insertions(+), 93 deletions(-)
 create mode 100644 tools/testing/slab/Makefile
 create mode 100644 tools/testing/slab/slub_defrag.c
 create mode 100755 tools/testing/slab/slub_defrag.py
 create mode 100644 tools/testing/slab/slub_defrag_xarray.c

-- 
2.21.0

