Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 1A2B26B009E
	for <linux-mm@kvack.org>; Tue, 14 May 2013 07:49:36 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id bv13so363621pdb.0
        for <linux-mm@kvack.org>; Tue, 14 May 2013 04:49:35 -0700 (PDT)
Message-ID: <519224C7.3010908@gmail.com>
Date: Tue, 14 May 2013 19:49:27 +0800
From: majianpeng <majianpeng@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 0/3] mm/kmemleak.c: Fix some trivial problems.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Jianpeng Ma (3):
  mm/kmemleak.c: Use %u to print ->checksum.
  mm/kmemleak.c: Use list_for_each_entry_safe to reconstruct function   
     scan_gray_list.
  mm/kmemleak.c: Merge the consecutive scan-areas.

 mm/kmemleak.c | 36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

-- 
1.8.3.rc1.44.gb387c77

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
