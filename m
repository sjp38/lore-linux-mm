Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id ABE946B0005
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 04:19:51 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id 128so53792462wmz.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 01:19:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b7si2583177wmh.119.2016.02.12.01.19.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 12 Feb 2016 01:19:50 -0800 (PST)
Subject: Re: [PATCH] mm, tracing: refresh __def_vmaflag_names
References: <1455144302-59371-1-git-send-email-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56BDA3B4.7040107@suse.cz>
Date: Fri, 12 Feb 2016 10:19:48 +0100
MIME-Version: 1.0
In-Reply-To: <1455144302-59371-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On 02/10/2016 11:45 PM, Kirill A. Shutemov wrote:
> Get list of VMA flags up-to-date and sort it to match VM_* definition
> order.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

How about also this?

----8<----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Fri, 12 Feb 2016 10:16:53 +0100
Subject: [PATCH] mm-tracing-refresh-__def_vmaflag_names-v2

Add a note above vmaflag definitions to update the names when changing.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mm.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a0ad7af5a1a2..550c88663362 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -122,6 +122,7 @@ extern unsigned int kobjsize(const void *objp);
 
 /*
  * vm_flags in vm_area_struct, see mm_types.h.
+ * When changing, update also include/trace/events/mmflags.h
  */
 #define VM_NONE		0x00000000
 
-- 
2.7.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
