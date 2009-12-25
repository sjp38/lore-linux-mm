Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BC85D620002
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 14:18:57 -0500 (EST)
Date: Fri, 25 Dec 2009 20:18:49 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Tmem [PATCH 0/5] (Take 3): Transcendent memory
Message-ID: <20091225191848.GB8438@elf.ucw.cz>
References: <d760cf2d0912222228y3284e455r16cdb2bfd2ecaa0e@mail.gmail.com>
 <ff435130-98a2-417c-8109-9dd029022a91@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ff435130-98a2-417c-8109-9dd029022a91@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, chris.mason@oracle.com, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed 2009-12-23 09:15:27, Dan Magenheimer wrote:
> > As I mentioned, I really like the idea behind tmem. All I am proposing
> > is that we should probably explore some alternatives to achive this using
> > some existing infrastructure in kernel.
> 
> Hi Nitin --
> 
> Sorry if I sounded overly negative... too busy around the holidays.
> 
> I'm definitely OK with exploring alternatives.  I just think that
> existing kernel mechanisms are very firmly rooted in the notion
> that either the kernel owns the memory/cache or an asynchronous
> device owns it.  Tmem falls somewhere in between and is very

Well... compcache seems to be very similar to preswap: in preswap case
you don't know if hypervisor will have space, in ramzswap you don't
know if data are compressible.

									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
