Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19A8FC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C02DB20868
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cU96DRv2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C02DB20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6246D6B026C; Tue, 16 Apr 2019 07:47:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D2966B026D; Tue, 16 Apr 2019 07:47:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C2D26B026E; Tue, 16 Apr 2019 07:47:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 152246B026C
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:47:06 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e128so13892994pfc.22
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:47:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=nXj43O3tSvY4CrMpVl1k4U9n4zfyio96xriZ/XakY7qQd9i9i1/AVDvbY6eiZUJdkr
         Y/s9HtbUvjwUclpFzK+CN3Grad8W0B53s83v5GQ4xnJulBBwVw12ljiNFimPNs0BCp0Q
         3ZVlbbgrKJQwApU4TCDgNCQRyY7cKKUdiwRhIMUGpNJDbmQlKgHNuYgvVvlCNuMaCXyk
         QMDjk+honCo1b2NY7K/HecL0s2ytC/SFvNRzzbazARSL9tiCqWNQPHFK+QS4He27aDip
         emARL3Xf905xWWMscApJeYJ+BZSWOB4lAEOtJQAY718ui4LvMhsJryPhbO9At+TFRji4
         10sg==
X-Gm-Message-State: APjAAAU+DnQ8oMgO/Khn82/h4VtxF0M0lWlvd+kg/w1hgFUph21dRUnL
	dn9MOsZgO0VeC3swWdM5b+CseOLiCtFygQfnCy2MbPVNhsZJ7ySPYcFTM3bNmvNhRlTz93kfbGX
	Y9UoUtRDftSS0NzayGyy02QtAShWL9NRKEMg+KetbawAYIMi+eCnpD6px3niweWFzBA==
X-Received: by 2002:a17:902:4381:: with SMTP id j1mr17504081pld.173.1555415225728;
        Tue, 16 Apr 2019 04:47:05 -0700 (PDT)
X-Received: by 2002:a17:902:4381:: with SMTP id j1mr17504003pld.173.1555415224995;
        Tue, 16 Apr 2019 04:47:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555415224; cv=none;
        d=google.com; s=arc-20160816;
        b=AQZUwR5/92iMhRkrX5dbobzuJuIQ6mtktFWee6QuHSfj7LenyrG1C5Q8UK2AwWfERs
         zFrGZ7LPXOCf/3Kp/WafRNbTlGiZWSz4+8+fAj09QtMwdKAIkxrTn3aBPmlez+zSMpaT
         lEtL0/gOPuMX7TKTD3Si2IkX6yUNUUy+RMhBE8nuYsUX9O3V8eXKegyihUn9tgQV1x+W
         zkJF2aDdmbfF0H5GF+OHLkUhiUo++jGlLQx+WTIhg0QpwzxGstBjGcfYR5JYORIQS7GN
         RfTokHIiTF7KzF9vgi8SlDdRkGFmFgY10Wr+VeZtFivyzNuYg+ERX6mjOv5GipYyahyf
         wH4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=c1WMV52jXwTlzViQV4EXwuzdUxNDMIUPlL9RAUXSxB91ABpQaUzHFycz4//TzS2ADt
         YFbi91B+gZMs/4NaSWyIA2Xu1UyTuSoMUC5np1KraD+TvirfKVczy9hutGoocdVZ8tQd
         0CJFAo70yUuXJbqt42iaZqkS+1E+pMYM7cg0J2sgkO8Ee/eNV6WsqGy62olxBBWuPS9q
         2Y/m4iEKewTx9Sx/ApLEnuZTzl/0n+f8soRaCKfndnKLbgysMM1ouiBTKlDFqSC8kIXy
         I5ViTUNsLzGj8GNR+SoUK6A2XiZCJkagpwdUwT1X6LqTQrKv9oyrHgSXESLn9b1JuV+s
         eoag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cU96DRv2;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bj5sor67615122plb.25.2019.04.16.04.47.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 04:47:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cU96DRv2;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=cU96DRv2ov3f6Cd6NK8xcTZ/pxd6ORU1P19E6pQIz3B49Xye1iNecd9iNZibBfJcjQ
         zuIvUPJ+CLar5CQjZRDX3VQ1TZCDeFWlILHsb8dRJWggD00EqzXEkyE8uJG1kMP2eIvp
         n24W6tCY3AanegajVewju3yYDXmhf0X9II/qFV5HCylGUkejdXzo9E/koqfyqUqq8zr9
         mW/ZBFGmtcso0v4QTX5OavZW9KBMU22Tan8pYhZR4Ld+BqKTsHamZTqQU3PDd55gPcFI
         MsgxhBrhXIs5Fh8xdDdB8AJYcTdBC4NqYXVKmPD9APCljql55oe+X1QMkhe2S4UTALoW
         5KAA==
