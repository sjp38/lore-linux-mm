Return-Path: <SRS0=zwjV=WV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC94DC3A59E
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4553E206E0
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Pzq9n9Kd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4553E206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACBFB6B04F4; Sat, 24 Aug 2019 20:54:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7C636B04F5; Sat, 24 Aug 2019 20:54:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B9D86B04F6; Sat, 24 Aug 2019 20:54:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0213.hostedemail.com [216.40.44.213])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8E46B04F4
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:54:10 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 17611180AD7C1
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:10 +0000 (UTC)
X-FDA: 75859128660.19.step65_41740ab065a2f
X-HE-Tag: step65_41740ab065a2f
X-Filterd-Recvd-Size: 2487
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:09 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 61069206E0;
	Sun, 25 Aug 2019 00:54:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566694448;
	bh=ml+L5mENqv764UnpshqOsnVCOnoJIj55Bi+/4cFapJQ=;
	h=Date:From:To:Cc:Subject:From;
	b=Pzq9n9KdfVVL0jH5TUbfeAPk++XsO9fgXGxjrBzwLanv/vORSsNe6Hh53uLE8PvG5
	 X2QWFRFeYmskYoEtETQ0xFuzXN7RtS1YoQ2f6KMvzIB0rPsmQQFNybKGGxLADR3HR0
	 l0h6knBcQfJyu1kd6hj1xihpKu5cBWjMJz7j9jaI=
Date: Sat, 24 Aug 2019 17:54:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, linux-mm@kvack.org
Subject: incoming
Message-Id: <20190824175407.90c7a9e1fbf2fa7bc922c03a@linux-foundation.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

11 fixes, based on 361469211f876e67d7ca3d3d29e6d1c3e313d0f1:

    Henry Burns <henryburns@google.com>:
      mm/z3fold.c: fix race between migration and destruction

    David Rientjes <rientjes@google.com>:
      mm, page_alloc: move_freepages should not examine struct page of reserved memory

    Qian Cai <cai@lca.pw>:
      parisc: fix compilation errrors

    Roman Gushchin <guro@fb.com>:
      mm: memcontrol: flush percpu vmstats before releasing memcg
      mm: memcontrol: flush percpu vmevents before releasing memcg

    Jason Xing <kerneljasonxing@linux.alibaba.com>:
      psi: get poll_work to run when calling poll syscall next time

    Oleg Nesterov <oleg@redhat.com>:
      userfaultfd_release: always remove uffd flags and clear vm_userfaultfd_ctx

    Vlastimil Babka <vbabka@suse.cz>:
      mm, page_owner: handle THP splits correctly

    Henry Burns <henryburns@google.com>:
      mm/zsmalloc.c: migration can leave pages in ZS_EMPTY indefinitely
      mm/zsmalloc.c: fix race condition in zs_destroy_pool

    Andrey Ryabinin <aryabinin@virtuozzo.com>:
      mm/kasan: fix false positive invalid-free reports with CONFIG_KASAN_SW_TAGS=y


