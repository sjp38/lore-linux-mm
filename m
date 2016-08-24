Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC9DA6B0267
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 18:47:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so57475739pfg.1
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 15:47:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k20si11765637pfg.177.2016.08.24.15.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 15:47:59 -0700 (PDT)
Date: Wed, 24 Aug 2016 15:47:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: silently skip readahead for DAX inodes
Message-Id: <20160824154758.3bb6bbf66f8914f0e90c9183@linux-foundation.org>
In-Reply-To: <20160824221429.21158-1-ross.zwisler@linux.intel.com>
References: <20160824134212.e9b50aa36523fbfcbcfe2f55@linux-foundation.org>
	<20160824221429.21158-1-ross.zwisler@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Kara <jack@suse.com>, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, Jeff Moyer <jmoyer@redhat.com>

On Wed, 24 Aug 2016 16:14:29 -0600 Ross Zwisler <ross.zwisler@linux.intel.com> wrote:

> For DAX inodes we need to be careful to never have page cache pages in the
> mapping->page_tree.  This radix tree should be composed only of DAX
> exceptional entries and zero pages.
> 
> ltp's readahead02 test was triggering a warning because we were trying to
> insert a DAX exceptional entry but found that a page cache page had
> already been inserted into the tree.  This page was being inserted into the
> radix tree in response to a readahead(2) call.
> 
> Readahead doesn't make sense for DAX inodes, but we don't want it to report
> a failure either.  Instead, we just return success and don't do any work.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reported-by: Jeff Moyer <jmoyer@redhat.com>

cc:stable [4.5+] ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
