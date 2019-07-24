Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B82D4C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76E6820644
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oT1UkxwA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76E6820644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AFAE6B0008; Wed, 24 Jul 2019 02:53:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 262416B000A; Wed, 24 Jul 2019 02:53:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14F008E0002; Wed, 24 Jul 2019 02:53:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE88B6B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:53:06 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q10so4475986pgi.9
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:53:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=nxIVoCpennKVcI7DbytWW21ua/k9dOz1onbRbm1cQCE=;
        b=nv78QBRpXgGpBtif7k7Ah3Rhk6cOvXeIqyDrM2J4tRZJBSEUH92xlmTF7PFufy1v7D
         rtsgdYnkrVYK3qj0Fy09+5k8XnF8WN6P0amxcgJ/urDWAV4fM1ckGD3toY2UQxJ//Qbp
         ybsPpGAhZ5cvjGnzDJrHTfTOvqfG4nTOkggybHUeYOO9+zMtm8Nrq/zPmDomV1Xu5iYa
         yuUHBLl/DtFwGPvYfXnv/N9qV8tP8PU0Q2IwbycvT9A47YpVdD9RzPOYS/+CZhi4NmOk
         HwIcqBmo39kTi24d9GJvIYXKjWUA7gSp7+Q+ttXNpisAfZIxY3e8P37hMgbMpgIIxds7
         +8tQ==
X-Gm-Message-State: APjAAAXrgNwkIwOYqidgKLVc/WkHAdjDS+JnefYrh+BA0ASXG6tnIF+7
	pN7drIdcVzirbyyY/nWJDBOJpc6+zRdPK7TpXZzCoQkFbdevoBWbMYn3dPXTXcMTPt4JWbltFCV
	h75NfXyIzMLjegxpP+bU7mhxFPzdYjQU6VwHUkk4EsEKL6T7Z90oclMCntpTdgkI=
X-Received: by 2002:a17:902:7043:: with SMTP id h3mr56295259plt.10.1563951186462;
        Tue, 23 Jul 2019 23:53:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3mN3d5J6tq4lFlHeg5oKer5mhZ2BrzDgSjR5P7/MT1xpLFsfOXlERc8rXjhMz1KbXdDPk
X-Received: by 2002:a17:902:7043:: with SMTP id h3mr56295203plt.10.1563951185658;
        Tue, 23 Jul 2019 23:53:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563951185; cv=none;
        d=google.com; s=arc-20160816;
        b=WLYkzx+BatOSlheJECQlluYoN+xF6vaIK3Sh9Sl42WsAmmle0TskhxohTsI9Riiwoj
         AWFflq/647iSt/LYTDDKGviF8nTNczom5Qdde4Niv5wuuUSzc1CDVelAuCxuGl3PD4g5
         5MMKc9vwYBy+2mc+66D4FAE03Zdrxfdb5UnKGA3hkmKs5Ewyo95FWho2LxzEE6UwJh/s
         y52MlMfLktpJUNKa6vlRB6rIXRyOmtMyXPiy1270JayQwF9HkVvzAtbS+vU5J6e0kBk9
         E9MO6lbMKXAarVF4t748n7ex8V57Qm964BLD0le6DQP64ls59ZkBEViaFnFbouxtbRaQ
         pgMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=nxIVoCpennKVcI7DbytWW21ua/k9dOz1onbRbm1cQCE=;
        b=faxlgYAvDbORP4Rf9Rc/bJQJv9xbjodliEHDL87/2ljQKPLQqsdPEgUdq0sbcsak8B
         PlxlKUliagXHxfOeFavjZGOT0bkO3ANdatLS1OuogzPNHhxhWkRnx2PtB5Q/WvNwwKgB
         pUHLAvvh2/IrXYqgP9o8c61ak/ZudcsuFJXX9ER8eXrLgW/ZiaxJZrQS3fRgbFZhgsFU
         sNITN5Aan5pElc6dQgmStsFYXlIf/FD44/Bk7zD/gUVvF9URz1vTNy+lfRGynFlaUul+
         e3z1J7S1IsY7ICYPWW1mJxqCoM6/GR7F/aIJLYFMItQ+B2tbE74uNuVhJ7vPqS8YSB1Y
         15SA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oT1UkxwA;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t134si15337200pgc.361.2019.07.23.23.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 23:53:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oT1UkxwA;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=nxIVoCpennKVcI7DbytWW21ua/k9dOz1onbRbm1cQCE=; b=oT1UkxwATR3uNfX9nvhPpejPy
	pzG4vC6QYUYgAgXlECubEZvLZDF5K+eNlTayweVvSxyqIO3v6nw9O4EZdfU+CvQWHVB71+n9N5k87
	MvKaAKSxHDWIO0SYlWaDUwo7zo9qYmIU6TX6Tzzj7Dyez5Rd9Obt8H4+L8SM2mtrm3UZG7AkYcWGp
	zzslZfgg8CUU/FA1z4RFQkBt8uCYQivm2n5RUam8BYNfDFwDlM8WYlubmQPRS2u+yDI9vScOTUpJo
	rwqpUvywoSh1seqL1wWx5ykh9VGgCyI5jt61j9WRluuS2LAkxLkB+HC8fjlVw/aeppuLqe6jgBNW9
	0YbLXShAg==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hqB94-0004Hw-C9; Wed, 24 Jul 2019 06:53:02 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: hmm_range_fault related fixes and legacy API removal v3
Date: Wed, 24 Jul 2019 08:52:51 +0200
Message-Id: <20190724065258.16603-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jérôme, Ben and Jason,

below is a series against the hmm tree which fixes up the mmap_sem
locking in nouveau and while at it also removes leftover legacy HMM APIs
only used by nouveau.

The first 4 patches are a bug fix for nouveau, which I suspect should
go into this merge window even if the code is marked as staging, just
to avoid people copying the breakage.

Changes since v2:
 - new patch from Jason to document FAULT_FLAG_ALLOW_RETRY semantics
   better
 - remove -EAGAIN handling in nouveau earlier

Changes since v1:
 - don't return the valid state from hmm_range_unregister
 - additional nouveau cleanups

