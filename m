Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C7D74900137
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 07:00:44 -0400 (EDT)
Message-ID: <1313146843.1015.YahooMailNeo@web162014.mail.bf1.yahoo.com>
Date: Fri, 12 Aug 2011 04:00:43 -0700 (PDT)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Reply-To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: Tracking page allocation in Zone/Node
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mgorman@suse.de" <mgorman@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,=0A=A0=0AI wanted to keep track of the page allocation in kernel every t=
ime there is an allocation request in kernel.=0A=A0=0AUnder "__alloc_pages_=
nodemask" , I wanted to print the zone/node information from which the page=
 is actually getting allocated.=0AAnd then some more stuffs later, based on=
 this.=0A=A0=0ABut I am facing some problem and I need some help.=0A=A0=0AO=
n my system I have only DMA zones with 3 nodes as follows:=0ANode 0, zone=
=A0=A0=A0=A0=A0 DMA=A0=A0=A0=A0=A0 3=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 6=A0=
=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 5=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0ANode 1, zone=
=A0=A0=A0=A0=A0 DMA=A0=A0=A0=A0=A0 8=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 3=A0=
=A0=A0=A0=A0 8=A0=A0=A0=A0=A0 7=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 2=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0ANode 2, zone=
=A0=A0=A0=A0=A0 DMA=A0=A0=A0=A0 10=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 8=A0=A0=
=A0=A0=A0 3=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=
=A0 1=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 2=A0=A0=A0=A0 28=0A=A0=0AIn __alloc_p=
ages_nodemask(...), just before "First Allocation Attempt" [that is before =
get_page_from_freelist(....)], I wanted to print=A0all the free pages from =
the "preferred_zone".=0AUsing something like=A0this : =0Atotalfreepages =3D=
 zone_page_state(zone, NR_FREE_PAGES);=0A=A0=0ABut in my case, there is onl=
y one zone (DMA) but 3 nodes.=0AThus the above "zone_page_state" always ret=
urns totalfreepages only from first Node 0.=0ABut the allocation actually h=
appening from Node 2.=0A=A0=0AHow can we point to the zone of Node 2 to get=
 the actual value?=0A=A0=0AIf anybody have any ideas please let me know.=0A=
=A0=0A=A0=0A=A0=0AThanks, Regards,=0APintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
