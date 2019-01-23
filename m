Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 134EEC41518
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:36:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C76A1218A2
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:36:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="dZuKBLN4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C76A1218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6171B8E004B; Wed, 23 Jan 2019 15:36:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5ECB58E0047; Wed, 23 Jan 2019 15:36:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DC858E004B; Wed, 23 Jan 2019 15:36:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7F48E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:36:48 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id a2so2324475pgt.11
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:36:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=Rl8db0nnJLRjwk+udm8zI1dppHxFLCqjaj+7JgpLVt8=;
        b=fz4EcmB2dLDESMjPJbpjE6CGB31XCUdib2jPCI0YgGWGJ6mN3KcaYPa1y/GHNq4nI7
         kG1+9Kl3DCyvEY/FG72xRzF8hPidgMxIIlbBTkI7bmu057NjyRJSh8mOO9vBkvjNZPHT
         9r4x4wn2y0JASR3jinLpXAPaMXix+9kJiqgqXhyBY/iS9pUbynGHCOw7Ot2cf2AthYFt
         wEFAUaIpd+JP12Q7zf8gJHnTHtVGc4XApOT5+4TiSzYbhEy3rPVyN+3i8CzCs57H5Q4Y
         aqS6wBLAreiOXCvAI5GKQ4oKojOAvXiUdNhb7fkQEWHMuCw3jnzRaM02sb2ye7gvhLSq
         rvSA==
X-Gm-Message-State: AJcUukcds5PVJhQ0r8OfrDAOqDBebnhj5jbMlT9XaOltpHZ6d/5rpqaT
	8YAAJX84pGwBq56HVjYUX/pU71xSB80fLt0CbrXrFRoFS/7qCLlxvr++sGJmnBrIsuXR8SJpXQR
	nwO3d2bLqYbiSy2NDpmRZmCAqcGgu1E7VSjALiNhHtQC3MLYgHGt6Bu57EX5YlPZlJw==
X-Received: by 2002:a62:104a:: with SMTP id y71mr3499745pfi.34.1548275807717;
        Wed, 23 Jan 2019 12:36:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4R0j5WeL31TYZr3j8l07b0ldS6ilR6TKM/EPYmz1vJyh5ny75/eAlaM96bfB9MxYBAnjgZ
X-Received: by 2002:a62:104a:: with SMTP id y71mr3499702pfi.34.1548275807007;
        Wed, 23 Jan 2019 12:36:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548275806; cv=none;
        d=google.com; s=arc-20160816;
        b=qNGzR6JFJRK6UW9VDdOand/S/OkQ7dgMFelOFsRpo5098+5Rv3f3zdv86nHrakrNal
         sA0p8snjSNq3epz5vny/1Q/sapupZZjasz3KrQyCplYAH2WXGAyJr13d7c9BryXLesJ1
         eguXksK70VEDP3q4MtRxgsET/AfbCAquh6p7pj/L1H9RwOeqiD/PMxxXm4WDUTHRwr47
         1FAzAIQC8qXISu4HbFAMKxgteoAffZMSs3sUPzPpzZlpneBc7hWOBdYpnIAyxtbCh6Ne
         A0rRl9azB+BQKjmRvyB/UWecFIuAr2oc7zK1lj8EJn1XU8WUGll+cve+/NtxIJSl2wV/
         nENw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=Rl8db0nnJLRjwk+udm8zI1dppHxFLCqjaj+7JgpLVt8=;
        b=bP+qDdugnkaC6lCs/20WalKaKqVxJjwH7WFj9HidZNhgCMRz6OAjwMUqedMS5lCSjI
         cB85kMwLk16S749cIFGDJZcp6efm+kl6qZvoPy31TGxnm7OxunkY+0ksWolYm4m+6dju
         A2NOa+JtfC7CFgxlXhWoIFttKlVNJu+xE7/ArIYZlE9RHXm+cLY/MLtUnD9STozYUQDN
         5EFRToJTTjYEJyPzlKqDxHQY6gEMxVv9OopE/raD100e7DDltlv3iM0tr+EUa2YZjv2i
         sjQzt1yCSRvzEfOxUkyY7XMygHSss1O49twblUVjoQEnAIUG7+N590YqfPEvY4wpxW++
         jc+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=dZuKBLN4;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id n3si20736696pld.36.2019.01.23.12.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:36:46 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) client-ip=198.182.47.9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=dZuKBLN4;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (dc2-mailhost2.synopsys.com [10.12.135.162])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtprelay.synopsys.com (Postfix) with ESMTPS id 4E1E324E09A5;
	Wed, 23 Jan 2019 12:36:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1548275806; bh=kJQpOk9ZK86cD+f4lSJLjtMX3cfMvrQBXd+6efrgIP4=;
	h=From:To:CC:Subject:Date:In-Reply-To:References:From;
	b=dZuKBLN4fosMTZqfsal0ZyRo/wn5iUM2k2qZFxow0NmEKflFzF5TFyfm2LdqocROm
	 bDMSfhbtHpZFSJCWhxE2dRYwiF6rKyN9FMzlCcQ1LGeMHIHi5NBINqc8G3EOvnxKRi
	 6JS+sR1bo9lYJySXOLo02kzhlEifaj/depZm9QfYIF71DF1DYwws5fFV0V9n5wRxki
	 vLPwh5q0FlcQiLAe1ZWQkokaNmnYAapoesdycqhKWu877Z6m9TejcXYHB/kY7bnwBV
	 iC1o7/eWs7mEKO0RIFUpdXiMbPB2cYWlcnpegJRjYuqMe6XyYvqpr9E8TNHpwZnbGv
	 oTMiXHfhObT3A==
