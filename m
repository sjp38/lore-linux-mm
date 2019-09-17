Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A30C0C4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 16:43:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F07A206C2
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 16:43:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F07A206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DCD06B0005; Tue, 17 Sep 2019 12:43:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 065006B0008; Tue, 17 Sep 2019 12:43:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E96066B000A; Tue, 17 Sep 2019 12:43:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0087.hostedemail.com [216.40.44.87])
	by kanga.kvack.org (Postfix) with ESMTP id C6E4B6B0005
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 12:43:04 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4901755F8C
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 16:43:04 +0000 (UTC)
X-FDA: 75944982288.18.glass62_54f4e7f738d4d
X-HE-Tag: glass62_54f4e7f738d4d
X-Filterd-Recvd-Size: 3212
Received: from mail-wm1-f67.google.com (mail-wm1-f67.google.com [209.85.128.67])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 16:43:03 +0000 (UTC)
Received: by mail-wm1-f67.google.com with SMTP id 7so4338691wme.1
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 09:43:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:mime-version
         :content-disposition:user-agent;
        bh=yhTmZINtjNfdp4gy1K5HLazPZjxpYm/RmtHx4P4J7gY=;
        b=rDJCpk3TThNbJIwOoiWZMTxtTqkJ3+CKKDkB1vnZSFWfU0j4a1QLYp8nMemLK0V8CZ
         bR13hTK5e8xrar7Q3lwZdkmV/R2ikTtJguUvBlmoh3AZkA8OgF9fkzcLQp5GKIQtKkUa
         sC5hjW3irQc+zEf5zBl/Bi79XXoqpBiFSknCGsFR9D16nThGWVCIlpawhnQTAb6CT05Q
         fHhFKyKOSboIAC6KDVdSQB+daI5rCs0a3UKnoKitjBPZff0wuUVTI3LSJPDQmmrWoEx2
         UrOKDy2hJzt4iC1MfkrPXCtKcz1IoHmefHFiMFmHLo9C0geDBjwTgEAydJMNcZJCJoBJ
         BkeQ==
X-Gm-Message-State: APjAAAVxHuiKHWvs0maMmXEIJmV3BgQOp3cAfd5xFGZkmxovo+dj3bFd
	KTHT6zksLBKufAz0/FSs6I8=
X-Google-Smtp-Source: APXvYqxo7+Dhbm2ARLzfR1YcZoqWrp4JTcUZckLYvieruU64IlfJhLMXkN1r2iECDr4iJFLWN5CcqQ==
X-Received: by 2002:a7b:c4c9:: with SMTP id g9mr4729974wmk.150.1568738582617;
        Tue, 17 Sep 2019 09:43:02 -0700 (PDT)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c092:200::1:b644])
        by smtp.gmail.com with ESMTPSA id e30sm4936977wra.48.2019.09.17.09.43.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Sep 2019 09:43:01 -0700 (PDT)
Date: Tue, 17 Sep 2019 17:43:00 +0100
From: Dennis Zhou <dennis@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] percpu changes for v5.4-rc1
Message-ID: <20190917164300.GA77280@dennisz-mbp.dhcp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

This pull request has a couple updates to clean up the code with no
change in behavior.

Thanks,
Dennis

The following changes since commit 6fbc7275c7a9ba97877050335f290341a1fd8dbf:

  Linux 5.2-rc7 (2019-06-30 11:25:36 +0800)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dennis/percpu.git for-5.4

for you to fetch changes up to 14d3761245551bdfc516abd8214a9f76bfd51435:

  percpu: Use struct_size() helper (2019-09-04 13:40:49 -0700)

----------------------------------------------------------------
Christophe JAILLET (1):
      percpu: fix typo in pcpu_setup_first_chunk() comment

Gustavo A. R. Silva (1):
      percpu: Use struct_size() helper

Kefeng Wang (1):
      percpu: Make pcpu_setup_first_chunk() void function

 arch/ia64/mm/contig.c    |  5 +----
 arch/ia64/mm/discontig.c |  5 +----
 include/linux/percpu.h   |  2 +-
 mm/percpu.c              | 23 +++++++++--------------
 4 files changed, 12 insertions(+), 23 deletions(-)

