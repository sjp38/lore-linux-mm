Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2AC9000BD
	for <linux-mm@kvack.org>; Sun, 25 Sep 2011 07:38:42 -0400 (EDT)
Received: by eye13 with SMTP id 13so3913825eye.14
        for <linux-mm@kvack.org>; Sun, 25 Sep 2011 04:38:39 -0700 (PDT)
Subject: Re: [PATCH 1/5] smp: Introduce a generic on_each_cpu_mask function
From: Sasha Levin <levinsasha928@gmail.com>
In-Reply-To: <1316940890-24138-2-git-send-email-gilad@benyossef.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	 <1316940890-24138-2-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 25 Sep 2011 14:37:52 +0300
Message-ID: <1316950672.3641.3.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Sun, 2011-09-25 at 11:54 +0300, Gilad Ben-Yossef wrote:
> +#define on_each_cpu_mask(mask, func, info, wait) \
> +       if (cpumask_test_cpu(0, (mask))) {      \
> +               local_irq_disable();            \
> +               func(info);                     \
		  (func)(info);
> +               local_irq_enable();             \
> +       }
> + 

Maybe it's worth changing it to be so in case someone passes a func ptr
such as 'ptr[0] + 3'.

-- 

Sasha.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
