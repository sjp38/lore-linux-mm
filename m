Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 488BEC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:05:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D85122CF8
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:05:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="naBgiF0A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D85122CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EBB56B0007; Tue,  3 Sep 2019 12:05:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C3536B0008; Tue,  3 Sep 2019 12:05:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FF106B000C; Tue,  3 Sep 2019 12:05:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0027.hostedemail.com [216.40.44.27])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF0C6B0007
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:05:30 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id F3A90824CA3A
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:05:29 +0000 (UTC)
X-FDA: 75894084420.16.ship56_6a0760a22c35d
X-HE-Tag: ship56_6a0760a22c35d
X-Filterd-Recvd-Size: 4091
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:05:28 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id k1so725452pls.11
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 09:05:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=tvXTRb5lTb+8B5XFSXnCmcD2ylzHPHyUlLmT6O6bjB8=;
        b=naBgiF0A8QgRy89rtmqoTZomowJ9uK/5AjCwiOZkdqSavGAgTEtHUEvi3BuU+ZsR1r
         Hk+/hBPe1mkmKr60NVAHnRmirg+F+2g+Kzua5FSmcqPhYpv/3jdJVV574ad54ITN73Rc
         cTYQMsE1N2FSJTVX5MTKW99AZnjgQlaS+vTsRl5fu1l4kykTT6PaT8J+1a6TJMHCDLIA
         JMj0TNF2mZ8XLf5nO/ABWSytNCpSpqefNx9kmcA5L2oAFj5jpP9ieWNMqzJxIxcCHUzE
         efpooqpVNE6l5QYc5zJMJQfBNTkEIMiuEPVCz9952cFkjaKFBkEJQTdUdPiSugr3iMA/
         +jjA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=tvXTRb5lTb+8B5XFSXnCmcD2ylzHPHyUlLmT6O6bjB8=;
        b=MEGd0LKUDYN8L9AMpskHXq0NMwLY7EqVK2pKebxyk7tvI0Tblo6HZm5iTMHZFOKK35
         ezdFdkB0leO9YR+NTBeEAIEsuPPb+E3g0prJiduxqrLX+GvIvpvNYXZMCEtEceM464wt
         4ykGGnyEh0ZjVZNbisOW/uwU91jMkIhWHdkgtmHp1vjhofdQjJm1S6DXFD3RT4ObuTL0
         EfuLkXuciLt6qS/bZ2+MTWuOI6YEqANM5CSZ6zcoASeoIK8vJrZ9lyiC/oOYGfSMsd58
         A30RGPdTnpRhNHihCtvn2wQpJIMLWD8oOrtOnCkVOnlj3rSlGzni3StNxn4fKzC/R5oT
         Lf9A==
X-Gm-Message-State: APjAAAXihe7RGjpFrFRHU7w5GntUu/A6R9P0HwbaiEtVA26loSdqlKJU
	fC0VfT0jTSodrbsafFXIkoY=
X-Google-Smtp-Source: APXvYqyG6ZxmJJmQ0MptfKqojMuF0K9Hu8/u4HROKumd5y2lXA1oHOH6rCFG98Ani34IiiGqmlRU+w==
X-Received: by 2002:a17:902:7792:: with SMTP id o18mr19221994pll.73.1567526726698;
        Tue, 03 Sep 2019 09:05:26 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id t11sm18501567pgb.33.2019.09.03.09.05.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 09:05:26 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 0/5] mm, slab: Make kmalloc_info[] contain all types of names
Date: Wed,  4 Sep 2019 00:04:25 +0800
Message-Id: <20190903160430.1368-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000010, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are three types of kmalloc, KMALLOC_NORMAL, KMALLOC_RECLAIM
and KMALLOC_DMA.

The name of KMALLOC_NORMAL is contained in kmalloc_info[].name,
but the names of KMALLOC_RECLAIM and KMALLOC_DMA are dynamically
generated by kmalloc_cache_name().

Patch1 predefines the names of all types of kmalloc to save
the time spent dynamically generating names.

The other 4 patches did some cleanup work.

These changes make sense, and the time spent by new_kmalloc_cache()
has been reduced by approximately 36.3%.

                         Time spent by
                         new_kmalloc_cache()
5.3-rc7                       66264
5.3-rc7+patch                 42188

Pengfei Li (5):
  mm, slab: Make kmalloc_info[] contain all types of names
  mm, slab_common: Remove unused kmalloc_cache_name()
  mm, slab: Remove unused kmalloc_size()
  mm, slab_common: Make 'type' is enum kmalloc_cache_type
  mm, slab_common: Make initializing KMALLOC_DMA start from 1

 include/linux/slab.h |  20 ---------
 mm/slab.c            |   7 +--
 mm/slab.h            |   2 +-
 mm/slab_common.c     | 101 +++++++++++++++++++++++--------------------
 4 files changed, 59 insertions(+), 71 deletions(-)

--=20
2.21.0


