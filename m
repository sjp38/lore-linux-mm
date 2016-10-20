Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 725F06B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 17:50:31 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id f129so133058342itc.7
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 14:50:31 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 88si1382007iop.72.2016.10.20.14.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 14:50:30 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id i85so6607976pfa.0
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 14:50:30 -0700 (PDT)
Date: Thu, 20 Oct 2016 23:50:17 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCHv2 0/3] z3fold: background page compaction
Message-Id: <20161020235017.d68ab1ff83d6f246fa3d7ee2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

The coming patchset is another take on z3fold page layout
optimization problem. The previous solution [1] used
shrinker to solve the issue of in-page space fragmentation
but after some discussions the decision was made to rewrite
background page layout optimization using good old work
queues.

The patchset thus implements in-page compaction worker for
z3fold, preceded by some code optimizations and preparations
which, again, deserved to be separate patches.

Main changes compared to v1:
- per-page locking is removed due to size problems (z3fold
  header becomes greater than one chunk on x86_64 with gcc
  6.0) and non-obvious performance benefits
- instead, per-pool spinlock is substituted with rwlock.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

[1] https://lkml.org/lkml/2016/10/15/31

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
