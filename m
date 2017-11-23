Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29E566B0069
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 10:02:45 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id s28so17197112pfg.6
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:02:45 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id bg3si13071568plb.167.2017.11.23.07.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 07:02:44 -0800 (PST)
Subject: Re: [PATCH 00/23] [v4] KAISER: unmap most of the kernel from
 userspace page tables
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123072742.ouswjlvevpuincgx@gmail.com>
 <20171123073254.vafflgq253mhppy5@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <2d07acca-48ca-a71d-c5e5-99ab309f2870@linux.intel.com>
Date: Thu, 23 Nov 2017 07:02:40 -0800
MIME-Version: 1.0
In-Reply-To: <20171123073254.vafflgq253mhppy5@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, jgross@suse.com

On 11/22/2017 11:32 PM, Ingo Molnar wrote:
> diff --git a/arch/x86/events/intel/ds.c b/arch/x86/events/intel/ds.c
> index c9f44d7ce838..61388b01962d 100644
> --- a/arch/x86/events/intel/ds.c
> +++ b/arch/x86/events/intel/ds.c
> @@ -3,7 +3,7 @@
>  #include <linux/types.h>
>  #include <linux/slab.h>
>  
> -#include <asm/kaiser.h>
> +#include <linux/kaiser.h>
>  #include <asm/perf_event.h>
>  #include <asm/insn.h>

Yes, that looks like the correct fix on both counts.

Please let me know if you would like an updated series to fix these,
either in email or a git tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
