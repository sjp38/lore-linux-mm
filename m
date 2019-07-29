Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46873C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07DA7216C8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="p6H12wQg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07DA7216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87D048E0005; Mon, 29 Jul 2019 10:29:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82E438E0002; Mon, 29 Jul 2019 10:29:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71D118E0005; Mon, 29 Jul 2019 10:29:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC508E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:29:00 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i33so33238223pld.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:29:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=gQDoUkRn7ohUi0AK4193GFFAVxKRpJGWSsD1aIDW0XQ=;
        b=niw4goGo3whDivrEjXFOANpVbJGfTlUKYLLSTYJe/1HnEgrOmoqAYtgiwuToqRGKlS
         h/2TH3gkBB1+OLz8yvNSZKiNQXHdLrEvBkjiptL+71OLfKH9m06/hCpW0hufTvmIKWZc
         lxejBx7g0mPTqHKVWMNRBYjFdQtGPA437+2HmawCxVnNMKIZztX80WMn2VFs1qKRwUMj
         +6qClabn9vyXt0K/czDeth206a/zsW6unghoi/DyyYLt5QUZI4ZPqR6OgDYrHXM8TTd2
         iKFVvQLaaGQhuvVI+t9lVy8VYWT1DQdpWiLnWtXmrzsPYd555fivNcEBXvzlwYD6qkhy
         GK+g==
X-Gm-Message-State: APjAAAUL6cGuEitG/cNnwpzmCbVFv8a6jNvZg7HJQ55dUtTl14TaPA3v
	8UGVX5e2CIDYQ6E5oNeq01M1LMYAGqwrNW+LQ4vE+JERUu4ZO6P2UW2h48P/SFGG633IxhQ5UA/
	IBky5ApjgN00a3M1YTAdCTxTlLRAJOKxhIRaieWJqo6hQm94AkPCdJgyqa7nnBCU=
X-Received: by 2002:a17:902:900a:: with SMTP id a10mr112223274plp.281.1564410539858;
        Mon, 29 Jul 2019 07:28:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYA2ZgtylDLdfedjKjHpe+d2QrzeVYJhNtjSn6jUiTQkosHUw+YCdbOh3G4jRuLGu8qVOq
X-Received: by 2002:a17:902:900a:: with SMTP id a10mr112223216plp.281.1564410539248;
        Mon, 29 Jul 2019 07:28:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410539; cv=none;
        d=google.com; s=arc-20160816;
        b=o2zPktMJ6e3u9MAN10/TfFgeD8EB2sowPvkyyd7vR7ri/z9Yhfc58BxOb/mnwb6IB2
         U1zUkF+C2IiDlWmObOODhH6sZgpOkH4T4DG7Q40H4G9R6ZZR6RZ7fmHXkikQw231N7pB
         AvnOQn5zcftXXjjBK3MJteDS235WoGHN9al53+stR2dA0iEYgrdkVrBTUFhxfOltX/ZR
         OtaqukypN1Z+OC7yp5/S6nMDiNt3LVvu+RqP5pPQG4xTU+JcBsKXfD65HBtahkje9e52
         bJxSo+m4wBqz/uz9t7GL87DHo9siZEIEOswXnLOh8XRg0YQgGd8YDjAJBGWm8YCIDPEJ
         I10g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=gQDoUkRn7ohUi0AK4193GFFAVxKRpJGWSsD1aIDW0XQ=;
        b=K6kSlLvLlO/gsSluxzrPThHbpCKOHfQ7N6v2uu/P1J1MTMzqd1DV0QEP4oxVwbeCfB
         j9V1XFaqtUKYrzPewWfy52gf/WvOxwQIkhWi6H58nB8/8Nz/hCZ85lziFa9dCO8XQcaP
         1JrFDkfd5+c02iNbmrf/xUDUwkUtS0JLM1XpHNsQMgKxfBFlUffeYZTv85O3xqWNm7eF
         c8wpsxZ7JiwGB1zXU3Rlk6lXbdEMkooF0l+sKq9tdbe35Xjl4P0vp8NpO4x4/IDecllQ
         WR+uSkUmHZe8K1xlHlVlULUOlqW7ySPliBWlm+9DEUwvi9Yzpjh/tSbamsdS9F/Y+EXh
         NzSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=p6H12wQg;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s192si27463905pgc.68.2019.07.29.07.28.59
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:28:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=p6H12wQg;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=gQDoUkRn7ohUi0AK4193GFFAVxKRpJGWSsD1aIDW0XQ=; b=p6H12wQgajmyDHgmBXKdemE7Y
	C8YxAS2Y+3b6ukgwoyVL9zbIvTacyBgW4tCrngVCwU+jaE8kWjD6arMSdL7X396OaWBv7cPNeR1sg
	wfirWKCQZYamFRQEpP35Crsfu7nifa9oziKwmOzjVzlhDro5Yn8PH0XkSZh7FQuxVrFF5vssBb95Z
	FzVuaLZZ787LDALYCdA1svJ9fKFIWVdIYLs5d1bWWzZO/pGHVpy4Y1Mq0JJctiKFck2EKLiQ1Ykdd
	EoLkzi9cw1xX9PIv4fjFm/IWGznw5KS+KN8yxTCxKhZo7oBCTYFqOwyygWPleV6mcS7+MsXs4LQ7f
	k8v32wtEg==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs6dy-0006J2-NA; Mon, 29 Jul 2019 14:28:55 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: turn the hmm migrate_vma upside down
Date: Mon, 29 Jul 2019 17:28:34 +0300
Message-Id: <20190729142843.22320-1-hch@lst.de>
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

below is a series against the hmm tree which starts revamping the
migrate_vma functionality.  The prime idea is to export three slightly
lower level functions and thus avoid the need for migrate_vma_ops
callbacks.

Diffstat:

    4 files changed, 285 insertions(+), 602 deletions(-)

A git tree is also available at:

    git://git.infradead.org/users/hch/misc.git migrate_vma-cleanup

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/migrate_vma-cleanup

