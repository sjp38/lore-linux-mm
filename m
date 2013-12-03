Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 188306B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 16:58:11 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k4so6048641qaq.1
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 13:58:10 -0800 (PST)
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTP id u5si56446571qed.99.2013.12.03.13.58.09
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 13:58:10 -0800 (PST)
Date: Tue, 3 Dec 2013 21:58:09 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: Slab BUG with DEBUG_* options
In-Reply-To: <alpine.SOC.1.00.1312032314040.25191@math.ut.ee>
Message-ID: <00000142ba77e59d-3e002746-996d-4843-b8f1-51d1431b47a9-000000@email.amazonses.com>
References: <alpine.SOC.1.00.1311300125490.6363@math.ut.ee> <alpine.DEB.2.02.1312030930450.4115@gentwo.org> <00000142ba22e43b-99d8d7cb-9ecd-4f18-9609-8805270843d4-000000@email.amazonses.com> <alpine.SOC.1.00.1312032314040.25191@math.ut.ee>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Meelis Roos <mroos@linux.ee>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Tue, 3 Dec 2013, Meelis Roos wrote:

> Tested it. seems to hang after switching to another console. Before
> that, slabs are initialized successfully, I verified it with my previous
> debug printk sprinkle patch. Many allocations are still off slab - is
> that OK?

Yes that was the intend. Only exempt the small ones.

> console [tty0] enabled, bootconsole disabled

Looks like the bootstrap worked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
