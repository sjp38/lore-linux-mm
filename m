Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E990628028E
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 07:20:38 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id b79so7560568pfk.9
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:20:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n1si8461443pge.830.2017.11.10.04.20.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 04:20:37 -0800 (PST)
Date: Fri, 10 Nov 2017 13:20:30 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 20/30] x86, mm: remove hard-coded ASID limit checks
Message-ID: <20171110122030.5zyplbb3tnwpa2vu@hirez.programming.kicks-ass.net>
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194724.C0167D83@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108194724.C0167D83@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Wed, Nov 08, 2017 at 11:47:24AM -0800, Dave Hansen wrote:
> +#define CR3_HW_ASID_BITS 12
> +#define NR_AVAIL_ASIDS ((1<<CR3_AVAIL_ASID_BITS) - 1)

That evaluates to 4095

> -		VM_WARN_ON_ONCE(asid > 4094);
> +		VM_WARN_ON_ONCE(asid > NR_AVAIL_ASIDS);

Not the same number

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
