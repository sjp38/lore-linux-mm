Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FAEDC3A59F
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 19:39:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E35062146E
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 19:39:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GOpi23ZW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E35062146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 832D66B000E; Sun, 18 Aug 2019 15:39:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E2946B0010; Sun, 18 Aug 2019 15:39:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F8D46B0266; Sun, 18 Aug 2019 15:39:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0053.hostedemail.com [216.40.44.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB946B000E
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 15:39:33 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B19F5180AD801
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 19:39:32 +0000 (UTC)
X-FDA: 75836562984.09.wave88_191597efff963
X-HE-Tag: wave88_191597efff963
X-Filterd-Recvd-Size: 5245
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 19:39:32 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id o70so5843380pfg.5
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 12:39:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=a8+L6poDC20GcQQ9CfyPX7El391DODwhknO5Uu2z/P8=;
        b=GOpi23ZWVr64SH0Vu9SJdU+hs6VoZUy5QE9KBREpVVzD4b07FglIvvvaPDBy5dC7J/
         nKMMCD6/copl5kczMBMnNguX0lSHQi9eiRApNpD2wGvk6JmFxUmDf9Q90Di8NIo2D2Gh
         CyTQttAEKWbh9IGkWTLdqLZeCmLoYDB2cUJIzJ93dXeEUuRDkcLR/GkedO8UfVSVQjRQ
         nCmHe17Xiu+VdGtHoOAI+Vt57aooSYAYtU4XpLEaXH22qig6FZP9soYjcT6OvVEtfe8Z
         hmrGZ+T4qwyuwhsAqcmH4C7xXSYyYZiuJIVnBXUSlfPQ0CtTBYLKSzlXVQmmj22EQfwK
         sx9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=a8+L6poDC20GcQQ9CfyPX7El391DODwhknO5Uu2z/P8=;
        b=dFWP/lx2WV6jLW/EIydTS076X23L4QVdl6SOymEtXLgpaimZOqY8EQbgiNps55VGpg
         tzktsNjW4+VfhGRxG+jITNyEPMQUocfrxidTX7NQLCNmIjhZw6re0w0RlYGJggP8cDeI
         aPP92dlww0hCGv7/ngP8VZ3FaGcaixQlDYnm0kfVNPtmK6bpO2wT1ej8znyqWzo90nI5
         FPb4YBsIPAg9kaoUn4M60Y/y5/fOmJOYLl8M1xkyLsQHdUOxvQnzp2vPayLyZwyGQTX3
         VyMJOj2Pq6h+BRzeyS26XMhWJVEYjwgEkRgyCrhBtRO4JU9uJzhGMfKEOar/MqhJkA0U
         348g==
X-Gm-Message-State: APjAAAWMBsxBfPH4YlY6KaeEoltqUFS1x7A5dnrEjru4Ix/59ok4aWXP
	1MLiXEo6yaHR7eDMePTK740=
X-Google-Smtp-Source: APXvYqxYIXFqhwAQK3mpk0fNnX3nZwkcmz/afOcd6XTFDlWHsIBUqj1+EURmOIXoL7iiX1TsTdbPFA==
X-Received: by 2002:aa7:9a12:: with SMTP id w18mr21671346pfj.110.1566157171532;
        Sun, 18 Aug 2019 12:39:31 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id m9sm24492787pgr.24.2019.08.18.12.39.30
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 18 Aug 2019 12:39:31 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com,
	jhubbard@nvidia.com
Cc: jglisse@redhat.com,
	ira.weiny@intel.com,
	gregkh@linuxfoundation.org,
	arnd@arndb.de,
	william.kucharski@oracle.com,
	hch@lst.de,
	inux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	Bharath Vedartham <linux.bhar@gmail.com>,
	linux-kernel@vger.kernel.org
Subject: [Linux-kernel-mentees][PATCH 2/2] sgi-gru: Remove uneccessary ifdef for CONFIG_HUGETLB_PAGE
Date: Mon, 19 Aug 2019 01:08:55 +0530
Message-Id: <1566157135-9423-3-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
References: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

is_vm_hugetlb_page will always return false if CONFIG_HUGETLB_PAGE is
not set.

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: William Kucharski <william.kucharski@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel-mentees@lists.linuxfoundation.org
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: William Kucharski <william.kucharski@oracle.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
 drivers/misc/sgi-gru/grufault.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufa=
ult.c
index 61b3447..bce47af 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -180,11 +180,11 @@ static int non_atomic_pte_lookup(struct vm_area_str=
uct *vma,
 {
 	struct page *page;
=20
-#ifdef CONFIG_HUGETLB_PAGE
-	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
-#else
-	*pageshift =3D PAGE_SHIFT;
-#endif
+	if (unlikely(is_vm_hugetlb_page(vma)))
+		*pageshift =3D HPAGE_SHIFT;
+	else
+		*pageshift =3D PAGE_SHIFT;
+
 	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <=3D =
0)
 		return -EFAULT;
 	*paddr =3D page_to_phys(page);
@@ -238,11 +238,12 @@ static int atomic_pte_lookup(struct vm_area_struct =
*vma, unsigned long vaddr,
 		return 1;
=20
 	*paddr =3D pte_pfn(pte) << PAGE_SHIFT;
-#ifdef CONFIG_HUGETLB_PAGE
-	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
-#else
-	*pageshift =3D PAGE_SHIFT;
-#endif
+
+	if (unlikely(is_vm_hugetlb_page(vma)))
+		*pageshift =3D HPAGE_SHIFT;
+	else
+		*pageshift =3D PAGE_SHIFT;
+
 	return 0;
=20
 err:
--=20
2.7.4


