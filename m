Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D3E2C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 19:11:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6C8D218D3
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 19:11:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6C8D218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 614068E0061; Thu,  7 Feb 2019 14:11:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C3B88E0002; Thu,  7 Feb 2019 14:11:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4659E8E0061; Thu,  7 Feb 2019 14:11:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 204F98E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 14:11:20 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id y83so847234qka.7
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 11:11:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition;
        bh=jE93ztQqK6ZP7V9w/37QJKes+ynfDKh1VBV042zKvCI=;
        b=Xfr4aB07aSJNmEOpwaUlfT2vEW7F6t9U76Pd4kHseIcB2BYmBSSFOB/GXwj947g8Y8
         7t7ytXP8W3SYGtt5vnwxqIwCWTM5gf0bgVO+/dtv9R0aMwKR8EvCO76OPEfc65D/9cIn
         1ery95nEzGYpc1unfUgAf2wSneLCN7EZF83kEB9CSuPhpx/9YYfZhAu3+KyVD3E7sqmk
         LlILy8842PnzjdVrHRmSSOKRmTvvkj9lZKhNSTcIeaKKK5fFbCOZ3e5TxxQiyPMN+dit
         dWd1logYMFPCTY69HGHjKhx+s6ku4LbAk2y4dSSAOw5aRXBYOfJGaUTnuxL4mUtfZTqT
         KAEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaXCteu5tnycScpZRLjbCClMd2baXpuqYK42FPAhE3h48ujMzAR
	MlHx1jyBFBHgoIj9Mj7D4UIhXiCBndc5HjanPfSQOTyevFvKSAVJT8xGJxIj+4p4o/fox4auUgM
	BoNyNpVm3Pvjvp5lqrm0eVJ85C8D/Z3ynRls+yWB5P+RjBa650fLSf4djvxK2BzwGfA==
X-Received: by 2002:a0c:d033:: with SMTP id u48mr13116487qvg.146.1549566679842;
        Thu, 07 Feb 2019 11:11:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IabA+P5EOEr9030pA4ZNywZGbN245y606ZMY9BDO11HpDQ6nNiNaMQDlNQbAfQn7s3+4tMZ
X-Received: by 2002:a0c:d033:: with SMTP id u48mr13116454qvg.146.1549566679358;
        Thu, 07 Feb 2019 11:11:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549566679; cv=none;
        d=google.com; s=arc-20160816;
        b=ZVNYk8wvldwhaqc8/s3dLvslEB2bdxW6ylf24rmQ82QqlwWkDlbtY6FY770rf8QMtH
         e1xPgQQmb8f2wE0i3WQ6Ot1mj6ta+GjavGEn4r5y9ngtuBYY0eA6acWFIOugw6iqtunt
         tRg48U2YSDZmqBtktsqfAnfAv3Yc0DbB3Y/FmXnAgFl6q85C2hY4gYlK17t3gQ+1IWaO
         YjWn7bPEa4VyMdHwHv7+HrYYWJ0NVAx4s8+4E/OnJvoQwiBNcXA5iIVGDkeBlQidPN9O
         Do2+jopnoxrNr8GeP8zuZjDshcqHQPzKrY/j1hG2aqQFkBqlal5MZHzoCMOkcCylQN0X
         fppw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date;
        bh=jE93ztQqK6ZP7V9w/37QJKes+ynfDKh1VBV042zKvCI=;
        b=YAbq4ynC+zpuZQ7lrndyBhVWTvyvwVWCaFMkSN89kup3M3zg0+E/eG2qjHNCD39q2S
         tZ1UsRD6DsPrV07xLuxhFCQUe/koOE9QMiNm61qb1HF6J5MsUKl48mDrzrsAFyjsLv3U
         H71WLlbGKlZkN8A/sQcdxOim1uslnG9f894WTCvIdkjgBpbmorjuyCEBrBWc6OfNLYiw
         1acYoGSfZHZnuY8BCKvxW6+VcEC9ZiIRrzMWUoInyZ0yMcRiXTRUj9B9R5z+nilNs3Iv
         aX51WE5eY7fQKqrzOaaoLcFCQBaSDzkAu+OtQKaPjgBY0nG/t6VEgZPP/PErBfK3/1XM
         m/hA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j18si17029278qth.388.2019.02.07.11.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 11:11:19 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 48CFB3DE0E;
	Thu,  7 Feb 2019 19:11:18 +0000 (UTC)
Received: from redhat.com (ovpn-123-55.rdu2.redhat.com [10.10.123.55])
	by smtp.corp.redhat.com (Postfix) with SMTP id 2D07063F61;
	Thu,  7 Feb 2019 19:11:17 +0000 (UTC)
Date: Thu, 7 Feb 2019 14:11:16 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: trivial@kernel.org, linux-mm@kvack.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	akpm@linux-foundation.org
Subject: [PATCH] mm/page_poison: update comment after code moved
Message-ID: <20190207191113.14039-1-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mutt-Fcc: =sent
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 07 Feb 2019 19:11:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mm/debug-pagealloc.c is no more, so of course header now needs to be
updated. This seems like something checkpatch should be
able to catch - worth looking into?

Cc: trivial@kernel.org
Cc: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org
Fixes: 8823b1dbc05f ("mm/page_poison.c: enable PAGE_POISONING as a separate option")
---
 include/linux/poison.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/poison.h b/include/linux/poison.h
index 15927ebc22f2..5046bad0c1c5 100644
--- a/include/linux/poison.h
+++ b/include/linux/poison.h
@@ -30,7 +30,7 @@
  */
 #define TIMER_ENTRY_STATIC	((void *) 0x300 + POISON_POINTER_DELTA)
 
-/********** mm/debug-pagealloc.c **********/
+/********** mm/page_poison.c **********/
 #ifdef CONFIG_PAGE_POISONING_ZERO
 #define PAGE_POISON 0x00
 #else
-- 
MST

