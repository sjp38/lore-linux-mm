Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C1EEC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:41:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C708120856
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:41:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Tp/kx4vO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C708120856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 730716B0008; Mon, 20 May 2019 01:41:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E2656B000A; Mon, 20 May 2019 01:41:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D00D6B000C; Mon, 20 May 2019 01:41:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC016B0008
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:41:33 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id h16so11746395qke.11
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:41:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pvmcntUKaLFWeIKV28cwZMSwwZ0f8GZCwK0RuRd6vxw=;
        b=qpx0NjPqJOUI0iQycBFNNrE8aCezSgwivPEqhpOgK3E2Jn2cIHGbq4WjsO/gwM5y03
         kNNofMXJ+PKbJvks6rYkmCRz5rvUw6voIRyFUxKHM4iSkOklf1MgasFsbOh5OtiPG+RI
         hSaeEj+m1/2bJ4COb3XwhaoXoH7/Jkl3iKW6C7tpxEAHzarmkqE4vVm54iJZLQfV/sjd
         VZ+d9mdxbbR7usD9bfd8ntD6jVNUaw/cMtFMLeoexHmxHll0rFutBJl5YxaBsx9wJLtI
         SAEweasbKyQE8qilzI0Sxc7CsfoCACotB/3NUowg3IYnoheeV1aASqeiN9o1cRPe51O/
         pkNg==
X-Gm-Message-State: APjAAAUDTM+LRK/P6OmmvYQ+zfp2rbl/RWHzfW7rScS8Y9MpQUSrQhFb
	I2LiucAXwil3rVOX/iCzrP8TTBFug9b51+iLu1Jn7iWHxPrbwLwKOHLHqxS1K89hl+6YXQQEYL4
	/gRLwI9JB5ZqVLAt38hazufTXhO1xm//02GCBejXqNdJqoiacIm+VyeRP/giE1+k=
X-Received: by 2002:aed:2428:: with SMTP id r37mr61067749qtc.213.1558330893006;
        Sun, 19 May 2019 22:41:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwdr5k3/QdFzYRbuHLDqP5z38MCtyO5IGYGPYZskZMCsRnBiwgUi/O0dOuFszTKiAE+YZw
X-Received: by 2002:aed:2428:: with SMTP id r37mr61067712qtc.213.1558330892151;
        Sun, 19 May 2019 22:41:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330892; cv=none;
        d=google.com; s=arc-20160816;
        b=C1b2EZYopxKyJ/dinhTyzq4SbsXf5+DC9ysKBzD5a3mqJFaeqKfiixHeHAFZX6lZjn
         DvdhBnTOVRjraK/F8AunSVlfTZIIVGP2U5gYG5gScTov4YlTzcTymW4KtR2ePR/+xuJg
         K74wYvS3jWpf0237ml0VozBMV0BfySwmshJQ79M8WPcKGX57zB/lYV+QpslJY94jNWk4
         uSpMOX62MLy7nyrX0iza/DarcjECJ/gfkZhz1E1y8SY4Nd+XoHKEkX9uS0XUgG3zGtsT
         N7NCjo3Ib6U/KIueuIx6EiXwIMLRvu5v+9vMq71GyRBY3/WfeN19Of3ZKvyhV/b7Jy69
         lLKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pvmcntUKaLFWeIKV28cwZMSwwZ0f8GZCwK0RuRd6vxw=;
        b=ygemhDaFYPHgr91NTbs0SVN9O9yaqnViFZU7V25vykq+GsY8663/8B46FqWL+uxKyZ
         4HGgWpw8rNIPmAcvHchwpCo/VuGQawDSu/ev94MlVvBIAgUkD4uToHmPC58rHWdUV2Vr
         jzKmAxyJXRbPamdXjuQfTQN3G0JEtM9XPwt7UQATqDcF89WHlhTuckh9RQS8OIb0fxju
         1qJX5P24kcq3XfdCy5uwvlxHe4pHdoP+b5wJbOg36NpImpZIv780sH4i5+ZUcP4La3M8
         Dgt52ib9kkAUQF08wBhGVwuXScTrUmYpyALGfaMoLvKNCDp4H7W4cRfQaE8nQYmiC2MY
         qrGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="Tp/kx4vO";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id p37si3008321qvc.125.2019.05.19.22.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:41:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="Tp/kx4vO";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id D6EB41160B;
	Mon, 20 May 2019 01:41:31 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:41:31 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=pvmcntUKaLFWeIKV28cwZMSwwZ0f8GZCwK0RuRd6vxw=; b=Tp/kx4vO
	UsH3lifxwz1hf6IIZvoCuYCbS3N/bxeIEVJczgn7f7NSK3ljq+hzZo75SxFHhs61
	eLKytTBmVNQeJfPJx0AqskyqdiYk4kRZD/sDasZgyVCdPfTew11AAqBLFyvz3ZiL
	gEoATFHVziwmgiSWPSPgNIBzkGFdMSk/oKmmb9a9XNpVoRjO6Eg08rYHYIw93/h6
	avf2LrUg+U9Sj6kHhjdlMRyWFY3YosBdV2e46UtDbn3yVm3YtKtj2mHDUyv0SF41
	tWoioUGzJWBWyPx/TgE7scZXI6laUj3o5rFiu1lZOANRvRPYxV6XVkLIO1yKT8El
	xjvjA4jOCg5H/w==
