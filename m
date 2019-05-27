Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AD68C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:53:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E3BC2146F
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:53:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d7+kIufB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E3BC2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C95086B0008; Mon, 27 May 2019 07:53:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4F2F6B0273; Mon, 27 May 2019 07:53:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B34556B0274; Mon, 27 May 2019 07:53:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4DF6B0008
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:53:17 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e6so11660297pgl.1
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:53:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=h7/sc5h9WgiFsGWJQ16HeJ0k14UeSaQXaZQVtIYPph4=;
        b=udN8B80Vojl10xdfVSs25dbK/NX7yLfv8VkC6SKy2sv9X68ZoDEBdjIxWuCx/nPfbP
         V7UM38PUcrBnDVmw5giZIl2/GUggSYrHQqweaptDHfTkYSXQX2sqCPQLjZ7kIZFQOnES
         nHxOhdOnqBcLF9D5bZL9SlFgNUymedNohHZF09O/KzZFMSLDZ08xMiLZVDSh4E7QvVPc
         Uma2FjL/mOV/IMi66rspqUE1gn9h5Z3H84GHPhgMA/gXD+VxHq40UejM5GsLIT5B4w/9
         A9xS57Igy/17e6mofToaK7/0SM3tB7tuu7i1/PaK83E8ymXu/R61kLlWvYlqsm0rRlj6
         t96A==
X-Gm-Message-State: APjAAAV2yTFitJtzXbT2o4EbK2G64b6dTkicR39Hj7ROrnklSi4WSePi
	P0hdMnmJacxZBOzhMdSdBeWuLSDUZMaStu95UoOAzhYFCZqGL2zkWguOdyIbhgBBqXUp5iXdb77
	QVSkg/KWkHmohfBXu38Bvfe0UJ1GoNDLSJMXahk1V9urmuE32PpG+IAQDkiYUvqOLkQ==
X-Received: by 2002:a17:90a:bf0d:: with SMTP id c13mr31223147pjs.88.1558957997038;
        Mon, 27 May 2019 04:53:17 -0700 (PDT)
X-Received: by 2002:a17:90a:bf0d:: with SMTP id c13mr31223086pjs.88.1558957995924;
        Mon, 27 May 2019 04:53:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558957995; cv=none;
        d=google.com; s=arc-20160816;
        b=XkmGTYrkNVK0jCiGHeSTkOf7KbzyLNympxxOI1Zp2K+9wgBeESxER7sWqKoI6Ux+a9
         6BebatOCKuqHCd9j4i6BIdNVRGyDz57mY6oz5kfz39V0+x7qBBQrBpuCrbZzkVg1Chf6
         W13rV0ZwytJ7kEttAmu+ogBVR7Wm+WUSXBXs6nMd5m1O6DgCL7mN+iWwFo8ZQ8dye40X
         Qta7ORQY+avepuO1wsZdbkVMWVpVrfzROcXQVTOAY1VE4W3cC6W+rLU7NxMie5nQ3HrB
         kdwa2IJjR3O1TmYzaMAclHLPl0gtHca/lJqGTe/pP2aqh9fhnEmAekzC4t3lYg2qhX10
         NlEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=h7/sc5h9WgiFsGWJQ16HeJ0k14UeSaQXaZQVtIYPph4=;
        b=hrTXKC8BVNacl0jGD5uAA7oEAKiwV5J0NjnM0cWuY7jmFLlmYkmswvr2gZTcVkyiGR
         Lfzc9+tmPJFXgeMn24MSmkbpalEu4iAvdA+Jjd1sf/Q+gk4cNASBg++qZuFGmwN3QEIC
         7zoPorXMhYs7Lg8HnQvxQxoZbF5OkAxkrYC7yOauyp3lwwDjocyB6z3kuAFZJcIqn4ne
         83pvFDWjqHEL74+ExD4nJh0wNM3YBVgAKfukH1r/zuK/9sNqOJbveqAlXPrKh0xObx1V
         whwbAjVu1XvFDICP7e6RAf0Jz6pPQgegTU+qgruR1fJ16Jf1f57j6hbWZbGKj3Gkh/uW
         gjTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d7+kIufB;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7sor10850370ple.21.2019.05.27.04.53.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 04:53:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d7+kIufB;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=h7/sc5h9WgiFsGWJQ16HeJ0k14UeSaQXaZQVtIYPph4=;
        b=d7+kIufBlb2p6NhbRgKuHbb0MuP11OPPdkyWK2kvC5ZdPKsE9qjwOFFo0vTYXQTor9
         8u+RoGE+aRYpW2dgjr+FDVmoIvXQtrqMoQgqLYBQP1H5hpVEae53KGp5mYjXvT00R9yd
         ZL2BwLprdK42dODwsteBGf+K81l1vUh6AaCo3nN/c6stpBegF2dsjV84RBZ+LnGkWkTy
         MtFmAVKsmxmqxL7vChYUMP9NIyOCnZpHwdeXCtWXQ0S+46GWrKSMvjHcc4zTmCNsdCua
         5IodEePJ2O+Urzx0UkAd3MyqNg+LRUJnH1lIYcktggW/R+asNNzfy5OIf7x/ct5DmTx1
         0qow==
X-Google-Smtp-Source: APXvYqwj/z0X+iQ8HMXXF0cupIZeeY0K0vA2fWZzYkiR9QoZl1gZ3ezYrUu1Xg8Qv/l3MqNuEw0eWQ==
X-Received: by 2002:a17:902:42a5:: with SMTP id h34mr104545424pld.178.1558957995698;
        Mon, 27 May 2019 04:53:15 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id e24sm9797738pgl.94.2019.05.27.04.53.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:53:14 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v2 0/3] mm: improvement in shrink slab
Date: Mon, 27 May 2019 19:52:51 +0800
Message-Id: <1558957974-23341-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the past few days, I found an issue in shrink slab.
We I was trying to fix it, I find there are something in shrink slab need
to be improved.

- #1 is to expose the min_slab_pages to help us analyze shrink slab.

- #2 is an code improvement.

- #3 is a fix to a issue. This issue is very easy to produce.
In the zone reclaim mode.
First you continuously cat a random non-exist file to produce
more and more dentry, then you read big file to produce page cache.
Finally you will find that the denty will never be shrunk.


Yafang Shao (3):
  mm/vmstat: expose min_slab_pages in /proc/zoneinfo
  mm/vmscan: change return type of shrink_node() to void
  mm/vmscan: shrink slab in node reclaim

 mm/vmscan.c | 33 +++++++++++++++++++++++++++++----
 mm/vmstat.c |  8 ++++++++
 2 files changed, 37 insertions(+), 4 deletions(-)

-- 
1.8.3.1

