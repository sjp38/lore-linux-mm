Subject: Re: xmm2 - monitor Linux MM active/inactive lists graphically
Date: Sun, 28 Oct 2001 17:48:09 +0000 (GMT)
In-Reply-To: <Pine.LNX.4.33.0110280931590.7323-100000@penguin.transmeta.com> from "Linus Torvalds" at Oct 28, 2001 09:34:31 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15xu2b-0008QL-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Does the -ac patches have any hpt366-specific stuff? Although I suspect
> you're right, and that it's just the driver (or controller itself) being

The IDE code matches between the two. It isnt a driver change


Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
