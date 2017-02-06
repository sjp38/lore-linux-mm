Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E03E6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 03:51:47 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so16908244wjb.7
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 00:51:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 75si7228397wml.110.2017.02.06.00.51.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 00:51:46 -0800 (PST)
Date: Mon, 6 Feb 2017 09:51:33 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: replace FAULT_FLAG_SIZE with parameter to huge_fault
Message-ID: <20170206085133.GB4004@quack2.suse.cz>
References: <148615748258.43180.1690152053774975329.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148615748258.43180.1690152053774975329.stgit@djiang5-desk3.ch.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: akpm@linux-foundation.org, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, dave.hansen@linux.intel.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, ross.zwisler@linux.intel.com, vbabka@suse.cz

On Fri 03-02-17 14:31:22, Dave Jiang wrote:
> Since the introduction of FAULT_FLAG_SIZE to the vm_fault flag, it has
> been somewhat painful with getting the flags set and removed at the
> correct locations. More than one kernel oops was introduced due to
> difficulties of getting the placement correctly. Removing the flag
> values and introducing an input parameter to huge_fault that indicates
> the size of the page entry. This makes the code easier to trace and
> should avoid the issues we see with the fault flags where removal of the
> flag was necessary in the fallback paths.
> 
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>

Yeah, the code looks less error-prone this way. I like it. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>


								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
