Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BD34C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:09:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E393216FD
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:09:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="o7Kj58FZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E393216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A89656B026A; Mon, 29 Apr 2019 23:09:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A44C36B026B; Mon, 29 Apr 2019 23:09:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 902E56B026C; Mon, 29 Apr 2019 23:09:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 708BF6B026A
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:09:04 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id c22so12160099qtk.10
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:09:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oAX6zCohmPiQ74kYACc2QgeImmemzleYDH4h+URdt/s=;
        b=oIV6bglmBOyBqcHCw089Q41pw/ClxRckPBtJcpOgAHO/+DZK78Em4YM8W05tqyL9ha
         OqyGFKbGmuoLYmPWagfyCI2DIi8s4Kcj/ODSWGBG0Sk3MswTdGc91v5xYEAGO+iHjRnW
         +FnbnBqAMp8EW1K96ERB1XvPbFdLdok00x+30qeQIlgpmiE1+Q0AqXKZVGzn+n+lcvvi
         7PJz32hPdq01xtC/m4YAymHh2tlUyeYJTc5S1OgB7XeVoANY37crG5WJQ0TH85nz7zB7
         MrOXqPjJfRR2A4BqTTAQQmiO7SewUKQGm3NN+34a6O3COTZQ/UTag96xmXqrokJ8dC/0
         OQ5g==
X-Gm-Message-State: APjAAAVriBqnRZV6BztpkaKj7EkxpaWCGa6GwRBI7QQiNz5yYhOBZfYk
	q6O4eN5b7uOpYolbh75d6GMaErJy+p1aNXY+ay84JV0hzUPXVuz6IlZadxlyBtM5oY44vpm0EfU
	HZ260BhVrECtgdB+iR36bGUBQCcaV/s2kzNGCjySj5j8eaX6/j498yReqvDqcQgA=
X-Received: by 2002:aed:30c1:: with SMTP id 59mr50879357qtf.277.1556593744240;
        Mon, 29 Apr 2019 20:09:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnxyaV3x3JVRK1NQqfxdSGgt8WwUbqxiVs1LYXRvCv9/1lx1j3XkZ7MFbP3eBLkt9JxRyT
X-Received: by 2002:aed:30c1:: with SMTP id 59mr50879318qtf.277.1556593743326;
        Mon, 29 Apr 2019 20:09:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556593743; cv=none;
        d=google.com; s=arc-20160816;
        b=hyf27IZuKIJ2dy45VpNWHeokFOLmDV1dm6QZpqO5wkt2gjrlNAtc+J9rALeDUfYB/q
         Orm3vDRfmuDjGTfCLle1QQ+GHa5nPqtXkh2BHKPzI8m+Yw0kAXNiiC5XMnjESMRX2DlA
         HClZqWQKXhjbdYrxmmSV2iLhS3Nrd6eIBeFkFlNbFPG4bLS99i2R24fNB496S1u4YdAn
         HRFj9MqKraWW05m9xyPAsrC8DM1VLyhE2/BL01mnYdOWkrdaM5urlywY29Aa+60yx8Qq
         Wf1dIOprZ3Cy2ENZcmtFrTgRA6EfsWeRBbKT590BhzWy9whFxLktTBVtEiHE+mAaW+Ig
         6d2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oAX6zCohmPiQ74kYACc2QgeImmemzleYDH4h+URdt/s=;
        b=E4QjSvVdq/v8N1ubr+7F4Gw8NnXwOzRxEHfOnlpPS4yHfRb+40j4ggByKFMbF2m8bj
         VvbU/Sxbb8kIsqzy/03HsA5lfNDZ0D+lXMH7aQ4sPHE9tUsy/yjhePV2Hbepaj2r9+UG
         v43fpoxMTLLMCfT2ralxTbLWJqaHKoceLRcuO2iaBu8+7uUZzPz89RieTyVBmk/pQsKd
         0zonqlfcYh1D0FX4vffEoHtsOCH/01p5gd6WAAI0s7E1gUKIfyvwTq/tRFM7vxbVXaF7
         wgmkn/gEjC8dOk0K1d2zw0TxWj+ZygoseZszWdeifU1EB3N///Nl17sWmHxmdW1rj3Ry
         U7+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=o7Kj58FZ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id l66si262015qkc.145.2019.04.29.20.09.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 20:09:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=o7Kj58FZ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 0FA4D9A40;
	Mon, 29 Apr 2019 23:09:03 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 29 Apr 2019 23:09:03 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=oAX6zCohmPiQ74kYACc2QgeImmemzleYDH4h+URdt/s=; b=o7Kj58FZ
	umNKgzxodgukfWTcut22REHE596NdqMjuUUUKvVQLx5BPJj0NTVZ3d36ynR8D3Zf
	hYyp6bB6IctA12jmf3nGBSK0wdsHhOvqQeEcd6b0LzA+naKDlxaYrR0fjB60JmUe
	4MiUVO1e1yNCnRGW7kcjNv1oqoV8UyK75OUyGjJOA0g/FLXFgmnLTuDupzgBhM8P
	CUdo56GgKBC4qFvCVJ4hWuNHTAk2LScEPqiaSMNqyfTpyPm5X2L1/ufg5GGEaQnq
	YWqkh8PwrTQOaKGoBxk+JLF74PucyHy5GI4Mu/mGFFa507wP+nZKxpxaS6juK5kQ
	WUOXSWsMIge3rg==
X-ME-Sender: <xms:TrzHXLdQCrW-0MvgwMZjm0YPha3-sEY1-r7hAsOPXKXY4h4rjgd5iw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieefgdeikecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvuddrgeegrddvfedtrddukeeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedv
X-ME-Proxy: <xmx:TrzHXIIX6ZhtAuJ9-uRJfHtMmQ_S407tPx2cNRw4N-42DnZm5t0vmQ>
    <xmx:TrzHXJrq_K8ahugLGfpzlux3Y-EBknA-l3Ipl82EKpMu5130SbM1rQ>
    <xmx:TrzHXBXOhrAnFepNxPYOou_H311KpNLeySM9kV_iZLNApDxhg8TMoA>
    <xmx:T7zHXCPi5HLnsGSs_FP5k0DZEP-m8e_kXjiYPsNRtLdtPEEKLF7HyQ>
Received: from eros.localdomain (ppp121-44-230-188.bras2.syd2.internode.on.net [121.44.230.188])
	by mail.messagingengine.com (Postfix) with ESMTPA id 12572103C8;
	Mon, 29 Apr 2019 23:08:54 -0400 (EDT)
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
Subject: [RFC PATCH v4 03/15] slub: Sort slab cache list
Date: Tue, 30 Apr 2019 13:07:34 +1000
Message-Id: <20190430030746.26102-4-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190430030746.26102-1-tobin@kernel.org>
References: <20190430030746.26102-1-tobin@kernel.org>
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
index ae44d640b8c1..f6b0e4a395ef 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4342,6 +4342,8 @@ void kmem_cache_setup_mobility(struct kmem_cache *s,
 		return;
 	}
 
+	mutex_lock(&slab_mutex);
+
 	s->isolate = isolate;
 	s->migrate = migrate;
 
@@ -4350,6 +4352,10 @@ void kmem_cache_setup_mobility(struct kmem_cache *s,
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

