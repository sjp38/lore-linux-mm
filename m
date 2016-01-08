Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 08DC36B0254
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 04:45:38 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id e65so7649699pfe.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 01:45:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ko6si21928224pab.2.2016.01.08.01.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 01:45:37 -0800 (PST)
Date: Fri, 8 Jan 2016 01:45:35 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Add support for usbfs zerocopy.
Message-ID: <20160108094535.GA17286@infradead.org>
References: <20160106144512.GA21737@imap.gmail.com>
 <Pine.LNX.4.44L0.1601061032000.1579-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.1601061032000.1579-100000@iolanthe.rowland.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: "Steinar H. Gunderson" <sesse@google.com>, Christoph Hellwig <hch@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jan 06, 2016 at 10:35:05AM -0500, Alan Stern wrote:
> Indeed, the I/O operations we are using with mmap here are not reads or 
> writes; they are ioctls.  As far as I know, the kernel doesn't have any 
> defined interface for zerocopy ioctls.

IF it was using mmap for I/O it would read in through the page fault
handler an then mark the page dirty for writeback by the VM.  Thats
clearly not the case.

Instead it's using mmap on a file as a pecial purpose anonymous
memory allocator, bypassing the VM and VM policies, including
allowing to pin kernel memory that way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
