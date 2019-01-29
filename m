Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FD71C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:36:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC0CE2082C
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:36:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="JnOTWShy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC0CE2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 608378E0002; Tue, 29 Jan 2019 18:36:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B8A58E0001; Tue, 29 Jan 2019 18:36:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 481DD8E0002; Tue, 29 Jan 2019 18:36:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 233C58E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:36:23 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id i2so6635540ybo.23
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:36:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=ypcjhC5gLgv1najtmqf3KGwBGuKlXgrvvho14o6HPq4=;
        b=UV82Zsykj53+88CenQfPMqZ7TGEI9ufcTCMKmAsEV1C71KRSkZCZLI0RSh86TJfSts
         ZN3OtEbobxbnUlDHLi6vNX4zvO5ZFlU69N4qYleilwUNCDbr18li76obi6H9bwRd0jEn
         C5Ch8ZGsAh5Di/9QDxa6eE7zsk5mdYbkhRmKL9XJtyAjJnCv7IbtfTWk2njN2e7kssmr
         f2BtjoKDjiJLZDEzlIko7SbOzr6AJFLDfsN15iMXPZqiLFdyHOPnjvCJIRI3P5QbCplL
         gA10ko5TIoRtaTBNJP9uDwlWQeUJv+jwZKJGlQWSqsjJPWjfO6gyWslbRBCr6fJF4wr1
         s8RQ==
X-Gm-Message-State: AJcUukdU9xg2WxFEEaQAcLANGJ3mqQqXdyZNHdhLZw53sLhHoG0JP4sV
	vwSLmmBHF4hU1+iJ7EAP0XrWvvmrkR+pYl1Og4aZOl1xxsCsGYejV80eCnfESblGK5iz34GQ1yj
	9WsxSBLUeipm4XWpLk9D/bsw5pvtgqr3eVDdmSl0dKmDGB4/OALWE0u7y5inwIDPUhn6RqNBW79
	brY/dnKWd+P8tcDRxwqp9pwQe7W5mdFDDCtMzx4pcPLPakLmEbFYNwPfporKNJG51VHyHTfdxze
	v/C7kPZbjH+RXQz6W02U3vyux9wL8+fREG5G1MhTUqwYfYgjZd6QTKhGiXLXkynD5/yYFlrhS5h
	a88pbPwFIbjkh1A9udSf4pLvv194Wxd9XLNFdwZX5QWC33Wd4mb4rOAPnQ3I7lVIv+slER4Sa0v
	E
X-Received: by 2002:a81:650b:: with SMTP id z11mr26455797ywb.441.1548804982726;
        Tue, 29 Jan 2019 15:36:22 -0800 (PST)
