Subject: Re: rmap for 2.4.19-strict-vm-overcommit?
From: Robert Love <rml@tech9.net>
In-Reply-To: <20021026160534.26faec56.shahamit@gmx.net>
References: <20021025185438.69ca2c1a.shahamit@gmx.net>
	<Pine.LNX.4.44L.0210251349570.1995-100000@imladris.surriel.com>
	<20021026160534.26faec56.shahamit@gmx.net>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 26 Oct 2002 13:37:26 -0400
Message-Id: <1035653847.730.7559.camel@phantasy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Amit Shah <shahamit@gmx.net>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2002-10-26 at 06:35, Amit Shah wrote:

> I would've liked if I got a separate patch that I could apply against my
> 2.4.19-overcommit.

I have a 2.4.19-pre7 + rmap patch.  I do not know how easily it will
apply to 2.4.19 and current rmap but it should go pretty good.

	http://www.kernel.org/pub/linux/kernel/people/rml/vm/strict-overcommit/v2.4/vm-strict-overcommit-rml-2.4.19-pre7-rmap-1.patch

> Also: any indications that overcommit and/or rmap might be included in the
> standard 2.4 kernel?

Probably no to both.  If you want them, they are both in 2.4-ac and 2.5.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
