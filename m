Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA03343
	for <linux-mm@kvack.org>; Wed, 12 May 1999 14:36:57 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14137.51764.951033.152486@dukat.scot.redhat.com>
Date: Wed, 12 May 1999 19:36:36 +0100 (BST)
Subject: Re: Swap Questions (includes possible bug) - swapfile.c / swap.c
In-Reply-To: <003f01be9c62$75765550$c80c17ac@clmsdev.local>
References: <003f01be9c62$75765550$c80c17ac@clmsdev.local>
Sender: owner-linux-mm@kvack.org
To: Manfred Spraul <masp0008@stud.uni-sb.de>
Cc: Rik van Riel <riel@nl.linux.org>, Joseph Pranevich <knight@baltimore.wwaves.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 12 May 1999 12:30:27 +0200, "Manfred Spraul"
<masp0008@stud.uni-sb.de> said:

> There is another problem with this line:
> set_blocksize() also means that the previous block size
> doesn't work anymore:
> if you accidentially enter 'swapon /dev/hda1' (my root drive)
> instead of 'swapon /dev/hda3', then you have to fsck:

Yep, it would make perfect sense to move the set_blocksize to be after
the EBUSY check.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
