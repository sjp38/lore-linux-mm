Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0B3FD6B0095
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 11:49:44 -0500 (EST)
Date: Mon, 13 Dec 2010 08:49:25 -0800
From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: 2.6.36.2 reliably panics in VFS
Message-ID: <20101213164925.GB23870@xanatos>
References: <20101212113004.94FA96FD97@nx.neverkill.us>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101212113004.94FA96FD97@nx.neverkill.us>
Sender: owner-linux-mm@kvack.org
To: Peter Steiner <sp@med-2-med.com>
Cc: viro@zeniv.linux.org.uk, linux-mm@kvack.org, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Sun, Dec 12, 2010 at 12:26:48PM +0100, Peter Steiner wrote:
> Hi
> 
> compiled latest 2.6.36.2 but it reliably panics() my machine.
> It happens if I try to dd sda to sdb (backup) using xhci USB3.0
> (conceptronic CUSB3EXC) but ALSO using native USB 2.0 ports on the
> machine - after 10-15 minutes of dd.

Can you run lspci -v and lsusb?  I'm wondering if the USB 2.0 ports are
part of an EHCI host controller or an xHCI host controller.

> Please see attached screenshot (I cannot copy it as text as it takes
> down the machine and locks up in text console, so I can only make a
> foto).

Can you run netconsole to capture more of the messages before that?  If
you need help with setting up netconsole, see:
	http://sarah.thesharps.us/2010-03-26-09-41

> see attached .config.
> 
> The bug did NOT happen on 2.6.35.7 - however there the USB3.0 xhci
> frequently disconnects the sdb backup disk and dd fails after 400GB of
> copy or so (but no panic).

Would this happen to be on a Lenovo W510 laptop?  I've received reports
of different oopses caused by disconnects, while running 2.6.35.8:

http://marc.info/?l=linux-kernel&m=129131271416325&w=2

Do you see panics or oopses when you run 2.6.35.8?  Or did you just
upgrade straight from 2.6.35.7 to 2.6.36.2?

Sarah Sharp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
