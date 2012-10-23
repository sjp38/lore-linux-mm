Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 143856B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 14:15:40 -0400 (EDT)
Date: Tue, 23 Oct 2012 18:15:38 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm/slob: Mark zone page state to get slab usage at
 /proc/meminfo
In-Reply-To: <CALF0-+VqGrcjw16rNPH459YAj7dubQnruzV-zOzYn6feOtQ4tQ@mail.gmail.com>
Message-ID: <0000013a8ed646c2-4cc34bd5-19c3-4e99-9fa0-248cdbc24feb-000000@email.amazonses.com>
References: <1350907434-2202-1-git-send-email-elezegarcia@gmail.com> <0000013a88ebfa65-af0fc24b-13fd-400f-b7fc-32230ca70620-000000@email.amazonses.com> <CALF0-+VqGrcjw16rNPH459YAj7dubQnruzV-zOzYn6feOtQ4tQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Mon, 22 Oct 2012, Ezequiel Garcia wrote:

> SLUB handles large kmalloc allocations falling back
> to page-size allocations (kmalloc_large, etc).
> This path doesn't touch NR_SLAB_XXRECLAIMABLE zone item state.

Right. UNRECLAIMABLE allocations do not factor in reclaim decisions.

> Without fully understanding it, I've decided to implement the same
> behavior for SLOB,
> leaving page-size allocations unaccounted on /proc/meminfo.
>
> Is this expected / wanted ?

Yes that is fine.

> SLAB, on the other side, handles every allocation through some slab cache,
> so it always set the zone state.

Right but the caching barely has any effect at large sizes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
