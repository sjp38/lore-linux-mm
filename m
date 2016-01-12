Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E70A0828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:26:53 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l65so269159289wmf.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 13:26:53 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id wx4si178596669wjc.156.2016.01.12.13.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 13:26:52 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id l65so269158805wmf.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 13:26:52 -0800 (PST)
Date: Tue, 12 Jan 2016 22:26:48 +0100
From: "Steinar H. Gunderson" <sesse@google.com>
Subject: Re: [PATCH] Add support for usbfs zerocopy.
Message-ID: <20160112212644.GA6172@imap.gmail.com>
References: <20160106144512.GA21737@imap.gmail.com>
 <Pine.LNX.4.44L0.1601061032000.1579-100000@iolanthe.rowland.org>
 <20160108094535.GA17286@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160108094535.GA17286@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 08, 2016 at 01:45:35AM -0800, Christoph Hellwig wrote:
> IF it was using mmap for I/O it would read in through the page fault
> handler an then mark the page dirty for writeback by the VM.  Thats
> clearly not the case.
> 
> Instead it's using mmap on a file as a pecial purpose anonymous
> memory allocator, bypassing the VM and VM policies, including
> allowing to pin kernel memory that way.

FWIW, the allocated memory counts against the usbfs limits, so there's
no unbounded allocation opportunity here.

How do you suggest we proceed here? If mmap really is the wrong interface
(which is a bit frustrating after going through so many people :-) ),
what does the correct interface look like?

/* Steinar */
-- 
Software Engineer, Google Switzerland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
