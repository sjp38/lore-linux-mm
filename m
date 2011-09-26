Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id F2B2F9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 03:29:54 -0400 (EDT)
Subject: Re: [PATCH 4/5] mm: Only IPI CPUs to drain local pages if they exist
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 26 Sep 2011 09:29:25 +0200
In-Reply-To: <1316940890-24138-5-git-send-email-gilad@benyossef.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	 <1316940890-24138-5-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317022165.9084.54.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Sun, 2011-09-25 at 11:54 +0300, Gilad Ben-Yossef wrote:
> +/* NOTE: If you call this function it is very likely you want to clear
> +   cpus_with_pcp as well. */
>  static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch=
)
>  {=20

  /*
   * Multi-line comment
   * style is like
   * this.
   */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
