Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE19DC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8473922387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ePnIO78e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8473922387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DD376B026B; Wed, 24 Jul 2019 00:25:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78F238E0003; Wed, 24 Jul 2019 00:25:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6094F8E0002; Wed, 24 Jul 2019 00:25:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4456B026B
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:25:39 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id r7so23346452plo.6
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:25:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=02PLAmxEK74OFGQcxHpfkZPpYQRAkLSlGOrHVK7lAMw=;
        b=EtP52KIsjfUU/oAZG9DOpphf1rkPLhqp/lqOaqRFiG8YBJkvscc23BX5tGf8RXLlpV
         Zu2tDF/S/5KVwPsersNOdIATfZ71krAGHUgZx6bf8biq+HDhawCAZeKjRQvATGg3cNU7
         TctIVy5sPTpLHBqtrkA7B835rA6ZBUMwluZkPctMwi6t3vgwqbSuHEi/4fD1tbNLq8hK
         3CgftADRAd5F07Yfnj5o8ievAs3g0inirH+252Mfwy6xGCS6l5oiFGyjVvgSGW7h25iD
         TEASs8BD+R9L02RTOckPv2Olr4s/bOnBncqj4NWirjS3r95knxe2NhD8VLHQL8Kq8HSr
         hxeQ==
X-Gm-Message-State: APjAAAWdohto7mUEqwbLuKkOERUTIPVpr9c2YjwPvGUEvIWx/ohzm9a0
	XofSdEAzxqDFte4oHC1hQCXKC1EF0C77spFpEpnUyInDpcnxQnEFCwg1PoZ0TkaN++WbEDl+gie
	lwU5z/6V2zQBkt8j9PWjnNZNww3gW7RfGh2E2K1IN8ZNvPnDgK0fiGmdCd3cALi8RYA==
X-Received: by 2002:a17:902:110b:: with SMTP id d11mr87509968pla.213.1563942338779;
        Tue, 23 Jul 2019 21:25:38 -0700 (PDT)
X-Received: by 2002:a17:902:110b:: with SMTP id d11mr87509903pla.213.1563942337521;
        Tue, 23 Jul 2019 21:25:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942337; cv=none;
        d=google.com; s=arc-20160816;
        b=Lyz328snpBbHDgzv/0Fr+PbcSy6m51M+puxcJe+cwVoqbvMmH78Elj8Q74R3NXxT+T
         ASoAHkbiZNsaI1WnAGetuLAEOUwKjvSmCLjn5dd5A96DJFOOxLcWEf/YiLXsaGLsXwhX
         qEZ0yFdT80i0s6yWjTC2s4Yiw3KcUt3p9mXm9sEl0DyPj0apyCQ2uIeKK5WMsUHjHmxK
         y3+eSXaUxbwJ828TpQkGodfincfyPd0nDDse0J92CSZmhDegwhCxG/eTQVI3dHU+Q8EK
         bJx6h/zw6fco28Zarrlz/Tdl109a7EFPE9p2DnQaPxRSd0rI/7C+3E/CPVDW66MNwZ8P
         E66A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=02PLAmxEK74OFGQcxHpfkZPpYQRAkLSlGOrHVK7lAMw=;
        b=Ds5WJyg9GeEHSxGsxN6nxpHBrYyUIbNg0jgZRSqYwch2S33bs9MLUYYfMpVZ27sRww
         Bbiy+Her2K56vsjqD8Oyw5+JIj+fXGR7Dz1qg6oq3flZYKl6+QQF77RK/OSdv0Q3NiVq
         6hC+RvMmn1SVEQjyDqeM6f1//alOqqzd8VRH5PAiZ00u5h8VXjRUevXQ7owNh7NWxYnE
         jYMyTySCCBmXqReIl0tXZ47SCIf3LvNDBVn4kcXxaqRV345bqXHI+XlNBIw5Na2ckC8g
         SoVcCKQZI/xK7wXDd13YssTMTKC0/K64bQTGH7UALTXGKjLKc9H/0YIcJORsRUnt1cjB
         C4Nw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ePnIO78e;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x9sor14264387pfn.15.2019.07.23.21.25.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:25:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ePnIO78e;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=02PLAmxEK74OFGQcxHpfkZPpYQRAkLSlGOrHVK7lAMw=;
        b=ePnIO78ePHju7ebrVW+7E2J/vpPNCVR6NpW8CfFYZY8+SSmWHWKTO0NxnamQnOd1xO
         1OGkt7YIiEVXHuQP8H6qf68cFYAXKIBbDAmLkkhsEsKXGaZ+gv+hELN1BEUzOzwBMd5C
         7+HvBq9DyjWP27jxx3AYMLHiRTGVA6MLCEKX2iEJB87gzmXSiGwi7V4lsrRtpgVdiW2p
         S3MHstLpNUFBNRlULB+VzXVBuGOOpmhbNeL8feVmi88K1eJfS5jDJOTI4suhlSh6IsAx
         VQkyNWZZC80jbTtz6ZOUtfZ39jWAkyRwTKuVKYxnomrnDfjnpzs8p0BXzMO9GjL2eB9Q
         8kCA==
