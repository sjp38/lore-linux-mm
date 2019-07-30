Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9259C31E40
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 18:32:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A3662064A
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 18:32:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JUA9FbUP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A3662064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B059B8E0003; Tue, 30 Jul 2019 14:32:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB6FB8E0001; Tue, 30 Jul 2019 14:32:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A5DC8E0003; Tue, 30 Jul 2019 14:32:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64DBA8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:32:50 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y9so35834618plp.12
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:32:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=6fCIBt83Qg0xm9/csFeyeLFWARKqAMvTELcBmphTpo0=;
        b=mSxpDZ05qQr87UsOdnhCVswEpoF8Q7XWTtAQApIJtpwvqZWmAOUgbjtYwnWKnDKz1t
         65WZ5zsZEWlWN894VJ5IxFkIJSoyErSFsdY/eGMIqUh6e//xXT7QCkVsm3vCbItcvxC8
         qnmgoslaCDY5sjMAqqn5M7jJGsd82og5os1F93eEIIv7DR5uzGJ0kDIUz+Ul/C/qmB+z
         oi9LhIVvOun6rPabRr9QAXgOXUB5Vi2ylxZ7JQd3PyZYnKmkqBDG6bLvAXQyFADz/6PM
         99zjxx9nqOs+vIgmELPlvp/VmjhaWHRH265fr8M3ZCKD3Y+7JvmYskxQ6WzKLPAgZzG8
         9mew==
X-Gm-Message-State: APjAAAWmxf1lHa6/9A8c3dX9w7XO6uPXQUeIRg0IqcAhj8XA8TpIB9pD
	jjFfdlisenhUqpPK2/3cn6Vx5+cZdmHXo97ge8cn7+tPRwvCyA8gDBWHLkumK04EulQNYYf5rSJ
	TG5ZG1AP4GcngbJ+2AomYX5jEuk5aFoReQIaTv9Q58pmHWsbVo1wSkoJynuveXMAPeQ==
X-Received: by 2002:a17:902:aa83:: with SMTP id d3mr113003944plr.74.1564511569918;
        Tue, 30 Jul 2019 11:32:49 -0700 (PDT)
X-Received: by 2002:a17:902:aa83:: with SMTP id d3mr113003891plr.74.1564511569060;
        Tue, 30 Jul 2019 11:32:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564511569; cv=none;
        d=google.com; s=arc-20160816;
        b=RNScVMncVneQgs5A/4Jpt2N7mrZr8+5pLsCdTdjRFD8ZGHMNsnQmt5Q3A8DERm2dov
         j46z8r3HFoGFHwnDDVTze6OCc1nwm1eEcTsJe2MTzIoh238oL2sjxNsFLa+tZ6BDrdX6
         KcS7rZzbKGmOLgoCS0T6Z01HGvk7bsX/z2DhK1V82ZrqZivw+3pRRYDnbLPhBXth4cD0
         mTBk/rVYL1UqGXORItAgj61mRuqPirk9jTNXMggcqsxQAiKnWtf4+TycckGG0zvgWakQ
         S3+PYgib4isXddd12VCHcqzyNLc2nkUhYeIdJZkJovoK5Xi3VUFzjRL9XrtKED6QSIJQ
         BLhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=6fCIBt83Qg0xm9/csFeyeLFWARKqAMvTELcBmphTpo0=;
        b=oeoTaD2GHUrhBmOjAWkiFb+BPjeBe/fWoUAvGmin3Sj1rMzoGCKmzPrVTPai10e8cQ
         dNuTltlDOqnVZ/AWiH2HI/AhsEHOjuCAs4hrSewPe7UeEVvIVneYWKPnHVqIUIhCb95E
         g2pYIyZpS/szJpmIS1Pp24a0rkPUGi4JdG1oWLaXuS3KcxTxakhrnFQA8BbEWOcJw7TJ
         3HEm6bnI6eRIIANOWJkKmwnOSJLWFWkW1VpUysmgI/ZRfCENUTENls8ZYjJyi7hVQiiJ
         gZ5ixc5UfFNZDxiHWQ/8l0yLcWJBE6Sm3WJqpsiFpfQ/dGJNg46LYzdgKHoEBFJxiLy3
         gxRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JUA9FbUP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n6sor47056200pfq.67.2019.07.30.11.32.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 11:32:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JUA9FbUP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=6fCIBt83Qg0xm9/csFeyeLFWARKqAMvTELcBmphTpo0=;
        b=JUA9FbUPr0F6xNgBd5J9MHwHtCHrMpBJuNDTvZBzKBZeCmNsbohHado2HBbGTi0It9
         yThD+OL5Bkf6Da9wJnEKF7n1ZuYfE+RCaAChBqmkI/jmB2QhloDai+ucTPidoKT2u6UQ
         29UC6QoAyrEf4tN2GNQniwXjZkr83rJH4ak6SFrbJFSb15jmyMBIWZiHh1EgvVH6j48q
         cZKmuIlqPfwxsnRzt4ye0SXQ2NpyGAmqO03R0RsRzNRYkzGXP/3U1W6hIGXqsFMnjHXR
         g7Xo3I2gA+uPgrVqyPZw3rp948eNJFIjP60aR0GcG/CsRV9BR7dafhIdCpB5PUi2sogn
         ixHw==
