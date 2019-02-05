Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FA23C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 20:17:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99DCA217D6
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 20:17:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KAzi4Km5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99DCA217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C1B38E009D; Tue,  5 Feb 2019 15:17:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 072038E009C; Tue,  5 Feb 2019 15:17:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC9648E009D; Tue,  5 Feb 2019 15:17:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9A1F8E009C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 15:17:55 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id e89so3392955pfb.17
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 12:17:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=/asjwI2h3R4dB1KhUJqTPMjf/nV/o0Zi8H3tJeSh7VI=;
        b=dLqLa/006PzWlAZNxlm0npGomTzh4AKUfptokeVv+cJouiJdSai1o5EMZkzP4yoCvz
         HpLVhc5ctAqprn3XKh0w3rV8B2MZ3qjWfZaxm/lAPUswoCjKrzMPMjH3qp4h2YikxOCf
         A1DV/lKCJ3uHXe3BPK69d0gWZm88C1fOvIGqoGpMMnyWN3TN/EZmb3O51pC4r1BeOwcZ
         dMg1EvzK6u9hcwnAmHRnWoGm7R+ySotOxsCOskaSfh50G9J6UD+r6akidPFUqBWetTWH
         taouKZk6t5xgnuJGMLOMl9gJiaQH1Ar36gPyYRehFcTTXH5E9n5HSEqpsVqLBBnquffQ
         C8JA==
X-Gm-Message-State: AHQUAubtANbaK056LR7mLfi9JuXJUM+Gj1pa9Z2btoEXjDJ03vXHqTnK
	0JKS7gF4I3HTvkqNWkOOhvXXZ600VgUcrfm4rZaqdsXYxwxlljCVZe8ecR3ngWdm6KOZEFetZ8M
	6T8vnX+qvlP1mndbWSLM67ggApxdyYLsbWidDiTSVUXkwiYdmp/qplrthrkgdgkbfJVsNH6Mdgf
	LFT3nM/ujDTLijExvK55AEEp9ldLE/AY3YIcE+3cD6jywt4GYjR8sMIwvXo1/JllOM44YY+vQmf
	IKxJZOwluu6JiSn4Ox7Q4urcv+ovXRpzYyKaBYL5+G1IFT3sZGu8lhrvSOkRxoczUfkGxzn11T0
	4Dfh+PZiWP71lkqBT0wpM0PV4FSDYXQVGGjtectY03DfbSQqoma6oW8pje8VNmaIZlU50jYQKeT
	C
X-Received: by 2002:a62:5287:: with SMTP id g129mr608517pfb.22.1549397875205;
        Tue, 05 Feb 2019 12:17:55 -0800 (PST)
X-Received: by 2002:a62:5287:: with SMTP id g129mr608442pfb.22.1549397874148;
        Tue, 05 Feb 2019 12:17:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549397874; cv=none;
        d=google.com; s=arc-20160816;
        b=log4XtbQ7EaeJpjw5u9zVIoDiqJRT/CyE02piGPkeJtWgMktit5cfueyqzGT+QZdG9
         lqq6YZBi+r3i3UoH/Sde+lqMdWVwJQ2jWAbZVu7Powg0JMvH4BUsmVXrKGDlWveKsjZv
         SY3FIrpawyAHjbe5YDHjnn35sA5YN7LSUIDra04AjiZ5VQ6kU4syKcUJX5enj2cPz7qh
         ne9OzwbQveML3CtXEfWg5qjoPNh2SwB5U0oDDN2NkkjZU83tiXZjP4qws33giQkuGOhc
         n7SGpRXIJBSQFCdu4+2ndWCHZkI1K91IFZ+W9/9jLJpUZmQYHyYBWFBvuTgxclO9aeRn
         +pvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=/asjwI2h3R4dB1KhUJqTPMjf/nV/o0Zi8H3tJeSh7VI=;
        b=HALONQ+9gEFatI7uikjXsDQvZVJLZedTY0SEEQhrAmbm8RGZcs0GQ1k7CH0UoSoUEs
         ltZ8LkqRwFbr7YdfeUyqXqmpRReGNwekh8BdSChMmXFZMFECXL5/FbVDgKFeBEmR+63p
         fOntq10BCWUOWgW2q5rNF5ZT6lGLICf+IONawp6ctbhjl1dSt2AXr3o95ONCrxMizskz
         zJGzrj5E+dxjlGfmY/n2RQkuL76ukdpGAhfENNAT9s0LYenuzlWkRF+BeNu3CdiCsv1J
         AnE1Ksvp8YSIyl5z0dkOKxHpTQMOiu3Ln5xQRbr2Br5mGHJu2kXB7XhVWVZ+JeR9SDTb
         zFjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KAzi4Km5;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q77sor6922909pfi.33.2019.02.05.12.17.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 12:17:54 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KAzi4Km5;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=/asjwI2h3R4dB1KhUJqTPMjf/nV/o0Zi8H3tJeSh7VI=;
        b=KAzi4Km5jRdAkGHd8bF9cYNW+h3If+L5zZL9wXe8rlZwk2X9UWvGIWw9I/vNP7Ded0
         eHc2JjtT4+muoLZ5IWpv/CpBbNDvyMWZpA7We2nd7HHvbNEPgHz9I6qtuvF309UvIm4Z
         TPtLp5ZlmhpbJ/PENU681DVQGwzC3ZYFm5X3rVrgrW7HtPWGWohKXY9CSa/H9u22shzU
         9N1iGG7Lt78dbVsBTqG/gzQ7k9avihm5xuQiy/ENFH92r9xyLYqcgFiIeAJocprDnPV2
         Oa1Ed2PGwzMHZrUAsO+/SbO8o6jzdX58TDEPUTdTWcTxXfFczNH2ydRuPtZVheCX6vrL
         bIiQ==
