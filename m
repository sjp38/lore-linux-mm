Date: Wed, 9 Oct 2002 20:19:28 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 2.5.41-mm1] new snapshot of shared page tables
Message-ID: <20021010031928.GT12432@holomorphy.com>
References: <228900000.1034197657@baldur.austin.ibm.com> <200210092304.47577.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <200210092304.47577.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 09, 2002 at 11:04:47PM -0400, Ed Tomlinson wrote:
> After realizing (thanks Dave) that kmail 3.03 has a bug saving
> multipart/mixed mime messages, I was able to use uudeview to extract
> a clean patch, and build kernel which boot fine.  Thats the good news.
> When I try to start kde 3.03 on an up to date debian sid (X 4.2 etc)
> kde fails to start. It complains that ksmserver cannot be started.
> Same setup works with 41-mm1.
> Know this is not a meaty report.  With X4.2 I have not yet figgered
> out how to get more debug messages (the log from xstart is anemic)
> nor is there anything in messages, kern.log or on the serial console.
> The box is a K6-III 400 on a via MVP3 chipset.
> What other info can I gather?
> Ed Tomlinson

Could you strace ksmserver on a working and non-working console and
(privately) send (probably large) logs to dmc & me? Please use
strace -f -ff or some equivalent that follows children.

I'll try to reproduce something locally.


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
