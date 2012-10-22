Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 863B36B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 10:50:37 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so2684081iak.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 07:50:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013a88ebfa65-af0fc24b-13fd-400f-b7fc-32230ca70620-000000@email.amazonses.com>
References: <1350907434-2202-1-git-send-email-elezegarcia@gmail.com>
	<0000013a88ebfa65-af0fc24b-13fd-400f-b7fc-32230ca70620-000000@email.amazonses.com>
Date: Mon, 22 Oct 2012 11:50:36 -0300
Message-ID: <CALF0-+X2GnTKykYT3pwDHZV-8-qoHQZdBaSscfrOei48ce-HWg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/slob: Mark zone page state to get slab usage at /proc/meminfo
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, uClinux development list <uclinux-dev@uclinux.org>

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
> Hmmm... that is unfortunate. The NR_SLAB_RECLAIMABLE stat is used by
> reclaim to make decisions on when to reclaim inodes and dentries.
>
> Could you fix that to properly account the reclaimable/unreclaimable
> pages?

Sure. Does everyone agree on this?

My concern is:

1. SLOB is minimal, designed to have minimal footprint, and I'd like
to keep it that way. Of course, perhaps the change will add just a few bytes.

2. Since no SLOB user has ever complained on this...
How will this affect SLOB workings?
(I'm adding the uclinux guys, so at least they're aware of this)

    Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
