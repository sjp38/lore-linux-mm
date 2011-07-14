Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 577F76B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 15:34:07 -0400 (EDT)
Date: Thu, 14 Jul 2011 14:34:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Memory allocation from ZONE_HIGHMEM ???
In-Reply-To: <1310625925.65469.YahooMailNeo@web162002.mail.bf1.yahoo.com>
Message-ID: <alpine.DEB.2.00.1107141432520.2923@router.home>
References: <1310625925.65469.YahooMailNeo@web162002.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-2109514762-1310672045=:2923"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-2109514762-1310672045=:2923
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 13 Jul 2011, Pintu Agarwal wrote:

> I have a question regarding kernel memory allocation(using kmalloc)=A0fro=
m ZONE_HIGHMEM zone.

kmalloc does not allocate from ZONE_HIGHMEM.

> But I want to specifically allocate=A0pages from ZONE_HIGHMEM instead of =
Normal zone.
> How to explicitly do that in kernel?

You must use the page allocator. The slab allocators cannot use
ZONE_HIGHMEM. ZONE_HIGHMEM contains pages that are not directly accessible
from the processor.

---1463811839-2109514762-1310672045=:2923--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
