Date: Wed, 30 May 2001 23:48:06 +0200
From: bert hubert <ahu@ds9a.nl>
Subject: Re: http://ds9a.nl/cacheinfo project - please comment & improve
Message-ID: <20010530234806.C8629@home.ds9a.nl>
References: <20010527222020.A25390@home.ds9a.nl> <Pine.LNX.4.21.0105301648290.5231-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0105301648290.5231-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Wed, May 30, 2001 at 04:54:12PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 30, 2001 at 04:54:12PM -0300, Marcelo Tosatti wrote:

> You're using the "address_space->dirty_pages" list to calculate the number
> of dirty pages.

I was wondering about that. In limited testing I've never seen a non-0
content of the dirty list. I ran:

dd if=/dev/zero of=test count=100000 &
while true ; do ./cinfo test; done

And saw no dirty pages. 

> So I suggest you to check for the PG_dirty (with the PageDirty macro) bit
> on pages of that list to know if they are really dirty. 

Ok - will do. I plan to release a slightly improved version shortly that
addresses this issue. Thanks!

Oh, if anybody has ideas on statistics that should be exported, please let
me know. On the agenda is a bitmap that describes which pages are actually
in the cache.

Regards,

bert

-- 
http://www.PowerDNS.com      Versatile DNS Services  
Trilab                       The Technology People   
'SYN! .. SYN|ACK! .. ACK!' - the mating call of the internet
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
