Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA24139
	for <linux-mm@kvack.org>; Mon, 31 May 1999 20:19:24 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14163.9991.453537.358805@dukat.scot.redhat.com>
Date: Tue, 1 Jun 1999 01:19:19 +0100 (BST)
Subject: Re: Application load times
In-Reply-To: <Pine.LNX.3.96.990531203217.18436A-100000@ferret.lmh.ox.ac.uk>
References: <199905311911.PAA13206@bucky.physics.ncsu.edu>
	<Pine.LNX.3.96.990531203217.18436A-100000@ferret.lmh.ox.ac.uk>
Sender: owner-linux-mm@kvack.org
To: Matthew Kirkwood <weejock@ferret.lmh.ox.ac.uk>
Cc: Emil Briggs <briggs@bucky.physics.ncsu.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 31 May 1999 20:33:54 +0100 (GMT), Matthew Kirkwood
<weejock@ferret.lmh.ox.ac.uk> said:

> Drop something bigger into /proc/sys/vm/page-cluster on bootup.

> I don't know how much bigger, but I suspect that 16 or 32 (4k pages)
> should improve matters on a lightly loaded 64Mb machine.

16 is the default.  The /proc number is interpreted as a power-of-two. 

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
