Date: Tue, 23 Jul 2002 10:49:42 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
Message-ID: <20020723174942.GL919@holomorphy.com>
References: <Pine.LNX.4.44L.0207221704120.3086-100000@imladris.surriel.com> <1027377273.5170.37.camel@plars.austin.ibm.com> <20020722225251.GG919@holomorphy.com> <1027446044.7699.15.camel@plars.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <1027446044.7699.15.camel@plars.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@austin.ibm.com>
Cc: Rik van Riel <riel@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 2002-07-22 at 17:52, William Lee Irwin III wrote:
>> ISTR this compiler having code generation problems. I think trying to
>> reproduce this with a working i386 compiler is in order, e.g. debian's
>> 2.95.4 or some similarly stable version.

On Tue, Jul 23, 2002 at 12:40:43PM -0500, Paul Larson wrote:
> That's exactly the one I was planning on trying it with.  Tried it this
> morning with the same error.  Three compilers later, I think this is
> looking less like a compiler error.  Any ideas?

Stands a good chance of being fixed by the recent rmap.c bugfix posted
by Rik. I'm seeing deadlocks every other boot over here, the cause of
which I've not yet been able to discover.

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
