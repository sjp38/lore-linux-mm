Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF43828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 05:25:37 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id q63so8289037pfb.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 02:25:37 -0800 (PST)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.183])
        by mx.google.com with ESMTPS id 83si4115218pfs.84.2016.01.08.02.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 02:25:36 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] Add support for usbfs zerocopy.
Date: Fri, 8 Jan 2016 10:22:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCC00A7@AcuExch.aculab.com>
References: <20160106144512.GA21737@imap.gmail.com>
 <Pine.LNX.4.44L0.1601061032000.1579-100000@iolanthe.rowland.org>
 <20160108094535.GA17286@infradead.org>
In-Reply-To: <20160108094535.GA17286@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Christoph Hellwig' <hch@infradead.org>, Alan Stern <stern@rowland.harvard.edu>
Cc: "Steinar H. Gunderson" <sesse@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

From: Christoph Hellwig
> Sent: 08 January 2016 09:46
> On Wed, Jan 06, 2016 at 10:35:05AM -0500, Alan Stern wrote:
> > Indeed, the I/O operations we are using with mmap here are not reads or
> > writes; they are ioctls.  As far as I know, the kernel doesn't have any
> > defined interface for zerocopy ioctls.
>=20
> IF it was using mmap for I/O it would read in through the page fault
> handler an then mark the page dirty for writeback by the VM.  Thats
> clearly not the case.

Indeed, and never is the case when mmap() is processed by a
driver rather than a filesystem.

> Instead it's using mmap on a file as a pecial purpose anonymous
> memory allocator, bypassing the VM and VM policies, including
> allowing to pin kernel memory that way.

Opening a driver often allocates kernel memory, not a big deal.

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
