Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB916B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 10:39:00 -0500 (EST)
Message-ID: <1322581121.2921.245.camel@twins>
Subject: Re: possible slab deadlock while doing ifenslave
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 29 Nov 2011 16:38:41 +0100
In-Reply-To: <alpine.DEB.2.00.1111290855570.14101@router.home>
References: <201110121019.53100.hans@schillstrom.com>
	  <alpine.DEB.2.00.1110121333560.7646@chino.kir.corp.google.com>
	  <201110131019.58397.hans@schillstrom.com>
	  <alpine.DEB.2.00.1110131557090.10968@chino.kir.corp.google.com>
	  <1322515158.2921.179.camel@twins> <1322515222.2921.180.camel@twins>
	 <alpine.DEB.2.00.1111290855570.14101@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Hans Schillstrom <hans@schillstrom.com>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org

On Tue, 2011-11-29 at 08:58 -0600, Christoph Lameter wrote:
> On Mon, 28 Nov 2011, Peter Zijlstra wrote:
>=20
> > Currently we only annotate the kmalloc caches, annotate all of them.
>=20
> What is the benefit?=20

Extra paranoia I guess..  I was fairly sure it was pointless, but I send
it anyway.

> The metadata for off slab caches uses the
> kmalloc array. Should the annotation for the kmalloc cache not be
> sufficient by putting that into a different lock category? Non-kmalloc
> caches already have a different lock category before this patch right?

Yeah, we annotate all kmalloc caches that have l3 and aren't OFF_SLAB().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
