Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F183C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 00:26:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1AE42084C
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 00:26:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="XGRLCVo2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1AE42084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DBFA8E0004; Thu, 10 Jan 2019 19:26:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B6D48E0001; Thu, 10 Jan 2019 19:26:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37D198E0004; Thu, 10 Jan 2019 19:26:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB0F98E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 19:26:43 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id ay11so7203175plb.20
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:26:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=rybgnvg4UUXVXfPODAcLL7t8ooaSruZ0ikD0phBPoYw=;
        b=ICEkxXGN80ixnatr8OBwbgE9zz62FJSy1Qu7TCzq5AmZeEleRTLEr3jhUGYrrbEh+V
         YKCxnk2U/G2zzx1ENmLLHXYowJRXCSDMHXWZk6YIAe8SzY5T4yc1EF5pm6Au68cgfl5r
         WNrsKSzONJdrL84DaXxz3z9gc9HNAb1Wv51VzPSBNqoxRhiQC5D3pUvaPO5uRE4mAfWK
         7AxP4A/R21Z6Lr4jSEZY6s5CBHZQZXhA9oeHz1C3BroyE4fMKsvFnhgxO0CegT5DcoVu
         VDnSx8lfqJuGw3X0FuHiHSomeBD3lRN+YL+5jGYHUw38DGZTLl3ahlw5fu4o3PZe5QHd
         3rxA==
X-Gm-Message-State: AJcUukdrD4UySbC6aWZDKyPJjEa7NkTXIKjBruXu0VZBrPTm232YBP7m
	FLU+p0UfeLWfXNMTPWPGpRhwvt2iPpunGiaS4+CVdQsooZYwTA4Vyigq+KFilZEjpDm51iBU4LJ
	/diSL6V+jqerdz2IkxpUs2JDust06BuufggYeRH7ljvP2n7C4fMh90aHFTP3TxzqfpQ==
X-Received: by 2002:a17:902:b494:: with SMTP id y20mr12704315plr.178.1547166403645;
        Thu, 10 Jan 2019 16:26:43 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4GwJ132tncLwpZJvGyY1pl9zDH+RyUACFXUQFHlRIRosE+B6i+yWsOfhkyFH02FQ1SqTEg
X-Received: by 2002:a17:902:b494:: with SMTP id y20mr12704284plr.178.1547166402837;
        Thu, 10 Jan 2019 16:26:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547166402; cv=none;
        d=google.com; s=arc-20160816;
        b=MWBCAESJ1XAgOrWts6TGp6dYdHUla57rcWZiyhD2T4XrfpQsOw8qQlpb12G5rIALqr
         0urjTkeYJelLv2sDIyZ5Jy0fgXXQgHCHfsEjK4upqzZmpaV3Pqll7rv0TrGoi8tuKm6Y
         /YTu+lRh8Dnxh+vOxTjCmedtncLg9fRWhpXg0WZzgyA8Km0unyo9ZK9X6V5/QBwrs41v
         tz2GNxSrsFID7elfn8bDRdlJbGiYIV0sdKPRiJim0nd6BiBJ80KyyzOMgny0R89IXJ1E
         DdLxRPutIkIpC12NMcnwEsY/I6MtBd7cQ8qVyR58gp11HUjs+iiFimNtl1EoEcp705/E
         yzIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=rybgnvg4UUXVXfPODAcLL7t8ooaSruZ0ikD0phBPoYw=;
        b=VaUuy/Enq3yL8GQHrKUktM741WRJmfCT6T5HBSwXcRbq9Nb15m013uUrRm37fv22dQ
         ouadvjy7wD8LFtid+4d1D/8t8AwJ82i34/o7z9JBjnBlW7ZkgBAmTOJJIY90IYoO4Q0s
         4N2Vmimno7usDmm2QVwqvQ0Svb2J4Vgg7O/mA0t2dv2rinZgzxQuxUrBX0JUqB7AqBmB
         meD2eX9RWa2n0gavsy1qM7rF9M3lMRFwVGtRSfyLtPooul8F+PTQE6IrWajYMfljIFLA
         8z5XA47LNIiTnAvNVLZ/5FW4rfxg3YX6WqbEitny12HpMarmDPjBSPJIKfd9bA7OVxyG
         PbEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=XGRLCVo2;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id c3si7995688plr.178.2019.01.10.16.26.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 16:26:42 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) client-ip=198.182.47.9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=XGRLCVo2;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (mailhost3.synopsys.com [10.12.238.238])
	by smtprelay.synopsys.com (Postfix) with ESMTP id 1C92F24E0607;
	Thu, 10 Jan 2019 16:26:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1547166402; bh=DVgWT4VOpi5ItAo8wxhZ9DfXiDw+m8gVPchbHy0ojuI=;
	h=From:To:CC:Subject:Date:In-Reply-To:References:From;
	b=XGRLCVo2XP8tQkWnaZQIZmEQVgpVkqn/Duw+Pi8ivbRQpZ0r0oZFFS8mKFKtld5U/
	 j42v9RNlWg2TsIkvLteU7Hncr1BOYWa1KQdvttpfsOtWI2uVg1o4pe2BF1w19sp+OT
	 aT4MQ7BHFq6F1sY8SOz2ZMlw/cIBsURPohz92YgHzUcEnbdGGt5VLNnz96Britwkr/
	 s9ap5nwiAZY1pyftzTdIJ1kyXBpm9BcUaKt09EDMrilUQgL0GHep4l/rrnPRWm73mg
	 7vBKSTwfVbnZ/vaqOvZcx5f6V8JaNr3JrUvM5yfuq/7EVXaYJe2fTdSHV9GnNgGyIz
	 8FRViI6ZPLrJg==
Received: from US01WEHTC3.internal.synopsys.com (us01wehtc3.internal.synopsys.com [10.15.84.232])
	by mailhost.synopsys.com (Postfix) with ESMTP id 931343436;
	Thu, 10 Jan 2019 16:26:41 -0800 (PST)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 US01WEHTC3.internal.synopsys.com (10.15.84.232) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 10 Jan 2019 16:26:41 -0800
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 11 Jan 2019 05:56:42 +0530
Received: from vineetg-Latitude-E7450.internal.synopsys.com (10.10.161.70) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 11 Jan 2019 05:56:43 +0530
From: Vineet Gupta <vineet.gupta1@synopsys.com>
To: <linux-kernel@vger.kernel.org>
CC: <linux-snps-arc@lists.infradead.org>, <linux-mm@kvack.org>,
	<peterz@infradead.org>, Vineet Gupta <vineet.gupta1@synopsys.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	<linux-fsdevel@vger.kernel.org>
Subject: [PATCH 1/3] coredump: Replace opencoded set_mask_bits()
Date: Thu, 10 Jan 2019 16:26:25 -0800
Message-ID: <1547166387-19785-2-git-send-email-vgupta@synopsys.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Originating-IP: [10.10.161.70]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111002625.q2bKSy08V6w0OJS877Iyi1T5qAdJAQA8z-H33Z3D0uU@z>

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Link: http://lkml.kernel.org/g/20150807115710.GA16897@redhat.com
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

