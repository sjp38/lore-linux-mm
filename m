Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
From: Paul Larson <plars@austin.ibm.com>
In-Reply-To: <20020722225251.GG919@holomorphy.com>
References: <Pine.LNX.4.44L.0207221704120.3086-100000@imladris.surriel.com>
	<1027377273.5170.37.camel@plars.austin.ibm.com>
	<20020722225251.GG919@holomorphy.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 23 Jul 2002 12:40:43 -0500
Message-Id: <1027446044.7699.15.camel@plars.austin.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 2002-07-22 at 17:52, William Lee Irwin III wrote:
> ISTR this compiler having code generation problems. I think trying to
> reproduce this with a working i386 compiler is in order, e.g. debian's
> 2.95.4 or some similarly stable version.
That's exactly the one I was planning on trying it with.  Tried it this
morning with the same error.  Three compilers later, I think this is
looking less like a compiler error.  Any ideas?

-Paul Larson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
