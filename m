Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0097B6B006E
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 15:44:19 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so23461038pdb.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 12:44:18 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id oe2si3199520pdb.149.2015.04.14.12.44.17
        for <linux-mm@kvack.org>;
        Tue, 14 Apr 2015 12:44:18 -0700 (PDT)
Date: Tue, 14 Apr 2015 15:44:16 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: mlock() on DAX returns -ENOMEM
Message-ID: <20150414194416.GW4003@linux.intel.com>
References: <CACTTzNY+u+4rU89o9vXk2HkjdnoRW+H8VcvCdr_H04MUEBCqNg@mail.gmail.com>
 <20150413125654.GB12354@node.dhcp.inet.fi>
 <CACTTzNZJzsisnPVb_+6e2QHeoDC_q=pwD5eqe5NxDTLrFBW32w@mail.gmail.com>
 <20150414114212.GA20651@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150414114212.GA20651@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Yigal Korman <yigal@plexistor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Apr 14, 2015 at 02:42:12PM +0300, Kirill A. Shutemov wrote:
> Or we can identify DAX mapping some other way. Or introduce VM_DAX.

IS_DAX(vma->vm_file->f_mapping->host)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
