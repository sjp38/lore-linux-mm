Date: Mon, 5 Mar 2001 10:49:53 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] count for buffer IO in page_launder()
Message-ID: <20010305104953.C1303@redhat.com>
References: <20010302171020.W28854@redhat.com> <Pine.LNX.4.21.0103030133440.1033-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0103030133440.1033-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Sat, Mar 03, 2001 at 01:52:19AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Mar 03, 2001 at 01:52:19AM -0300, Marcelo Tosatti wrote:
> 
> On Fri, 2 Mar 2001, Stephen C. Tweedie wrote:
> 
> > Have you done an performance testing on it?
> 
> No. The code makes sense now.

The development of the VM has been _full_ of well-intended,
well-reasoned patches which failed to work properly for subtle
reasons.  I despair of us ever getting the 2.4 VM right as long as
people think it's safe to submit VM patches without even basic
performance testing.

This isn't an experimental kernel.  It's supposed to be a stable
branch.

Cheers,
 Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
