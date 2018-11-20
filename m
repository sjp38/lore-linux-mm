Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 679AC6B2161
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 13:39:30 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 89so2486937ple.19
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 10:39:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b11-v6sor42473747pla.12.2018.11.20.10.39.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 10:39:29 -0800 (PST)
Date: Tue, 20 Nov 2018 10:39:26 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH -next 1/2] mm/memfd: make F_SEAL_FUTURE_WRITE seal more
 robust
Message-ID: <20181120183926.GA124387@google.com>
References: <20181120052137.74317-1-joel@joelfernandes.org>
 <CALCETrXgBENat=5=7EuU-ttQ-YSXT+ifjLGc=hpJ=unRgSsndw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXgBENat=5=7EuU-ttQ-YSXT+ifjLGc=hpJ=unRgSsndw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, Linux API <linux-api@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, Nov 20, 2018 at 07:13:17AM -0800, Andy Lutomirski wrote:
> On Mon, Nov 19, 2018 at 9:21 PM Joel Fernandes (Google)
> <joel@joelfernandes.org> wrote:
> >
> > A better way to do F_SEAL_FUTURE_WRITE seal was discussed [1] last week
> > where we don't need to modify core VFS structures to get the same
> > behavior of the seal. This solves several side-effects pointed out by
> > Andy [2].
> >
> > [1] https://lore.kernel.org/lkml/20181111173650.GA256781@google.com/
> > [2] https://lore.kernel.org/lkml/69CE06CC-E47C-4992-848A-66EB23EE6C74@amacapital.net/
> >
> > Suggested-by: Andy Lutomirski <luto@kernel.org>
> > Fixes: 5e653c2923fd ("mm: Add an F_SEAL_FUTURE_WRITE seal to memfd")
> 
> What tree is that commit in?  Can we not just fold this in?

It is in linux-next. Could we keep both commits so we have the history?

thanks,

 - Joel
