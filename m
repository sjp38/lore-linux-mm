Subject: Re: iounmap() - can't always unmap memory I've mappedt
Date: Sat, 30 Sep 2000 00:24:43 +0100 (BST)
In-Reply-To: <20000929222813Z129135-481+1113@vger.kernel.org> from "Timur Tabi" at Sep 29, 2000 05:12:58 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13f9WH-0001kV-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Unfortunately, this mapping is a requirement for our product.  I'd hate to have
> to create my own pte's and do it all manually.

If you are doing it at boot time as Id expect then you may need to - the SMP
code for bootstrapping has to do pte stuff itself for the same reason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
