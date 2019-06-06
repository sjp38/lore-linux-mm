Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D88FBC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A381520868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Rvt6PYlH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A381520868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED07F6B0284; Thu,  6 Jun 2019 14:44:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E58BF6B0285; Thu,  6 Jun 2019 14:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D209A6B0286; Thu,  6 Jun 2019 14:44:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAEEA6B0284
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:51 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id i196so2754819qke.20
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IcIuNwf0zSIjR7XDITYyS7Upr/ibuj30Et6ThDetGUk=;
        b=EzD+WOAkzAWuTtOF06iIbrbfGOzjcJmv7syFvk+5ziTfR9kTPjEHk/EZ02lrRRXk+h
         yq/z49XY7NFY99QkV7+LnefqcQJt6TmKhOSG9LO40GJbMLd0/UFswxGLff0QqKHawu+o
         Q0OprvDmXEBkRV+vry1ByKWkXBSHZh70YrrX2wyGSK+jZ2pSbm73rRQxvoeNqFEs0PVb
         BWTjyVors2tX7qLghwdf0OMA+LnZSUbC/STQCb4LxsINMMwfwCNK4alNQNsk60YK1q6l
         QsPusuOq5RdpkzGNCpT8tBi8gxDfROlUrYwQ1zI50RmhLSq9DWICigWgdpxA9Ux40Pe8
         ahrw==
X-Gm-Message-State: APjAAAVtgJYpf/AJXeotf1qlInJvfLP5UMV9zS8zVm2W55UwL5hFAnbK
	+0nraM01K/i4g815nWv4kf9hAj+cKQTFRj/Sze7ENqM2+vhtuGsDd53y7SmN5zlHqsfVeQlq+ly
	E8ZT50k58bHNpdBqPG0kY1WzakzKP/fAIPOUwRALfQnIUT0EF71FhwoMnWobnf/0oSQ==
X-Received: by 2002:a0c:c164:: with SMTP id i33mr21776331qvh.37.1559846691452;
        Thu, 06 Jun 2019 11:44:51 -0700 (PDT)
X-Received: by 2002:a0c:c164:: with SMTP id i33mr21776284qvh.37.1559846690715;
        Thu, 06 Jun 2019 11:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846690; cv=none;
        d=google.com; s=arc-20160816;
        b=rCd41AaZ3o2PPH58BGXi2GummjpzGA4bSk8ObvA+vbAPjh7pWD1zqm+GvJJ5clKzOS
         Sj+ZC+Mj6Ow/POM2Be8KMIbQkF+KVHd5Csj/TwO8XAF4eGGqIthanq0ncUCctBJVkdhC
         SiYY3dkT1hjSefzZVX4cmq4U43DVTvuLaqpS8qBbF5AHFsgVwV0oUmp40GmtsOvgozlX
         7iuruWaBucxydGcIiJHMYfDd0LR+WFUgowTn+l03xrBLvpanmcIQ5MVjnKcgoRX14w25
         /2cR5dCVc9tn78LJH1Quh8C1dDu+SohWPg3b9R/fruMZkQ53W715toEwwWDCnfH6I9YJ
         hDGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=IcIuNwf0zSIjR7XDITYyS7Upr/ibuj30Et6ThDetGUk=;
        b=gcnxqQxrwwI+Ua0+nukZHNTctTkFx+0Gn9uAof6Guhqk7vB4txnof9L2Z0oWi46QBj
         LEemWXgDqt0lEJlCadQtfmatQORca4/RR4XTW4DChdbao6vA9fclcSkd/TomMoe/pXnS
         ATFfWcRQWepj0HIeqeZstgbEPapDO3KjbS7jwFSUh1wiTj5E9QC1IZLcA04dqHm4ftM0
         XBR3M0ldE22KUHBrZlNlO2yH9LubsW9stx8EvZrI2COVtv8TGZyE5AxNKwpF7DDTloxw
         zEwCZJFBvXFgkv4v5BKQCt+j42rBoeNAdyEsjzTL9r6K7OLzeMrZ208ie3eg9hkyXEom
         byvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Rvt6PYlH;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b11sor3160196qtc.50.2019.06.06.11.44.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Rvt6PYlH;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=IcIuNwf0zSIjR7XDITYyS7Upr/ibuj30Et6ThDetGUk=;
        b=Rvt6PYlHJVz8B4LawxVuziHGCwRJD2Qr2qMiY3NEDUJNQxIcviDgQFIUHpNOBK6bPf
         MIIBJmiWVVkfUMbHMVhNgYzIahm6Aa7GUFAb3gMyDxztH5h7Eb+fHHV92q7izqEBwwUK
         enoyn9lRGevzhavWgW36BHvjzT31gUq2EFNwzhKeKkZTpVNTzzVvik0L2TrM3EnBxw1d
         HwLNV0REutZrfhliSSQTwWrC1elVFzjojR+FeHHh1CsZjd+KT2xql8gm7opCTrlBcvvX
         NVsKXd0JcUf5SXTHZ3LhocSEFVCL79+sS0K2915hv11I6abm0hUCKJT6F6DnKNs8vXBi
         N3Ug==
X-Google-Smtp-Source: APXvYqykn/mITkIwjkB65/z/6RCijqiu6Ix2iI3uboXOjS2+VibgJIHgW9EaDOqfs4y2pX6u4b1Wyw==
X-Received: by 2002:aed:33e6:: with SMTP id v93mr42686308qtd.157.1559846690472;
        Thu, 06 Jun 2019 11:44:50 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id y8sm1656836qth.22.2019.06.06.11.44.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008Ix-Sq; Thu, 06 Jun 2019 15:44:45 -0300
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
Subject: [PATCH v2 hmm 10/11] mm/hmm: Do not use list*_rcu() for hmm->ranges
Date: Thu,  6 Jun 2019 15:44:37 -0300
Message-Id: <20190606184438.31646-11-jgg@ziepe.ca>
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

This list is always read and written while holding hmm->lock so there is
no need for the confusing _rcu annotations.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index c2fecb3ecb11e1..709d138dd49027 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -911,7 +911,7 @@ int hmm_range_register(struct hmm_range *range,
 	mutex_lock(&hmm->lock);
 
 	range->hmm = hmm;
-	list_add_rcu(&range->list, &hmm->ranges);
+	list_add(&range->list, &hmm->ranges);
 
 	/*
 	 * If there are any concurrent notifiers we have to wait for them for
@@ -941,7 +941,7 @@ void hmm_range_unregister(struct hmm_range *range)
 		return;
 
 	mutex_lock(&hmm->lock);
-	list_del_rcu(&range->list);
+	list_del(&range->list);
 	mutex_unlock(&hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */
-- 
2.21.0

