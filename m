Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84331C41517
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:43:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47489217F4
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:43:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a5bFBq8d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47489217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E62AD6B0007; Wed,  7 Aug 2019 18:43:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E12C86B0008; Wed,  7 Aug 2019 18:43:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D03DF6B000A; Wed,  7 Aug 2019 18:43:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1EF6B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 18:43:20 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r142so57620589pfc.2
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 15:43:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=JeIgr7e7hHZv6A4Fffxt7LSkm0XrDQLm+lvjPBfxnRqFK+CH+k7f/avg434jafR/Mn
         RsnuT9vGTuvyCIeyr//z04qGSQzrcM7g0ciseurmsFGWyfF9PkVB/x/5wV+OJH0zrEl+
         w0cv05QLAHkuoTeGUBv10Yq+Uq+DlQODsiy/Gn4xEqQMgZU3AjDpiaLl5vGYNjFNfLk3
         eERVoPsm6bZqIeEUDkTaOVmTQREgo1gpMcOj3tFKhpWQXdFU+c/GpEIl6pNITONVX41/
         BLzSaAfP2Yoyww5J7VoVfVa+Jp2x3s9Bm9vKAAFEgRtMiSfG3at4jdVfZhqCPwZpOMPP
         My2w==
X-Gm-Message-State: APjAAAWu3j771NqVQOT13QxOerYpnHVlj69EoF83tDFdAqShl26GHFVR
	Vw6IPRHx8boHexNx1K6Nj+zmJOmGaLTR/sHBTwrJKRE2wGT2tl2/VnP4UHzyGAqatX7B+Phs1zV
	B8vRcDnctGhxmIsKxUVQnqDIxC6KcRd4Pllmpnu2L2U5amdaLq01yVFBpxjfH2ZXbdw==
X-Received: by 2002:a63:5765:: with SMTP id h37mr9515388pgm.183.1565217800215;
        Wed, 07 Aug 2019 15:43:20 -0700 (PDT)
X-Received: by 2002:a63:5765:: with SMTP id h37mr9515336pgm.183.1565217799210;
        Wed, 07 Aug 2019 15:43:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565217799; cv=none;
        d=google.com; s=arc-20160816;
        b=crKSpHzo41r0oN9H+sybRyqHZstj7ffoXWE+8e5o28T7LKJVprrDaTEArIkmgKmD03
         EDAtZlQbQBo0/+lD/4RwTEm4D/z83qiziJvZ3c7AqbNXrRaJEQMyrRy9U0Aqf4HxfWAB
         bFyZsGK2kxbHAm2og8+gqebfJG9LWFCHtxhPGEdakToZ1U8iDuMeQQ5nH9l/d3gPx13I
         ADpF5yZJzi319pXHIjCQUeH5kOsh0Gu03NFM+UFbrDH0cm7k4y/T5DpvknHvPde+A8tR
         i8SkYTsw7UUfjMRgkKx5jXclG9stcnbvAePUhWprbBdYcbzUE5ajh8CxN4j6ce6uWOIh
         s98w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=K0rjj+xKE2y9Hjv8wJfVET43X3n8GGwym7V+83xOE6kpP2YHpNvXl3Xe+NmsH43CiJ
         1icMbzjXocqJiEjKkcfqy7FThaeowKHq3SUYvJiefRTX+mh6qjXuK+LBytPgksJBfgKu
         qyryh/lXJG/qtctvn6o2moMJdSCgdqnFCeCqhOd6/trF9eh2XJ9DfW5R1d7+YClMuLZs
         q8jC8jrDOhUPKZ7wbBjf6jJvQCnWtdG9K1yyD3VnYGIT1fALrrxGUbhnZ8spdz7PxSBI
         LcNtskjW0sV+nplIYNcKHx9L8tRu230Fl4CPfgaBPxnypNQqnGG4k7B6m0Tb6TO6mmUR
         l9/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a5bFBq8d;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u15sor33597881pgn.82.2019.08.07.15.43.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 15:43:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a5bFBq8d;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=a5bFBq8dljd+KFQj8GsRoLSHGqJwQp1D5ijrMfnYKZTD6Bt+CaAUzJalWN7vPj8cwG
         pWIQHZeWlF01w9ODFOdx9z+f+AlMLp5FqwG2TA53NLFH8peXxKWTES629HP/akXRJg9n
         DJ4jY46AP3dbxMN0WsuHo/WqAxvhjf7UEESQNwx4G3HUYGxtjEoQXl58QUb/NYO66oVF
         3aabuZS4qG67Nxwzn84c+8qH9jDl5J0UQODHXlzenEHEQLM1eahgGf+upLYULSRlAiHW
         FaF3thHu2UqU5E+esQH85Bkzf9kbZTwMvNbp1I+Ebwv8CLfPptCXwrq0LMxDlQkwY/v6
         F5Yw==
X-Google-Smtp-Source: APXvYqyW8MKXNJvVuax/guRo5BBwLkQSLi3lLIO/meHglhLBkCaN+RruEG3XpplsxDaBU/3G1+9j0Q==
X-Received: by 2002:a65:5a8c:: with SMTP id c12mr9521695pgt.73.1565217798671;
        Wed, 07 Aug 2019 15:43:18 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id n128sm47421037pfn.46.2019.08.07.15.43.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 15:43:18 -0700 (PDT)
Subject: [PATCH v4 QEMU 2/3] virtio-balloon: Add bit to notify guest of
 unused page reporting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Wed, 07 Aug 2019 15:43:17 -0700
Message-ID: <20190807224317.7333.84787.stgit@localhost.localdomain>
In-Reply-To: <20190807224037.6891.53512.stgit@localhost.localdomain>
References: <20190807224037.6891.53512.stgit@localhost.localdomain>
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

