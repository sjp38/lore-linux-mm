Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1B18C41514
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 01:40:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 888E22190F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 01:40:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H2461pL6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 888E22190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB91C8E0021; Wed, 24 Jul 2019 21:40:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6A5E8E001C; Wed, 24 Jul 2019 21:40:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C58C18E0021; Wed, 24 Jul 2019 21:40:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A71628E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 21:40:48 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id r27so53130712iob.14
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 18:40:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=oXN5GwXNrqWezDYAWTbIPylSr9KykD38a2m5LA5Vzvk=;
        b=S9e0zjbIM6I3Buovtjm9Jx1zh3JW3EcozuMZH/A21OESzPF1lwLa2dPmfQXfAj6GY9
         hyZf/ZpDSKKUiJmFYh8rwQlll7tMGaLCkWJFBX4SUJ0bkohHjl9gLiCUZIjlyQB500Pe
         u2r02s4JU7VoewjTocHaqhu3enagyHGm7IINZTnYO3BBEWY4GVazOJKdZIW0cXpqsY5k
         vEiPjju46jrUctutAuj1h+KZ1NCO8CVU5q2R+iS/w3yQIWORRxtZw5XNaybVi4DzBMAt
         oRlmbFXWKZy9aAT7oIdpN4yptBjhSwbsn+d8ZiNCC98ZgEp7L2N2AXB/LmPNOCSb+IPg
         3izg==
X-Gm-Message-State: APjAAAV/ZUYlsdeRmqaSgJbJMo4abz12pxdT6BhJiVzdT5p65s1K9DGk
	5bB5vpkYt39JgvlXJsL1XbmM9W+Kaqj49zom5vWwKiduwtcd1zRtUAc0RC4rCdI8kXqMejyQIo6
	JxV+ASyLrnWarN0F+UAwpBQ8fWP1IMq53RbCGuL8xCc8v7WSITrJlbRY4dp4Sck/Evg==
X-Received: by 2002:a6b:7909:: with SMTP id i9mr48161269iop.8.1564018848411;
        Wed, 24 Jul 2019 18:40:48 -0700 (PDT)
X-Received: by 2002:a6b:7909:: with SMTP id i9mr48161229iop.8.1564018847644;
        Wed, 24 Jul 2019 18:40:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564018847; cv=none;
        d=google.com; s=arc-20160816;
        b=C6ViYzf0c6H0mHhyJipWPOeZDuctnrQsoNKgH7Fm0uKj+mKUhKzHfxye++qZq0chlt
         WQMuZQZih425PHQNxgWsGpnVATfzP51sj39yFukXwcIdEWzB8AHbOpcm5Z+rNBy8Sg8n
         ho9cGJqwU+1xAaDU87CrgFVHoFycUad6XnZwvmBTwmH6nI/1uucb+5xosfrIxE91KA6a
         cqB+o8xs/+bW3e2I/EjeHXOXvGnOryMrgsJm1fJc277EizBcyWg6f5nKUDb5ktASw1oq
         bntoBRNVwX8YRgC9apXntLotz3psMprUxgkwNwGP+qnU3M2yxDEYWX0KoHCMMBvArezs
         M9rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=oXN5GwXNrqWezDYAWTbIPylSr9KykD38a2m5LA5Vzvk=;
        b=aVKIhvbkkSQ766iil9Ku+qkJTEHbOvgRwgCoiDcRP0Tvk7Zye4kzTR+SUwjzn8VToP
         ur5t9rNFBHI55xR0WnS+mnifGqNMaOlMD9akSMFDu/qnh56mec8Hp/MghfSrN9Y8FMos
         sXifvscdTpkIw/RgYOxU36bSJQRkqrXmEaDjx8hux7vS9kLaXu7GLbojyoA5EAwT/W3f
         ApVE/xWUbVSrAZCUDdU4V6sCCtZhefQ5MQs0bkx+tfSGWDc3Kf0DWtm+RFvycvuhwbAl
         RlNR4WAteWYYFIeEMSLevvhMeVeqGmXVWtfQSViHLaZLxXFnn96XirHehHTzzrfh0B4+
         y7Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H2461pL6;
       spf=pass (google.com: domain of navid.emamdoost@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=navid.emamdoost@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v8sor32053967ioj.68.2019.07.24.18.40.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 18:40:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of navid.emamdoost@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H2461pL6;
       spf=pass (google.com: domain of navid.emamdoost@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=navid.emamdoost@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=oXN5GwXNrqWezDYAWTbIPylSr9KykD38a2m5LA5Vzvk=;
        b=H2461pL6theAnpW5edW+3dqP8T5QMrpFl0SXGGIZnqB+ZlHIXGHeYrYrfnlBuLfUp9
         o+DcklySifYG765de/M6SgutOlGYOP4WF5mJtz1jTM2lOmhvJX9V6DhHKgn2HOScs53e
         IzBcWiOROr/uvNK+aKEyV/oc1kulroh6fFFau4kjUzN5aRYuMC+51OMqOcoZLa0nC2bS
         8+BoGmCcQceVuXdjrqbcfXyFNI4xY1/t62QHTPZefRz7oOXBCShHxOwzmafADOk8VhJX
         gLdEGHfYCnCmIhAozPvWbPT1+3C7/khPdVJ4aX000z8Dz28NjCaJoqArS2QvPkpIHpQM
         slfg==
X-Google-Smtp-Source: APXvYqwZV+csN65QFH3c/+ek2MRlo4Jzp+G1GLrE+iP8KG1lV2GK5/itgNtY2zuUMy76j+9IordQ7Q==
X-Received: by 2002:a02:aa8f:: with SMTP id u15mr88348318jai.39.1564018847231;
        Wed, 24 Jul 2019 18:40:47 -0700 (PDT)
Received: from cs-dulles.cs.umn.edu (cs-dulles.cs.umn.edu. [128.101.35.54])
        by smtp.googlemail.com with ESMTPSA id h19sm32973203iol.65.2019.07.24.18.40.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 18:40:46 -0700 (PDT)
From: Navid Emamdoost <navid.emamdoost@gmail.com>
To: emamd001@umn.edu
Cc: kjlu@umn.edu,
	smccaman@umn.edu,
	Navid Emamdoost <navid.emamdoost@gmail.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/hugetlb.c: check the failure case for find_vma
Date: Wed, 24 Jul 2019 20:39:44 -0500
Message-Id: <20190725013944.20661-1-navid.emamdoost@gmail.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

find_vma may fail and return NULL. The null check is added.

Signed-off-by: Navid Emamdoost <navid.emamdoost@gmail.com>
---
 mm/hugetlb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ede7e7f5d1ab..9c5e8b7a6476 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4743,6 +4743,9 @@ void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 {
 	struct vm_area_struct *vma = find_vma(mm, addr);
+	if (!vma)
+		return (pte_t *)pmd_alloc(mm, pud, addr);
+
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
 			vma->vm_pgoff;
-- 
2.17.1

