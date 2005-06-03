Received: from smtp3.akamai.com (vwall2.sanmateo.corp.akamai.com [172.23.1.72])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j531NdRt005373
	for <linux-mm@kvack.org>; Thu, 2 Jun 2005 18:23:40 -0700 (PDT)
Message-ID: <429FB11B.3DC2EEF3@akamai.com>
Date: Thu, 02 Jun 2005 18:23:39 -0700
From: Prasanna Meda <pmeda@akamai.com>
MIME-Version: 1.0
Subject: Re: [patch] scm: fix scm_fp_list allocation problem
References: <200506012227.PAA05624@allur.sanmateo.akamai.com>
		<20050602161341.3d94f17b.akpm@osdl.org>
		<429FA5D4.87FD9B6C@akamai.com> <20050602175327.6e257d94.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> Prasanna Meda <pmeda@akamai.com> wrote:
> >
> > >
> > > Given that you need to patch the kernel to support larger SCM_MAX_FD, why
> > > not add this patch at the same time, keep it out of the main tree?
> >
> > Can do.
> > Ideally every fd openable should be passed over. I work towards that goal
> > and submit again.
>
> No.
>
> I meant that given that you are already patching your personal kernel to make
> SCM_MAX_FD larger, why don't you simultaneously apply this patch?

> In other words: why does the kernel.org kernel need this patch?

I agreed that I can apply both the changes locally.

kernel.org does not  get direct benifit.  It is merely benificial to people
who wants to use more fds.   I just thought  changing  SCM_MAX_FD
is easier  for them than changing macro and adding code .



Thanks,
Prasanna.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
