Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADE716B0008
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 17:30:16 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a207so13766068qkb.23
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:30:16 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b46si10454878qtb.411.2018.03.26.14.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 14:30:15 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 0/2] Small HMM fixes
Date: Mon, 26 Mar 2018 17:30:07 -0400
Message-Id: <20180326213009.2460-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Two small fixes on top of what i already sent. First one fix a real
dumb mistake (i did). Second one fix fault logic to be consistant in
respect to all combinations.

No cc-ing stable for lack of current upstream user.

Kudos to Ralph for catching those.

Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>

Ralph Campbell (2):
  mm/hmm: do not ignore specific pte fault flag in hmm_vma_fault()
  mm/hmm: clarify fault logic for device private memory

 mm/hmm.c | 25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

-- 
2.14.3
