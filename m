Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 70D0A6B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 06:42:54 -0400 (EDT)
Received: by wgbds1 with SMTP id ds1so4343865wgb.2
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 03:42:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALF0-+UZj-cunn-+AW0N6_oi1j9VFH8btKV1pvhjtVFiVsE1yQ@mail.gmail.com>
References: <1348571229-844-1-git-send-email-elezegarcia@gmail.com>
	<1348571229-844-2-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1209252115000.28360@chino.kir.corp.google.com>
	<CALF0-+UZj-cunn-+AW0N6_oi1j9VFH8btKV1pvhjtVFiVsE1yQ@mail.gmail.com>
Date: Wed, 26 Sep 2012 13:42:52 +0300
Message-ID: <CAOJsxLHBENuus5+isE8ucKUAqVHwaYHuGxOqgGmtPC-2TYri3A@mail.gmail.com>
Subject: Re: [PATCH] mm/slab: Fix kmem_cache_alloc_node_trace() declaration
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: David Rientjes <rientjes@google.com>, kernel-janitors@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com

On Wed, Sep 26, 2012 at 1:09 PM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
> Yes. I just asked Pekka to revert this patch altogether.
> The original patch was meant to match SLAB and SLUB, and this
> fix should maintain that. But instead I fix it the wrong way.
>
> I'll send another one.

Okay, I'm now confused and somewhat unhappy. What commits do you want
me to nuke exactly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
