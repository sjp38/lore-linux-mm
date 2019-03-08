Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6C1AC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8982220851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="8PgI+TUX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8982220851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A4088E0006; Thu,  7 Mar 2019 23:15:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 252E08E0002; Thu,  7 Mar 2019 23:15:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F6938E0006; Thu,  7 Mar 2019 23:15:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D77D18E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:12 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id i3so17348812qtc.7
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=O+DTezmhhc3P3jb0PBTMRAkkiTEY+lCxD+tCh+cgBHo=;
        b=VkkJOYSTAidUINmFaWx59iFq0Z4eMM5xOmY+KFUVMTRumYm9pIKud1txg75QsTuqvF
         oCShhvFKZiKCROr72rCwYEkWsBarQx11SKSoiEL4AuJY4LwCtmkp7lm1sSf73BQtnra2
         2c1w5uq+4iT86Z9v1IYsy/Ux4/RwZ322EfT94HPaPYLANoxMPNlwMETRLcHkpJ4tQO5h
         TEM8OK/TxWUEpESa8UwkxUetlwMnuDJq3Q91rrbD9CJUBHBL5rjt09cAWUumCojw8BDC
         X4Iwt9/0wcBoL+pWpZOXlne9r802EE4pjxI3GKc8Fm8JtYghdFFr9K8aRQ2sIlD7QkIk
         wrng==
X-Gm-Message-State: APjAAAXQUAPbEupgyPMvsvW3hXmHakNBll5NmqxzVQvx03pSgiw35d4O
	KYC9fQZrMXUzuh1Tw3Rdux08rfrko/vhSMzbV1RLXd+k5CJZX0YzNW2XE2rka63T9MToN+9sv6q
	/1tjP3C1/LtowtNGecmL5VOqJwKgVDe43bVBtErahDZbudU60tJ1KuEWy6rFbd3s=
X-Received: by 2002:ac8:1b24:: with SMTP id y33mr12811447qtj.111.1552018512633;
        Thu, 07 Mar 2019 20:15:12 -0800 (PST)
X-Google-Smtp-Source: APXvYqwh/3PchvHnGZ/7Nz/QB9B3jeW57U5oeWRs304vQNdq78Hgz1lJU3MLhkjh2Kuh+MrWlucz
X-Received: by 2002:ac8:1b24:: with SMTP id y33mr12811391qtj.111.1552018511343;
        Thu, 07 Mar 2019 20:15:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018511; cv=none;
        d=google.com; s=arc-20160816;
        b=gdv3g0IgqrZzO11F58+9Qf7mwr9kYccIswdTbuGQUe4HUUHNhDi/EBEZqPLsQQKes+
         o3xZUnfGkBDaMfgywZDHasciuu6XNB+qeUNUekpChPo9O53CzjGciCRgR3fqPhBQnvzS
         aDf0hjLT1ryN7/qKLY67A2u+8KJrlvbfXaHH1HnUyTxWNHPpmOJsz5mgraNJbBUhTbAu
         oId+ngXvNx2Jb2vcV/uVBRWMpyZ0phSoh3mRKp4SUu0up2mIt+O/VBLpfryIv/nVmB+W
         5b0O3utsZFHcnJFfdfuTcD2pwXUaU6Cx6vUl55HenGY2DzpENxdSn5OZG7SoeL6KiKD3
         Rwbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=O+DTezmhhc3P3jb0PBTMRAkkiTEY+lCxD+tCh+cgBHo=;
        b=OKm5EqPByp/uA5YTbQuN+QafoM1t5ItD46hSvgEVQjKQk7bdzpslu3Xlz/zQ4VSbA5
         7GQpyBEAmB63So/fyC0NVs3KM9QXenFPrpizXhltSwZm5yvZJ5wOw/hrf4yi/lOmUfrk
         4sTviRWOyXel4fhW8JMIQd0K9Uubt9624EiVEySlhLzjhyPHEMBjPGgDy4e4WqDjtsw+
         lV6IddyKvu07rWxo+N9YrbntnMqxcjAXIVsYZKsBVHNvBvSjKMuk16OkGoMSOE/vBUbZ
         i/n/IBuh+ro7Q/bMQck43K4zU6ofIpNooieklqWMPFkoNILjNi1WlIYSv5zJ8uyI1dXQ
         riAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=8PgI+TUX;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id k14si4234707qtf.371.2019.03.07.20.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:11 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=8PgI+TUX;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id D3BD236A7;
	Thu,  7 Mar 2019 23:15:09 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:10 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=O+DTezmhhc3P3jb0PBTMRAkkiTEY+lCxD+tCh+cgBHo=; b=8PgI+TUX
	d++yguSzS1y5c4WM0fBOLRR6TTLDx4kG9oKzNZDHCt7viNyjm0wNEIkRA2Fu+psU
	cA9580Ry0ysSv/RbM3+27g2Qxf33jRydYnLfTfzG9/Nkeq+JVYxpx5HGJw0fzB3N
	/Oq8eG35zbMlg1GDqb/8ElS68ZgC2MjxbRgusH5jn1c4ICGVsBp0o1RLElQRR5Zj
	XjY82iFl2rl6cmxWytjWqJbAxlPyQs0WYstoQhzvCevIRyNr5nYvIcyGdevSc1xH
	X81e3CVfHUmEtf/E2C2kSOBpajX8kVjHdkDLd1BfjNR7ghG62GiYNbazFdIM1g6Z
	Dk7PaKdLfcclKw==
