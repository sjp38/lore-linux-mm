Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 3A6BA6B0075
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 13:14:04 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so5006463ied.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 10:14:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013a88ebfa65-af0fc24b-13fd-400f-b7fc-32230ca70620-000000@email.amazonses.com>
References: <1350907434-2202-1-git-send-email-elezegarcia@gmail.com>
	<0000013a88ebfa65-af0fc24b-13fd-400f-b7fc-32230ca70620-000000@email.amazonses.com>
Date: Mon, 22 Oct 2012 14:14:03 -0300
Message-ID: <CALF0-+VqGrcjw16rNPH459YAj7dubQnruzV-zOzYn6feOtQ4tQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/slob: Mark zone page state to get slab usage at /proc/meminfo
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

Hi Christoph,

On Mon, Oct 22, 2012 at 11:41 AM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 22 Oct 2012, Ezequiel Garcia wrote:
>
>> On page allocations, SLAB and SLUB modify zone page state counters
>> NR_SLAB_UNRECLAIMABLE or NR_SLAB_RECLAIMABLE.
>> This allows to obtain slab usage information at /proc/meminfo.
>>
>> Without this patch, /proc/meminfo will show zero Slab usage for SLOB.
>>
>> Since SLOB discards SLAB_RECLAIM_ACCOUNT flag, we always use
>> NR_SLAB_UNRECLAIMABLE zone state item.
>

... and I have a question about this.

SLUB handles large kmalloc allocations falling back
to page-size allocations (kmalloc_large, etc).
This path doesn't touch NR_SLAB_XXRECLAIMABLE zone item state.

Without fully understanding it, I've decided to implement the same
behavior for SLOB,
leaving page-size allocations unaccounted on /proc/meminfo.

Is this expected / wanted ?

SLAB, on the other side, handles every allocation through some slab cache,
so it always set the zone state.

Thanks!

    Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
