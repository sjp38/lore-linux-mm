Date: Fri, 28 Jan 2000 15:09:48 +0300
From: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Subject: Re: 2.2.15pre4 VM fix
Message-ID: <20000128150948.A3816@jurassic.park.msu.ru>
References: <Pine.LNX.4.10.10001260118220.1373-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10001260118220.1373-100000@mirkwood.dummy.home>; from riel@nl.linux.org on Wed, Jan 26, 2000 at 01:20:48AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 26, 2000 at 01:20:48AM +0100, Rik van Riel wrote:
> 
> Please give this patch (against 2.2.15pre4) a solid beating
> and report back to us. Thanks all!
> 

n_tty_open() has been caught with your patch.
Thanks!

Ivan.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
