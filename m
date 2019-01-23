Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5242EC282C0
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:35:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0726B2184C
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:35:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="UwABq9HC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0726B2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAC368E0049; Wed, 23 Jan 2019 15:35:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5B7C8E0047; Wed, 23 Jan 2019 15:35:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9238D8E0049; Wed, 23 Jan 2019 15:35:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 505458E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:35:38 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q63so2605650pfi.19
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:35:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=KxWdOwMPjg+flSL9vY1TXEx2fKTnpU0iIdNL5rQ8Iuw=;
        b=OmQEFIB2mK+zAb9fB15QSQ+FVvhnCWKPzgaS10yW9li0UbQCn0qIj5gtj5U0BorqiQ
         dOkPkG5ssVS0VCF4Dx6tcfsPnh4bJtFVh7neQDdS5elq2NFtIjplh+RNXo8xnz7sR8VG
         X+uWl2AEgTl8r0wzWeAm1ICseDM2/To93wjP3rDNPNNcTvkVSbAIncZW8rokqpRELhbB
         Owbw44MI2h5fbQ/b5VBZJFHaMDRD2/6ph2qt0YhPuLLfmOMjgHGf58oAb69QXELtCsxF
         2/ad/yWl84Xg5KAsrx2dfbWMW1M6KkFaOqghZaDOJv7fUdDB0MoxesMbomtKQxFO/AVl
         XuCQ==
X-Gm-Message-State: AJcUukczDFHNavnGa1/VDiXtpffzkz6oKgqehNoYhH+sLw/Dx6iBlEE5
	2AaJSPeAbiw0uIJ0iHETuiSCeiA4aohaJ9ZGjhusiFnKUVUUHPiEqCWyUL5Tb+RmPmiaLJDVPOM
	JuOG3aZXLjYPy90z7H9jrjoJ4KePZHhBWN/6iZrk/9Sbd3eHc50lazHFb/bE5VMuYaA==
X-Received: by 2002:a62:345:: with SMTP id 66mr3493976pfd.189.1548275738000;
        Wed, 23 Jan 2019 12:35:38 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6HhXAGuyVNaBrgfpStCeo07mE3FU/3BL8FgF0/Kh2JCQmrRfF6NdjDg21nb3Qbg04ekRF0
X-Received: by 2002:a62:345:: with SMTP id 66mr3493930pfd.189.1548275737410;
        Wed, 23 Jan 2019 12:35:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548275737; cv=none;
        d=google.com; s=arc-20160816;
        b=uYTbl6uGoO+9IE566SKKFK27ZVry1DvfuQRkiJjFspjtjuUOI3iB0Ts49r/0UH1fkN
         TEu6IUW4e6QkxIPOK/UH+Qb6y69F4NV58/AkfoZSJeNR4o+wLTAM5HeVHjNtz3vMC4vg
         5NNnhEnamYn7mjUaxXJozyWT8jnAG0IRDGcvoWIAeccob3YinhCT+P9oPpukAy/5Wt8j
         sJKbzU4+zI4C2qQHaKN6kMxrVVa4dHRsGsquhzc/nuNaRp49Mw7yQmrNLuebk0Cr8epv
         JCElF1+D2ePh1NTDSVyxrm7KHtSgEuLyQE5/9FqVUpffTrfCMed8wZG0s5tgNZz7Lj/n
         QFRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=KxWdOwMPjg+flSL9vY1TXEx2fKTnpU0iIdNL5rQ8Iuw=;
        b=yUE+oVEPAh1T3iVFpgpnXoxFrIwXcVyhRcJs19Y24e+yiRf6MbGVjjJ+/qJ7DME3lb
         OIj2WsWcuqYz9XlRqJk/4fxfR60fudYQCIjCqgoiOznw1Zmpd+fobZiPrJXS0TVLHoom
         3Tso8YZpzLNQCdcbLxYN//MJdjAKk/NknmYir6dZdpCWnNEX/tToFlEiPFMqaviUQMef
         dXu/OklB0kzPZ7POpoa9KUz//RcpaLYOTGNjYdr0M2XvAUBFfl1thIasfOgI9YNBIUHD
         wVZzaVIha6hLrIWnTsisQ0ohJKct0Wq+GjjbAnAIxLciI+C1Pwo0uClpvlmxd5kRP+Py
         1efA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=UwABq9HC;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id i64si20445115pge.361.2019.01.23.12.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:35:37 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) client-ip=198.182.60.111;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=UwABq9HC;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (dc2-mailhost1.synopsys.com [10.12.135.161])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtprelay.synopsys.com (Postfix) with ESMTPS id 69EEB10C0EB9;
	Wed, 23 Jan 2019 12:35:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1548275736; bh=5aqJIt6TmksnMnFVKjXMkW1BGCYVhXZ+GYxGZlH9Bhk=;
	h=From:To:CC:Subject:Date:In-Reply-To:References:From;
	b=UwABq9HCGrxzd0x+PMqCWh3JwQ7ooGkdnfoILCzSLZeKmLLWOybXyjeu61ecChbV4
	 yOVNQ2j3JajcEzlUejxh3MnFRNGqN6epSxutpCQ8bthEigufj6W+dhjv7o/twWGNL6
	 KHMwVKZk8a4m464p/oP5gR+/yLSTDc9uRgmrnmmdWvD9dg4nONK/v5Q0XtBoxP3c3V
	 rY0ME/sobPY7eNFJkSZsoV1e8FADT0RbBpk6K5VtwA3Ii6FwFhuUg/2cHfuqn7TS3U
	 UgbNeHlRzmC5dM436fX0f8VCZtk4DB+8zzOjcI5k1u4D1Y0KcVYiHm4CX1LMLr9Ga2
	 bw3jOmjcALOkQ==
