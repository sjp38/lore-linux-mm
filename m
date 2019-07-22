Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 056CDC76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0B402190F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AfgJ8lP1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0B402190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BCB68E0001; Mon, 22 Jul 2019 05:44:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56E136B0266; Mon, 22 Jul 2019 05:44:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 483F28E0001; Mon, 22 Jul 2019 05:44:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 150CC6B000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:44:33 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h27so23461475pfq.17
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:44:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=O26sc2nLoVFgJqI+86Nh+/jE5QZWcSMhT2Y2hH/y3V8=;
        b=LSWIHV2kO6wN8JF67XBJ7kRuDUgDRyhko1DkLbgV/rPXGOiODD0AVJI6V6z4GMIVDe
         Lt0lKUr81QtFp/nr7hgY2Bj5PP/RXb2Z5SJO8mq55YxW56KTDkAe7ClQ7QNxyHoSkY0R
         rIZ83Exp+dG8cv/HUItEm4mTBqgT1IGu0KLBf0wlCIULUiLwLiHfpLOOgt/QDfdDfYzS
         lHyBeom8x9DqUhLxTzSc9IAAjRrKaIofbsfIxWKRCHgbuhcvCZmhi/J5+TSJ26s1uc6f
         ISZFiSALCd76lGMSfsL3W6umaZ2QeUy2/zOEutH5J9DyiYY1lT8lMQooBQkQJxxK+Fri
         uIZQ==
X-Gm-Message-State: APjAAAU+IgsGCr7l5YZ3NsRC2h0iulqPTTV7TIkAUVe49x30m1y4cqaQ
	X8w8g4pTtSycGRVZkmPPOSazm5C61E0h/TEsX1Avhpx1+NInNYduNKyWxEpsQBw/0y+h1Yhm6Ow
	S3b+mOJ4X1ygvwtUdzfLa2q141+R/rrldwmy/83DCRHxpuAY0XQws3bz8UqlD3Lg=
X-Received: by 2002:a65:6415:: with SMTP id a21mr59019749pgv.98.1563788672641;
        Mon, 22 Jul 2019 02:44:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZqVYTNMk3DDUGcVG3F+CV2+Bx2+4dU9OhqbqlQwEOzN8M2wL0HwUEzyA0AHHAZKpMy7K5
X-Received: by 2002:a65:6415:: with SMTP id a21mr59019712pgv.98.1563788671994;
        Mon, 22 Jul 2019 02:44:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788671; cv=none;
        d=google.com; s=arc-20160816;
        b=iIom1c61HOzJVUaqytUhbbZFx4MHEUyowvSzYnPOr6x3tvVge7H1z+GLqvKQHu/b7z
         61V0NwDbDoH2/H7aTS48u1dObseAzacBsKi4r5lUisQISZ4Bu8fOw3H3qk2sPz4JQBW0
         l8WsSsAlF/ISK2LTpaiLomctzxyCSUyn93FRQF0mf+do6a9GfIoWqsYv8yFYDGWQEyKR
         tmpnXoytL2dzAe9L4HO9MNxvfjCiaP7R4gXs69sdqAqRcrayd33AntqMgFjeHP6AyGM1
         44xRtOU3XgzhIzR9bWTNw1MPvd0bNPaHOwpNC0MqpTD5JJqAP4VAiBITnLUYJgxTaYKe
         aPZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=O26sc2nLoVFgJqI+86Nh+/jE5QZWcSMhT2Y2hH/y3V8=;
        b=WwrrHO7hZDd3rtzzzUINKLPqaJP5GhOVanZOgYpzdG79fYmgdS1JgxiPYgtuqhC2yL
         d83KKYSCn7/owX5gKj9egUuCoovje78UsmGreR2vWzyUsOU1Zs3Essok+UtBsa9y2lnZ
         Fa+ghfcIE5CI9WHH/vlu2VvbMy44aI65SSJvu5FV254IgxXYBxMaHSnHsjVS+97RUV+U
         50IyBPwNVnuVL/6aWIWEpa43lL+rBKKJtkQpaJEHAV9mvT7HZ6YWPYUSn214dh3GQosQ
         bHTLV2xK5je5TmmTXIdNZWlBZVKbrXIGRj01bpnYC5tNTxlaJ/Ok67FhKHysSKhuAZ6E
         J0yA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AfgJ8lP1;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n1si8879104pgn.77.2019.07.22.02.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 02:44:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AfgJ8lP1;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=O26sc2nLoVFgJqI+86Nh+/jE5QZWcSMhT2Y2hH/y3V8=; b=AfgJ8lP1A7t1NBzOAMyaRjNbd
	T7I9Zn/foXgv6ag7KA/LDtL1Fh5GITciR4hIQAlS1u3mi0JtAqcdEFqbeD8V7L5YoeZQpj8qCpTEb
	w3J1/Qeffo9punlPAzBqh5esZiJsiko9MyMhJo15FFT3k4bJ5rW6JtUxbDeHdKRN5MoOM2ban6PLO
	vm80xm0u0Zd4kBX34rz+RMHF+g83+rgSzKOcWWeJtlM0NSyheBCY+FayqQuVWf2u+mhYMDA6LgPUT
	m8X2OIBfxYeAdHjxte71yKVXT/1qfYuiMLaSqLrcboQb5GQJHyKyIpj3af5EFzxqXsIe+SJKcOcE2
	5wys/HGlw==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hpUrs-0001rX-DG; Mon, 22 Jul 2019 09:44:28 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: hmm_range_fault related fixes and legacy API removal v2
Date: Mon, 22 Jul 2019 11:44:20 +0200
Message-Id: <20190722094426.18563-1-hch@lst.de>
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

Changes since v1:
 - don't return the valid state from hmm_range_unregister
 - additional nouveau cleanups