X-Google-Smtp-Source: AHgI3IaxNujIIMGLSxIBhRN36McCLaK/t8qyuhWae1Pe1AbArdzO/lDa9w0pCkuUIZ50wuLA5kt+Hw==
X-Received: by 2002:a62:ae04:: with SMTP id q4mr6864882pff.126.1549397872974;
        Tue, 05 Feb 2019 12:17:52 -0800 (PST)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id 24sm6722800pfr.75.2019.02.05.12.17.51
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Feb 2019 12:17:51 -0800 (PST)
Date: Tue, 5 Feb 2019 12:17:50 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Hugh Dickins <hughd@google.com>, Artem Savkov <asavkov@redhat.com>, 
    Baoquan He <bhe@redhat.com>, Qian Cai <cai@lca.pw>, 
    Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, 
    Vlastimil Babka <vbabka@suse.cz>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
    Linux-MM <linux-mm@kvack.org>
Subject: Re: mm: race in put_and_wait_on_page_locked()
In-Reply-To: <CAHk-=wjXP6dnbdeLryqrMCG8+-yk1G7gcSKiopDKDEj0AdzdAA@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1902051109120.9007@eggly.anvils>
References: <20190204091300.GB13536@shodan.usersys.redhat.com> <alpine.LSU.2.11.1902041201280.4441@eggly.anvils> <CAHk-=wjXP6dnbdeLryqrMCG8+-yk1G7gcSKiopDKDEj0AdzdAA@mail.gmail.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2019, Linus Torvalds wrote:
> On Mon, Feb 4, 2019 at 8:43 PM Hugh Dickins <hughd@google.com> wrote:
> >
> > Something I shall not be doing, is verifying the correctness of the
> > low-level get_page_unless_zero() versus page_ref_freeze() protocol
> > on arm64 and power - nobody has reported on x86, and I do wonder if
> > there's a barrier missing somewhere, that could manifest in this way -
> > but I'm unlikely to be the one to find that (and also think that any
> > weakness there should have shown up long before now).
> 
> Remind me what the page_ref_freeze() rules even _are_?
> 
> It's a very special thing, setting the page count down to zero if it
> matches the "expected" count.
> 
> Now, if another CPU does a put_page() at that point, that certainly
> will hit the "oops, we dropped the ref to something that was zero".
> 
> So the "expected" count had better be only references we have and own
> 100%, but some of those references aren't really necessarily private
> to our thread.
> 
> For example, what happens if
> 
>  (a) one CPU is doing migration_entry_wait() (counting expected page
> refs etc, before doing page_ref_freeze)

s/migration_entry_wait/migrate_page_move_mapping/

> 
>  (b) another CPU is dirtying a page that was in the swap cache and
> takes a reference to it, but drops it from the swap cache

This is reuse_swap_page() called from do_wp_page(), I presume.

> 
> Note how (b) does not change the refcount on the page at all, because
> it just moves the ref-count from "swap cache entry" to "I own the page
> in my page tables". Which means that when (a) does the "count expected
> count, and match it", it happily matches, and the page_ref_freeze()
> succeeds and makes the page count be zero.
> 
> But now (b) has a private reference to that page, and can drop it, so
> the "freeze" isn't a freeze at all.
> 
> Ok, so clearly the above cannot happen, and there's something I'm
> missing with the freezing. I think we hold the page lock while this is
> going on, which means those two things cannot happen at the same time.
> But maybe there is something else that does the above kind of "move
> page ref from one owner to another"?

You're right that the page lock prevents even getting there (and is
essential whenever mucking around with PageSwapCache), but more to
the point is that the expected_count passed to page_ref_freeze()
does not include any user mapping references (mapcount).

All user mappings (known of at that instant) have been unmapped before
migrate_page_move_mapping() is called, and if any got added since
(difficult without page lock, but I wouldn't assume impossible),
their associated page references are sure to make the page_ref_freeze()
fail (so long as the page refcounting has not been broken).

reuse_swap_page() is called while holding the page table lock: so
although do_wp_page() cannot quite be said to own the page, it is
making sure that it cannot be racily unmapped at that point.  So
until the pte_unmap_unlock() (by which time it has done its own
get_page()) it can treat the page reference associated with the
user mapping as safe, as if it were its own.  And no racing
page_ref_freeze() could succeed while it's there, page lock or not.

Page lock is more important at the "outer" level of the page
migration protocol: holding together the "atomic" switch from old
to new page with the copying of data and flags from old to new.
And more important with anon (swapless) pages, for which there's no
shared visible cache, so migrate_page_move_mapping() does not even
bother with a page_ref_freeze() (though sometimes I want it to).

> 
> The page_ref_freeze() rules don't seem to be documented anywhere.

I would not enjoy documenting what has to be done at what stage
in the page migration sequence: it has evolved, it is subtle,
and we're grateful just to have working code.

At the inner level (where I worried we might have some barrier problem),
the relation between page_ref_freeze() and get_page_unless_zero():
the best documentation I can think of on page_ref_freeze() indeed does
not mention it as such at all (I think it has gone through renamings):
the big comment Nick wrote above page_cache_get_speculative() in
include/linux/pagemap.h.  And there's a helpful little comment in
include/linux/mm.h get_page() too.

(Ah, those innocent days, when the word "speculative" filled us
with delight and hope, instead of horror and dread.)

By the way, I won't put this bug out of my mind, until I've done
an audit of PagePrivate: I've a feeling that fs/iomap.c is not the
first place to forget that PagePrivate must be associated with a
page reference (which is not a special demand of page migration:
page reclaim won't work without it either); and put_and_wait_blah
may now expose such incorrectness as crashes.

Hugh

