From: Andreas Dilger <adilger@turbolinux.com>
Message-Id: <200106072105.f57L5HXp005687@webber.adilger.int>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.21.0106071330060.6510-100000@penguin.transmeta.com>
 "from Linus Torvalds at Jun 7, 2001 01:43:33 pm"
Date: Thu, 7 Jun 2001 15:05:16 -0600 (MDT)
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus writes:
> On Thu, 7 Jun 2001, Marcelo Tosatti wrote:
> > Who did this change to refill_inactive_scan() in 2.4.6-pre1 ? 
> 
> I think it was Andreas Dilger..

Definitely NOT.  I don't touch MM stuff.  I do filesystems and LVM only.

Cheers, Andreas
-- 
Andreas Dilger  \ "If a man ate a pound of pasta and a pound of antipasto,
                 \  would they cancel out, leaving him still hungry?"
http://www-mddsp.enel.ucalgary.ca/People/adilger/               -- Dogbert
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
