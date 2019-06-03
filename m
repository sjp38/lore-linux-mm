Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEA50C04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:28:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A962627225
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:28:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="h8lhB1kH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A962627225
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DE416B026A; Mon,  3 Jun 2019 00:28:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B7C36B0271; Mon,  3 Jun 2019 00:28:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A7936B0272; Mon,  3 Jun 2019 00:28:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB586B026A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:28:19 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z16so6499112qto.10
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:28:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=;
        b=I0uSbvoSbvWkj+RnhubY9vN6KVomjpVhK9fTbQPZ6P5a9VGjeS+QJHcHqhZEst94NW
         fOwAhxpMHH9ltoNAzCnT+LRJVMxrcBDPqJO4qYxAPDKQ7TOqAAB0qMQKc252JFv8+Q30
         VVLpoc8LRCSdxsrBnusR89wRyMxHP14qpL58HVSy/A1T8VF+9Jbl5iJu1zdzu7ordG6R
         cnpNMlm2zt11NRte1Lh6cz8DvtxDuvyN0L3ujW/kCrc17fdBull0mgiPvmg+2U6Fynt3
         SQef+1RTeKmLUzvbAChu65RqXA1DBDsXXNftlX7kV6SE0i7KaqIz3z1qKjhhUwyME4Dn
         uBGQ==
X-Gm-Message-State: APjAAAUsqAF4cORazEWF/cELNm1tgKKg+ZQZJDOgItVR8/QochyfBVnG
	P80Id1wIrq96NxeLpApryf2N12iKBVFuhLiGBhWPMkRJgezBPOyETxN0EjprlpWpvhMqO+KMhte
	0XPq0ShVPxXam1Yy/xHKbVyxrzt6QYnBGo28CJzM22XVbOqqmWq7oApzP1UncePg=
X-Received: by 2002:a0c:fcc6:: with SMTP id i6mr9543104qvq.109.1559536098939;
        Sun, 02 Jun 2019 21:28:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOTpjhCS4n9ScPTSH+qieBgRjGKoj/37kNiPvf+DK+Xwh6elqGCHKl8iwG45AQi6pl8r/6
X-Received: by 2002:a0c:fcc6:: with SMTP id i6mr9543068qvq.109.1559536098093;
        Sun, 02 Jun 2019 21:28:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559536098; cv=none;
        d=google.com; s=arc-20160816;
        b=KoXpRdmdOJFMuFQKl7YZi7OLLvpOm2SuECATSLNjBQRqK70SuRMJESY6wjZfDrhStW
         wdUTODQMiL9PNRC/AH31bZ7gIHxJ3sPZr3xK1q6MG2Bbk8DUCooEFEUdJaMilm0Pk4UI
         B3o7Cnbf8j24mhiocqO620D0zBUDPPkFrocyfsWEfudr4cZvWUte/ipvuUccgq22MJev
         17CaPUXsSX2xHkaMo7gtw85Wl8tMqonpm9Di7TE6ad04G1VhuaXm/4gVR/sUv0K93eMz
         8PB+2tQ4d/a6ctUwSHvbfqMN6bhujKqObZaefquCni5ygZoJTHgf8doy9/baFH/fXgCH
         MJ1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=;
        b=O4inlAWb/f1pJY3jFYX6NVzWM3gWicRTJ7JeE9SXUKPFAWDPJScRernGcG2VlTOYsi
         Pbz2WNZnIi7yK7dMhhX4GdWrUOZbylLUIviHdRpEzYv2DsrCmnyhPpTS4uZV9hsshW5r
         W5CfqaAp6aBA9nNuL2j8xNmheSAHuXIa8fthIZY6Dnjf0NbthTNbA/5tbqiLOnlfgqg8
         /AMfUUe3zuVyFcSmBo6Ojb9VcLyUyZQnDxzDZ6zzl5k3Hbp+ZkSD7qGyA9IT48MeCbik
         S7uqoKjSa/D/6gMEA4wy0enPTn5yiOAGp4N7dZKU112MNbMbUN4aVTbcxCc0EXhaYz8b
         brVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=h8lhB1kH;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id q5si1009048qke.271.2019.06.02.21.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 21:28:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=h8lhB1kH;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id D64B415E4;
	Mon,  3 Jun 2019 00:28:17 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 03 Jun 2019 00:28:17 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=; b=h8lhB1kH
	/ZzWq7shkCDu3x1p3MQLgFcheSThypTFlbmAunpKVRrTI+jS3wEx0oXjx1+h4vae
	osoL6PSLNto2hLwr/Oqkoq9YUQ4/Ilv19G4cbmgdd/fe2oZ8QwkalEhSlW+fhfe0
	78jdTuCqOqOjx5O1ekAIDMFSnqksJyvWPvmUfHSE1kYsHDlWzcY/CIGHeH7z3O/f
	7f8EP/7M9IMXnrQQcoQ1jnISJkxFZKEp0KbxSVO5aU2648H3JH3VCqb5LP1aN3xY
	kytxgvMZjJY614JPtc0ry8yak8OPJjPoI4i+Kzdn/KwuUx/PPUx15JGQeBWK05ju
	LaW42Ofr9GVSGg==
