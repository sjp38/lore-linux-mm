Subject: Re: [PATCH] boobytrap for 2.2.15pre5
Date: Fri, 28 Jan 2000 14:54:13 +0000 (GMT)
In-Reply-To: <XFMail.20000128144037.gale@syntax.dera.gov.uk> from "Tony Gale" at Jan 28, 2000 02:40:37 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E12ECms-0004uM-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tony Gale <gale@syntax.dera.gov.uk>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@nl.linux.org>
List-ID: <linux-mm.kvack.org>

> > That path is easy - tcp_connect(). Looks like NFS is being naughty
> 
> I don't have NFS compiled in. This is, afterall, part of
> my firewall :-)

Ok that definitely convinces me Rik's booby trap is booby trapped 8). Ive just
let Rik know why on irc, expect rev 2 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
