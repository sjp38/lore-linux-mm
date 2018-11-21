Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6E26B2512
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 03:14:08 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 34-v6so6858568plf.6
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:14:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9-v6sor49495577pfk.21.2018.11.21.00.14.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 00:14:07 -0800 (PST)
From: john.hubbard@gmail.com
Subject: [PATCH 0/1] mm/gup: finish consolidating error handling
Date: Wed, 21 Nov 2018 00:14:01 -0800
Message-Id: <20181121081402.29641-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Hi,

Keith Busch and Dan Williams noticed that this patch
(which was part of my RFC[1] for the get_user_pages + DMA
fix) also fixes a bug. Accordingly, I'm adjusting
the changelog and posting this as it's own patch.

[1] https://lkml.kernel.org/r/20181110085041.10071-1-jhubbard@nvidia.com

John Hubbard (1):
  mm/gup: finish consolidating error handling

 mm/gup.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

-- 
2.19.1
