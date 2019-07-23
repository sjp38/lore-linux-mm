Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A0F4C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:40:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00BA2229EB
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:40:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="xHY7KZzG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00BA2229EB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6AD96B0003; Tue, 23 Jul 2019 17:40:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1A896B0006; Tue, 23 Jul 2019 17:40:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 931508E0002; Tue, 23 Jul 2019 17:40:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6293D6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 17:40:09 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y22so22747423plr.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:40:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=L0Jlil94VkLt502zM+ZMPJ76q3F8rDbyXUBeAm9kIlc=;
        b=hFsMDUvKoR5aKK1iUsRItxxQJ5sDGk1UlDGF2KX+7qAtw45MLH0+Hn6TB5L5fXyoVC
         rl4OQcMGw0yLmgyS7rItp+mItRCuJbHiNVIVt6IxYodXeDN66P2Mv5q+Xp6cEFdl/BQO
         B6V83bY/nCrvuESwyTR1kNwLKFbWXsa8TpKtlVh9/kF6no/yq0l6UbRovNlQxAkgCvVM
         A1K2C8dLvjlhEro1CqAGFG2yjc0jpJKy71AbXuzFrRJQ/oicw/U9+dDxHGcSBudAMpdr
         aqa8Y/ZVNa+k4yEyeKjp36rjgv4gSXbevx7mUEzBXugClM3M9HWY2Y+3ahFm3FBaifhP
         IH/w==
X-Gm-Message-State: APjAAAVQYK4tVnun4B6OEfrp/jKhFifzzenMCzlBPWwwGgslnRQFzPZE
	MXzxd3ml6WP9lSe9oZeg2FjDnAjGfpe5+OBlqDtjFSZ37TWNKNx4twOPWOVoT8i/IxPMhkav//b
	L91ZExGPrkv9fFbECaZpEH4NE/b1dvZweUaaMBw1pdSXXhHMPUVTcMQ7dsM/nQ3qw2w==
X-Received: by 2002:a17:90a:2343:: with SMTP id f61mr85283327pje.130.1563918009021;
        Tue, 23 Jul 2019 14:40:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+MK6ipZLb4tJXlZ9Jg89lzaw3KdNCrcVJvPpFuSoZW+TZeJJcAzOa5qiH74HGgAzqng44
X-Received: by 2002:a17:90a:2343:: with SMTP id f61mr85283287pje.130.1563918008264;
        Tue, 23 Jul 2019 14:40:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563918008; cv=none;
        d=google.com; s=arc-20160816;
        b=lrUQmmdwoCmH6Jje5I0E5cm8U7N6xdMXFrCeBE2Eo1Ku3C6m626tfKmQwb9aakSrkJ
         fr6CNPgpnFnlhlyfD82J7KFnOQw2E0rnMCUfMBKmrN9ZvVzzPqY2ND0V92qVMQSvUdTn
         fG+LUYPznSOqoe6eXM+lQ/0p4972675r/71u4yyJ8Djn43ppf8pz1hyNtmSklc83lmOv
         V46XzADgKMUpu4c5uUGdM6ZvAs0ap4VNOJEoLUbOMzhbgUVk1xPl8m6+4fLYH3AYbaLk
         XgBSllUAd2csvhFcXZv+AVH6UKuhv3V+Qb5WnZqW0YCQ8x05bV1QFkS3l7NaZIpeVsDm
         VDoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=L0Jlil94VkLt502zM+ZMPJ76q3F8rDbyXUBeAm9kIlc=;
        b=ysbfRgXMP8G/CsgOuC6FzVpkiOX0SHiTNhxihSZTr8XnYtJA3oquUeO8PH8d2GYc6N
         RRC5/oP+sET3+PXWcNGyTlx5zEOAtgoYK2Dm/J6XAeSie96j2SI0vBMeUyToETXb67UR
         19QOZXp8WofxB+sCBmtLI3rS34xDmx2sKTpKuVBLwFewREJ+J1uXEmnoa9YSNGK9WmP/
         VMLLN+UeGVIEKlC3btt2nfUAlZCknFkMi44fWFYqGJjzg7xa4GL3TaC87xswuh7+5YSp
         ZYq9sr0+w/gDiqX6qPyNjTsRSLi1Q8spwCqxmqTSvfUFNl3u5Xgp3MTV/JPEe+5v+/89
         bBmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xHY7KZzG;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g94si39010640plb.142.2019.07.23.14.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 14:40:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xHY7KZzG;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B25322253D;
	Tue, 23 Jul 2019 21:40:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563918007;
	bh=M+0jZRNec2kYgBhUlCTZ6xhzUORSrzgFEY/0rUC4FDA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=xHY7KZzGgPlgJRPYSPpdIy0PXNS/cVB3IDriPis8s3heiFZad2UZaTStT+fkq4ZKg
	 x042oWhlspkN4vzGDXM9SBzZEbY5NNAj1m4O/D/N+kqpWhffdayGjj/vO+JjVrbCr/
	 jF9hhYpDnt2UQkBMfEfilGXMKzeCt0ngDdqyk+68=
Date: Tue, 23 Jul 2019 14:40:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Yafang Shao <laoar.shao@gmail.com>, linux-mm@kvack.org, Mel Gorman
 <mgorman@techsingularity.net>, Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm/compaction: introduce a helper
 compact_zone_counters_init()
Message-Id: <20190723144007.9660c3c98068caeba2109ded@linux-foundation.org>
In-Reply-To: <20190723081218.GD4552@dhcp22.suse.cz>
References: <1563869295-25748-1-git-send-email-laoar.shao@gmail.com>
	<20190723081218.GD4552@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jul 2019 10:12:18 +0200 Michal Hocko <mhocko@suse.com> wrote:

> On Tue 23-07-19 04:08:15, Yafang Shao wrote:
> > This is the follow-up of the
> > commit "mm/compaction.c: clear total_{migrate,free}_scanned before scanning a new zone".
> > 
> > These counters are used to track activities during compacting a zone,
> > and they will be set to zero before compacting a new zone in all compact
> > paths. Move all these common settings into compact_zone() for better
> > management. A new helper compact_zone_counters_init() is introduced for
> > this purpose.
> 
> The helper seems excessive a bit because we have a single call site but
> other than that this is an improvement to the current fragile and
> duplicated code.
> 
> I would just get rid of the helper and squash it to your previous patch
> which Andrew already took to the mm tree.

--- a/mm/compaction.c~mm-compaction-clear-total_migratefree_scanned-before-scanning-a-new-zone-fix-fix
+++ a/mm/compaction.c
@@ -2068,19 +2068,6 @@ bool compaction_zonelist_suitable(struct
 	return false;
 }
 
-
-/*
- * Bellow counters are used to track activities during compacting a zone.
- * Before compacting a new zone, we should init these counters first.
- */
-static void compact_zone_counters_init(struct compact_control *cc)
-{
-	cc->total_migrate_scanned = 0;
-	cc->total_free_scanned = 0;
-	cc->nr_migratepages = 0;
-	cc->nr_freepages = 0;
-}
-
 static enum compact_result
 compact_zone(struct compact_control *cc, struct capture_control *capc)
 {
@@ -2091,7 +2078,15 @@ compact_zone(struct compact_control *cc,
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 	bool update_cached;
 
-	compact_zone_counters_init(cc);
+	/*
+	 * These counters track activities during zone compaction.  Initialize
+	 * them before compacting a new zone.
+	 */
+	cc->total_migrate_scanned = 0;
+	cc->total_free_scanned = 0;
+	cc->nr_migratepages = 0;
+	cc->nr_freepages = 0;
+
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
_

