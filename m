From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14199.62101.566519.64494@dukat.scot.redhat.com>
Date: Mon, 28 Jun 1999 23:09:25 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <199906281955.MAA06984@google.engr.sgi.com>
References: <Pine.BSO.4.10.9906281530400.24888-100000@funky.monkey.org>
	<199906281955.MAA06984@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Chuck Lever <cel@monkey.org>, andrea@suse.de, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 12:55:23 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> Agreed this would be a nice thing to be able to do ...  Other than the
> deadlock problem, there's another issue involved, I think. Processes
> can go to sleep (inside drivers/fs for example while
> mmaping/munmaping/faulting) holding their mmap_sem, so any solution
> should be able to guarantee that (at least one of) the memory free'ers
> do not go to sleep indefinitely (or for some time that is upto
> driver/fs code to determine).

Which is why we don't take the mm semaphore in swapout.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
