Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id EBC546B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 06:46:50 -0400 (EDT)
Received: by ied10 with SMTP id 10so1286764ied.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 03:46:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLHBENuus5+isE8ucKUAqVHwaYHuGxOqgGmtPC-2TYri3A@mail.gmail.com>
References: <1348571229-844-1-git-send-email-elezegarcia@gmail.com>
	<1348571229-844-2-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1209252115000.28360@chino.kir.corp.google.com>
	<CALF0-+UZj-cunn-+AW0N6_oi1j9VFH8btKV1pvhjtVFiVsE1yQ@mail.gmail.com>
	<CAOJsxLHBENuus5+isE8ucKUAqVHwaYHuGxOqgGmtPC-2TYri3A@mail.gmail.com>
Date: Wed, 26 Sep 2012 07:46:50 -0300
Message-ID: <CALF0-+WYRrC544p-JBYXZzacbGW5FpNM0p17Nrp+-49KTFhuDQ@mail.gmail.com>
Subject: Re: [PATCH] mm/slab: Fix kmem_cache_alloc_node_trace() declaration
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, kernel-janitors@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com

On Wed, Sep 26, 2012 at 7:42 AM, Pekka Enberg <penberg@kernel.org> wrote:
> On Wed, Sep 26, 2012 at 1:09 PM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
>> Yes. I just asked Pekka to revert this patch altogether.
>> The original patch was meant to match SLAB and SLUB, and this
>> fix should maintain that. But instead I fix it the wrong way.
>>
>> I'll send another one.
>
> Okay, I'm now confused and somewhat unhappy. What commits do you want
> me to nuke exactly?

>From your slab/tracing topic branch:

1e5965bf1f018cc30a4659fa3f1a40146e4276f6
mm/slab: Fix kmem_cache_alloc_node_trace() declaration

Thanks,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
