Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C88A5830A3
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 13:08:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so2135983wmz.2
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:08:40 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d10si2728836wje.168.2016.08.18.10.08.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 10:08:39 -0700 (PDT)
Date: Thu, 18 Aug 2016 19:08:19 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 03/16] slab: Convert to hotplug state machine
Message-ID: <20160818170819.pubp6ywvzkf5u3dg@linutronix.de>
References: <20160818125731.27256-1-bigeasy@linutronix.de>
 <20160818125731.27256-4-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20160818125731.27256-4-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, rt@linutronix.de, Richard Weinberger <richard@nod.at>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On 2016-08-18 14:57:18 [+0200], To linux-kernel@vger.kernel.org wrote:
> diff --git a/mm/slab.c b/mm/slab.c
> index 0eb6691ae6fc..e8d465069b87 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
=E2=80=A6
> +static int slab_online_cpu(unsigned int cpu)
> +{
> +	pr_err("%s(%d) %d\n", __func__, __LINE__, cpu);

as the careful reader will notice, it has been double checked whether or
not this callback is invoked. This output needs to go.

> +	start_cpu_timer(cpu);
> +	return 0;
> +}

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
