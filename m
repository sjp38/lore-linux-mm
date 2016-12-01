Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5118E280260
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 10:39:42 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j128so356040592pfg.4
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:39:42 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g19si606349plj.102.2016.12.01.07.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 07:39:41 -0800 (PST)
Date: Thu, 1 Dec 2016 08:39:40 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 3/6] dax: add tracepoint infrastructure, PMD tracing
Message-ID: <20161201153940.GC5160@linux.intel.com>
References: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
 <1480549533-29038-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161201091628.7057580f@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201091628.7057580f@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, Dec 01, 2016 at 09:16:28AM -0500, Steven Rostedt wrote:
> On Wed, 30 Nov 2016 16:45:30 -0700
> Ross Zwisler <ross.zwisler@linux.intel.com> wrote:
> 
> 
> > --- /dev/null
> > +++ b/include/trace/events/fs_dax.h
> > @@ -0,0 +1,68 @@
> > +#undef TRACE_SYSTEM
> > +#define TRACE_SYSTEM fs_dax
> > +
> > +#if !defined(_TRACE_FS_DAX_H) || defined(TRACE_HEADER_MULTI_READ)
> > +#define _TRACE_FS_DAX_H
> > +
> > +#include <linux/tracepoint.h>
> > +
> > +DECLARE_EVENT_CLASS(dax_pmd_fault_class,
> > +	TP_PROTO(struct inode *inode, struct vm_area_struct *vma,
> > +		unsigned long address, unsigned int flags, pgoff_t pgoff,
> > +		pgoff_t max_pgoff, int result),
> > +	TP_ARGS(inode, vma, address, flags, pgoff, max_pgoff, result),
> > +	TP_STRUCT__entry(
> > +		__field(dev_t, dev)
> > +		__field(unsigned long, ino)
> > +		__field(unsigned long, vm_start)
> > +		__field(unsigned long, vm_end)
> > +		__field(unsigned long, vm_flags)
> > +		__field(unsigned long, address)
> > +		__field(unsigned int, flags)
> > +		__field(pgoff_t, pgoff)
> > +		__field(pgoff_t, max_pgoff)
> > +		__field(int, result)
> 
> For better compaction, I would put flags and result together, as they
> are both ints. Otherwise, you'll probably have 4 empty bytes after
> flags.

Sure, will do for v3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