Received: from us01wehtc1.internal.synopsys.com (us01wehtc1-vip.internal.synopsys.com [10.12.239.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
	(No client certificate requested)
	by mailhost.synopsys.com (Postfix) with ESMTPS id 22C98A0070;
	Wed, 23 Jan 2019 20:35:34 +0000 (UTC)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 us01wehtc1.internal.synopsys.com (10.12.239.235) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Wed, 23 Jan 2019 12:33:23 -0800
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 24 Jan 2019 02:03:24 +0530
Received: from vineetg-Latitude-E7450.internal.synopsys.com (10.10.161.70) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 24 Jan 2019 02:03:22 +0530
From: Vineet Gupta <vineet.gupta1@synopsys.com>
To: <linux-kernel@vger.kernel.org>
CC: <linux-snps-arc@lists.infradead.org>, <linux-mm@kvack.org>,
	<peterz@infradead.org>, <mark.rutland@arm.com>,
	Vineet Gupta <vineet.gupta1@synopsys.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	"Theodore  Ts'o" <tytso@mit.edu>, <linux-fsdevel@vger.kernel.org>
Subject: [PATCH v2 2/3] fs: inode_set_flags() replace opencoded set_mask_bits()
Date: Wed, 23 Jan 2019 12:33:03 -0800
Message-ID: <1548275584-18096-3-git-send-email-vgupta@synopsys.com>
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
Message-ID: <20190123203303.u_jEAJx13a50SnL-TSHRKeji0mgiz6HFVsTd417Qx5U@z>

It seems that 5f16f3225b0624 and 00a1a053ebe5, both with same commitlog
("ext4: atomically set inode->i_flags in ext4_set_inode_flags()")
introduced the set_mask_bits API, but somehow missed not using it in
ext4 in the end

Also, set_mask_bits is used in fs quite a bit and we can possibly come up
with a generic llsc based implementation (w/o the cmpxchg loop)

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 fs/inode.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 0cd47fe0dbe5..799b0c4beda8 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2096,14 +2096,8 @@ EXPORT_SYMBOL(inode_dio_wait);
 void inode_set_flags(struct inode *inode, unsigned int flags,
 		     unsigned int mask)
 {
-	unsigned int old_flags, new_flags;
-
 	WARN_ON_ONCE(flags & ~mask);
-	do {
-		old_flags = READ_ONCE(inode->i_flags);
-		new_flags = (old_flags & ~mask) | flags;
-	} while (unlikely(cmpxchg(&inode->i_flags, old_flags,
-				  new_flags) != old_flags));
+	set_mask_bits(&inode->i_flags, mask, flags);
 }
 EXPORT_SYMBOL(inode_set_flags);
 
-- 
2.7.4

