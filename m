Subject: Re: [PATCH] Recent VM fiasco - fixed
References: <Pine.LNX.4.21.0005081544360.20958-100000@duckman.conectiva>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 08 May 2000 20:53:31 +0200
In-Reply-To: Rik van Riel's message of "Mon, 8 May 2000 15:46:09 -0300 (BRST)"
Message-ID: <dnhfc8yitw.fsf@magla.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> 20MB and 24MB machines will be in the same situation, if
> that's of any help to you ;)
> 

Yes, you are right. And thanks for that tip (booting with mem=24m)
because that will be my first test case later tonight.

> > But after few hours spent dealing with the horrible VM that is
> > in the pre6, I'm not scared anymore. And I think that solution
> > to all our problems with zone balancing must be very simple.
> 
> It is. Linus is working on a conservative & simple solution
> while I'm trying a bit more "far-out" code (active and inactive
> list a'la BSD, etc...). We should have at least one good VM
> subsystem within the next few weeks ;)
> 

Nice. I'm also in favour of some kind of active/inactive list
solution (looks promising), but that is probably 2.5.x stuff.

I would be happy to see 2.4 out ASAP. Later, when it stabilizes, we
will have lots of fun in 2.5, that's for sure.

Regards,
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
