Date: Mon, 8 Jul 2002 23:32:16 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <20020709063216.GW25360@holomorphy.com>
References: <3D2A7466.AD867DA7@zip.com.au> <1221230287.1026170151@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1221230287.1026170151@[10.10.2.3]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Don't tell me those NUMAQ's are using IDE ;)
> 
> No, that's one level of pain I don't have to deal with ;-)
> 
> Now switched fibrechannel SANs on a machine that really needs
> NUMA aware multipath IO is more likely to be a problem, on 
> the other hand ... but I can live without that for now ...
> 
> > But seriously, what's the problem?  We really do need the big
> > boxes to be able to test 2.5 right now, and any blockage needs
> > to be cleared away.
> 
> You really want the current list? The whole of our team is 
> shifting focus to 2.5, which'll make life more interesting ;-)
> 
On Mon, Jul 08, 2002 at 11:15:52PM -0700, Martin J. Bligh wrote:
> wli might care to elaborate on 2 & 3, since I think he helped
> them identify / fix (helped maybe meaning did).

Oh, I forgot, there was a bad v86 info thing on the 9th cpu woken
that I never finished debugging, too. And the MAX_IO_APICS issue,
which is easily solved by just increasing the constant #ifdef
CONFIG_MULTIQUAD as usual. This panics before console_init() though,
which makes it seem more painful than it really is.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
