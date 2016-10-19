Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC566B025E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:33:52 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id z65so47193383itc.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 09:33:52 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id v192si5164596ith.89.2016.10.19.09.33.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 09:33:51 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id 139so1868250itm.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 09:33:51 -0700 (PDT)
Date: Wed, 19 Oct 2016 18:33:40 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 0/3] z3fold: background page compaction
Message-Id: <20161019183340.9e3738b403ddda1a04c8f906@gmail.com>
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

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

[1] https://lkml.org/lkml/2016/10/15/31

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
