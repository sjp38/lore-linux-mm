Date: Mon, 22 Jul 2002 15:52:51 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
Message-ID: <20020722225251.GG919@holomorphy.com>
References: <Pine.LNX.4.44L.0207221704120.3086-100000@imladris.surriel.com> <1027377273.5170.37.camel@plars.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <1027377273.5170.37.camel@plars.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@austin.ibm.com>
Cc: Rik van Riel <riel@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 2002-07-22 at 15:19, Dave Hansen wrote:
>> I was hitting the same thing on a Netfinity 8500R/x370.  The problem 
>> was an old compiler (egcs 2.91-something).  It was triggered by a few 
>> different things, including kernprof and dcache_rcu.

On Mon, Jul 22, 2002 at 05:34:32PM -0500, Paul Larson wrote:
> Well, it was a redhat box.  Just to be certain, I made sure to use kgcc
> and it still hung on boot, but kgcc is egcs-2.91.66 19990314/Linux
> (egcs-1.1.2 release).  If it would be helpful, I'll try compiling my
> kernel on a debian box tomorrow and booting with that.

ISTR this compiler having code generation problems. I think trying to
reproduce this with a working i386 compiler is in order, e.g. debian's
2.95.4 or some similarly stable version.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
