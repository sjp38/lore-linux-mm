Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA29917
	for <linux-mm@kvack.org>; Wed, 24 Feb 1999 20:01:11 -0500
Date: Thu, 25 Feb 1999 01:47:58 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: PATCH - bug in vfree
In-Reply-To: <36CEA095.D5EA37B5@earthling.net>
Message-ID: <Pine.LNX.4.05.9902250142030.218-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Neil Booth <NeilB@earthling.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 20 Feb 1999, Neil Booth wrote:

>I posted this bug on the kernel mailing list last year, but it never got
>fixed, probably as I didn't include a patch. I attach a patch this time

I included it one year ago in my tree and infact if you grab my
arca-patches you'll find it again ;).

>against kernel 2.2.1. The bug is rare, but can lead to kernel virtual
>memory corruption.

Hmm, when I checked it one year ago I didn't seen a way the bug could
corrupt memory.

>More deeply:- Close inspection of get_vm_area reveals that
>(intentionally?) it does NOT insist there be a cushion page behind a VMA
>that is placed in front of a previously-allocated VMA, it ONLY

Could you explain me better? I agree that there's no good reason trying to
free the gap-faulting page, but I don't see how there couldn't be a
page-gap between two vmalloced areas.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
