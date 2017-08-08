Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 094FC6B049F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 11:01:35 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s23so30239760ioe.8
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 08:01:35 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id u18si1553908ioi.269.2017.08.08.08.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 08:01:33 -0700 (PDT)
Date: Tue, 8 Aug 2017 10:01:31 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] mm/slub.c: Allow poisoning to use the fast path
In-Reply-To: <CAGXu5jKsb+7NyKLemdkS4ENtxuQzbaDY2h2DnMEr+=qBqJAJqw@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1708080957470.25441@nuc-kabylake>
References: <20170804231002.20362-1-labbott@redhat.com> <alpine.DEB.2.20.1708070936400.17268@nuc-kabylake> <559096f0-bf1b-eff1-f0ce-33f53a4df255@redhat.com> <alpine.DEB.2.20.1708071302310.18681@nuc-kabylake> <e0fc8a0a-fa52-e644-1fc2-4e96082858e0@redhat.com>
 <CAGXu5jKsb+7NyKLemdkS4ENtxuQzbaDY2h2DnMEr+=qBqJAJqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>


On Mon, 7 Aug 2017, Kees Cook wrote:
>
> To clarify, this is desirable to kill exploitation of
> exposure-after-free flaws and some classes of use-after-free flaws,
> since the contents will have be wiped out after a free. (Verification
> of poison is nice, but is expensive compared to the benefit against
> these exploits -- and notably doesn't protect against the other
> use-after-free attacks where the contents are changed after the next
> allocation, which would have passed the poison verification.)

Well the only variable in the freed area that is in use by the allocator
is the free pointer. This ensures that complete object is poisoned and the
free pointer has a separate storage area right? So the size of the slab
objects increase. In addition to more hotpath processing we also have
increased object sizes.

I am not familiar with the terminology here.

So exposure-after-free means that the contents of the object can be used
after it was freed?

Contents are changed after allocation? Someone gets a pointer to the
object and the mods it later?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
