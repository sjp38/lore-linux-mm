Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8483E6B0007
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 10:35:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g15so4254702pfi.8
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 07:35:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d125si7067904pfa.263.2018.04.21.07.35.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 21 Apr 2018 07:35:16 -0700 (PDT)
Date: Sat, 21 Apr 2018 07:35:08 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Xen-devel] [Bug 198497] handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Message-ID: <20180421143508.GB14610@bombadil.infradead.org>
References: <bug-198497-200779@https.bugzilla.kernel.org/>
 <bug-198497-200779-43rwxa1kcg@https.bugzilla.kernel.org/>
 <CAKf6xpuYvCMUVHdP71F8OWm=bQGFxeRd7SddH-5DDo-AQjbbQg@mail.gmail.com>
 <20180420133951.GC10788@bombadil.infradead.org>
 <CAKf6xpuVrPwc=AxYruPVfdxx1Yv7NF7NKiGx7vT2WKLogUoqfA@mail.gmail.com>
 <76a4ee3b-e00a-5032-df90-07d8e207f707@citrix.com>
 <5ADA0A6D02000078001BD177@prv1-mh.provo.novell.com>
 <CAKf6xps4RiC48zCie0o7VzTOCDu8ik1hmFP=b_qMx8qTo8F3TQ@mail.gmail.com>
 <5ADA0F1502000078001BD1D2@prv1-mh.provo.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5ADA0F1502000078001BD1D2@prv1-mh.provo.novell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>
Cc: Jason Andryuk <jandryuk@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, linux-mm@kvack.org, akpm@linux-foundation.org, xen-devel@lists.xen.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, labbott@redhat.com, Juergen Gross <jgross@suse.com>

On Fri, Apr 20, 2018 at 10:02:29AM -0600, Jan Beulich wrote:
> >>>> Skylake 32bit PAE Dom0:
> >>>> Bad swp_entry: 80000000
> >>>> mm/swap_state.c:683: bad pte d3a39f1c(8000000400000000)
> >>>>
> >>>> Ivy Bridge 32bit PAE Dom0:
> >>>> Bad swp_entry: 40000000
> >>>> mm/swap_state.c:683: bad pte d3a05f1c(8000000200000000)
> >>>>
> >>>> Other 32bit DomU:
> >>>> Bad swp_entry: 4000000
> >>>> mm/swap_state.c:683: bad pte e2187f30(8000000200000000)
> >>>>
> >>>> Other 32bit:
> >>>> Bad swp_entry: 2000000
> >>>> mm/swap_state.c:683: bad pte ef3a3f38(8000000100000000)

> As said in my previous reply - both of the bits Andrew has mentioned can
> only ever be set when the present bit is also set (which doesn't appear to
> be the case here). The set bits above are actually in the range of bits
> designated to the address, which Xen wouldn't ever play with.

Is it relevant that all the crashes we've seen are with PAE in the guest?
Is it possible that Xen thinks the guest is not using PAE?
