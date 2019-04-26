Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65967C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:27:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21B9D206BF
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:27:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="qXdtKMep"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21B9D206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A97E36B000D; Thu, 25 Apr 2019 22:27:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A47D06B000E; Thu, 25 Apr 2019 22:27:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9105A6B0010; Thu, 25 Apr 2019 22:27:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3FA6B000D
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 22:27:47 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id t23so1646791qtj.13
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 19:27:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QQkx/gI38BRanILmeGSHvkh1ypHOhw/OGbmPVvX1nTs=;
        b=QQZGP3RFhKSAC2OFk7ZNwL5u/gGIMAR8E4g2GYtwk4pgl1VZZFrE2M25B098fV1u5K
         lGh3rog2uHeybNq4aZhMszQ1MpVPAQCwj3GE94nKePKe1iqEvLn7aGDbUK4MqPKTZFk8
         ib2bQ5f0a2FKGfTgjKpQc9Nd6y7RKmEFgEesAg7ONe1ES0dcX6KK6omutK/7rQQpD70g
         dqc4S1TSv+kvC6xqr1PwiNkbnvf0c6a3L8AMdv3QLvKdWMk80AFoUnPunTmF1wa1LCRt
         jFnmd6I/XVDwtR7URraIo0C6lTylCOtEZXD6hXiMThXYiYMO76n0y9KkxWDlZQnwwDZ9
         BzFg==
X-Gm-Message-State: APjAAAU53R1qj2PhPAMPEMJjPvLjRSqD3fu4yrYEB3Iqv38VptKsjuBa
	KaYfnG0/PxvIS3ZISymeBQ5A8JVN8MNNvbp4k3imiBV8HEns+dWqygVjKuY3Bg/ae+CbDdad6yk
	cINuIPhWnY1iMU1QQhPAthx2K0qNsUtD0Zh84CedmjfhLY0CqmXQF4eqiEDk4tF0=
X-Received: by 2002:ac8:1ab2:: with SMTP id x47mr8274418qtj.357.1556245667239;
        Thu, 25 Apr 2019 19:27:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyD02dhOdUeOh7E05e7IcAr0+wErvCmviuxz2lRsCOVffkeAOQtfRUPPoMyo3JwkDufM3xN
X-Received: by 2002:ac8:1ab2:: with SMTP id x47mr8274384qtj.357.1556245666539;
        Thu, 25 Apr 2019 19:27:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556245666; cv=none;
        d=google.com; s=arc-20160816;
        b=cZOucz/hA1MLVpjil3rw3YoyCFNjy1a4e4RnsYdwvR804xxrmZaRBkMVPpkwzAhfh6
         RspaVY8x7er6f9m8JMNHU7Jz7ei7L4Mnt5QJeqwuxKhinNUQ5BOhpMU3yGbzE2C9UtFR
         Xuo7BjDP1msDiDisgXHInTxakwHTiBGur8K58lftiPfPR0wkPsVV2cxW8uwOnm2C0EUE
         Iq/boLQ2CKA6sDgOHbWhBmLls77+Uq5iPeP2Qa57yTSgHkQ8//3vgojpcxVQ+KkgVKBB
         lk12uOd+JHFccKsNH5PHufHHqs4RNR5ZCt+9O+q5dBNdUVJ8jr0cAzgN/uTrQ0Jrrf5J
         YHiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QQkx/gI38BRanILmeGSHvkh1ypHOhw/OGbmPVvX1nTs=;
        b=wMgVIpgJGm0Kat5d6BDPWOU4OM8PVk9vh77iTsDFmOhGSh4bH583kXcSrrGsv2xJan
         gZASG5iOoCSzD1BLx+HqRyzEYdZQBTvPxD++OKkkWRb/z6VGvPJSHM+crDyvdm6AhRse
         KZJ9tqj5Z6DJSf9v91/AN+uLgBPDjrxtPUo5c3GzFB51LJGLsjltR85YAL2L/iah8nKV
         5EFSrZBBkKfZaQGmyTzkgytrpVw/kURXauFBbP5qyWPmMZEmQnzNYwaz8OT0rzJHRyoL
         3LcTkyrwkB+2NnAepmjbLNiSn2cTJP7Gmt7DJ23sVAnduzsLbq2E60o2kLLt0OYmUZHj
         zLFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=qXdtKMep;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id z11si8083697qka.196.2019.04.25.19.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 19:27:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=qXdtKMep;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 4704A1117A;
	Thu, 25 Apr 2019 22:27:46 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Thu, 25 Apr 2019 22:27:46 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=QQkx/gI38BRanILmeGSHvkh1ypHOhw/OGbmPVvX1nTs=; b=qXdtKMep
	7JDjQV5xD/FEs7OSSrFz1KGr5mwvWUhM3f/Cxf7Ky9JhusqXXfdim9UkH3SQ9HqC
	kxlvNUvKjNyi+TNmoY8Yc9bkosj91gHOsHBNPlJY3zuRlodq+5y4ioLMiGtNBIIS
	4cNadJCqn3IsZrqN1R8ssXsMHkHyRQp3pcpUSvSVDRxbkkX+dLFN9KqGFhJ4yPQi
	iWYK5Bid1+T10xKSE+56r6ieyGlPjSJfE3EfYHop169CUyfS44r79XHi2O1vRfLQ
	bM37OjrmD8Iqa8wg7XgHy5q6fB/6DXbejbk7fByMyWorBviIFlrzmqgxOKgL42Uo
	eeI8GS6eTZpviA==
X-ME-Sender: <xms:omzCXHmol7zeCWJCB-AsvpeLSVcndbRrCKxJyLuQOIfyRdCEeXzPzA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrheehgdehlecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrudehledrvddutdenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepfe
X-ME-Proxy: <xmx:omzCXOpFMBNDQ_xdNyKdWBg1yL_-yINraJ_bz9NtsDB_CzbKy5jspg>
    <xmx:omzCXGtgYzzyFg0PwBNVPwYexP2_L2ZuDxvAp09cC-024vmiIRchtQ>
    <xmx:omzCXDGLbh8TRAYvcgwl1xkYwejd5c9zPCZeI2BSa99HDTbwuHID6w>
    <xmx:omzCXBrmZLT5pe-fbeJGMsKBIE2LmwfhOdM_kq0cKN_dBhyXOlodLA>
Received: from eros.localdomain (124-169-159-210.dyn.iinet.net.au [124.169.159.210])
	by mail.messagingengine.com (Postfix) with ESMTPA id B7D3C103D5;
	Thu, 25 Apr 2019 22:27:40 -0400 (EDT)
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
Subject: [PATCH 4/4] tools/vm/slabinfo: Add sorting info to help menu
Date: Fri, 26 Apr 2019 12:26:22 +1000
Message-Id: <20190426022622.4089-5-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190426022622.4089-1-tobin@kernel.org>
References: <20190426022622.4089-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Passing more than one sorting option has undefined behaviour.

Add an explicit statement as such to the help menu, this also has the
advantage of highlighting all the sorting options.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index 469ff6157986..68092d15e12b 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -148,6 +148,8 @@ static void usage(void)
 		"    p | P              Poisoning\n"
 		"    u | U              Tracking\n"
 		"    t | T              Tracing\n"
+
+		"\nSorting options (--Loss, --Size, --Partial) are mutually exclusive\n"
 	);
 }
 
-- 
2.21.0

