Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EDA226B02F3
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:07:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e3so210417581pfc.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:07:03 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id g9si11056922pgr.529.2017.07.27.05.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 05:07:02 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id g69so8998859pfe.1
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:07:02 -0700 (PDT)
From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 1/5] mm: ksm: constify attribute_group structures.
Date: Thu, 27 Jul 2017 17:36:07 +0530
Message-Id: <1501157167-3706-2-git-send-email-arvind.yadav.cs@gmail.com>
In-Reply-To: <1501157167-3706-1-git-send-email-arvind.yadav.cs@gmail.com>
References: <1501157167-3706-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org, minchan@kernel.org, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, aarcange@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

attribute_group are not supposed to change at runtime. All functions
working with attribute_group provided by <linux/sysfs.h> work with
const attribute_group. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 mm/ksm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 4dc92f1..0c927e3 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -3042,7 +3042,7 @@ static ssize_t full_scans_show(struct kobject *kobj,
 	NULL,
 };
 
-static struct attribute_group ksm_attr_group = {
+static const struct attribute_group ksm_attr_group = {
 	.attrs = ksm_attrs,
 	.name = "ksm",
 };
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
