Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47371C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:27:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DDA82088F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:27:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="SV6OliWT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DDA82088F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 877206B0005; Thu, 25 Apr 2019 22:27:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 825036B0006; Thu, 25 Apr 2019 22:27:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EF0C6B0007; Thu, 25 Apr 2019 22:27:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE3A6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 22:27:25 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id w53so1604866qtj.22
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 19:27:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=y3yrDcJRK7dMxaYtTUWgba/vmU9ehGb7y7oYmTnnM9U=;
        b=dIZVs94KXFBpjKQEHwF0uTNLhL5rdhPhZsi4FDt8E7eAwTXZIgZFqCfBYcS7lyEtBI
         ULIzMTBDPbCIJMNi2bBJE5pk9V98l0LFtm6B7ZIuA1EOdBmlslJ7oGXbCScQbn1AJDqP
         txH2JX3KCWXlpgTbZ0TBcw2JHHq+FYtIiQYSWPcAjljp0Ba43nZ3A8nZmqc76ElWzKZl
         Ymdy8AgR/J80EntKBLukD3YD07N6VEwcFBLrTTnxglFz7vNwLZ6MgEOQe4VL9s4YX08k
         eJHG1L/bu2BzNsmErozwWCjRnsPdZ/WwOvJ+ftn0KfzyTQzccRpsuMovQr5y27sRJP7r
         RjSg==
X-Gm-Message-State: APjAAAW7WJi0zqpm1ccZIh0+NvqfLUNpuJhzvV2mDHFKpE6gri5VSLSe
	KcHlHVC1FrY0qihxRiFPxxPwjxxBbI5EQM3Li7Tz7R74RjxQCWVzA7c6ylYqZkylGCrqyrJUNBK
	5pB07wazlFAM0Z/LsprWLzDDDH63FPj+jnfK8weE3sgxAnxppj8iC9Y9Hy5Yr5Fw=
X-Received: by 2002:aed:39c6:: with SMTP id m64mr34740314qte.239.1556245645041;
        Thu, 25 Apr 2019 19:27:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKSsYoOYxhnk5m1Qw2WVvlTEyaUfmRg6ovdal+gmDXOlx0SFFdYV8TmwAN79syk1Bx7hrk
X-Received: by 2002:aed:39c6:: with SMTP id m64mr34740282qte.239.1556245644379;
        Thu, 25 Apr 2019 19:27:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556245644; cv=none;
        d=google.com; s=arc-20160816;
        b=d9bL7AwJy3Ble/yjOhaXkeaRAQcRgHwz+PBg3SQ7z3PVxWa/x1/eestSKDxxQGnWbl
         bI1pLuw3rvrHrcdkKMLda525xQCXRHsxh1kad/nt0vJ5U6CaIA4jQuOG4bTsWVb71pJm
         Zxgt7ZGdyt6NrbnlgAJ2YM3X3NwZQK/6Ni2B2Jyf1n89d2N3ak+TjP0zUla0XlDviDFf
         7lhtkw8rOTQOnezNhy0S2zfaKfSqzAt7UflOMd4maOHzc2JJLvKjLeIflkCpnjHw+3O1
         RCalctxojGKHvqohSMRljj/eZWiW5wMgp1SYamwCVlZfBuH+gwAa1sA8i3VyNqxErQ8x
         CIHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=y3yrDcJRK7dMxaYtTUWgba/vmU9ehGb7y7oYmTnnM9U=;
        b=by0k9HWjDp3n9pwCCMMA8D54dyZyMSq0F7XCU6TAyJr514rdlyQkzPvay4dUbHyqwz
         XaiqEguZuB4yyX9LJpmF0t+XY40pL9XOHUVdR1VqUf6zSZ0uSOUYcKU/FDD29/4BUTbY
         EInkjXkwerJsN7AKoMqVX27TMSh/Kax98ZB1Sjs1I8EUq4pSkWF4AeX/l7ZlESCUCpki
         ezxODN0PfZrAWy5hZq14MUDO+nnnc3R/kY8gq3F7930YYV/3SlmSs82AzJ3N/9H2paay
         XOp5ShcptkDxYOltSbxQ9S2L5yNVD0H0gXkxmSyjvaBdX3dI5Lp015pvJAb8GVzCBx7A
         flhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=SV6OliWT;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id y3si120259qth.188.2019.04.25.19.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 19:27:24 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=SV6OliWT;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id EAE73D691;
	Thu, 25 Apr 2019 22:27:23 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Thu, 25 Apr 2019 22:27:23 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=y3yrDcJRK7dMxaYtT
	UWgba/vmU9ehGb7y7oYmTnnM9U=; b=SV6OliWTD8ttZp1RKHuKAOf7Ie2IiJcuD
	80Sz9+UWyLhDoItwOSnOmhNh5uSF/mD+sMZ5HLZfFP5PpYqnGxDH+PiD2bKLJK2P
	hFfeUCVsW3F+DYTiI984IrTamwGKDo+udXQIoydexaXGIWJXapEamYTbVKRmhBWQ
	tQpKGwGq1zExtALbVIXa3n7HkckTY2bqYLl6bkrtktIdohEGS9TdVTk7pbD2V26u
	31FXqoHPvmvo03a0WkPGCyFP5QChLnJZErqGywEtKV71awoAVVBZU4LxJQqyats1
	74zCcsHocAJjSw/24f0L6j0icuQIIC4kpSF7XGDZoNJGEFJCL/GlA==
