Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 220056B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 08:58:28 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ao6so26346563pac.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 05:58:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id f5si16564693pay.145.2016.06.21.05.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 05:58:27 -0700 (PDT)
Date: Tue, 21 Jun 2016 05:58:07 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 2/4] Add the latent_entropy gcc plugin
Message-ID: <20160621125807.GA19065@infradead.org>
References: <20160620203910.a8b6b5b10d18f24661916e7b@gmail.com>
 <20160620204119.6299c961570a7a9ad6cbdd51@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160620204119.6299c961570a7a9ad6cbdd51@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emese Revfy <re.emese@gmail.com>
Cc: kernel-hardening@lists.openwall.com, pageexec@freemail.hu, spender@grsecurity.net, mmarek@suse.com, keescook@chromium.org, linux-kernel@vger.kernel.org, yamada.masahiro@socionext.com, linux-kbuild@vger.kernel.org, tytso@mit.edu, akpm@linux-foundation.org, linux-mm@kvack.org, axboe@kernel.dk, viro@zeniv.linux.org.uk, paulmck@linux.vnet.ibm.com, mingo@redhat.com, tglx@linutronix.de, bart.vanassche@sandisk.com, davem@davemloft.net

On Mon, Jun 20, 2016 at 08:41:19PM +0200, Emese Revfy wrote:
> --- /dev/null
> +++ b/scripts/gcc-plugins/latent_entropy_plugin.c
> @@ -0,0 +1,639 @@
> +/*
> + * Copyright 2012-2016 by the PaX Team <pageexec@freemail.hu>
> + * Copyright 2016 by Emese Revfy <re.emese@gmail.com>
> + * Licensed under the GPL v2
> + *
> + * Note: the choice of the license means that the compilation process is
> + *       NOT 'eligible' as defined by gcc's library exception to the GPL v3,
> + *       but for the kernel it doesn't matter since it doesn't link against
> + *       any of the gcc libraries

I remember we used to have architectures that actually linked against
libgcc.  Isn't that the case anymore?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
