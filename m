Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 081C4C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:41:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C4FE20851
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:41:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="rdmJSE8h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C4FE20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 312E96B0005; Mon, 20 May 2019 01:41:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C3726B0006; Mon, 20 May 2019 01:41:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B33E6B0007; Mon, 20 May 2019 01:41:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFBA16B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:41:14 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id c54so13204042qtc.14
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:41:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=0r/Sn1Y0gO0Oyf6yWSFKUDRK3ejus11HRZy7eGnGflw=;
        b=n29ad84oPyh4nqvbsBt+E4U7RF0IJCt1UkC4H+TdC72UC0E7VFpYI3HxQrNP27Hf9u
         Aou7CFGurF3qC+GteVBtvGXBlJPM4G4+Ibc0azqIQaF4XoUXdloW7U8n2hT3VNxG9XNK
         8UUUfUEmKKYuCokTxVoqfCs+bR1h1L516EsyhZ8r6/JDmQDpyhWCnSxv11VoEqbY4JL7
         kqjkdhhKX0senvPB7kbo0XpCxkwZo2XrW/VY7Omp4ZyY/fcMm2fScBk+TdKuRfcTkrJD
         KgWmoaFxfqT2qr4wHb3gK43znhXLM5gAO4H6ScNYwkMDSW5JwMv4sm8Gi1i6dSAZ6bq0
         A+mA==
X-Gm-Message-State: APjAAAXsg7tCc6YR7s450S7h7MpzZk6PR4qrt0u7IW9PZhztv7GjJMfs
	aPZzDuKwy3ONGcrIcFGGN1PDwd7eEJtLGqjtxA1I7O9sG70uBzi7GlWXTAu2D4XXPG/2gk16ZBN
	A2a7K1jGxi9BqCKEZiCoVeFo6N5T7L3YPl3++2iXyfUfOiHWP3huAuO9aRlqEMNg=
X-Received: by 2002:a0c:eb8f:: with SMTP id x15mr27164863qvo.156.1558330874581;
        Sun, 19 May 2019 22:41:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfk+P1ag/d6SICCZmMfZrdrVRYWFf6xL4Qb5NpMu4hphwRHNRlvvNjms3kzHxmA/xPXK7I
X-Received: by 2002:a0c:eb8f:: with SMTP id x15mr27164829qvo.156.1558330873908;
        Sun, 19 May 2019 22:41:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330873; cv=none;
        d=google.com; s=arc-20160816;
        b=suDGUKCdVe2TgDQjx7JPILhbcVHIeEnyyNSbnstqw+nqn8CNR6WJWYWUbUEMPwOeBx
         PvLkn3CQhTNTxMWEVlRtr26+DZcroEGTd8K+mjGX+VIVAZJw0u0Ao5jn99DZA6+2UrMM
         mmHHjwN3XFLhxv4AlTxnyc56P+ur71cZhfg1VDos/Ofi9Nphzfpb60EJKZEvFG1fjTAd
         yKmaL4h2g56rGiN2I4OvyVzRATJ35a3OrgsZUqzPidtNQeZ6Wf8pfsVDDImTRuRnwR3h
         9uveB9vWUdLh3Eu70v2pHsDjDDBOiAO8dMsqPIsuAWhm/WEs/UUpDH2J5FZunBnM4+6/
         sffw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=0r/Sn1Y0gO0Oyf6yWSFKUDRK3ejus11HRZy7eGnGflw=;
        b=FMN+cmBNBPP4F4VT336aztNtZUYZFWeFPTAjtAuPBo0SMNpZQ9sOVYjLMVk27H4/O9
         +TEJkF8KNZo4O9fLg/tijh/gc69wU9ywH+8+TJ9KqNCtKhKxgao+Ook2N4V+6OUb0bXs
         sXpPRMVb39W2eUVyqZcv7VjuBjxd9vH3NYPtGjr75UjWbyCvITvwptCM1ci2E6PlLMo3
         BYeFqabmLumlzaz0I6jOZ2YZWxlY4Bd4knLY3Ji25zoB0ygKXP5h2+UKoSW6VZC08XzK
         1KJeIu62TQUgrmPobn2kvzg/xg0h1df5XOl96zI+SxxlQ1xiKWIJXD9FxHc3u2NCNPHP
         N1rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=rdmJSE8h;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id h20si1201175qkg.262.2019.05.19.22.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:41:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=rdmJSE8h;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 5EE8240D7;
	Mon, 20 May 2019 01:41:13 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:41:13 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=0r/Sn1Y0gO0Oyf6yW
	SFKUDRK3ejus11HRZy7eGnGflw=; b=rdmJSE8h9XyUOGAIv/XSalLdgxvzqP7Zs
	qzNQ2b2J62DI0tLAstwp0mU/KAivM79ira4ir6eU9aE1T0v4V1+hZBza6J95Yrr6
	fch2eFMr84W3Q66XoiUTtficSc0IsxQdA/QOVd7meKJfNJwMhX+792bI5YbhuPvT
	aoMO/SDU7qc0THRuY+RFStolsfmr6bFC00L+Pm05Jbcwz34Mct9+6CTRAb36AQ8L
	e9FPLLGDtJMm1RXv3AGn9YVMZ4Y6tsVYlnqbCVHdP80DZrTJQ9/0ZIFsO0uODSHT
	nlkU5Mu+Wc/F+vHpy18HLHzP31r0fhvG0TCCRiGwxKURtYYBK/t8Q==
