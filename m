Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 22B836B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 09:44:51 -0400 (EDT)
Received: by eyh6 with SMTP id 6so4052eyh.20
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 06:44:48 -0700 (PDT)
Date: Tue, 9 Aug 2011 16:44:40 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLUB fixes for v3.1-rc1
Message-ID: <alpine.DEB.2.00.1108091644170.2453@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Linus,

Here's two SLUB debugging fixes. The most important one is the full list
corruption issue reported by multiple people when SLUB debugging is enabled.
The other one is from Akinobu Mita that fixes up debugging byte pattern
checking.

                         Pekka

The following changes since commit 322a8b034003c0d46d39af85bf24fee27b902f48:
   Linus Torvalds (1):
         Linux 3.1-rc1

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git slab/urgent

Akinobu Mita (1):
       slub: fix check_bytes() for slub debugging

Christoph Lameter (1):
       slub: Fix full list corruption if debugging is on

  mm/slub.c |    8 +++++---
  1 files changed, 5 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
