Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1D28280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 11:56:12 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id r101so22230991ioi.3
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:56:12 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0200.hostedemail.com. [216.40.44.200])
        by mx.google.com with ESMTPS id h4si971967ite.28.2016.12.01.08.56.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 08:56:12 -0800 (PST)
Date: Thu, 1 Dec 2016 11:56:08 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3 4/5] dax: add tracepoints to dax_pmd_load_hole()
Message-ID: <20161201115608.4f97630b@gandalf.local.home>
In-Reply-To: <1480610271-23699-5-git-send-email-ross.zwisler@linux.intel.com>
References: <1480610271-23699-1-git-send-email-ross.zwisler@linux.intel.com>
	<1480610271-23699-5-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu,  1 Dec 2016 09:37:50 -0700
Ross Zwisler <ross.zwisler@linux.intel.com> wrote:

> Add tracepoints to dax_pmd_load_hole(), following the same logging
> conventions as the tracepoints in dax_iomap_pmd_fault().
> 
> Here is an example PMD fault showing the new tracepoints:
> 
> read_big-1478  [004] ....   238.242188: xfs_filemap_pmd_fault: dev 259:0
> ino 0x1003
> 
> read_big-1478  [004] ....   238.242191: dax_pmd_fault: dev 259:0 ino 0x1003
> shared ALLOW_RETRY|KILLABLE|USER address 0x10400000 vm_start 0x10200000
> vm_end 0x10600000 pgoff 0x200 max_pgoff 0x1400
> 
> read_big-1478  [004] ....   238.242390: dax_pmd_load_hole: dev 259:0 ino
> 0x1003 shared address 0x10400000 zero_page ffffea0002c20000 radix_entry
> 0x1e
> 
> read_big-1478  [004] ....   238.242392: dax_pmd_fault_done: dev 259:0 ino
> 0x1003 shared ALLOW_RETRY|KILLABLE|USER address 0x10400000 vm_start
> 0x10200000 vm_end 0x10600000 pgoff 0x200 max_pgoff 0x1400 NOPAGE
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> ---

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
