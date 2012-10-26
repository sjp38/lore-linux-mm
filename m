Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 665D16B0075
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 15:18:38 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hq4so710257wib.2
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 12:18:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <508AE1A3.6030607@redhat.com>
References: <20121025121617.617683848@chello.nl> <20121025124832.840241082@chello.nl>
 <CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com>
 <5089F5B5.1050206@redhat.com> <CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com>
 <508A0A0D.4090001@redhat.com> <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com>
 <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com>
 <m2pq45qu0s.fsf@firstfloor.org> <508A8D31.9000106@redhat.com>
 <20121026132601.GC9886@gmail.com> <20121026144419.7e666023@dull>
 <CA+55aFwdcMzMQ2ns6-p97GXuNhxiDO-nFa0h1A-tjN363mJniQ@mail.gmail.com> <508AE1A3.6030607@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 26 Oct 2012 12:18:16 -0700
Message-ID: <CA+55aFxOywu=6pqejQi5DFm0KQYj0i9yQexwxgzdM5z3kcDgrg@mail.gmail.com>
Subject: Re: [PATCH 1/3] x86/mm: only do a local TLB flush in ptep_set_access_flags()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Oct 26, 2012 at 12:16 PM, Rik van Riel <riel@redhat.com> wrote:
>
> I can change the text of the changelog, however it looks
> like do_wp_page does actually use ptep_set_access_flags
> to set the write bit in the pte...
>
> I guess both need to be reflected in the changelog text
> somehow?

Yeah, and by now, after all this discussion, I suspect it should be
committed with a comment too. Commit messages are good and all, but
unless chasing a particular bug they introduced, we shouldn't expect
people to read them for background information.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
