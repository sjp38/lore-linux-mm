Date: Tue, 27 Jun 2000 04:26:42 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: RSS guarantees and limits
Message-ID: <20000627042642.D1065@redhat.com>
References: <Pine.LNX.4.21.0006211059410.5195-100000@duckman.distro.conectiva> <m2lmzx38a1.fsf@boreas.southchinaseas> <20000622221923.A8744@redhat.com> <m2og4t9w7j.fsf@boreas.southchinaseas> <20000624192245.A6617@saw.sw.com.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000624192245.A6617@saw.sw.com.sg>; from saw@saw.sw.com.sg on Sat, Jun 24, 2000 at 07:22:45PM +0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrey Savochkin <saw@saw.sw.com.sg>
Cc: John Fremlin <vii@penguinpowered.com>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Jun 24, 2000 at 07:22:45PM +0800, Andrey Savochkin wrote:
> 
> Small applications are not always good, as well as big are not bad.
> We just want good memory service for those applications which we want to have
> it :-)  It hears like tautology, but that it.  It's completely administrator
> policy decision.

Somewhat, but not entirely.

Remember that we were talking about both RSS limits and RSS guarantees
being dymamic.  RSS guarantees for small processes (based on their
fault activity, of course, so that idle small tasks can still be
swapped out) are perhaps dependent on what those tasks are actually
doing if the object is to have them compete against each other more
fairly.

However, RSS limits on the largest tasks in the system have an
entirely different effect --- they prevent swap storms from
overwhelming small tasks entirely, by placing more of the burden of
the swapping on the large task.

If a task is so large that it is thrashing, then removing a few 100K
from its RSS doesn't usually have all that a dramatic effect on its
performance.  Remember, we'll only be doing this pruning if there is
continuing memory pressure.  If that large task becomes the only task
wanting more memory again, we can let its RSS limit creep up again.
That way, processes which just fit into memory on an idle system will
continue to work just fine, but once we get memory contention, they
won't stop the rest of the system from getting going again.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
