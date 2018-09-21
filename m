Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FF9E8E0025
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 19:21:14 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r130-v6so6159113pgr.13
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 16:21:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o3-v6si4898970plk.95.2018.09.21.16.21.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 16:21:12 -0700 (PDT)
Date: Fri, 21 Sep 2018 16:21:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: possible deadlock in __do_page_fault
Message-Id: <20180921162110.e22d09a9e281d194db3c8359@linux-foundation.org>
In-Reply-To: <CAEXW_YSot+3AMQ=jmDRowmqoOmQmujp9r8Dh18KJJN1EDmyHOw@mail.gmail.com>
References: <000000000000f7a28e057653dc6e@google.com>
	<20180920141058.4ed467594761e073606eafe2@linux-foundation.org>
	<CAHRSSEzX5HOUEQ6DgEF76OLGrwS1isWMdtvneBLOEEnwoMxVrA@mail.gmail.com>
	<CAEXW_YSot+3AMQ=jmDRowmqoOmQmujp9r8Dh18KJJN1EDmyHOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Todd Kjos <tkjos@google.com>, Joel Fernandes <joelaf@google.com>, syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com, ak@linux.intel.com, Johannes Weiner <hannes@cmpxchg.org>, jack@suse.cz, jrdr.linux@gmail.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, Arve =?ISO-8859-1?Q?Hj=F8nnev=E5g?= <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thu, 20 Sep 2018 19:33:15 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:

> On Thu, Sep 20, 2018 at 5:12 PM Todd Kjos <tkjos@google.com> wrote:
> >
> > +Joel Fernandes
> >
> > On Thu, Sep 20, 2018 at 2:11 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > >
> > > Thanks.  Let's cc the ashmem folks.
> > >
> 
> This should be fixed by https://patchwork.kernel.org/patch/10572477/
> 
> It has Neil Brown's Reviewed-by but looks like didn't yet appear in
> anyone's tree, could Greg take this patch?

All is well.  That went into mainline yesterday, with a cc:stable.
