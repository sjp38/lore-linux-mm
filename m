Message-ID: <20010720184806.50078.qmail@web14311.mail.yahoo.com>
Date: Fri, 20 Jul 2001 11:48:06 -0700 (PDT)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: Support for Intel 4MB Pages
In-Reply-To: <20010720203820.A16411@caldera.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@ns.caldera.de>, Timur Tabi <ttabi@interactivesi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I did some initial work on this previously. Some of
it is stored at

 http://reality.sgi.com/kanoj_engr/lpage.html

David Miller also tried out certain things to do with
large pages.

Kanoj

--- Christoph Hellwig <hch@ns.caldera.de> wrote:
> On Fri, Jul 20, 2001 at 01:32:20PM -0500, Timur Tabi
> wrote:
> > I thought Linux already used 4MB pages for its
> 1-to-1 kernel virtual
> > memory mapping.
> 
> Yes.   But this is only _wierd_ kernel memory, not
> general-purpose
> memory.
> 
> 	Christoph
> 
> -- 
> Whip me.  Beat me.  Make me maintain AIX.
> --
> To unsubscribe, send a message with 'unsubscribe
> linux-mm' in
> the body to majordomo@kvack.org.  For more info on
> Linux MM,
> see: http://www.linux-mm.org/


__________________________________________________
Do You Yahoo!?
Get personalized email addresses from Yahoo! Mail
http://personal.mail.yahoo.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
