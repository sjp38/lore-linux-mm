Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 449FB6B026C
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 13:58:48 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q81so9437068ioi.12
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 10:58:48 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id i66si1443054iti.130.2017.11.01.10.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 10:58:47 -0700 (PDT)
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
 <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com>
 <CA+55aFypdyt+3-JyD3U1da5EqznncxKZZKPGn4ykkD=4Q4rdvw@mail.gmail.com>
 <8bacac66-7d3e-b15d-a73b-92c55c0b1908@linux.intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <094b0c84-929e-c108-0fc0-19753a18d892@infradead.org>
Date: Wed, 1 Nov 2017 10:58:40 -0700
MIME-Version: 1.0
In-Reply-To: <8bacac66-7d3e-b15d-a73b-92c55c0b1908@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On 11/01/2017 10:31 AM, Dave Hansen wrote:

(from attachment)

diff --git a/arch/x86/mm/kaiser.c b/arch/x86/mm/kaiser.c
index 57f7637..cde9014 100644
--- a/arch/x86/mm/kaiser.c
+++ b/arch/x86/mm/kaiser.c
@@ -49,9 +49,21 @@
 static DEFINE_SPINLOCK(shadow_table_allocation_lock);
 
 /*
+ * This is a generic page table walker used only for walking kernel
+ * addresses.  We use it too help recreate the "shadow" page tables

                          to help 

+ * which are used while we are in userspace.
+ *



-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
