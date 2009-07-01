Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 23F5D6B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 04:04:33 -0400 (EDT)
Date: Wed, 1 Jul 2009 10:04:32 +0200
From: Attila Kinali <attila@kinali.ch>
Subject: Re: Long lasting MM bug when swap is smaller than RAM
Message-Id: <20090701100432.2d328e46.attila@kinali.ch>
In-Reply-To: <4A4ABD8F.40907@gmail.com>
References: <20090630115819.38b40ba4.attila@kinali.ch>
	<4A4ABD8F.40907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robert Hancock <hancockrwd@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jun 2009 19:36:15 -0600
Robert Hancock <hancockrwd@gmail.com> wrote:

> On 06/30/2009 03:58 AM, Attila Kinali wrote:
> > Moin,
> >
> > There has been a bug back in the 2.4.17 days that is somehow
> > triggered by swap being smaller than RAM, which i thought had
> > been fixed long ago, reappeared on one of the machines i manage.
> >
> > <history>
> 
> It's quite unlikely what you are seeing is at all related to that 
> problem. The VM subsystem has been hugely changed since then.

That's why i thought this problem was fixed.

> You didn't post what the swap usage history before the upgrade was. 

Because i don't have any hard data on this. I checked it by hand
from time to time and we never had more than a few MB of swap used.

> But 
> swapping does not only occur if memory is running low. If disk usage is 
> high then non-recently used data may be swapped out to make more room 
> for disk caching.

Hmm..I didn't know this.. thanks!

 
> Also, by increasing memory from 2GB to 6GB on a 32-bit kernel, some 
> memory pressure may actually be increased since many kernel data 
> structures can only be in low memory (the bottom 896MB).

Interesting. But shouldnt memory be "swapped" to highmem first
before going out onto disk?

> The more that 
> the system memory is increased the more the pressure on low memory can 
> become. Using a 64-bit kernel avoids this problem.

Unfortunately, the CPU we have is still a pure 32bit CPU, so this option
cannot be used.

			Attila Kinali

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