X-Google-Smtp-Source: APXvYqzqsCqiqq73YLTFw/re4Wrx/oAutFm/LKqajLsW6nTmQ7iAK5rTUPq3/lEGra2dE5Y0hbuJJw==
X-Received: by 2002:a62:cdc3:: with SMTP id o186mr9322982pfg.168.1563942337240;
        Tue, 23 Jul 2019 21:25:37 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id a15sm34153364pgw.3.2019.07.23.21.25.35
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:25:36 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jason Wang <jasowang@redhat.com>,
	Jens Axboe <axboe@kernel.dk>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	ceph-devel@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org,
	samba-technical@lists.samba.org,
	v9fs-developer@lists.sourceforge.net,
	virtualization@lists.linux-foundation.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Boaz Harrosh <boaz@plexistor.com>
Subject: [PATCH 11/12] 9p/net: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 21:25:17 -0700
Message-Id: <20190724042518.14363-12-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190724042518.14363-1-jhubbard@nvidia.com>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: v9fs-developer@lists.sourceforge.net
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Ming Lei <ming.lei@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Boaz Harrosh <boaz@plexistor.com>
Cc: Eric Van Hensbergen <ericvh@gmail.com>
Cc: Latchesar Ionkov <lucho@ionkov.net>
Cc: Dominique Martinet <asmadeus@codewreck.org>
---
 net/9p/trans_common.c | 14 ++++++++++----
 net/9p/trans_common.h |  3 ++-
 net/9p/trans_virtio.c | 18 +++++++++++++-----
 3 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/net/9p/trans_common.c b/net/9p/trans_common.c
index 3dff68f05fb9..e5c359c369a6 100644
--- a/net/9p/trans_common.c
+++ b/net/9p/trans_common.c
@@ -19,12 +19,18 @@
 /**
  *  p9_release_pages - Release pages after the transaction.
  */
-void p9_release_pages(struct page **pages, int nr_pages)
+void p9_release_pages(struct page **pages, int nr_pages, bool from_gup)
 {
 	int i;
 
-	for (i = 0; i < nr_pages; i++)
-		if (pages[i])
-			put_page(pages[i]);
+	if (from_gup) {
+		for (i = 0; i < nr_pages; i++)
+			if (pages[i])
+				put_user_page(pages[i]);
+	} else {
+		for (i = 0; i < nr_pages; i++)
+			if (pages[i])
+				put_page(pages[i]);
+	}
 }
 EXPORT_SYMBOL(p9_release_pages);
diff --git a/net/9p/trans_common.h b/net/9p/trans_common.h
index c43babb3f635..dcf025867314 100644
--- a/net/9p/trans_common.h
+++ b/net/9p/trans_common.h
@@ -12,4 +12,5 @@
  *
  */
 
-void p9_release_pages(struct page **, int);
+void p9_release_pages(struct page **pages, int nr_pages, bool from_gup);
+
diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index a3cd90a74012..3714ca5ecdc2 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -306,11 +306,14 @@ static int p9_get_mapped_pages(struct virtio_chan *chan,
 			       struct iov_iter *data,
 			       int count,
 			       size_t *offs,
-			       int *need_drop)
+			       int *need_drop,
+			       bool *from_gup)
 {
 	int nr_pages;
 	int err;
 
+	*from_gup = false;
+
 	if (!iov_iter_count(data))
 		return 0;
 
@@ -332,6 +335,7 @@ static int p9_get_mapped_pages(struct virtio_chan *chan,
 		*need_drop = 1;
 		nr_pages = DIV_ROUND_UP(n + *offs, PAGE_SIZE);
 		atomic_add(nr_pages, &vp_pinned);
+		*from_gup = iov_iter_get_pages_use_gup(data);
 		return n;
 	} else {
 		/* kernel buffer, no need to pin pages */
@@ -397,13 +401,15 @@ p9_virtio_zc_request(struct p9_client *client, struct p9_req_t *req,
 	size_t offs;
 	int need_drop = 0;
 	int kicked = 0;
+	bool in_from_gup, out_from_gup;
 
 	p9_debug(P9_DEBUG_TRANS, "virtio request\n");
 
 	if (uodata) {
 		__le32 sz;
 		int n = p9_get_mapped_pages(chan, &out_pages, uodata,
-					    outlen, &offs, &need_drop);
+					    outlen, &offs, &need_drop,
+					    &out_from_gup);
 		if (n < 0) {
 			err = n;
 			goto err_out;
@@ -422,7 +428,8 @@ p9_virtio_zc_request(struct p9_client *client, struct p9_req_t *req,
 		memcpy(&req->tc.sdata[0], &sz, sizeof(sz));
 	} else if (uidata) {
 		int n = p9_get_mapped_pages(chan, &in_pages, uidata,
-					    inlen, &offs, &need_drop);
+					    inlen, &offs, &need_drop,
+					    &in_from_gup);
 		if (n < 0) {
 			err = n;
 			goto err_out;
@@ -504,11 +511,12 @@ p9_virtio_zc_request(struct p9_client *client, struct p9_req_t *req,
 err_out:
 	if (need_drop) {
 		if (in_pages) {
-			p9_release_pages(in_pages, in_nr_pages);
+			p9_release_pages(in_pages, in_nr_pages, in_from_gup);
 			atomic_sub(in_nr_pages, &vp_pinned);
 		}
 		if (out_pages) {
-			p9_release_pages(out_pages, out_nr_pages);
+			p9_release_pages(out_pages, out_nr_pages,
+					 out_from_gup);
 			atomic_sub(out_nr_pages, &vp_pinned);
 		}
 		/* wakeup anybody waiting for slots to pin pages */
-- 
2.22.0

