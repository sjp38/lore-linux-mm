Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB4D0C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9381D2184C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="jkiZvFmA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9381D2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14A6A8E0003; Wed, 13 Mar 2019 01:21:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FA3B8E0002; Wed, 13 Mar 2019 01:21:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00E878E0003; Wed, 13 Mar 2019 01:21:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3BA48E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 01:21:09 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x18so552500qkf.8
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 22:21:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=syfOZfzAEXP08coD58eOkvYA4m3WRZUBnOoyYyN32bc=;
        b=rq3/iCI5UCjZRA6gJJNhGEsyUiRFlBI3piZIoAl2FBvhxQw9UDQSaJuXmxLKs7q4Sq
         DKkWbLWuzReDn4mGeVDKIVMPew8NA9xvBDxC50HO5LJ5BmhJvkSDhIkT1IlB/Qepocri
         CJWkpSPX+qiuY03FVZlJqAa402xz3U8Kmjq2WwS5XPmCbzN5j2RoRkzJZDnaa69xh60d
         3tVBrvBTPrEBbOTU4ImMz3j4jqGXRTjJJM+tz9coxjS+ITgDXfoKdgovdl2jEZQ7TXjZ
         e47FNJP+9xmfUlKDNovN6YUZR3XlLnlYVVXXsgaxPgxcon9fOqhHGX9mxz01U73XpEFa
         ZlgA==
X-Gm-Message-State: APjAAAUj8Y4Mpo2Z4M0nWKLyN2Q+8nUQIhpK+C3NiHKTEvkJbBVOfPO/
	yokE8OcnkNR7abE4haFIv9mYXoPuBPIC7iLJFORK7LR8jm/ewctRM1bzmrOGG+nrQb+550mFs3t
	/VM+zExnCYqybiTKHhTZU/TEuCrMeh+7eJ+pVjTjoMDGDnBe4hxYR3HN153AoBbs=
X-Received: by 2002:a0c:9587:: with SMTP id s7mr33379295qvs.155.1552454469626;
        Tue, 12 Mar 2019 22:21:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEaebH2NsC0epMLgO4dlWPvYRW1gfm0v2qhU/e4riOdg3J7Qva4khRq411VUVrvuxJC6Vq
X-Received: by 2002:a0c:9587:: with SMTP id s7mr33379261qvs.155.1552454468885;
        Tue, 12 Mar 2019 22:21:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552454468; cv=none;
        d=google.com; s=arc-20160816;
        b=xcZ9g4NJZPslu62KLCJ+JYUG9FWT651Mrckb6/QwgHc5tNCb+ed6HBhs4f3ExWILg2
         xVDMiNY2TUiY/8S938KYM3m+9+3HDaHj4BpEkBj8fNFSlxmuN5evw57Cq4ZAiGU6ttZT
         ZqIgkeriaO43HLVd2N8lIsFyL6eyl2VhZYKqBZ9BAWV2Qc0EYikVQjUyRPoynM5SGFtd
         wEEd623dd5fAZ8OJcfcUszMtzx/5zpXsqXdse+ZUE323UAEjt8cvMjNNbsJpoxa1u1aM
         4yA5OqDK1eTZ1N2tE7K+DSS2q1Z28B42Chx/tFpkXUCdUdOvKHUw0TVetUd8/DvxI5AB
         Srxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=syfOZfzAEXP08coD58eOkvYA4m3WRZUBnOoyYyN32bc=;
        b=J0uKKVXtBYBByaL5yy6KoT2dhKbdRLbR7i0qQxCw6cWEWGbWGU0UylRhNSqQ0dFs/b
         7lcYrDH6p2M5q3Khc4JYTOiHfo63uaQlE7e95cuDP8FDP1IxpPB/d7fHesWyJeHGgGvT
         qCMctM4KWDqd9/5wlodvpQAkewT8YRwZCoQAaORzNZYWB6qb2xlymSNbo+EczV9OdYR6
         /zzWhAcgnaIxD0PqTHnBPv7Hs3ReaoDvN446RFLrtNAxabLxYsFMqcpK74NLT0Yzztxa
         LKnfH0VG6yYzk8gWVYhkeQHVrH1jkSXc/KvVAX/kn4nUJe27ebPbUtDKHiditkcoVJIy
         9bIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=jkiZvFmA;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id s7si4080346qtq.73.2019.03.12.22.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 22:21:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=jkiZvFmA;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id EDDC82FB2;
	Wed, 13 Mar 2019 01:21:06 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 13 Mar 2019 01:21:07 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=syfOZfzAEXP08coD5
	8eOkvYA4m3WRZUBnOoyYyN32bc=; b=jkiZvFmA5Yxsd7Q4Uj92iZu1KoJrCzWsn
	9ahQfl0EMu6OyJRSrl23KtVYdOJANGTW1S31McTpaZB/VRJbnSYYHBNcbjDYrJsO
	vSQNZ5BbyUeHFiK7e2WMfgqDdPRrWnIp9UDOGLaEtzTT4VqUD4sCO9MzknmK6i8v
	s88TpBcWcUqB6+xgo7bAx/g3RKcKZzJwV5JKFsT5rB/+lz511LL5xqnUKXUh2PiB
	06d4+qwq5UNcheAMY6Bt0NEnhhLSkubGr7mowrrdaTrHrJ9ZZIRdtBXso6soVHIY
	CA2lpooyn/MLeXcGnNSVzMuSfckD06CqeRrvrbhrZSnrltAPzimzA==