X-Google-Smtp-Source: APXvYqz3TKO5CR8bm9L/zAhw0K/5mmOOXYnkeug29AHRYcKaRz4UPuCN4Qa7WYzWXEa+PlUkZGXEBw==
X-Received: by 2002:a62:754d:: with SMTP id q74mr42050335pfc.211.1564511568653;
        Tue, 30 Jul 2019 11:32:48 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC.domain.name ([106.51.16.0])
        by smtp.gmail.com with ESMTPSA id j5sm57328671pgp.59.2019.07.30.11.32.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jul 2019 11:32:47 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: boris.ostrovsky@oracle.com,
	jgross@suse.com,
	sstabellini@kernel.org,
	marmarek@invisiblethingslab.com
Cc: willy@infradead.org,
	akpm@linux-foundation.org,
	linux@armlinux.org.uk,
	linux-mm@kvack.org,
	xen-devel@lists.xenproject.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	gregkh@linuxfoundation.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] xen/gntdev.c: Replace vm_map_pages() with vm_map_pages_zero()
Date: Wed, 31 Jul 2019 00:04:56 +0530
Message-Id: <1564511696-4044-1-git-send-email-jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

'commit df9bde015a72 ("xen/gntdev.c: convert to use vm_map_pages()")'
breaks gntdev driver. If vma->vm_pgoff > 0, vm_map_pages()
will:
 - use map->pages starting at vma->vm_pgoff instead of 0
 - verify map->count against vma_pages()+vma->vm_pgoff instead of just
   vma_pages().

In practice, this breaks using a single gntdev FD for mapping multiple
grants.

relevant strace output:
[pid   857] ioctl(7, IOCTL_GNTDEV_MAP_GRANT_REF, 0x7ffd3407b6d0) = 0
[pid   857] mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, 7, 0) =
0x777f1211b000
[pid   857] ioctl(7, IOCTL_GNTDEV_SET_UNMAP_NOTIFY, 0x7ffd3407b710) = 0
[pid   857] ioctl(7, IOCTL_GNTDEV_MAP_GRANT_REF, 0x7ffd3407b6d0) = 0
[pid   857] mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, 7,
0x1000) = -1 ENXIO (No such device or address)

details here:
https://github.com/QubesOS/qubes-issues/issues/5199

The reason is -> ( copying Marek's word from discussion)

vma->vm_pgoff is used as index passed to gntdev_find_map_index. It's
basically using this parameter for "which grant reference to map".
map struct returned by gntdev_find_map_index() describes just the pages
to be mapped. Specifically map->pages[0] should be mapped at
vma->vm_start, not vma->vm_start+vma->vm_pgoff*PAGE_SIZE.

When trying to map grant with index (aka vma->vm_pgoff) > 1,
__vm_map_pages() will refuse to map it because it will expect map->count
to be at least vma_pages(vma)+vma->vm_pgoff, while it is exactly
vma_pages(vma).

Converting vm_map_pages() to use vm_map_pages_zero() will fix the
problem.

Marek has tested and confirmed the same.

Reported-by: Marek Marczykowski-Górecki <marmarek@invisiblethingslab.com>
Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Tested-by: Marek Marczykowski-Górecki <marmarek@invisiblethingslab.com>
---
 drivers/xen/gntdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 4c339c7..a446a72 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -1143,7 +1143,7 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 		goto out_put_map;
 
 	if (!use_ptemod) {
-		err = vm_map_pages(vma, map->pages, map->count);
+		err = vm_map_pages_zero(vma, map->pages, map->count);
 		if (err)
 			goto out_put_map;
 	} else {
-- 
1.9.1

