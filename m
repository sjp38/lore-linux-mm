Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
References: <200003062301.PAA11473@google.engr.sgi.com>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 08 Mar 2000 13:02:51 +0100
In-Reply-To: kanoj@google.engr.sgi.com's message of "Mon, 6 Mar 2000 15:01:43 -0800 (PST)"
Message-ID: <qww7lfdr7o4.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Ingo Molnar <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

Hi Kanoj,

kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:
> > To make this work for shared anonymous pages, we need two changes
> > to the swap cache.  We need to teach the swap cache about writable
> > anonymous pages, and we need to be able to defer the physical
> > writing of the page to swap until the last reference to the swap
> > cache frees up the page.  Do that, and shared /dev/zero maps will
> > Just Work.
> 
> The current implementation of /dev/zero shared memory is to treat
> the mapping as similarly as possible to a shared memory segment. The
> common code handles the swap cache interactions, and both cases
> qualify as shared anonymous mappings. While its not well tested, in
> theory it should work. We are currently agonizing over how to
> integrate the /dev/zero code with shmfs patch.
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since this is not as easy as you thought, wouldn't it be better to do 
the /dev/zero shared maps in the swap cache instead of this workaround
over shm? Thus we would get the mechanisms to redo all shm stuff wrt
swap cache.

At the same time we would not hinder the development of normal shm
code to use file semantics (aka shm fs) which will give us posix shm.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
