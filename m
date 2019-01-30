Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F548C282D5
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:12:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A19D2184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:12:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A19D2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBB208E0002; Wed, 30 Jan 2019 04:12:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6A268E0001; Wed, 30 Jan 2019 04:12:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5AA98E0002; Wed, 30 Jan 2019 04:12:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1628E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:12:28 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id f18so9042073wrt.1
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:12:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=m2Amwt5xRuAF/BtRiYoVPKvt+0oNJQzkx+zBwAntzV0=;
        b=NTRFXZm2Fq30CBzaqNciHOzTf96948qt1xqnb63fQayumTmS7StliFBRQBSnX48Xol
         sHdCxGK/n0xZnhQmG53Q3P2vIi2uRSTL6cp/mBjCn+sxEC6x4XGzJlQUP7J78Kgg3B8K
         yCsnlsCfqJh9xtG5a//sJnuTYKt7SdbWxyk8/BXbTGyaPrKzKHqAFonZ8fi0Bc+Gskge
         fc0CTNR57uHqkoaLq1ScW7rpa3HZzmOtJh8YB+1KXgkGZMVI6HjDpquuiBnmFL1hyfB4
         8aiTeDyEm0HEwRQSo/39P72SLFTfKROw1bp/WIyBE0/sA062SmLNR1Jvo3Z/Uv5V0pzF
         3gDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAub4oyqPI3OBu85IANzNJNnZeiYLcK59rFyz/oS6jDEejpouTa/2
	fk0DDALNzU5t6DSx5Kpbq24hD3LPh7pTQ3+N864+7f5ZFle4mb0Wo3EdOPG4Ycb89UKYmSs9VQT
	QdSvH0CnFtK+ks8MjnjIdPegQ19z3cc+W0elnmbOHQkRGsmlURId2EozTKwu/UF417PhDImEmAJ
	r9usW7YrydDFfZnBLqSVFVTFk6k3GiJcduXsAoBI6gb/Q64IsvviBbKGxjhmUS0gpKKfuczZ6Q3
	i2tTHku9IY6S316qGx9yytu80zlGHCOo1mBXhAWoCRel8YW+46iPVhhrzLt9WQXltKoKf1+L4ln
	gNtuwVo69z0sYBPLfKckIwos7rWvonKex/kclwTIdTCUs5Ot7Xukxjof/2IjrEKPIDN+bs7nFw=
	=
X-Received: by 2002:a5d:4d87:: with SMTP id b7mr5589933wru.316.1548839547931;
        Wed, 30 Jan 2019 01:12:27 -0800 (PST)
X-Received: by 2002:a5d:4d87:: with SMTP id b7mr5589861wru.316.1548839546795;
        Wed, 30 Jan 2019 01:12:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548839546; cv=none;
        d=google.com; s=arc-20160816;
        b=OYc1DmDh0GsRkxWNN6MFIpEa00ZP8Tf/guR0pnTLUZukouSYkzs3cZSPoxrtx8C/ID
         hP6Q18MOfE1VjjttGKMohIN8HNjj8/WJHNXSLnyG+aj+LXul1iEn0Vcu9hrNWk1tcchv
         xBZCTDipRyZyOAM3/wkxujh5Ugfz8CiSw312L2J9jSedA3/08v2pFrXTmsjtTfZgSEZC
         HeTsHGvQbzxaKeegyD7v14kmTslO65dAYxNb5afYSoPV7qv79lAPgzGMW9fUyh+rEjdK
         MfdT3xbWSedyINSy/4ruTBjHskmGl944X9ewhjvCqHKcDfKHWcvCHl8vmJd97joF4Ffh
         ZmNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=m2Amwt5xRuAF/BtRiYoVPKvt+0oNJQzkx+zBwAntzV0=;
        b=SiuZg8Xli2C2/IlF2s1X9I7M4QY73NIEx9b7DtbQo8vsPG7YYEAyndNeAxwEYTYi6K
         jJWQZRJvSXLdH8KMkfSsNz7yLl1krg+9W627kCsOMUAtaunbm8qWpwcmGWY9oA+m/7Tk
         I8gNDaW4eOg213TisgMT8dS1KpafMTqg1fMnVFqhsNb8gBPerQGsNGP42lfLjhwW+ABW
         q2ItJD8T8XMbIYjcslZl5cGgDylJnbLhAuSKALhhwAzV/l1/ghzppLpTpyeV+M1DfRkm
         3apNZvZIBf7PHulSqjEWpB8ixlkre69mBt+bUUnUpF7Bvnu+RYk6NbZSD/BK2YaE+63y
         yogQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j19sor630169wre.41.2019.01.30.01.12.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 01:12:26 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN4o3NSnbRORIiG4pA/Fv1evNFjLo0o4MeeOLg8R2mbOHP9LIlrcP7bYQJHQ8zV9o1nuBHk5MQ==
X-Received: by 2002:adf:e6ce:: with SMTP id y14mr30456657wrm.239.1548839546420;
        Wed, 30 Jan 2019 01:12:26 -0800 (PST)
Received: from tiehlicka.suse.cz (ip-37-188-142-190.eurotel.cz. [37.188.142.190])
        by smtp.gmail.com with ESMTPSA id l19sm1491875wme.21.2019.01.30.01.12.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 01:12:25 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com,
	gerald.schaefer@de.ibm.com,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH v2 0/2] mm, memory_hotplug: fix uninitialized pages fallouts.
Date: Wed, 30 Jan 2019 10:12:15 +0100
Message-Id: <20190130091217.24467-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
this is the second version of the series. v1 was posted [1]. There are
no functional changes since v1. I have just fixed up the changelog of
patch 1 which had a wrong trace (c&p mistake). I have also added
tested-bys and reviewed-bys.

Mikhail has posted fixes for the two bugs quite some time ago [2]. I
have pushed back on those fixes because I believed that it is much
better to plug the problem at the initialization time rather than play
whack-a-mole all over the hotplug code and find all the places which
expect the full memory section to be initialized. We have ended up with
2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full
memory section") merged and cause a regression [3][4]. The reason is
that there might be memory layouts when two NUMA nodes share the same
memory section so the merged fix is simply incorrect.

In order to plug this hole we really have to be zone range aware in
those handlers. I have split up the original patch into two. One is
unchanged (patch 2) and I took a different approach for `removable'
crash. It would be great if Mikhail could test it still works for his
memory layout.

[1] http://lkml.kernel.org/r/20190128144506.15603-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
[3] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
[4] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz


