Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 635986B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 16:30:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 4so44911441pfw.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 13:30:25 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id g197si4542973pfb.203.2016.05.10.13.30.24
        for <linux-mm@kvack.org>;
        Tue, 10 May 2016 13:30:24 -0700 (PDT)
Date: Tue, 10 May 2016 14:30:03 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [RFC v3] [PATCH 0/18] DAX page fault locking
Message-ID: <20160510203003.GA5314@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <20160506203308.GA12506@linux.intel.com>
 <20160509093828.GF11897@quack2.suse.cz>
 <20160510152814.GQ11897@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160510152814.GQ11897@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Tue, May 10, 2016 at 05:28:14PM +0200, Jan Kara wrote:
> On Mon 09-05-16 11:38:28, Jan Kara wrote:
> Somehow, I'm not able to reproduce the warnings... Anyway, I think I see
> what's going on. Can you check whether the warning goes away when you
> change the condition at the end of page_cache_tree_delete() to:
> 
>         if (!dax_mapping(mapping) && !workingset_node_pages(node) &&
>             list_empty(&node->private_list)) {

Yep, this took care of both of the issues that I reported.  I'll restart my
testing with this in my baseline, but as of this fix I don't have any more
open testing issues. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
