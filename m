Subject: Re: [PATCH] Prevent OOM from killing init
Date: Thu, 22 Mar 2001 22:52:09 +0000 (GMT)
In-Reply-To: <20010322230041.A5598@win.tue.nl> from "Guest section DW" at Mar 22, 2001 11:00:41 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14gDwB-0003Tj-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Guest section DW <dwguest@win.tue.nl>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephen Clouse <stephenc@theiqgroup.com>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > Eventually you have to kill something or the machine deadlocks.
> 
> Alan, this is a fake argument.

No it is not.

> You see, the bug is that malloc does not fail. This means that the
> decisions about what to do are not taken by the program that knows
> what it is doing, but by the kernel.

Even if malloc fails the situation is no different. You can do 
overcommit avoidance in Linux if you are bored enough to try it. I did it
in 1.2 one afternoon when bored. You simply account address space. Almost
everything you need to touch is in mm/*.c and localised. The only exception
is ptrace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
