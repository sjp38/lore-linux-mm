Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
From: Paul Larson <plars@austin.ibm.com>
In-Reply-To: <1027383490.32299.94.camel@irongate.swansea.linux.org.uk>
References: <Pine.LNX.4.44L.0207221704120.3086-100000@imladris.surriel.com>
	<1027377273.5170.37.camel@plars.austin.ibm.com>
	<1027383490.32299.94.camel@irongate.swansea.linux.org.uk>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 23 Jul 2002 06:34:56 -0500
Message-Id: <1027424097.5170.43.camel@plars.austin.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 2002-07-22 at 19:18, Alan Cox wrote:
> > and it still hung on boot, but kgcc is egcs-2.91.66 19990314/Linux
> > (egcs-1.1.2 release).  If it would be helpful, I'll try compiling my
> > kernel on a debian box tomorrow and booting with that.
> 
> egcs-1.1.2 does have real problems with 2.5
> 
> 7.1 errata/7.2/7.3 gcc 2.96 appear quite happy
7.3 gcc 2.96 was the one I was originally using when I found this
problem.  I decided to go back and try kgcc just in case.  I'll try
compiling it on another machine and moving it over today.

-Paul Larson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