Received: from US01WXQAHTC1.internal.synopsys.com (us01wxqahtc1.internal.synopsys.com [10.12.238.230])
	(using TLSv1.2 with cipher AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	by mailhost.synopsys.com (Postfix) with ESMTPS id EBC3AA0091;
	Wed, 23 Jan 2019 20:36:45 +0000 (UTC)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 US01WXQAHTC1.internal.synopsys.com (10.12.238.230) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Wed, 23 Jan 2019 12:33:20 -0800
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 24 Jan 2019 02:03:21 +0530
Received: from vineetg-Latitude-E7450.internal.synopsys.com (10.10.161.70) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 24 Jan 2019 02:03:19 +0530
From: Vineet Gupta <vineet.gupta1@synopsys.com>
To: <linux-kernel@vger.kernel.org>
CC: <linux-snps-arc@lists.infradead.org>, <linux-mm@kvack.org>,
	<peterz@infradead.org>, <mark.rutland@arm.com>,
	Vineet Gupta <vineet.gupta1@synopsys.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	<linux-fsdevel@vger.kernel.org>
Subject: [PATCH v2 1/3] coredump: Replace opencoded set_mask_bits()
Date: Wed, 23 Jan 2019 12:33:02 -0800
Message-ID: <1548275584-18096-2-git-send-email-vgupta@synopsys.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1548275584-18096-1-git-send-email-vgupta@synopsys.com>
References: <1548275584-18096-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Originating-IP: [10.10.161.70]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123203302.nl-9fxLxzUbas6NYG9DBeb-rTu3WqX5n_KsRWvUNO6Q@z>

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Link: http://lkml.kernel.org/g/20150807115710.GA16897@redhat.com
Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>
Acked-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 fs/exec.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index fb72d36f7823..df7f05362283 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1944,15 +1944,10 @@ EXPORT_SYMBOL(set_binfmt);
  */
 void set_dumpable(struct mm_struct *mm, int value)
 {
-	unsigned long old, new;
-
 	if (WARN_ON((unsigned)value > SUID_DUMP_ROOT))
 		return;
 
-	do {
-		old = READ_ONCE(mm->flags);
-		new = (old & ~MMF_DUMPABLE_MASK) | value;
-	} while (cmpxchg(&mm->flags, old, new) != old);
+	set_mask_bits(&mm->flags, MMF_DUMPABLE_MASK, value);
 }
 
 SYSCALL_DEFINE3(execve,
-- 
2.7.4

