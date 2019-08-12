Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2584FC32750
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:14:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E608420842
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:14:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E608420842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FE996B0008; Mon, 12 Aug 2019 09:14:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AF316B000A; Mon, 12 Aug 2019 09:14:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ED246B000C; Mon, 12 Aug 2019 09:14:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0010.hostedemail.com [216.40.44.10])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3D66B0008
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 09:14:10 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id F008E181AC9AE
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:14:09 +0000 (UTC)
X-FDA: 75813819018.28.steam13_5e86923b56b60
X-HE-Tag: steam13_5e86923b56b60
X-Filterd-Recvd-Size: 2683
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:14:09 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5CCB1C004F52;
	Mon, 12 Aug 2019 13:14:08 +0000 (UTC)
Received: from virtlab605.virt.lab.eng.bos.redhat.com (virtlab605.virt.lab.eng.bos.redhat.com [10.19.152.201])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 59F6E1000324;
	Mon, 12 Aug 2019 13:13:58 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	virtio-dev@lists.oasis-open.org,
	pbonzini@redhat.com,
	lcapitulino@redhat.com,
	pagupta@redhat.com,
	wei.w.wang@intel.com,
	yang.zhang.wz@gmail.com,
	riel@surriel.com,
	david@redhat.com,
	mst@redhat.com,
	dodgen@google.com,
	konrad.wilk@oracle.com,
	dhildenb@redhat.com,
	aarcange@redhat.com,
	alexander.duyck@gmail.com,
	john.starks@microsoft.com,
	dave.hansen@intel.com,
	mhocko@suse.com,
	cohuck@redhat.com
Subject: [QEMU Patch 1/2] virtio-balloon: adding bit for page reporting support
Date: Mon, 12 Aug 2019 09:13:56 -0400
Message-Id: <20190812131357.27312-1-nitesh@redhat.com>
In-Reply-To: <20190812131235.27244-1-nitesh@redhat.com>
References: <20190812131235.27244-1-nitesh@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 12 Aug 2019 13:14:08 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch will be replaced once the feature is merged into the
Linux kernel.

Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
---
 include/standard-headers/linux/virtio_balloon.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/st=
andard-headers/linux/virtio_balloon.h
index 9375ca2a70..1c5f6d6f2d 100644
--- a/include/standard-headers/linux/virtio_balloon.h
+++ b/include/standard-headers/linux/virtio_balloon.h
@@ -36,6 +36,7 @@
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning =
*/
+#define VIRTIO_BALLOON_F_REPORTING	5 /* Page reporting virtqueue */
=20
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
--=20
2.21.0