X-Google-Smtp-Source: APXvYqzDjDcAV7GNAw1BnDNouVWt6jT57KNhFlyZntYAXIOvC1nqtveURqFOLb2rK8ycg0MhFKUzow==
X-Received: by 2002:a17:902:d24:: with SMTP id 33mr83552990plu.246.1555415224705;
        Tue, 16 Apr 2019 04:47:04 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC.domain.name ([49.207.50.11])
        by smtp.gmail.com with ESMTPSA id p6sm55942835pfd.122.2019.04.16.04.46.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 04:47:03 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@suse.com,
	kirill.shutemov@linux.intel.com,
	vbabka@suse.cz,
	riel@surriel.com,
	sfr@canb.auug.org.au,
	rppt@linux.vnet.ibm.com,
	peterz@infradead.org,
	linux@armlinux.org.uk,
	robin.murphy@arm.com,
	iamjoonsoo.kim@lge.com,
	treding@nvidia.com,
	keescook@chromium.org,
	m.szyprowski@samsung.com,
	stefanr@s5r6.in-berlin.de,
	hjc@rock-chips.com,
	heiko@sntech.de,
	airlied@linux.ie,
	oleksandr_andrushchenko@epam.com,
	joro@8bytes.org,
	pawel@osciak.com,
	kyungmin.park@samsung.com,
	mchehab@kernel.org,
	boris.ostrovsky@oracle.com,
	jgross@suse.com
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net,
	dri-devel@lists.freedesktop.org,
	linux-rockchip@lists.infradead.org,
	xen-devel@lists.xen.org,
	iommu@lists.linux-foundation.org,
	linux-media@vger.kernel.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [REBASE PATCH v5 3/9] drivers/firewire/core-iso.c: Convert to use vm_map_pages_zero()
Date: Tue, 16 Apr 2019 17:19:44 +0530
Message-Id:
 <88645f5ea8202784a8baaf389e592aeb8c505e8e.1552921225.git.jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190416114944.ix4mSh61--XPakLAu8mvAGkx0eF2dKtErW3nSNKgZ9I@z>

Convert to use vm_map_pages_zero() to map range of kernel memory
to user vma.

This driver has ignored vm_pgoff and mapped the entire pages. We
could later "fix" these drivers to behave according to the normal
vm_pgoff offsetting simply by removing the _zero suffix on the
function name and if that causes regressions, it gives us an easy
way to revert.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/firewire/core-iso.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/firewire/core-iso.c b/drivers/firewire/core-iso.c
index 35e784c..5414eb1 100644
--- a/drivers/firewire/core-iso.c
+++ b/drivers/firewire/core-iso.c
@@ -107,19 +107,8 @@ int fw_iso_buffer_init(struct fw_iso_buffer *buffer, struct fw_card *card,
 int fw_iso_buffer_map_vma(struct fw_iso_buffer *buffer,
 			  struct vm_area_struct *vma)
 {
-	unsigned long uaddr;
-	int i, err;
-
-	uaddr = vma->vm_start;
-	for (i = 0; i < buffer->page_count; i++) {
-		err = vm_insert_page(vma, uaddr, buffer->pages[i]);
-		if (err)
-			return err;
-
-		uaddr += PAGE_SIZE;
-	}
-
-	return 0;
+	return vm_map_pages_zero(vma, buffer->pages,
+					buffer->page_count);
 }
 
 void fw_iso_buffer_destroy(struct fw_iso_buffer *buffer,
-- 
1.9.1

