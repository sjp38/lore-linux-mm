Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB1676B026A
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:32:19 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e4so126422095pfg.4
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:32:19 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id g89si20953169pfa.120.2017.01.24.14.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 14:32:18 -0800 (PST)
Received: by mail-pf0-x22e.google.com with SMTP id y143so52962963pfb.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:32:18 -0800 (PST)
Date: Tue, 24 Jan 2017 14:32:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -man] madvise.2: Specify new ENOMEM return value
In-Reply-To: <alpine.DEB.2.10.1701241431120.42507@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1701241431530.42507@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701241431120.42507@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Johannes Weiner <hannes@cmpxchg.org>, Jerome Marchand <jmarchan@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

madvise(2) may return ENOMEM if the advice acts on a vma that must be
split and creating the new vma will result in the process exceeding
/proc/sys/vm/max_map_count.

Specify this additional possibility.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 man2/madvise.2 | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/man2/madvise.2 b/man2/madvise.2
--- a/man2/madvise.2
+++ b/man2/madvise.2
@@ -467,7 +467,12 @@ Not enough memory: paging in failed.
 .TP
 .B ENOMEM
 Addresses in the specified range are not currently
-mapped, or are outside the address space of the process.
+mapped, are outside the address space of the process, or will result in the
+number of areas mapped by this process to exceed
+.I /proc/sys/vm/max_map_count
+(see the Linux kernel source file
+.I Documentation/sysctl/vm.txt
+for more details).
 .TP
 .B EPERM
 .I advice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
