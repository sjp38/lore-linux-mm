Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5EDDF828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 11:04:21 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id oh2so227063100lbb.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 08:04:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88si62271248lfv.243.2016.01.08.08.04.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 08 Jan 2016 08:04:19 -0800 (PST)
Message-ID: <1452268927.11435.3.camel@suse.com>
Subject: Re: [PATCH] Add support for usbfs zerocopy.
From: Oliver Neukum <oneukum@suse.com>
Date: Fri, 08 Jan 2016 17:02:07 +0100
In-Reply-To: <20160108094535.GA17286@infradead.org>
References: <20160106144512.GA21737@imap.gmail.com>
	 <Pine.LNX.4.44L0.1601061032000.1579-100000@iolanthe.rowland.org>
	 <20160108094535.GA17286@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>, "Steinar H. Gunderson" <sesse@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2016-01-08 at 01:45 -0800, Christoph Hellwig wrote:
> On Wed, Jan 06, 2016 at 10:35:05AM -0500, Alan Stern wrote:
> > Indeed, the I/O operations we are using with mmap here are not reads or 
> > writes; they are ioctls.  As far as I know, the kernel doesn't have any 
> > defined interface for zerocopy ioctls.
> 
> IF it was using mmap for I/O it would read in through the page fault
> handler an then mark the page dirty for writeback by the VM.  Thats
> clearly not the case.

That won't work because we need the ability to determine the chunk size
IO is done in. USB devices don't map to files, yet the memory they can
operate on depends on the device, so allocation in the kernel for
a specific device is a necessity.

	Regards
		Oliver


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
