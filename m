Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CB55C282E2
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 15:31:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC9FC2087F
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 15:31:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="b/Yq2Wyk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC9FC2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22C5B6B0003; Sat, 20 Apr 2019 11:31:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DBAE6B0006; Sat, 20 Apr 2019 11:31:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F3226B0007; Sat, 20 Apr 2019 11:31:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3BFE6B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 11:31:52 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g48so7469398qtk.19
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 08:31:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :mime-version:content-transfer-encoding;
        bh=iv/3jCjojRbd14DgOBHd7PqX9WLmv8DR7Ac/LmkKrj0=;
        b=pDJhAqfvEMfIWCZgFrn26ZgEOk+RYIv8oJGXzW4aY1Sct46/ESxxobDHbQvHlnzEj2
         SX1ucpqBts/onE/9s+X/SIcKyn8fA/cVdL893LIbog1WEZHqb9nBjBu3/a5ff4I0FwnZ
         1IT3S9vObx3kNQ1tGQkyCl4vFINIIm5tcILoen+9FGmVgVXbEQQuOYJ6bwHHWgK+UvYi
         t9Hg/OvBhUh/E6qhHLg6FyOpcmjeebasiLKoEvAWYPiLW03rfNRyrG08mH7Iwb1UhZKv
         oCJghy2/ypRzyH+zh9Z8LOZc5oZhIh1+ukWIYsQqOeku9NEyy83e4icws0HoBxzxkQ/F
         e9uw==
X-Gm-Message-State: APjAAAWQwIT386M6BKKBlLQJ9LUGgkMjkk+tQ+gvrmsreCSGIYF1W+9k
	1yyuSNupd3Fh/sGFyaCKpDLRXaoL9cozGEeLIIzjv2U5P2wsvtUnxUQgyreYX9bwLsYjYqgmWwq
	gScal+8563mJ9+dfpn+eHk652uFeDgGZ6DaSGYU/RPmavGF0+b/DZrIiAvZeSInOjdA==
X-Received: by 2002:a37:5a05:: with SMTP id o5mr5335930qkb.94.1555774312606;
        Sat, 20 Apr 2019 08:31:52 -0700 (PDT)
X-Received: by 2002:a37:5a05:: with SMTP id o5mr5335864qkb.94.1555774311463;
        Sat, 20 Apr 2019 08:31:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555774311; cv=none;
        d=google.com; s=arc-20160816;
        b=qZ43vUj89yXYdijQwzOWUEH9PgGPxdkW5h3bg5EhazMDEZp5eaIWIE5Og2hbTw2bss
         Qv0lJjXQyuI5sEyuIix0lcSSYGckD02+Qi2DkO5vjG+mO02SVoCZXq1RrUwgxHmID4cp
         s5a6yJSsp6N+mlNr6dDM1pOzEYNHKcOBZZMI2wnL1WZcnOC00BB+wMVehJ9gXiOcqusU
         6mvtJejDBht7qMFQrNVzz535Qk+hDk5bwU9gdQO7PgMjMyU5qIucbNYPfXnmMkOSzl4G
         NfScvpizAwvTm3qhkZBJ0hsrT+7vbkIhn8uR3KRwhNs4clIwVqZwMrOet3t6s7F3H+Z8
         Brxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:dkim-signature;
        bh=iv/3jCjojRbd14DgOBHd7PqX9WLmv8DR7Ac/LmkKrj0=;
        b=dLRvRGbig6+0pUTavl71T+UK1AFzM71WpPmerKdK93vT/OCSpnqPNnXFSoocNHxg2/
         mEafiux0uM/HaiXApI3XY/RvqsFx67wc4p1ZI7OfFSNKUKcS/BrV/7eZtugjAFHCoBfL
         vAxPSGmxlwje919y6DO9ShPRLh9XPb5fSfpyyde5c3SgsEuM5Ar5q6Ruijgx9Xo4ASQH
         yKGbXxafvKzpz4ooBnxUG2TmXSgPx0P0nZRqvp+ES1b+aW76zsgZp2F3uwtU1ZzBr7BD
         dF+o4WAN57gg9d/CLv0/hZHSkVw6luOBSacyxkIafIqOfKIdD1AMkrQqXFFV4qBG3afK
         t93A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="b/Yq2Wyk";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j9sor11148252qth.30.2019.04.20.08.31.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 08:31:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="b/Yq2Wyk";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=iv/3jCjojRbd14DgOBHd7PqX9WLmv8DR7Ac/LmkKrj0=;
        b=b/Yq2Wyky+AzSHOY8doHM8jY0gDFDLN4Bwh9KAQ/2+IlQgeZY75BLUNWCKYxkdKv5n
         hS2Y+Ojmik31r27ETq9pxJpeop8Ag2eXVOpaOkBN2UHh5xm+yzaR7Ht1NlY+jEHUaZ7G
         D9HWFJY4TFDC0GQ8XSLYTxyCibHgzBAlnHx08PM/ZNlcGqxcZFrEWJq1KN2LvmVebPlA
         o3pVg2F8CmMUQhE823VPI3JGCn48LTavYXzWNiKBhXD00tk5UELtXpqCRgtY0CFU5GkH
         f4sDIvUpgnEziD65bkWGSAuxd1RTc8bArgId61nh2RCiDcDQCq92BSToui4qQPwDAZuy
         ppLQ==
