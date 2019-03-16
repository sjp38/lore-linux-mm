Return-Path: <SRS0=HgWV=RT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F25AC43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 21:25:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A802421904
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 21:25:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="aTydi4j0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A802421904
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A8246B02E3; Sat, 16 Mar 2019 17:25:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 256466B02E4; Sat, 16 Mar 2019 17:25:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 146C96B02E5; Sat, 16 Mar 2019 17:25:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D55A06B02E3
	for <linux-mm@kvack.org>; Sat, 16 Mar 2019 17:25:19 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e5so14476901pfi.23
        for <linux-mm@kvack.org>; Sat, 16 Mar 2019 14:25:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:dkim-signature:from:in-reply-to
         :references:message-id:date:to:cc;
        bh=/97fXcQWk4RkB+VBut4/SRqUfRQJPrBbBU840QsdegA=;
        b=BZ1ThNDoyiluZAgpZFQBd8I5jKHQWnvbVS3v/+lEWk4nHxbEnSiAEtPx80Qc6G+af9
         lJ8s3FZ7b3uNEWDzfGZ/iKYLAdohhMg79bKxWJ4nmOIhUH565xm+eLIKbYDAAgKdHVsd
         JSb5pnEuAs5q4R6qARmmpqMG5yBhY6BLhlRNxyTRidepy2vFMNcuHIIT8Y+tvbVSsnAm
         T7LQ6KWJvdUnaD0J7m+fmlTraH4bAqPGI7GLJRTQVHjZKDKJEa3LmHuGUHqr2fcyT8On
         p/muwHFkPfrymT+jinl6lrQWgeSrf1MT6OY9YBme0t5L4unPFCkNghVw9Ky4YX6YQPAy
         /RxQ==
X-Gm-Message-State: APjAAAVN1G+tUOE+oiVdhHCvyAdtm8Nl1FvNdaIqvBQ3SmK7avzY/aGB
	2KGo7aPDv81dA7dL3hl7/rdlT183ABY4mR07LoZIrn1su2/dLrO753K+vRfvSnuaM0Y+U+KiO0F
	9obfYcHSkhM4lH3rs1NzlKjamML/s3L/Z7xjbAj9WpHnhjduNq+4YWWj7lFrqG7DGYA==
X-Received: by 2002:aa7:9102:: with SMTP id 2mr10994628pfh.179.1552771519395;
        Sat, 16 Mar 2019 14:25:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5oZFYoD4vUzVG38eQT0DJWnW7LY0ZI8i8Paf0F1sADDMWpNkKILQJba2pu6WFTeb07xbU
X-Received: by 2002:aa7:9102:: with SMTP id 2mr10994567pfh.179.1552771518353;
        Sat, 16 Mar 2019 14:25:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552771518; cv=none;
        d=google.com; s=arc-20160816;
        b=N6AdoGjl1Rk3X10/o+8rLGg5TwLAm/cIfTft9+N/ts8xz86IKBxdLxZXuABjW4wD5M
         38qshIUg6GOL0sIHyUkw+xtLcBaCvn6AcXRH3d1GsVlYST2y2TLA77xUJRXmv4t2wUIR
         74jhS9FKSHF0F1Nvvvtmg5pfunhT4gd59bumLOWnjchBbZeqxVu0f8l69xa3VG4LIhsj
         KgfYHDdnDfe0LWboBjZx2w9yJUYH/go/3QgGo2U9tmMQIQuHxx4CBATpIM37ixZFJcfe
         38sOXBX35FEnKxzEU3Yp01fdsTzIFE5I/tpo+kpQEZKqscgz0sOeV43iYb4+Bk7BTMKL
         ivug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:date:message-id:references:in-reply-to:from:dkim-signature
         :subject;
        bh=/97fXcQWk4RkB+VBut4/SRqUfRQJPrBbBU840QsdegA=;
        b=paK/kFi4nEvpmsPnAGChlmSb2XWPTm7krBF7SSuoiG7uekAgOlfIvdBoSEMD+2sOus
         GCvoFgfSD3h7WWFi0DTSh9efeOls9V4ag8KBajMcPuiKZcaq3Wsl9TZPLo/WIJzuUECY
         5PSCkKC4alsZi+HBsJISOqFAOS6DMeHdWC6gEX6neU/4YnrLzpZqmLaBun4e//I7El4E
         hL5Mea1lMVP6BxieO/AfQD5LXfD1N0xqYdy722HoljbsYGlJQBTMz3nrYDPogkN9x5lO
         cDpgeCXPwhUHdAI/TelEiafA8ku3BIHaw4RGVzuroa7x2OMWZclYwRMHSKbFeTYYRm+m
         44tA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aTydi4j0;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n2si5113063plp.341.2019.03.16.14.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Mar 2019 14:25:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aTydi4j0;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Subject: Re: [GIT PULL] device-dax for 5.1: PMEM as RAM
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552771517;
	bh=D7XQSY07+HWJMWfEdqVUp20+WyAo6t+KLLs2rVGIYk0=;
	h=From:In-Reply-To:References:Date:To:Cc:From;
	b=aTydi4j0+Z/ATpgjtSfoJY02ObwM1COmZ8C9OkdaaV/fcAV49YIwCMjCgUlYBDrFd
	 oNiceszYn2hfDb+AOgBwf47doXgXjoy9o9yWJPqekdxakUFhQ69/AQN5CVpmYzSpiF
	 6EwFNgy1KQuvloMtOieT8OcECxvbvG3qCoybhWVA=
From: pr-tracker-bot@kernel.org
In-Reply-To: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
References: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm
 tags/devdax-for-5.1
X-PR-Tracked-Commit-Id: c221c0b0308fd01d9fb33a16f64d2fd95f8830a4
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: f67e3fb4891287b8248ebb3320f794b9f5e782d4
Message-Id: <155277151790.28247.13079414442798739990.pr-tracker-bot@kernel.org>
Date: Sat, 16 Mar 2019 21:25:17 +0000
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
 linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>,
 Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pull request you sent on Sun, 10 Mar 2019 12:54:01 -0700:

> git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm tags/devdax-for-5.1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/f67e3fb4891287b8248ebb3320f794b9f5e782d4

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker

