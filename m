Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A3DE36B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 09:58:10 -0400 (EDT)
Date: Mon, 15 Aug 2011 08:58:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Tracking page allocation in Zone/Node
In-Reply-To: <1313384511.62052.YahooMailNeo@web162020.mail.bf1.yahoo.com>
Message-ID: <alpine.DEB.2.00.1108150855580.22335@router.home>
References: <1313146843.1015.YahooMailNeo@web162014.mail.bf1.yahoo.com> <alpine.DEB.2.00.1108121053490.16906@router.home> <1313384511.62052.YahooMailNeo@web162020.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-442464136-1313416687=:22335"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Cc: "mgorman@suse.de" <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-442464136-1313416687=:22335
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sun, 14 Aug 2011, Pintu Agarwal wrote:

> Thanks Christoph for your reply :)
> =A0
> > Weird system. One would expect it to only have NORMAL zones. Is this an
> > ARM system?
> =A0
> Yes this is an ARM based system for linux mobile phone.

Ok.Maybe The memory setup is broken. Make the DMA zones into NORMAL
zones?

> Yes, I tried exactly like this, but since I have only one zone (DMA), it =
always returns me the data from the first Node 0.
> This will only work, if I have 3 separate zones (DMA, Normal, HighMem)

Well yes that is the way its designed. DMA is an exceptional zone.

> In "__alloc_pages_nodemask", before the actual allocation happens, how to=
 find out the allocation is going to happen from which zone and which Node.=
?
> (The _preferred_zone_ info is not enough, I need to know the Node number =
as well)

You can get the node number from a zone. Use zone_to_nid().
---1463811839-442464136-1313416687=:22335--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
