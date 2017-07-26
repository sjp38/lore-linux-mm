Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B1BE96B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:43:25 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 6so10838711qts.7
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:43:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g185si14724036qka.540.2017.07.26.09.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 09:43:25 -0700 (PDT)
Date: Wed, 26 Jul 2017 18:43:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170726164319.GC29716@redhat.com>
References: <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725142626.GJ26723@dhcp22.suse.cz>
 <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
 <20170725152300.GM26723@dhcp22.suse.cz>
 <20170725153110.qzfz7wpnxkjwh5bc@node.shutemov.name>
 <20170725160359.GO26723@dhcp22.suse.cz>
 <20170725191952.GR29716@redhat.com>
 <20170726054557.GB960@dhcp22.suse.cz>
 <20170726162912.GA29716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726162912.GA29716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 26, 2017 at 06:29:12PM +0200, Andrea Arcangeli wrote:
> From 3d9001490ee1a71f39c7bfaf19e96821f9d3ff16 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Tue, 25 Jul 2017 20:02:27 +0200
> Subject: [PATCH 1/1] mm: oom: let oom_reap_task and exit_mmap to run
>  concurrently

This needs an incremental one liner...

diff --git a/mm/mmap.c b/mm/mmap.c
index bdab595ce25c..fd16996ee0a8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -44,6 +44,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/moduleparam.h>
 #include <linux/pkeys.h>
+#include <linux/oom.h>
 
 #include <linux/uaccess.h>
 #include <asm/cacheflush.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
