Message-ID: <396F0E1D.AE1C4D27@uow.edu.au>
Date: Fri, 14 Jul 2000 22:57:01 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: vmtruncate question
References: <396BCFA8.C033D94A@uow.edu.au>,
            <396BCFA8.C033D94A@uow.edu.au>; from andrewm@uow.edu.au on Wed,
            Jul 12, 2000 at 01:53:44AM +0000 <20000714111802.R3113@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Wed, Jul 12, 2000 at 01:53:44AM +0000, Andrew Morton wrote:
> > The flushes which surround the second call to zap_page_range()
> > would appear to be flushing more memory than is to be
> > zapped.  Is this correct, or should it be:
> 
> Yes, I noticed that too: I think you're right.

OK, thanks.  I'll implement this in the changes which are part of the
low-lat patch and send it off to LT tonight.  If he says "no
low-latency" then I'll make sure this issue isn't forgotten about.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
