Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4806B0253
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:37:55 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id x49so411069061qtc.7
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:37:55 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id 31si15557631qtz.162.2017.02.01.15.37.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:37:54 -0800 (PST)
From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 0/4] mm: trivial sparse and checkpatch fixes
Date: Thu,  2 Feb 2017 10:37:16 +1100
Message-Id: <1485992240-10986-1-git-send-email-me@tobin.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Tobin C Harding <me@tobin.cc>

From: Tobin C Harding <me@tobin.cc>

This patchset fixes trivial sparse and checkpatch errors/warnings. The
majority of the changes are whitespace only. The only code changes are
replace 0 with NULL, and remove extraneous braces around single statement.

Patchset aims to only make changes when they objectively increase the
cleanliness of the code, does not touch line over 80 warnings.

Changes have been tested by building and booting kernel.

Tobin C Harding (4):
  mm: Fix sparse, use plain integer as NULL pointer
  mm: Fix checkpatch warnings, whitespace
  mm: Fix checkpatch errors, whitespace errors
  mm: Fix checkpatch warning, extraneous braces

 mm/memory.c | 66 ++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 32 insertions(+), 34 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
