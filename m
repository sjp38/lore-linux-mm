Message-Id: <200001041719.JAA03724@icarus.com>
Subject: Re: vm_operations (was: Re: release not called for my driver?) 
In-Reply-To: Message from Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
   of "Tue, 04 Jan 2000 08:35:34 +0100." <Pine.LNX.4.10.10001040816410.8982-100000@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Tue, 04 Jan 2000 09:19:12 -0800
From: Stephen Williams <steve@icarus.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Linux Kernel Development <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

As far as I can tell, the Linux kernel device driver interface is very
poorly documented. The Rubinni book is as close as one gets to documentation,
but that does not cover much of vm behavior, and certainly doesn't cover
the cases you and I are handling.

Example code may well be the best documentation (thanks, Alan) but a
driver for a complex dvice can get a bit opaque and what are really needed
are contrived and heavily commented examples.

Oh well, Linux drivers are part of my job description so I do have the
time to figure things out. It just would be nice if the people who add these
nifty-neato interfaces in the kernel actually took the time to describe
them.
-- 
Steve Williams                "The woods are lovely, dark and deep.
steve@icarus.com              But I have promises to keep,
steve@picturel.com            and lines to code before I sleep,
http://www.picturel.com       And lines to code before I sleep."


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
