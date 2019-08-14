Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 027DFC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA6CD216F4
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="SElBQSnY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA6CD216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D16176B000E; Wed, 14 Aug 2019 16:20:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD9556B0010; Wed, 14 Aug 2019 16:20:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4CF56B0266; Wed, 14 Aug 2019 16:20:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id 81CF76B000E
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:20:42 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 26D098248AA2
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:42 +0000 (UTC)
X-FDA: 75822151524.06.books64_613a28a9c808
X-HE-Tag: books64_613a28a9c808
X-Filterd-Recvd-Size: 4679
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:41 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id w5so348688edl.8
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:20:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=8YdsxBm4SorcCs6LR7QkyWK07j5ac679kdHnkcCO8NA=;
        b=SElBQSnY/MEpHH8627z9LUJO0AwXfwMVSdTTj8+/meirzqVOVaUQig461Ql4grU9BW
         AVOrqu2gy8FVObWFxEJFZZI9KGDQ9zAPfmV41ZLckaSp17XA9+mEmzFQIBhzh/7c6swP
         BOywaRmA/1lgbIGeuvAe+e1TOiq/MWLuxLS1U=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=8YdsxBm4SorcCs6LR7QkyWK07j5ac679kdHnkcCO8NA=;
        b=k7Cmj4G7jmjCWzFT69MM8IY6S4AmYEL/UYboR7oiaKIs/3Q3h+O4O58+8cwPWC3G2i
         sdLh/6FaPQ+CGoNxXgYE7sD+g6Pb+avLrt/jcTKXDzmswwl0tNkLP9kjyaoQaKU825fy
         TMivey+HUZy2Uyqd/cdGa/yIu7Z9gBXc3wB7pZota5TLmUAFXvwOMo5qXVXZvjHaX79r
         SuaUJh8dkXH0HcLPBdTqz43dwW+m6E1z2aHAJRQOBwJja1ZwnqeSiXXqAn0vYX9vB8n4
         dBdV6ax5aARLBzfujimPmLF+Artk5sUw9Q8f3Mml/LsqPcj9nivWVhZCbg/YnvKSiKs1
         jejQ==
X-Gm-Message-State: APjAAAVGIdjQFlMPBCM91PeJRymEHU8kgxOFWUASPuIVKWMyUI4hu/b9
	nWi1KfoDNeK/qzAYF3sqj1gLfg==
X-Google-Smtp-Source: APXvYqyP95CvDgYSo4eGFz7IoA7gCAiTTQNCbZZ85IgUxdxzhynRxhcbBwMwFB/O5KsYTtdIbvM0uQ==
X-Received: by 2002:aa7:d285:: with SMTP id w5mr1658562edq.134.1565814040425;
        Wed, 14 Aug 2019 13:20:40 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id ns22sm84342ejb.9.2019.08.14.13.20.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Aug 2019 13:20:39 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Balbir Singh <bsingharora@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: [PATCH 5/5] mm/hmm: WARN on illegal ->sync_cpu_device_pagetables errors
Date: Wed, 14 Aug 2019 22:20:27 +0200
Message-Id: <20190814202027.18735-6-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Similar to the warning in the mmu notifer, warning if an hmm mirror
callback gets it's blocking vs. nonblocking handling wrong, or if it
fails with anything else than -EAGAIN.

Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 mm/hmm.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/hmm.c b/mm/hmm.c
index 16b6731a34db..52ac59384268 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -205,6 +205,9 @@ static int hmm_invalidate_range_start(struct mmu_noti=
fier *mn,
 			ret =3D -EAGAIN;
 			break;
 		}
+		WARN(ret, "%pS callback failed with %d in %sblockable context\n",
+		     mirror->ops->sync_cpu_device_pagetables, ret,
+		     update.blockable ? "" : "non-");
 	}
 	up_read(&hmm->mirrors_sem);
=20
--=20
2.22.0


