Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D92516B0270
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 07:06:56 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x79so8114452lff.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 04:06:56 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id u3si4127697lfi.19.2016.10.27.04.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 04:06:54 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id n3so1751171lfn.0
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 04:06:54 -0700 (PDT)
Date: Thu, 27 Oct 2016 13:06:47 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCHv3 0/3] z3fold: background page compaction
Message-Id: <20161027130647.782b8ab1f71555200ba15605@gmail.com>
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

Changes compared to v2:
- more accurate accounting of unbuddied_nr, per Dan's
  comments
- various cleanups.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

[1] https://lkml.org/lkml/2016/10/15/31

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
