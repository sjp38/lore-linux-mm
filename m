Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 388EFC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:35:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7340217F4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:35:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="PrShYazj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7340217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F8DF6B0007; Wed, 10 Apr 2019 21:35:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A9546B0008; Wed, 10 Apr 2019 21:35:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 470BA6B000A; Wed, 10 Apr 2019 21:35:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 255C56B0007
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:35:57 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g17so4058615qte.17
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:35:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bxV5jBaXvA/LKL0qOR0ZLSK5IIfdrfWAd0nyjsopfiM=;
        b=pHnEB6cEItTOGLPe05BT32FQHT3+dTPAGHXKKX4aFXIZTf8laUdAyfdXuxuoVoOKlo
         +IeVwIpoPCYu/2p99zfQYqX+NOdo4MytBdZ6jA3b5TWNsjat7ge2PWolKQ7aiqF0tIWQ
         M6TeMbZpH3oha5r/x3wVrseDzYgl9oWdyGP18uGKfDASFudG1IXtDo+s6w9g3Ln86K2L
         RvVUWV+uHA5bhOu81P2KYsZdw8kNlJB+l5syiEUPIKeGki+JE3VHLGDbW1ukoNpgUUeR
         PLIXFJGXpAKEEuuhhl/w9fGNZ3sWhvGjblVRG3vgRLJJB85cwPqpBNeC3oRCfOr955wj
         LXcg==
X-Gm-Message-State: APjAAAXUzeqB28Pz9+b+o3oIBnqDsLl851BOCetlCJegTbEjPsJaSQgN
	7dHE3pxs4nhBEHxtVhSfN/NofrQSPeZokUP5uBbNZTwEXRjp7Ji65k/BCnbu9IZ60HIefGJWKG0
	S7Zo5TR26jcXEQiSUcw4IW5ous8J8jGDWuqlE2fRI0OkNKz8OItbLutOYOd2VUvM=
X-Received: by 2002:ac8:1119:: with SMTP id c25mr38072793qtj.165.1554946556905;
        Wed, 10 Apr 2019 18:35:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/Vsdx5QDFvuGHce43HWvQnL8s/KYu5mbAy+J4ZEKMD0mMQeZUf0wIWhs5xk3H7Rv64ya4
X-Received: by 2002:ac8:1119:: with SMTP id c25mr38072735qtj.165.1554946555553;
        Wed, 10 Apr 2019 18:35:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946555; cv=none;
        d=google.com; s=arc-20160816;
        b=YxYt7US7HuIRoNSU+vW5M0ijobdcKOotHqdD2LS47+PZuVt7DGGxiCc+qa2So6lhQK
         tKmtg17yDhFmwnfRb32uqLHxiCdJ23GxNFecQUy5BwiRYbuwWwAPcSlHmoSqdEvhIyhS
         YTDByiE8SP/9WQKqL/kTNQGbv6sfh6Q5DbIH+StveHDncgjg29BjLS4O+PSBHq9Xqbxc
         CjhIV5u04S95dwcGDJdYsAf7Iw13OqLWGIlxYvL/3cOGEqwODYEu40ObrjUlwa2bvcOJ
         r/lEirXbLbtVz8eidznsmTy+D8Ejt+NjWapsDFyWP//Z6iBxSf+nkTog1yPSX2Fk9pR+
         R6Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bxV5jBaXvA/LKL0qOR0ZLSK5IIfdrfWAd0nyjsopfiM=;
        b=IT8hQ+Noj1k+Dqh/WW2qHaHhDGkiP6LfMsZG5ajIqVKo0AyPu2up/Cd7WU+jKcqJGh
         lzPG3g7SFJe2dBP7QWLOXtuIIKRC947JyASvKbEFzkVhv+O3R3nEzkiieFlVJa+ImdQ8
         n3hbYapVQAzBEo97IEd2GJQjSXAuUTNiddxgOISPt0Is44EsKtloW8hSmcRLts+gIr6c
         +CDyggUfN3bcXjHn4EfLaJ/33bM+olkAGf8OVB0sDSGQX/7quMNYIAFfKh7AAmg02NiR
         99sOW1ZlBZUG4w011xKd4Pcy+mr02GJZeWCO8nNvEB/UcFvvsfliTOF+2iIQfI8PkEhV
         Iybw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=PrShYazj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id g42si6192749qta.54.2019.04.10.18.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:35:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=PrShYazj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 486741426A;
	Wed, 10 Apr 2019 21:35:55 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:35:55 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=bxV5jBaXvA/LKL0qOR0ZLSK5IIfdrfWAd0nyjsopfiM=; b=PrShYazj
	J7g3amgSFJOXs0AmeAmek0urDxYw9Q8khwQEVOj5lX5EDGQj03Imu0ZhqicOLmyv
	hAgIka9i5+Xrhl6WoQc8tUhjVAmoECKTRWLJcDu8B14MAFYb+wOQbz1AQMXunTGU
	ICuugwNW6g2+fzectfA24m8cMQTBDyUlbNzUgZTPWg3br70NE2AFRPmhlnZsiVll
	qYQOWbr6b7pBApy/AvnsWSwoFWLwTgFMUxjXdCRljrtUdfP7e1B/DQNrGi2MpHZg
	2Iph5llNCS40QsxEwu7oQHA/vddwb3PrCSDJRfIy68K7jGQIY3knsHS4bg4ja2a/
	jyyP2LBWhi9onQ==
