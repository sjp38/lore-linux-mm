Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99DEEC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53E8A22387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="N74tfFBy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53E8A22387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5FE36B000E; Wed, 24 Jul 2019 00:25:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE9B28E0003; Wed, 24 Jul 2019 00:25:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9159E8E0002; Wed, 24 Jul 2019 00:25:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C53C6B000E
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:25:31 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h5so27450931pgq.23
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:25:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sE4MQj+XhMD6UPTZi8xJ0bNX4cYnp7r/5/gkEQk0tas=;
        b=b4bh0Q4ts0nAyRMae0E2Wqg3Wtghz0ySS5FRyvU56en48TvI9LXqqSRo7Bz1hprbhq
         3WR8l8zEyGsjGMGaaTuiTM+YRGVLQT9StsoEFuccKsLvYIzstIBm+muIsZohsATgxBaN
         JW+5IyuW61tJeSnFmNz91RnKgneDHIDxAKDEyOjmme7agpJutEni2P82JUTTTn+A2EzO
         pLQN1WE5y/CFIqKyikAL05vYq4df+RDxgBx5znOIuXg0xYukcugaIn5DgnICinKgdO7g
         NQnw6pVJUkQkV7S7DsxQwIbAlNIL8i8MXnRZBvPY7Ac7s/h9TuYBp0SG0Qb5WAXmTter
         /vfg==
X-Gm-Message-State: APjAAAUGZDTT6TF2c4t9qRdzEN13f8BSvNjN5OIF4lX61cc2n0hVUb+d
	eJcyups9jq0JdkooJYL7G4ex3wo3y14b/50OkEqfrB649cQDraIsg3VC1/GVP9ndFUSrRSSTFCj
	SlLnSi3Z+SQwXjCGW0CGh4UON1mhjPAdEpBjvAc7U3DNrueUNONoWrNmFyfB5KwhFQA==
X-Received: by 2002:a17:902:7288:: with SMTP id d8mr83793909pll.133.1563942330956;
        Tue, 23 Jul 2019 21:25:30 -0700 (PDT)
X-Received: by 2002:a17:902:7288:: with SMTP id d8mr83793852pll.133.1563942329984;
        Tue, 23 Jul 2019 21:25:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942329; cv=none;
        d=google.com; s=arc-20160816;
        b=SxMCPAMphrakBp0Y3CL2AOkLDLRMLlFt9k6fCbcRzhpeTLqpocp1Gsliie0Wzu235H
         jmDFTckR4tvCbGtwKPpiJonIjkk8uExvAeP5+tiMlCi46wJY/PXwOh58lEmooilyuOt0
         ZbpHyt+3Wa66vLhph7vkLmTm2DNxJi3O78vKCR/xtDjLLmfV+w9q6FgPw6/S+Ghk6xwJ
         NZAVVUvK0Kj5D5BMJ4siGm47T0So1mEo2sRZSdhrMM3pKkkO5ATOURoaYJIfkYGix4JI
         yIkgM/ceAoYonUV0MZJS/XkNjMBGuZXtktfiUfC9B59Qp3fLenKI0YYFcaTzpNMIMNe9
         vx6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=sE4MQj+XhMD6UPTZi8xJ0bNX4cYnp7r/5/gkEQk0tas=;
        b=hsmhz4kVOyuDqjIQI2BqKwDR53UDYqMJHCKBWxc/6TC0gGzXjgVTedNcePyx770S3K
         35zvPkgka3He0IRLw4Cxvp+b1TxzkCfNfg6CNTcbPFzcJhwreU4eGISRF9aziY1/1Mw+
         G34AVxpVjtclxtdseB4bxyt+UDfwb/IrwJYNnspRdqkebTgC0qqwt3osY8SgmVyUbsW6
         X9TC/dbqNkhfkiRK1777mSDM4fF7k5y0ZMdmHy2dYQ5X56F3o3tCA1Eb6MmvezJRVdAp
         hdvmzINdlt2oqxX90avIS6iGEzB8I/q2VSn4ZMf/HYqooYOlETFqF4DZsbg0H65u1uYS
         HPyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=N74tfFBy;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4sor26084720pfb.41.2019.07.23.21.25.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:25:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=N74tfFBy;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=sE4MQj+XhMD6UPTZi8xJ0bNX4cYnp7r/5/gkEQk0tas=;
        b=N74tfFByAZggYZcsUYTvgYBqmp8bGoZSPNbPePQDgI9xHOKtDI+JBR5Z/IiOFQ1dt4
         oWVFdgGyfImD0LwBldj16IkrMRl7/f0OT/Q4l6ls05QNNVgjJIUWu+aeK2CLI7WrmOO1
         TCwZxwbVGwL+85kP8X47MDnZlnY5CwsAaw+XO6UEjqntQs8fO4Oc87gAiS/1YP6rdwM3
         9NVpw94/A/DYK3lq7v7X4QjwLe8vgVS0TAdSk8ZgDg7r0yVNM7SKDo6TuP97iAlISt79
         gTDmZw4nL2v0p7bxSBy6D4Zi0oq/Mz2I8pSvkTef9m0MiEMvo0WtG93wFrP09qcMFi9e
         QIZA==
X-Google-Smtp-Source: APXvYqxW3prZwkWHWgnoMEubD7xNwrSIeIAF1uZdix4e6/fDDx4fF84KKWNkiOUj/KQ81cpzXumLMA==
X-Received: by 2002:a62:4d85:: with SMTP id a127mr9256862pfb.148.1563942329748;
        Tue, 23 Jul 2019 21:25:29 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id a15sm34153364pgw.3.2019.07.23.21.25.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:25:29 -0700 (PDT)
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
Subject: [PATCH 06/12] fs/nfs: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 21:25:12 -0700
Message-Id: <20190724042518.14363-7-jhubbard@nvidia.com>
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
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-nfs@vger.kernel.org
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
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
---
 fs/nfs/direct.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 0cb442406168..35f30fe2900f 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -512,7 +512,10 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			pos += req_len;
 			dreq->bytes_left -= req_len;
 		}
-		nfs_direct_release_pages(pagevec, npages);
+		if (iov_iter_get_pages_use_gup(iter))
+			put_user_pages(pagevec, npages);
+		else
+			nfs_direct_release_pages(pagevec, npages);
 		kvfree(pagevec);
 		if (result < 0)
 			break;
@@ -935,7 +938,10 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			pos += req_len;
 			dreq->bytes_left -= req_len;
 		}
-		nfs_direct_release_pages(pagevec, npages);
+		if (iov_iter_get_pages_use_gup(iter))
+			put_user_pages(pagevec, npages);
+		else
+			nfs_direct_release_pages(pagevec, npages);
 		kvfree(pagevec);
 		if (result < 0)
 			break;
-- 
2.22.0

