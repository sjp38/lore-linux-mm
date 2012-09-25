Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 2B1CD6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 06:13:51 -0400 (EDT)
Received: by ied10 with SMTP id 10so16737045ied.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 03:13:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLHBqXEeUK4TxjF50BH3yzbmMrXW0FaXZgbn2rbyBLdoFw@mail.gmail.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
	<1347137279-17568-2-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1209091427160.13346@chino.kir.corp.google.com>
	<CALF0-+V9wpWoLe2jmCqpS-y0S89i3sS52cMXn9UvE+mNT-t10Q@mail.gmail.com>
	<CAOJsxLHBqXEeUK4TxjF50BH3yzbmMrXW0FaXZgbn2rbyBLdoFw@mail.gmail.com>
Date: Tue, 25 Sep 2012 07:13:50 -0300
Message-ID: <CALF0-+Ux=iHfc8tVrCRnMApo+FOXQ4hPbWLQ+ZUBWPgTSsRyEA@mail.gmail.com>
Subject: Re: [PATCH 02/10] mm, slob: Use NUMA_NO_NODE instead of -1
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 25, 2012 at 4:37 AM, Pekka Enberg <penberg@kernel.org> wrote:
> On Mon, Sep 24, 2012 at 8:13 PM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
>> Will you pick this (and the rest of cleanup patches)
>> for v3.7 pull request?
>> Or is there anything for me to redo?
>
> I merged all the patches except for the last one which conflicts with
> the kmem/memcg changes.

Ok, great. We can work on those later, after kmem/memcg is settled.

Thanks,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
