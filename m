Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2C36B0038
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 02:32:58 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v8so986622wmh.2
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 23:32:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g96sor6983344wrd.9.2017.11.22.23.32.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 23:32:57 -0800 (PST)
Date: Thu, 23 Nov 2017 08:32:54 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/23] [v4] KAISER: unmap most of the kernel from
 userspace page tables
Message-ID: <20171123073254.vafflgq253mhppy5@gmail.com>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123072742.ouswjlvevpuincgx@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171123072742.ouswjlvevpuincgx@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, jgross@suse.com


* Ingo Molnar <mingo@kernel.org> wrote:

> 
> 32-bit x86 defconfig still doesn't build:
> 
>  arch/x86/events/intel/ds.c: In function a??dsalloca??:
>  arch/x86/events/intel/ds.c:296:6: error: implicit declaration of function a??kaiser_add_mappinga??; did you mean a??kgid_has_mappinga??? [-Werror=implicit-function-declaration]

The patch below should cure this one - only build tested.

Thanks,

	Ingo

 arch/x86/events/intel/ds.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/events/intel/ds.c b/arch/x86/events/intel/ds.c
index c9f44d7ce838..61388b01962d 100644
--- a/arch/x86/events/intel/ds.c
+++ b/arch/x86/events/intel/ds.c
@@ -3,7 +3,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 
-#include <asm/kaiser.h>
+#include <linux/kaiser.h>
 #include <asm/perf_event.h>
 #include <asm/insn.h>
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
