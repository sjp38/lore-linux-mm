Date: Wed, 24 Jan 2001 12:50:38 -0600
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <3A6F22D7.3000709@valinux.com>
References: <20010124174824Z129401-18594+948@vger.kernel.org>
Subject: Re: Page Attribute Table (PAT) support?
Message-Id: <20010124184751Z131205-224+36@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Jeff Hartmann <jhartmann@valinux.com> on Wed, 24 Jan
2001 11:45:43 -0700


> I'm actually writing support for the PAT as we speak.  I already have 
> working code for PAT setup.  Just having a parameter for ioremap is not 
> enough, unfortunately.  According to the Intel Architecture Software 
> Developer's Manual we have to remove all mappings of the page that are 
> cached.  Only then can they be mapped with per page write combining.  I 
> should have working code by the 2.5.x timeframe.  I can also discuss the 
> planned interface if anyone is interested.

I'm interested.  Would it be possible to port this support to 2.2, or would
that be too much work?


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
