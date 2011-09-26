Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 036719000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 04:48:37 -0400 (EDT)
Subject: Re: [PATCH 1/5] smp: Introduce a generic on_each_cpu_mask function
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 26 Sep 2011 10:48:07 +0200
In-Reply-To: <1316940890-24138-2-git-send-email-gilad@benyossef.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	 <1316940890-24138-2-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317026887.9084.68.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Sun, 2011-09-25 at 11:54 +0300, Gilad Ben-Yossef wrote:
> +#define on_each_cpu_mask(mask, func, info, wait) \
> +       if (cpumask_test_cpu(0, (mask))) {      \
> +               local_irq_disable();            \
> +               func(info);                     \
> +               local_irq_enable();             \
> +       }=20

Typically we wrap that in an extra do { } while(0) loop to properly
consume the trailing ;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