X-ME-Sender: <xms:TeyBXMQngIWs4Wro-cWjtU1EDL_Ex286kGT_mCyueHqqdfCc6c9LJQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepvd
X-ME-Proxy: <xmx:TeyBXOD7Hz0izU4eKfipnKxymz0nJyHpUA-GjOV3FIME4_sZBurxNA>
    <xmx:TeyBXE1rFPcjNicgsEz7eI1tMkmxOL4Itgn_ncwxI8lUqvOaC490SQ>
    <xmx:TeyBXEXnE0zIdZDUprUhdC12aKOS4mFK_db_s-6rNILWfQ3nAUxAyg>
    <xmx:TeyBXM_YwbhcI4q6pKMCaGrJKdtLjofWgXU-Zl4zT_RlzWVA1P3eEQ>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id 3CCD8E46B8;
	Thu,  7 Mar 2019 23:15:05 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 03/15] tools/vm/slabinfo: Add support for -C and -F options
Date: Fri,  8 Mar 2019 15:14:14 +1100
Message-Id: <20190308041426.16654-4-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190308041426.16654-1-tobin@kernel.org>
References: <20190308041426.16654-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

-F lists caches that support object migration.

-C lists caches that use a ctor.

Add command line options to show caches with a constructor and caches
with that are migratable (i.e. have isolate and migrate functions).

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 40 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 36 insertions(+), 4 deletions(-)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index 73818f1b2ef8..6ba8ffb4ea50 100644
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
@@ -109,14 +112,17 @@ static void fatal(const char *x, ...)
 
 static void usage(void)
 {
-	printf("slabinfo 4/15/2011. (c) 2007 sgi/(c) 2011 Linux Foundation.\n\n"
-		"slabinfo [-aADefhilnosrStTvz1LXBU] [N=K] [-dafzput] [slab-regexp]\n"
+	printf("slabinfo 4/15/2017. (c) 2007 sgi/(c) 2011 Linux Foundation/(c) 2017 Jump Trading LLC.\n\n"
+	       "slabinfo [-aACDefFhilnosrStTvz1LXBU] [N=K] [-dafzput] [slab-regexp]\n"
+
 		"-a|--aliases           Show aliases\n"
 		"-A|--activity          Most active slabs first\n"
 		"-B|--Bytes             Show size in bytes\n"
+		"-C|--ctor              Show slabs with ctors\n"
 		"-D|--display-active    Switch line format to activity\n"
 		"-e|--empty             Show empty slabs\n"
 		"-f|--first-alias       Show first alias\n"
+		"-F|--movable           Show caches that support movable objects\n"
 		"-h|--help              Show usage information\n"
 		"-i|--inverted          Inverted list\n"
 		"-l|--slabs             Show slabs\n"
@@ -588,6 +594,12 @@ static void slabcache(struct slabinfo *s)
 	if (show_empty && s->slabs)
 		return;
 
+	if (show_movable && !s->movable)
+		return;
+
+	if (show_ctor && !s->ctor)
+		return;
+
 	if (sort_loss == 0)
 		store_size(size_str, slab_size(s));
 	else
@@ -602,6 +614,10 @@ static void slabcache(struct slabinfo *s)
 		*p++ = '*';
 	if (s->cache_dma)
 		*p++ = 'd';
+	if (s->movable)
+		*p++ = 'F';
+	if (s->ctor)
+		*p++ = 'C';
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
+	{ "movable", no_argument, NULL, 'F' },
 	{ "aliases", no_argument, NULL, 'a' },
 	{ "activity", no_argument, NULL, 'A' },
 	{ "debug", optional_argument, NULL, 'd' },
@@ -1367,7 +1393,7 @@ int main(int argc, char *argv[])
 
 	page_size = getpagesize();
 
-	while ((c = getopt_long(argc, argv, "aAd::Defhil1noprstvzTSN:LXBU",
+	while ((c = getopt_long(argc, argv, "aACd::DefFhil1noprstvzTSN:LXBU",
 						opts, NULL)) != -1)
 		switch (c) {
 		case '1':
@@ -1423,6 +1449,12 @@ int main(int argc, char *argv[])
 		case 'z':
 			skip_zero = 0;
 			break;
+		case 'C':
+			show_ctor = 1;
+			break;
+		case 'F':
+			show_movable = 1;
+			break;
 		case 'T':
 			show_totals = 1;
 			break;
-- 
2.21.0

