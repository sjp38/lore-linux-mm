From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14199.63731.189456.865467@dukat.scot.redhat.com>
Date: Mon, 28 Jun 1999 23:36:35 +0100 (BST)
Subject: Re: filecache/swapcache questions
In-Reply-To: <199906211846.LAA91751@google.engr.sgi.com>
References: <14190.31543.461985.372712@dukat.scot.redhat.com>
	<199906211846.LAA91751@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 21 Jun 1999 11:46:27 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

>> Look no further than swap_in(), which knows that there is no pte (so
>> swapout concurrency is not a problem) and it holds the mmap lock (so
>> there are no concurrent swap_ins on the page).  It reads in the page adn
>> unconditionally sets up the pte to point to it, assuming that nobody
>> else can conceivably set the pte while we do the swap outselves.

> Hmm, am I being fooled by the comment in swap_in?

> /*
>  * The tests may look silly, but it essentially makes sure that
>  * no other process did a swap-in on us just as we were waiting.
>  *

afaik only swapoff can trigger that.  Concurrent swap-in on the same
entry can occur into the page cache, but not into the page tables
because those are protected by the semaphore.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
