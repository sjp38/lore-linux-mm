Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1CA5C76188
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 09:56:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DED92084C
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 09:56:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DED92084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wanadoo.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D44FD8E0001; Sun, 21 Jul 2019 05:56:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF6B86B0008; Sun, 21 Jul 2019 05:56:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE4308E0001; Sun, 21 Jul 2019 05:56:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 84C486B0007
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 05:56:55 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id p13so17626030wru.17
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 02:56:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=x1og2ZNy3c497vm0LOnwUcH+1uTWURlAy/0lJrYTV7g=;
        b=JAeFbO2BWqIRtXQ+OmkQ2dNuNiFaYn5Gk5+jqaaNUGXyqVYf/1ro2WWjBh29huH/Xw
         rlhGxuDPVSQQoR/I7PCrqBfaBNVIBpqg+VWZJ+ju3iHD8GGLxEh97eEMeu9UKWPdPuAe
         eVFCz74vo9tMziF1MILcAX8S67USxAmaKP2hWmJJ6Aod4siQME+O53TM6uVrBOJcoqHp
         cL8b0Q4QeBe0ERRF9vJHnU0rlt6j+G6LhG2YTN6RXIEZf4gjOa8EIEhnvpzyDKaX6Lht
         ziCMDP9arGwxJ879UF1qo23N9N4/Gc518Cddwzeh8pEqFxjtp9/A6mHhie6Pqa1O/2Yg
         0H3g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 80.12.242.132 is neither permitted nor denied by best guess record for domain of christophe.jaillet@wanadoo.fr) smtp.mailfrom=christophe.jaillet@wanadoo.fr
X-Gm-Message-State: APjAAAWw9HA7KtbpWBj3wla5FEi2EF5GNobyLIWFazidthUNBEg2Gbtx
	ZL2VLupbbq75JQyDo2ZA7gVjEtpObwL+vrQMKZbVCfHD31uVZSpxmbyoljDj2dRP9GohueCM/XI
	DsVCi6WV5jTp+Djx/to+No9oYJDfp0bYKlCIVBAl/T1rsSpjg3+6fiPoFqtk9q3w=
X-Received: by 2002:a1c:18d:: with SMTP id 135mr58183441wmb.171.1563703015008;
        Sun, 21 Jul 2019 02:56:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgHJDrTGfJpAsxJXTE9YFELDkm5VAaPvDV5DksiZm6FMoLzid8pvvY8qRui7OYtOlm0GYi
X-Received: by 2002:a1c:18d:: with SMTP id 135mr58183401wmb.171.1563703013981;
        Sun, 21 Jul 2019 02:56:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563703013; cv=none;
        d=google.com; s=arc-20160816;
        b=GaC8zsl8M/gHFE861ZfN14Blp176I32q60QSlm/VhcUnkB4lTMs6H0XjRLNPNnT/+5
         Qo/hHl93v9WFpAOFEPzkCC7WrlJ82YbAZIIZKAikiOND2dmMl9elDu9E1/vQ3C/YinOe
         033OR28Ks5OOi5TxaMzBQ8WZwTb2pw/mtE8C1gQLajD+Yhdfih+h5VjETRp9cjt4iKD/
         HLqIYtoT9mJHSdidhVCSwgJsdZDKSgsI4siqnPJkamuqjMwUanAM7t5GnuLajgQKMrBz
         DWiyORIRtn2A3QvK2jUeMSGQcOdLbTcz6xvJRi/uOG6EPdDeGiofSdf5EpVYjbE8ew1G
         a1Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=x1og2ZNy3c497vm0LOnwUcH+1uTWURlAy/0lJrYTV7g=;
        b=vH9iYJD1Ga0s/NEgRHo68/dW0k64KmSuEjOE+h2GV0zFmwy3USr2RB/DvQGbv9Knvl
         02Czu2LzlTY3heFWySwM5MeX0YO39NhACOG5zxKc5sBXnO5tYJ+mVkKzWZAIKbpa6FbU
         iPuYxJJbf0CZHx3mRfobER5m/6M+svW2JdWp7cTtlXbMH4+QpSELxGT+IbKZMvSaH2V9
         ga64idR+UbtfCqu15mcaBbmBE5x0u2wqSbaH48wWUhuy/BJBHIgwKIktrfW57rB4gktU
         bFRsualX4Lkuk7FmJUlxCbP0WR6H8Yb4oiQqoSXS+naxGy/YkE0V9YoxuVF3vFt/ocEr
         C9hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 80.12.242.132 is neither permitted nor denied by best guess record for domain of christophe.jaillet@wanadoo.fr) smtp.mailfrom=christophe.jaillet@wanadoo.fr
Received: from smtp.smtpout.orange.fr (smtp10.smtpout.orange.fr. [80.12.242.132])
        by mx.google.com with ESMTPS id t131si23659060wmg.59.2019.07.21.02.56.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 21 Jul 2019 02:56:53 -0700 (PDT)
Received-SPF: neutral (google.com: 80.12.242.132 is neither permitted nor denied by best guess record for domain of christophe.jaillet@wanadoo.fr) client-ip=80.12.242.132;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 80.12.242.132 is neither permitted nor denied by best guess record for domain of christophe.jaillet@wanadoo.fr) smtp.mailfrom=christophe.jaillet@wanadoo.fr
Received: from localhost.localdomain ([92.140.204.221])
	by mwinf5d33 with ME
	id fMwr2000B4n7eLC03MwrcU; Sun, 21 Jul 2019 11:56:53 +0200
X-ME-Helo: localhost.localdomain
X-ME-Auth: Y2hyaXN0b3BoZS5qYWlsbGV0QHdhbmFkb28uZnI=
X-ME-Date: Sun, 21 Jul 2019 11:56:53 +0200
X-ME-IP: 92.140.204.221
From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: dennis@kernel.org,
	tj@kernel.org,
	cl@linux.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] percpu: Fix a typo
Date: Sun, 21 Jul 2019 11:56:33 +0200
Message-Id: <20190721095633.10979-1-christophe.jaillet@wanadoo.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000015, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

s/perpcu/percpu/

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 mm/percpu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 9821241fdede..febf7c7c888e 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -2220,7 +2220,7 @@ static void pcpu_dump_alloc_info(const char *lvl,
  * @base_addr: mapped address
  *
  * Initialize the first percpu chunk which contains the kernel static
- * perpcu area.  This function is to be called from arch percpu area
+ * percpu area.  This function is to be called from arch percpu area
  * setup path.
  *
  * @ai contains all information necessary to initialize the first
-- 
2.20.1

