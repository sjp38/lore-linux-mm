Date: Thu, 4 Jul 2002 23:52:32 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: vm lock contention reduction
Message-ID: <20020704235232.A24688@redhat.com>
References: <3D2501FA.4B14EB14@zip.com.au> <Pine.LNX.4.44L.0207042315560.6047-100000@imladris.surriel.com> <3D250A47.DEF108DA@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D250A47.DEF108DA@zip.com.au>; from akpm@zip.com.au on Thu, Jul 04, 2002 at 07:53:59PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 04, 2002 at 07:53:59PM -0700, Andrew Morton wrote:
> Or provide a non-blocking try_to_submit_bio() for pdflush.

Ooooh, I need that too. =-)

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
