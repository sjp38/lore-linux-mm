Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D112C46460
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:52:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 200FA20989
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:52:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 200FA20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4D0C6B0003; Mon, 13 May 2019 14:52:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FDC46B0006; Mon, 13 May 2019 14:52:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C4646B0007; Mon, 13 May 2019 14:52:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67B7C6B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 14:52:46 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id c48so14193484qta.19
        for <linux-mm@kvack.org>; Mon, 13 May 2019 11:52:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=b4TlRietwnM6oTPXcxhj2JOE8FV7T3pSL6QJavmQ1dg=;
        b=uK/8ZBXSaLCVm3TIAHBzLJZYl0eUjfIqsBhhtQNS3EC+QM99UAvv8Qh7xAHO8QJ2xz
         tm12lOvo4fcumE3HygOZE0UeL2S8w7rzyRavOuQvwGAquHe15/k8u2XWZmvTeK6qGhwq
         JKXLofPv/qhtRVE9hgBbiR6gODO1Ud8Otmdgk5ZlR/HpoGR/comTRfndugspRqglYH0D
         7eqyPAYCBK9wDqZkVu/KTlgUmv+kDI2ZiQvrGgrsxfndlDbbtdxMjo9IMi5tGjv5ZBvl
         UpkObk9oSraaqYYHbt0a9sSVlUMcxBByorrl9WgG4v0hCzauRfQNYVSoNHF12sNeUkhk
         89UQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX7+7oh7DFkr3yt9DVQMO/dMzFNdC72CjYc4o/47DN6Hq3El2WX
	TsKDpw52F5mHjBUFKNilX0oY9bbDVhmEpRjeJRkAdEJGUzhkI0/2bLKHF0o9SjbNPYvMKvyVw7e
	TF73vtWGGhZuE10wr4qDU4v3I6yC/0XoHODJ9nNcPo6FCKuh9Llgk3k+PvV+nTmo=
X-Received: by 2002:a0c:906e:: with SMTP id o101mr23640460qvo.97.1557773566151;
        Mon, 13 May 2019 11:52:46 -0700 (PDT)
X-Received: by 2002:a0c:906e:: with SMTP id o101mr23640414qvo.97.1557773565448;
        Mon, 13 May 2019 11:52:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557773565; cv=none;
        d=google.com; s=arc-20160816;
        b=sHbLc6jA5SOwFDLMn71CpqIHxZBg+qICbqTKJkla7OKl26vWt8G4Wvyzs33hD5YisX
         crizlrrLKbgcJFuAhQHjLOb1XV45nD5M44p4g7IxeksqfV6YZIRtVT3pcEkO7g4VvdYI
         4PG7DNou333FpQV4xARPPwmTJuAijaeVo0bv50RzY8ExI0/fBE+31PvhzLVeX1Wh+DIK
         JPaiZjOZZU2gRAmtnzd7Wh9stsaZmyvZmkG/wqqr4N64Ny10nLooA9T26m1KyNT5TxGX
         iwYTV2SSd+9e91fpdhBPU8FZnTj3+VBwqHf6N37LUoXZ9bNO9hmr8yYmdyAyToC65NOG
         GigA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=b4TlRietwnM6oTPXcxhj2JOE8FV7T3pSL6QJavmQ1dg=;
        b=aOS9/WNNqI8Zk9fFaaEFtYdoVDMkiL5drS8faHkp0pJYDONnYtZmUEnzsYlKAniof9
         3X4Lk3LbQLC823uxFEJaOHi0nfm9K5Y2isJGYx5CtLSY57U/nrRW8Jx+lNTs8ooCBfaQ
         /g/gkuPPDw7mTiTc3uSWvAFudFUxRY+r8T0Tz7Q6Iqgpwd6ZOU79PKuOufjKgGB+kSO8
         1btCoHCoCOreWuAhYi8P8a4/6Vzc6uMPh8AiFO7fK4ZTku75miH+eJ18cCr/qlwE1DVa
         GvU7peUDeN6RLHgXLOfYVMnqb4aWDncT0bnqIIQLlBz3PLYUsHSNjQXUhDUVHFqn0p/I
         7qJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k39sor11240151qvf.59.2019.05.13.11.52.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 11:52:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxSKsVgAu+I6jDct+Jb+foaVr1VkQpIWA0uKzdaIX/lqaAusSviehhQATr1kLcIrmTwBR5YQQ==
X-Received: by 2002:a0c:b161:: with SMTP id r30mr2632858qvc.15.1557773565039;
        Mon, 13 May 2019 11:52:45 -0700 (PDT)
Received: from dennisz-mbp ([2620:10d:c091:500::3:b635])
        by smtp.gmail.com with ESMTPSA id y8sm2445558qki.26.2019.05.13.11.52.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 11:52:43 -0700 (PDT)
Date: Mon, 13 May 2019 14:52:41 -0400
From: Dennis Zhou <dennis@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] percpu changes for v5.2-rc1
Message-ID: <20190513185241.GA74787@dennisz-mbp>
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

This pull request includes my scan hint update which helps address
performance issues with heavily fragmented blocks.

The other change is a lockdep fix when freeing an allocation causes
balance work to be scheduled.

Thanks,
Dennis

The following changes since commit fa3d493f7a573b4e4e2538486e912093a0161c1b:

  Merge tag 'selinux-pr-20190312' of git://git.kernel.org/pub/scm/linux/kernel/git/pcmoore/selinux (2019-03-13 11:10:42 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dennis/percpu.git for-5.2

for you to fetch changes up to 198790d9a3aeaef5792d33a560020861126edc22:

  percpu: remove spurious lock dependency between percpu and sched (2019-05-08 12:08:48 -0700)

----------------------------------------------------------------
Dennis Zhou (12):
      percpu: update free path with correct new free region
      percpu: do not search past bitmap when allocating an area
      percpu: introduce helper to determine if two regions overlap
      percpu: manage chunks based on contig_bits instead of free_bytes
      percpu: relegate chunks unusable when failing small allocations
      percpu: set PCPU_BITMAP_BLOCK_SIZE to PAGE_SIZE
      percpu: add block level scan_hint
      percpu: remember largest area skipped during allocation
      percpu: use block scan_hint to only scan forward
      percpu: make pcpu_block_md generic
      percpu: convert chunk hints to be based on pcpu_block_md
      percpu: use chunk scan_hint to skip some scanning

John Sperbeck (1):
      percpu: remove spurious lock dependency between percpu and sched

 include/linux/percpu.h |  12 +-
 mm/percpu-internal.h   |  15 +-
 mm/percpu-km.c         |   2 +-
 mm/percpu-stats.c      |   5 +-
 mm/percpu.c            | 549 ++++++++++++++++++++++++++++++++++---------------
 5 files changed, 405 insertions(+), 178 deletions(-)

