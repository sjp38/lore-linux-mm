Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F75F6B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:10:16 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fi2so187077425pad.3
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:10:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id r84si19231019pfg.83.2016.09.30.02.10.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Sep 2016 02:10:15 -0700 (PDT)
Date: Fri, 30 Sep 2016 02:10:14 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 02/20] mm: Join struct fault_env and vm_fault
Message-ID: <20160930091014.GB24352@infradead.org>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-3-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:06PM +0200, Jan Kara wrote:
> Currently we have two different structures for passing fault information
> around - struct vm_fault and struct fault_env. DAX will need more
> information in struct vm_fault to handle its faults so the content of
> that structure would become event closer to fault_env. Furthermore it
> would need to generate struct fault_env to be able to call some of the
> generic functions. So at this point I don't think there's much use in
> keeping these two structures separate. Just embed into struct vm_fault
> all that is needed to use it for both purposes.

Looks sensible, and I wonder why it's not been like that from
the start.  But given that you touched all users of the virtual_address
member earlier:  any reason not to move everyone to the unmasked variant
there and avoid having to pass the address twice?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
