Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D082280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 11:11:13 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id m67so183340306qkf.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:11:13 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0225.hostedemail.com. [216.40.44.225])
        by mx.google.com with ESMTPS id g78si869006iog.32.2016.12.01.08.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 08:11:12 -0800 (PST)
Date: Thu, 1 Dec 2016 11:11:06 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 6/6] dax: add tracepoints to dax_pmd_insert_mapping()
Message-ID: <20161201111106.47510605@gandalf.local.home>
In-Reply-To: <20161201154432.GD5160@linux.intel.com>
References: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
	<1480549533-29038-7-git-send-email-ross.zwisler@linux.intel.com>
	<20161201091930.2084d32c@gandalf.local.home>
	<20161201154432.GD5160@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, 1 Dec 2016 08:44:32 -0700
Ross Zwisler <ross.zwisler@linux.intel.com> wrote:


> Actually I think it may be ideal to stick it as the 2nd entry after 'dev'.
> dev_t is:
> 
> typedef __u32 __kernel_dev_t;
> typedef __kernel_dev_t		dev_t;
> 
> So those two 32 bit values should combine into a single 64 bit space.

Yeah that should work too.

-- Steve

> 
> Thanks for the help, I obviously wasn't considering packing when ordering the
> elements.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
