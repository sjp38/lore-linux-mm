Date: Mon, 22 Jul 2002 17:37:04 -0600 (MDT)
From: Thunder from the hill <thunder@ngforever.de>
Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
In-Reply-To: <1027383490.32299.94.camel@irongate.swansea.linux.org.uk>
Message-ID: <Pine.LNX.4.44.0207221735190.3309-100000@hawkeye.luckynet.adm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Paul Larson <plars@austin.ibm.com>, Rik van Riel <riel@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

Hi,

On 23 Jul 2002, Alan Cox wrote:
> egcs-1.1.2 does have real problems with 2.5
> 
> 7.1 errata/7.2/7.3 gcc 2.96 appear quite happy

So what compiler could I use on my sparc64? IIRC, the current gcc versions 
failed to make up clean bytecode, and the older versions fail to deal with 
newer code...

I've seen the gcc 3.1 test report from Dave Miller, and I knew it could be 
nasty times if I try to get used to it...

							Regards,
							Thunder
-- 
(Use http://www.ebb.org/ungeek if you can't decode)
------BEGIN GEEK CODE BLOCK------
Version: 3.12
GCS/E/G/S/AT d- s++:-- a? C++$ ULAVHI++++$ P++$ L++++(+++++)$ E W-$
N--- o?  K? w-- O- M V$ PS+ PE- Y- PGP+ t+ 5+ X+ R- !tv b++ DI? !D G
e++++ h* r--- y- 
------END GEEK CODE BLOCK------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
