Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA28597
	for <linux-mm@kvack.org>; Thu, 14 Jan 1999 17:43:38 -0500
Date: Thu, 14 Jan 1999 23:38:31 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.91.990114105702.20708C-100000@toaster.roan.co.uk>
Message-ID: <Pine.LNX.3.96.990114232702.640A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mike Jagdis <mike@roan.co.uk>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alessandro Suardi <asuardi@uninetcom.it>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jan 1999, Mike Jagdis wrote:

> With either the shm used is normally "large" with respect to
> available physical memory (i.e. everything that isn't needed by
> processes under your normal load) because the database engines
> use it to cache data (this is why they want raw IO - there's no
> point the OS caching the data as well).

Ah but if what you say is true the db server shm issue raised by Stephen
is completly pointless. If the shm memory is used as _cache_ for the data
there's _no_ one point to swapout it out in first place. So when using the
shm for caching purposes the db server _must_ set the SHM_LOCK flag on the
shm memory using shmctl.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
