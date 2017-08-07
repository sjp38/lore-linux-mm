Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD836B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:03:05 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id w204so10814442ita.13
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:03:05 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id m62si9290672ith.204.2017.08.07.11.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:03:04 -0700 (PDT)
Date: Mon, 7 Aug 2017 13:03:03 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] mm/slub.c: Allow poisoning to use the fast path
In-Reply-To: <559096f0-bf1b-eff1-f0ce-33f53a4df255@redhat.com>
Message-ID: <alpine.DEB.2.20.1708071302310.18681@nuc-kabylake>
References: <20170804231002.20362-1-labbott@redhat.com> <alpine.DEB.2.20.1708070936400.17268@nuc-kabylake> <559096f0-bf1b-eff1-f0ce-33f53a4df255@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>

On Mon, 7 Aug 2017, Laura Abbott wrote:

> > Ok I see that the objects are initialized with poisoning and redzoning but
> > I do not see that there is fastpath code to actually check the values
> > before the object is reinitialized. Is that intentional or am
> > I missing something?
>
> Yes, that's intentional here. I see the validation as a separate more
> expensive feature. I had a crude patch to do some checks for testing
> and I know Daniel Micay had an out of tree patch to do some checks
> as well.

Ok then this patch does nothing? How does this help?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
