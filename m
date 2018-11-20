Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 827B36B21B8
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 16:13:39 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id x7so3458646pll.23
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 13:13:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h80-v6sor50916450pfj.52.2018.11.20.13.13.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 13:13:38 -0800 (PST)
Date: Tue, 20 Nov 2018 13:13:35 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH -next 1/2] mm/memfd: make F_SEAL_FUTURE_WRITE seal more
 robust
Message-ID: <20181120211335.GC22801@google.com>
References: <20181120052137.74317-1-joel@joelfernandes.org>
 <CALCETrXgBENat=5=7EuU-ttQ-YSXT+ifjLGc=hpJ=unRgSsndw@mail.gmail.com>
 <20181120183926.GA124387@google.com>
 <20181121070658.011d576d@canb.auug.org.au>
 <469B80CB-D982-4802-A81D-95AC493D7E87@amacapital.net>
 <20181120204710.GB22801@google.com>
 <F8E28229-C99E-4711-982B-5B5DE0F70F16@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <F8E28229-C99E-4711-982B-5B5DE0F70F16@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, Linux API <linux-api@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>

On Tue, Nov 20, 2018 at 02:02:49PM -0700, Andy Lutomirski wrote:
> 
> > On Nov 20, 2018, at 1:47 PM, Joel Fernandes <joel@joelfernandes.org> wrote:
> > 
> >> On Tue, Nov 20, 2018 at 01:33:18PM -0700, Andy Lutomirski wrote:
> >> 
> >>> On Nov 20, 2018, at 1:07 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >>> 
> >>> Hi Joel,
> >>> 
> >>>>> On Tue, 20 Nov 2018 10:39:26 -0800 Joel Fernandes <joel@joelfernandes.org> wrote:
> >>>>> 
> >>>>> On Tue, Nov 20, 2018 at 07:13:17AM -0800, Andy Lutomirski wrote:
> >>>>> On Mon, Nov 19, 2018 at 9:21 PM Joel Fernandes (Google)
> >>>>> <joel@joelfernandes.org> wrote:  
> >>>>>> 
> >>>>>> A better way to do F_SEAL_FUTURE_WRITE seal was discussed [1] last week
> >>>>>> where we don't need to modify core VFS structures to get the same
> >>>>>> behavior of the seal. This solves several side-effects pointed out by
> >>>>>> Andy [2].
> >>>>>> 
> >>>>>> [1] https://lore.kernel.org/lkml/20181111173650.GA256781@google.com/
> >>>>>> [2] https://lore.kernel.org/lkml/69CE06CC-E47C-4992-848A-66EB23EE6C74@amacapital.net/
> >>>>>> 
> >>>>>> Suggested-by: Andy Lutomirski <luto@kernel.org>
> >>>>>> Fixes: 5e653c2923fd ("mm: Add an F_SEAL_FUTURE_WRITE seal to memfd")  
> >>>>> 
> >>>>> What tree is that commit in?  Can we not just fold this in?  
> >>>> 
> >>>> It is in linux-next. Could we keep both commits so we have the history?
> >>> 
> >>> Well, its in Andrew's mmotm, so its up to him.
> >>> 
> >>> 
> >> 
> >> Unless mmotm is more magical than I think, the commit hash in your fixed
> >> tag is already nonsense. mmotm gets rebased all the time, and is only
> >> barely a git tree.
> > 
> > I wouldn't go so far to call it nonsense. It was a working patch, it just did
> > things differently. Your help with improving the patch is much appreciated.
> 
> Ia??m not saying the patch is nonsense a?? Ia??m saying the *hash* may be
> nonsense. akpm uses a bunch of .patch files and all kinds of crazy scripts,
> and the mmotm.git tree is not stable at all.
> 

Oh, ok. Sorry for misunderstanding and thanks for clarification. :-)

> > I am Ok with whatever Andrew wants to do, if it is better to squash it with
> > the original, then I can do that and send another patch.
> > 
> > 
> 
> From experience, Andrew will food in fixups on request :)

Andrew, could you squash this patch into the one titled ("mm: Add an
F_SEAL_FUTURE_WRITE seal to memfd")? That one was already picked up by -next
but I imagine you might have a crazy script as Andy pointed out for exactly
these situations. ;-)

thanks,

 - Joel
