Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9BFD4800C7
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 18:54:26 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id f206so52937413wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 15:54:26 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id i9si128540445wjf.175.2016.01.05.15.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 15:54:25 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id f206so41699553wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 15:54:25 -0800 (PST)
Date: Wed, 6 Jan 2016 00:54:21 +0100
From: "Steinar H. Gunderson" <sesse@google.com>
Subject: Re: Does vm_operations_struct require a .owner field?
Message-ID: <20160105235418.GA1599@imap.gmail.com>
References: <20160105205812.GA24738@node.shutemov.name>
 <Pine.LNX.4.44L0.1601051619200.1350-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.1601051619200.1350-100000@iolanthe.rowland.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, David Laight <David.Laight@ACULAB.COM>, "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>

On Tue, Jan 05, 2016 at 04:31:09PM -0500, Alan Stern wrote:
> Thank you.  So it looks like I was worried about nothing.
> 
> Steinar, you can remove the try_module_get/module_put lines from your
> patch.  Also, the list_del() and comment in usbdev_release() aren't 
> needed -- at that point we know the memory_list has to be empty since 
> there can't be any outstanding URBs or VMA references.  If you take 
> those things out then the patch should be ready for merging.

Good, thanks. Did so, compiled, testing it still works, sending :-)

/* Steinar */
-- 
Software Engineer, Google Switzerland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
