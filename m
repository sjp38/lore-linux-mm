Received: from Galois.suse.de (Galois.suse.de [195.125.217.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA03982
	for <linux-mm@kvack.org>; Wed, 17 Dec 1997 09:22:45 -0500
Date: Wed, 17 Dec 1997 15:14:32 +0100
Message-Id: <199712171414.PAA22677@boole.fs100.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <19971216214115.05614@Elf.mj.gts.cz> (message from Pavel Machek
	on Tue, 16 Dec 1997 21:41:15 +0100)
Subject: Re: Memory usage maps into /proc/memmap and /proc/mempages
Sender: owner-linux-mm@kvack.org
To: pavel@Elf.mj.gts.cz
Cc: linux-kernel@vger.rutgers.edu, mj@atrey.karlin.mff.cuni.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> 
> Hi!
> 
> Marnix Coppens presented stand-alone module usable for listing memory
> usage in very nice way. I think that this is really nice, that it
> could be simply compiled into kernel, and maybe even merged into
> official tree. What do you think? (I did not make it CONFIG_
> option. Do you think that it should be?)
> 
> 								Pavel


These two entries a really worth to go into kernel with a (config)
option for kernel hackers.  But one thing is still missed ... I would
like to see the order of the pages or the page clusters.  This would
be a glassy memory mapping :-)



            Werner
