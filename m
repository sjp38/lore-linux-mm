From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003062301.PAA11473@google.engr.sgi.com>
Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
Date: Mon, 6 Mar 2000 15:01:43 -0800 (PST)
In-Reply-To: <14532.13432.760022.313353@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Mar 06, 2000 10:43:04 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> To make this work for shared anonymous pages, we need two changes to the
> swap cache.  We need to teach the swap cache about writable anonymous
> pages, and we need to be able to defer the physical writing of the page
> to swap until the last reference to the swap cache frees up the page.
> Do that, and shared /dev/zero maps will Just Work.
>

The current implementation of /dev/zero shared memory is to treat the
mapping as similarly as possible to a shared memory segment. The common
code handles the swap cache interactions, and both cases qualify as shared
anonymous mappings. While its not well tested, in theory it should work. 
We are currently agonizing over how to integrate the /dev/zero code with 
shmfs patch.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
