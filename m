Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 62E2A6B0082
	for <linux-mm@kvack.org>; Sun, 27 May 2012 16:45:50 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so6196171obb.14
        for <linux-mm@kvack.org>; Sun, 27 May 2012 13:45:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1205261317310.2488@eggly.anvils>
References: <1337884054.3292.22.camel@lappy> <20120524120727.6eab2f97.akpm@linux-foundation.org>
 <CA+1xoqcbZWLpvHkOsZY7rijsaryFDvh=pqq=QyDDgo_NfPyCpA@mail.gmail.com> <alpine.LSU.2.00.1205261317310.2488@eggly.anvils>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Sun, 27 May 2012 22:45:28 +0200
Message-ID: <CA+1xoqfGeQjrVWM3p4M0hV=hAwzx18bcoH7Bcn1mv_vOE8hDRw@mail.gmail.com>
Subject: Re: mm: kernel BUG at mm/memory.c:1230
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, viro <viro@zeniv.linux.org.uk>, oleg@redhat.com, "a.p.zijlstra" <a.p.zijlstra@chello.nl>, mingo <mingo@kernel.org>, Dave Jones <davej@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>

On Sat, May 26, 2012 at 10:26 PM, Hugh Dickins <hughd@google.com> wrote:
> I'm keeping off the linux-next for the moment; I'll worry about this
> more if it shows up when we try 3.5-rc1. =A0Your fuzzing tells that my
> logic above is wrong, but maybe it's just a passing defect in next.

I have a theory about this, which might explain it.

After a couple of days of not being able to reproduce it, I've decided
to revert Mel Gorman's patch related to memory corruption in mbind().
Once I've reverted it, I wasn't able to reproduce this exact case, but
did observe several other interesting things:

 - The original mbind() memory corruption.
 - Corruption in eventfd related structures (same dump as the mbind
one, but about eventfd structure).
 - Same as above, but with flock.
 - Hit a different BUG() in mm/mempolicy.c (The one at the end of slab_node=
()).

Is it possible that this issue could be explained by a corruption
related to the mbind() issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
