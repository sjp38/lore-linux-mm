Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17C0FC00319
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 04:39:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA5E420857
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 04:39:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QTCUa43Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA5E420857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFD448E0003; Fri,  1 Mar 2019 23:39:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DABFA8E0001; Fri,  1 Mar 2019 23:39:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC4808E0003; Fri,  1 Mar 2019 23:39:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB838E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 23:39:18 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id e5so19154646pgc.16
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 20:39:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=E8xVMa3UyuhomxW571zy6yHj+BYk0T3qqrgE0C01lI8=;
        b=llfLy5kRi156w5+vJjz6zl4+EbTj0hc2xl911vhC7rRDdhyu9S06x32F31XT1LlZ+7
         dSxHERbdiFSIs+VpfBmT0YJsjGaNzWrfQshMQ2D5HKaXK4YiRawSmbWxyD231xPx7sum
         if7+KKlSuBg7uxQvgsp4rX63lknSqGMN5j1uPh7GpzE3vWpCAPB67HznvKz/rU5q1T1P
         lIP9A2pbuvM2vyxpoGWtmc+aZSXmmdxJSiBkKP39P7TWN5y/TsO4YdZ5VhDnZllmCUaX
         qyik2n/caBxg+JhZKmFrhqOVOwv7Jt1S4MMXK84T5erITBN/NXIBhdMRge+TobVzogO3
         LamA==
X-Gm-Message-State: APjAAAVS+EvK5sb0LQohhrlmMR/u59hKgdCof3J5QYWuLsaycr+2BsyZ
	zvRsTZTyBtRr3nVjvQ82Z16VWDPoyho7etWjHMxY84+Re+6XST+sj92nskdBfi9lrgqg1kajp95
	Ff6kYehO7KouYQBXb3U0EZt4ougRH1nvCJi8gpuFJSd+kGH3TQm5k4t5xWftO4VLGYbIH/BHmnt
	lIGEp9Tidk9gL0h14VJmeJH8PsK+uMtyVGxBvNR9rkA2Qrto+gdnvhcjLROVib0RsYvIaM2K0Me
	q5z1RnPtHPTSMnW6g7KUHX7qYpVEKLnDUQoUWsNc1SuV3fp8ib12GRswFQf8neYz+6FGfWm2Jo1
	2mgAeEPp/A54WanbzGcXPyFNgbMYEPa42iMwVJfCVZLWiFh2d180qeSU/+UV+Twj8Zxb8PU7pN/
	Q
X-Received: by 2002:a65:624a:: with SMTP id q10mr8456832pgv.377.1551501558161;
        Fri, 01 Mar 2019 20:39:18 -0800 (PST)
X-Received: by 2002:a65:624a:: with SMTP id q10mr8456790pgv.377.1551501556992;
        Fri, 01 Mar 2019 20:39:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551501556; cv=none;
        d=google.com; s=arc-20160816;
        b=JbfI7Y39vKQXReuwMO0doc6vK8lkGL+morID+Kuy5K2O4GWArlty4ukn0Uw1QU8vcG
         e8nf4XTm6YnE/KELQC9dbNJwuBquMuIEaVZFsXxAeaSSmBXMS54XVGJfLe2yvBxugp7X
         Ug+PyYZe4LfSgAclAbA5QpDUIKV0W5vQw96HaGBxVQXHbH0RQ2WQEnQb0E27+Sjng22w
         aPXsTr6ENYF+uPM8CrpU5hoNR+tTR1wB+BQbLYSVTdM9GZrqkpaUcEcZEaMBQlGf1Nt9
         XxLuQ76dY4+QmQuHYaqJndA3+w4U380dwwSHowaVBj1ieEYz5+io4qbAhDzbJgXTuZFf
         T9BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=E8xVMa3UyuhomxW571zy6yHj+BYk0T3qqrgE0C01lI8=;
        b=arx322biyduOLuPLnnNEB6r+RcYVkN4u+rPsegOS24wHhgyjWqTeMMQhQihqrF08fb
         9hZ3/NWDxLfDr5vHGTIgatvYe1DIr1goMraI8xWHDPC4TjKXaUFXMQb1+aPWYEENkIWG
         Ry9v71qf1vXhSF4u7KYF5FiFPIasSB9jzRCmZY1bLRccUCO1d25y/IypyAQqeVMukbYu
         8w767Ve7KOQYiJukLhhVBNaNWsxbajXQpwQKqxlEi+NIwxZUvCrTJg8HsCel5plxDtoJ
         ViJ0jNvCejklpZFhRCyQlAO2wfLx0IgroDC/I/xbNDqAsvFO1xYUT5jE2GNe4KpcaFAS
         i3FA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QTCUa43Q;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x12sor9671123pgj.56.2019.03.01.20.39.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 20:39:16 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QTCUa43Q;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=E8xVMa3UyuhomxW571zy6yHj+BYk0T3qqrgE0C01lI8=;
        b=QTCUa43Qqn46xL2GJEFIy3N7UKDlwEPNFPIMLCF62SXxWkUAvnVEtC/sHcpVsqXRJF
         gTaiwkPOaM800+E4W+uo9eGPjv/lRcx9KLrnL2T/QxyXTojp5WmCbl3Ww+jFL55/kqs3
         2Xi8cYJuB1oQgCzTgD5YDG1oE1ecIKs8VIFvERZ9GjGQFfKUMNPVJBwtX+ek8PjA2sPC
         hsI6GWwQLGpkg/MD+Yy0QZ/Xjg50F84/Rnl08tagz0ExUwUT33hC43nTEoUcOh/5JLPf
         e1Qgfa5VmDcV8S6B85KZkzBCzaKoXxs54o3GQDdLSSRW+nY9lWtWA1TlzwaFut/TCNwG
         tvQQ==
X-Google-Smtp-Source: APXvYqyfVorxlZUwAAT9aEX4cV0VaLDj91iyCjHgIS5j2y9UZvsAX25pp8fFaFh2TeAiWHrhAHE4Sg==
X-Received: by 2002:a63:2b82:: with SMTP id r124mr8310326pgr.214.1551501556456;
        Fri, 01 Mar 2019 20:39:16 -0800 (PST)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id a24sm29102508pfo.160.2019.03.01.20.39.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 20:39:15 -0800 (PST)
From: Yafang Shao <laoar.shao@gmail.com>
To: vbabka@suse.cz,
	mhocko@suse.com,
	jrdr.linux@gmail.com
Cc: akpm@linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm: compaction: show gfp flag names in try_to_compact_pages tracepoint
Date: Sat,  2 Mar 2019 12:38:57 +0800
Message-Id: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000233, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

show the gfp flag names instead of the gfp_mask could make the trace
more convenient.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/compaction.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 6074eff..e66afb818 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -189,9 +189,9 @@
 		__entry->prio = prio;
 	),
 
-	TP_printk("order=%d gfp_mask=0x%x priority=%d",
+	TP_printk("order=%d gfp_mask=%s priority=%d",
 		__entry->order,
-		__entry->gfp_mask,
+		show_gfp_flags(__entry->gfp_mask),
 		__entry->prio)
 );
 
-- 
1.8.3.1