X-ME-Sender: <xms:Cz7iXF2ceonTc1MTLpyFy7_yETIfJipMjVUHW4kZ1vTH_7KN0QZ3bw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenuc
    fkphepuddvgedrudeiledrudehiedrvddtfeenucfrrghrrghmpehmrghilhhfrhhomhep
    thhosghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepvd
X-ME-Proxy: <xmx:Cz7iXDK4xz1HSpbPhUmlrahE4BKa0oW2wB4YcmU158qk3pK_FnIS9Q>
    <xmx:Cz7iXNl6aPGjcaqlu6VlxiMcVecndGcYo7iUQVMhKzCuaUA_5MgxEw>
    <xmx:Cz7iXJP49d9iPxz-K9gMLROM_-gWZrSWN3_CmXA9cydkbiwsdRKCVw>
    <xmx:Cz7iXMuOis1jY3FSM9AHvZDNX2zz_izaaamv8wYPTOw-S8MfHr1Cjg>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id BA1B18005B;
	Mon, 20 May 2019 01:41:24 -0400 (EDT)
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
Subject: [RFC PATCH v5 03/16] slub: Sort slab cache list
Date: Mon, 20 May 2019 15:40:04 +1000
Message-Id: <20190520054017.32299-4-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190520054017.32299-1-tobin@kernel.org>
References: <20190520054017.32299-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is advantageous to have all defragmentable slabs together at the
beginning of the list of slabs so that there is no need to scan the
complete list. Put defragmentable caches first when adding a slab cache
and others last.

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slab_common.c | 2 +-
 mm/slub.c        | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..db5e9a0b1535 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -393,7 +393,7 @@ static struct kmem_cache *create_cache(const char *name,
 		goto out_free_cache;
 
 	s->refcount = 1;
-	list_add(&s->list, &slab_caches);
+	list_add_tail(&s->list, &slab_caches);
 	memcg_link_cache(s);
 out:
 	if (err)
diff --git a/mm/slub.c b/mm/slub.c
index 1c380a2bc78a..66d474397c0f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4333,6 +4333,8 @@ void kmem_cache_setup_mobility(struct kmem_cache *s,
 		return;
 	}
 
+	mutex_lock(&slab_mutex);
+
 	s->isolate = isolate;
 	s->migrate = migrate;
 
@@ -4341,6 +4343,10 @@ void kmem_cache_setup_mobility(struct kmem_cache *s,
 	 * to disable fast cmpxchg based processing.
 	 */
 	s->flags &= ~__CMPXCHG_DOUBLE;
+
+	list_move(&s->list, &slab_caches);	/* Move to top */
+
+	mutex_unlock(&slab_mutex);
 }
 EXPORT_SYMBOL(kmem_cache_setup_mobility);
 
-- 
2.21.0

