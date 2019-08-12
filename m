Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 488E4C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:34:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0594220820
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:34:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LqnVlh5q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0594220820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABCEE6B0266; Mon, 12 Aug 2019 17:34:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6C056B0269; Mon, 12 Aug 2019 17:34:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 983E96B026A; Mon, 12 Aug 2019 17:34:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0185.hostedemail.com [216.40.44.185])
	by kanga.kvack.org (Postfix) with ESMTP id 7A78C6B0266
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:34:42 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2F1114859
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:34:42 +0000 (UTC)
X-FDA: 75815080404.09.spark35_633692c27c144
X-HE-Tag: spark35_633692c27c144
X-Filterd-Recvd-Size: 4570
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com [209.85.214.196])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:34:41 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id c2so48363145plz.13
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:34:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=LqnVlh5qwXJFuAES6AvqFxLV+HOJVvsMnunOc+a0bV4Yi1JKqAumYDprRdSCLepkMd
         7nX3R1JUVKI5IZNxd009+DcXEyNmcKrXLSGgHn1onPvgXFAytzu45ihmZu6nXGZjcsdE
         TcQlMZYpHJtPzNSbEXPle/C+NHykz0SwEZ6+JZSfGVKycsEW7KSZ6xnaPFangu3mAiAN
         T5IeWvWvrvIVjIuIWThjSuBqur0Qy7ft54j21bboL40n/Ggonb3DvHz/J9n2M0cKl46+
         uhjo9S8iIE9NPZ9PvXe/mQAyIGkrcviO1jDjU0fg9l0JSgIwKDa6TAxq1vXddbn9Ioe2
         hpmw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=sqHDhphoNTMLOMCaSq7RxKS/CP+DQaQ7IJB8rOZVosYReA8SACuRL2xtaitPhjnlKI
         YrHUKpY2nW54s89tPRgFMI/Ox0EfxhNtxHuQbwhMdJO8eckuwZbCp2UJqHVRofwbC6W8
         zQkYYfNq/AroiYcs6bmj3Da+7pcF2MD07YTLrkbJsIv8x+YWxaVFUmehqTn7okVCr+95
         lEzv6Lophjty+kYcT8dgYRyKLBj6b0alw4q29R8EGOeipXtWKCBHZxG09eGz4j7BaTHN
         zhKcbnexGN1mgZTS2TnZqOLm76cPyZWYIFA5ASFBKSXDTRwKaCdkmtikEhXg4bpPf8YG
         vkIA==
X-Gm-Message-State: APjAAAXbvOmPonnVlgnX3TYPrVCBc9/RSTleUREnNDrTVdiBz2C7drqL
	hQvPeEb6o1gg32tgMWfBU+A=
X-Google-Smtp-Source: APXvYqwXhOtrHg3dp0PNbSaVXSKNK/u6uHt5QRfcWxzex+pgpfmAcc/zMxe56yONs1VRm8Cl7HMK1A==
X-Received: by 2002:a17:902:8205:: with SMTP id x5mr35210808pln.279.1565645680733;
        Mon, 12 Aug 2019 14:34:40 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id 131sm129598899pfx.57.2019.08.12.14.34.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Aug 2019 14:34:40 -0700 (PDT)
Subject: [PATCH v5 QEMU 2/3] virtio-balloon: Add bit to notify guest of
 unused page reporting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, mhocko@kernel.org, alexander.h.duyck@linux.intel.com,
 osalvador@suse.de
Date: Mon, 12 Aug 2019 14:34:39 -0700
Message-ID: <20190812213439.22552.44254.stgit@localhost.localdomain>
In-Reply-To: <20190812213158.22097.30576.stgit@localhost.localdomain>
References: <20190812213158.22097.30576.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Add a bit for the page reporting feature provided by virtio-balloon.

This patch should be replaced once the feature is added to the Linux kernel
and the bit is backported into this exported kernel header.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/standard-headers/linux/virtio_balloon.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/standard-headers/linux/virtio_balloon.h
index 9375ca2a70de..1c5f6d6f2de6 100644
--- a/include/standard-headers/linux/virtio_balloon.h
+++ b/include/standard-headers/linux/virtio_balloon.h
@@ -36,6 +36,7 @@
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
+#define VIRTIO_BALLOON_F_REPORTING	5 /* Page reporting virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12


