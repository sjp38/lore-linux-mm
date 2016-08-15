Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 780376B0038
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 17:11:08 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so135926879pfg.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 14:11:08 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id g1si28321277pab.228.2016.08.15.14.11.07
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 14:11:07 -0700 (PDT)
Date: Mon, 15 Aug 2016 15:11:06 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 0/7] re-enable DAX PMD support
Message-ID: <20160815211106.GA31566@linux.intel.com>
References: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
 <CAPcyv4j_eh8Rcozb40JeiPwvbPoMY2sCt+yTewZ-MZzUkBbj-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4j_eh8Rcozb40JeiPwvbPoMY2sCt+yTewZ-MZzUkBbj-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Mon, Aug 15, 2016 at 01:21:47PM -0700, Dan Williams wrote:
> On Mon, Aug 15, 2016 at 12:09 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> > locking.  This series allows DAX PMDs to participate in the DAX radix tree
> > based locking scheme so that they can be re-enabled.
> 
> Looks good to me.
> 
> > This series restores DAX PMD functionality back to what it was before it
> > was disabled.  There is still a known issue between DAX PMDs and hole
> > punch, which I am currently working on and which I plan to address with a
> > separate series.
> 
> Perhaps we should hold off on applying patch 6 and 7 until after the
> hole-punch fix is ready?

Sure, I'm cool with holding off on patch 7 (the Kconfig change) until after
the hole punch fix is ready.

I don't see a reason to hold off on patch 6, though?  It stands on it's own,
implements the correct locking, and doesn't break anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
