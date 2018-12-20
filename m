Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EEB1C43444
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1451A21904
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="G61d0PPs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1451A21904
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAC0C8E0013; Thu, 20 Dec 2018 14:22:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB31D8E0001; Thu, 20 Dec 2018 14:22:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B367A8E0013; Thu, 20 Dec 2018 14:22:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8069E8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:22:03 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 41so2902871qto.17
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:22:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject:references:mime-version
         :content-disposition:feedback-id;
        bh=GqEKdOJa4NqL/PJEDbtnXVuUXZJi3QIuuXaA6btbLhU=;
        b=nHReTCOiqL3G6yYp7eWlO2T+A2vlrC10+skBDJsm0pv12mhQnppktoyjtDQp6Rk8zM
         WWlKgPfockxxpAwLQDgmpZjJobFU8BC2jzevtssSzX4nBL6HTHYECTL9r0FDjoRdGDJz
         BGFW6/u4ZZbWr8WArjjIo0Cwk8gbw4K3WWkMd+6FLho7XtiPbNU6K/Wrd80sZGr/nN3X
         tZkKOj09WGY9HPiES1l9EeoGgKs4ckPlvYBv+6iofqgXTd2XKOohD18jd5kIS4O6vmO1
         7zJf3rNEX783EAP9wvQo0wr4x1O+ShOwfU0r7kG9m6QvYajYa17nGhipGqswCun3NKA5
         tzEQ==
X-Gm-Message-State: AA+aEWa3bnjyc42Ld5bJfyWPGIzdDEby3WFbGlj2RNRfvGScJW7TACW6
	7bAqTt9aZ9ee84uisSFJqD2OZOyRHQ+VaAwpCpJY5jvZsNs0VBPnwXmCX1/Dy+NbKo2j9PZ2ZGQ
	AEzOMfysqkQ+fVPiwWJ1OfgQ89+U8QQdI8dFJGP736qKAvynwPjJV63x2Vxt8UT8=
X-Received: by 2002:ae9:ed89:: with SMTP id c131mr25660818qkg.222.1545333723277;
        Thu, 20 Dec 2018 11:22:03 -0800 (PST)
X-Google-Smtp-Source: AFSGD/WI62eyyVDJjUj9H6eiZtREibPLWBQmWzKIMSBDNbCMz6nwr/y9Q/68GW7haJBI8wB00yb+
X-Received: by 2002:ae9:ed89:: with SMTP id c131mr25660797qkg.222.1545333722816;
        Thu, 20 Dec 2018 11:22:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545333722; cv=none;
        d=google.com; s=arc-20160816;
        b=fYXuctYSgOla2BRAZ7fkB8vSCMst1lv/UlfSncTHm+zpa22uzdMVQJA9UTQh9o2ilM
         oMYSuXGnrNWcYCvHDm8BYUvrv5Q0bPMoXsa0Aq2tLfhSRksnsE8wuQZvPa7xf98gi/cp
         aC9DdaMe134FTN8i7L70kQ05v2XqkLnhFCoyYecMuJnNjYuVQkIoF69afxP6I6K12/Nj
         yGlcQeEtWL4ab2XBCCWKQWGMUL9rZi7cNns8x1mWZKAUQegDrkn31sthpGFIAfpd88hJ
         skBaMO6//e1O5CRtvg3iYWyxC2HSwPNqgIKmZxHAFH0Tm2/VeSl99UDP4LxIKLZpUvov
         aruw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:content-disposition:mime-version:references:subject:cc
         :cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id
         :dkim-signature;
        bh=GqEKdOJa4NqL/PJEDbtnXVuUXZJi3QIuuXaA6btbLhU=;
        b=v6mVioNm2bsl/veC5+XXckWZZXaDP1H4zBhcZjqWaV+BliDaVyh9XHKAUtbFJylb1C
         ESPhTz0kbwbzfjlPC2/qekYwUamYlfcdaioOEJu++USM72D+fNyP/g+SN24Dj6+p1dok
         WrxpWL/8XSktnGIdHWib1LmN1TAkKdpk1XHcNudUxaNjfIYyfe9ePajvzfElHXEdHZGK
         vfXcuEsP1aPqnnE6EQnFyjST3HGw/zU2OSCiKy271cuIFLUD5gURmx29/WFlN1Z+f0Zx
         HCu8ed79yK8HaZE6ZOSFG/ZUG4IVbarR9nt76PqJiMv/NKFxf3YeqZT1iYH1kry90gNv
         HHmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=G61d0PPs;
       spf=pass (google.com: domain of 01000167cd114cfc-077a81a2-a425-4578-a5af-89d000f59749-000000@amazonses.com designates 54.240.9.112 as permitted sender) smtp.mailfrom=01000167cd114cfc-077a81a2-a425-4578-a5af-89d000f59749-000000@amazonses.com
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id j62si2339122qkj.139.2018.12.20.11.22.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:22:02 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000167cd114cfc-077a81a2-a425-4578-a5af-89d000f59749-000000@amazonses.com designates 54.240.9.112 as permitted sender) client-ip=54.240.9.112;
Authentication-Results: mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=G61d0PPs;
       spf=pass (google.com: domain of 01000167cd114cfc-077a81a2-a425-4578-a5af-89d000f59749-000000@amazonses.com designates 54.240.9.112 as permitted sender) smtp.mailfrom=01000167cd114cfc-077a81a2-a425-4578-a5af-89d000f59749-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1545333722;
	h=Message-Id:Date:From:To:Cc:Cc:Cc:CC:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:References:MIME-Version:Content-Type:Feedback-ID;
	bh=BCm2PiyMf3tx6ZvzxPPkAP12ULxpZW06gS2AyjZcLp8=;
	b=G61d0PPsXs+Tscj8XOVELBwbPKNf0QVDMLAyIG79j+4VmVPBVzFJG5Dz0m/9PH2h
	ry86kMX1hOxMd6oDUO344KEEn9bQUqwhIDCnskTOtohaz/7Sf0sRWOibU7TT1d9AcwP
	bhouU10HazEhSJ9aeKk0WJh6roPvH8OD7Ou55ljE=
Message-ID:
 <01000167cd114cfc-077a81a2-a425-4578-a5af-89d000f59749-000000@email.amazonses.com>
User-Agent: quilt/0.65
Date: Thu, 20 Dec 2018 19:22:02 +0000
From: Christoph Lameter <cl@linux.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
CC: akpm@linux-foundation.org
Cc: Mel Gorman <mel@skynet.ie>
Cc: andi@firstfloor.org
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC 6/7] slub: Extend slabinfo to support -D and -F options
References: <20181220192145.023162076@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=extend_slabinfo
X-SES-Outgoing: 2018.12.20-54.240.9.112
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220192202.YFPFuACjJRUxLKXshVXKGbPCgQy9oEcuF4Riw1aqQFQ@z>

-F lists caches that support moving and defragmentation

-C lists caches that use a ctor.

Change field names for defrag_ratio and remote_node_defrag_ratio.

Add determination of the allocation ratio for a slab. The allocation ratio
is the percentage of available slots for objects in use.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 Documentation/vm/slabinfo.c |   48 +++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 43 insertions(+), 5 deletions(-)

Index: linux/tools/vm/slabinfo.c
===================================================================
--- linux.orig/tools/vm/slabinfo.c
+++ linux/tools/vm/slabinfo.c
@@ -33,6 +33,8 @@ struct slabinfo {
 	unsigned int hwcache_align, object_size, objs_per_slab;
 	unsigned int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
+	int movable, ctor;
+	int defrag_ratio, remote_node_defrag_ratio;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
 	unsigned long free_fastpath, free_slowpath;
@@ -67,6 +69,8 @@ int show_report;
 int show_alias;
 int show_slab;
 int skip_zero = 1;
+int show_movable;
+int show_ctor;
 int show_numa;
 int show_track;
 int show_first_alias;
@@ -109,14 +113,16 @@ static void fatal(const char *x, ...)
 
 static void usage(void)
 {
-	printf("slabinfo 4/15/2011. (c) 2007 sgi/(c) 2011 Linux Foundation.\n\n"
-		"slabinfo [-ahnpvtsz] [-d debugopts] [slab-regexp]\n"
+	printf("slabinfo 4/15/2017. (c) 2007 sgi/(c) 2011 Linux Foundation/(c) 2017 Jump Trading LLC.\n\n"
+		"slabinfo [-aCdDefFhnpvtsz] [-d debugopts] [slab-regexp]\n"
 		"-a|--aliases           Show aliases\n"
 		"-A|--activity          Most active slabs first\n"
 		"-d<options>|--debug=<options> Set/Clear Debug options\n"
+		"-C|--ctor              Show slabs with ctors\n"
 		"-D|--display-active    Switch line format to activity\n"
 		"-e|--empty             Show empty slabs\n"
 		"-f|--first-alias       Show first alias\n"
+		"-F|--movable           Show caches that support movable objects\n"
 		"-h|--help              Show usage information\n"
 		"-i|--inverted          Inverted list\n"
 		"-l|--slabs             Show slabs\n"
@@ -369,7 +375,7 @@ static void slab_numa(struct slabinfo *s
 		return;
 
 	if (!line) {
-		printf("\n%-21s:", mode ? "NUMA nodes" : "Slab");
+		printf("\n%-21s: Rto ", mode ? "NUMA nodes" : "Slab");
 		for(node = 0; node <= highest_node; node++)
 			printf(" %4d", node);
 		printf("\n----------------------");
@@ -378,6 +384,7 @@ static void slab_numa(struct slabinfo *s
 		printf("\n");
 	}
 	printf("%-21s ", mode ? "All slabs" : s->name);
+	printf("%3d ", s->remote_node_defrag_ratio);
 	for(node = 0; node <= highest_node; node++) {
 		char b[20];
 
@@ -535,6 +542,8 @@ static void report(struct slabinfo *s)
 		printf("** Slabs are destroyed via RCU\n");
 	if (s->reclaim_account)
 		printf("** Reclaim accounting active\n");
+	if (s->movable)
+		printf("** Defragmentation at %d%%\n", s->defrag_ratio);
 
 	printf("\nSizes (bytes)     Slabs              Debug                Memory\n");
 	printf("------------------------------------------------------------------------\n");
@@ -585,6 +594,12 @@ static void slabcache(struct slabinfo *s
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
@@ -599,6 +614,10 @@ static void slabcache(struct slabinfo *s
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
@@ -633,7 +652,8 @@ static void slabcache(struct slabinfo *s
 		printf("%-21s %8ld %7d %15s %14s %4d %1d %3ld %3ld %s\n",
 			s->name, s->objects, s->object_size, size_str, dist_str,
 			s->objs_per_slab, s->order,
-			s->slabs ? (s->partial * 100) / s->slabs : 100,
+			s->slabs ? (s->partial * 100) /
+					(s->slabs * s->objs_per_slab) : 100,
 			s->slabs ? (s->objects * s->object_size * 100) /
 				(s->slabs * (page_size << s->order)) : 100,
 			flags);
@@ -1252,7 +1272,17 @@ static void read_slab_dir(void)
 			slab->cpu_partial_free = get_obj("cpu_partial_free");
 			slab->alloc_node_mismatch = get_obj("alloc_node_mismatch");
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
+			slab->defrag_ratio = get_obj("defrag_ratio");
+			slab->remote_node_defrag_ratio =
+					get_obj("remote_node_defrag_ratio");
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
@@ -1329,6 +1359,8 @@ static void xtotals(void)
 }
 
 struct option opts[] = {
+	{ "ctor", no_argument, NULL, 'C' },
+	{ "movable", no_argument, NULL, 'F' },
 	{ "aliases", no_argument, NULL, 'a' },
 	{ "activity", no_argument, NULL, 'A' },
 	{ "debug", optional_argument, NULL, 'd' },
@@ -1364,7 +1396,7 @@ int main(int argc, char *argv[])
 
 	page_size = getpagesize();
 
-	while ((c = getopt_long(argc, argv, "aAd::Defhil1noprstvzTSN:LXBU",
+	while ((c = getopt_long(argc, argv, "aACd::DefFhil1noprstvzTSN:LXBU",
 						opts, NULL)) != -1)
 		switch (c) {
 		case '1':
@@ -1420,6 +1452,12 @@ int main(int argc, char *argv[])
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

