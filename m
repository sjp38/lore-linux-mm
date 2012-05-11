Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id C28078D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 12:26:50 -0400 (EDT)
Received: by wefh52 with SMTP id h52so783207wef.14
        for <linux-mm@kvack.org>; Fri, 11 May 2012 09:26:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1205110054520.2801@eggly.anvils>
References: <alpine.LSU.2.00.1205110054520.2801@eggly.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 11 May 2012 09:26:28 -0700
Message-ID: <CA+55aFzKkR4sntktx63jstftfw_Grf1A5D97VzXo=hGS2R34=Q@mail.gmail.com>
Subject: Re: [PATCH] mm: raise MemFree by reverting percpu_pagelist_fraction
 to 0
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <levinsasha928@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 11, 2012 at 1:00 AM, Hugh Dickins <hughd@google.com> wrote:
>
> Commit 93278814d359 "mm: fix division by 0 in percpu_pagelist_fraction()"
> mistakenly initialized percpu_pagelist_fraction to the sysctl's minimum 8,
> which leaves 1/8th of memory on percpu lists (on each cpu??); but most of
> us expect it to be left unset at 0 (and it's not then used as a divisor).

Applied.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
