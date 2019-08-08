Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F8BAC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:42:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 444D821743
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:42:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="CGR53+Ky"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 444D821743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDC146B0276; Thu,  8 Aug 2019 11:42:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8BD96B0278; Thu,  8 Aug 2019 11:42:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7B136B0279; Thu,  8 Aug 2019 11:42:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7027B6B0276
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:42:49 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so55694730plp.12
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:42:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=ToKAXlut0bLzp0i2AEiO/Hgmk4iALY2Z3psq1k6MNzg=;
        b=VylDGg/wBcqMXFQULzVPHJGje6HqHorYP02mHmYjBc/+Qp6XsSmw5I1GL2e+ncfSdD
         hsYtkeUQZYtKjktPm+7NbKcvAn6Uual/wZxhKxD/vLGx6tOiZlHT03Qid4vTdyXZg76h
         UAlyi5l5CXmG98sBw6bvmU1xWgMwxcttr45V30qybGi2czRxlKQziLvQ1/CdOWg4UjOB
         qDf66LASR20qJuLoa7KdAaUAlpnxfeh3VIz+N2GMbu3oyFBQh5XRBCwtGNTId6CmbeSS
         mXvYrdqp5CJRvIN+d91+kI0u0sD8HnJeifmCvzp5sHREmXy8uU+VC+VYbHU+lCkFBcRU
         SFnA==
X-Gm-Message-State: APjAAAVx3PM59OoT56KaVhqqIk/R3TcWEavWWo3qhXg9WYO3cDrubTWH
	35HiC0TorpHLC1AHkwyv9gDanaWjELnd0tT9WOCjF7pK/O8z0rHid/5e4bJ21wzAdyKup7uLfl0
	ywfUZx+lx76OiJk+JfRi7n4m3MQvctKG2MkKXeajX5nZ0cTP1qTQBhf5e5R7y08k=
X-Received: by 2002:a63:2157:: with SMTP id s23mr9979249pgm.167.1565278969041;
        Thu, 08 Aug 2019 08:42:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJwpw85jXZmAKVVhKy3fTqe2H7Llox2qDbi6tqmJ7liC3bDrjOIQFQg8+H/1+pNx4NW6lM
X-Received: by 2002:a63:2157:: with SMTP id s23mr9979199pgm.167.1565278968177;
        Thu, 08 Aug 2019 08:42:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278968; cv=none;
        d=google.com; s=arc-20160816;
        b=wsspVz+0r3/wYoA6WWlDHLUTDm1JDknrEoUthYliRYqQ+H1Wz9YVDfhKDQYGvW8ioL
         CXA4aUpkj1+uIi+HPDjxKf9n5jF46CLLLAQ3NyMACCOSH8QSaPWd1bJpaizE85yxDZMR
         bX8Me6h4l1pqhLmrotpJwnfixBv+/BXp6fvNJ4knLmSKL+RPVMGBdHNvjTGcQHmodKSL
         Iq5WFaBVWJCSwG7ieLgsErwXJ8wwTzC0ZeYpYAQj1v2w3UAW1mrEYARY+TV8F+SsTH9E
         SoZnTYx3JX5H+OCDMTA3OKnaD0l2qB2i5AYlJ4Yr6HB4Rm3HlWqzMGRtcobxP8UnkMeg
         7BjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=ToKAXlut0bLzp0i2AEiO/Hgmk4iALY2Z3psq1k6MNzg=;
        b=u4JGpII6g5oaXTLe76xRZm0YGYKHWeVq2KS2X1pL5MQa3bLploXceOQWMz8mqw/I+i
         TlW+Clvajotw01jQ7HI5QAwjll82w2kqehaUIVELpsH7352X4NuhMYOpVNMXgyCyMJWV
         hoNXWA4I+HlOxC35CK6reUeuEH2+FjgMINyUEhaI4WdBe8vHNUuW+VWpqeqstXErv4LK
         hhR23sm1R/+oeU1q8cZmb9wThh82xNqS1RBU7WEYueVidQrqPk9pwFYdwm+8bjfJDwxC
         Bx0+r2EJrnZMqR2bMUyg1xL3YSMey75p8o6IIC/Kr4cNCgaoclVeScGXG4QW8YXFsuB+
         MeFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=CGR53+Ky;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a19si43927024pgv.180.2019.08.08.08.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:42:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=CGR53+Ky;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ToKAXlut0bLzp0i2AEiO/Hgmk4iALY2Z3psq1k6MNzg=; b=CGR53+Ky/s5jodPOMrXDgVQqS
	nIdN8nlQ47Y/ET8+fk0jhQd86MbectDChtyIUnt+xMS+RhRlI9NSsrlraqp29G7BYyOtJAkn0aSFT
	znF+t0JxjzDTt8PdyUXzdAtr+80QUiW/K4dYv5VqKL78yv9h6sfZqMCQQqt6PEMCdvyROJa2DqKQt
	PxIcs9ozNrf1Eo9IOeLx3NpHC8EnLwGEw7EZuzK9CquVY6m28XgydRpMAd2ECum8NAR4W9ASeBCkI
	RTcDjFSXl9cWQk9TSzLzbY5W9+LBOcXqP+WjLl/3K42pRVwOQWUqAlHxb2SnvmI/1ZPE26TaDYbIE
	5dTFevMXw==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkYs-0008UM-8p; Thu, 08 Aug 2019 15:42:42 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?Thomas=20Hellstr=C3=B6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: cleanup the walk_page_range interface
Date: Thu,  8 Aug 2019 18:42:37 +0300
Message-Id: <20190808154240.9384-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

this series is based on a patch from Linus to split the callbacks
passed to walk_page_range and walk_page_vma into a separate structure
that can be marked const, with various cleanups from me on top.

Note that both Thomas and Steven have series touching this area pending,
and there are a couple consumer in flux too - the hmm tree already
conflicts with this series, and I have potential dma changes on top of
the consumers in Thomas and Steven's series, so we'll probably need a
git tree similar to the hmm one to synchronize these updates.


This series is also available as a git tre here:

    git://git.infradead.org/users/hch/misc.git pagewalk-cleanup

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/pagewalk-cleanup


Diffstat:

    14 files changed, 285 insertions(+), 278 deletions(-)