X-ME-Sender: <xms:4aH0XNYo_PEx4p7ZEzfdVQMIt8w42deQJ9Hxej6jwXiMVcs5cL7ewA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudefiedgkedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufffkffojghfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghi
    nhcuvedrucfjrghrughinhhgfdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukf
    hppeduvdegrddugeelrdduudefrdefieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:4aH0XE1uwulZWSmp4e-tyH32u6kHk2pgVcrA7py0amUiiWWkTNAACg>
    <xmx:4aH0XFZonIBSFuGiFN2s4O5krapdBGhBpa_nVJZTsBOwK17CLViM_w>
    <xmx:4aH0XJkH1iEJsJi-X5TcUcT8mg1I8VRy7SM0_UqRJXbjd6lgsP2EtQ>
    <xmx:4aH0XE8GUtOK0mfybgY3eUB7fNSF5gRCbO0VnQVUOq46truUohSUDQ>
Received: from eros.localdomain (124-149-113-36.dyn.iinet.net.au [124.149.113.36])
	by mail.messagingengine.com (Postfix) with ESMTPA id AEE378005C;
	Mon,  3 Jun 2019 00:28:10 -0400 (EDT)
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
Subject: [PATCH 06/15] tools/vm/slabinfo: Add defrag_used_ratio output
Date: Mon,  3 Jun 2019 14:26:28 +1000
Message-Id: <20190603042637.2018-7-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190603042637.2018-1-tobin@kernel.org>
References: <20190603042637.2018-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add output for the newly added defrag_used_ratio sysfs knob.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index d2c22f9ee2d8..ef4ff93df4cc 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -34,6 +34,7 @@ struct slabinfo {
 	unsigned int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
 	int movable, ctor;
+	int defrag_used_ratio;
 	int remote_node_defrag_ratio;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
@@ -549,6 +550,8 @@ static void report(struct slabinfo *s)
 		printf("** Slabs are destroyed via RCU\n");
 	if (s->reclaim_account)
 		printf("** Reclaim accounting active\n");
+	if (s->movable)
+		printf("** Defragmentation at %d%%\n", s->defrag_used_ratio);
 
 	printf("\nSizes (bytes)     Slabs              Debug                Memory\n");
 	printf("------------------------------------------------------------------------\n");
@@ -1279,6 +1282,7 @@ static void read_slab_dir(void)
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
 			slab->remote_node_defrag_ratio =
 					get_obj("remote_node_defrag_ratio");
+			slab->defrag_used_ratio = get_obj("defrag_used_ratio");
 			chdir("..");
 			if (read_slab_obj(slab, "ops")) {
 				if (strstr(buffer, "ctor :"))
-- 
2.21.0

