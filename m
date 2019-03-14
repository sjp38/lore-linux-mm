Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC136C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F7FC2186A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="nXFyTnSv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F7FC2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B2428E0003; Thu, 14 Mar 2019 01:32:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93A248E0001; Thu, 14 Mar 2019 01:32:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 802558E0003; Thu, 14 Mar 2019 01:32:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 538758E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:32:09 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id i21so4300776qtq.6
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:32:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=0As+3Iv3Sxmfep8uKsH5/xjkJPw9kSFzNL2pVLlfV7o=;
        b=YGpQZxFXtNS7ihpqQP44kTlfR4Y4ZILqJ4kKA/1fdsCwSKod7idx5SMkfgsaTudZLU
         Aa2yfb5fTiPphK/5dKh9RavC0No1I34uRNh+gj+w6gFeijfrhX1Elo8QsoucFPHHOdXv
         9ICrCLtpxEulGXM9vJemTtsQ/Xy2vdNJe5BrzV7fCYIgnd4Czu/e4xwLfhoRFdYXyxQ1
         zTjQHl8/3dDhPRs35iwjBG0GqeZp4Bhd6FLjMp0eKV7nOjeoEIUhgumQO7n8wwF3r8oX
         bEgDrsBLSsCNoelwSZCmUDEklTiIaE3QjVih/b4ck7RaJ26Bx8gfQbY1CzxTpZPqIxnx
         z1nA==
X-Gm-Message-State: APjAAAXOJ2dpu1LnwyKYncvbNqU77u499e4KvuWqMH6X25zwtb+C0x8D
	UjYAU6abz/VM61bNuyXVyLodZjH5CP8ZY73g8b5PFjSoBWxBIWNN2+c5j4KhBdJfBReledr8u1/
	qWJp2jW+XaFfAdfRd7c3147qMxvHVYrOMr7lfvRqfbLV03r/r8fmg5Ur0lgRZ3Tc=
X-Received: by 2002:ac8:96c:: with SMTP id z41mr36908117qth.305.1552541529058;
        Wed, 13 Mar 2019 22:32:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTZTnWzq2VF3oSXEOY0wWmdQ48MS0iFAecC7BGG2kKj6Tl5UajGGqdZFKi1IbM1I57YkHV
X-Received: by 2002:ac8:96c:: with SMTP id z41mr36908076qth.305.1552541528062;
        Wed, 13 Mar 2019 22:32:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552541528; cv=none;
        d=google.com; s=arc-20160816;
        b=zeBKSbjQVThYbE/2jPcvHDFH4nszDTimGJPXtwZeKBu+ZaHF2NuoGQm0S05e6YNsdf
         +qmzj7TliuHCQa8SQLPjk29XoAbkew20TcUOFKFfN4fMfGhvmGslCay83rbuVDoYGwHn
         6wGPMP1EEPBnTaUHiNMXhn99cM3ecXBowKc/UxUvhjO6My6sh2zuq8M8P3hAOwbSF7+W
         m+OzxmWc/+lfitmKyQM2rjt0XpHnmerW2uBGIAooeUSEZfvHpabcuUQDcu7EOJ4LzOkL
         0KeYWOeFJrj9XKj8OwpPB91qOtUCxVmjkA5B5xXfJfreo3b4ywghTvfl9ZbomgVQe9uA
         +qiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=0As+3Iv3Sxmfep8uKsH5/xjkJPw9kSFzNL2pVLlfV7o=;
        b=cE0kt2p3CK1TmysT6oylNOZPImgJJfeHqMgkUtkPkNaR01mLapqRgfjkJnu9eKxOUV
         AhcMLroj0ccZh+6llkfBFzohLI+hhTixAtbMnHhSox6l4Ccx7UZo3DI2dukRqRgbrQZW
         hw2eoNkYgHZInMiGGu0nOzrEd939ANez9hA2x86jIGG35wO/N0tEaaS2VxQr98TEam3b
         3gOyWD4qIcwWeDvjifw580wa3w1Rf1zg2OV9qHXNztlHi2nLp/yFpTxiqPzaqYY0XkJX
         mNsK8wePGcDLm/Um2v8h0ipl5HBw22bmomIRT5dk5x0TLftiyeN4JhHXKEDyzn9vCEhN
         YXNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=nXFyTnSv;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id k46si1208609qvf.84.2019.03.13.22.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 22:32:07 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=nXFyTnSv;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id A6DAC213BD;
	Thu, 14 Mar 2019 01:32:07 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 14 Mar 2019 01:32:07 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=0As+3Iv3Sxmfep8uK
	sH5/xjkJPw9kSFzNL2pVLlfV7o=; b=nXFyTnSvQ0TXZ5esZxcjU2Z6vcxxfwqmZ
	e4QC8rQzhDCWT/uGYUgxLo6y3GTtFjjfIX6REQiGEwetHoG7K6qpJy1yQZhimGet
	mZO2iZOBRIS+PPIJRbT3m6YK8hFi+CJpaeUcylBhAwk/6rnso8WU1BItuOQ1e6O+
	9u+TU1WG8GYWePLEVSkHO0yaPn+ZThhTTymCL4XaNdJPXo2c+aJbV4oga2ob1U2q
	SfDI7JCRjkWv5mITQHY1+6r4543vxEfIpu9ezTDGcqISFFP3sAHfTjkNsSNqFwZG
	Yx3+KWjweqOMK4G+cfiRZnG+1+xrV0/SG013bqPbQuMtUVk0sRYrQ==
