Message-ID: <39CF6AB8.3040604@speakeasy.org>
Date: Mon, 25 Sep 2000 08:09:44 -0700
From: Miles Lane <miles@speakeasy.org>
MIME-Version: 1.0
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu> <20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random> <20000925003650.A20748@home.ds9a.nl>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bert hubert <ahu@ds9a.nl>
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

bert hubert wrote:

> On Mon, Sep 25, 2000 at 12:13:42AM +0200, Andrea Arcangeli wrote:
> 
>> On Sun, Sep 24, 2000 at 10:43:03PM +0100, Stephen C. Tweedie wrote:
>> 
>>> any form of serialisation on the quota file).  This feels like rather
>>> a lot of new and interesting deadlocks to be introducing so late in
>>> 2.4.  :-)
>> 
> True. But they also appear to be found and solved at an impressive rate.
> These deadlocks are fatal and don't hide in corners, whereas the previous mm
> problems used to be very hard to spot and fix, there not being real
> showstoppers, except for abysmal performance. [1]
> 
> Since Rik's stuff was merged, the number of eyeball hours devoted to MM have
> skyrocketed, whereas the previous incarnations had far smaller audiences.
> The patches are barely a week in, and look how much has been improved that
> hadn't been found by the people working with Rik.
> 
> It's tempting to revert the merge, but let's work at it a bit longer. There
> are problems, but we are solving them rapidly and both performance and
> design of the new MM are pretty pleasing.
> 
> Let's not waste this opportunity.

I agree.  I have seen really fabulous system response since Rik's 
changes were merged in.
I have managed to crash my machine a couple of times (I am working on 
getting a
serial debugging connection set up, since I don't see any OOPS 
messages), but I think this
is not terribly surprising.  My impression is that system responsiveness 
is much improved.
Let's hang in there a bit longer.  We are making rapid progress on 
testing and fixing.

       Miles              

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
