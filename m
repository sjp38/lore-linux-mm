Subject: Re: [PATCH] 2.3.99-pre6-7 VM rebalanced
Date: Sun, 30 Apr 2000 16:18:09 +0100 (BST)
In-Reply-To: <Pine.LNX.4.10.10004300357400.4270-100000@iq.rulez.org> from "Sasi Peter" at Apr 30, 2000 04:01:53 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E12lvU3-0008Ki-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sasi Peter <sape@iq.rulez.org>
Cc: riel@nl.linux.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> The problem with this is that even if the kernel is in .99 pre-release
> state for several weeks _nothing_ has been changed in it about the RAID
> stuff still, so a lot of people using 2.2 + raid 0.90 patch (eg. RedHat
> users) _cannot_ change to and try 2.3.99, because their partitions would
> not mount.
> 
> It seems to me, that if we are talking about widening the testbase for
> 2.3.99, this is the most important item on Alan's todo list.

In some ways it probably is. Almost every production site I would feed stuff
to is using raid 0.90 and some of them are now using ext3 as well. 

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
