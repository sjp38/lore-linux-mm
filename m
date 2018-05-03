Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1F116B000A
	for <linux-mm@kvack.org>; Thu,  3 May 2018 16:47:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z5so4395579pfz.6
        for <linux-mm@kvack.org>; Thu, 03 May 2018 13:47:29 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id bi5-v6si11865663plb.190.2018.05.03.13.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 13:47:28 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH -next 0/2] ipc/shm: shmat() fixes around nil-page
Date: Thu,  3 May 2018 13:32:41 -0700
Message-Id: <20180503203243.15045-1-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aarcange@redhat.com
Cc: joe.lawrence@redhat.com, gareth.evans@contextis.co.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave@stgolabs.net, stable@kernel.org

Hi,

These patches fix two issues reported[1] a while back by Joe and Andrea
around how shmat(2) behaves with nil-page.

The first reverts a commit that it was incorrectly thought that mapping
nil-page (address=0) was a no no with MAP_FIXED. This is not the case,
with the exception of SHM_REMAP; which is address in the second patch.

I chose two patches because it is easier to backport and it explicitly
reverts bogus behaviour. Both patches ought to be in -stable and ltp
testcases need updated (the added testcase around the cve can be modified
to just test for SHM_RND|SHM_REMAP).

[1] lkml.kernel.org/r/20180430172152.nfa564pvgpk3ut7p@linux-n805

Thanks! 

Davidlohr Bueso (2):
  Revert "ipc/shm: Fix shmat mmap nil-page protection"
  ipc/shm: fix shmat() nil address after round-down when remapping

 ipc/shm.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

-- 
2.13.6
