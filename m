Subject: Re: kernel hangs in 118th call to vmalloc
References: <3B8FDA36.5010206@interactivesi.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 08 Sep 2001 12:30:41 -0600
In-Reply-To: <3B8FDA36.5010206@interactivesi.com>
Message-ID: <m1ae05h6we.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Timur Tabi <ttabi@interactivesi.com> writes:

> I'm writing a driver for the 2.4.2 kernel.  I need to use this kernel because
> this driver needs to be compatible with a stock Red Hat system. Patches to the
> kernel are not an option.
> 
> The purpose of the driver is to locate a device that exists on a specific memory
> 
> chip.  To help find it, I've written this routine:

What is wrong with using SPD to detect interesting properties of
memory chips?  That should be safer and usually easier then what you
are trying now. 

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
