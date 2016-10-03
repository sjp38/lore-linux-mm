Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0186B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 03:43:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b201so33305627wmb.2
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 00:43:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c184si17380056wmd.123.2016.10.03.00.43.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Oct 2016 00:43:53 -0700 (PDT)
Date: Mon, 3 Oct 2016 09:43:51 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 02/20] mm: Join struct fault_env and vm_fault
Message-ID: <20161003074351.GF6457@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-3-git-send-email-jack@suse.cz>
 <20160930091014.GB24352@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160930091014.GB24352@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri 30-09-16 02:10:14, Christoph Hellwig wrote:
> On Tue, Sep 27, 2016 at 06:08:06PM +0200, Jan Kara wrote:
> > Currently we have two different structures for passing fault information
> > around - struct vm_fault and struct fault_env. DAX will need more
> > information in struct vm_fault to handle its faults so the content of
> > that structure would become event closer to fault_env. Furthermore it
> > would need to generate struct fault_env to be able to call some of the
> > generic functions. So at this point I don't think there's much use in
> > keeping these two structures separate. Just embed into struct vm_fault
> > all that is needed to use it for both purposes.
> 
> Looks sensible, and I wonder why it's not been like that from
> the start.  But given that you touched all users of the virtual_address
> member earlier:  any reason not to move everyone to the unmasked variant
> there and avoid having to pass the address twice?

Hum, right, probably makes sense. I'll do that for the next version.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
