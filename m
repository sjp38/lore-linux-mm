Message-ID: <XFMail.20000128144037.gale@syntax.dera.gov.uk>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
In-Reply-To: <E12ECQo-0004s2-00@the-village.bc.nu>
Date: Fri, 28 Jan 2000 14:40:37 -0000 (GMT)
From: Tony Gale <gale@syntax.dera.gov.uk>
Subject: Re: [PATCH] boobytrap for 2.2.15pre5
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: " (Linux MM)" <linux-mm@kvack.org>, " (Rik van Riel)" <riel@nl.linux.org>
List-ID: <linux-mm.kvack.org>

On 28-Jan-2000 Alan Cox wrote:
>> c014d30c T sk_alloc
>> c014db40 T alloc_skb
>> c014dd04 T skb_clone
> 
> That path is easy - tcp_connect(). Looks like NFS is being naughty

I don't have NFS compiled in. This is, afterall, part of
my firewall :-)

-tony



---
E-Mail: Tony Gale <gale@syntax.dera.gov.uk>
Reporter, n.:
	A writer who guesses his way to the truth and dispels it with a
	tempest of words.
		-- Ambrose Bierce, "The Devil's Dictionary"

The views expressed above are entirely those of the writer
and do not represent the views, policy or understanding of
any other person or official body.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