X-ME-Sender: <xms:-pmuXN2hz_bnSXGBgF8i_IwDabMVbfcXlM8-Bn4L3CKCdSeb5_nr3Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:-5muXPyxNvOl1DNVo8M3got2SF9UsbijnIGpQ1nb1kl9koAdXmrnDA>
    <xmx:-5muXKUx936DDyG0LMfmXGwiptlTlvGJ4jZy4uGJVJLMz6KV4vRG7Q>
    <xmx:-5muXD85FFxR9pQef1DcekRIe2Efpw96IUHSCu9EDEo5mqCyytCOBQ>
    <xmx:-5muXAOb4HNkJzw_FbKhiC4ARdZDZzXR24sdnu7woVeh8KrU1d6lpw>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 671AAE4210;
	Wed, 10 Apr 2019 21:35:47 -0400 (EDT)
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
Subject: [RFC PATCH v3 02/15] tools/vm/slabinfo: Add support for -C and -M options
Date: Thu, 11 Apr 2019 11:34:28 +1000
Message-Id: <20190411013441.5415-3-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190411013441.5415-1-tobin@kernel.org>
References: <20190411013441.5415-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

-C lists caches that use a ctor.

-M lists caches that support object migration.

Add command line options to show caches with a constructor and caches
that are movable (i.e. have migrate function).

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 40 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 36 insertions(+), 4 deletions(-)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index 73818f1b2ef8..cbfc56c44c2f 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -33,6 +33,7 @@ struct slabinfo {
 	unsigned int hwcache_align, object_size, objs_per_slab;
 	unsigned int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
+	int movable, ctor;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
 	unsigned long free_fastpath, free_slowpath;
@@ -67,6 +68,8 @@ int show_report;
 int show_alias;
 int show_slab;
 int skip_zero = 1;
+int show_movable;
+int show_ctor;
 int show_numa;
 int show_track;
 int show_first_alias;
@@ -109,11 +112,13 @@ static void fatal(const char *x, ...)
 
 static void usage(void)
 {
-	printf("slabinfo 4/15/2011. (c) 2007 sgi/(c) 2011 Linux Foundation.\n\n"
-		"slabinfo [-aADefhilnosrStTvz1LXBU] [N=K] [-dafzput] [slab-regexp]\n"
+	printf("slabinfo 4/15/2017. (c) 2007 sgi/(c) 2011 Linux Foundation/(c) 2017 Jump Trading LLC.\n\n"
+	       "slabinfo [-aACDefhilMnosrStTvz1LXBU] [N=K] [-dafzput] [slab-regexp]\n"
+
 		"-a|--aliases           Show aliases\n"
 		"-A|--activity          Most active slabs first\n"
 		"-B|--Bytes             Show size in bytes\n"
+		"-C|--ctor              Show slabs with ctors\n"
 		"-D|--display-active    Switch line format to activity\n"
 		"-e|--empty             Show empty slabs\n"
 		"-f|--first-alias       Show first alias\n"
@@ -121,6 +126,7 @@ static void usage(void)
 		"-i|--inverted          Inverted list\n"
 		"-l|--slabs             Show slabs\n"
 		"-L|--Loss              Sort by loss\n"
+		"-M|--movable           Show caches that support movable objects\n"
 		"-n|--numa              Show NUMA information\n"
 		"-N|--lines=K           Show the first K slabs\n"
 		"-o|--ops               Show kmem_cache_ops\n"
@@ -588,6 +594,12 @@ static void slabcache(struct slabinfo *s)
 	if (show_empty && s->slabs)
 		return;
 
+	if (show_ctor && !s->ctor)
+		return;
+
+	if (show_movable && !s->movable)
+		return;
+
 	if (sort_loss == 0)
 		store_size(size_str, slab_size(s));
 	else
@@ -602,6 +614,10 @@ static void slabcache(struct slabinfo *s)
 		*p++ = '*';
 	if (s->cache_dma)
 		*p++ = 'd';
+	if (s->ctor)
+		*p++ = 'C';
+	if (s->movable)
+		*p++ = 'M';
 	if (s->hwcache_align)
 		*p++ = 'A';
 	if (s->poison)
@@ -636,7 +652,8 @@ static void slabcache(struct slabinfo *s)
 		printf("%-21s %8ld %7d %15s %14s %4d %1d %3ld %3ld %s\n",
 			s->name, s->objects, s->object_size, size_str, dist_str,
 			s->objs_per_slab, s->order,
-			s->slabs ? (s->partial * 100) / s->slabs : 100,
+			s->slabs ? (s->partial * 100) /
+					(s->slabs * s->objs_per_slab) : 100,
 			s->slabs ? (s->objects * s->object_size * 100) /
 				(s->slabs * (page_size << s->order)) : 100,
 			flags);
@@ -1256,6 +1273,13 @@ static void read_slab_dir(void)
 			slab->alloc_node_mismatch = get_obj("alloc_node_mismatch");
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
 			chdir("..");
+			if (read_slab_obj(slab, "ops")) {
+				if (strstr(buffer, "ctor :"))
+					slab->ctor = 1;
+				if (strstr(buffer, "migrate :"))
+					slab->movable = 1;
+			}
+
 			if (slab->name[0] == ':')
 				alias_targets++;
 			slab++;
@@ -1332,6 +1356,8 @@ static void xtotals(void)
 }
 
 struct option opts[] = {
+	{ "ctor", no_argument, NULL, 'C' },
+	{ "movable", no_argument, NULL, 'M' },
 	{ "aliases", no_argument, NULL, 'a' },
 	{ "activity", no_argument, NULL, 'A' },
 	{ "debug", optional_argument, NULL, 'd' },
@@ -1367,7 +1393,7 @@ int main(int argc, char *argv[])
 
 	page_size = getpagesize();
 
-	while ((c = getopt_long(argc, argv, "aAd::Defhil1noprstvzTSN:LXBU",
+	while ((c = getopt_long(argc, argv, "aACd::Defhil1MnoprstvzTSN:LXBU",
 						opts, NULL)) != -1)
 		switch (c) {
 		case '1':
@@ -1376,6 +1402,9 @@ int main(int argc, char *argv[])
 		case 'a':
 			show_alias = 1;
 			break;
+		case 'C':
+			show_ctor = 1;
+			break;
 		case 'A':
 			sort_active = 1;
 			break;
@@ -1399,6 +1428,9 @@ int main(int argc, char *argv[])
 		case 'i':
 			show_inverted = 1;
 			break;
+		case 'M':
+			show_movable = 1;
+			break;
 		case 'n':
 			show_numa = 1;
 			break;
-- 
2.21.0

