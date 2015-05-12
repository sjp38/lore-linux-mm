Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7846E6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:43:08 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so1232128lbb.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:43:07 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [95.108.253.251])
        by mx.google.com with ESMTPS id e4si9997048laf.74.2015.05.12.02.43.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 02:43:06 -0700 (PDT)
Subject: [PATCH RFC 0/3] pagemap: make useable for non-privilege users
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 12 May 2015 12:43:02 +0300
Message-ID: <20150512090156.24768.2521.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Williamson <mwilliamson@undo-software.com>, Pavel Emelyanov <xemul@parallels.com>, linux-api@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Machek <pavel@ucw.cz>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Daniel James <djames@undo-software.com>, Finn Grimwood <fgrimwood@undo-software.com>

This patchset tries to make pagemap useable again in the safe way.
First patch adds bit 'map-exlusive' which is set if page is mapped only here.
Second patch restores access for non-privileged users but hides pfn if task
has no capability CAP_SYS_ADMIN. Third patch removes page-shift bits and
completes migration to the new pagemap format (flags soft-dirty and
mmap-exlusive are available only in the new format).

---

Konstantin Khlebnikov (3):
      pagemap: add mmap-exclusive bit for marking pages mapped only here
      pagemap: hide physical addresses from non-privileged users
      pagemap: switch to the new format and do some cleanup


 Documentation/vm/pagemap.txt |    3 -
 fs/proc/task_mmu.c           |  178 +++++++++++++++++-------------------------
 tools/vm/page-types.c        |   35 ++++----
 3 files changed, 91 insertions(+), 125 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
