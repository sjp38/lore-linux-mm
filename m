Received: from mail.wol.dk (mail01s.image.dk [212.54.64.152])
	by kvack.org (8.8.7/8.8.7) with SMTP id LAA18439
	for <linux-mm@kvack.org>; Fri, 21 May 1999 11:14:12 -0400
Message-ID: <19990521165432.A13600@arbat.com>
Date: Fri, 21 May 1999 16:54:32 +0200
From: Erik Corry <erik@arbat.com>
Subject: Re: Assumed Failure rates in Various o.s's ?
References: <19990521120725.A581384@daimi.au.dk> <Pine.LNX.3.95.990521101041.17710A-100000@as200.spellcast.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.990521101041.17710A-100000@as200.spellcast.com>; from Benjamin C.R. LaHaise on Fri, May 21, 1999 at 10:25:42AM -0400
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, ak-uu@muc.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 21, 1999 at 10:25:42AM -0400, Benjamin C.R. LaHaise wrote:
> On Fri, 21 May 1999, Erik Corry wrote:
> 
> > According to Andi you already fixed this with a read lock that
> > prevents mmap and mmunmap from doing anything while the copy
> > is running.  This makes sense, since if you do it right with a
> > readers/writers lock you can keep out mmap without serialising
> > copy_to_user or copy_from_user.
> 
> I really like the cleanliness of this approach, but it's troublesome:
> memory allocations in other threads would then get blocked during large
> IOs -- very bad.

Actually, isn't it just munmap that is problematic?

After the access_ok you can't map a read-only file into the
path of an oncoming copy_to_user without first unmapping
what was there before (this is assuming a version of
access_ok that checks whether something was mapped).
So mmaps can safely happen in parallel with copy_to_user.

-- 
Erik Corry erik@arbat.com           Ceterum censeo, Microsoftem esse delendam!
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
