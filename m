Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9610C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:55:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A6FF217D7
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:55:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Swb7dcHK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A6FF217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0EB46B0005; Thu, 18 Apr 2019 11:55:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBCB26B0006; Thu, 18 Apr 2019 11:55:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAD326B0007; Thu, 18 Apr 2019 11:55:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9F76B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:55:54 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d16so1709808pll.21
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:55:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :in-reply-to:message-id:mime-version:content-transfer-encoding;
        bh=Mwu8bdvzFWo5PJrnmoXM4uXFOyCPd9+D4w2uDhG61cs=;
        b=sWrUvzxJGVOhmBJ8dkLqtp9Jz8Eo/MjIr2VIJMgSEVLlkvvG7bVnDgukx6M8Mw1Env
         LCNhcuSQit1u8w+Gx7sHQBNfClcEEhxZuIJxvbRWwd5YbnjYdVboPHORsEDh1hO71sOI
         hlYKduuOH7J4lsq2Ot7ah8O2Ymc/ldIgU/0WYRUWpuc648QT/wvdVwKp84r5dVkS1zBC
         WoLp9U4WkGDCWuE9SszJHIrvXM8iTEtQd5irGKCafUoD6v87616w2cVmc+QF55LPAeIR
         95liEaFaQC60d6AwdyY6aSDSgCD2ULhd96fgOihTwXF9lmLNdUPTQGfgws7ClFoEkxrd
         L9EQ==
X-Gm-Message-State: APjAAAVUCeNX67FtG0vTcihs9+MRI9AVWpiikl+YuphYDWZawA4Xmqjd
	o1FdAtX+LMIvTtHT/vJX4lmzed29ZpWk6ONX+R53+G2M2idZixJgF8C5V9pge09+Lb9TSyvY2eK
	/VYCMjfqTgAzA9y951U22mFa48c/Jzp38mFYkdXGvh0nRScc6GYaxaJIHMvpAoFIdIA==
X-Received: by 2002:a62:6f47:: with SMTP id k68mr80515535pfc.196.1555602954108;
        Thu, 18 Apr 2019 08:55:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXWWdpqOOV0xqNep4u78TR8lujiBR8X7bgQwwsdxm6r6hwu/S8S3wLLGUnacxQZDBC0yy3
X-Received: by 2002:a62:6f47:: with SMTP id k68mr80515474pfc.196.1555602953440;
        Thu, 18 Apr 2019 08:55:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555602953; cv=none;
        d=google.com; s=arc-20160816;
        b=1JQhE10hHm0oGtOomFI1vU/4QROuoDc8afIlHWlBcKgziPPq8LDvEtZ44OaaO3Bcrv
         0hi+8lPkq2oBACes+5P9B287M5wGKxe5RzPW8aFwQU5q/fNeOyNbkPsd5glL0FQFEJEx
         FxFTBm0rMG6GiCb17/cHWkpXdKKQn+RKFv8iLMr3yTSbucifh1lhVao7u2nrZwc3oSO3
         crzDNbqViyV8ysTBVI/8soqNEOcTZNkSSwJNSrqPlcbMNf3k4nXuuvfr00bCttfYgZSY
         BVaf7sU9a/MbbNJznFIgHHoIwTvQLfbY14PAtODF/QWTLI/65RnAAehr0EhnbqbIsBUu
         9JFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:in-reply-to:date
         :from:cc:to:subject:dkim-signature;
        bh=Mwu8bdvzFWo5PJrnmoXM4uXFOyCPd9+D4w2uDhG61cs=;
        b=NrbMI6F3rEhzQjreaix0/Za+JuIC2QuTMSZWG1BHvQE986axQ/07Wh8t6RfNi5KhF4
         ItsTbFyKHHNKDY2zZKemLGoWrM7LW80MGKwuapShFA/TU7glL7Aosg8la9XIvVWT2Hj1
         gU4kokEJbBZQoUDJt+D44UN2C9dBJugCRinh/YReSBdqzKTBpVQk1n1j6huxOtFjkcGh
         49kaJnHBUh+g+ax0tz946Wfv/n3jNedOPhHmCUipeX5rXVi9SZ3yg3oHepTtOJsN1qVk
         I6ZgIxw2abVE/f7dMGqW2X3ajxh4WI2icJ9rbU4CEAUVoWKxZLLU8+qOq2XN08emTpx5
         P7sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Swb7dcHK;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id ci14si2558993plb.264.2019.04.18.08.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 08:55:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Swb7dcHK;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 774F02148D;
	Thu, 18 Apr 2019 15:55:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555602953;
	bh=p8Vh6V/JTze/+NYlJaIw/h/hfPhRHxpUig1heR6KLfQ=;
	h=Subject:To:Cc:From:Date:In-Reply-To:From;
	b=Swb7dcHKN4LEqyt5U4Zxl2i3IhVPWdikiW6D32NbGmU+3+onCiVdaEkSeAI4Mxk5I
	 4CEcQBJyAQeafumPuTgfLLia1tU8zBDrjYl9qjjg1ZlqaKqwhjGw6Q38pB9r84F+Ew
	 Gf4inQCCypyAeyOu0yLveLpgDwskYdkfhkdOt2X8=
Subject: Patch "[PATCH 4.19.y 2/2] mm: hide incomplete nr_indirectly_reclaimable in sysfs" has been added to the 4.14-stable tree
To: gregkh@linuxfoundation.org,guro@fb.com,khlebnikov@yandex-team.ru,linux-mm@kvack.org,vbabka@suse.cz
Cc: <stable-commits@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Thu, 18 Apr 2019 17:55:50 +0200
In-Reply-To: <155482954368.2823.12386748649541618609.stgit@buzz>
Message-ID: <155560295039175@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
X-stable: commit
X-Patchwork-Hint: ignore 
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


This is a note to let you know that I've just added the patch titled

    [PATCH 4.19.y 2/2] mm: hide incomplete nr_indirectly_reclaimable in sysfs

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     mm-hide-incomplete-nr_indirectly_reclaimable-in-sysfs.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


From khlebnikov@yandex-team.ru  Thu Apr 18 17:53:53 2019
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 09 Apr 2019 20:05:43 +0300
Subject: [PATCH 4.19.y 2/2] mm: hide incomplete nr_indirectly_reclaimable in sysfs
To: stable@vger.kernel.org
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Vlastimil Babka <vbabka@suse.cz>
Message-ID: <155482954368.2823.12386748649541618609.stgit@buzz>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

In upstream branch this fixed by commit b29940c1abd7 ("mm: rename and
change semantics of nr_indirectly_reclaimable_bytes").

This fixes /sys/devices/system/node/node*/vmstat format:

...
nr_dirtied 6613155
nr_written 5796802
 11089216
...

Cc: <stable@vger.kernel.org> # 4.19.y
Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Roman Gushchin <guro@fb.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/base/node.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -197,11 +197,16 @@ static ssize_t node_read_vmstat(struct d
 			     sum_zone_numa_state(nid, i));
 #endif
 
-	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
+		/* Skip hidden vmstat items. */
+		if (*vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
+				 NR_VM_NUMA_STAT_ITEMS] == '\0')
+			continue;
 		n += sprintf(buf+n, "%s %lu\n",
 			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
 			     NR_VM_NUMA_STAT_ITEMS],
 			     node_page_state(pgdat, i));
+	}
 
 	return n;
 }


Patches currently in stable-queue which might be from khlebnikov@yandex-team.ru are

queue-4.14/mm-hide-incomplete-nr_indirectly_reclaimable-in-sysfs.patch

