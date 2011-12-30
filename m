Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 8D4256B004D
	for <linux-mm@kvack.org>; Fri, 30 Dec 2011 12:45:39 -0500 (EST)
Received: by wibhq12 with SMTP id hq12so9976092wib.14
        for <linux-mm@kvack.org>; Fri, 30 Dec 2011 09:45:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EFD6F22.5010501@monstr.eu>
References: <4EEF42F5.7040002@monstr.eu>
	<20111219162835.GA24519@google.com>
	<4EF05316.5050803@monstr.eu>
	<20111229155836.GB3516@google.com>
	<4EFC995A.5090904@monstr.eu>
	<20111229170745.GE3516@google.com>
	<4EFD6F22.5010501@monstr.eu>
Date: Sat, 31 Dec 2011 02:45:37 +0900
Message-ID: <CAOS58YPtNRK3mhAp26585+nWFL44kghfAh8vfiB=kdEYmn_8bg@mail.gmail.com>
Subject: Re: memblock and bootmem problems if start + size = 4GB
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: monstr@monstr.eu
Cc: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello,

On Fri, Dec 30, 2011 at 4:58 PM, Michal Simek <monstr@monstr.eu> wrote:
> I haven't said to replace phys_addr_t!
> My point was something like this (just as example on parisc and
> free_bootmem_node).
> The problematic part is kmemleak code which could be good reason not to
> change it.

I think it's still a bad idea and you haven't provided any
justification for it.  Think about it - any user which uses pa() may
get that last page and if that user is using [start,end) range, it may
overflow.  It doesn't even matter how you implement it.  I just can't
understand why you obsess about that last page.  It doesn't matter.
Just add those few lines to exclude the last single page and be done
with it.  Unless you're gonna provide rationale for why adding such
risk and more complexity makes sense for that single last page which
most BIOSes wouldn't even map, I don't really think this thread is
going anywhere.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
