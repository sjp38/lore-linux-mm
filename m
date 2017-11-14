Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3CC6B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 13:20:23 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 76so18542465pfr.3
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 10:20:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e8si16272303pgt.670.2017.11.14.10.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 10:20:22 -0800 (PST)
Date: Tue, 14 Nov 2017 19:20:09 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 18/30] x86, kaiser: map virtually-addressed performance
 monitoring buffers
Message-ID: <20171114182009.jbhobwxlkfjb2t6i@hirez.programming.kicks-ass.net>
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193139.B039E97B@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110193139.B039E97B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, x86@kernel.org

On Fri, Nov 10, 2017 at 11:31:39AM -0800, Dave Hansen wrote:
>  static int alloc_ds_buffer(int cpu)
>  {
> +	struct debug_store *ds = per_cpu_ptr(&cpu_debug_store, cpu);
>  
> +	memset(ds, 0, sizeof(*ds));

Still wondering about that memset...

>  	per_cpu(cpu_hw_events, cpu).ds = ds;
>  
>  	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