X-Received: by 2002:a81:650b:: with SMTP id z11mr26455776ywb.441.1548804982064;
        Tue, 29 Jan 2019 15:36:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548804982; cv=none;
        d=google.com; s=arc-20160816;
        b=aeMa4BZsPMQGGTITrNIiCG4R8U/9bmqHFzoKDlWfbqc/8PD3QtiG2ZVQZROpm24BDm
         YK93uQ+AYeKdI5vI86Uxe9tcMNLoC9XqX0Esi64rmWglKCcuPVig5mCPHExMH4TjXKKn
         i4RIWHwy3Mo3nvSVkeCWdypA5Q0K7Jp6CgO9rIuGcrH3vcYZQ3gKaHi6g0rApj3PCz2v
         wCWmG2hUjbl5Lb5YnSMT9Q0bqoj6rjGXlVEuJmPCT5F92BBOu6MlM+P2cdyP5Hnip6fU
         2ykF6PGdEVyXcq51HSZiflkGD8EV9wOuWBFMIa9X8JJy6weGHktQgztNip4kwzpjMcm7
         4x0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=ypcjhC5gLgv1najtmqf3KGwBGuKlXgrvvho14o6HPq4=;
        b=EyUKwqElCE1BaEm8jxKghwiFFNJNBxZlNVqi3cEXwnNn7tcITSbZ/jXoV/Wil8kVqF
         2PmWeX4DwB9nYJ0qFwyATwDPwidyhipBM4x7AEKgCWw6rY8DRMMqiN4EHwPE9FWrfEe+
         lepzpOaI65CmbzheJ7Pc0qpqqG1B4tdlSJD0ldrZOUosQlZVFt7OdIj3lDc11D2wE/oP
         KKheW34a8y7YV5/H0ycjw0o5hjZWifmU/JJv/5sD/pcxWs2Bp4NzPzjk2YctjEsjgIpZ
         ORDEoI1mWguGZ5dwnkQKVCjqB3ae1b6GZyKlG4Y6b35WcHlPusOjPaUGYCsSv00CDA+2
         Jwpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=JnOTWShy;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor4932221ywa.0.2019.01.29.15.36.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 15:36:19 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=JnOTWShy;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ypcjhC5gLgv1najtmqf3KGwBGuKlXgrvvho14o6HPq4=;
        b=JnOTWShy8zOoZyip47uhC8ph1M4XcBA2QNn/g34BScolFhs1qAn5yHiIAiYqNKjwHY
         nmCc9DcEdq5jBZ8RAhFB/5J2py2kKU47cVjPJ+KWp/bwqEEe0RAxd5fOzNg1SVcsfEqK
         v8j/SDr9HWejcaQ0n9k7CG7A6XP2mgL6JkcmWaE6BKnZLlr51syPc9bw0yQBJnsu/rUZ
         EjMOSfq0hVZLVhf78Ieu+Vt168ODqC3uhSZlf9yg3mEfuw3Kwrh6XDmMMtkLHpSDDYiX
         n+K+K7XRC38sbnnXxoPxYPA1ZiZ/17uZZd6rHcaGaqYcNDdPG/OsjrYY6EEKOBDiDuWO
         bICA==
X-Google-Smtp-Source: ALg8bN6PRN1HYwkcGXaRrY0s20nXRdjPrEH7n5y8QSD0tg5DA7sqfugxO+FQ+zN8x44L+qcnQSxumA==
X-Received: by 2002:a81:6257:: with SMTP id w84mr27686832ywb.273.1548804979275;
        Tue, 29 Jan 2019 15:36:19 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:1d25])
        by smtp.gmail.com with ESMTPSA id j12sm16757805ywk.43.2019.01.29.15.36.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 15:36:18 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] psi: clarify the Kconfig text for the default-disable option
Date: Tue, 29 Jan 2019 18:36:17 -0500
Message-Id: <20190129233617.16767-1-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current help text caused some confusion in online forums about
whether or not to default-enable or default-disable psi in vendor
kernels. This is because it doesn't communicate the reason for why we
made this setting configurable in the first place: that the overhead
is non-zero in an artificial scheduler stress test.

Since this isn't representative of real workloads, and the effect was
not measurable in scheduler-heavy real world applications such as the
webservers and memcache installations at Facebook, it's fair to point
out that this is a pretty cautious option to select.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 init/Kconfig | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/init/Kconfig b/init/Kconfig
index 513fa544a134..ad3381e57402 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -512,6 +512,17 @@ config PSI_DEFAULT_DISABLED
 	  per default but can be enabled through passing psi=1 on the
 	  kernel commandline during boot.
 
+	  This feature adds some code to the task wakeup and sleep
+	  paths of the scheduler. The overhead is too low to affect
+	  common scheduling-intense workloads in practice (such as
+	  webservers, memcache), but it does show up in artificial
+	  scheduler stress tests, such as hackbench.
+
+	  If you are paranoid and not sure what the kernel will be
+	  used for, say Y.
+
+	  Say N if unsure.
+
 endmenu # "CPU/Task time and stats accounting"
 
 config CPU_ISOLATION
-- 
2.20.1

