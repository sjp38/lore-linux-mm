Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id E67C56B0006
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 14:48:18 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id c6-v6so1178606ybm.10
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 11:48:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q124-v6sor2320647ywf.89.2018.10.09.11.48.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 11:48:13 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/4] mm: workingset & shrinker fixes
Date: Tue,  9 Oct 2018 14:47:29 -0400
Message-Id: <20181009184732.762-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Andrew,

these patches address problems we've had in our fleet with excessive
shadow radix tree nodes and proc inodes.

Patch #1 is a fix for the same-named patch already queued up in the
-mm tree. The other three patches are stand-alone.
