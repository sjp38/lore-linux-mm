Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E94B6C282D8
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:45:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3DA520882
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:45:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3DA520882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E30168E0002; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB6C38E0006; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A462F8E0005; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3285B8E0002
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id l45so9375433edb.1
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:45:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=D7DQqgItge2UeEQTW8Q1iI5PgclPoSq1iksp929EWUA=;
        b=MxppwE+hWp9PIWeCuKYP451J5Hu73GO41Jf824yElV+wr3a1V/W74/Tzsox0HO/Zgl
         6voDwsxl68+9flQ7LEL9EE0jEVd/wP16Who0S4F70hxMQapbsbbSqGJfN+qwOwRqpTTh
         NdzZwdOSF+9qC/kQJnFztI2T5NfpjAxkh+oxEtQOEK7wbQWt3uhZaJHMSP13XkSMO1yJ
         TO5x0YVp1Z5d6Qgvt9uIKqrspypt9ipCTX8wlCLHnY7+92w+m1nEr4oLh7OlK37HGn1W
         f5fdLFWDK4MLLcpcotH/jWgnXx0e0XrWCVLpJSdz93vuTBrE2Mv0V5uG9Pup9p1K6ho/
         uAdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukfxq+g9rHwRXOZxhIYCjTKJwDphOdjMftGCpUJ479olk7NLuP2L
	h79pJOu721r0f8nGcUzG803Aqc0l6L1D2tGvQujDmWMRtdtc1cP8OuX7fGgHD15KtpEzDcGOalG
	xcXJgJA0VStrlssFF9zkYrx5BBkpSYv3eJUPh2trfhJ7kOKDtTyYoztqBltHO1E04fw==
X-Received: by 2002:a17:906:345a:: with SMTP id d26mr15535640ejb.133.1548852315550;
        Wed, 30 Jan 2019 04:45:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6nliY6EuFexi13/mXBARH2vJs/nhE+v5ptiTcVPYocK02G3c9r7sJV3Xr8ZGHQZosIdtl8
X-Received: by 2002:a17:906:345a:: with SMTP id d26mr15535568ejb.133.1548852314173;
        Wed, 30 Jan 2019 04:45:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548852314; cv=none;
        d=google.com; s=arc-20160816;
        b=jV2CggjE87JpM2FxO1/1ZhJO2wONvQAxQUqPwhWF4qApC4+G8uDUoTBGUcOGvBaPvN
         /Uozf4lzzy14jgXGa0Fdhr5Ud0lktYSDoowUS/S3zILK1p9yPeHw2rQdk4udsJ8f7Vin
         v5/amwdHnx336XbC9ru5Ku+7SaqerydfJ11XKsICJbYn46UasF+F853HqecFPpmOH/8l
         FgRW2PJw8QNea7sZ1kGqqALGDGAg/v+hYaBlHXfORuYa+wq/94FZOVgv66Y6b1zp+RFf
         RaDvOvtGNqb6DVFy6++XZcd4PxrC/iEf5jHsNaWu8StwbgEtP9PLcujmg+jOxeI5hdPx
         04bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=D7DQqgItge2UeEQTW8Q1iI5PgclPoSq1iksp929EWUA=;
        b=kGBsIDUjzPZWaBPR7ZGW1JeFnxNOQcpmShfE9ygqwqrGL/nPlkaYg9+qjdINQGv/Td
         uTpUJ0xyzofODMoUgR1W4iGhOtEQZwPHXWBRzHMbVm+Wqx2TGAkfBXACR1Z6U9KahVgP
         Egsa6Km3MEg0swQcHMrvAp2CejfAOkXk2ND/BL41Jr1swAd4EZujAD5IPzo+ZIulNJyp
         W4u6HvpLqnT92cEa7zZasEB7adGlLoUBt0JblXvDYycuDlFRaNsB0CpYXvUJCXScvmWZ
         zdpBb287+3+8cHLTYzPvzBsOtGNj3OXJfGR8twDigoyqasVILMV+gFDRvenCD+HLP0Nk
         +7wA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b18si1022742edc.268.2019.01.30.04.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 04:45:14 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 412F8AE4B;
	Wed, 30 Jan 2019 12:45:13 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	Jann Horn <jannh@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Andy Lutomirski <luto@amacapital.net>,
	Cyril Hrubis <chrubis@suse.cz>,
	Daniel Gruss <daniel@gruss.cc>,
	Dave Chinner <david@fromorbit.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Jiri Kosina <jikos@kernel.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Kevin Easton <kevin@guarana.org>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Matthew Wilcox <willy@infradead.org>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH 0/3] mincore() and IOCB_NOWAIT adjustments
Date: Wed, 30 Jan 2019 13:44:17 +0100
Message-Id: <20190130124420.1834-1-vbabka@suse.cz>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I've collected the patches from the discussion for formal posting. The first
two should be settled already, third one is the possible improvement I've
mentioned earlier, where only in restricted case we resort to existence of page
table mapping (the original and later reverted approach from Linus) instead of
faking the result completely. Review and testing welcome.

The consensus seems to be going through -mm tree for 5.1, unless Linus wants
them alredy for 5.0.

Jiri Kosina (2):
  mm/mincore: make mincore() more conservative
  mm/filemap: initiate readahead even if IOCB_NOWAIT is set for the I/O

Vlastimil Babka (1):
  mm/mincore: provide mapped status when cached status is not allowed

 mm/filemap.c |  2 --
 mm/mincore.c | 54 ++++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 42 insertions(+), 14 deletions(-)

-- 
2.20.1

