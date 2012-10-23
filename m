Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id BAE2D6B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 14:43:09 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so7225153ied.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 11:43:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013a8ed646c2-4cc34bd5-19c3-4e99-9fa0-248cdbc24feb-000000@email.amazonses.com>
References: <1350907434-2202-1-git-send-email-elezegarcia@gmail.com>
	<0000013a88ebfa65-af0fc24b-13fd-400f-b7fc-32230ca70620-000000@email.amazonses.com>
	<CALF0-+VqGrcjw16rNPH459YAj7dubQnruzV-zOzYn6feOtQ4tQ@mail.gmail.com>
	<0000013a8ed646c2-4cc34bd5-19c3-4e99-9fa0-248cdbc24feb-000000@email.amazonses.com>
Date: Tue, 23 Oct 2012 15:43:09 -0300
Message-ID: <CALF0-+WASdSAT9rnLxx8OmHrNV5tjrDwpBTE9irCRd91QxMkBA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/slob: Mark zone page state to get slab usage at /proc/meminfo
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Tue, Oct 23, 2012 at 3:15 PM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 22 Oct 2012, Ezequiel Garcia wrote:
>
>> SLUB handles large kmalloc allocations falling back
>> to page-size allocations (kmalloc_large, etc).
>> This path doesn't touch NR_SLAB_XXRECLAIMABLE zone item state.
>
> Right. UNRECLAIMABLE allocations do not factor in reclaim decisions.
>

I wasn't asking about reclaim decisions.

I think my question wasn't clear.

The issue is: with SLUB large kmallocs don't set NR_SLAB_UNRECLAIMABLE
zone item.
Thus, they don't show at /proc/meminfo. Is this okey?

Thanks!

    Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