X-ME-Sender: <xms:QJOIXOAsRxVAJuhkp22PLWJxUS7pDDcSPKOvZypr6tU83REriQUW0w>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeelgdekudcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhnucev
    rdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkphepud
    dvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgsihhn
    sehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:QJOIXGZh9BhKKRJhShwCV9I8RwP6iQhaVY2syXoOc0ZmVYjo_2Vcfg>
    <xmx:QJOIXKqQbBnxD4qStmdWdN5YUsimIdKw60rwUubEh7gDNaohpNOTEQ>
    <xmx:QJOIXOCx_MCP0So2QhWcYSBWOoejvktwYvukBIU974q1GPkliR7dYg>
    <xmx:QpOIXFrtkk-EKVM-GhBU4zx9dUYjq4gJ6dV4TO8emxihrev9ugqr2A>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id A2467E427E;
	Wed, 13 Mar 2019 01:21:00 -0400 (EDT)
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
Subject: [PATCH v2 0/5]] mm: Use slab_list list_head instead of lru
Date: Wed, 13 Mar 2019 16:20:25 +1100
Message-Id: <20190313052030.13392-1-tobin@kernel.org>
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

Clean up all three allocators by using the 'slab_list' list_head instead
of overloading the 'lru' list_head.

Patch 1 -  Makes no code changes, adds comments to #endif statements.

Patches 2,3,4 - Do changes as a patch per allocator, tested by building
                and booting (in Qemu) after configuring kernel to use
                appropriate allocator.  Also build and boot with debug
                options enabled (for slab and slub).  Verify the object
                files (before and after the set applied) are the same.

Patch 5 - Removes the now stale comment in the page struct definition.

Changes since v1:

 - Verify object files are the same before and after the patch set is
   applied (suggested by Matthew).
 - Add extra explanation to the commit logs explaining why these changes
   are safe to make (suggested by Roman).
 - Remove stale comment (thanks Willy).


thanks,
Tobin.


Tobin C. Harding (5):
  slub: Add comments to endif pre-processor macros
  slub: Use slab_list instead of lru
  slab: Use slab_list instead of lru
  slob: Use slab_list instead of lru
  mm: Remove stale comment from page struct

 include/linux/mm_types.h |  2 +-
 mm/slab.c                | 49 ++++++++++++++++----------------
 mm/slob.c                | 10 +++----
 mm/slub.c                | 60 ++++++++++++++++++++--------------------
 4 files changed, 61 insertions(+), 60 deletions(-)

-- 
2.21.0

