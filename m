Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62CC3C10F00
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 03:31:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21AA72087C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 03:31:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="4h6GGvxj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21AA72087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9211E6B0003; Mon,  1 Apr 2019 23:31:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CEED6B0005; Mon,  1 Apr 2019 23:31:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E6126B0007; Mon,  1 Apr 2019 23:31:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 609AC6B0003
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 23:31:14 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id w124so10365543qkb.12
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 20:31:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=GhdVsMTVKjBk9iUxn5IpYnUVsn7WlgpvFL7kEcghYa8=;
        b=ijEYS0E/Z6vfqnS+kiBQjMz6yzJsSFFtunoIQPxDCQl77eEEyWbbY9la/HN5b9vbzo
         yax1uEcMrCvB2PdjksGU84RA5g9qQwufHJQnQ8EpVnWk4mMWIVQ5lDo0IwFeAiSVHKPL
         uipMRT6BsKUphIvLlS3hCLt+IYKwKgEpLbKzqc/m8PNGqn332OxqeFKfQopH4iu3Zv/g
         GQres0ipGgwWUWvGAcqhWwgOnzdT+CaLILDL9IsNx4czyPyHyGkJLhk4rgjHdkAMx5tE
         5k64DETHJZdzE464ikfbbOmLYD0CZANN6YpZm/k0nYhyZFV1WPNrbWiw7vmaEt7LDr38
         LeCA==
X-Gm-Message-State: APjAAAV+HuIjcdUBljHOrS1dkegIBeKAnCdMAmow5hgrZB6/vzC0ZKcj
	fUozmQvGmQPy8Z3Iq88MFXkhh9fLWZ2/p56Ql2hngmq75hJNaGuBTcICFvuID7QQx3ixnfZaS4v
	5gIVoGNi1drnvAI2WI/UInerNQbaHu+0Ee2yAyno9iyuTR/lTGRMpcPoooYfhq/k=
X-Received: by 2002:a37:a34a:: with SMTP id m71mr31611825qke.323.1554175874012;
        Mon, 01 Apr 2019 20:31:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6Hrcd2opTRGS68Hg0oXxIij68S+6/NwWOPTP/ADnRx1VOf+Kp16w4WuTa4Bda+F6QsXF3
X-Received: by 2002:a37:a34a:: with SMTP id m71mr31611779qke.323.1554175873135;
        Mon, 01 Apr 2019 20:31:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554175873; cv=none;
        d=google.com; s=arc-20160816;
        b=abX+caBfIgb/lcnvWlVLXs3lj7mf9bimjxuigY1TxNxHVfoB7k8bAH+GUK6M4x+z4W
         NDznip4MtHziFMo6WRxCRNp0UwYXdnSp5bYl8EpJr8U204hZSNQSxKE8HHUOgTWVvS7J
         r0gDKWe5c2zvhQLeqJexawt2yek/POTxxFMhmIWWy3eid4da3BExW439CJ7KZnodRiGh
         SDgNSphR7vmPr7l8jmbJwq8G6/6hgaL3sz57ew77f5gyfim9a/C/DXVqXQX1ceeZHB9V
         Bjd4rC8VgZFFzA3HVm+zZB8Fzo8EWg8rIXjYLzq+bBEw/HJXvYzZj1VmEWaCyuyWDGYD
         GwNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=GhdVsMTVKjBk9iUxn5IpYnUVsn7WlgpvFL7kEcghYa8=;
        b=mrWGmG7bV5naa4WGNnVttiL+Rfwf0jhbV135HzE1QSk+T3b90fCV4JCrsmx0JiQhxY
         p5yYhHQ9Zjl0oqMvSK1LBsGT/Iu/PsZ4msgl8Rmtp3LJRKUNSzjq97KAWZtpd8luI0An
         ZaHRkiRfF1I3DiY0CUAhlNiYPdj+4TlyygMDmcK2vmUV6L7X073PgKuATmndwVve1x+b
         yLagb6F1lWtwITGSLZoRf7knX4FwiQEjjiSbSkEY7KHCnWGEIhwgCFaImHHyWzgIXirc
         9H6Ff/NqOeeHUehWABv9HGkx8QEfXpmk0pqga0Ji4dOZ1azzzC76MuYjbX8Mkhe+Rlp4
         3oUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4h6GGvxj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id i6si1640681qvj.31.2019.04.01.20.31.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 20:31:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4h6GGvxj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id A7F3E22205;
	Mon,  1 Apr 2019 23:31:12 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 01 Apr 2019 23:31:12 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=GhdVsMTVKjBk9iUxn
	5IpYnUVsn7WlgpvFL7kEcghYa8=; b=4h6GGvxjAduskW8z2+xkvHUDonHLeaxzo
	OpdND1moNstvSCB3U3UdLmRHXe652TX2LIbSCHBSSeU2QHfoPUnDpE/SYUUWHrju
	W4n+KQ8A8O9eQCbep+ok5OoWGoIRWpbjYMHH/DgckHggOrlWn80KS/F77ZkwFSE8
	qwu6spWnxPpVn+Y3rSjZsqBrCwJaBQBm2h/lUw0WXJ0MZGBYH43tKJ+g13TezuSN
	9G3nOBLFdSlM+BpaDnGL5yRbumtwrw7id36ZWRmKDMuHLJRyeGfnRyWFbrGaHhzO
	D8XKDA3g/TzeQZqMTyKCU05fKaIMBrbi9XLTMsgpKTGE4is3wPx5g==