X-ME-Sender: <xms:iWzCXBWuDlemqmrv-oJTwjpHitqe_VxCH1SbcePYwD5rtRIWt7NPMg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrheehgdehlecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhnucev
    rdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkphepud
    dvgedrudeiledrudehledrvddutdenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:imzCXNqtAfCZ5stdQhcpR3kMY2_-S6gtPvrEYg1DkBiRnK_0HnwcBA>
    <xmx:imzCXIvXT110NsF9AqhlfKJ6_e5Qs1n8gXrKCHvlsiF-Dy6J3AoXsQ>
    <xmx:imzCXDQFNrldy5eBUSK5x8YW8U7FZemC7hoGzRmwE4H4dETTvnGUEA>
    <xmx:i2zCXI_1X8UNP05CrjKqpZQL1AcTRGo9FweuEcztJhvuqFuVj3U73A>
Received: from eros.localdomain (124-169-159-210.dyn.iinet.net.au [124.169.159.210])
	by mail.messagingengine.com (Postfix) with ESMTPA id AE2BE1037C;
	Thu, 25 Apr 2019 22:27:16 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Pekka Enberg <penberg@iki.fi>,
	Vlastimil Babka <vbabka@suse.cz>,
	Christoph Lameter <cl@linux.com>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Tejun Heo <tj@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Michal Hocko <mhocko@kernel.org>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 0/4] tools/vm/slabinfo: Add fragmentation output
Date: Fri, 26 Apr 2019 12:26:18 +1000
Message-Id: <20190426022622.4089-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

During recent discussion on LKML over SLAB vs SLUB it was suggested by
Jesper that it would be nice to have a tool to view the current
fragmentation of the slab allocators.  CC list for this set is taken
from that thread. 

For SLUB we have all the information for this already exposed by the
kernel and also we have a userspace tool for displaying this info:

	tools/vm/slabinfo.c

Extend slabinfo to improve the  fragmentation information by enabling
sorting of caches by number of partial slabs.

Also add cache list sorted in this manner to the output of `slabinfo -X`.

thanks,
Tobin.


Tobin C. Harding (4):
  tools/vm/slabinfo: Order command line options
  tools/vm/slabinfo: Add partial slab listing to -X
  tools/vm/slabinfo: Add option to sort by partial slabs
  tools/vm/slabinfo: Add sorting info to help menu

 tools/vm/slabinfo.c | 118 ++++++++++++++++++++++++++------------------
 1 file changed, 70 insertions(+), 48 deletions(-)

-- 
2.21.0

