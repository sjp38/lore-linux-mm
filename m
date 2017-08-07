Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id EAD0D6B02F4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 10:37:49 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o72so5414354ita.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 07:37:49 -0700 (PDT)
Received: from resqmta-po-05v.sys.comcast.net (resqmta-po-05v.sys.comcast.net. [2001:558:fe16:19:96:114:154:164])
        by mx.google.com with ESMTPS id 187si3414688iox.338.2017.08.07.07.37.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 07:37:49 -0700 (PDT)
Date: Mon, 7 Aug 2017 09:37:46 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] mm/slub.c: Allow poisoning to use the fast path
In-Reply-To: <20170804231002.20362-1-labbott@redhat.com>
Message-ID: <alpine.DEB.2.20.1708070936400.17268@nuc-kabylake>
References: <20170804231002.20362-1-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>

On Fri, 4 Aug 2017, Laura Abbott wrote:

> All slub debug features currently disable the fast path completely.
> Some features such as consistency checks require this to allow taking of
> locks. Poisoning and red zoning don't require this and can safely use
> the per-cpu fast path. Introduce a Kconfig to continue to use the fast
> path when 'fast' debugging options are enabled. The code will
> automatically revert to always using the slow path when 'slow' options
> are enabled.

Ok I see that the objects are initialized with poisoning and redzoning but
I do not see that there is fastpath code to actually check the values
before the object is reinitialized. Is that intentional or am
I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
