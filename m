Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8E37F6B0036
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 14:32:45 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id lx4so1996571iec.9
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 11:32:45 -0800 (PST)
Date: Thu, 19 Dec 2013 13:35:08 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: bad page state in 3.13-rc4
Message-ID: <20131219183508.GB881@redhat.com>
References: <20131219040738.GA10316@redhat.com>
 <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com>
 <20131219155313.GA25771@redhat.com>
 <CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com>
 <20131219181134.GC25385@kmo-pixel>
 <20131219182920.GG30640@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131219182920.GG30640@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Kent Overstreet <kmo@daterainc.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

On Thu, Dec 19, 2013 at 01:29:21PM -0500, Benjamin LaHaise wrote:
 
 > > > and some kind of double free in an error path would certainly explain
 > > > this (with io_setup() . And the first oops reported obviously had that
 > > > migration thing. So maybe those "fixes" weren't fixing things at all
 > > > (or just moved the error case around).
 > > > 
 > > > Btw, that "rework aio migrate pages to use aio fs" looks odd. It has
 > > > Ben LaHaise marked as author, but no sign-off, instead "Tested-by" and
 > > > "Acked-by".
 > > 
 > > I could certainly believe a double free, but rereading the current code
 > > I can't find anything, and I just manually tested all the relevant error
 > > paths in ioctx_alloc() and aio_setup_ring() without finding anything.
 > 
 > The same here.  It would be very helpful to know what syscalls trinity is 
 > issuing in the lead up to the bug.

Working on narrowing it down.  The io_setup fuzzer is actually incredibly dumb,
and 99.9% of the time will just EFAULT or EINVAL. I'll see if I can smarten it
up to succeed more often, in the hope that it can reproduce this faster, because
right now it looks like it needs the planets to line up just right to hit
the bug (even though I've hit it twice in the last 24 hrs)

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
