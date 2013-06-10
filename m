Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 897D16B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 10:09:16 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so1855996pbc.35
        for <linux-mm@kvack.org>; Mon, 10 Jun 2013 07:09:15 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 10 Jun 2013 16:09:15 +0200
Message-ID: <CAAxaTiNXV_RitbBKxCwV_rV44d1cLhfEbLs3ngtEGQUnZ2zk_g@mail.gmail.com>
Subject: Handling of GFP_WAIT in the slub and slab allocators
From: Nicolas Palix <nicolas.palix@imag.fr>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

Hi,

In the SLUB allocator, the GFP_WAIT mask bit is used
in allocate_slab to decide if local_irq_enable must be called.
This test is done again later to decide if local_irq_disable
must be called.

I notice that in the SLAB allocator, local_irq_save and
local_irq_restore are called in slab_alloc_node and slab_alloc without
checking the GFP_WAIT bit of the flags parameter.

Am I missing something or is there something to be fixed in the SLAB allocator ?

As I understand the code so far, this could change the state of the irqs
during the execution of start_kernel (init/main.c) for instance.

Could someone give me enlightenment about those points ?

Regards,
--
Nicolas Palix

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
