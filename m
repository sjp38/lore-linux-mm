Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8EA46B401E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 08:35:40 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id d23so21125839plj.22
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 05:35:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s20sor562692pgv.12.2018.11.26.05.35.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 05:35:39 -0800 (PST)
Date: Mon, 26 Nov 2018 05:35:36 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH -next 1/2] mm/memfd: make F_SEAL_FUTURE_WRITE seal more
 robust
Message-ID: <20181126133536.GB242510@google.com>
References: <20181121070658.011d576d@canb.auug.org.au>
 <469B80CB-D982-4802-A81D-95AC493D7E87@amacapital.net>
 <20181120204710.GB22801@google.com>
 <F8E28229-C99E-4711-982B-5B5DE0F70F16@amacapital.net>
 <20181120211335.GC22801@google.com>
 <20181121182701.0d8a775fda6af1f8d2be8f25@linux-foundation.org>
 <CALCETrUGyhqi+M3cTdqJNNOPfTWn-R-ekM_R5heq2mbdVqPUAw@mail.gmail.com>
 <20181122230906.GA198127@google.com>
 <20181124164229.89c670b6e7a3530ef7b0a40c@linux-foundation.org>
 <20181125004736.GA3065@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181125004736.GA3065@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, Linux API <linux-api@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>

On Sat, Nov 24, 2018 at 04:47:36PM -0800, Matthew Wilcox wrote:
> On Sat, Nov 24, 2018 at 04:42:29PM -0800, Andrew Morton wrote:
> > This changelog doesn't have the nifty test case code which was in
> > earlier versions?
> 
> Why do we put regression tests in the changelogs anyway?  We have
> tools/testing/selftests/vm/ already, perhaps they should go there?

The reason is I didn't add it was that test case went out of date and the
updated version of the test case went into the selftests in patch 2/2. I
thought that would suffice which covers all the cases. That's why I dropped
it.  Would that be Ok?

The changelog of the previous series had it because the selftest was added
only later.

Let me know, thanks,

 - Joel