X-ME-Sender: <xms:VOeJXHEmVIIZEg4WNbm1bwpqsXP7F_zvMVSMBPANGfqoBUhfCZ6C0Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrhedugdekgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhnucev
    rdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucffohhmrg
    hinhepghhithhhuhgsrdgtohhmnecukfhppeduvdegrdduieelrddvfedrudekgeenucfr
    rghrrghmpehmrghilhhfrhhomhepthhosghinheskhgvrhhnvghlrdhorhhgnecuvehluh
    hsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:VOeJXN7bV-NvEfa9PkjGrsxsR6vy6e2L8bCLt8lp-0_uOs1oQnYvhQ>
    <xmx:VOeJXEn0Js7yIQgnKaP9ROa3OkngZgF7A6j-8irY3qWjKcVGHw4asw>
    <xmx:VOeJXDzavEaLvm7GKBafZ9D1vpwCUH1yhpFVCR2OPo0DVHAU6wUCtA>
    <xmx:V-eJXGbXgXRLTn8NSz_s3BVNmYx-JZLhuYN3xvjddjiZfER7ZEhEXg>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 811BCE415C;
	Thu, 14 Mar 2019 01:32:00 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 0/7] mm: Use slab_list list_head instead of lru
Date: Thu, 14 Mar 2019 16:31:28 +1100
Message-Id: <20190314053135.1541-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently the slab allocators (ab)use the struct page 'lru' list_head.
We have a list head for slab allocators to use, 'slab_list'.

During v2 it was noted by Christoph that the SLOB allocator was reaching
into a list_head, this version adds 2 patches to the front of the set to
fix that.

Clean up all three allocators by using the 'slab_list' list_head instead
of overloading the 'lru' list_head.

Patch 1 - Adds a function to rotate a list to a specified entry.

Patch 2 - Removes the code that reaches into list_head and instead uses
	  the list_head API including the newly defined function.

Patches 3-7 are unchanged from v3

Patch 3 (v2: patch 4) - Changes the SLOB allocator to use slab_list
      	     	      	instead of lru.

Patch 4 (v2: patch 1) - Makes no code changes, adds comments to #endif
      	     	      	statements.

Patch 5 (v2: patch 2) - Use slab_list instead of lru for SLUB allocator.

Patch 6 (v2: patch 3) - Use slab_list instead of lru for SLAB allocator.

Patch 7 (v2: patch 5) - Removes the now stale comment in the page struct
      	     	      	definition.

During v2 development patches were checked to see if the object file
before and after was identical.  Clearly this will no longer be possible
for mm/slob.o, however this work is still of use to validate the
change from lru -> slab_list.

Patch 1 was tested with a module (creates and populates a list then
calls list_rotate_to_front() and verifies new order):

      https://github.com/tcharding/ktest/tree/master/list_head

Patch 2 was tested with another module that does some basic slab
allocation and freeing to a newly created slab cache:

	https://github.com/tcharding/ktest/tree/master/slab

Tested on a kernel with this in the config:

	CONFIG_SLOB=y
	CONFIG_SLAB_MERGE_DEFAULT=y


Changes since v2:

 - Add list_rotate_to_front().
 - Fix slob to use list_head API.
 - Re-order patches to put the list.h changes up front.
 - Add acks from Christoph.

Changes since v1:

 - Verify object files are the same before and after the patch set is
   applied (suggested by Matthew).
 - Add extra explanation to the commit logs explaining why these changes
   are safe to make (suggested by Roman).
 - Remove stale comment (thanks Willy).

thanks,
Tobin.


Tobin C. Harding (7):
  list: Add function list_rotate_to_front()
  slob: Respect list_head abstraction layer
  slob: Use slab_list instead of lru
  slub: Add comments to endif pre-processor macros
  slub: Use slab_list instead of lru
  slab: Use slab_list instead of lru
  mm: Remove stale comment from page struct

 include/linux/list.h     | 18 ++++++++++++
 include/linux/mm_types.h |  2 +-
 mm/slab.c                | 49 ++++++++++++++++----------------
 mm/slob.c                | 32 +++++++++++++--------
 mm/slub.c                | 60 ++++++++++++++++++++--------------------
 5 files changed, 94 insertions(+), 67 deletions(-)

-- 
2.21.0