X-Google-Smtp-Source: APXvYqwTnQt2szuODS6U8sqXMKFWO/ts92cmT+co0EE9kl200+47XKgG9xaCl7CYjK6wOgGhVT1l0w==
X-Received: by 2002:ac8:21ad:: with SMTP id 42mr8105239qty.219.1555774310943;
        Sat, 20 Apr 2019 08:31:50 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id n201sm3976523qka.10.2019.04.20.08.31.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Apr 2019 08:31:50 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	dave.hansen@linux.intel.com,
	dan.j.williams@intel.com,
	keith.busch@intel.com,
	vishal.l.verma@intel.com,
	dave.jiang@intel.com,
	zwisler@kernel.org,
	thomas.lendacky@amd.com,
	ying.huang@intel.com,
	fengguang.wu@intel.com,
	bp@suse.de,
	bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com,
	tiwai@suse.de,
	jglisse@redhat.com
Subject: [v1 0/2] "Hotremove" persistent memory
Date: Sat, 20 Apr 2019 11:31:46 -0400
Message-Id: <20190420153148.21548-1-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Recently, adding a persistent memory to be used like a regular RAM was
added to Linux. This work extends this functionality to also allow hot
removing persistent memory.

We (Microsoft) have a very important use case for this functionality.

The requirement is for physical machines with small amount of RAM (~8G)
to be able to reboot in a very short period of time (<1s). Yet, there is
a userland state that is expensive to recreate (~2G).

The solution is to boot machines with 2G preserved for persistent
memory.

Copy the state, and hotadd the persistent memory so machine still has all
8G for runtime. Before reboot, hotremove device-dax 2G, copy the memory
that is needed to be preserved to pmem0 device, and reboot.

The series of operations look like this:

	1. After boot restore /dev/pmem0 to boot
	2. Convert raw pmem0 to devdax
	ndctl create-namespace --mode devdax --map mem -e namespace0.0 -f
	3. Hotadd to System RAM 
	echo dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
	echo dax0.0 > /sys/bus/dax/drivers/kmem/new_id
	4. Before reboot hotremove device-dax memory from System RAM
	echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
	5. Create raw pmem0 device
	ndctl create-namespace --mode raw  -e namespace0.0 -f
	6. Copy the state to this device
	7. Do kexec reboot, or reboot through firmware, is firmware does not
	zero memory in pmem region.

Pavel Tatashin (2):
  device-dax: fix memory and resource leak if hotplug fails
  device-dax: "Hotremove" persistent memory that is used like normal RAM

 drivers/dax/dax-private.h |  2 +
 drivers/dax/kmem.c        | 82 ++++++++++++++++++++++++++++++++++++---
 2 files changed, 79 insertions(+), 5 deletions(-)

-- 
2.21.0

