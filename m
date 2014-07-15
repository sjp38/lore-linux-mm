Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C1EF56B0036
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 01:47:50 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so248245pad.25
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 22:47:50 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id cb2si5457794pdb.235.2014.07.14.22.47.48
        for <linux-mm@kvack.org>;
        Mon, 14 Jul 2014 22:47:49 -0700 (PDT)
Date: Tue, 15 Jul 2014 14:53:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC/PATCH RESEND -next 10/21] mm: slab: share virt_to_cache()
 between slab and slub
Message-ID: <20140715055342.GH11317@js1304-P5Q-DELUXE>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-11-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404905415-9046-11-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Wed, Jul 09, 2014 at 03:30:04PM +0400, Andrey Ryabinin wrote:
> This patch shares virt_to_cache() between slab and slub and
> it used in cache_from_obj() now.
> Later virt_to_cache() will be kernel address sanitizer also.

I think that this patch won't be needed.
See comment in 15/21.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
