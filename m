Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89A2EC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8854920868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="NWo/t5Eg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8854920868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3626B6B0286; Thu,  6 Jun 2019 14:45:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 299C86B0287; Thu,  6 Jun 2019 14:45:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0ED5E6B0288; Thu,  6 Jun 2019 14:45:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DBA6A6B0286
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:59 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k13so2784626qkj.4
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=m5r23PQEATRs0yuo7EiwMQdVkzY1U+YCz5n+ShEeoJ4=;
        b=o5HYA0YDcOKvnJ+of5HeyjSx7gD5OJinuMKqRwfZ0pNvCPFGWGCfqWZ91g2PdO43WN
         RDadySjgdfmR+ACfUw9TwjPN95mlxLxlDH+rBbEbawVcmHTE0Faud7bJwocKuqlU8buj
         XcQtKd8ufy746Ldff1Nm0APaIfSOM/ZcUESk3Yt1eH422gqpvljSS+GcJFRf90/Ft0p2
         1NLa3MdUzUvOQFVdlUmJ8pjqsq93f2IgchqqRGuxrABl7ZDwvsjRlHBQ7BxaSW1nbABF
         Dp1gSXP2X98H4XjkJHvPck7TCLAv3Mr2Iy5W1guL/ZfUuTiZhY+B9LZE62n4PiBx9Jvo
         wi+g==
X-Gm-Message-State: APjAAAWs0TF/gd0C2BXX8aJK0Hm+hggSN+GPLfO+AMN+9a2B5Hlb8SNF
	/FgAysaz4M8l4LbDlaG8fxiR/EG7Rw/Z1MqOvbX3cxUjE7HgACkNsT2ud5g5tJaiT1Rd/35WTdb
	u2EnWkFxQlpXO3eSbklbciSmZKSsYComh6KANILHL8Al1wHH5POJRSl88z/ozhEJ08g==
X-Received: by 2002:a0c:8b49:: with SMTP id d9mr39265537qvc.63.1559846699484;
        Thu, 06 Jun 2019 11:44:59 -0700 (PDT)
X-Received: by 2002:a0c:8b49:: with SMTP id d9mr39264968qvc.63.1559846690575;
        Thu, 06 Jun 2019 11:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846689; cv=none;
        d=google.com; s=arc-20160816;
        b=ef6idjr38wp9bZ2JqlDX54v2LCBOr920g0oygAmC7fiMZ7wZKganvKR8X+69+eEd8Q
         3eSwbB0O1JBwCzXZBcVnZkF355We5axKXD8tfa5jZE6okFFpLyIGeaAOeSXQUsaDSE/g
         danZqHYqlrUvQpit94T07XPuAasX9oyAGsiJMmVC1jN4+pyEvcgnyIBYC/o+FzrgfQMn
         WaWDkJWlOpHLhS60IhcqBAs9h82oUvzpBqBXPDirleP+RVQtaPO0g82MOlOyIeceVYFr
         IUZLJjQ0wlAXwtE6lF4hD++RZ+n7QmlhsqFR2DNGgKTDwWmLVOz8DrpG/x36yuU2PAmJ
         aY5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=m5r23PQEATRs0yuo7EiwMQdVkzY1U+YCz5n+ShEeoJ4=;
        b=n+XAh67Co7tDY2TQSGO2pXyDuMVy3a63ZoB2LEG7+0OjEh6opuPT+2WkI82SES88f9
         antgoYsbvyuv+9Ob9DkSNd2hdie4bzumYbdN1oId+dW+3lfmp2/lYmj5t28eTHL/KFJM
         QuTDrfKDLr0q4it4yg+zfBrX/lIjkX7sm+dgW8kQmlIzYb60K1GLc9xiCLce80W8HITW
         duMdfzTJeD3JvaGR1ahOcqItorCgbVHbyKRZAd7MvjNi2yqIIT1+ZX49LS4vxU4FIeSN
         RnmmPsZTqpy5mVvXa+nQQYJHwByE0RW98q8PIlkizcsRtmbXepzjcBHgmGFarBlxQa/e
         O/Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="NWo/t5Eg";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o65sor1458877qkd.6.2019.06.06.11.44.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="NWo/t5Eg";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=m5r23PQEATRs0yuo7EiwMQdVkzY1U+YCz5n+ShEeoJ4=;
        b=NWo/t5Eg8vkPop9rmLEJM24/TPCJSDGLkfJSg++y8tqe0YH7o0F0c+BLBxXYqlWbHn
         TQBM+rvo5UiyMgZHvqK7Pvgn4ARc08XbQ20YAC3fqCirAP5zyCBTuaRKGYQxA5+ez9MY
         5dtAcK3pg10dTEX2QJmbgVOe2q4izOeIa/IhaKfFTg1LtlOqd5CgPkliph8c0pVndS4n
         r9g5yTZjE2Bz4PyNamQroNF8IT3K4ojSe1Y0KMRcIsSxPFsRL0WgkcnPYGMbxXNaACfs
         /YPv4ioHw6zlpgsrcrlglyXYrBLyXki3e7XQt67BaOsoljLrmJ+pampgcg1bCjvTHEk3
         u1yw==
X-Google-Smtp-Source: APXvYqyDTfgtep66c/jLgBTZULmgoKmkAN7hyfuI/DrREbp9gQ0U06D4ocKYi5xCroJDWLKbh/kYjQ==
X-Received: by 2002:ae9:c30e:: with SMTP id n14mr34724569qkg.220.1559846689590;
        Thu, 06 Jun 2019 11:44:49 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s64sm1267327qkb.56.2019.06.06.11.44.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008Ir-QZ; Thu, 06 Jun 2019 15:44:45 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v2 hmm 09/11] mm/hmm: Poison hmm_range during unregister
Date: Thu,  6 Jun 2019 15:44:36 -0300
Message-Id: <20190606184438.31646-10-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190606184438.31646-1-jgg@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

Trying to misuse a range outside its lifetime is a kernel bug. Use WARN_ON
and poison bytes to detect this condition.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
---
v2
- Keep range start/end valid after unregistration (Jerome)
---
 mm/hmm.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 6802de7080d172..c2fecb3ecb11e1 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -937,7 +937,7 @@ void hmm_range_unregister(struct hmm_range *range)
 	struct hmm *hmm = range->hmm;
 
 	/* Sanity check this really should not happen. */
-	if (hmm == NULL || range->end <= range->start)
+	if (WARN_ON(range->end <= range->start))
 		return;
 
 	mutex_lock(&hmm->lock);
@@ -948,7 +948,10 @@ void hmm_range_unregister(struct hmm_range *range)
 	range->valid = false;
 	mmput(hmm->mm);
 	hmm_put(hmm);
-	range->hmm = NULL;
+
+	/* The range is now invalid, leave it poisoned. */
+	range->valid = false;
+	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
 }
 EXPORT_SYMBOL(hmm_range_unregister);
 
-- 
2.21.0

