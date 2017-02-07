Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD726B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 16:49:38 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so167836726pfb.7
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 13:49:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j184si5237033pge.121.2017.02.07.13.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 13:49:37 -0800 (PST)
Date: Tue, 7 Feb 2017 13:49:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/slub: Fix random_seq offset destruction
Message-Id: <20170207134936.2cd986e5b673352d30cfad45@linux-foundation.org>
In-Reply-To: <CAJcbSZEKdgpuTYWO4R-KP3c2fsi-8OKyE=JhF1e83n+SYLrxAQ@mail.gmail.com>
References: <20170207140707.20824-1-sean@erifax.org>
	<CAJcbSZEKdgpuTYWO4R-KP3c2fsi-8OKyE=JhF1e83n+SYLrxAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Sean Rees <sean@erifax.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 7 Feb 2017 07:41:13 -0800 Thomas Garnier <thgarnie@google.com> wrote:

> On Tue, Feb 7, 2017 at 6:07 AM, Sean Rees <sean@erifax.org> wrote:
> > Bailout early from init_cache_random_seq if s->random_seq is already
> > initialised. This prevents destroying the previously computed random_seq
> > offsets later in the function.
> >
> > If the offsets are destroyed, then shuffle_freelist will truncate
> > page->freelist to just the first object (orphaning the rest).
> >
> > This fixes https://bugzilla.kernel.org/show_bug.cgi?id=177551.
> >
> > Signed-off-by: Sean Rees <sean@erifax.org>
> 
> Please add:
> 
> Fixes: 210e7a43fa90 ("mm: SLUB freelist randomization")

I also added

Reported-by: <userwithuid@gmail.com>
Cc: <stable@vger.kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
