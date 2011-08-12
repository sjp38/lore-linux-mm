Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EB4E56B00EE
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 12:08:15 -0400 (EDT)
Date: Fri, 12 Aug 2011 11:08:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Tracking page allocation in Zone/Node
In-Reply-To: <1313146843.1015.YahooMailNeo@web162014.mail.bf1.yahoo.com>
Message-ID: <alpine.DEB.2.00.1108121053490.16906@router.home>
References: <1313146843.1015.YahooMailNeo@web162014.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1378856699-1313165293=:16906"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Cc: "mgorman@suse.de" <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1378856699-1313165293=:16906
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 12 Aug 2011, Pintu Agarwal wrote:

> On my system I have only DMA zones with 3 nodes as follows:
> Node 0, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0=A0=A0 3=A0=A0=A0=A0=A0 4=A0=A0=
=A0=A0=A0 6=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 5=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=
=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0
> Node 1, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0=A0=A0 8=A0=A0=A0=A0=A0 4=A0=A0=
=A0=A0=A0 3=A0=A0=A0=A0=A0 8=A0=A0=A0=A0=A0 7=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=
=A0 2=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0
> Node 2, zone=A0=A0=A0=A0=A0 DMA=A0=A0=A0=A0 10=A0=A0=A0=A0=A0 2=A0=A0=A0=
=A0=A0 8=A0=A0=A0=A0=A0 3=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 =
4=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 2=A0=A0=A0=A0 28

Weird system. One would expect it to only have NORMAL zones. Is this an
ARM system?


> In __alloc_pages_nodemask(...), just before "First Allocation Attempt" [t=
hat is before get_page_from_freelist(....)], I wanted to print=A0all the fr=
ee pages from the "preferred_zone".
> Using something like=A0this :
> totalfreepages =3D zone_page_state(zone, NR_FREE_PAGES);
> =A0
> But in my case, there is only one zone (DMA) but 3 nodes.
> Thus the above "zone_page_state" always returns totalfreepages only from =
first Node 0.
> But the allocation actually happening from Node 2.
> =A0
> How can we point to the zone of Node 2 to get the actual value?
>


I am not sure that I understand you correctly but you can get the data
from node 2 via

zone_page_state(NODE_DATA[2]->node_zones[ZONE_DMA], NR_FREE_PAGES);

or in __alloc_pages_nodemask

zone_page_state(preferred_zone, NR_FREE_PAGES);

---1463811839-1378856699-1313165293=:16906--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
