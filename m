Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id A13806B005A
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 13:13:04 -0400 (EDT)
Received: by ied10 with SMTP id 10so14441676ied.14
        for <linux-mm@kvack.org>; Mon, 24 Sep 2012 10:13:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1209091427160.13346@chino.kir.corp.google.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
	<1347137279-17568-2-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1209091427160.13346@chino.kir.corp.google.com>
Date: Mon, 24 Sep 2012 14:13:03 -0300
Message-ID: <CALF0-+V9wpWoLe2jmCqpS-y0S89i3sS52cMXn9UvE+mNT-t10Q@mail.gmail.com>
Subject: Re: [PATCH 02/10] mm, slob: Use NUMA_NO_NODE instead of -1
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

Pekka,

On Sun, Sep 9, 2012 at 6:27 PM, David Rientjes <rientjes@google.com> wrote:
> On Sat, 8 Sep 2012, Ezequiel Garcia wrote:
>
>> Cc: Pekka Enberg <penberg@kernel.org>
>> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
>
> Acked-by: David Rientjes <rientjes@google.com>
>

Will you pick this (and the rest of cleanup patches)
for v3.7 pull request?
Or is there anything for me to redo?

Thanks,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
