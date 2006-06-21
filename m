Message-ID: <44998C4F.8090502@google.com>
Date: Wed, 21 Jun 2006 11:13:35 -0700
From: Martin Bligh <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/tracking dirty pages: update get_dirty_limits for
 mmap tracking
References: <5c49b0ed0606211001s452c080cu3f55103a130b78f1@mail.gmail.com>
In-Reply-To: <5c49b0ed0606211001s452c080cu3f55103a130b78f1@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nate Diller <nate.diller@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>, Hans Reiser <reiser@namesys.com>, "E. Gryaznova" <grev@namesys.com>
List-ID: <linux-mm.kvack.org>

> -int vm_dirty_ratio = 40;
> +int vm_dirty_ratio = 80;

I don't think you can do that. Because ...

>     unsigned long available_memory = total_pages;
...
> +    dirty = (vm_dirty_ratio * available_memory) / 100;

... there are other things in memory besides pagecache. Limiting
dirty pages to 80% of pagecache might be fine, but not 80%
of total memory.

dirty = (vm_dirty_ratio * (nr_active + nr_inactive)) / 100

might be more sensible. Frankly the whole thing is a crock
anyway, because we should be counting easily freeable clean
pages, not dirty pages, but still.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
