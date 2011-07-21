Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 931166B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 11:27:42 -0400 (EDT)
Date: Thu, 21 Jul 2011 10:27:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
In-Reply-To: <1311237839.2422.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.DEB.2.00.1107211025530.3995@router.home>
References: <20110720121612.28888.38970.stgit@localhost6>  <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>  <alpine.DEB.2.00.1107200854390.32737@router.home>  <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.DEB.2.00.1107200950270.1472@router.home> <1311237839.2422.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1751958307-1311262060=:3995"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1751958307-1311262060=:3995
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Thu, 21 Jul 2011, Eric Dumazet wrote:

> Le mercredi 20 juillet 2011 =C3=A0 09:52 -0500, Christoph Lameter a =C3=
=A9crit :
>
> > We should be making it a per cpu pointer like slub then. I looked at wh=
at
> > it would take to do so a couple of month ago but it was quite invasive.
> >
>
> I took a look at this too, but using percpu data would consume more
> memory, because percpu allocator allocates memory blobs for all possible
> cpus, while current code handles online/offline cpu nicely.

The number of possible cpus is determined on bootup. If the BIOS provides
the right information about which cpus are present and if there is no
hotswapping of cpus possible then only per cpu areas for the actual
functioning cpus are allocated. Certainly no desktop bios will indicate
that 4096 cpus are possible.



---1463811839-1751958307-1311262060=:3995--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
