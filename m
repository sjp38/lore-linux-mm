From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14518.22746.519992.127418@dukat.scot.redhat.com>
Date: Fri, 25 Feb 2000 10:26:34 +0000 (GMT)
Subject: Re: [PATCH] kswapd performance fix
In-Reply-To: <Pine.LNX.4.10.10002250026040.1385-100000@mirkwood.dummy.home>
References: <Pine.LNX.4.10.10002250026040.1385-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, "Stephen Tweedie <sct@redhat.com> Linux Kernel" <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 25 Feb 2000 00:30:59 +0100 (CET), Rik van Riel
<riel@nl.linux.org> said:

> The patch should apply to any 2.2 or 2.3 kernel, but for
> 2.3 it'll have the interesting side effect of nullifying
> the (minimal) page aging that's going on there.

Have you actually tested the impact of this under a variety of load
conditions?  In the past we have seen such apparently trivial changes
completely break the VM balance under certain loads.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
