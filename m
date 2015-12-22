Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7764B82F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 17:46:13 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id o64so112679853pfb.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:46:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t2si15971068pfa.163.2015.12.22.14.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 14:46:12 -0800 (PST)
Date: Tue, 22 Dec 2015 14:46:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 3/7] mm: add find_get_entries_tag()
Message-Id: <20151222144611.07002cfde41d035125da2fa5@linux-foundation.org>
In-Reply-To: <1450502540-8744-4-git-send-email-ross.zwisler@linux.intel.com>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
	<1450502540-8744-4-git-send-email-ross.zwisler@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org, xfs@oss.sgi.com, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, 18 Dec 2015 22:22:16 -0700 Ross Zwisler <ross.zwisler@linux.intel.com> wrote:

> Add find_get_entries_tag() to the family of functions that include
> find_get_entries(), find_get_pages() and find_get_pages_tag().  This is
> needed for DAX dirty page handling because we need a list of both page
> offsets and radix tree entries ('indices' and 'entries' in this function)
> that are marked with the PAGECACHE_TAG_TOWRITE tag.
> 
> ...
>
> +EXPORT_SYMBOL(find_get_entries_tag);

This is actually a pretty crappy name because it doesn't describe what
subsystem it belongs to.  scheduler?  scatter/gather?  filesystem?

But given what we've already done, I don't see an obvious fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
