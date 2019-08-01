Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53E52C32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2377820693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2377820693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDC448E0008; Wed, 31 Jul 2019 22:18:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8DDD8E0003; Wed, 31 Jul 2019 22:18:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A31E58E000A; Wed, 31 Jul 2019 22:18:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64D918E0008
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:03 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id k9so38653286pls.13
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yJIi7kQG62nMwnJ47jDyvR1n1Z0LdKvDaJwlq08Hgfk=;
        b=sc0PE3IHOyHNln+P8e7it2UGA/F+swGXEmjeSXXA4UWxNVqk/4pJ63/UujqrkLTV97
         PhSnpLsiWWrsYrFtIGE2cTOv3EVAtGf5TjKu+LHqP0+rK1HElZdCUaSK+xWQtTIwVURA
         Zo1qK5tk+fooow+nwtxeCHgpHh7juhqS1Au/A3d4MfigVmXuSAKKJz42DPM5GFO1/Mgz
         YDG1kf2peqr0p35TBjJ78dFPMqRkYB+eofP5z9nCxMi8Y4EP1OSXQRos1HPAQPCOJAdA
         +3EJcqCorBEQNVK2TvssBd/L8y9u3qLKFA0QGmeWPCCfR0lx4ddLtJ+aLXZNdRHAs9y7
         WH2Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVVYYfgonocZWHCKmmHHuZDsWXgL/d/aL6ueivC9tv70Q5cf2aG
	5nTJV4xtkDl8HSfcANadfADk2snew6MoZt3ogvjjm3UtF7dn2S6dnad3WY4KaqFfHhemrgOCD1X
	TMMhOf9rAhMeN9ngrjtP1ryCvJZ+DGJOPRUsZNbaRXiRYOKNxj++0Zd30EyAlo3o=
X-Received: by 2002:a62:303:: with SMTP id 3mr50294158pfd.118.1564625883054;
        Wed, 31 Jul 2019 19:18:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjB1doqOjBf2LmPoPfXpHs4wYm/ZdedtIk3ycExqbyJy6xUQ/p88MjlfBKrN+rO35+RM9o
X-Received: by 2002:a62:303:: with SMTP id 3mr50294057pfd.118.1564625881467;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625881; cv=none;
        d=google.com; s=arc-20160816;
        b=cfdnrfey+5OGBRdtB/tC7/0hFQE3Iyd4KX02YO1UwbZ83YT5V/+LBR3CGFaQpujA7j
         oSldDTLf/9dDpLcfBxgL0Zp30oJDpr578Q1tqETzccQvlMEbUI6sD28NZcEvhRme6NFW
         tfsI+4oYwXUfvLwdMgo7va60uTK7xMeiBgqTpGl1OGruExbF86+pYp2QvvrWwWade8BJ
         0nRui5uJWgmvSbbOGlfTBLZZDBn0vulrM1OilxP4/josvoFZ53KXDeqI/NA57/M9YCXI
         0bHJ1J0Reve2JiNi45LdGPFNdsJgkoVDL4Mujivnl8g3IB6I5WoQJafhJZKciTZxfjDT
         XkPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yJIi7kQG62nMwnJ47jDyvR1n1Z0LdKvDaJwlq08Hgfk=;
        b=A2q/dSWXBlZtfUhUfAhjfehecse1NsZf/ru33QJedHsJW81yCvLSIpwtxzecc2huSP
         kI6D2j0PjG5/FjLrh3pAV7hi20xv34T8e3RaHsrbCnEZ2bDOa+m8hQcruj19pNczNynI
         l+EAQMgNzEAmcwIY6Qa/5ZoTjwTD6zeErpsz5rTaAzPUYd1f5ynJD1qkYDLBZF1V9k+k
         1gT0GgdKWLQPIgg4uKPD3/tJMyZSWVs4YFA5dl9yQ3Jyi3C1ke3io/dTgxy8Sx8X/d/N
         W7xuNGNi71tSCLbihDzyKvUZSbQCItMd18XSmfAjPBSOtW7auNX1tMe9GHYTCFa+QiEO
         9mTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id c1si30277329plr.405.2019.07.31.19.18.01
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id A1D8B361350;
	Thu,  1 Aug 2019 12:17:58 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eB-0003aw-3V; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fH-0001l7-16; Thu, 01 Aug 2019 12:17:59 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 12/24] xfs: correctly acount for reclaimable slabs
Date: Thu,  1 Aug 2019 12:17:40 +1000
Message-Id: <20190801021752.4986-13-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=q-nAjRHzglZ9esTleQAA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

The XFS inode item slab actually reclaimed by inode shrinker
callbacks from the memory reclaim subsystem. These should be marked
as reclaimable so the mm subsystem has the full picture of how much
memory it can actually reclaim from the XFS slab caches.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index f9450235533c..67b59815d0df 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1916,7 +1916,7 @@ xfs_init_zones(void)
 
 	xfs_ili_zone =
 		kmem_zone_init_flags(sizeof(xfs_inode_log_item_t), "xfs_ili",
-					KM_ZONE_SPREAD, NULL);
+					KM_ZONE_SPREAD | KM_ZONE_RECLAIM, NULL);
 	if (!xfs_ili_zone)
 		goto out_destroy_inode_zone;
 	xfs_icreate_zone = kmem_zone_init(sizeof(struct xfs_icreate_item),
-- 
2.22.0

