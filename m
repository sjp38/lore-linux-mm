Date: Tue, 17 Aug 1999 14:37:29 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <Pine.LNX.4.10.9908162324001.1048-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.9908171435340.414-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 1999, Linus Torvalds wrote:

>I'd like you to do the above cleanup, and then the bigmem patches look
>like they could easily be integrated into the current 2.3.x series. But
>with #ifdef's it won't.

Fine ;)). I'll do the cleanup and I'll give you a new patch without the
#ifdef in the common code (all other archs will have to #define some noop
as well then of course).

Thanks.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
