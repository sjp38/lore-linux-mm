Date: Wed, 24 Jan 2001 14:30:10 -0600
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <3A6F22D7.3000709@valinux.com>
References: <20010124174824Z129401-18594+948@vger.kernel.org>
Subject: Re: Page Attribute Table (PAT) support?
Message-Id: <20010124203012Z129444-18594+1042@vger.kernel.org>
Content-Type: 
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Jeff Hartmann <jhartmann@valinux.com> on Wed, 24 Jan
2001 11:45:43 -0700


> I'm actually writing support for the PAT as we speak.  I already have 
> working code for PAT setup.  Just having a parameter for ioremap is not 
> enough, unfortunately.  According to the Intel Architecture Software 
> Developer's Manual we have to remove all mappings of the page that are 
> cached.

For our specific purposes, that's not important.  We already flush the cache
before we create uncached regions (via ioremap_nocache).  I understand that as a
general Linux feature, you can't ignore cache incoherency, but I don't think
it's a hard requirement.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
Please read the FAQ at http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
