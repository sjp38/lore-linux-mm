Subject: Re: page locking and error handling
References: <Pine.GSO.4.10.10102151835020.2986-100000@zeus.fh-brandenburg.de>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 15 Feb 2001 16:37:59 -0700
In-Reply-To: Roman Zippel's message of "Thu, 15 Feb 2001 19:50:09 +0100 (MET)"
Message-ID: <m1ae7n7c14.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@fh-brandenburg.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Roman Zippel <zippel@fh-brandenburg.de> writes:

> Hi,
> 
> On 15 Feb 2001, Eric W. Biederman wrote:
> 
> > > - if copy_from_user() fails the page is set as not uptodate. AFAIK this
> > >   assumes that the page->buffers are still uptodate, so previous writes
> > >   are not lost.
> > If copy_from_user fails that invokes undefined behavior, and you just lost
> > your previous writes because you ``overwrote'' them.
> 
> What about partial writes?

The important thing is if copy_from_user fails it is because of a buggy
user space app.  Because the buggy app passed a bad memory area.  So you
have undefined behavior, so you can do whatever is convenient.

The only case to worry about how do we keep from breaking kernel invariants.
I think it make break an invariant to set a mmaped page as not
uptodate, but I can't see any other problems with the interface.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
