Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 603D56B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:46:04 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so17408163pbc.30
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:46:04 -0800 (PST)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id sj7si12590873pbb.179.2014.02.18.14.46.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 14:46:03 -0800 (PST)
Received: by mail-pd0-f169.google.com with SMTP id v10so16818808pde.14
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:46:03 -0800 (PST)
Date: Tue, 18 Feb 2014 14:46:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V6 ] mm readahead: Fix readahead fail for memoryless cpu
 and limit readahead pages
In-Reply-To: <20140218143838.aee7a4f0c94ab28b3b04c1e4@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1402181441360.20772@chino.kir.corp.google.com>
References: <1392708338-19685-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <alpine.DEB.2.02.1402181421590.20772@chino.kir.corp.google.com> <20140218143838.aee7a4f0c94ab28b3b04c1e4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 18 Feb 2014, Andrew Morton wrote:

> > I'm not sure I understand why we want to be independent of PAGE_SIZE since 
> > we're still relying on PAGE_CACHE_SIZE.  Don't you mean to do
> > 
> > #define MAX_READAHEAD	((512*PAGE_SIZE)/PAGE_CACHE_SIZE)
> 
> MAX_READAHEAD is in units of "pages".
> 
> This:
> 
> +#define MAX_READAHEAD   ((512*4096)/PAGE_CACHE_SIZE)
> 
> means "two megabytes", and is implemented in a way to ensure that
> MAX_READAHEAD=2mb on 4k pagesize as well as on 64k pagesize.  Because
> we don't want variations in PAGE_SIZE to cause alterations in readahead
> behavior.
> 

Ah, ok, so 2MB is the magic value that we limit readhead to on all 
architectures.  512 * 4096 is a strange way to write 2MB, but ok :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
