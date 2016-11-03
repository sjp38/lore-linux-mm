Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94C766B02CC
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 17:16:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 17so14966223pfy.2
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 14:16:51 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id 89si11621215pfl.229.2016.11.03.14.16.49
        for <linux-mm@kvack.org>;
        Thu, 03 Nov 2016 14:16:50 -0700 (PDT)
Date: Fri, 4 Nov 2016 08:16:46 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v9 00/16] re-enable DAX PMD support
Message-ID: <20161103211646.GB28177@dastard>
References: <1478030058-1422-1-git-send-email-ross.zwisler@linux.intel.com>
 <20161103015826.GI9920@dastard>
 <20161103175102.GA11784@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161103175102.GA11784@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu, Nov 03, 2016 at 11:51:02AM -0600, Ross Zwisler wrote:
> On Thu, Nov 03, 2016 at 12:58:26PM +1100, Dave Chinner wrote:
> > On Tue, Nov 01, 2016 at 01:54:02PM -0600, Ross Zwisler wrote:
> > > DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> > > locking.  This series allows DAX PMDs to participate in the DAX radix tree
> > > based locking scheme so that they can be re-enabled.
> > 
> > I've seen patch 0/16 - where did you send the other 16? I need to
> > pick up the bug fix that is in this patch set...
> 
> I CC'd your "david@fromorbit.com" address on the entire set, as well as all
> the usual lists (linux-xfs, linux-fsdevel, linux-nvdimm, etc).

Ok, now I'm /really/ confused. Procmail logs show:
