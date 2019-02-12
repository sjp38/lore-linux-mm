Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 005A7C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 09:53:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 982EE2070C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 09:53:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 982EE2070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 145178E0018; Tue, 12 Feb 2019 04:53:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F5628E0017; Tue, 12 Feb 2019 04:53:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F27318E0018; Tue, 12 Feb 2019 04:53:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEF988E0017
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:53:55 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d9so846100edh.4
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 01:53:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=EFijitDAnYbGumAIWyNs+KdKOOdzXlmahj3GLOHXWfY=;
        b=Ppku2TqhoVzwxT8IezLcPY0mSDszn0BeZ5dfsIVJZXG8K6OgytL4w4T3/GnikjdD26
         YIjem5v7is5ZzDMlrdSeX2ALw0xkeaEADir4Do5oHNga10Wmy4VD+cBFT0NMtxMc4ujd
         +3vbsdbSewmkgd+W+eFXqtPdRP4i+CpIPS60M3aIbZzA6BA6wRT2wMReWSZlof9WAlM+
         +S3jZHDatCY4iFbgNNQbfohD9KBNa/2JVw9uffOuyQeKFyJ3H98vGdVaEjHkSyUE7b4T
         J3d7nRmGhCBJV5JJ2cZ6019t4r0L1xsgkLy8n41ukxA4JojCP6n9O4r2HUIoRldvwk5U
         Ss/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZF6gHi71d9NCxnasSkq1DTUmrqQX0tDjbUhvW0QMS/6+UZ+epp
	15S0Pcs9icGzP/ZVQqXBTsa/xGrM+4Shrm+9/WzJnvmrOuaNluSoeRN56Tr25njTnXPnRS0P2a1
	R0r8SoLj0HQwZ9aeDUCbX4S/2vzgoPeD/tpBpTEv1KpZk9AKVG1IkIMOMxAisUW5XQvz4H9Cu8J
	mN5vtPKaR+3f8XjsrWdvXKf96On516vhYwh8OJ4gRUCfPF37YlJ4IHPcWAZjzdJga9hlcjteCAw
	cgORQTL6d3ZB5Zb6fWBVxTXgoa8L4omwtIa6WytwjYnUER3a6jJpCgc/jpa8PVyW1nVNC6KG8Mb
	TghElEkDRhaDlNon9bPa9zUEF7SPDbGjZbwCUev9Yc7ehwN3AlhKk5hC5jr9DD1J06tJLJCzKg=
	=
X-Received: by 2002:a50:b3b8:: with SMTP id s53mr2405154edd.122.1549965235221;
        Tue, 12 Feb 2019 01:53:55 -0800 (PST)
X-Received: by 2002:a50:b3b8:: with SMTP id s53mr2405096edd.122.1549965234249;
        Tue, 12 Feb 2019 01:53:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549965234; cv=none;
        d=google.com; s=arc-20160816;
        b=kesU8FD8MUBJFGaGF705K7gtEtery7xBYR+mjNRB/TVKvgANJqAbKulimE7cx1xLCQ
         ucoQ6tbuVBDI+ZlmvesFRSmSYHJHldmQjx7OSh0Az9ksh4DtungU8asJ5CAJxSkMTAlw
         piuN+1OmCCDWes005elmHnX+Ql2hwXZ/V9W7krRNnoQKA+EvXHflRquUVRaUEN+PvVww
         guGnjdGPBYiSlfucCSDYgHuM2q6230JHojmP7b7nGLLiW0uJBlK8Wb6T6flk+WNRRc50
         zLd4KS6qEnHjJo5jYpzqx1gvHH03Qu3U+8H2kqdcV0pLWTDLXNiVqXrbzzy57Hoqgezg
         PuSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=EFijitDAnYbGumAIWyNs+KdKOOdzXlmahj3GLOHXWfY=;
        b=JdAhLSC0s6WuAfeMMdL9XcsE1LxdlYgOFCnSIyeqEJO40nx87hVv7Xgx9rXEH9Ym4Z
         Ys5rdbT6afoTJx9R97a2FK9Xw3lB5W/+LsQq2I65L4tHvM2LV4VM1j/X+K6peD8CSx3s
         dflr+Zm24d2hwuNODy85lbGN3J1iNLd/EH09xjGKgwmw4uIv5Mzo6hNpJDCsovP3OsP3
         E26VXFTm6KWd1jBxoC19HmujAHox2VxJX5ELQut6CBv9KOYXW2inuUNo/CP5wVfZHQIM
         5RUwMkFfEzsbm0TxFXCHlIWSSJIR9cTKkA6tF2Q//VUCReCUIIwb3gUB+mH39bQ/KvL+
         Z+0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u7sor3657351ejz.29.2019.02.12.01.53.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 01:53:54 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IZuQQu7DIy+YQkt/vIiKLToazp6FM++4dnhmcZqF3E9VfSmrDOChUquc2Ds0W5XPmXFSJDecA==
X-Received: by 2002:a17:906:32c7:: with SMTP id k7mr2066905ejk.180.1549965233523;
        Tue, 12 Feb 2019 01:53:53 -0800 (PST)
Received: from tiehlicka.microfocus.com (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id i14sm2876791ejy.25.2019.02.12.01.53.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 01:53:52 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: <linux-mm@kvack.org>
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>,
	linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
Subject: [PATCH 0/2] x86, numa: always initialize all possible nodes
Date: Tue, 12 Feb 2019 10:53:41 +0100
Message-Id: <20190212095343.23315-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
this has been posted as an RFC previously [1]. There didn't seem to be
any objections so I am reposting this for inclusion. I have added a
debugging patch which prints the zonelist setup for each numa node
for an easier debugging of a broken zonelist setup.

[1] http://lkml.kernel.org/r/20190114082416.30939-1-mhocko@kernel.org


