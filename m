Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26C44C3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D06D223430
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="CPN//g20"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D06D223430
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52D1D6B0006; Fri, 30 Aug 2019 19:04:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DD5F6B0008; Fri, 30 Aug 2019 19:04:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F2466B000A; Fri, 30 Aug 2019 19:04:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0166.hostedemail.com [216.40.44.166])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1756B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 19:04:27 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B0EA3824CA3A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:26 +0000 (UTC)
X-FDA: 75880624932.18.cloth08_26c555fb7e75a
X-HE-Tag: cloth08_26c555fb7e75a
X-Filterd-Recvd-Size: 2450
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:26 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2F9BF23430;
	Fri, 30 Aug 2019 23:04:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567206265;
	bh=yYvR6C/3REO818kqJy9ukr6/OfjeGjXTu6MjuUCRRFw=;
	h=Date:From:To:Cc:Subject:From;
	b=CPN//g20SO13fSxAyPXsoe4XNczWqxF7X+H/HIPaUjU5NnX7rnnmfI7fpSfDL6GSZ
	 pLhM4JA9tymic6az+oONxdejIyOagllA6hzRFnmB8coczyGc19vtEW6beV0LCJj4Fg
	 M9XJoelAwUuQTuyiy3Jux35RKPmBI2NlpeNOwQgk=
Date: Fri, 30 Aug 2019 16:04:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, linux-mm@kvack.org
Subject: incoming
Message-Id: <20190830160424.d9ece1ff59cfcb1edcc269f5@linux-foundation.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

7 fixes, based on 846d2db3e00048da3f650e0cfb0b8d67669cec3e:


    Roman Gushchin <guro@fb.com>:
      mm: memcontrol: flush percpu slab vmstats on kmem offlining

    Andrew Morton <akpm@linux-foundation.org>:
      mm/zsmalloc.c: fix build when CONFIG_COMPACTION=n

    Roman Gushchin <guro@fb.com>:
      mm, memcg: partially revert "mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones"

    "Gustavo A. R. Silva" <gustavo@embeddedor.com>:
      mm/z3fold.c: fix lock/unlock imbalance in z3fold_page_isolate

    Dmitry Safonov <dima@arista.com>:
      mailmap: add aliases for Dmitry Safonov

    Michal Hocko <mhocko@suse.com>:
      mm, memcg: do not set reclaim_state on soft limit reclaim

    Shakeel Butt <shakeelb@google.com>:
      mm: memcontrol: fix percpu vmstats and vmevents flush

 .mailmap               |    3 ++
 include/linux/mmzone.h |    5 ++--
 mm/memcontrol.c        |   53 ++++++++++++++++++++++++++++++++-----------------
 mm/vmscan.c            |    5 ++--
 mm/z3fold.c            |    1 
 mm/zsmalloc.c          |    2 +
 6 files changed, 47 insertions(+), 22 deletions(-)


