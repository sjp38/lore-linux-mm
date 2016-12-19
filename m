Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E29F96B02A7
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 11:46:02 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id p66so418451753pga.4
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 08:46:02 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o61si18988763plb.168.2016.12.19.08.46.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 08:46:01 -0800 (PST)
Date: Mon, 19 Dec 2016 09:46:00 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 0/5] introduce DAX tracepoint support
Message-ID: <20161219164600.GA21334@linux.intel.com>
References: <1480610271-23699-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480610271-23699-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, Dec 01, 2016 at 09:37:46AM -0700, Ross Zwisler wrote:
> Tracepoints are the standard way to capture debugging and tracing
> information in many parts of the kernel, including the XFS and ext4
> filesystems.  This series creates a tracepoint header for FS DAX and add
> the first few DAX tracepoints to the PMD fault handler.  This allows the
> tracing for DAX to be done in the same way as the filesystem tracing so
> that developers can look at them together and get a coherent idea of what
> the system is doing.
> 
> I do intend to add tracepoints to the normal 4k DAX fault path and to the
> DAX I/O path, but I wanted to get feedback on the PMD tracepoints before I
> went any further.
> 
> This series is based on Jan Kara's "dax: Clear dirty bits after flushing
> caches" series:
> 
> https://lists.01.org/pipermail/linux-nvdimm/2016-November/007864.html
> 
> I've pushed a git tree with this work here:
> 
> https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_tracepoints_v3
> 
> Changes since v2:
>  - Dropped "dax: remove leading space from labels" patch. (Jan)
>  - Reordered TP_STRUCT__entry() fields so that all the 64 bit entries (for
>    64 bit machines) come first, followed by the 32 bit entries.  This
>    allows for optimal packing of the entires. (Steve)
>  - Fixed 'mask' in trace_print_flags_seq_u64() to be an unsigned long long.
>    (Steve)
> 
> Ross Zwisler (5):
>   tracing: add __print_flags_u64()
>   dax: add tracepoint infrastructure, PMD tracing
>   dax: update MAINTAINERS entries for FS DAX
>   dax: add tracepoints to dax_pmd_load_hole()
>   dax: add tracepoints to dax_pmd_insert_mapping()
> 
>  MAINTAINERS                   |   5 +-
>  fs/dax.c                      |  56 ++++++++++-----
>  include/linux/mm.h            |  25 +++++++
>  include/linux/pfn_t.h         |   6 ++
>  include/linux/trace_events.h  |   4 ++
>  include/trace/events/fs_dax.h | 161 ++++++++++++++++++++++++++++++++++++++++++
>  include/trace/trace_events.h  |  11 +++
>  kernel/trace/trace_output.c   |  38 ++++++++++
>  8 files changed, 288 insertions(+), 18 deletions(-)
>  create mode 100644 include/trace/events/fs_dax.h

Ping on this series - Dave, were you planning on sending this for v4.10-rc1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
