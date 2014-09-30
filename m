Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B8EDB6B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 10:48:59 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id et14so4997144pad.3
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 07:48:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ki1si12499794pbd.167.2014.09.30.07.48.57
        for <linux-mm@kvack.org>;
        Tue, 30 Sep 2014 07:48:57 -0700 (PDT)
Date: Tue, 30 Sep 2014 10:48:54 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
Message-ID: <20140930144854.GA5098@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <15705.1412070301@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15705.1412070301@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>

On Tue, Sep 30, 2014 at 05:45:01AM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 25 Sep 2014 16:33:17 -0400, Matthew Wilcox said:
> 
> > Patch 19 adds some DAX infrastructure to support ext4.
> >
> > Patch 20 adds DAX support to ext4.  It is broadly similar to ext2's DAX
> > support, but it is more efficient than ext4's due to its support for
> > unwritten extents.
> 
> I don't currently have a use case for NV-DIMM support.
> 
> However, it would be nice if this code could be leveraged to support
> 'force O_DIRECT on all I/O to this file' - that I *do* have a use
> case for.  Patch 20 looks to my untrained eye like it *almost* gets
> there.
> 
> (And if in fact it *does* do the whole enchilada, the Changelog etc should
> mention it :)

No, it doesn't try to do that.  Wouldn't you be better served with an
LD_PRELOAD that forces O_DIRECT on?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
