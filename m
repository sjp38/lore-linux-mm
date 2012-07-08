Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 93E916B0074
	for <linux-mm@kvack.org>; Sat,  7 Jul 2012 22:33:15 -0400 (EDT)
Received: by obhx4 with SMTP id x4so16283691obh.14
        for <linux-mm@kvack.org>; Sat, 07 Jul 2012 19:33:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207070139510.10445@chino.kir.corp.google.com>
References: <1341588521-17744-1-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1207070139510.10445@chino.kir.corp.google.com>
Date: Sun, 8 Jul 2012 11:33:14 +0900
Message-ID: <CAAmzW4PXdpQ2zSnkx8sSScAt1OY0j4+HXVmf=COvP7eMLqrEvQ@mail.gmail.com>
Subject: Re: [PATCH] mm: don't invoke __alloc_pages_direct_compact when order 0
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2012/7/7 David Rientjes <rientjes@google.com>:
> On Sat, 7 Jul 2012, Joonsoo Kim wrote:
>
>> __alloc_pages_direct_compact has many arguments so invoking it is very costly.
>> And in almost invoking case, order is 0, so return immediately.
>>
>
> If "zero cost" is "very costly", then this might make sense.
>
> __alloc_pages_direct_compact() is inlined by gcc.

In my kernel image, __alloc_pages_direct_compact() is not inlined by gcc.
So I send this patch.
But, currently I think it is not useful, so drop it.

Thanks for comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
