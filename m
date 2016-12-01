Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE29D280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 11:53:50 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id t31so15918848ioi.4
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:53:50 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0116.hostedemail.com. [216.40.44.116])
        by mx.google.com with ESMTPS id b42si947753iod.162.2016.12.01.08.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 08:53:50 -0800 (PST)
Date: Thu, 1 Dec 2016 11:53:46 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3 1/5] tracing: add __print_flags_u64()
Message-ID: <20161201115346.1ba16485@gandalf.local.home>
In-Reply-To: <1480610271-23699-2-git-send-email-ross.zwisler@linux.intel.com>
References: <1480610271-23699-1-git-send-email-ross.zwisler@linux.intel.com>
	<1480610271-23699-2-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu,  1 Dec 2016 09:37:47 -0700
Ross Zwisler <ross.zwisler@linux.intel.com> wrote:

> Add __print_flags_u64() and the helper trace_print_flags_seq_u64() in the
> same spirit as __print_symbolic_u64() and trace_print_symbols_seq_u64().
> These functions allow us to print symbols associated with flags that are 64
> bits wide even on 32 bit machines.
> 
> These will be used by the DAX code so that we can print the flags set in a
> pfn_t such as PFN_SG_CHAIN, PFN_SG_LAST, PFN_DEV and PFN_MAP.
> 
> Without this new function I was getting errors like the following when
> compiling for i386:
> 
> ./include/linux/pfn_t.h:13:22: warning: large integer implicitly truncated
> to unsigned type [-Woverflow]
>  #define PFN_SG_CHAIN (1ULL << (BITS_PER_LONG_LONG - 1))
>   ^
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