X-ME-Sender: <xms:9T3iXHLIt4vNmKYs0VNUf3XtYk2meotQ7mfiDUh6Jkd9d_B7QRoqIA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucffoh
    hmrghinhepkhgvrhhnvghlrdhorhhgnecukfhppeduvdegrdduieelrdduheeirddvtdef
    necurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenuc
    evlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:9T3iXCxHOeLs0Brh--rNvBlGvfP0gl1TFmfFykbobJzlrDeYdfnxqg>
    <xmx:9T3iXK4hgcnMZ3pVD3MYg7ejVQfn5Pevh06iZr3mDZzvk1OJ1kGLlg>
    <xmx:9T3iXKsQxmRfae1PKOqtD62SZIgSspcMsEg-nosXpSyaO7Lt8I7Lhg>
    <xmx:-T3iXARXSH-QbhMw9vVJXU1BmnRC9M8sTH4QG1AEFtiGYLH8faRhUg>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id 05EF080061;
	Mon, 20 May 2019 01:41:02 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>
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
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 00/16] Slab Movable Objects (SMO)
Date: Mon, 20 May 2019 15:40:01 +1000
Message-Id: <20190520054017.32299-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Another iteration of the SMO patch set, updates to this version are
restricted to the XArray patches (#9 and #10 and tested with module
implemented in #11).

Applies on top of Linus' tree (tag: v5.2-rc1).

This is a patch set implementing movable objects within the SLUB
allocator.  This is work based on Christopher Lameter's patch set:

 https://lore.kernel.org/patchwork/project/lkml/list/?series=377335

The original code logic is from that set and implemented by Christopher.
Clean up, refactoring, documentation, and additional features by myself.
Responsibility for any bugs remaining falls solely with myself.

I am intending on sending a non-RFC version soon after this one (if
XArray stuff is ok).  If anyone has any objects with SMO in general
please yell at me now.

Changes to this version:

Patch XArray to use a separate slab cache.  Currently the radix tree and
XArray use the same slab cache.  Radix tree nodes can not be moved but
XArray nodes can.

Matthew,

Does this fit in ok with your plans for the XArray and radix tree?  I
don't really like the function names used here or the init function name
(xarray_slabcache_init()).  If there is a better way to do this please
mercilessly correct me :)


Thanks for looking at this,
Tobin.


Tobin C. Harding (16):
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
  slub: Enable moving objects to/from specific nodes
  slub: Enable balancing slabs across nodes
  dcache: Provide a dentry constructor
  dcache: Implement partial shrink via Slab Movable Objects
  dcache: Add CONFIG_DCACHE_SMO

 Documentation/ABI/testing/sysfs-kernel-slab |  14 +
 fs/dcache.c                                 | 110 ++-
 include/linux/slab.h                        |  71 ++
 include/linux/slub_def.h                    |  10 +
 include/linux/xarray.h                      |   3 +
 init/main.c                                 |   2 +
 lib/radix-tree.c                            |   2 +-
 lib/xarray.c                                | 109 ++-
 mm/Kconfig                                  |  14 +
 mm/slab_common.c                            |   2 +-
 mm/slub.c                                   | 819 ++++++++++++++++++--
 tools/testing/slab/Makefile                 |  10 +
 tools/testing/slab/slub_defrag.c            | 567 ++++++++++++++
 tools/testing/slab/slub_defrag.py           | 451 +++++++++++
 tools/testing/slab/slub_defrag_xarray.c     | 211 +++++
 tools/vm/slabinfo.c                         |  51 +-
 16 files changed, 2343 insertions(+), 103 deletions(-)
 create mode 100644 tools/testing/slab/Makefile
 create mode 100644 tools/testing/slab/slub_defrag.c
 create mode 100755 tools/testing/slab/slub_defrag.py
 create mode 100644 tools/testing/slab/slub_defrag_xarray.c

-- 
2.21.0