X-ME-Sender: <xms:fteiXAjnNz3kCdhLz_BNzY1vJkrn2ex_iR3UDTk_kTdj153i9WeFIg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrleehgdeikecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhnucev
    rdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucffohhmrg
    hinhepghhithhhuhgsrdgtohhmpdhoiihlrggsshdrohhrghenucfkphepuddvgedrudej
    uddrvdefrdduvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgsihhnsehkvghrnh
    gvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:fteiXPEdeXrUl6-EIAHSsIYBBfSJGzp32qnEMy0YjngnrfonQJ_G1A>
    <xmx:fteiXLWmLQ_UGez3uQT65pc1rGihfbjIIHgdKhTxYSFQzRc-MVpEYA>
    <xmx:fteiXJYwuU6SQ9oBX_iQqk506dpLynTdOZh4bH6rWD2AxjmALkLW6w>
    <xmx:gNeiXMWpmRg18hyrF_R-xsScykLtThsdIv0Pn3YCaKvtUWsow9nZOQ>
Received: from eros.localdomain (124-171-23-122.dyn.iinet.net.au [124.171.23.122])
	by mail.messagingengine.com (Postfix) with ESMTPA id CD8B710390;
	Mon,  1 Apr 2019 23:31:06 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	LKP <lkp@01.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 0/1] slob: Fix list_head bug during allocation
Date: Tue,  2 Apr 2019 14:29:56 +1100
Message-Id: <20190402032957.26249-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

This patch is in response to an email from the 0day kernel test robot
subject:

  340d3d6178 ("mm/slob.c: respect list_head abstraction layer"):  kernel BUG at lib/list_debug.c:31!


This patch applies on top of linux-next tag: next-20190401

It fixes a patch that was merged recently into mm:

  The patch titled
       Subject: mm/slob.c: respect list_head abstraction layer
  has been added to the -mm tree.  Its filename is
       slob-respect-list_head-abstraction-layer.patch
  
  This patch should soon appear at
      http://ozlabs.org/~akpm/mmots/broken-out/slob-respect-list_head-abstraction-layer.patch
  and later at
      http://ozlabs.org/~akpm/mmotm/broken-out/slob-respect-list_head-abstraction-layer.patch


If reverting is easier than patching I can re-work this into another
version of the original (buggy) patch set which was the series:

  [PATCH 0/4] mm: Use slab_list list_head instead of lru

Please don't be afraid to give a firm response.  I'm new to mm and I'd
like to not be a nuisance if I can manage it ;)  I'd also like to fix
this in a way that makes your day as easy as possible.


The 0day kernel test robot found a bug in the slob allocator caused by a
patch from me recently merged into the mm tree.  This is the first time
the 0day has found a bug in already merged code of mine so I do not know
the exact protocol in regards to linking the fix with the report,
patching, reverting etc.

I was unable to reproduce the crash, I tried building with the config
attached to the email above but the kernel booted fine for me in Qemu.

So I re-worked the module originally used for testing, it can be found
here:

	https://github.com/tcharding/ktest/tree/master/list_head

From this I think the list.h code added prior to the buggy patch is
ok.

Next I tried to find the bug just using my eyes.  This patch is the
result.  Unfortunately I can not understand why this bug was not
triggered _before_ I originally patched it.  Perhaps I'm not juggling
all the state perfectly in my head.  Anyways, this patch stops and code
calling list manipulation functions if the slab_list page member has
been modified during allocation.

The code in question revolves around an optimisation aimed at preventing
fragmentation at the start of a slab due to the first fit nature of the
allocation algorithm.

Full explanation is in the commit log for the patch, the short version
is; skip optimisation if page list is modified, this only occurs when an
allocation completely fills the slab and in this case the optimisation
is unnecessary since we have not fragmented the slab by this allocation.

This is more than just a bug fix, it significantly reduces the
complexity of the function while still fixing the reason for originally
touching this code (violation of list_head abstraction).

The only testing I've done is to build and boot a kernel in Qemu (with
CONFIG_LIST_DEBUG and CONFIG_SLOB) enabled).  However, as mentioned,
this method of testing did _not_ reproduce the 0day crash so if there
are better suggestions on how I should test these I'm happy to do so.

thanks,
Tobin.


Tobin C. Harding (1):
  slob: Only use list functions when safe to do so

 mm/slob.c | 50 ++++++++++++++++++++++++++++++--------------------
 1 file changed, 30 insertions(+), 20 deletions(-)

-- 
2.21.0

