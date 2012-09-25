Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id F24406B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 03:37:33 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so4927109wib.8
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 00:37:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALF0-+V9wpWoLe2jmCqpS-y0S89i3sS52cMXn9UvE+mNT-t10Q@mail.gmail.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
	<1347137279-17568-2-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1209091427160.13346@chino.kir.corp.google.com>
	<CALF0-+V9wpWoLe2jmCqpS-y0S89i3sS52cMXn9UvE+mNT-t10Q@mail.gmail.com>
Date: Tue, 25 Sep 2012 10:37:32 +0300
Message-ID: <CAOJsxLHBqXEeUK4TxjF50BH3yzbmMrXW0FaXZgbn2rbyBLdoFw@mail.gmail.com>
Subject: Re: [PATCH 02/10] mm, slob: Use NUMA_NO_NODE instead of -1
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Sep 24, 2012 at 8:13 PM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
> Will you pick this (and the rest of cleanup patches)
> for v3.7 pull request?
> Or is there anything for me to redo?

I merged all the patches except for the last one which conflicts with
the kmem/memcg changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
